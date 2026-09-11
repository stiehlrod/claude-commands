# Summary Template

Use this template when all reviews are complete.

## File Location

`.claude/reviews/{branch-name}/SUMMARY.md`

## Template

````markdown
# Review Pipeline Summary

## Overview

| Field | Value |
|-------|-------|
| **Branch** | `{branch_name}` |
| **Started** | {start_timestamp} |
| **Completed** | {end_timestamp} |
| **Duration** | {duration} |
| **Total Issues** | {n} |
| **Total Commits** | {n} |

---

## Reviews Executed

| # | Review | Issues | Commits | Status |
|---|--------|--------|---------|--------|
| 1 | Architecture & Design | {n} | {n} | ✅ Complete |
| 2 | Security | {n} | {n} | ✅ Complete |
| 3 | Authorization | {n} | {n} | ✅ Complete |
| 4 | Design Audit | {n} | {n} | ✅ Complete |
| 5 | Accessibility | {n} | {n} | ✅ Complete |
| 6 | Test Coverage | {n} | {n} | ✅ Complete |
| 7 | Test Audit | {n} | {n} | ✅ Complete |
| 8 | PR Review | {n} | {n} | ✅ Complete |
| | **Total** | **{n}** | **{n}** | |

*Note: Design Audit and Accessibility only run if frontend changes detected.*

---

## Issues by Severity

| Severity | Count |
|----------|-------|
| 🚨 Critical | {n} |
| ⚠️ High | {n} |
| 🟡 Medium | {n} |
| 🟢 Low | {n} |
| **Total** | **{n}** |

---

## All Commits (Chronological)

| # | Commit | Issue | Review | Description |
|---|--------|-------|--------|-------------|
| 1 | `{sha}` | ARCH-001 | Architecture | {description} |
| 2 | `{sha}` | ARCH-002 | Architecture | {description} |
| 3 | `{sha}` | SEC-001 | Security | {description} |
| ... | ... | ... | ... | ... |

---

## Individual Reports

- [Architecture & Design](01-architecture.md)
- [Security](02-security.md)
- [Authorization](03-authorization.md)
- [Design Audit](04-design-audit.md) *(if applicable)*
- [Accessibility](05-accessibility.md) *(if applicable)*
- [Test Coverage](06-test-coverage.md)
- [Test Audit](07-test-audit.md)
- [PR Review](08-pr-review.md)

---

## Verification

To verify any fix, you can revert the specific commit:

```bash
# Revert a specific fix
git revert {commit_sha}

# Or view what a commit changed
git show {commit_sha}
```

---

## Ready for Merge

✅ **All reviews complete. All issues resolved. Ready to merge.**
````

## Notes

- Create this file only after ALL reviews complete
- Link to individual report files for details
- List commits in chronological order (oldest first)
- Include the verification section so reviewers know how to revert if needed
