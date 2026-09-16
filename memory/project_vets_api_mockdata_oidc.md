---
name: vets-api-mockdata OIDC + ECR setup
description: Post-migration workflow auth on vets-api-mockdata uses OIDC with the narrowly-scoped sbom role; ECR base-image perms had to be granted by DevOps
type: project
originSessionId: c1affa47-bf9e-4551-8342-0f7701776154
---
## Setup
- Repo: `software/vets-api-mockdata` on `va.ghe.com`
- Auth on `build_vets_api.yml`: OIDC, role `arn:aws-us-gov:iam::008577686731:role/gha_sre_sbom_oidc_role` via repo variable `AWS_ASSUME_ROLE`
- `vets-api` itself uses a different, broader role: `vets-api-gha-oidc-role`. Steven prefers we DO NOT swap mockdata onto that role unless many other things demand it.

## Pre-migration vs post-migration
- Pre-migration: workflow used static `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` tied to an IAM user with broad ECR perms. No role.
- Post-migration: switched to OIDC with `gha_sre_sbom_oidc_role` (the only `AWS_ASSUME_ROLE` variable set up for the repo). The role's *trust* already includes `repo:software/vets-api-mockdata:*` (Steven confirmed) — but its *permissions* were narrowly scoped (sbom only) so ECR pulls 403'd.

## Resolution path
- Steven Venner (DevOps) is updating `gha_sre_sbom_oidc_role` to grant `ecr:BatchGetImage` / `ecr:GetDownloadUrlForLayer` on `008577686731/ruby` and `008577686731/dpokidov/imagemagick` (the upstream base images vets-api's Dockerfile pulls).
- Slack thread: `#platform-cop-devops` with Rachal Cassity and Steven Venner, 2026-04-29.

## Why: zero-tolerance accuracy on SBOM-vs-broad-role choice
- Reason: `gha_sre_sbom_oidc_role` is intentionally narrow. Don't reflexively suggest swapping to `vets-api-gha-oidc-role` — Steven prefers narrow scoping where possible.
- How to apply: when wiring AWS auth on a new GHEC-US repo, prefer the existing repo's `AWS_ASSUME_ROLE` variable; if a 403 arises, ask DevOps to grant the specific ECR perms rather than reaching for the broader role.

## Open after Steven's IAM change lands
- Verify build succeeds on PR #746 (currently `push: false` for testing)
- Flip `push: true` and confirm `ecr:PutImage` works on `dsva/vets-api` and `dsva/vets-api-postman`
- Remove `pull_request:` trigger if not desired long-term (or keep for fast feedback)
- Confirm "Release and Update Vets API Manifests" `workflow_run` cascade triggers
- Close ticket #136716 once master CI is green end-to-end
