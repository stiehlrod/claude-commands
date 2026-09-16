---
name: Sprint 1 (May 7-20) recalibrated pointing estimates
description: My pointing estimates for the 6 needs-refinement tickets remaining after the 2026-05-04 refinement session, recalibrated using the SRE pointing feedback memory. Used for comparison once the team votes.
type: project
originSessionId: 474ca75d-b3ec-40cf-9257-df564c3875dd
---
Six tickets carried `needs-refinement` into Sprint 1 (May 7-20) after the 2026-05-04 refinement. My recalibrated estimates (lowered per `feedback_ticket_pointing_sre.md`) below.

**Why:** A 2026-05-04 pointing run showed I overestimated 5 of 6 tickets by 1-3 points. These are my recalibrated guesses for the remaining 6, recorded so the next refinement comparison gives me feedback on whether the calibration stuck.

**How to apply:** When the team points these, compare team vote against my estimate below. Update `feedback_ticket_pointing_sre.md` if there's a new pattern (e.g., still over- or under-estimating a specific complexity dimension).

| Ticket | Original estimate | Recalibrated | Reasoning |
|---|---|---|---|
| #140261 Discovery: Terminal access logging tool architecture | 5 | **3** | Discovery default; flag if team scopes feedback loop tightly enough to drop to 2, or if they treat the multi-component design as novel-enough to push to 5 |
| #140432 Discovery: Advanced CodeQL eval | 3 | **3** | Multi-repo coverage analysis; could come back as 2 if team treats it as pure read-only research |
| #138203 Supportbot Node 22 + dep modernization | 5 | **5** | Preserved — breaking-dep migrations (moment → date-fns, googleapis v72 → v139) are the explicit "keep at 5" case in the calibration memory; recommend splitting |
| #138205 Pin supportbot Actions to SHAs | 2 | **2** | Mechanical pinning across 2 workflows |
| #140541 Replace `marocchino/sticky-pull-request-comment` | 2 | **2** | One workflow file; small replacement-research scope |
| #140580 Replace static PATs with GitHub App tokens | 5 | **5** | Preserved — new JWT token provider service is the explicit "new infrastructure" case in the calibration memory; recommend splitting App-creation/provider service from per-integration migrations |

**Net change:** 1 ticket lowered (#140261, 5 → 3). Five preserved at original because they fall into the "reserve 5" or "default low" cases the calibration memory codifies.

**Watch-list for the next comparison:**
- If #140261 comes back as 2-3, calibration is working.
- If #138203 or #140580 come back lower than 5, the "breaking deps" / "new infra" rules in the calibration memory may need tightening.
- If anything comes back HIGHER than my estimate, that's a new pattern worth noting (under-estimation, not over-estimation).
