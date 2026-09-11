# Security Review Criteria

**Issue Prefix**: `SEC`
**Condition**: Always run

## Focus Areas

Prioritize issues by **impact and exploitability**. Be paranoid and specific.

### 1. Input Handling & Injection

- SQL injection (unsafe string interpolation, raw SQL, dynamic column names)
- Command injection (shell/system calls, backticks, Open3, eval-like behavior)
- SSRF (user-controlled URLs in HTTP requests, webhooks, fetchers, crawlers)
- XSS (unsafe HTML rendering, user content, markdown rendering, admin UIs)
- Template injection, unsafe YAML/JSON deserialization

### 2. Authentication & Session Safety

- Missing or inconsistent authentication checks
- Session fixation, weak session invalidation, long-lived tokens
- MFA/OTP flows, step-up auth, recovery codes handling
- Password handling weaknesses

### 3. Secrets, Tokens, and Sensitive Data

- Secrets accidentally committed or logged
- Token leakage in URLs, logs, error messages, analytics events
- Overly verbose error responses in API endpoints
- PII exposure (emails, phone numbers, addresses, medical/financial fields)
- Unsafe file uploads: content type, size limits, public access

### 4. Web Security Controls

- CSRF protections (especially for state-changing actions)
- CORS misconfiguration
- Clickjacking protections, secure headers
- Open redirects

### 5. Background Jobs, Webhooks, External Integrations

- Webhook signature verification
- Replay attack resistance (timestamps/nonces)
- Untrusted payload parsing
- Rate limiting and abuse controls on expensive endpoints
- Third-party API calls with user-controlled parameters

### 6. Data Integrity & Safety

- Mass assignment risks / unsafe parameter permitting
- Dangerous migrations affecting data confidentiality
- Authorization in service objects/jobs (not only controllers)

## Severity Classification

| Severity | Criteria |
|----------|----------|
| Critical | Directly exploitable vulnerability with high impact (RCE, SQLi, auth bypass) |
| High | Exploitable vulnerability requiring some conditions |
| Medium | Security weakness that increases attack surface |
| Low | Defense-in-depth improvement, hardening opportunity |

## Output Format

For each issue found, capture:

```yaml
id: SEC-001
title: Short description
severity: Critical|High|Medium|Low
file: path/to/file.rb
line: 45
category: Injection|Auth|Secrets|WebSecurity|Jobs|DataIntegrity
description: |
  Detailed explanation of the vulnerability
exploit_scenario: |
  How an attacker would abuse this
recommended_fix: |
  Specific fix with code example
blocked_by: []
```
