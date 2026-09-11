---
name: test-coverage-review
description: Analyze test coverage against thresholds (80% global, 90% critical, 95% high-risk).
---

# Test Coverage Review

Analyze the current test coverage for this repository.

Before reviewing, detect your git context:
```bash
if [ "$(git rev-parse --git-dir 2>/dev/null)" = "$(git rev-parse --git-common-dir 2>/dev/null)" ]; then echo "NORMAL"; else echo "WORKTREE"; fi
```
- **NORMAL**: Use `git diff main...HEAD` for branch changes
- **WORKTREE**: Use `git diff HEAD` — do NOT assume `main` exists or that merge-base is meaningful. Do NOT run destructive git commands.

## Coverage Requirements

Evaluate coverage using **relevant lines**, not raw line count.

### Global Threshold

- Overall test coverage must be **≥ 80%**

### Elevated Requirements (Non-Negotiable)

The following code must meet **higher minimums**:

- **Critical services** (core business logic, data mutation, orchestration):
  - **≥ 90%**
- **Policies / authorization logic**:
  - **≥ 90%**
- **High-risk code** (anything involving money, quotas, billing, authentication, permissions, irreversible actions, or compliance):
  - **≥ 95%**

## Focus Areas

### 1. Uncovered Critical Paths

- Business logic methods with no test coverage
- Authorization/policy methods untested
- Error handling branches not exercised
- Edge cases not covered

### 2. High-Risk Uncovered Code

- Payment/billing logic
- Authentication flows
- Permission checks
- Data mutations
- External API integrations

### 3. Legitimate Exclusions

These are acceptable to have lower coverage:
- Generators and rake tasks
- Boilerplate and framework glue
- Configuration files
- Simple delegators with no logic
- View helpers with trivial logic

### 4. Coverage Gaps to Flag

- New code added without corresponding tests
- Modified code with tests that don't cover the changes
- Complex conditionals with only happy path tested
- Rescue blocks never exercised

## Severity Classification

| Severity | Criteria |
|----------|----------|
| Critical | High-risk code (auth, billing, permissions) below 95% coverage |
| High | Critical services or policies below 90% coverage |
| Medium | Overall coverage below 80% or significant gaps in new code |
| Low | Minor coverage gaps in non-critical code |

## What To Do

1. Identify files or directories that fall **below required thresholds**
2. Distinguish between:
   - Legitimate coverage gaps that should be fixed
   - Acceptable exclusions (e.g., generators, rake tasks, boilerplate, framework glue)
3. Call out **high-risk under-covered code explicitly**
4. Summarize findings in a short, actionable report:
   - Overall status (pass / fail)
   - Key risks
   - Recommended next steps

Do **not** chase 100% coverage.
Prioritize **safety, correctness, and maintainability** over raw numbers.
