#!/bin/bash
# Smoke-test an installed s3proxy release by performing a full S3 round-trip
# THROUGH the s3proxy Service: create bucket -> put -> get -> compare -> list ->
# delete. Uses the AWS CLI over a kubectl port-forward, authenticating with the
# s3proxy client credentials (config.auth.identity / config.auth.secret).
#
# Usage: smoke-test.sh RELEASE NAMESPACE PORT IDENTITY SECRET
#
# Exit non-zero on any failure (a broken backend wiring makes the round-trip fail).
set -euo pipefail

RELEASE="${1:?release name required}"
NAMESPACE="${2:?namespace required}"
PORT="${3:-9000}"
IDENTITY="${4:?s3proxy client identity required}"
SECRET="${5:?s3proxy client secret required}"

LOCAL_PORT=9900
BUCKET="smoke-$(date +%s)"
ENDPOINT="http://127.0.0.1:${LOCAL_PORT}"
SRC="$(mktemp)"
DL="$(mktemp)"

export AWS_ACCESS_KEY_ID="$IDENTITY"
export AWS_SECRET_ACCESS_KEY="$SECRET"
export AWS_DEFAULT_REGION=us-east-1
export AWS_EC2_METADATA_DISABLED=true
# AWS CLI v2.23+ adds default data-integrity checksums (CRC headers on PUT and
# x-amz-checksum-mode on GET) that S3Proxy / jclouds S3-compatible backends do
# not implement ("NotImplemented"). Only send/validate them when required.
export AWS_REQUEST_CHECKSUM_CALCULATION=when_required
export AWS_RESPONSE_CHECKSUM_VALIDATION=when_required
# s3proxy is not virtual-host aware over an IP endpoint — force path-style.
aws configure set default.s3.addressing_style path

PF_PID=""
cleanup() {
  if [ -n "$PF_PID" ]
  then
    kill "$PF_PID" 2>/dev/null || true
  fi
  rm -f "$SRC" "$DL"
}
trap cleanup EXIT

echo "==> Waiting for deploy/${RELEASE} to be ready"
kubectl -n "$NAMESPACE" rollout status "deploy/${RELEASE}" --timeout=120s

echo "==> Port-forwarding svc/${RELEASE} ${LOCAL_PORT}:${PORT}"
kubectl -n "$NAMESPACE" port-forward "svc/${RELEASE}" "${LOCAL_PORT}:${PORT}" >/tmp/s3proxy-pf.log 2>&1 &
PF_PID=$!

echo "==> Waiting for the port-forward to accept connections"
ready=false
for _ in $(seq 1 30)
do
  if curl -s -o /dev/null "$ENDPOINT"
  then
    ready=true
    break
  fi
  sleep 1
done
if [ "$ready" != "true" ]
then
  echo "ERROR: s3proxy did not become reachable on ${ENDPOINT}" >&2
  cat /tmp/s3proxy-pf.log >&2 || true
  exit 1
fi

AWS=(aws --endpoint-url "$ENDPOINT")

echo "==> Creating bucket: $BUCKET"
"${AWS[@]}" s3api create-bucket --bucket "$BUCKET"

echo "==> Uploading object"
echo "hello-s3proxy round-trip $(date +%s)" > "$SRC"
"${AWS[@]}" s3 cp "$SRC" "s3://${BUCKET}/smoke.txt"

echo "==> Downloading object"
"${AWS[@]}" s3 cp "s3://${BUCKET}/smoke.txt" "$DL"

echo "==> Verifying round-trip integrity"
cmp "$SRC" "$DL"

echo "==> Listing bucket"
"${AWS[@]}" s3 ls "s3://${BUCKET}/"

echo "==> Cleaning up"
"${AWS[@]}" s3 rm "s3://${BUCKET}/smoke.txt"
"${AWS[@]}" s3api delete-bucket --bucket "$BUCKET" || true

echo "✅ Smoke test passed for release '${RELEASE}'"
