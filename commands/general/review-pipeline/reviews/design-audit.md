# Design Token Audit Criteria

**Issue Prefix**: `DESIGN`
**Condition**: Only if frontend changes detected, AND only if the project has a semantic design-token CSS layer on top of Tailwind

## Purpose

Ensure views use the project's semantic design tokens instead of hardcoded Tailwind classes. A semantic token layer enables:
- Global theme changes in one place
- Automatic dark mode support
- Consistent styling across all pages

If the project has no token layer (no project-prefixed semantic classes like `app-card`, `app-text` etc.), skip this review.

## Prerequisites

Locate the project's token system before reviewing:

1. The **CSS / Tailwind layer file** that defines the tokens (commonly `app/frontend/entrypoints/application.css`, `tailwind.config.js`, or a dedicated tokens file)
2. The **token reference document** with the conversion table (commonly `docs/DESIGN_TOKENS.md` or similar)

Use the project's conversion table — don't fabricate mappings.

## Focus Areas

### 1. Hardcoded Colors That Should Use Tokens

Scan for hardcoded Tailwind utility patterns that have a semantic-token equivalent. Common categories:

- Text colors with explicit dark-mode variants (`text-gray-900 dark:text-white`) → typically a `text` token
- Card / panel backgrounds with shadow + outline (`bg-white shadow-xs outline...`) → typically a `card` token
- Form input backgrounds (`bg-white dark:bg-white/5 outline...`) → typically an `input` token
- Primary action buttons (`bg-{brand}-600`) → typically a `btn-primary` token
- Destructive buttons (`bg-red-600`) → typically a `btn-danger` token
- Status badges (`bg-green-50 ring-green-*`, `bg-yellow-50 ring-yellow-*`, etc.) → typically `badge-success` / `badge-warning` / `badge-danger` / `badge-neutral` tokens
- Dividers (`h-px bg-gray-200 dark:bg-white/10`) → typically a `divider` token

The exact token names depend on the project. Cross-reference against the conversion table in the project's reference doc.

### 2. Files to Scan

View files in the project's main view directory. Adjust to the project's structure:
- `app/views/**/*.erb` (or equivalent template files)
- `app/frontend/controllers/*_controller.js` (if classes are added dynamically by JS)
- Skip vendored or third-party files

### 3. Acceptable Hardcoded Patterns

These are structural/chrome and OK to leave hardcoded:
- Sidebar backgrounds and borders
- Header/footer backgrounds
- Dialog/modal backdrops
- Navigation icon colors
- Loading spinner colors
- One-off decorative elements

### 4. Potential New Tokens

If you find a pattern used 3+ times that doesn't have a token:
- Note the pattern and usage count
- Suggest a semantic token name
- Flag for potential addition to the project's token CSS file

## Severity Classification

| Severity | Criteria |
|----------|----------|
| Critical | N/A (design issues are never critical) |
| High | Multiple instances of same hardcoded pattern that breaks dark mode |
| Medium | Hardcoded pattern that should use existing token |
| Low | Minor inconsistency or potential new token opportunity |

## Output Format

For each issue found, capture:

```yaml
id: DESIGN-001
title: Short description
severity: High|Medium|Low
file: path/to/file.erb
line: 45
category: MissingToken|InconsistentPattern|DarkModeBreak
current_code: |
  text-gray-900 dark:text-white
recommended_token: <token-name-from-project>
description: |
  Explanation of why this should use a token
recommended_fix: |
  Replace `<current pattern>` with `<token-name>`
blocked_by: []
```

## Reference

Token definitions and the conversion table live in the host project. Find them before reviewing — don't audit against a token system you haven't located.
