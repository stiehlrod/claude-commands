---
name: review-docs: check for existing review file before starting
description: Before running /review-docs, always check the doc-reviews directory for an existing file on the same document
type: feedback
originSessionId: 3a4a03c5-8855-4ea3-890c-85ee46652e28
---
Before creating a new review file via /review-docs, check `/Users/jennicastiehl/github/.claude/claude-results/doc-reviews/` for an existing review on the same document. Files are named `YYYY-MM-DD-review-[doc-name].md`. If one exists, read it and report the findings rather than repeating the process.

**Why:** User had to interrupt a duplicate review that was already fully written the previous day.

**How to apply:** At the start of every /review-docs invocation, run `ls` on the doc-reviews directory and scan for a filename that matches the document being reviewed before doing any review work.
