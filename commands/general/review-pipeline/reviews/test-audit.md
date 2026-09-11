# Test Audit Criteria

**Issue Prefix**: `TEST`
**Condition**: Always run

## Purpose

Identify **tests that provide little or no real value** and should be improved or deleted.

This is **not** a coverage review and **not** a correctness review. Assume all tests currently pass. Focus on **test usefulness, signal, and long-term maintenance cost**.

## Focus Areas

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

For each test file reviewed, categorize tests as:

- **DELETE**: Test adds no value, remove it
- **CONSOLIDATE**: Merge with another test
- **REWRITE**: Change to test meaningful behavior instead
- **KEEP**: Genuinely valuable test

## Severity Classification

| Severity | Criteria |
|----------|----------|
| Critical | N/A (test quality issues are never critical blockers) |
| High | Significant test debt: many low-value tests, high maintenance burden |
| Medium | Some tests should be deleted or rewritten |
| Low | Minor improvements to test quality |

## Output Format

For each issue found, capture:

```yaml
id: TEST-001
title: Short description
severity: High|Medium|Low
file: spec/path/to/file_spec.rb
test_name: "describes X when Y"
category: LowSignal|Brittle|Redundant|MissingPoint
action: DELETE|CONSOLIDATE|REWRITE
description: |
  Explanation of why this test adds little value
what_it_tests: |
  What the test is supposedly verifying
why_low_value: |
  Why this test wouldn't catch a real regression
recommended_fix: |
  DELETE: Remove the test
  CONSOLIDATE: Merge into {other_test}
  REWRITE: Test {actual_behavior} instead
blocked_by: []
```

## Philosophy

We prefer **fewer, stronger tests** over broad but shallow coverage.

A good test:
- Tests behavior, not implementation
- Would fail if the behavior broke
- Is easy to understand and maintain
- Doesn't duplicate other tests
