---
name: Ticket and PR standards
description: Ticket structure, PR requirements, and automation checks for team readability and tracking
type: feedback
originSessionId: 96a6a4d8-2986-4e53-8499-d37788a65373
---
1. **Ticket numbers in PRs** — Always include the ticket number (e.g., #134015) in PR title or body so the connection is explicit and traceable.

2. **Ticket updates every two days** — Each ticket should have a visible update (comment, status change, or task progress) at least every 48 hours to show momentum and keep stakeholders informed.

3. **Non-tech readable tickets** — Write acceptance criteria and descriptions in plain language that non-engineers can understand. Avoid jargon; explain the "why" and the value, not just the technical "what."

4. **Automated task completeness checks** — Use a hook (run on code push) to verify all tasks in a ticket are marked complete before merging. Prevents incomplete work from shipping.

5. **WIP tracking file** — Consider using a work-in-progress file to track in-flight work across tickets and blockers.


**Why:** These standards ensure visibility, accountability, and clarity across the team — especially for cross-functional stakeholders who may not read code.

**How to apply:** When creating tickets, use /ticket-create with these standards baked in. When reviewing PRs, check for ticket linkage. Set up hooks in settings.json for automated checks.
