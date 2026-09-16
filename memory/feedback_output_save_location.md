---
name: Output save location
description: Where to save all Claude-generated output files by default
type: feedback
originSessionId: bfdad425-2c8c-4c0c-b1c8-5efb17cbd853
---
Save all generated files (scripts, docs, prompts, notes, etc.) to `/Users/jennicastiehl/github/.claude/claude-results/` unless the file belongs directly in a specific repo.

**Why:** User wants all Claude output in one predictable place, separate from repo content.

**How to apply:** Before writing any new file, check — does it belong in a repo? If not, default to `/Users/jennicastiehl/github/.claude/claude-results/`. Pick a sensible subfolder if one already exists (e.g. `scripts/`, `doc-reviews/`, `collab-reviews/`).
