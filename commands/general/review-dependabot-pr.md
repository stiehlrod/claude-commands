---
name: review-dependabot-pr
description: >-
  Triage a bot-authored dependency bump PR (Dependabot, Renovate) into a
  single verdict: Safe to merge, or Needs investigation with an enumerated,
  actionable risk list and an optional validation ticket. Inventories every
  bump, verifies SHA pins against their claimed tags, reads upstream release
  notes for each major bump and maps breaking changes against the repo's
  actual usage, checks CI, then posts the verdict. Not a code review: there
  is no author to negotiate with, so there is no finding curation. Trigger:
  user invokes /review-dependabot-pr with a PR, or asks whether a Dependabot
  or Renovate PR is safe to merge.
argument-hint: "[PR URL, owner/repo#number, or bare PR number]"
allowed-tools: Bash, Read, Grep, Glob, Agent, AskUserQuestion
---

# Dependency bump review

A dependency bump is not code to review; it is a set of upstream changes to
triage. The output is a **verdict**, one of exactly two, plus any defects in
the PR itself:

- **Safe to merge**: every bump is patch or minor, or every major bump's
  documented breaking changes touch nothing this repository uses.
- **Needs investigation**: at least one major bump carries a breaking change
  that touches a real usage and can be confirmed safe only by running
  something. The verdict lists each such risk with enough detail to act on,
  and the follow-up is a validation ticket, not a review thread.

Separately from the verdict, **PR defects** are things wrong with the bump PR
regardless of what it upgrades: a pinned SHA that does not match the tag the
trailing comment claims, a bare tag reference where the repository pins by
SHA, inconsistent pin styles across the diff, or a reference inside a
commented-out or disabled block that got updated. A PR defect blocks the
merge on its own.

## Contracts

**Context discipline.** Full diffs, PR bodies, release notes, and CI logs
never enter the main session. Subagents read them and return summaries. The
main session holds PR coordinates, the inventory, the risk list, and the
verdict. Violating this causes mid-review compaction, which evicts these
instructions.

**Static analysis only.** Subagents read; they never execute. No running
repository code, tests, builds, installs, or one-off scripts. "Verify" means
reading and citing file:line evidence. A claim that can only be settled by
executing something is reported as exactly that, and it is what turns a
breaking change into a risk. One extension specific to this skill: subagents
may **read** upstream metadata about the bumped dependencies (release notes,
tags, compare views, registry metadata) through `gh api` reads against the
dependency's own repository or a registry's read endpoints. Dependency source
repositories live on `github.com` even when the PR is on an enterprise host,
so those reads take no `GH_HOST` prefix.

**Git shape.** Every git command takes the form `git -C <repo-path> <op>`,
never `cd` into the repo. Permitted ops in subagents are read-only:
`show <ref>:<path>`, `grep <pattern> <ref> -- <path>`. Subagents never
`git fetch`; Stage 1 is the only fetch.

**Waiting on subagents.** Completions notify automatically. Never poll with
status checks or sleep loops between spawning agents and their completion.

## Input

`$ARGUMENTS` accepts a full PR URL, `owner/repo#number`, or a bare PR number
(repo inferred from the cwd git remote). Prompt if not provided.

Resolve the GitHub host from the URL, the cwd git remote, or default to
`github.com`. Every `gh` command targeting a non-`github.com` host is
prefixed with `GH_HOST=<host>`.

## Stage 1: Setup (main session, thin)

1. **Confirm the author is a bot.** Fetch `gh pr view <n> --repo <owner/repo>
   --json author --jq '.author | "\(.login) \(.is_bot)"'`. The PR qualifies
   when `is_bot` is true, the login starts with `app/` (how GitHub Enterprise
   renders app identities, e.g. `app/dependabot`), the login ends in
   `[bot]`, or the login is one of `dependabot`, `renovate`, `renovate-bot`.
   If it does not qualify, say so and stop: this skill is for bot bumps, and
   a human-authored dependency change deserves a code review.
2. **Write the diff and the PR body to a work directory**, never into
   context. Use the session scratchpad directory when the system prompt
   names one; otherwise `mktemp -d`.
   ```bash
   GH_HOST=<host> gh pr diff <n> --repo <owner/repo> > <work>/pr-<n>.diff
   GH_HOST=<host> gh pr view <n> --repo <owner/repo> --json body --jq .body > <work>/pr-<n>.body.md
   ```
   Bot bodies carry release-note and commit excerpts the inventory subagent
   needs, and they are long.
3. **Fetch a metadata summary only**: title, base and head branches, head
   SHA, and the changed-file list with add/delete counts (`gh pr view --json`
   with `--jq` projections, never the raw JSON dump).
4. **Prior run check.** If the current user already posted a review or
   comment on this PR, note it; the presentation shows the prior verdict
   beside the new one. Bots rebase and force-push rather than append, so a
   re-run is always a full triage of the current head, never a delta.
5. **Freshen the checkout once.** If a local clone of the PR's repository is
   available (the cwd repo when its remote matches, or a path the user
   names), run `git -C <checkout> fetch origin --quiet`, then check whether
   the checked-out branch is even with its upstream
   (`git -C <checkout> rev-list --count HEAD..@{upstream}`). Record the
   result: **even**, subagents read the working tree with Read/Grep/Glob;
   **behind, ahead, or no upstream**, subagents use git ref reads only,
   against `origin/<base-branch>`. With no checkout at all, usage lookups are
   marked unverified.

## Stage 2: Inventory and pin verification (one subagent)

Spawn ONE subagent (general-purpose) with: the diff path, the PR body path,
the changed-file list, the checkout path with Stage 1's freshness result, and
the Contracts section above verbatim. It returns a compact **inventory**, one
row per bumped dependency, and nothing else:

- ecosystem (GitHub Actions, npm/yarn, RubyGems, pip, Go, Docker, Terraform,
  and so on), name, from-version, to-version;
- jump class: **patch**, **minor**, or **major** (semver when the dependency
  uses it; otherwise judged from the upstream's own versioning, and said so);
- for every SHA-pinned reference: whether the pinned SHA resolves to the tag
  the trailing comment claims. Resolve through the dependency's repository:
  `gh api repos/<owner>/<name>/git/ref/tags/<tag>`; when the object type is
  `tag` (annotated), dereference once more via `git/tags/<sha>`. A mismatch,
  an unresolvable tag, or a pin with no version comment is a PR defect,
  reported with file and line;
- the usage sites in this repository for each dependency (workflow files and
  `uses:` lines for Actions; import or require sites, or the manifest entry,
  for packages), found by grep against the checkout per Stage 1's freshness
  result, or marked unverified when no checkout is available;
- PR defects beyond pin verification: mixed pin styles, bare tags where the
  repository pins by SHA, updated references inside commented-out or
  disabled blocks, manifest and lockfile disagreeing.

The version table in the PR body is a claim like any other: the inventory is
built from the diff, and the body is used only to locate release-note
excerpts.

## Stage 3: Breaking-change scan (one subagent per major bump, concurrent)

Patch and minor bumps get no scan; they ride on the inventory. For each
**major** bump, spawn one subagent with that inventory row (name, from, to,
usage sites), the checkout path with freshness result, and the Contracts
section verbatim. It reads the upstream's release notes and changelog across
the from-to range (`gh api repos/<owner>/<name>/releases`, the compare view
between the two tags, or the changelog file at the target tag, whichever the
upstream publishes), extracts every documented breaking change, and for each
one checks the usage sites: does this repository use the input, default,
behavior, or runtime the change touches?

It returns, per breaking change: **relevant** (cites the usage file:line and
says what would need to be confirmed or changed) or **not relevant** (one
clause on why), plus any blanket note that applies across the bump: a new
minimum runner version when actions move to a newer Node runtime, a new
minimum language or engine version, a dropped platform. An upstream with no
published notes for the range is reported as exactly that, and its major
bump is treated as **relevant, unconfirmed**. Silence is not safety.

A relevant breaking change whose safety can be settled by reading (the
repository does not pass the removed input; the changed default is already
set explicitly) is settled and reported as such. One that can only be
settled by running something (does the yarn cache still populate, does the
artifact round-trip survive digest enforcement, does the push after checkout
still authenticate) is a **risk** and lands in the verdict.

## Stage 4: CI check (one subagent, concurrent with Stages 2 and 3)

Spawn a subagent that reads CI state through `gh` only:

```bash
GH_HOST=<host> gh pr checks <n> --repo <owner/repo>
```

On any failing check, find its run and write a bounded tail of the failed
job log to a file in the work directory, never into context:

```bash
GH_HOST=<host> gh run list --repo <owner/repo> --branch <head-branch> --limit 10 --json databaseId,name,conclusion
GH_HOST=<host> gh run view <run-id> --repo <owner/repo> --log-failed | tail -n 200 > <work>/ci-<run-id>.log
```

It returns: a per-check status table, a three-line-maximum failure summary
per failing check with its quoted evidence lines, and a judgment per failure:
related to this bump, pre-existing on the base branch, or unclear. Green does
not mean the check ran; a skipped or not-required check is reported as such.

A failing check judged related to the bump makes the verdict **Needs
investigation** at minimum, and its summary joins the risk list.

## Stage 5: Present the triage (main session)

Present the full triage as text output, in this order, with plain ASCII
numbering:

1. The inventory table: ecosystem, name, from, to, jump class, pin status.
2. PR defects, if any, each with file:line.
3. Per major bump: its breaking changes, each marked relevant / not relevant
   / risk, with the evidence.
4. Blanket notes.
5. The CI status table.
6. The **verdict** on its own line, with the risk list beneath it. Each risk
   names the dependency, what changed upstream, which usage it touches, and
   what would confirm it is safe.

There is no curation step. The verdict is the output. The user may still
disagree (a risk they know to be settled, a jump they want held back); that
conversation happens here, before anything is posted.

## Stage 6: Validation ticket (only on Needs investigation)

Before the comment is posted, so the comment can link the ticket, ask via
`AskUserQuestion`: "Open a validation ticket for the risks in PR #<n>?" with
options **Yes, open the ticket** and **No, comment only**.

On yes, draft the ticket body from the template below, show it in full, and
create it only after explicit approval:

```bash
GH_HOST=<host> gh issue create --repo <tracking-repo> --title "Validate breaking changes in <bot> dependency bump (PR #<n>)" --body-file <work>/ticket-<n>.md
```

The tracking repo is the PR's repo unless the user names another. Teams with
their own issue-drafting skill or template should invoke that instead of
this inline template; the content contract is the same.

Ticket body template:

```markdown
## Summary
[PR link] bumps N dependencies, M of which cross a major version. SHA pins
[verified / N defects found]. Several upgrades carry behavioral breaking
changes that need validation against this repository's usage before merging.

| Dependency | From | To | Risk |
|---|---|---|---|
[one row per bump; Risk is High / Medium / Low / None (patch), rated by
whether a relevant breaking change touches a real usage]

## Tasks
- [ ] [One per risk: "Validate <dependency> <to-version> <change>: confirm
      <usage site> still <behavior>"]
- [ ] [One per PR defect: "Fix <file>: <defect>"]
- [ ] [One per blanket note, when actionable: "Confirm runners meet >= <version>"]
- [ ] Run a representative set of workflows or tests on a test branch with
      the new versions before merging to the default branch

## Acceptance criteria
- [ ] Every identified breaking change confirmed safe against actual usage,
      or mitigated
- [ ] CI passes on a test branch with the updated versions
- [ ] All references use the repository's pinning convention consistently
- [ ] [PR link] merged, or a documented hold on specific upgrades
```

Take the created issue URL for the comment.

## Stage 7: Post the verdict comment

Draft the comment in the shape below, show it in full, and post only after
explicit approval. The reader is whoever decides whether to merge, not the
bot. Lead with the verdict, then show the work compactly. No praise section;
there is no author to acknowledge. Rows and risks come from the triage as
presented; this step words them, it does not re-rate them.

```markdown
**Verdict: Safe to merge** / **Verdict: Needs investigation**

[One or two sentences: how many dependencies bumped, how many crossed a major
version, pins verified or not.]

| Dependency | From | To | Jump | Notes |
|---|---|---|---|---|
[one row per bump; Notes carries "pin verified", a settled breaking change in
a clause, or "see risk N"]

### Risks
[Only when Needs investigation. Numbered. Each names the dependency, the
upstream change, the usage it touches, and what would confirm it is safe. End
with "Tracking validation in <ticket url>." when a ticket was opened.]

### PR defects
[Only when there are any. Each with file and line.]

[Blanket notes, if any, as a closing sentence.]
```

The action is fixed by the verdict; present it as a one-question
`AskUserQuestion` with the mapped action first and marked "(Recommended)":

| Outcome | Action | Command |
|---|---|---|
| Safe to merge, no PR defects | Approve | `gh pr review <n> --repo <owner/repo> --approve --body-file <file>` |
| Needs investigation | Comment | `gh pr comment <n> --repo <owner/repo> --body-file <file>` |
| Any PR defect, whatever the verdict | Request changes | `gh pr review <n> --repo <owner/repo> --request-changes --body-file <file>` |

Needs investigation posts a comment rather than a blocking review because the
risks are validated in the ticket, not negotiated with the bot; the PR stays
open and unblocked until that work lands. A PR defect is the PR being wrong
as written, so it blocks regardless.

Confirm the post succeeded and give the URL.

## Cost and re-runs

- Stage 2 is one subagent; Stage 3 is one per **major** bump and zero for a
  patch-only PR. A patch-only bump with clean pins costs one subagent plus
  the CI check and renders Safe to merge.
- A re-run after the bot rebases or the group changes is a fresh triage of
  the current head. There is no delta mode.

## Adapting this skill

- **Bot detection.** Extend the login list in Stage 1 for in-house bots.
- **Ticketing.** Replace the inline `gh issue create` in Stage 6 with a call
  to the team's own issue-drafting skill; keep the risk table and
  one-task-per-risk content.
- **Pinning policy.** If the repository has a written dependency or pinning
  policy, hand it to the Stage 2 subagent as a checklist; violations are PR
  defects.
- **Worked example of the Needs-investigation path.** A 13-action GitHub
  Actions group bump with 11 major jumps produced a ticket with a per-action
  risk table and seven validation tasks (credential persistence after a
  checkout major, yarn caching after a setup-node major, artifact digest
  enforcement, strict boolean inputs on an AWS credentials action, runner
  minimum version, one pre-existing unpinned reference, and a test-branch
  run). The PR merged eleven days later once every task was checked.
