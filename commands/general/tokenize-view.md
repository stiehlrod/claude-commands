---
name: tokenize-view
description: View the project's design tokens or convert a view file from raw Tailwind utilities to semantic design-token classes. Use when working on a project with a semantic design-token system layered on top of Tailwind.
argument-hint: "[convert <file_path>]"
---

# Tokenize View

View the project's design tokens or convert a file from raw Tailwind utilities to semantic token classes.

This skill assumes the project has a **semantic design-token CSS layer** built on top of Tailwind — a set of project-prefixed classes (e.g., `app-card`, `app-input`, `app-text`) that bundle light/dark/hover/focus variants and map to CSS variables. If your project doesn't have such a layer, this skill won't be useful.

## Prerequisites — find the project's token system

Before doing anything, locate two things in the host project:

1. The **CSS / Tailwind layer file** that defines the tokens (commonly something like `app/frontend/entrypoints/application.css`, `app/assets/stylesheets/tokens.css`, or `tailwind.config.js`)
2. The **token reference document** (commonly `docs/DESIGN_TOKENS.md`, `docs/design-system.md`, or similar)

If you can't find a token system, ask the user to point you at the right files before proceeding. Don't fabricate token names.

## Usage

- `/tokenize-view` - Show available tokens and usage examples
- `/tokenize-view convert <file_path>` - Convert a file to use semantic classes

## Instructions

### If no argument provided (show tokens):

Read the project's token reference document and summarize the available tokens. The summary should be tailored to the project's actual prefix and categories — don't invent generic categories that don't exist there.

Typical categories you might encounter (vary by project):

- **Containers** — cards, modals, panels, page backgrounds
- **Form elements** — input, select, textarea, label, help text
- **Text colors** — primary, secondary, muted, error, link
- **Form controls** — checkbox/radio backgrounds and borders
- **Borders & dividers** — standard, dashed, danger
- **Buttons** — primary, secondary, danger, ghost, keyboard-shortcut badge
- **Status badges** — success, warning, neutral, info, danger
- **Settings / list cards** — soft cards, nested cards, code/identifier badges
- **Danger zone** — destructive-action headings and borders

Show only categories that exist in the host project. Point to the canonical reference doc for the full list.

### If "convert <file_path>" argument provided:

1. **Read the specified file**

2. **Identify patterns to replace**. Look for raw Tailwind utilities (especially `bg-*`, `text-*`, `border-*`, `ring-*` with explicit dark-mode variants like `dark:bg-gray-800`) that have a semantic-token equivalent in the project's token system. Cross-reference against the project's conversion table.

3. **Show the user what will change**:

   ```text
   ## Conversion Analysis for: <file_path>

   ### Changes to make:
   - Line X: Replace `<old classes>` → `<new class>`
   - Line Y: Replace `<old classes>` → `<new class>`

   ### Manual review needed:
   - Line Z: Contains similar pattern but may need review
   ```

4. **Ask for confirmation before making changes**

5. **Apply the changes and show the result**

## Notes

- Tokens are typically defined in a CSS file and documented in a markdown reference — find both in the host project before working
- Apply only to files in the project's main view directory (often `app/views/...` or `app/frontend/...`); skip vendored assets
- Most token classes bundle focus states, dark-mode variants, and hover behavior — converting to tokens generally reduces line length and improves consistency
- Don't fabricate token names. If a Tailwind pattern doesn't have a clear token equivalent, leave it alone and flag it for the user
