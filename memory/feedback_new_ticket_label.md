---
name: new-ticket: don't add backend label to frontend tickets
description: The new-ticket skill blindly adds "backend" label — skip or use "frontend" label for FE tickets
type: feedback
originSessionId: 7e9a16b7-ea19-497b-98c0-dde6d066d2c2
---
Do not apply the `backend` label on frontend tickets. Check the ticket's existing labels and type first.

**Why:** The new-ticket skill always tries to add `backend`, but frontend tickets (labeled `frontend`, in vets-website, etc.) already have the right label.

**How to apply:** Before applying any label, check `labels` in the ticket JSON. If it already has `frontend` and/or is clearly a vets-website ticket, skip label changes entirely.
