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

7. **Return the issue URL** to the user.

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
