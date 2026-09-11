---
name: review-pipeline
description: Automated code review pipeline with issue tracking. Runs 10 sequential reviews — architecture, security, authorization, logic verification, dead references, design, accessibility, test coverage, test audit, and PR review. Each issue is fixed with an atomic commit. Reports saved to .claude/reviews/{branch}/. Use for comprehensive pre-merge review.
---

# Review Pipeline Orchestrator

Automated sequential review pipeline with per-issue commits and full audit trail.

## Overview

This skill runs all code reviews in sequence, creates detailed reports, fixes every issue with an atomic commit, and produces a complete audit trail.

**Reports saved to**: `.claude/reviews/{branch-name}/`

## Reviews (In Order)

| # | Review | Condition | Depends On | Criteria File |
|---|--------|-----------|------------|---------------|
| 1 | Architecture & Design | Always | — | [reviews/architecture.md](reviews/architecture.md) |
| 2 | Security | Always | — | [reviews/security.md](reviews/security.md) |
| 3 | Authorization | Always | — | [reviews/authorization.md](reviews/authorization.md) |
| 4 | Logic Verification | Always | — | [reviews/logic-verification.md](reviews/logic-verification.md) |
| 5 | Dead References | Always | — | [reviews/dead-references.md](reviews/dead-references.md) |
| 6 | Design Audit | If frontend changes | — | [reviews/design-audit.md](reviews/design-audit.md) |
| 7 | Accessibility | If frontend changes | **#6 fully resolved** | [reviews/accessibility.md](reviews/accessibility.md) |
| 8 | Test Coverage | Always | — | [reviews/test-coverage.md](reviews/test-coverage.md) |
| 9 | Test Audit | Always | **#8 fully resolved** | [reviews/test-audit.md](reviews/test-audit.md) |
| 10 | PR Review | Always (final) | **#1-9 fully resolved** | [reviews/pr-review.md](reviews/pr-review.md) |

## Review Dependencies (STRICT)

Some reviews MUST wait for prior reviews to be **fully resolved** (all issues found AND fixed) before they can start. This is not optional.

**Accessibility (#7)** depends on **Design Audit (#6)**:
- Design Audit fixes hardcoded colors, missing design tokens, and CSS issues. These fixes change the markup and styles that the Accessibility review inspects.
- If Accessibility runs first, it may flag issues already being fixed by the Design Audit, or miss new a11y concerns introduced by design fixes.
- **Rule**: Do NOT start Accessibility until Design Audit status is `complete` with all issues resolved and committed.

**Test Audit (#9)** depends on **Test Coverage (#8)**:
- Test Coverage finds missing tests and writes them. Test Audit evaluates test quality.
- If Test Audit runs before the new tests from Test Coverage exist, it audits stale code and misses the new tests entirely.
- **Rule**: Do NOT start Test Audit until Test Coverage status is `complete` with all issues resolved and committed.

**PR Review (#10)** depends on **all reviews #1-9**:
- PR Review is the final gate. It verifies the branch is production-ready.
- If it runs before other reviews finish fixing issues, it reviews code that will change.
- **Rule**: Do NOT start PR Review until every prior review has status `complete` with all issues resolved and committed.

**Reviews #1-6 and #8** have no inter-dependencies and may run in any order (including parallel), as long as each review's own issues are fully resolved before moving on.

## Issue ID Format

Each issue gets a unique ID: `{TYPE}-{###}`

| Review | Prefix | Example |
|--------|--------|---------|
| Architecture | `ARCH` | `ARCH-001` |
| Security | `SEC` | `SEC-003` |
| Authorization | `AUTH` | `AUTH-002` |
| Logic Verification | `LOGIC` | `LOGIC-001` |
| Dead References | `REF` | `REF-001` |
| Design Audit | `DESIGN` | `DESIGN-001` |
| Accessibility | `A11Y` | `A11Y-004` |
| Test Coverage | `COV` | `COV-001` |
| Test Audit | `TEST` | `TEST-002` |
| PR Review | `PR` | `PR-001` |

## ⚠️ DELEGATION RULES (READ BEFORE RUNNING) ⚠️

> **Background agents (Task tool) CANNOT reliably write files.**
> They frequently fail to get write permissions, causing the orchestrator
> to redo all their work. Follow these rules to avoid wasting time:

### Rule 1: Agents MUST NOT write report files

When delegating a review to a background agent via the Task tool, the agent
prompt **MUST** include this instruction (copy verbatim):

```
╔══════════════════════════════════════════════════════════════════╗
║  ⚠️  DO NOT write any files. DO NOT use the Write tool.        ║
║  ⚠️  DO NOT use Bash to write files.                           ║
║                                                                  ║
║  Instead, return your COMPLETE review findings in your final     ║
║  response as structured markdown. The orchestrator will write    ║
║  the report file.                                                ║
║                                                                  ║
║  Your response MUST include:                                     ║
║  1. total_issues count (integer)                                 ║
║  2. For each issue: id, title, severity, file, line,             ║
║     description, recommended_fix                                 ║
║  3. If no issues: say "No issues found"                          ║
║                                                                  ║
║  Return findings ONLY. Do NOT attempt to save files.             ║
╚══════════════════════════════════════════════════════════════════╝
```

### Rule 2: The orchestrator writes ALL reports

After a background agent returns its findings, the **orchestrator** (this
skill runner) must:
1. Parse the agent's response for issues
2. Write the report file using its own Write tool
3. Never rely on the agent having written anything

### Rule 3: Run simple reviews inline

These reviews are fast enough to run directly (no background agent):
- **Accessibility (#7)** — read a few ERB/JS files, check WCAG criteria
- **PR Review (#10)** — holistic check of final branch state
- **Test Coverage (#8)** — read source + test files, assess coverage
- **Dead References (#5)** — grep/search for referenced names, verify they exist

Only delegate reviews that require deep multi-file analysis:
- Architecture (#1), Security (#2), Authorization (#3), Logic Verification (#4), Design Audit (#6), Test Audit (#9)

---

## Execution Protocol

### Step 1: Initialize

```
1. Get current branch name: git branch --show-current
2. Detect worktree vs normal branch:
   - Check: if [ "$(git rev-parse --git-dir 2>/dev/null)" = "$(git rev-parse --git-common-dir 2>/dev/null)" ]; then echo "normal"; else echo "worktree"; fi
   - WORKTREE: find branch creation point via reflog:
     git reflog show {branch} --oneline | tail -1
     → extract the SHA from the "branch: Created from" entry
     set DIFF_CMD="git diff --name-only {creation_sha}..HEAD"
     (compares all changes since branch was created)
   - NORMAL:  set DIFF_CMD="git diff --name-only main...HEAD"
     (standard branch comparison against main)
   - Output: "MODE: {worktree|normal}"
3. Archive previous run (if any):
   - Check: does .claude/reviews/{branch}/SUMMARY.md exist?
   - If YES (previous run is complete):
     a. Find next run number: count existing run-N/ directories, next = N+1
        (first archive is run-1/, then run-2/, etc.)
     b. Move all report files into archive:
        mkdir .claude/reviews/{branch}/run-{N}/
        mv .claude/reviews/{branch}/*.md .claude/reviews/{branch}/run-{N}/
     c. Output: "ARCHIVED: previous run → run-{N}/"
   - If NO: check for in-progress reports and resume (see State Recovery)
4. Create/ensure report directory: .claude/reviews/{branch}/
5. Detect frontend changes (determines which reviews to run):
   - Check for changes in: app/views/**, app/frontend/**, *.erb, *.js, *.ts, *.css, *.scss
   - Command: ${DIFF_CMD} | grep -E '\.(erb|js|ts|css|scss)$|app/(views|frontend)/'
6. Output: "INITIALIZING: {branch} (mode: {worktree|normal}, frontend: yes/no)"
```

**Worktree rules** (when MODE=worktree):
- Do NOT assume `main` exists or that merge-base is meaningful
- Do NOT run destructive git commands (branch deletion, reset, rebase)
- Prefer inspecting the working tree and local diffs directly
- All commits and staging work normally in worktrees

### Step 2: For Each Review

```
FOR review_number, review_type IN applicable_reviews:

  report_file = ".claude/reviews/{branch}/{##}-{review_type}.md"

  # ── Dependency gate ──────────────────────────────────────────
  # STRICT: Some reviews must wait for prior reviews to finish.
  # "Finished" = report exists AND status == "complete" AND
  #              resolved_issues == total_issues (all fixes committed).
  #
  # Accessibility (#7): BLOCKED until Design Audit (#6) is fully resolved
  # Test Audit    (#9): BLOCKED until Test Coverage (#8) is fully resolved
  # PR Review    (#10): BLOCKED until ALL reviews #1-#9 are fully resolved
  #
  # Do NOT parallelize blocked reviews. Do NOT start them early.
  # Wait for the dependency to be satisfied, then proceed.

  IF review_type == "accessibility":
    REQUIRE review #6 (design-audit) status == "complete"
    IF NOT: OUTPUT: "BLOCKED: accessibility waiting on design-audit"
            DO NOT proceed — finish design-audit first

  IF review_type == "test-audit":
    REQUIRE review #8 (test-coverage) status == "complete"
    IF NOT: OUTPUT: "BLOCKED: test-audit waiting on test-coverage"
            DO NOT proceed — finish test-coverage first

  IF review_type == "pr-review":
    REQUIRE ALL reviews #1-#9 status == "complete"
    IF NOT: OUTPUT: "BLOCKED: pr-review waiting on {incomplete_reviews}"
            DO NOT proceed — finish all prior reviews first

  # ── Check existing state ─────────────────────────────────────
  IF report_file exists:
    READ report frontmatter
    IF status == "complete":
      OUTPUT: "SKIP: {review_type} (already complete)"
      CONTINUE to next review
    ELSE:
      OUTPUT: "RESUME: {review_type} ({pending_count} issues remaining)"
      GOTO fix_loop

  # Run fresh review
  OUTPUT: "REVIEW: {review_type}"

  # ── Delegation decision (see DELEGATION RULES above) ─────────
  # Simple reviews (accessibility, pr-review, test-coverage): run INLINE
  # Complex reviews (architecture, security, authorization, design-audit, test-audit):
  #   may delegate to background agents, but agents MUST NOT write files.
  #   Include the ⚠️ DO NOT write files instruction block in agent prompts.
  #   The ORCHESTRATOR writes all report files from agent responses.

  EXECUTE review using criteria from reviews/{review_type}.md

  PARSE all findings into structured issues:
    - Assign sequential IDs: {TYPE}-001, {TYPE}-002, etc.
    - Set severity: Critical > High > Medium > Low
    - All issues start as status: PENDING
    - Note any dependencies between issues

  # IMPORTANT: The orchestrator ALWAYS writes the report file itself.
  # Never rely on a background agent to have written the report.
  CREATE report file using template (see templates/report.md)
  SAVE report to {report_file}

  OUTPUT: "FOUND: {count} issues in {review_type}"

  fix_loop:
  WHILE any issue has status == PENDING:

    # Select next issue by severity (Critical first)
    SELECT issue WHERE status == PENDING
    ORDER BY severity_rank ASC, id ASC

    # Check dependencies
    IF issue.blocked_by has unresolved items:
      OUTPUT: "BLOCKED: {issue.id} waiting on {blocked_by}"
      SELECT next non-blocked issue
      IF no unblocked issues available:
        OUTPUT: "ERROR: Circular dependency detected"
        BREAK

    OUTPUT: "FIXING: {issue.id} - {issue.title}"
    OUTPUT: "  Severity: {issue.severity}"
    OUTPUT: "  File: {issue.file}:{issue.line}"
    OUTPUT: "  Description: {issue.description}"

    # Implement the fix
    IMPLEMENT fix based on issue.recommended_fix

    # Create atomic commit
    STAGE: git add {affected_files}

    COMMIT with message format:
      {TYPE}-{ID}: {short_title}

      {longer_description_if_needed}

      Review: {review_type}
      Severity: {severity}
      File: {file_path}

    GET commit_sha = git rev-parse --short HEAD

    # Update report
    UPDATE issue in report:
      - status: RESOLVED
      - commit: {commit_sha}
      - fix_applied: {description of fix}
      - resolved_at: {timestamp}

    UPDATE report frontmatter:
      - resolved_issues: +1

    SAVE report

    OUTPUT: "COMMITTED: {issue.id} -> {commit_sha}"

  END WHILE

  # Mark review complete
  UPDATE report frontmatter: status = "complete"
  SAVE report

  OUTPUT: "COMPLETE: {review_type} ({total_issues} issues fixed)"

END FOR
```

### Step 3: Generate Summary

After all reviews complete, create `.claude/reviews/{branch}/SUMMARY.md`:

```markdown
# Review Pipeline Summary

Branch: {branch_name}
Started: {start_timestamp}
Completed: {end_timestamp}
Duration: {duration}

## Reviews Executed

| # | Review | Issues Found | Issues Fixed | Status |
|---|--------|--------------|--------------|--------|
| 1 | Architecture | {n} | {n} | Complete |
| 2 | Security | {n} | {n} | Complete |
...

## All Commits (Chronological)

| Commit | Issue ID | Description |
|--------|----------|-------------|
| a1b2c3d | ARCH-001 | Extract service for user creation |
| e4f5g6h | SEC-001 | Use parameterized query |
...

## Statistics

- Total issues found: {n}
- Total commits made: {n}
- Reviews executed: {n}
- Frontend reviews included: Yes/No

## Ready for Merge
```

### Step 4: Complete

OUTPUT: "ALL_REVIEWS_COMPLETE"

This is the completion promise for Ralph Loop.

## Issue Handling Rules

1. **ALL issues must be fixed** - No deferrals or skips
2. **Fix order**: Critical -> High -> Medium -> Low (within each review)
3. **Dependencies**: If issue B depends on issue A, fix A first
4. **One commit per issue** - Atomic, revertable changes
5. **Review dependencies are STRICT** - Test Audit waits for Test Coverage; PR Review waits for all others (see "Review Dependencies" above)
6. **Each review must fully resolve before dependent reviews start** - "Fully resolved" means all issues found, fixed, committed, and report status set to `complete`
7. **Do NOT parallelize dependent reviews** - Reviews #1-6 and #8 may run in parallel, but #7, #9, and #10 must wait for their dependencies

## Commit Message Format

```
{TYPE}-{ID}: {Short title under 50 chars}

{Optional body with more detail}

Review: {review_type}
Severity: {Critical|High|Medium|Low}
File: {primary_file_path}
```

Example:
```
SEC-001: Use parameterized query in UserSearch

Replaced string interpolation with ActiveRecord parameterized
query to prevent SQL injection vulnerability.

Review: security
Severity: Critical
File: app/services/user_search.rb:45
```

## State Recovery & Re-runs

**Re-run (all reviews complete):**
If SUMMARY.md exists (previous run finished), the pipeline archives the old reports
into `run-{N}/` and starts a completely fresh run. No manual cleanup needed.

**Resume (interrupted mid-run):**
If reports exist but SUMMARY.md does NOT exist (interrupted before completion):
1. Detect existing report files
2. Check each report's status (complete vs in_progress)
3. Skip completed reviews
4. Resume from first PENDING issue in current review
5. Continue through remaining reviews

**Directory structure after multiple runs:**
```
.claude/reviews/{branch}/
├── run-1/              ← archived first run
│   ├── 01-architecture.md
│   ├── ...
│   └── SUMMARY.md
├── run-2/              ← archived second run
│   ├── ...
│   └── SUMMARY.md
├── 01-architecture.md  ← current/latest run
├── ...
└── SUMMARY.md
```

## Frontend Detection

Frontend changes are detected by checking for modifications to:
- `app/views/**/*`
- `app/frontend/**/*`
- `*.erb` files
- `*.js`, `*.ts` files
- `*.css`, `*.scss` files

If ANY frontend files changed, include Design Audit and Accessibility reviews.

## Ralph Loop Integration

```bash
/ralph-loop "/review-pipeline" --max-iterations 100 --completion-promise "ALL_REVIEWS_COMPLETE"
```

The loop continues until:
- `ALL_REVIEWS_COMPLETE` appears in output (success)
- Max iterations reached (needs manual intervention)
- User runs `/cancel-ralph`

## Manual Usage

Can also be run without Ralph Loop:
```
/review-pipeline
```

The skill will run all reviews and fix all issues in one session, or you can re-run to resume if interrupted.
