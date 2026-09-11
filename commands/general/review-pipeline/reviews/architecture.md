# Architecture & Design Review Criteria

**Issue Prefix**: `ARCH`
**Condition**: Always run

## Focus Areas

This is a **design critique**, not a correctness review. Look for architectural weaknesses that will cause maintenance pain.

### 1. Boundaries & Layering

- Inappropriate layering (controllers doing business logic, views doing logic, jobs doing orchestration without services)
- Inversion of dependencies (low-level code knowing about high-level concerns)
- Excessive coupling, poor boundaries, leaky abstractions
- Missing or inconsistent namespacing

### 2. Abstractions & Responsibilities

- Unclear responsibilities (fat controllers/models, god services, anemic objects)
- Repeated conditional logic suggesting missing polymorphism/strategy/state objects
- Overuse of metaprogramming where simple code would work
- Missing service objects for complex operations
- **Over-abstraction** (AI-specific failure mode):
  - Concerns/modules created for a single includer
  - Helper methods wrapping a single expression
  - Service objects for operations that are just one method call
  - Configuration layers for values that should be constants
  - Abstractions "for future extensibility" that add complexity now

### 3. Duplication & Anti-Patterns

- Code duplication (copy-paste logic, repeated queries)
- Feature duplication (duplicate controllers, duplicate routes)
- Hacky shortcuts, band-aids, fragile implementations
- "Clever" code that will age badly

### 4. Magic Values & Configuration

- Magic numbers / magic strings / hidden constants
- Configuration scattered across files
- Environment-specific logic embedded in application code

### 5. Error Handling & Side Effects

- Poor error handling patterns (silent rescue, swallow-and-continue, ambiguous failures)
- Hidden side effects, implicit global state
- Surprising callbacks that affect distant code

### 6. Testability & Maintainability

- Poor testability signals (hard-to-stub dependencies, tightly bound time/randomness)
- Static calls everywhere making testing difficult
- Missing dependency injection

### 7. AI-Authored Code Smells

Patterns that AI coding assistants produce frequently:

- **Over-abstraction**: concerns/modules for a single includer, helper methods wrapping one expression, service objects for single method calls, configuration layers for values that should be constants
- **Defensive over-engineering**: nil checks on values that can never be nil, rescue blocks for impossible exceptions, `.presence || default` on required fields
- **Redundant coercion**: `.to_s` on strings, `.to_i` on integers, `.to_a` on arrays
- **Dead code paths**: methods defined but never called, branches unreachable given the data model
- **Premature extraction**: private methods for 2-3 lines called once, clearer inline
- **Verbose guard clauses**: `return if x.blank?` followed by `return if x.nil?` — one suffices

## Severity Classification

| Severity | Criteria |
|----------|----------|
| Critical | Architectural flaw that will cause major issues at scale or blocks development |
| High | Significant design problem that increases maintenance burden |
| Medium | Suboptimal pattern that should be improved |
| Low | Minor improvement opportunity |

## Output Format

For each issue found, capture:

```yaml
id: ARCH-001
title: Short description
severity: Critical|High|Medium|Low
file: path/to/file.rb
line: 45
category: Boundaries|Abstractions|Duplication|Magic|Errors|Testability
description: |
  Detailed explanation of what's wrong and why it's risky
recommended_fix: |
  Specific, actionable fix with code example if helpful
blocked_by: []  # Other issue IDs this depends on
```
