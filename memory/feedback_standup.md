---
name: Standup format preferences
description: /standup should use last working day (not assume Friday on Mondays) and check support rotation calendar
type: feedback
---

"Yesterday" in standup should always mean the last working day — NOT assumed to be Friday when today is Monday. The user may have worked on Monday or other days.

**Why:** User works on days that don't follow a strict M-F assumption. Assuming "Friday" on Mondays produced inaccurate standups.

**How to apply:** When generating standup, determine the actual last working day from context (e.g., if today is Tuesday 4/14, yesterday = Monday 4/13). Don't skip to Friday unless explicitly told.
