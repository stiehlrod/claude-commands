# Authorization & Data Access Review Criteria

**Issue Prefix**: `AUTH`
**Condition**: Always run

## Context

This is **enterprise software** with strict multi-tenancy requirements. Users must NEVER:
- See data belonging to other users
- Access resources from organizations they don't belong to
- Perform actions beyond their role permissions
- Bypass membership checks through direct object references

**Zero tolerance for authorization bugs.** A single missing scope can expose customer data.

## Focus Areas

### 1. Controller-Level Authorization

- Every controller action has explicit authorization
- No actions skip authorization without documented justification
- `current_user` is verified before any data access
- Organization context is established and validated early
- Role checks use proper hierarchy (admin > member > viewer)

**Red flags:**
- `skip_before_action :authenticate` without careful scoping
- Actions that assume authorization happened elsewhere
- `if current_user.admin?` without checking org membership first

### 2. Query Scoping (CRITICAL)

Every database query must be scoped to the appropriate tenant:

```ruby
# BAD - Unscoped, vulnerable to IDOR
Notification.find(params[:id])
Project.where(status: :active)

# GOOD - Scoped to current user/org
current_user.notifications.find(params[:id])
current_organization.projects.where(status: :active)
```

Check for:
- All `find`, `find_by`, `where` queries scoped to user/org/membership
- Join tables properly constrain access
- Nested resources validate parent ownership
- Polymorphic associations check resource ownership
- Counter caches and aggregations respect tenant boundaries

### 3. Organization & Membership Boundaries

- Organization lookups use `current_user.organizations` not `Organization.find`
- Membership verified before any org-scoped action
- Role checked after membership confirmed
- Invitation/join flows validate email ownership
- Org switching doesn't leak data from previous org context

### 4. User Data Isolation

- User preferences/settings scoped to `current_user`
- Notifications, activity logs scoped to user
- File uploads/attachments check ownership
- API keys/tokens scoped to creating user or org
- Search results filtered by access permissions

### 5. Service Objects & Background Jobs

Authorization is often forgotten outside controllers:

- Service objects receive and verify authorized context
- Background jobs re-validate permissions (don't trust enqueue-time checks)
- Mailers don't leak data to wrong recipients
- Broadcasts/Turbo streams scoped to authorized channels
- Webhooks validate ownership before processing

### 6. Views & Data Exposure

- Views don't render data from unscoped queries
- Partials don't assume authorization was checked
- JSON serializers exclude sensitive fields
- Turbo frames/streams check recipient authorization
- Error messages don't leak existence of resources

### 7. Edge Cases & Race Conditions

- Membership revocation immediately restricts access
- Deleted resources can't be accessed via cached references
- Concurrent requests can't bypass checks (TOCTOU)
- Soft-deleted records properly excluded from queries
- Invitation tokens invalidated after use

## Severity Classification

| Severity | Criteria |
|----------|----------|
| Critical | Direct data exposure to unauthorized users, missing auth check on sensitive action |
| High | IDOR possible, weak scoping that could be exploited |
| Medium | Defense-in-depth gap, inconsistent authorization pattern |
| Low | Hardening opportunity, authorization could be tighter |

## Output Format

For each issue found, capture:

```yaml
id: AUTH-001
title: Short description
severity: Critical|High|Medium|Low
file: path/to/file.rb
line: 45
category: IDOR|MissingAuth|ScopeGap|RaceCondition|DataLeak
description: |
  Detailed explanation of the authorization gap
exploit_scenario: |
  How an attacker would abuse this (step by step)
recommended_fix: |
  Specific fix with code example
blocked_by: []
```
