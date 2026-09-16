---
name: PR review: skip draft PRs
description: Never include draft PRs in the review queue
type: feedback
originSessionId: 05643837-3a9b-4cf3-9fb7-ba8b48563f1f
---
Skip PRs where `isDraft: true`. Add `--draft=false` to gh search commands or filter out drafts from JSON results before checking teammate approval.

**Why:** Draft PRs are not ready for review — they're works in progress.

**How to apply:** In every `gh search prs` or `gh pr view` call for queue building, filter out drafts. When fetching PR metadata with `--json`, include `isDraft` in the fields and exclude any PR where `isDraft == true`.
