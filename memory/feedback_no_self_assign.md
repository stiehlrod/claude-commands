---
name: No self-assign on tickets
description: Never self-assign GitHub issues when creating tickets unless explicitly asked
type: feedback
originSessionId: fd957317-c11f-40e0-988f-dbfeff59b310
---
Never self-assign tickets when creating GitHub issues. Default to no assignee.

**Why:** User preference — "mostly never self assign."

**How to apply:** When using /ticket-create or any ticket creation flow, do not add `--add-assignee "@me"` or ask if the user wants to self-assign. Only assign if the user explicitly requests it.
