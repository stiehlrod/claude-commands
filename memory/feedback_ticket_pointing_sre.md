---
name: Ticket pointing - SRE team calibration
description: Calibration guidance for pointing Platform SRE Team tickets - default lower than instinct on volume, comms, and investigation
type: feedback
originSessionId: 474ca75d-b3ec-40cf-9257-df564c3875dd
---
For Platform SRE Team tickets (project #358 on `software` org GHEC-US), default to LOWER point estimates than the complexity framework would suggest. I have been consistently overestimating by 1-3 points.

**Why:** A 2026-05-04 pointing run showed 5 of 6 refined tickets came back below my estimate. The team treats several factors as routine that the framework treats as complexity drivers:

1. **High-volume per-item judgment calls are not 5s.** "107 users to evaluate individually" came back as 2. "~30 monitors to inventory" came back as 3. The team has tooling and context to move through high-count work fast — item volume ≠ cognitive load for them.
2. **Cross-team comms doesn't add points.** Posting in Slack, announcing at ToT, presenting at Backend COP — the team treats this as routine SRE work, not collaboration complexity.
3. **Investigation on a small surface is a 2, not a 3-5.** "Debugging unknown DataDog workflow failures" came back as 2 because the surface area (3 workflow files) is bounded.

**How to apply:**
- For SRE discovery tickets, default to **3** unless they include novel architecture decisions (e.g., #140261 terminal access tool design, which the team has not yet pointed). The bot's "discovery tickets are 1-3" guidance applies — believe it.
- For cleanup/audit tickets with a per-item evaluation step, default to **2** unless the items themselves require deep individual investigation.
- For mechanical multi-file changes (find-and-replace patterns), default to **1-2**.
- Reserve **5** for tickets with truly novel design work, breaking dependency upgrades that require code-level migration (e.g., moment → date-fns), or new infrastructure (e.g., implementing a JWT token provider service).
- After pointing, scan my estimates: if more than half are 5s, suspect over-pessimism and recheck.
