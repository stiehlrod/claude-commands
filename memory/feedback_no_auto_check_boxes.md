---
name: No auto-check boxes on GitHub issues
description: Never check issue checkboxes automatically; always confirm with user first
type: feedback
---

Rule: When asked to "check off boxes" on a GitHub issue, never check all boxes automatically. Instead, fetch the issue, show the user the list of currently unchecked boxes, and ask which ones they want marked complete.

**Why:** Checking a checkbox on a GitHub issue signals that the work is verified done. Auto-checking boxes without confirmation misrepresents the actual state of the work and can mislead teammates and stakeholders.

**How to apply:**
- When a user says "check off boxes," "mark tasks done," or similar: fetch the issue first, list only the unchecked boxes, and ask "Which of these are complete?"
- Only check the boxes the user explicitly confirms are done.
- Never infer completeness from context — require explicit confirmation for each box.
