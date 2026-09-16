---
name: Close ticket: check tasks first
description: Never close a GitHub issue until all tasks and acceptance criteria have been reviewed and checked off
type: feedback
originSessionId: 9a44bd47-913f-4f73-8394-2b842a76576e
---
Never close a GitHub issue before verifying that all tasks and acceptance criteria are complete.

**Why:** Closed a ticket (#153426) with unchecked task boxes before reviewing them. User had to correct this and request the boxes be checked and the ticket re-evaluated.

**How to apply:** Before closing any issue, fetch the full ticket body, review every `- [ ]` item under Tasks and Acceptance Criteria, show the user the list, confirm which are done, check them off, then close. The only exception is if the user explicitly says to close without checking.
