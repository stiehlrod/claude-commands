---
name: ticket-create: always include backend label for SRE tickets
description: SRE template tickets must include backend label — omitting it breaks project automation
type: feedback
originSessionId: c055e2a0-047f-4c23-9bbf-fe34cc9f8a2d
---
Always include `backend` in the label list when creating SRE template tickets, even though the SRE template description only lists `needs-refinement` and `platform-sre-team`. The actual `gh issue create` command in the skill includes `backend`, and project board automation (including pointing bot) may key off it.

**Why:** Missing `backend` label caused pointing bot not to fire on ticket #155212.

**How to apply:** For all SRE template tickets, use `--label "needs-refinement,platform-sre-team,backend"` — never just the two-label version.
