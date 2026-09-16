---
name: GHEC-US clones live in ghec/ subdirectory
description: Local clones of repos migrated to GHEC-US (va.ghe.com) belong in /Users/jennicastiehl/github/ghec/, not at the top level
type: feedback
originSessionId: 95973956-1ad6-4474-9ad1-c528205aa250
---
Local clones of repos that have been migrated to GHEC-US (`va.ghe.com/software/...`) should live in `/Users/jennicastiehl/github/ghec/<repo>`, not at `/Users/jennicastiehl/github/<repo>`.

**Why:** During the GHEC-US migration there can be both a legacy clone (from `github.com/department-of-veterans-affairs/...`) and a new GHEC-US clone of the same repo. Keeping GHEC-US clones segregated under `ghec/` prevents confusion about which clone you're working in — the path itself tells you.

**How to apply:**
- When cloning a newly-migrated repo, clone into `/Users/jennicastiehl/github/ghec/<repo>` (e.g. `git clone https://va.ghe.com/software/vets-api-mockdata.git ghec/vets-api-mockdata`).
- If you find a GHEC-US clone at the top level (`/Users/jennicastiehl/github/<repo>` with `va.ghe.com` origin), move it into `ghec/` — `mv` preserves git state including branches and uncommitted work.
- Top-level `/Users/jennicastiehl/github/` is reserved for legacy `github.com` clones and ad-hoc tooling like `ghec-migration/` and `dova-users.csv`.
- As of 2026-04-30, `vets-api-mockdata` and `vsp-infra-application-manifests` were the first two relocated.
