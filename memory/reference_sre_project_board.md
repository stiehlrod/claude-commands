---
name: SRE GitHub Project board
description: Project numbers for the Platform SRE team's sprint board on GHEC-US (canonical) and the legacy github.com mirror
type: reference
originSessionId: 301166d0-bad9-42c7-aab4-5a1e95222330
---
**Canonical (GHEC-US):** Project **#358** under `software` on `va.ghe.com` — title "Platform SRE Team". This is the source of truth post-migration.
- URL: https://va.ghe.com/orgs/software/projects/358
- Project node ID: `PVT_kwDOAAEG5c1Ayg`
- Status field ID: `PVTSSF_lADOAAEG5c1Ays4ABAWs`

**Legacy (github.com):** Project **#1335** under `department-of-veterans-affairs` — read-only / stale post-migration.

Use this when invoking sprint-monitor or complete-tickets with sprint/iteration filters:
- `/sprint-monitor 358 mine` (GHEC-US) or `/sprint-monitor 1335 mine` (legacy, deprecated)
- `/complete-tickets sprint:<N> project:358`

Sprint field titles on GHEC-US follow `"Sprint N '26-'27"` format (e.g. `"Sprint 2 '26-'27"`). Legacy github.com sprints used plain `"Sprint 26"` format.

When querying GHEC-US project: use `GH_HOST=va.ghe.com gh project item-list 358 --owner software` and filter by `sprint.title` and `assignees` containing `Jennica-Stiehl`. Use `GH_HOST=va.ghe.com gh issue view <N> --repo software/va.gov-team` to fetch ticket bodies (not `--hostname` flag — that doesn't work for `gh issue view`).

**Token scope note:** Reading project state needs `read:project`; writing (e.g., status changes via `updateProjectV2ItemFieldValue`) needs the `project` scope. The default `gh auth login` token has only `read:project`.
