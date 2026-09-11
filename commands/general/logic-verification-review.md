---
name: logic-verification-review
description: Verify that the code actually does what it's supposed to do. Catches "implemented the wrong thing correctly" — code that is well-structured, secure, and tested, but produces the wrong result or misses the intent. Especially valuable for AI-authored code.
---

# Logic Verification Review

Verify that the code in the current branch **actually does what it's supposed to do**. This is the review that catches "implemented the wrong thing correctly" — code that is well-structured, secure, tested, but produces the wrong result or misses the intent.

This is especially critical for AI-authored code, which tends to be structurally clean but can misinterpret requirements, use stale APIs, or implement subtly wrong algorithms.

## Git Context — Auto-Detect

Before reviewing, detect your git context:
```bash
if [ "$(git rev-parse --git-dir 2>/dev/null)" = "$(git rev-parse --git-common-dir 2>/dev/null)" ]; then echo "NORMAL"; else echo "WORKTREE"; fi
```
- **NORMAL**: Use `git diff main...HEAD` for branch changes
- **WORKTREE**: Use `git diff HEAD` — do NOT assume `main` exists or that merge-base is meaningful. Do NOT run destructive git commands. Prefer inspecting the working tree directly.

## Process

1. **Read the PR description and linked ticket** to understand intent
2. **Trace each changed method end-to-end** — follow data from input to output
3. **Verify edge cases** — nil, empty, boundary values, concurrent access
4. **Check that tests verify the right behavior**, not just that code runs

## Focus Areas

### 1. Semantic Correctness

- Does the method return what its name promises?
- Are conditional branches correct? (Is the `if` testing the right thing? Should it be `unless`?)
- Are comparisons correct? (`>` vs `>=`, `==` vs `===`, `include?` vs `start_with?`)
- Are boolean operators correct? (`&&` vs `||`, negation logic)
- Are early returns / guard clauses guarding the right conditions?
- Are default values sensible? (nil, 0, empty string, empty array)

### 2. Data Flow Errors

- Is data transformed correctly between layers? (controller → service → model)
- Are hash keys correct? (string vs symbol, snake_case vs camelCase)
- Are arguments passed in the right order?
- Are return values used correctly by callers?
- Is data mutated when it should be copied, or copied when it should be mutated?

### 3. Off-by-One and Boundary Errors

- Array/string indexing correct? (0-based, inclusive/exclusive ranges)
- Pagination: first page, last page, empty results
- Time calculations: timezone handling, DST transitions, midnight edge cases
- Numeric precision: floating point comparison, currency rounding, integer overflow

### 4. Nil Safety

- Can any variable be nil when the code assumes it's present?
- Are `dig`, `&.`, `try` used where needed?
- Does `find_by` handle the nil case? (vs `find` which raises)
- Are array/hash methods called on potentially nil values?

### 5. State and Ordering

- Are operations in the correct order? (validate before save, check before delete)
- Are state transitions valid? (can this status change actually happen?)
- Are side effects triggered at the right time? (after commit, not after save)
- Is data consistent after partial failure? (transaction wrapping)

### 6. AI-Specific Failure Modes

- **Stale method signatures**: does the called method actually accept these arguments?
- **Hallucinated Rails methods**: are all ActiveRecord/ActionController methods real?
- **Invented options**: are hash option keys actually consumed by the receiving method?
- **Copy-paste drift**: were similar methods updated consistently, or did one get missed?
- **Over-abstraction**: is a helper/concern/service created for something used exactly once?

## What To Do

1. Enumerate logic findings and rank them:
   - 🚨 Critical (logic bug that produces wrong results in normal usage)
   - ⚠️ High (logic error in edge case that will happen in production)
   - 🟡 Medium (subtle correctness issue that could cause confusion)
   - 🟢 Low (minor logic improvement, defensive coding opportunity)
2. For each finding:
   - State **actual behavior** (what happens when the code runs)
   - State **expected behavior** (what should happen instead)
   - Identify the exact file(s) and line numbers
   - Propose a specific fix with code example
3. Call out spots where the implementation correctly matches non-obvious intent (so we preserve them)

Do **not** focus on lint/style. Focus on **does this code do the right thing**.

## Claude Output Format

### Summary

- Overall correctness posture: ✅ matches intent / ⚠️ subtle gaps / 🚨 wrong behavior
- Top 3 logic risks (one line each)

### Findings (ranked by severity)

For each finding:

- **Severity**
- **Category**: SemanticError / DataFlow / BoundaryError / NilSafety / StateOrdering / AIFailureMode
- **Location**: file path + line numbers
- **Actual behavior**
- **Expected behavior**
- **Recommended fix** (with code snippet)
