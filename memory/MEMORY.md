# PR/Commit Preferences
- Always add label `platform-sre-team` when pushing PRs (on va.gov-team repo)
- Always add label `platform-sre` (not `platform-sre-team`) on `vsp-infra-application-manifests` PRs — that repo uses a different label name
- Do NOT include `Co-Authored-By` lines in commit messages
- Do NOT include "Generated with Claude Code" or any Claude attribution in PR bodies

---

# Accuracy Standards
- **100% accuracy required on 100% of content** — zero tolerance for unverified claims
- If accuracy is uncertain, always dig deeper (search codebase, check PRs, verify claims) before including in output
- Never assume — verify every claim against the actual code, especially comparisons to other code patterns
- If a claim can't be verified to 100% confidence, do not include it; investigate further first
- This applies to all review documents, recommendations, and technical findings

---

# GHEC-US Migration - Ticket #134015

## Key Info
- Legacy org: `department-of-veterans-affairs` on github.com
- GHEC-US org: `software` on `va.ghe.com`
- GHEC-US usernames are `FirstName-LastName` format (Entra ID)
- User's legacy login: `stiehlrod`, GHEC-US login: `Jennica-Stiehl`
- Kerry's legacy login: `KerryMin`, GHEC-US login: `Kerry-ann-Minott`
- CSV mapping file: `/Users/jennicastiehl/github/dova-users.csv`

## Scripts (in /Users/jennicastiehl/github/ghec-migration/)
- `inventory_teams.py` — Main migration script (Phases A-D)
- `cleanup_membership.py` — Remove yourself from teams you don't belong on
- `backend-repos.txt` — Backend SRE repo list (11 repos): platform-atlas, fhir_client, govdelivery-tms, apivore, betamocks, breakers, bgs_ext, gibct-data-service, vets-api, vets-api-mockdata, vets-json-schema
- Originals attached to ticket #134015 as GitHub artifacts; download fresh from there if local copies are missing
- Re-run workflow (add new members to existing teams): Phase A → Phase B → Phase D `--maintainer Jennica-Stiehl` (skip Phase C since teams exist; PUT API is idempotent so re-runs are safe)

## Workflow for Adding a New Repo
1. Check admin access: `gh api repos/department-of-veterans-affairs/{repo} --jq '{visibility, permissions}'`
2. List teams: `gh api repos/department-of-veterans-affairs/{repo}/teams --paginate`
3. Add new teams to manifest (inventory members + roles for teams not already in manifest)
4. Check which new teams already exist on GHEC-US
5. Pick one small NEW team for test — dry-run Phase C + D first
6. Run Phase C + D for the test team, verify maintainer + roles
7. Run Phase C + D for remaining new teams
8. Pre-existing teams on GHEC-US are managed by whoever created them (usually Kerry)

## Important Flags
- `--maintainer Jennica-Stiehl` on BOTH Phase C and Phase D (prevents catch-22 lockout)
- `--dry-run` always first
- `--team-filter {slug}` for single-team testing

## Gotchas
- Phase C sets you as maintainer, but Phase D will overwrite to member unless `--maintainer` is passed to Phase D too
- If maintainer fails on Phase C, team is auto-deleted (rollback safety)
- Pre-existing teams: can't add maintainer unless you're already maintainer or org owner
- `user/teams` API only works for the authenticated user
- Phase B CSV parsing needs `encoding="utf-8-sig"` for Windows line endings

## Repos Completed
- 11 backend SRE repos (all except connect_vbms — handled by another team)
- va.gov-team
- va.gov-team-sensitive
- Manifest: 132 teams total

## Pending
- `connect_vbms` — handled by another team
- Repo permissions — separate ticket #134031
- Cleanup membership — run before migration with `cleanup_membership.py`
- Announce in #vfs-all-teams after full migration

---

# Feedback
- [new-ticket: don't add backend label to FE tickets](feedback_new_ticket_label.md) — check existing labels first; skip label step if ticket is already labeled frontend
- [Output save location](feedback_output_save_location.md) — all generated files go to /Users/jennicastiehl/github/.claude/claude-results/ unless they belong in a repo
- [collab-review: save location](feedback_collab_review_save_location.md) — save review files to /Users/jennicastiehl/github/.claude/claude-results/collab-reviews/
- [review-docs: check for existing file first](feedback_review_docs_check_existing.md) — always check doc-reviews/ for an existing file before starting a new review
- [PR review: team approval only](feedback_pr_review_team_approval.md) — next batch should only include PRs with existing team approval
- [PR review: priority engineers](feedback_pr_priority_engineers.md) — PRs from team members (Wayne, Evan, David, etc.) should be reviewed first
- [PR review: oldest first](feedback_pr_review_oldest_first.md) — sort queue oldest-first (lowest PR#) to respect 24hr SLA
- [Standup format](feedback_standup.md) — use actual last working day, don't assume Friday on Mondays
- [GHEC-US clones live in ghec/](feedback_ghec_clone_location.md) — newly migrated repos go in /Users/jennicastiehl/github/ghec/, not top level
- [GHEC-US is source of truth for ticket state](feedback_ghec_ticket_source_of_truth.md) — query software/va.gov-team on va.ghe.com; legacy github.com repo is locked for migration and stale
- [Ticket pointing: SRE team calibration](feedback_ticket_pointing_sre.md) — default lower than instinct; team treats high-volume per-item work, cross-team comms, and small-surface investigation as routine
- [Ticket and PR standards](feedback_ticket_standards.md) — ticket numbers in PRs, updates every 2 days, plain-language AC for non-tech audiences, task-completeness hooks, refine /ticket-create
- [ticket-create: always include backend label](feedback_ticket_create_backend_label.md) — SRE tickets need `backend` label or pointing bot won't fire
- [ticket-create: verify all URLs before posting](feedback_ticket_url_verification.md) — tickets with bad URLs get sent back; verify every link resolves first
- [No auto-reply to PR comments](feedback_no_auto_reply_comments.md) — always show proposed reply text and get explicit approval before posting to GitHub
- [PR review: always verify GitHub approval state](feedback_pr_pending_approval_check.md) — query GitHub, don't track from session memory
- [PR review: three-bucket tracking](feedback_pr_review_tracking.md) — needs-re-review / needs-GitHub-review / done, not flat "pending approval"
- [PR review: no intermediate check-ins](feedback_pr_review_no_checkins.md) — run full batch workflow end-to-end without pausing to ask for confirmation
- [PR review: skip draft PRs](feedback_pr_review_no_drafts.md) — never include draft PRs in the review queue
- [PR review: diff-only findings](feedback_pr_review_diff_only.md) — only flag issues on lines actually in the diff; never flag existing unchanged code
- [PR review: COMMENTED ≠ done](feedback_pr_commented_not_done.md) — COMMENTED review state does not count as reviewed; only APPROVED or CHANGES_REQUESTED does
- [No self-assign on tickets](feedback_no_self_assign.md) — never self-assign GitHub issues; only assign if user explicitly requests it
- [collab-review: GitHub post length](feedback_collab_review_post_length.md) — only post actionable items + closing note to GitHub; not the full review (no BLUF, no AI verification table, no positive observations)
- [collab-review: no self-cc on posts](feedback_collab_review_no_self_cc.md) — never cc @Jennica-Stiehl on comments posted as her; she is the author
- [Sandbox is a high environment](feedback_sandbox_is_high_env.md) — customers test in sandbox; treat it with same rigor as prod, validate independently, never bundle with staging
- [No auto-check boxes on GitHub issues](feedback_no_auto_check_boxes.md) — never check all boxes automatically; show unchecked list and ask user which ones are done before checking anything
- [Close ticket: check tasks first](feedback_close_ticket_check_tasks.md) — before closing any issue, review all Tasks and ACs, confirm with user, check off completed items, then close

# Projects
- [OOB Single-Commit Deploy Strategy](project_oob_deploy_strategy.md) — deploy individual commits to prod via manifest pinning, not all accumulated changes

# Projects (continued)
- [GHEC-US gem access app](project_ghec_gem_access_app.md) — Post-migration: install vets-api-gem-access app on 6 gem repos for CI bundle install
- [vets-api-mockdata OIDC + ECR](project_vets_api_mockdata_oidc.md) — Uses gha_sre_sbom_oidc_role (narrow); Steven granting ECR base-image perms; do NOT swap to vets-api-gha-oidc-role
- [Sprint 1 pointing estimates](project_sprint1_pointing_estimates.md) — Recalibrated estimates for the 6 needs-refinement tickets carried into Sprint 1 (May 7-20); compare against team vote
- [Sprint 2 OY4 pointing estimates](/Users/jennicastiehl/github/refinement/2026-05-11-sprint2-pointing.md) — Estimates for 10 unpointed Sprint 2 tickets (May 21–Jun 03); total 23pts; flags on #128857 (blank AC) and #132301 (needs-info)

# References
- [Support rotation calendar](reference_support_rotation.md) — Google Calendar is source of truth for rotation schedule
- [SRE GitHub Project board](reference_sre_project_board.md) — Project #1335 on `department-of-veterans-affairs` for SRE sprints
