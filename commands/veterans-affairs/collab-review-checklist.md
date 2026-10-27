# Collaboration Cycle Manager Bot

## Purpose
Automated review system for VA.gov Collaboration Cycle to ensure government standards, security compliance, and architecture patterns are met.

---

## Review Categories

### 1. Architecture Intent Review
### 2. Staging Review
### 3. Code Quality & Best Practices
### 4. Security & Compliance
### 5. Backend Standards (vets-api specific)

---

## 1. ARCHITECTURE INTENT REVIEW CHECKLIST

### Engineering & Security Checklist Completeness

#### **Product Description**
- [ ] **Required:** Brief overview of motivation provided
- [ ] **Required:** Link to Collaboration Cycle Request issue included
- [ ] **Recommended:** Problem statement clearly articulated

#### **Frontend Changes**
- [ ] **Required:** Significant code changes identified (new functions, refactors)
- [ ] **Required:** New design system components documented or changes to existing components noted
- [ ] **Recommended:** Product analytics strategy described
- [ ] **Recommended:** Frontend error detection strategy documented
- [ ] **Consider:** Impact on shared code assessed

#### **Backend Changes**
- [ ] **Required:** New/unusual infrastructure dependencies documented
- [ ] **Required:** New connections or information exchanges with external systems described
- [ ] **Required:** PII/PHI transmission and storage documented
- [ ] **Required:** API success/failure determination strategy defined
- [ ] **Recommended:** All failure and error cases handled while in custody of user data
- [ ] **Recommended:** Information captured in logs/metrics documented
- [ ] **Recommended:** Impact on shared code assessed
- [ ] **Consider:** API polling strategy (if applicable)

#### **User-Uploaded Data**
- [ ] **Required:** If handling user uploads, virus scanning implemented
- [ ] **Required:** Temporary file handling and cleanup process documented
- [ ] **Required:** File materialization location specified

#### **Internal API Changes**
- [ ] **Required:** New or modified vets-api endpoints documented
- [ ] **Required:** API documentation provided (Swagger/OpenAPI)
- [ ] **Required:** Schema validation enforced (vets-json-schema)
- [ ] **Recommended:** Expected call patterns described
- [ ] **Recommended:** Rate limiting/throttling requirements identified
- [ ] **Recommended:** Third-party integrations vetted
- [ ] **Recommended:** Scheduled/cron jobs impact assessed (especially during high traffic)
- [ ] **Consider:** Deprecation/removal of APIs documented

#### **External API Changes**
- [ ] **Required:** New/modified upstream APIs listed
- [ ] **Required:** PII/PHI transmission documented
- [ ] **Required:** Expected call patterns described

#### **Background Jobs**
- [ ] **Required:** Required background processing listed
- [ ] **Required:** Error and dead letter handling described
- [ ] **Recommended:** Impact during high-volume periods assessed

#### **Data Storage**
- [ ] **Required:** New/modified databases, tables, or columns described
- [ ] **Required:** Indexes and constraints documented
- [ ] **Required:** PII/PHI storage, processing, expiration, and deletion documented
- [ ] **Required:** Data expiration policy defined
- [ ] **Required:** Cleanup/removal mechanism specified
- [ ] **Recommended:** Large or new data volume impact assessed
- [ ] **Recommended:** Impact on database/caching layers (Redis, Postgres) evaluated
- [ ] **Recommended:** New caches: caching hypothesis stated (instance, TTL, pattern, why); Rails.cache unless app-data is justified (see collab-review.md "Caching")
- [ ] **Recommended:** Cached PII/PHI encrypted with Lockbox (compress first if >1 KB), per-user keys, every entry has a TTL
- [ ] **Consider:** Memory, CPU, and data volume implications

#### **Libraries and Dependencies**
- [ ] **Required:** New or updated dependencies listed
- [ ] **Recommended:** Dependency selection rationale provided
- [ ] **Consider:** Security implications of dependencies assessed

#### **Metrics, Logging, Observability**
- [ ] **Required:** Key monitoring areas identified
- [ ] **Required:** Sensitive data risks in logging mitigated
- [ ] **Recommended:** Custom metric tags cost and cardinality considered
- [ ] **Recommended:** Datadog dashboard plan provided

#### **Infrastructure and Network**
- [ ] **Required:** Infrastructure/network changes or additions listed
- [ ] **Recommended:** Security implications assessed

#### **Test Strategy**
- [ ] **Required:** Automated, manual, and UAT strategies described
- [ ] **Required:** Required test data and test user accounts described
- [ ] **Recommended:** VCR cassettes for external services planned

#### **Rollout Plan**
- [ ] **Required:** Feature flag scope listed
- [ ] **Required:** Rollback plan described
- [ ] **Recommended:** Other teams to coordinate with identified
- [ ] **Recommended:** Phased rollout strategy (Phase I, II, Go Live) documented

#### **Internal Administration**
- [ ] **Recommended:** Periodic maintenance/administration tasks described
- [ ] **Recommended:** Task execution method specified (web page, terminal, etc.)

---

### Security Checklist Review

#### **Problem & Monitoring**
- [ ] **Required:** Problem being solved clearly described
- [ ] **Required:** Monitoring plan for code compromise detection provided
- [ ] **Required:** Process to disable code in product documented
- [ ] **Required:** Process privilege and isolation documented
- [ ] **Recommended:** Dashboard links for debugging provided
- [ ] **Recommended:** Release plan with "Planning" sections completed

#### **Endpoints & Abuse**
- [ ] **Required:** New endpoints documented (front/back-end)
- [ ] **Required:** Abuse scenarios and mitigation plans provided
- [ ] **Consider:** OWASP Top 10 vulnerabilities assessed (XSS, SQL injection, command injection)

#### **Logging & PII/PHI** (Updated June 2025)
- [ ] **Required:** New logging data capture documented
- [ ] **Required:** If PII/PHI/PI captured, strong encryption confirmed
- [ ] **Required:** If PII captured, ability to scrub data confirmed
- [ ] **Required:** No logging of full `response_body` containing sensitive data
- [ ] **Required:** Custom log statements use `ParameterFilterHelper.filter_params()`
- [ ] **Required:** Rails parameter filtering confirmed for custom logging (not automatic)
- [ ] **Recommended:** Cookie usage justified and documented

#### **Artifacts**
- [ ] **Required:** Architecture Diagram provided (scope, dependencies, security approaches)
- [ ] **Required:** Incident Response Plan provided (contacts, timeline for fixes)
- [ ] **Required:** Sequence Diagram provided (including authentication)
- [ ] **Required:** Data Flow Diagram provided (data collection, storage, transfer, access, audit trail)
- [ ] **Required:** API Endpoint Documentation provided
- [ ] **Required:** Release Plan link provided
- [ ] **Required:** Product Outline link provided (with incident response, dashboards, playbook)
- [ ] **Required:** Code links provided (frontend, backend, DevOps)

---

## 2. STAGING REVIEW CHECKLIST

### Architecture Intent Feedback Verification
- [ ] **Required:** All "Required" feedback from Architecture Intent addressed
- [ ] **Recommended:** All "Recommended" feedback addressed or explanation provided
- [ ] **Consider:** "Consider" feedback evaluated

### Code Implementation Review

#### **Routing & Authorization**
- [ ] **Required:** Endpoints properly routed on api.va.gov
- [ ] **Required:** Authorization implemented through appropriate policies
- [ ] **Required:** Authentication status clearly defined

#### **Input Validation**
- [ ] **Required:** User input validated
- [ ] **Required:** Form submissions validated
- [ ] **Required:** Schema validation enforced (vets-json-schema)

#### **External Service Integration**
- [ ] **Required:** External service client properly instantiated
- [ ] **Required:** Response data properly serialized and rendered
- [ ] **Required:** Error handling for external service failures implemented
- [ ] **Recommended:** Circuit breaker/retry logic implemented for resilience

#### **Testing Coverage**
- [ ] **Required:** User flows tested in staging with multiple scenarios
- [ ] **Required:** VCR cassettes recorded for external services
- [ ] **Required:** VCR cassettes scrubbed of sensitive data
- [ ] **Required:** Test coverage adequate for critical paths
- [ ] **Recommended:** Edge cases and error scenarios tested

---

## 3. CODE QUALITY & BEST PRACTICES

### Pull Request Standards
- [ ] **Required:** PR size under 500 lines (or detailed explanation provided)
- [ ] **Required:** PR title summarizes changes
- [ ] **Required:** Description includes linked issues and testing instructions
- [ ] **Required:** All required checks passing
- [ ] **Required:** Team member approval obtained
- [ ] **Required:** Jira details included in PR body
- [ ] **Recommended:** Screenshots provided for visual changes
- [ ] **Recommended:** Code linted before submission
- [ ] **Consider:** Separate PRs for each feature

### Code Organization
- [ ] **Required:** Uses main branch as base
- [ ] **Recommended:** Separate branches for each feature
- [ ] **Recommended:** Code follows Rails idioms and conventions
- [ ] **Consider:** Code readability optimized

---

## 4. SECURITY & COMPLIANCE

### PII/PHI Handling (Updated June 2025)
- [ ] **Required:** VA PII never stored/processed on non-VA assets
- [ ] **Required:** PII stored only in approved locations (GFE, VA Azure, VA.gov AWS, PersonalInformationLog)
- [ ] **Required:** ICN not stored in unauthorized systems (Datadog, Sentry, Google Analytics, Domo)
- [ ] **Required:** ICN not in unencrypted database fields
- [ ] **Required:** `user_account_uuid` used instead of ICN for linking
- [ ] **Required:** Parameter filtering using `Rails.application.config.filter_parameters`
- [ ] **Required:** Custom log statements use `ParameterFilterHelper.filter_params()` (Rails filtering does NOT protect custom logs automatically)
- [ ] **Required:** No logging of full `response_body` containing sensitive data (can expose ICNs, names, addresses, phone numbers)
- [ ] **Required:** No PII in VCR cassettes
- [ ] **Required:** `filter_sensitive_data` VCR configuration applied
- [ ] **Required:** No sharing PII/tokens/credentials with external AI tools (ChatGPT, Copilot)
- [ ] **Required:** PII/PHI in Rails.cache or Redis encrypted at rest with Lockbox (caching policy)
- [ ] **Required:** Data classified using the Platform PII/PHI definition (direct, indirect, aggregation); ICN, EDIPI, and IP address are direct PII

### Prohibited Actions
- [ ] **Required:** No emailing PII-containing files to non-VA addresses
- [ ] **Required:** No storing datasets with PII on non-government equipment
- [ ] **Required:** No sharing PII/tokens/credentials with external AI tools
- [ ] **Required:** Encrypted VA email only for sensitive information

### Logging Best Practices
- [ ] **Recommended:** Structured logging with key-value pairs
- [ ] **Recommended:** Non-PII fields logged only
- [ ] **Recommended:** Known sensitive fields redacted before logging
- [ ] **Consider:** Hashing identifiers for trace correlation

---

## 5. BACKEND STANDARDS (vets-api)

### Database Migrations
- [ ] **Required:** Zero-downtime compatible (no downtime required)
- [ ] **Required:** All running versions maintain schema compatibility
- [ ] **Required:** No rollbacks (migrations forward-only)
- [ ] **Required:** Index operations use `concurrently` algorithm
- [ ] **Required:** Columns with defaults added in multiple steps
- [ ] **Required:** Non-null columns added as multi-step process
- [ ] **Required:** Type changes use new column + dual writes + migration
- [ ] **Required:** Data migrations implemented as rake tasks in `lib/data_migrations/`
- [ ] **Required:** Table removal follows three-step process
- [ ] **Recommended:** `zero_downtime_migrations` gem safeguards leveraged

### External Service Integration
- [ ] **Required:** Forward proxy connectivity tested with `curl`
- [ ] **Required:** Forward proxy configuration added to all environments (dev, staging, sandbox, prod)
- [ ] **Required:** SSL certificates generated via Venafi
- [ ] **Required:** Certificates stored as Jinja2 templates in `ansible/deployment/config/fwdproxy/`
- [ ] **Required:** Private keys stored in AWS Parameter Store at `/devops/certificates/<service>.key`
- [ ] **Required:** Forward proxy ports validated in `listener_ports` terraform variable
- [ ] **Required:** Host redirects updated in vets-api settings
- [ ] **Recommended:** ESECC request submitted for non-443 ports
- [ ] **Consider:** Short-circuit/health check leveraged for resilience

### VCR Testing
- [ ] **Required:** VCR cassettes recorded for external service calls
- [ ] **Required:** Cassettes contain no sensitive information
- [ ] **Required:** Local credentials in `settings/test.local.yml` (git-ignored)
- [ ] **Required:** One cassette per test when possible
- [ ] **Recommended:** `filter_sensitive_data` applied in VCR initialization
- [ ] **Recommended:** Cassette contents inspected before committing
- [ ] **Consider:** Forward proxy or review instances for complex scenarios

### Sidekiq Background Jobs
- [ ] **Required:** Job monitoring via `/sidekiq` endpoint accessible
- [ ] **Recommended:** Job error handling implemented
- [ ] **Recommended:** Dead letter queue handling defined
- [ ] **Consider:** Job impact during high-traffic periods assessed

### API Deprecation
- [ ] **Required:** Deprecation announced to teams (Slack, docs, meetings)
- [ ] **Required:** Deprecation plan and timeline documented
- [ ] **Required:** Comments added to controllers marking deprecated endpoints
- [ ] **Required:** CODEOWNERS file updated
- [ ] **Recommended:** Datadog dashboard tracking deprecation traffic
- [ ] **Recommended:** Legacy endpoints isolated behind version namespace (`v0::Deprecated`)
- [ ] **Recommended:** Swagger documentation updated with deprecation dates
- [ ] **Recommended:** Feature toggles implemented for gradual rollout
- [ ] **Recommended:** Follow-up removal tickets created
- [ ] **Consider:** Dual routing during transition period

### Monitoring & Observability
- [ ] **Required:** Datadog dashboard configured
- [ ] **Required:** Key metrics and alerts identified
- [ ] **Recommended:** StatsD instrumentation for critical paths
- [ ] **Recommended:** Sentry error tracking configured
- [ ] **Consider:** Custom metric tag cardinality and cost

---

## REVIEW OUTPUT FORMAT

All feedback should use GitHub checkbox format with Launch-blocking/Required/Recommended/Consider classification and a friendly, collaborative tone:

```markdown
## Backend Engineering Feedback for [Architecture Intent|Staging Review]

**BLUF:** [No backend engineering concerns OR X item(s) to address, Y launch-blocking (if applicable)]

---

Thanks for submitting this for review!

### Launch-blocking

These items must be resolved before launch (add `launch-blocking` label to ticket):

- [ ] **[Item title]** - [Explanation of the issue and why this blocks launch]

### Highly Recommended

We highly recommend addressing these items before moving forward:

- [ ] **[Item title]** - [Details and explanation of why this is needed]

### Recommended

We recommend addressing these items to align with best practices:

- [ ] **[Item title]** - [Explanation of how this would improve the implementation]

### Suggestions

These are optional improvements to consider:

- [ ] **[Item title]** - [Suggestion and potential benefit]

---

If you have any questions about this feedback, please comment on this ticket and tag the relevant reviewer(s). We're happy to discuss any of these items!

**Note:** [For Staging Review only] Please hold off on making changes until after our upcoming meeting, as changes may impact the Governance review. Thank you!

cc @reviewer-handle
```

---

## LAUNCH-BLOCKING CRITERIA (Staging Review)

An issue is **launch-blocking** if it:
- Greatly compromises safety/security of VA.gov
- Makes infrastructure unstable
- Drastically outside VA.gov norms and best practices
- Violates VA.gov Experience Standards

Launch-blocking issues require the `launch-blocking` label on the ticket.

---

## USAGE INSTRUCTIONS

### For Architecture Intent Review:
1. Review product outline and Engineering & Security Checklist
2. Review architecture diagrams, sequence diagrams, data flow diagrams
3. Assess against Architecture Intent Review Checklist
4. Provide Must/Should/Consider feedback in GitHub format
5. Check completion box in Collab Cycle ticket

### For Staging Review:
1. Verify Engineering & Security Checklist updated per Architecture Intent feedback
2. Review full codebase against all checklists
3. Test user flows in staging environment
4. Identify findings (must answer YES to: Would this cause issues? Compromise safety?)
5. Determine if findings are launch-blocking
6. Provide findings in GitHub format with launch-blocking label if applicable
7. Check completion box in Collab Cycle ticket

### For PR Reviews (General):
1. Review against Code Quality & Best Practices
2. Review against Security & Compliance
3. Review against Backend Standards (if applicable)
4. Provide feedback in review comments
5. Request changes if Must items not met
6. Approve if standards met

---

## REFERENCE DOCUMENTATION

- Backend Developer Documentation: https://depo-platform-documentation.scrollhelp.site/developer-docs/backend-developer-documentation
- PII Guidelines (Updated June 2025): https://depo-platform-documentation.scrollhelp.site/developer-docs/personal-identifiable-information-pii-guidelines
- What is PII/PHI (Updated June 2025): https://depo-platform-documentation.scrollhelp.site/research-design/what-is-pii
- vets-api Caching Best Practices (Updated Oct 2026): https://depo-platform-documentation.scrollhelp.site/developer-docs/vets-api-caching-best-practices
- Database Migrations: https://depo-platform-documentation.scrollhelp.site/developer-docs/vets-api-database-migrations
- External Service Integration (Updated Aug 2025): https://depo-platform-documentation.scrollhelp.site/developer-docs/adding-a-new-external-service-integration
- VCR Testing: https://depo-platform-documentation.scrollhelp.site/developer-docs/vcr-debugging
- Sidekiq Jobs: https://depo-platform-documentation.scrollhelp.site/developer-docs/sidekiq-jobs
- API Deprecation: https://depo-platform-documentation.scrollhelp.site/developer-docs/deprecating-api-endpoints
- Pull Request Best Practices: https://depo-platform-documentation.scrollhelp.site/developer-docs/pull-request-best-practices
- Submitting PRs: https://depo-platform-documentation.scrollhelp.site/developer-docs/submitting-pull-requests-for-approval
- **Staging Review Accessibility (NEW Pilot)**: https://depo-platform-documentation.scrollhelp.site/collaboration-cycle/prepare-for-an-accessibility-staging-review
- Architecture Intent: https://depo-platform-documentation.scrollhelp.site/collaboration-cycle/architecture-intent

---

## SUPPORT

For questions or clarification:
- Slack: `#vfs-platform-support`
- Slack: `#platform-collaboration-cycle`
