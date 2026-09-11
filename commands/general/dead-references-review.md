---
name: dead-references-review
description: Verify that all references to methods, constants, config keys, model names, and external resources in the current branch actually exist. Catches the "gpt-4o problem" — code that confidently references something that doesn't exist (renamed, removed, hallucinated by AI).
---

# Dead References Review

Verify that all references to methods, constants, config keys, model names, and external resources in the changed code actually exist in the current codebase.

AI-authored code is especially prone to referencing things that existed in training data but have since been renamed, removed, or never existed in this project. This review catches the "gpt-4o problem" — code that confidently references something that doesn't exist.

## Git Context — Auto-Detect

Before reviewing, detect your git context:
```bash
if [ "$(git rev-parse --git-dir 2>/dev/null)" = "$(git rev-parse --git-common-dir 2>/dev/null)" ]; then echo "NORMAL"; else echo "WORKTREE"; fi
```
- **NORMAL**: Use `git diff main...HEAD` for branch changes
- **WORKTREE**: Use `git diff HEAD` — do NOT assume `main` exists or that merge-base is meaningful. Do NOT run destructive git commands. Prefer inspecting the working tree directly.

## Process

1. **For each changed file**, extract all references to:
   - Class/module names
   - Method calls on other objects
   - Constants and config keys
   - Database column names
   - Route helpers
   - Partial paths
   - CSS class names (in ERB/JS)
   - Stimulus controller names and targets
2. **Verify each reference exists** by searching the codebase
3. **Flag anything that can't be found**

## Focus Areas

### 1. Ruby References

- **Class/module names**: e.g. `MyApp::Domain::Service`, `Auth::TokenIssuer`
  - Verify the class actually exists (grep for `class` or `module` definition)
  - Check the namespace is correct (common error: stale namespace from before a rename)

- **Method calls on other classes**: e.g. `Provider.resolve(key)`, `Config.default_model`
  - Verify the method is defined on that class
  - Check method signature matches (number of arguments, keyword args)

- **Constants**: e.g. `DEFAULT_MODEL`, `STATUSES`, `MAX_INPUT_CHARS`
  - Verify the constant is defined in the expected class/module

- **Config keys**: e.g. `Rails.application.config.my_feature[:key]`, `config.dig(:engines, :foo)`
  - Verify the config key exists in the relevant initializer
  - Check the config path is correct (nested keys especially)

- **String references to external identifiers**: e.g. AI model keys like `"gpt-4o"`, vendor SKUs, feature flags
  - Verify the identifier exists in seed data, configuration, or vendor documentation
  - Check whether the identifier has been deprecated or retired

### 2. View References

- **Partial paths**: e.g. `render "shared/banner"`, `render partial: "users/form"`
  - Verify the partial file exists at the expected path

- **Route helpers**: e.g. `dashboard_path`, `edit_user_path`
  - Verify the route exists in `config/routes.rb`

- **Turbo frame/stream IDs**: e.g. `turbo_frame_tag "results"`, `turbo_stream.replace "list"`
  - Verify the matching frame/stream ID exists in the target view

### 3. JavaScript References

- **Stimulus controller names**: e.g. `data-controller="dropdown"`
  - Verify the controller is registered in `index.js`
  - Verify the controller file exists

- **Stimulus targets**: e.g. `data-dropdown-target="menu"`
  - Verify the target is declared in the controller (`static targets = [...]`)

- **Stimulus values**: e.g. `data-dropdown-open-value="true"`
  - Verify the value is declared in the controller (`static values = { open: Boolean }`)

- **Stimulus actions**: e.g. `data-action="click->dropdown#toggle"`
  - Verify the method exists on the controller

- **CSS classes added/removed in JS**: e.g. `element.classList.add("badge-success")`
  - Verify the class exists in CSS

- **Import paths**: e.g. `import { something } from "@controllers/concerns/file"`
  - Verify the file exists and exports the referenced name

### 4. Database References

- **Column names in queries**: e.g. `.where(status: "active")`, `.order(:created_at)`
  - Verify the column exists on that model's table

- **Association names**: e.g. `has_many :orders`, `belongs_to :user`
  - Verify the association is defined and the target model exists

- **Scope names**: e.g. `Model.active`, `Model.for_owner(user)`
  - Verify the scope is defined on the model

### 5. External References

- **External identifiers**: e.g. AI model names passed to providers, vendor product IDs
  - Flag any that reference known-retired versions
  - Flag any not present in the project's seed data / config

- **URLs**: hardcoded URLs to external services
  - Flag any that look like they might be stale

## What To Do

1. Enumerate findings and rank them:
   - 🚨 Critical (reference to non-existent class, method, or config that will cause a runtime error)
   - ⚠️ High (reference to deprecated/retired external resource — API model, URL)
   - 🟡 Medium (reference to renamed entity — old name still works via alias but should be updated)
   - 🟢 Low (unused import, potentially stale comment reference)
2. For each finding:
   - State **what was referenced** and **why it doesn't exist**
   - State **how you confirmed it's missing** (grep command, file check, etc.)
   - Propose the **correct reference or removal**
3. Call out clean reference chains (so we preserve them)

## Claude Output Format

### Summary

- Overall reference health: ✅ all resolve / ⚠️ some stale / 🚨 runtime errors waiting
- Count of broken references by category

### Findings (ranked by severity)

For each finding:

- **Severity**
- **Category**: ClassNotFound / MethodNotFound / ConfigMissing / ColumnMissing / PartialMissing / ControllerMissing / TargetMissing / RetiredModel
- **Location**: file path + line numbers
- **Reference**: the literal string/symbol that's broken
- **Verified by**: how you confirmed it's missing
- **Recommended fix**: correct reference or removal
