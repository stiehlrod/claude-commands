# Report Template

Use this template when creating review reports.

## File Location

`.claude/reviews/{branch-name}/{##}-{review-type}.md`

Examples:
- `.claude/reviews/feature-user-auth/01-architecture.md`
- `.claude/reviews/feature-user-auth/02-security.md`

## Template

```markdown
---
review_type: {type}
review_number: {##}
branch: {branch_name}
created_at: {ISO timestamp}
status: in_progress
total_issues: {n}
resolved_issues: {n}
last_updated: {ISO timestamp}
---

# {Review Type} Review

**Branch**: `{branch_name}`
**Started**: {human readable timestamp}
**Status**: {IN PROGRESS|COMPLETE} ({resolved}/{total} resolved)

---

## Issues

### {TYPE}-001: {Title}

| Field | Value |
|-------|-------|
| **Severity** | {emoji} {Critical/High/Medium/Low} |
| **File** | `{path/to/file.rb}:{line}` |
| **Category** | {category from review criteria} |
| **Status** | {emoji} {PENDING/RESOLVED} |
| **Commit** | {— or sha} |
| **Blocked By** | {— or list of issue IDs} |

**Description:**
{Detailed explanation of the issue}

**Recommended Fix:**
{Specific fix with code example if helpful}

**Fix Applied:**
{— or description of what was done}

---

### {TYPE}-002: {Title}

[repeat for each issue]

---

## Summary

| Severity | Total | Resolved | Pending |
|----------|-------|----------|---------|
| 🚨 Critical | {n} | {n} | {n} |
| ⚠️ High | {n} | {n} | {n} |
| 🟡 Medium | {n} | {n} | {n} |
| 🟢 Low | {n} | {n} | {n} |
| **Total** | **{n}** | **{n}** | **{n}** |

## Commits

| Commit | Issue | Description |
|--------|-------|-------------|
| {sha} | {TYPE}-001 | {short description} |
| {sha} | {TYPE}-002 | {short description} |

---

**Next Action**: {Fix {TYPE}-{###} or REVIEW COMPLETE}
```

## Status Values

- `in_progress` - Review has pending issues
- `complete` - All issues resolved

## Severity Emojis

- 🚨 Critical
- ⚠️ High
- 🟡 Medium
- 🟢 Low

## Status Emojis

- ⏳ PENDING
- ✅ RESOLVED
- ⏸️ BLOCKED (waiting on dependency)

## Updating the Report

When fixing an issue:

1. Change status from `⏳ PENDING` to `✅ RESOLVED`
2. Add the commit SHA
3. Fill in "Fix Applied" with what was done
4. Increment `resolved_issues` in frontmatter
5. Update `last_updated` timestamp
6. Add commit to the Commits table
7. Update "Next Action" to next pending issue or "REVIEW COMPLETE"

When all issues resolved:

1. Change frontmatter `status` to `complete`
2. Update "Status" line to show "COMPLETE"
3. Set "Next Action" to "REVIEW COMPLETE"
