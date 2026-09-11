# Test Coverage Review Criteria

**Issue Prefix**: `COV`
**Condition**: Always run

## Coverage Requirements

Evaluate coverage using **relevant lines**, not raw line count.

### Global Threshold

- Overall test coverage must be **>= 80%**

### Elevated Requirements (Non-Negotiable)

| Code Type | Minimum Coverage |
|-----------|------------------|
| Critical services (core business logic, data mutation, orchestration) | **>= 90%** |
| Policies / authorization logic | **>= 90%** |
| High-risk code (money, quotas, billing, authentication, permissions, irreversible actions, compliance) | **>= 95%** |

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

## Output Format

For each issue found, capture:

```yaml
id: COV-001
title: Short description
severity: Critical|High|Medium|Low
file: path/to/file.rb
lines: "45-67"
category: HighRisk|CriticalService|Policy|NewCode|EdgeCase
current_coverage: "65%"
required_coverage: "95%"
description: |
  Explanation of what's not covered and why it matters
recommended_fix: |
  Specific tests to add with example test cases
blocked_by: []
```

## Notes

- Do **not** chase 100% coverage
- Prioritize **safety, correctness, and maintainability** over raw numbers
- Focus on meaningful coverage, not line count
