---
name: token-audit
description: Audit the current branch for design-token issues — hardcoded Tailwind that should use existing semantic tokens, and patterns repeated enough to warrant new tokens. Companion to /tokenize-view, which converts one file at a time.
---

# Token Audit

Audit the current branch for design-token issues: hardcoded Tailwind that should use the project's existing semantic-token classes, and recurring patterns that suggest new tokens are needed.

This skill assumes the project has a **semantic design-token CSS layer** built on top of Tailwind (a set of project-prefixed classes like `app-card`, `app-text`, `app-btn-primary` that bundle light/dark/hover/focus variants). If your project doesn't have one, this skill won't be useful.

## Usage

`/token-audit` - Analyze changes in current branch for token violations and new-token candidates

## Prerequisites

Before auditing, locate the project's token system:

1. The **CSS / Tailwind layer file** that defines the tokens (e.g., `app/frontend/entrypoints/application.css`, `app/assets/stylesheets/tokens.css`)
2. The **token reference document** that documents the conversion table (e.g., `docs/DESIGN_TOKENS.md`)

The conversion table in the reference doc is the source of truth for what raw Tailwind patterns map to which tokens — use it, don't fabricate mappings.

## Git Context — Auto-Detect

Before auditing, detect your git context:
```bash
if [ "$(git rev-parse --git-dir 2>/dev/null)" = "$(git rev-parse --git-common-dir 2>/dev/null)" ]; then echo "NORMAL"; else echo "WORKTREE"; fi
```
- **NORMAL**: Use `git diff main...HEAD` for branch changes
- **WORKTREE**: Use `git diff HEAD` — do NOT assume `main` exists or that merge-base is meaningful

## Instructions

1. **Get the diff of view files changed in the current branch**:
   ```bash
   # Adjust paths to match the project's view structure.
   # Git pathspec doesn't expand brace patterns inside quotes, so each
   # extension must be its own pathspec entry.
   # NORMAL branch:
   git diff main...HEAD -- \
     'app/views/**/*.erb' \
     'app/helpers/**/*.rb' \
     'app/frontend/**/*.js' \
     'app/frontend/**/*.ts' \
     'app/frontend/**/*.erb'
   # WORKTREE:
   git diff HEAD -- \
     'app/views/**/*.erb' \
     'app/helpers/**/*.rb' \
     'app/frontend/**/*.js' \
     'app/frontend/**/*.ts' \
     'app/frontend/**/*.erb'
   ```

2. **Scan the diff for hardcoded Tailwind color patterns** that are NOT using the project's semantic-token classes:
   - `text-{color}-{shade}` — text colors with explicit shade
   - `bg-{color}-{shade}` — backgrounds
   - `border-{color}-{shade}` — borders
   - `ring-{color}-{shade}` — focus rings
   - Patterns with explicit dark-mode variants (`dark:bg-gray-800` etc.) are especially likely to have a token equivalent

3. **Categorize findings against the project's conversion table**:

   - **Already has a token** — the pattern appears in the project's conversion table. Recommend the token replacement.
   - **Structural / chrome** — sidebar backgrounds, header/footer, dialog backdrops, navigation icon colors. Usually OK to leave hardcoded.
   - **Potential new tokens** — a non-structural pattern that appears 3+ times and isn't in the conversion table. Note the pattern, count, and where it's used as a new-token candidate.

4. **Generate report**:

   ```markdown
   ## Design Token Audit Report

   **Branch**: <current_branch>
   **Files changed**: <count> view files

   ### Should use existing tokens:
   | File | Line | Current | Should Use |
   |------|------|---------|------------|
   | ... | ... | ... | ... |

   ### Potential new tokens to create:
   | Pattern | Count | Suggested Token | Files |
   |---------|-------|-----------------|-------|
   | ... | ... | ... | ... |

   ### OK as hardcoded (structural/chrome):
   - <pattern> in <file> - <reason>

   ### Recommendation:
   <summary of what should be done>
   ```

5. **If issues found, ask user**:
   - "Should I convert these to use existing tokens?"
   - "Should I add the suggested new tokens to the design-token CSS file?"

## Reference

Find the project's token CSS file and reference doc before auditing. Don't audit against a token system you haven't located.
