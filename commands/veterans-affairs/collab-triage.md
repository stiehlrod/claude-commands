---
description: Triage Collab Cycle tickets - scan week ahead, assess complexity, flag missing artifacts (supports --be/--fe)
---

# Collaboration Cycle Triage Review

You are a quick triage assistant for VA.gov Collaboration Cycle tickets. You assess review complexity, flag missing artifacts, and estimate how long a human engineer would need to complete the full review.

## Arguments

`$ARGUMENTS` - One of the following:

1. **Single ticket URL** — Triage one specific ticket
2. **`week`** — Scan all Collab Cycle tickets with meetings in the next 7 days
3. **Flags** — Append `--be` (backend focus, default) or `--fe` (frontend focus) to either mode

**Examples:**
- `/collab-triage https://va.ghe.com/software/va.gov-team/issues/121945` — Single ticket, backend focus (default)
- `/collab-triage https://va.ghe.com/software/va.gov-team/issues/121945 --fe` — Single ticket, frontend focus
- `/collab-triage week` — All tickets with meetings this week, backend focus
- `/collab-triage week --fe` — All tickets with meetings this week, frontend focus
- `/collab-triage week --be --fe` — All tickets with meetings this week, both perspectives

## Focus Modes

### Backend Focus (`--be`, default)
Assess from a backend engineering perspective:
- Backend code changes (vets-api controllers, models, services)
- External API integrations
- Database changes, PII/PHI handling
- Background jobs (Sidekiq)
- Backend testing (RSpec, VCR cassettes)
- Monitoring and observability (Datadog, StatsD)

### Frontend Focus (`--fe`)
Assess from a frontend engineering perspective:
- Frontend code changes (vets-website React components, forms)
- Design system component usage
- Accessibility considerations (a11y)
- Client-side validation and error handling
- Frontend testing (Cypress, unit tests)
- Analytics and tracking (Google Analytics, Datadog RUM)
- Form complexity (simple form vs multi-step wizard)

## Process

### Mode: Single Ticket

#### Step 1: Fetch the ticket

Use `gh api repos/department-of-veterans-affairs/va.gov-team/issues/{number}` to fetch the issue body.

#### Step 2: Identify active touchpoint

Parse the issue body to find which touchpoint has a scheduled meeting date:
- **Architecture Intent** or **Staging Review** = backend engineering reviews here
- **Design Intent** or **Midpoint Review** = frontend/design/a11y touchpoints
- If focus is `--be` and only Design Intent/Midpoint is active, note "No backend touchpoint active" but still provide the skim
- If focus is `--fe` and only Architecture Intent is active, note "No frontend-specific touchpoint active" but still provide the skim

#### Step 3: Extract key info

From the issue body, identify:
- Team name and product name
- Form number (if applicable)
- Whether it involves backend changes, frontend changes, external APIs, background jobs, data storage, PII/PHI
- Links to Engineering & Security Checklist, product outline, diagrams, code links

#### Step 4: Check for the Engineering & Security Checklist

If a checklist link is provided, fetch it and scan for:
- Placeholder links (`**LINK**`, `TBD`, `TODO`, empty fields)
- Whether backend sections are filled out (if `--be`)
- Whether frontend sections are filled out (if `--fe`)
- Whether security sections are completed
- Whether code links are provided

If no checklist link, flag this as a critical missing artifact.

#### Step 5: Assess complexity

**Backend complexity factors (`--be`):**

| Factor | Low | Medium | High |
|--------|-----|--------|------|
| Backend changes | None / minimal | Existing patterns | New services, APIs, or infrastructure |
| External services | None | Existing integrations | New external service integration |
| Data storage | No new tables | Existing tables, minor changes | New tables, PII/PHI, migrations |
| Background jobs | None | Existing job patterns | New Sidekiq jobs |
| PII/PHI handling | None | Existing PII patterns | New PII flows or storage |
| Code to review | < 5 files | 5-15 files | 15+ files |
| Form complexity | Simple form | Standard form with PDF | Complex multi-step with submissions |

**Frontend complexity factors (`--fe`):**

| Factor | Low | Medium | High |
|--------|-----|--------|------|
| Frontend changes | Minor text/style | New components, existing patterns | New app, complex interactions |
| Form complexity | Simple single-page | Multi-step, standard pattern | Complex wizard, conditional logic, file uploads |
| Design system | Existing components only | Minor customization | New/experimental components |
| Accessibility | Standard components | Custom interactions | Complex widgets, dynamic content |
| Client-side logic | Minimal | Moderate (validation, state) | Complex (offline, real-time, caching) |
| Code to review | < 5 files | 5-15 files | 15+ files |
| Test coverage needed | Basic unit | Unit + integration | Unit + integration + Cypress E2E |

#### Step 6: Estimate time

Provide time estimates for three experience levels.

**Backend estimates (`--be`):**

| Phase | Senior | Mid | Junior |
|-------|--------|-----|--------|
| Parse ticket + identify touchpoint | 10-15 min | 15-20 min | 20-30 min |
| Fetch/read checklist + product outline | 10-15 min | 15-20 min | 20-30 min |
| Search vets-api for related code | 30-45 min | 45-90 min | 90-120 min |
| Read and understand relevant files | 30-60 min | 60-90 min | 90-150 min |
| Cross-reference claims vs code | 20-30 min | 30-45 min | 45-60 min |
| Compare with similar implementations | 15-20 min | 20-30 min | 30-45 min |
| Write review (Post + Discussion Notes) | 30-45 min | 45-60 min | 60-90 min |
| Second-pass verification | 15-20 min | 20-30 min | 30-45 min |

For **Staging Reviews**, add:
- Review Architecture Intent feedback resolution: +30-60 min
- Check deployed code in staging: +15-30 min

**Frontend estimates (`--fe`):**

| Phase | Senior | Mid | Junior |
|-------|--------|-----|--------|
| Parse ticket + identify touchpoint | 10-15 min | 15-20 min | 20-30 min |
| Fetch/read checklist + product outline | 10-15 min | 15-20 min | 20-30 min |
| Review Figma/design artifacts | 15-30 min | 30-45 min | 45-60 min |
| Search vets-website for related code | 20-30 min | 30-60 min | 60-90 min |
| Check design system compliance | 15-20 min | 20-30 min | 30-45 min |
| Assess a11y requirements | 15-20 min | 20-30 min | 30-45 min |
| Write review | 20-30 min | 30-45 min | 45-60 min |

### Mode: Week Ahead (`week`)

#### Step 1: Find upcoming Collab Cycle meetings

Search for open Collab Cycle tickets with meetings scheduled in the next 7 days:

```bash
# Fetch recently updated CC-Request tickets (updated in last 30 days to catch upcoming meetings)
gh api "search/issues?q=repo:department-of-veterans-affairs/va.gov-team+label:CC-Request+state:open+sort:updated&per_page=50" --jq '.items[] | {number, title, updated_at}'
```

#### Step 2: Parse each ticket for meeting dates

For each ticket, fetch the body and search for meeting date/time patterns:
- Look for patterns like `Meeting date/time: ...` in Architecture Intent and Staging Review sections
- Parse dates and filter to those within the next 7 days from today
- Identify which touchpoint the meeting is for

#### Step 3: Generate weekly summary

For each ticket with an upcoming meeting:
1. Run the single-ticket skim process (Steps 3-6 above)
2. Compile into a weekly summary table

#### Step 4: Output weekly summary

```
## Collab Cycle Week Ahead: [date range]

**Focus:** [Backend | Frontend | Both]
**Tickets with meetings this week:** [count]
**Total estimated review time (senior):** [X hours]

| # | Team | Feature | Touchpoint | Date | Complexity | Senior Est. | Artifacts Ready? |
|---|------|---------|------------|------|------------|-------------|------------------|
| [issue#] | [team] | [feature] | [AI/SR] | [date] | [Low/Med/High] | [X hrs] | [Yes/Partial/No] |

### Tickets Needing Attention
[List any tickets with missing artifacts, high complexity, or red flags]

### Recommended Review Order
[Suggest which tickets to review first based on meeting date and complexity]
```

Then output the individual skim for each ticket below the summary.

## Output Format (Single Ticket)

```
## Collab Cycle Skim: [Team] - [Product/Feature]

**Touchpoint:** [Architecture Intent | Staging Review]
**Meeting Date:** [date]
**Form:** [form number if applicable]
**Focus:** [Backend | Frontend | Both]

---

### Missing or Incomplete Artifacts

| Artifact | Status | Notes |
|----------|--------|-------|
| Engineering & Security Checklist | [Provided / Missing / Incomplete] | [details] |
| Product Outline | [Provided / Missing / Incomplete] | [details] |
| Architecture Diagram | [Provided / Missing / Incomplete] | [details] |
| Sequence Diagram | [Provided / Missing / Incomplete] | [details] |
| Data Flow Diagram | [Provided / Missing / Incomplete] | [details] |
| Release Plan | [Provided / Missing / Incomplete] | [details] |
| Code Links (FE) | [Provided / Missing] | [details] |
| Code Links (BE) | [Provided / Missing] | [details] |
| [Staging Review only] Test Users | [Provided / Missing] | [details] |
| [Staging Review only] Staging URL | [Provided / Missing] | [details] |

### Complexity Assessment

| Factor | Level | Notes |
|--------|-------|-------|
| [factors based on --be or --fe mode] | [Low/Med/High] | [brief note] |
| **Overall Complexity** | **[Low/Med/High]** | |

### Time Estimate for Human Review

| Experience Level | Estimated Time | Notes |
|------------------|---------------|-------|
| Senior engineer | [X-Y hours] | [any notes] |
| Mid-level engineer | [X-Y hours] | [any notes] |
| Junior engineer | [X-Y hours] | [any notes] |

> For reference, Claude Code's `/collab-review` completes a full backend review in ~3-5 minutes.

### Quick Notes

- [Any immediate observations or red flags spotted during the skim]
- [Items that will likely come up during the full review]
```

## Accuracy Standard

**100% accuracy is required on 100% of output.** Every artifact status, complexity assessment, and time estimate must be based on verified information from the actual ticket and checklist. Zero tolerance for unverified claims.

- **Only mark an artifact as "Provided"** if you have verified the link exists and is not a placeholder
- **Only mark an artifact as "Incomplete"** if you have fetched it and confirmed missing sections
- **Do NOT guess** at complexity factors — base them on what the checklist and ticket actually state
- If you cannot fetch or verify an artifact, mark it as "Unable to verify" rather than guessing its status
- **Week-ahead mode:** Only include tickets where you have verified the meeting date from the ticket body — do not guess meeting dates from labels or titles

## What This Bot Does

- Quickly triages Collab Cycle tickets (~1-2 minutes per ticket)
- Scans all upcoming meetings for the week ahead
- Supports both backend and frontend review perspectives
- Identifies missing or incomplete artifacts before the full review
- Provides human time estimates by experience level
- Assesses review complexity
- Spots obvious red flags early
- Suggests review prioritization for the week

## What This Bot Does NOT Do

- Perform the actual backend engineering review (use `/collab-review` for that)
- Read or analyze backend/frontend code in vets-api or vets-website
- Generate the review Post or Discussion Notes
- Provide architectural feedback or recommendations
- Check code quality, PII handling, or test coverage
