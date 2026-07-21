#!/bin/bash
# Multi-backend routing assertion for the s3proxy functional test.
#
# Writes one bucket per backend THROUGH s3proxy (smoke-s3-*, smoke-az-*,
# smoke-fs-*) and proves each object physically landed on its INTENDED backend by
# querying that backend's native store directly:
#   * s3         -> MinIO (S3 API)       : bucket+object present in MinIO.
#   * azureblob  -> Azurite (Azure API)  : container+blob present in Azurite.
#   * filesystem -> (no external store)  : absent from MinIO AND Azurite.
# It also cross-checks that no bucket leaks into another backend's store, i.e.
# routing is EXCLUSIVE — this is what the old test missed (every bucket silently
# landed on the single default backend, so it passed without exercising routing).
#
# Assumes the multi-backend release is installed with MinIO + Azurite mocks in
# the same namespace (ci/functional/mocks/{minio,azurite}.yaml) and the values in
# ci/functional/values/multi-backend.yaml. Requires kubectl, aws and az on PATH.
#
# Usage: assert-routing.sh RELEASE NAMESPACE
set -euo pipefail

RELEASE="${1:?release name required}"
NAMESPACE="${2:?namespace required}"

# Fixed CI credentials (match multi-backend.yaml + the mock manifests).
S3P_ID=test-access-key
S3P_SECRET=test-secret-key
MINIO_ID=minioadmin
MINIO_SECRET=minioadmin
AZ_ACCOUNT=devstoreaccount1
AZ_KEY="Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw=="

TS=$(date +%s)
B_S3="smoke-s3-${TS}"
B_AZ="smoke-az-${TS}"
B_FS="smoke-fs-${TS}"

S3P_PORT=9900
MINIO_PORT=9901
AZ_PORT=9902
SRC="$(mktemp)"
DL="$(mktemp)"
PIDS=""

# AWS CLI defaults that S3Proxy / jclouds S3-compatible backends need:
# path-style addressing over an IP endpoint, and no default CRC checksums
# (AWS CLI v2.23+) which the backends answer with NotImplemented.
export AWS_EC2_METADATA_DISABLED=true
export AWS_REQUEST_CHECKSUM_CALCULATION=when_required
export AWS_RESPONSE_CHECKSUM_VALIDATION=when_required
aws configure set default.s3.addressing_style path

cleanup() {
  # Best-effort: remove the test buckets through s3proxy, then kill forwards.
  for b in "$B_S3" "$B_AZ" "$B_FS"; do
    s3p s3 rm "s3://${b}/obj.txt" >/dev/null 2>&1 || true
    s3p s3api delete-bucket --bucket "$b" >/dev/null 2>&1 || true
  done
  for p in $PIDS; do kill "$p" 2>/dev/null || true; done
  rm -f "$SRC" "$DL"
}
trap cleanup EXIT

pf() { # pf <target> <local-port> <remote-port>
  kubectl -n "$NAMESPACE" port-forward "$1" "$2:$3" >"/tmp/pf-$2.log" 2>&1 &
  PIDS="$PIDS $!"
}

wait_tcp() { # wait_tcp <url>
  for _ in $(seq 1 30); do
    if curl -s -o /dev/null "$1"; then return 0; fi
    sleep 1
  done
  return 1
}

s3p() { # AWS CLI against s3proxy (client creds)
  AWS_ACCESS_KEY_ID="$S3P_ID" AWS_SECRET_ACCESS_KEY="$S3P_SECRET" \
    aws --endpoint-url "http://127.0.0.1:${S3P_PORT}" --region us-east-1 "$@"
}
minio() { # AWS CLI against MinIO directly (mock creds)
  AWS_ACCESS_KEY_ID="$MINIO_ID" AWS_SECRET_ACCESS_KEY="$MINIO_SECRET" \
    aws --endpoint-url "http://127.0.0.1:${MINIO_PORT}" --region us-east-1 "$@"
}
AZ_CONN="DefaultEndpointsProtocol=http;AccountName=${AZ_ACCOUNT};AccountKey=${AZ_KEY};BlobEndpoint=http://127.0.0.1:${AZ_PORT}/${AZ_ACCOUNT};"
azc() { az "$@" --connection-string "$AZ_CONN"; }

echo "==> Waiting for deploy/${RELEASE}"
kubectl -n "$NAMESPACE" rollout status "deploy/${RELEASE}" --timeout=120s

echo "==> Port-forwarding s3proxy / minio / azurite"
pf "svc/${RELEASE}" "$S3P_PORT" 9000
pf "svc/minio" "$MINIO_PORT" 9000
pf "svc/azurite" "$AZ_PORT" 10000
wait_tcp "http://127.0.0.1:${S3P_PORT}"  || { echo "ERROR: s3proxy unreachable" >&2; exit 1; }
wait_tcp "http://127.0.0.1:${MINIO_PORT}/minio/health/live" || wait_tcp "http://127.0.0.1:${MINIO_PORT}" || { echo "ERROR: minio unreachable" >&2; exit 1; }
# Azurite has no plain-GET health page; give the forward a moment to accept.
sleep 3

echo "hello-multibackend ${TS}" > "$SRC"

# 1) Write one object per backend through s3proxy and round-trip each.
for b in "$B_S3" "$B_AZ" "$B_FS"; do
  echo "==> [$b] create + put + get via s3proxy"
  s3p s3api create-bucket --bucket "$b"
  s3p s3 cp "$SRC" "s3://${b}/obj.txt"
  s3p s3 cp "s3://${b}/obj.txt" "$DL"
  cmp "$SRC" "$DL"
  echo "    round-trip OK"
done

# 2) s3 bucket must live in MinIO; az/fs must NOT.
echo "==> MinIO must hold ${B_S3} only"
minio s3api head-bucket --bucket "$B_S3"
minio s3 ls "s3://${B_S3}/obj.txt" >/dev/null || { echo "FAIL: object missing in MinIO for ${B_S3}" >&2; exit 1; }
if minio s3api head-bucket --bucket "$B_AZ" >/dev/null 2>&1; then echo "FAIL: ${B_AZ} leaked into MinIO" >&2; exit 1; fi
if minio s3api head-bucket --bucket "$B_FS" >/dev/null 2>&1; then echo "FAIL: ${B_FS} leaked into MinIO" >&2; exit 1; fi

# 3) azureblob container must live in Azurite; s3/fs must NOT.
echo "==> Azurite must hold ${B_AZ} only"
azc storage container show --name "$B_AZ" >/dev/null || { echo "FAIL: ${B_AZ} container missing in Azurite" >&2; exit 1; }
azc storage blob show --container-name "$B_AZ" --name obj.txt >/dev/null || { echo "FAIL: blob missing in Azurite for ${B_AZ}" >&2; exit 1; }
if azc storage container show --name "$B_S3" >/dev/null 2>&1; then echo "FAIL: ${B_S3} leaked into Azurite" >&2; exit 1; fi
if azc storage container show --name "$B_FS" >/dev/null 2>&1; then echo "FAIL: ${B_FS} leaked into Azurite" >&2; exit 1; fi

# 4) filesystem: proven by elimination (absent from both external stores above)
#    plus a successful s3proxy round-trip.
echo "==> ${B_FS} absent from MinIO and Azurite -> served by the filesystem backend"

echo "✅ Multi-backend routing verified: smoke-s3 -> MinIO, smoke-az -> Azurite, smoke-fs -> filesystem (routing is exclusive)"
