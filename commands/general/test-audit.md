---
name: test-audit
description: Analyze new/modified tests to identify low-value tests that should be deleted, consolidated, or rewritten.
---

# Test Value Audit

Analyze **only the new or modified tests** added in the current branch.

The goal is to identify **tests that provide little or no real value** and should likely be **deleted**, not fixed.

## Git Context — Auto-Detect

Before reviewing, detect your git context:
```bash
if [ "$(git rev-parse --git-dir 2>/dev/null)" = "$(git rev-parse --git-common-dir 2>/dev/null)" ]; then echo "NORMAL"; else echo "WORKTREE"; fi
```
- **NORMAL**: Use `git diff main...HEAD` for branch changes
- **WORKTREE**: Use `git diff HEAD` — do NOT assume `main` exists or that merge-base is meaningful. Do NOT run destructive git commands. Prefer inspecting the working tree directly.

## Instructions

This is **not** a coverage review and **not** a correctness review.

Assume all tests currently pass.

Focus on **test usefulness, signal, and long-term maintenance cost**.

### 1. Low-Signal Tests

Tests that add maintenance burden without catching real bugs:

- Assert trivial behavior (getters, simple validations already covered elsewhere)
- Mirror implementation details instead of behavior
- Duplicate coverage already provided by other tests
- Test framework/library behavior instead of application behavior
- Assert constants, enums, or static mappings without risk
- Exist only to bump coverage numbers
- Would not fail under any realistic regression

### 2. Brittle Tests

Tests that break frequently for wrong reasons:

- Over-mocked, tightly coupled to internal structure
- Re-test private methods indirectly without meaningful assertions
- Test generated, boilerplate, or configuration code with no branching logic
- Depend on specific implementation details that could change
- Use hardcoded values that are likely to change

### 3. Redundant Tests

Tests that duplicate what other tests already verify:

- Multiple tests covering the exact same code path
- Integration tests that duplicate unit test assertions
- Tests that verify behavior already guaranteed by the framework

### 4. Tests Missing the Point

Tests that technically pass but don't verify what matters:

- Test setup that's more complex than the assertion
- Assertions that don't actually verify the behavior
- Happy path only with no edge case coverage
- Tests that pass regardless of implementation

## What To Do

For each test reviewed, categorize as:

- **DELETE** ❌: Test adds no value, remove it
- **CONSOLIDATE** ⚠️: Merge with another test
- **REWRITE** 🔁: Change to test meaningful behavior instead
- **KEEP** ✅: Genuinely valuable test

For each non-KEEP candidate:
- Explain **why the test adds little value**
- Explain **what regression it would (or would not) catch**
- For REWRITE: name the actual behavior that should be tested instead

Be opinionated. We prefer **fewer, stronger tests** over broad but shallow coverage.

## Philosophy

A good test:
- Tests behavior, not implementation
- Would fail if the behavior broke
- Is easy to understand and maintain
- Doesn't duplicate other tests

## Claude Output Format

### Summary

- Overall test quality: ✅ strong / ⚠️ mixed / ❌ weak
- Number of tests likely safe to delete
- Biggest patterns of low-value testing observed (Low-Signal / Brittle / Redundant / Missing the Point)

### Findings

For each test file reviewed:

- ❌ Tests to delete (with reasons + category)
- ⚠️ Tests to consolidate (with target test)
- 🔁 Tests to rewrite (with what to test instead)
- ✅ Tests that are genuinely valuable
