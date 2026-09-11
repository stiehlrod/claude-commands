# PR Review Criteria (Final Gate)

**Issue Prefix**: `PR`
**Condition**: Always run (last review in pipeline)

## Purpose

This is the **final gate** before merge. By the time this review runs, all other reviews should have passed. This review does a holistic check to ensure the code is production-ready.

## Focus Areas

### 1. Scope & Purpose

- Does the PR do **one clear thing**?
- Is the solution the **simplest that could work**?
- Are unrelated or experimental changes excluded?

### 2. Code Quality & Maintainability

- Is the code **clean, readable, and maintainable**?
- Any **dead, orphaned, or unnecessary code**?
- Does it follow **project conventions and namespaces**?
- Are abstractions used appropriately?

### 3. Legacy / Backwards-Compatibility Code (project-policy-dependent)

If the project has production users and supports legacy data, skip this section. If the project is pre-MVP / pre-v1 with no production users, apply the stricter rule:

- "Legacy" data formats or migrations from old formats
- "Backwards compatibility" with previous versions
- "v1 format" vs "v2 format" handling
- Fallback logic for "old" data structures
- Comments like "for backwards compatibility" or "legacy support"

For pre-MVP projects, when data format changes the old data should simply be deleted or ignored — not migrated. For projects with production users, the opposite is true: a migration path is required.

**Pick a policy for your project and apply it consistently.** Reviewers should not have to guess.

### 4. Duplication Check

**Feature Duplication:**
- No duplicate controllers serving the same purpose
- No duplicate routes pointing to similar endpoints
- No duplicate database migrations or schema definitions
- No duplicate test files in different directories

**Code Duplication:**
- Repeated logic extracted into methods/services/concerns
- Similar view partials consolidated with parameters
- Duplicate queries moved to scopes or query objects
- Shared validation logic in models/concerns
- Repeated JavaScript extracted into reusable functions/controllers

### 5. Tests & Correctness

- Are new behaviors, edge cases, and error paths covered by tests?
- Are tests **clear, isolated, and behavior-focused**?
- Any **flaky, skipped, or incomplete tests**?
- Do all tests pass?

### 6. Performance & Data Integrity

- Any **N+1 queries**, unindexed columns, or large data loads?
- Are migrations **reversible, safe, and minimal-risk**?
- Any logic that could **impact scalability or response time**?

### 7. Documentation & Deployment

- Is documentation (README, CHANGELOG, comments) updated if needed?
- Are there **feature flags or migration notes** for risky changes?
- Is this code **safe to deploy to production**?

## Auto-Fail Conditions

These should have been caught in earlier reviews, but verify:

- Tests are failing
- Secrets or credentials committed
- Migrations are non-reversible or destructive
- Duplicate or orphaned features/code
- Debug or console code left in
- Legacy/backwards-compatibility handling that conflicts with the project's policy (see Section 3 — either it shouldn't exist in pre-MVP, or it's missing where production users require it)

## Severity Classification

| Severity | Criteria |
|----------|----------|
| Critical | Blocks merge: tests failing, secrets committed, destructive migration |
| High | Should fix before merge: significant code quality issue |
| Medium | Should fix: minor issue that could cause problems |
| Low | Nice to fix: polish, minor improvements |

## Output Format

For each issue found, capture:

```yaml
id: PR-001
title: Short description
severity: Critical|High|Medium|Low
file: path/to/file.rb
line: 45
category: Scope|Quality|Legacy|Duplication|Tests|Performance|Docs
description: |
  Explanation of the issue
recommended_fix: |
  Specific fix
blocked_by: []
```

## Approval Criteria

Approve when:
- All tests pass
- Code is clean, simple, and follows project patterns
- No performance, duplication, or security issues
- Documentation is updated (if needed)
- Code is production-ready
- No issues from previous reviews remain unfixed
