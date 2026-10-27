---
name: create-ticket
description: Create a GitHub issue from a description. Explores the codebase to write a proper ticket with tasks and acceptance criteria. Pass a description of the work as argument.
---

# Create Ticket

Create a well-structured GitHub issue by exploring the codebase to understand context.

## Arguments

The user provides a description of what the ticket is about. This can be brief — you will explore the codebase to fill in the details.

## Instructions

1. **Understand the request** — parse the user's description to identify:
   - What area of the codebase is involved
   - What the desired outcome is
   - Any constraints or dependencies mentioned

2. **Explore the codebase** — read relevant files to understand:
   - Current state of the code related to this work
   - Existing patterns to follow
   - Dependencies and related systems
   - What already exists vs what needs to be built

3. **Draft the ticket** using the template below. Do NOT include implementation details like code snippets, file paths, or specific method names — keep it at the product/task level. The developer working on it will explore the code themselves.

4. **Select labels** — every ticket gets exactly one `epic:*` label. Run `gh label list --limit 100 | grep '^epic:'` to see the project's available epic labels, then pick the one that fits.

   If no existing epic fits, **stop and create the right epic label first** (with the user's confirmation on the name and color) before creating the issue. Don't create an unlabeled ticket — the epic-label policy is consistent across every ticket so the backlog stays queryable.

   Add a `bug` label only if the ticket is fixing broken behavior. Do not add any other labels by default.

5. **Present the draft** to the user for review before creating.

6. **Create the issue**:
   ```bash
   gh issue create --title "TITLE" --body-file /tmp/ticket_body.md --label "epic:xxx"
   ```

7. **Run the pointing tool** (`software/va.gov-team` on va.ghe.com only; skip for other repos). The [Copilot Refinement Analysis](https://va.ghe.com/software/va.gov-team/actions/workflows/copilot-refinement-analysis.lock.yml) workflow posts a complexity estimate comment and writes Points and Priority to the Platform SRE Team board (project #358).
   - If the issue was created with the `platform-sre-team` label (and no `Epic` label), the workflow fires on its own from `issues: opened`. Do not dispatch it again.
   - Otherwise, dispatch it:
     ```bash
     GH_HOST=va.ghe.com gh workflow run copilot-refinement-analysis.lock.yml -R software/va.gov-team -f issue_number=NUMBER
     ```
   - Wait for the bot comment (usually a few minutes). Use a Monitor until-loop that polls for it, and do not use `sleep`:
     ```bash
     GH_HOST=va.ghe.com gh api repos/software/va.gov-team/issues/NUMBER/comments \
       --jq '.[] | select(.body | test("Recommended points:")) | .body'
     ```
     If no comment appears within ~10 minutes, check `gh run list --workflow copilot-refinement-analysis.lock.yml -R software/va.gov-team --limit 5` and report the run state to the user. Do not guess points.

8. **Set board Status**. The workflow does not set Status, so set it here from the `Recommended points: N` line. Points reflect complexity. Do not use the `Recommended priority` line (that is urgency, not complexity) or the per-dimension Low/Medium/High ratings.
   - Points 1–3: set Status to Ready. Use **Ready - BE** for `backend` tickets, **Ready - FE** for `frontend` tickets, and **Ready** otherwise.
   - Points 5+ (the rubric calls 5 "Major difficulty" and says 8+ should be split), or no points posted: set Status to **To Refine** and add the `needs-refinement` label.
   ```bash
   ITEM_ID=$(GH_HOST=va.ghe.com gh project item-add 358 --owner software --url ISSUE_URL --format json --jq .id)
   GH_HOST=va.ghe.com gh project item-edit --project-id PVT_kwDOAAEG5c1Ayg --id "$ITEM_ID" \
     --field-id PVTSSF_lADOAAEG5c1Ays4ABAWs --single-select-option-id OPTION_ID
   ```
   Status option IDs: Ready - BE `47c42292`, Ready - FE `4a23982b`, Ready `f013e127`, To Refine `318e935a`.

9. **Return the issue URL** to the user, with the recommended points, priority, and Status that was set.

## Ticket Template

```markdown
## Background

[1-3 sentences explaining why this work is needed and what problem it solves. Written for someone unfamiliar with the specific context.]

## Tasks

- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

## Acceptance Criteria

- AC 1
- AC 2
- AC 3

## Dependencies

[List any tickets or systems this depends on, or remove this section if none.]

## Notes

[Any additional context, constraints, or decisions. Remove this section if empty.]
```

## Guidelines

- **Title**: Use the format `EPIC-NNN: Short description` if the ticket belongs to a numbered epic series (e.g., `BILLING-18: ...`). Otherwise use a clear, concise title.
- **Background**: Explain the "why", not the "how". No code.
- **Tasks**: Concrete, checkable items. Each task should be a single unit of work. Not too granular (not "add import"), not too vague ("implement feature").
- **Acceptance Criteria**: Observable outcomes. Written as "when X, then Y" or simple assertions. These are what a reviewer checks.
- **Size**: Keep tickets to a size that can be completed in a single PR. If the work is too large, suggest splitting into multiple tickets.
