# S3Proxy Helm Chart

A Helm chart for deploying [S3Proxy](https://github.com/gaul/s3proxy) to Kubernetes.
The chart lives in `charts/s3proxy/`.

## README.md is generated: never hand-edit it, and never commit it in a PR

`README.md` (repo root) is generated from `charts/s3proxy/README.md.gotmpl` by
helm-docs. The values table is generated from the `# --` comments in
`charts/s3proxy/values.yaml`.

**When changing documentation:**

1. Edit **only** the source: `charts/s3proxy/README.md.gotmpl` (prose/sections) and
   `charts/s3proxy/values.yaml` (the `# --` comments that drive the values table).
2. **Never edit `README.md` by hand.**
3. **Never regenerate or commit `README.md` in a pull request.** The
   `release.yaml` workflow renders it from the template and commits it back to
   `main` on merge; `preview-readme.yaml` posts the rendered diff on the PR for
   review. A hand-rendered `README.md` in a PR only creates churn and merge
   conflicts with that automation. Leave `README.md` untouched in the PR diff.

## Helm chart conventions

- Validate rendering with `helm template` and `helm lint` after editing chart files.
- Keep `values.yaml` `# --` documentation comments in sync with any value changes
  (they feed the generated README values table).
- Preserve the existing YAML indentation style (spaces, per the YAML spec).
- The rendered manifests are schema-checked with `kubeconform -strict` and
  style-checked with helm-polish in CI (`lint-render.yaml`); run them locally
  before pushing when possible.
- Chart changes require a `Chart.yaml` `version` bump (`verify-chart-version.yaml`
  enforces this).
- Functional behavior is covered by kind-based tests in `ci/functional/` and the
  `functional-test.yaml` workflow; add a leg there when adding a feature that can
  be exercised end to end.
