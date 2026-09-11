---
name: verify-implementation
description: Review implementation plan documents against actual code to verify all requirements were met. Use after completing a feature to check nothing was missed.
argument-hint: "<path to plan file or directory>"
---

# Verify Implementation Plan

Review the implementation plan document(s) against the actual code in the current branch to verify all requirements were met.

## Usage

```text
/verify-implementation <path>
```

Where `<path>` is either:
- A **file path** to a single implementation plan document (e.g., `todos/backend/feature/PLAN.md`)
- A **directory path** containing multiple implementation plan documents (e.g., `todos/backend/feature/`)

## Instructions

### Step 1: Read the Implementation Plan(s)

1. **If a file path was provided**:
   - Read the single implementation plan document

2. **If a directory path was provided**:
   - List all markdown files in the directory
   - Read each document to build a complete picture of the requirements
   - Note how documents relate to each other (e.g., main plan + ChatGPT refinements)

### Step 2: Extract Requirements

From the implementation plan(s), identify and catalog:

1. **Data Model Requirements**
   - New tables/migrations
   - Model associations and validations
   - Database indexes

2. **Service/Business Logic Requirements**
   - New services, jobs, or engines
   - Core methods and their expected behavior
   - Integration points with existing code

3. **API/Controller Requirements**
   - New endpoints or routes
   - Controller actions
   - Authentication/authorization requirements

4. **Configuration Requirements**
   - New initializers
   - Environment variables
   - Scheduled jobs (cron)

5. **Test Requirements**
   - Expected test coverage
   - Specific test cases mentioned

6. **Explicit Non-Goals**
   - Features explicitly deferred or out of scope

### Step 3: Analyze the Current Branch

1. **Detect git context**:
   ```bash
   if [ "$(git rev-parse --git-dir 2>/dev/null)" = "$(git rev-parse --git-common-dir 2>/dev/null)" ]; then echo "NORMAL"; else echo "WORKTREE"; fi
   ```

2. **Get branch changes**:
   ```bash
   git branch --show-current
   # NORMAL branch:
   git diff origin/main --stat
   git diff origin/main --name-only
   # WORKTREE (no origin/main available):
   git diff HEAD --stat
   git diff HEAD --name-only
   ```

3. **For each requirement category**, check if the corresponding code exists:
   - Read the relevant files
   - Compare against the plan specifications
   - Note any deviations or additions

### Step 4: Generate Verification Report

## Output Format

```markdown
# Implementation Verification Report

## Plan Source
- **Path**: [file or directory path provided]
- **Documents Reviewed**: [list of files read]

## Branch Info
- **Branch**: [current branch name]
- **Files Changed**: [count]

---

## Requirements Checklist

### Data Model
| Requirement | Status | Notes |
|-------------|--------|-------|
| [requirement] | ✅/⚠️/❌ | [details] |

### Services & Business Logic
| Requirement | Status | Notes |
|-------------|--------|-------|
| [requirement] | ✅/⚠️/❌ | [details] |

### Controllers & Routes
| Requirement | Status | Notes |
|-------------|--------|-------|
| [requirement] | ✅/⚠️/❌ | [details] |

### Configuration
| Requirement | Status | Notes |
|-------------|--------|-------|
| [requirement] | ✅/⚠️/❌ | [details] |

### Tests
| Requirement | Status | Notes |
|-------------|--------|-------|
| [requirement] | ✅/⚠️/❌ | [details] |

---

## Summary

### Fully Implemented
- [list of completed requirements]

### Partially Implemented
- [list of partial implementations with what's missing]

### Not Implemented
- [list of missing requirements]

### Additional Work (Not in Plan)
- [list of code changes not mentioned in the plan]

---

## Deviations from Plan

[List any intentional or unintentional deviations from the original plan, with explanation if apparent]

---

## Recommendations

[Any suggestions for completing missing work or addressing discrepancies]
```

## Status Legend

- ✅ **Implemented** - Requirement fully met as specified
- ⚠️ **Partial** - Requirement partially met or implemented differently
- ❌ **Missing** - Requirement not implemented
- ➕ **Extra** - Work done beyond the plan (may be intentional)

## Important Notes

- Be thorough but pragmatic - minor deviations that don't affect functionality are fine
- Consider that plans may have been refined during implementation
- Flag any security or architectural concerns even if they match the plan
- Note if tests exist for implemented features
