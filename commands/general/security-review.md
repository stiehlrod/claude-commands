---
name: security-review
description: Perform a security-focused review of the current branch. Covers injection, auth, secrets, CSRF, and more.
---

# Security Review

Perform a security-focused review of the code in the branch we're currently in.

## Git Context — Auto-Detect

Before reviewing, detect your git context:
```bash
if [ "$(git rev-parse --git-dir 2>/dev/null)" = "$(git rev-parse --git-common-dir 2>/dev/null)" ]; then echo "NORMAL"; else echo "WORKTREE"; fi
```
- **NORMAL**: Use `git diff main...HEAD` for branch changes
- **WORKTREE**: Use `git diff HEAD` — do NOT assume `main` exists or that merge-base is meaningful. Do NOT run destructive git commands. Prefer inspecting the working tree directly.

## Instructions

This is a **security review**, not a general PR review.

Prioritize issues by **impact and exploitability**. Be paranoid and specific.

Actively look for:

### Input Handling & Injection

- SQL injection (unsafe string interpolation, raw SQL, dynamic column names)
- Command injection (shell/system calls, backticks, Open3, eval-like behavior)
- SSRF (user-controlled URLs in HTTP requests, webhooks, fetchers, crawlers)
- XSS (unsafe HTML rendering, user content, markdown rendering, admin UIs)
- Template injection, unsafe YAML/JSON deserialization

### Authentication & Session Safety

- Missing or inconsistent authentication checks
- Session fixation, weak session invalidation, long-lived tokens
- MFA/OTP flows, step-up auth, recovery codes handling
- Password handling weaknesses

> Authorization concerns (IDOR, scope leaks, privilege escalation, multi-tenancy) are covered by `/authorization-review`.

### Secrets, Tokens, and Sensitive Data

- Secrets accidentally committed or logged
- Token leakage in URLs, logs, error messages, analytics events
- Overly verbose error responses in API endpoints
- PII exposure (emails, phone numbers, addresses, medical/financial fields)
- Unsafe file uploads / ActiveStorage: content type, size limits, public access

### Web Security Controls

- CSRF protections (especially for state-changing actions)
- CORS misconfiguration
- Clickjacking protections, secure headers where relevant
- Open redirects

### Background Jobs, Webhooks, and External Integrations

- Webhook signature verification
- Replay attack resistance (timestamps/nonces)
- Untrusted payload parsing
- Rate limiting and abuse controls on expensive endpoints
- Third-party API calls with user-controlled parameters

### Data Integrity & Safety

- Mass assignment risks / unsafe parameter permitting
- Dangerous migrations affecting data confidentiality (backfills leaking data)
- Authorization in service objects/jobs (not only controllers)

## What To Do

1. Enumerate security findings and rank them:
   - 🚨 Critical (likely exploitable, high impact)
   - ⚠️ High
   - 🟡 Medium
   - 🟢 Low / Hardening
2. For each finding:
   - Explain the exploit scenario (how it would be abused)
   - Identify the exact file(s) and code area
   - Propose a specific fix (not vague advice)
3. Call out "looks safe" areas too (so we don't regress later)

Do **not** focus on lint/style. Focus on real security risk.

## Claude Output Format

### Summary

- Overall security posture: ✅ solid / ⚠️ needs work / 🚨 risky
- Top 3 risks (one line each)

### Findings (ranked)

For each finding:

- Severity
- Location (file path)
- Exploit scenario
- Recommended fix

### Quick Wins

- Small changes that reduce risk significantly
