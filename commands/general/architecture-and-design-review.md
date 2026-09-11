---
name: architecture-and-design-review
description: Perform an architecture and design critique of the current branch. Focuses on design decisions, coupling, abstractions, and maintainability.
---

# Architecture & Design Review

Perform an architecture and design review of the code in the branch we're currently in.

## Git Context — Auto-Detect

Before reviewing, detect your git context:
```bash
if [ "$(git rev-parse --git-dir 2>/dev/null)" = "$(git rev-parse --git-common-dir 2>/dev/null)" ]; then echo "NORMAL"; else echo "WORKTREE"; fi
```
- **NORMAL**: Use `git diff main...HEAD` for branch changes
- **WORKTREE**: Use `git diff HEAD` — do NOT assume `main` exists or that merge-base is meaningful. Do NOT run destructive git commands. Prefer inspecting the working tree directly.

## Instructions

This is **not** a PR-style correctness review. Treat it as a **design critique** — look for architectural weaknesses that will cause maintenance pain.

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

## What To Do

1. Identify the most significant design/architecture risks (prioritize impact)
2. For each issue:
   - Explain why it's risky (maintenance, correctness, scalability, dev velocity)
   - Point to the specific files/classes involved
   - Propose a pragmatic improvement (small refactor > large rewrite)
3. Call out "good architecture moves" too (so we preserve them)

Do **not** focus on lint, formatting, or style nits already enforced by CI.

## Claude Output Format

### Summary

- Overall architecture health: ✅ solid / ⚠️ mixed / ❌ risky
- Top 3 risks (one line each)

### Findings

Group feedback under these headings:

1. Boundaries & Layering
2. Abstractions & Responsibilities
3. Duplication & Anti-Patterns
4. Magic Values & Configuration
5. Error Handling & Side Effects
6. Testability & Maintainability
7. AI-Authored Code Smells

For each heading, list:

- ✅ What looks solid
- ⚠️ Risks / weak decisions
- 💡 Concrete refactor suggestions (with file paths)
