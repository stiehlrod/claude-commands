---
name: authorization-review
description: Perform a comprehensive authorization and data access review. Focuses on multi-tenancy, IDOR prevention, and query scoping.
---

# Authorization & Data Access Review

Perform a comprehensive authorization and data access review of the code in the branch we're currently in.

## Git Context — Auto-Detect

Before reviewing, detect your git context:
```bash
if [ "$(git rev-parse --git-dir 2>/dev/null)" = "$(git rev-parse --git-common-dir 2>/dev/null)" ]; then echo "NORMAL"; else echo "WORKTREE"; fi
```
- **NORMAL**: Use `git diff main...HEAD` for branch changes
- **WORKTREE**: Use `git diff HEAD` — do NOT assume `main` exists or that merge-base is meaningful. Do NOT run destructive git commands. Prefer inspecting the working tree directly.

## Context

This is **enterprise software** with strict multi-tenancy requirements. Users must NEVER:
- See data belonging to other users
- Access resources from organizations they don't belong to
- Perform actions beyond their role permissions
- Bypass membership checks through direct object references

**Zero tolerance for authorization bugs.** A single missing scope can expose customer data.

## Instructions

This is an **authorization review**, not a general PR review.

Prioritize issues by **data exposure risk**. Be paranoid and assume attackers will:
- Guess/enumerate IDs (UUIDs don't prevent IDOR)
- Manipulate request parameters
- Exploit race conditions in membership checks
- Chain multiple small gaps into larger exploits

---

## Authorization Checklist

### 1. Controller-Level Authorization

- [ ] Every controller action has explicit authorization (`before_action`, policy check, or inline)
- [ ] No actions skip authorization without documented justification
- [ ] `current_user` is verified before any data access
- [ ] Organization context is established and validated early
- [ ] Role checks use proper hierarchy (admin > member > viewer)

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

**Check for:**
- [ ] All `find`, `find_by`, `where` queries scoped to user/org/membership
- [ ] Join tables properly constrain access (e.g., `user_notifications` not just `notifications`)
- [ ] Nested resources validate parent ownership
- [ ] Polymorphic associations check resource ownership
- [ ] Counter caches and aggregations respect tenant boundaries

### 3. Organization & Membership Boundaries

- [ ] Organization lookups use `current_user.organizations` not `Organization.find`
- [ ] Membership verified before any org-scoped action
- [ ] Role checked after membership confirmed
- [ ] Invitation/join flows validate email ownership
- [ ] Org switching doesn't leak data from previous org context

**Check these patterns:**
```ruby
# BAD - Trusts slug without membership check
@organization = Organization.find_by!(slug: params[:org_slug])

# GOOD - Validates membership
@organization = current_user.organizations.find_by!(slug: params[:org_slug])
# or
@membership = current_user.memberships.find_by!(organization: @organization)
```

### 4. User Data Isolation

- [ ] User preferences/settings scoped to `current_user`
- [ ] Notifications, activity logs scoped to user
- [ ] File uploads/attachments check ownership
- [ ] API keys/tokens scoped to creating user or org
- [ ] Search results filtered by access permissions

### 5. Service Objects & Background Jobs

Authorization is often forgotten outside controllers:

- [ ] Service objects receive and verify authorized context
- [ ] Background jobs re-validate permissions (don't trust enqueue-time checks)
- [ ] Mailers don't leak data to wrong recipients
- [ ] Broadcasts/Turbo streams scoped to authorized channels
- [ ] Webhooks validate ownership before processing

### 6. Views & Data Exposure

- [ ] Views don't render data from unscoped queries
- [ ] Partials don't assume authorization was checked
- [ ] JSON serializers exclude sensitive fields
- [ ] Turbo frames/streams check recipient authorization
- [ ] Error messages don't leak existence of resources

### 7. Edge Cases & Race Conditions

- [ ] Membership revocation immediately restricts access
- [ ] Deleted resources can't be accessed via cached references
- [ ] Concurrent requests can't bypass checks (TOCTOU)
- [ ] Soft-deleted records properly excluded from queries
- [ ] Invitation tokens invalidated after use

---

## Common Vulnerability Patterns

### Insecure Direct Object Reference (IDOR)
```ruby
# VULNERABLE
def show
  @notification = Notification.find(params[:id])  # Any user can access any notification
end

# SECURE
def show
  @notification = current_user.notifications.find(params[:id])  # Scoped to current user
end
```

### Missing Membership Check
```ruby
# VULNERABLE
def members
  @organization = Organization.find_by!(slug: params[:slug])
  @members = @organization.members  # Leaks member list to non-members
end

# SECURE
def members
  @organization = current_user.organizations.find_by!(slug: params[:slug])
  @members = @organization.members  # Only members can see members
end
```

### Nested Resource Trust
```ruby
# VULNERABLE - Trusts org_id from params
def show
  @project = Project.find_by!(organization_id: params[:org_id], id: params[:id])
end

# SECURE - Validates through membership
def show
  @organization = current_user.organizations.find_by!(slug: params[:org_slug])
  @project = @organization.projects.find(params[:id])
end
```

### Job/Service Authorization Gap
```ruby
# VULNERABLE - Job trusts enqueue-time authorization
class ExportDataJob < ApplicationJob
  def perform(user_id, org_id)
    org = Organization.find(org_id)  # User may have lost access since enqueue
    # ... exports data
  end
end

# SECURE - Re-validates at execution time
class ExportDataJob < ApplicationJob
  def perform(user_id, org_id)
    user = User.find(user_id)
    org = user.organizations.find(org_id)  # Validates current membership
    # ... exports data
  end
end
```

---

## What To Do

1. **Map all data access points** in the changed files
2. **Trace each query** back to its authorization check
3. **Enumerate findings** and rank them:
   - 🚨 Critical (direct data exposure, missing auth check)
   - ⚠️ High (IDOR possible, weak scoping)
   - 🟡 Medium (defense-in-depth gaps, inconsistent patterns)
   - 🟢 Low (hardening opportunities)
4. For each finding:
   - Explain the exploit scenario
   - Identify exact file(s) and line numbers
   - Propose specific fix with code example
5. **Call out "secure by default" patterns** so we preserve them

Do **not** focus on lint/style. Focus on **data access safety**.

---

## Claude Output Format

### Summary

- Overall authorization posture: ✅ solid / ⚠️ needs work / 🚨 vulnerable
- Top 3 risks (one line each)
- Scope of review (files/components examined)

### Findings (ranked by severity)

For each finding:

- **Severity**: 🚨 Critical / ⚠️ High / 🟡 Medium / 🟢 Low
- **Category**: IDOR / Missing Auth / Scope Gap / Race Condition / etc.
- **Location**: file path + line numbers
- **Exploit scenario**: How an attacker would abuse this
- **Recommended fix**: Specific code change

### Authorization Patterns (Good)

List patterns that are correctly implemented so we maintain them:
- Example: "User notifications properly scoped via `current_user.user_notifications`"
- Example: "Org membership validated in `set_organization` before_action"

### Testing Recommendations

Specific tests to add:
- IDOR tests (accessing other users' resources)
- Membership boundary tests
- Role escalation tests
- Race condition tests (if applicable)
