---
name: PR review: no intermediate check-ins
description: Don't pause to ask for confirmation during the pr-review batch workflow; just run straight through
type: feedback
originSessionId: b7bbc54d-3302-4d21-b304-ddec8cacfc96
---
Run the full pr-review batch workflow end-to-end without pausing to ask for approval between steps (fetching, filtering, spawning agents, QA checks, presenting results).

**Why:** User explicitly said "just run the checks without asking."

**How to apply:** For /pr-review next batch, proceed through all steps — triage, parallel review agents, QA checks, final output — in one uninterrupted flow. Only surface results, not intermediate status requests.
