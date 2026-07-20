# Contributing to s3proxy-chart

Thanks for contributing! This chart deploys [S3Proxy](https://github.com/gaul/s3proxy)
to Kubernetes. Please read the notes below before opening a pull request.

## Chart layout

- The chart lives in [`charts/s3proxy/`](charts/s3proxy).
- **`README.md` is auto-generated** by helm-docs from
  [`charts/s3proxy/README.md.gotmpl`](charts/s3proxy/README.md.gotmpl) and
  `values.yaml` doc comments. Never edit `README.md` directly — edit the template
  and/or the `values.yaml` comments.
- Bump `version` in [`charts/s3proxy/Chart.yaml`](charts/s3proxy/Chart.yaml) for any
  change under `charts/s3proxy/**` — the `verify-chart-version` check enforces that
  the version is greater than the latest release.

## CI checks

Every PR runs three checks (all on GitHub-hosted runners — no self-hosted runners,
no secrets, so they are safe to run for fork PRs):

| Workflow | What it does | Gate |
|----------|--------------|------|
| **Lint & Render** (`lint-render.yaml`) | `helm lint` + `helm template` + `kubeconform` schema validation across one value set per backend in [`test-values/`](test-values) | Blocking |
| **Helm Render Diff** (`helm-diff.yaml`) | Renders each `test-values/` scenario on the PR base and head and posts a manifest diff as a sticky PR comment | Informational |
| **Functional Test (kind)** (`functional-test.yaml`) | Spins up an ephemeral [kind](https://kind.sigs.k8s.io) cluster, deploys mock backends ([MinIO](https://min.io), [Azurite](https://github.com/Azure/Azurite)), installs the chart, and runs a real S3 round-trip through s3proxy | Blocking (azureblob leg non-blocking, see below) |

### Adding coverage for a change

- Touching a template or `values.yaml`? Make sure the affected backend has a
  representative file in [`test-values/`](test-values); add one if not.
- Adding functional coverage for a backend needs a lightweight in-cluster mock
  (see [`ci/functional/mocks/`](ci/functional/mocks)) and a values file in
  [`ci/functional/values/`](ci/functional/values), then a matrix entry in
  `functional-test.yaml`.

### Known non-blocking legs

The functional test surfaced pre-existing chart bugs. These legs run with
`continue-on-error` so they do not block PRs, and each will auto-go-green once its
bug is fixed — the failing round-trip is the functional test doing its job:

- **filesystem** / **transient** — the chart does not emit
  `jclouds.identity`/`jclouds.credential` for local backends, so s3proxy refuses
  to start. Tracked in **DND-1442**.
- **azureblob** — the chart emits `jclouds.azureblob.endpoint` instead of the
  provider-agnostic `jclouds.endpoint`, so a custom endpoint (including the Azurite
  mock) is ignored. Tracked in **DND-1416**.

The **s3 → MinIO** leg is the blocking functional gate.

`autoscaling` is deliberately not enabled in any `test-values/` scenario because
`hpa.yaml` still emits the removed `autoscaling/v2beta1` API (kubeconform rejects
it) — tracked in **DND-1443**. Add an autoscaling scenario once that is fixed.

## Fork pull requests

All CI checks are secret-free and run on GitHub-hosted runners, so they are safe
to approve for external contributions. GitHub requires a maintainer to approve
workflow runs for first-time / outside contributors — approving them is safe here
because none of these workflows hold credentials or touch Comet infrastructure.

## Local validation

```bash
# Lint + render + schema-validate a scenario
helm lint charts/s3proxy -f test-values/s3.yaml
helm template s3proxy charts/s3proxy -f test-values/s3.yaml --kube-version 1.29.0 \
  | kubeconform -strict -summary -kubernetes-version 1.29.0 -schema-location default -

# Functional round-trip against a local kind cluster
kind create cluster
kubectl create namespace s3proxy-test
kubectl apply -n s3proxy-test -f ci/functional/mocks/minio.yaml
kubectl -n s3proxy-test rollout status deploy --timeout=180s
helm upgrade --install s3proxy charts/s3proxy -n s3proxy-test \
  -f ci/functional/values/s3.yaml --wait --timeout 5m
ci/functional/smoke-test.sh s3proxy s3proxy-test 9000 test-access-key test-secret-key
kind delete cluster
```
