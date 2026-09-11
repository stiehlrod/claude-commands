---
name: pr-review
description: Perform a thorough code review of the current branch. Focuses on correctness, simplicity, duplication, and project patterns.
---

# PR Review

Review the code in the branch we're currently in.

## Git Context — Auto-Detect

Before reviewing, detect your git context:
```bash
if [ "$(git rev-parse --git-dir 2>/dev/null)" = "$(git rev-parse --git-common-dir 2>/dev/null)" ]; then echo "NORMAL"; else echo "WORKTREE"; fi
```
- **NORMAL**: Use `git diff main...HEAD` for branch changes
- **WORKTREE**: Use `git diff HEAD` — do NOT assume `main` exists or that merge-base is meaningful. Do NOT run destructive git commands. Prefer inspecting the working tree directly.

## Instructions

Please perform a **thorough yet pragmatic code review** of these files. Focus on correctness, simplicity, duplication, and adherence to established project patterns — not on lint or formatting issues already enforced by CI.

### **🔍 Review Focus**

#### **1. Scope & Purpose**

- Does the PR do **one clear thing**? (optional - i often fail at this)

- Is the solution the **simplest that could work**?

- Are unrelated or experimental changes excluded?

#### **2. Code Quality, Architecture & Duplication**

- Is the code **clean, readable, and maintainable**?

- Any **dead, orphaned, or unnecessary code**?

- Does it follow **project conventions and namespaces**?

- Are abstractions (services, presenters, query objects) used appropriately?

**Legacy / Backwards-Compatibility Code (project-policy-dependent):**

If the project is pre-MVP / pre-v1 with no production users, there should be **zero code** handling:

- "Legacy" data formats or migrations from old formats
- "Backwards compatibility" with previous versions
- "v1 format" vs "v2 format" handling
- Fallback logic for "old" data structures
- Comments like "for backwards compatibility" or "legacy support"

For pre-MVP projects, when data format changes the old data should simply be deleted or ignored — not migrated. For projects with production users, the opposite is true: a migration path is required.

**Pick a policy for your project and apply it consistently.**

**Feature Duplication:**

- No duplicate controllers serving the same purpose (e.g., blog_tags vs tags)

- No duplicate routes pointing to similar endpoints

- No duplicate database migrations or schema definitions

- No duplicate test files in different directories

**Code Duplication:**

- Repeated logic extracted into methods/services/concerns

- Similar view partials consolidated with parameters

- Duplicate queries moved to scopes or query objects

- Shared validation logic in models/concerns

- Repeated JavaScript extracted into reusable functions/controllers

#### **3. Correctness & Tests**

- Are new behaviors, edge cases, and error paths covered by tests?

- Are tests **clear, isolated, and behavior-focused** (not implementation-bound)?

- Any **flaky, skipped, or incomplete tests**?

#### **4. Performance & Data Integrity**

- Any **N+1 queries**, unindexed columns, or large data loads?

- Are migrations **reversible, safe, and minimal-risk**?

- Any logic that could **impact scalability or response time**?

#### **5. Security & Safety**

- Any risk of **SQL injection, XSS, CSRF, or leaked secrets**?

- Are **auth/authorization checks** consistent and enforced?

- Are errors handled gracefully without exposing sensitive data?

#### **6. Documentation & Deployment**

- Is documentation (README, CHANGELOG, comments) updated?

- Are there **feature flags or migration notes** for risky changes?

- Is this code **safe to deploy to production**?

### **⚠️ Auto-Fail Conditions**

Request changes immediately if:

- ❌ Tests are failing

- ❌ Secrets or credentials are committed

- ❌ Migrations are non-reversible or destructive

- ❌ Duplicate or orphaned features/code

- ❌ Debug or console code left in

- ❌ Legacy/backwards-compatibility handling that conflicts with the project's stated policy (see the Legacy section above — either it shouldn't exist in pre-MVP, or it's missing where production users require it)

### **✅ Approve When**

- ✅ All tests pass

- ✅ Code is clean, simple, and follows project patterns

- ✅ No performance, duplication, or security issues

- ✅ Documentation is updated

- ✅ Code is production-ready

**Claude Output Format:**

Group your feedback under the same section headings above.

For each section, list:

- ✅ What looks good

- ⚠️ What needs attention

- 💡 Suggestions for improvement
