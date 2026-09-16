---
name: ticket-create: verify all URLs before posting
description: Tickets with bad URLs get sent back — verify every link resolves before creating
type: feedback
originSessionId: c055e2a0-047f-4c23-9bbf-fe34cc9f8a2d
---
Every URL in a ticket body or context comment must be verified before the ticket is created. This includes GitHub issue/PR links, file paths, and Confluence pages. Tickets with broken links have been returned.

**Why:** User has had multiple tickets sent back for broken or incorrect URLs.

**How to apply:** Before calling `gh issue create`, extract all URLs and verify each one:
- GitHub issues/PRs: `GH_HOST=va.ghe.com gh api repos/software/<repo>/issues/<number> --jq '.number'`
- GitHub file paths: `GH_HOST=va.ghe.com gh api repos/software/<repo>/contents/<path> --jq '.name'`
- Confluence: `curl -sI <url> | head -1` — must return 200
- If a URL fails: remove it from the ticket, do not include it unverified
