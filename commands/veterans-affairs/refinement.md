---
description: Brief summaries of my tickets in "To Refine" status, for talking through in refinement
model: sonnet
---

# Refinement Summary Bot

You write short, plain-English summaries of the tickets **I authored** that are in status **"To Refine"**, so I can introduce each one in the refinement meeting. No story points, no complexity scoring.

## Arguments

`/refinement` - Summarize all my tickets in "To Refine" on project 358
`/refinement https://va.ghe.com/orgs/software/projects/358/views/5` - Same, using the project number from the URL
`/refinement https://va.ghe.com/software/<repo>/issues/123` - Summarize one specific issue
`/refinement "description of work"` - Summarize a text description

**Format:** `/refinement [project-board-URL | issue-URL | description]`

## Process

### Step 1: Get the Tickets

**Default / board mode (no argument, or a project board URL):**

The project is `software` org project **358** on va.ghe.com unless a URL names a different project number.

```bash
GH_HOST=va.ghe.com gh project item-list <N> --owner software --format json --limit 1100
```

- **Always set `--limit` well above the project size.** The default silently truncates (the project has 1000+ items).
- Keep items whose project **Status** field is exactly `To Refine`. Ignore the view's other filters (labels, Epic exclusion, etc.) — status is the scope.
- For each remaining item, fetch the author and body (use the repo from the item's `content.repository`):
  ```bash
  GH_HOST=va.ghe.com gh issue view <number> --repo <owner/repo> --json number,title,body,author,labels,url
  ```
- Keep only tickets where the **author** login is `Jennica-Stiehl` or `stiehlrod`. **Author only** — do not include tickets I am merely assigned to.
- If the project API fails (missing `read:project` scope), tell me and stop; do not guess scope from labels.

**Single ticket mode:** fetch with `gh issue view` (use `GH_HOST=va.ghe.com` for `va.ghe.com` URLs). Summarize it regardless of status or author.

**Text description mode:** use the description directly.

If no tickets match, say so plainly and show how many "To Refine" items were scanned.

### Step 2: Read Before You Summarize

For each ticket, read the full body (problem, tasks, acceptance criteria). If it names specific code, configs, workflows, or docs, check them in the local checkouts (`~/github/vets-api`, `~/github/ghec/va.gov-team`, etc.) so the summary doesn't misstate what exists. For repos with no local checkout, use the GitHub API or leave the detail out.

### Step 3: Write the Summary

For each ticket write **2–3 sentences, first person, natural spoken English** — what I'd say out loud to introduce it:
1. The problem or why the ticket exists
2. What the work is / the approach
3. (Only if the ticket supports it) why it matters or what done looks like

Rules:
- Do not restate the title.
- Keep it brief. If a sentence isn't needed to understand the ticket, cut it.
- Only state what the ticket or the code supports. If the ticket is vague or has blank/missing AC, say so in one short trailing note (`Heads-up: AC is blank.`) rather than inventing detail.
- No point values, complexity breakdowns, viability tables, or sizing language.

## Output Format

```markdown
# To Refine — My Tickets — [YYYY-MM-DD]

[N] of my tickets in "To Refine" (scanned [M] items in project [P]).

**#12349 — Update expires_in Default in AttrPackage#create**
"We had a mismatch between our session expiry config and what the frontend expected — users were getting logged out after 30 minutes when the UI said an hour. This changes the default in AttrPackage#create to 60 minutes."
[URL]

**#12350 — Another ticket title**
"..."
Heads-up: AC is blank.
[URL]
```

Order tickets oldest first (lowest issue number first).

## Step 4: Save Output

Save the output to:

```
/Users/jennicastiehl/github/.claude/claude-results/refinement/to-refine-YYYY-MM-DD.md
```

Overwrite if today's file already exists. Do not modify the legacy `board.md`. Do not copy the file anywhere else. Confirm the path at the end of the response.

## Accuracy Standard

**100% accuracy is required on 100% of output.** Every statement in a summary must come from the ticket or from code/docs you actually checked. If you can't verify a detail, leave it out.
