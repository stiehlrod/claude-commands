---
model: sonnet
---

# On-Call Bot Usage Guide

## Quick Start

```
/on-call [describe your emergency]
```

## Examples

### Service Down
```
/on-call all pods are crashing with OOMKilled
```

### Certificate Issues
```
/on-call SSL certificate expired on api.va.gov
```

### Error Spike
```
/on-call seeing 500 errors spike on /v0/user endpoint
```

### Database Issues
```
/on-call database connections exhausted, cannot connect
```

### Performance Problems
```
/on-call API response times are very slow, 5+ seconds
```

### Sidekiq Backup
```
/on-call sidekiq queue backed up, 10000 jobs pending
```

## What You'll Get

The bot provides:
1. **🚨 Immediate Action**: Commands to run RIGHT NOW
2. **📊 Diagnosis**: What to look for in logs/metrics
3. **🔧 Fix**: Step-by-step resolution with actual commands
4. **⚠️ Escalation**: When to call for help
5. **📚 Reference**: Links to detailed docs

## Tips for Best Results

✅ **DO**: Be specific about symptoms
- "500 errors on /v0/claims endpoint"
- "Pods restarting every 2 minutes"
- "Database connection pool exhausted"

❌ **DON'T**: Be vague
- "Something's broken"
- "Users are complaining"
- "Fix the API"

## Bot Capabilities

### Covered Incident Types
- Service down / traffic stopped
- Certificate failures
- Error spikes
- Database connection issues
- Sidekiq queue backups
- Memory leaks / OOM kills
- Slow API responses
- External service failures

### Quick Commands Available
- Kubernetes pod management
- Rails console access patterns
- Database diagnostic queries
- Sidekiq queue management
- Rollback procedures
- Scaling operations

### Documentation Access
The bot has indexed references to:
- Platform developer documentation
- Database migration guides
- External service integration docs
- Sidekiq job documentation
- PII/security guidelines
- Common runbooks

## When to Use

### ✅ Use On-Call Bot For:
- **Emergencies**: Need fix NOW
- **Common patterns**: Error spike, pod crash, cert failure
- **Quick commands**: What kubectl/SQL to run
- **Escalation guidance**: Who to call

### ❌ Use Other Bots For:
- **Deep research**: Use `/discovery`
- **Code review**: Use `/pr-review`
- **CI failures**: Use `/ci-check`
- **Planning**: Use regular Claude

## Example Session

```
User: /on-call all vets-api pods are OOMKilled

Bot:
🚨 IMMEDIATE ACTION
Check pod restarts and memory usage:
kubectl get pods -n vets-api -o wide | grep -v "0.*Running"
kubectl top pods -n vets-api --sort-by=memory
kubectl describe pod <failing-pod> -n vets-api | grep -A 10 Events

📊 DIAGNOSIS
Look for:
- "OOMKilled" in pod status
- Memory usage climbing to limit
- Frequent restarts (every few minutes)

🔧 FIX
1. Immediate: Restart pods
   kubectl rollout restart deployment/vets-api -n vets-api

2. Short-term: Increase memory limits
   Edit deployment YAML to increase memory

3. Long-term: Find memory leak
   Profile code with memory_profiler gem

⚠️ ESCALATE IF:
- Restarts don't help
- Production severely impacted
- Leak source unclear

📚 Reference: https://depo-platform-documentation.scrollhelp.site/developer-docs/backend-developer-documentation
```

## Advanced: Documentation Lookups

If you need deeper explanation (not emergency):

```
/on-call explain zero-downtime database migrations in detail
```

The bot will fetch relevant documentation and provide detailed context.

## Integration with Other Tools

### DataDog
Bot references DataDog URLs for:
- APM traces
- Log analysis
- Metrics dashboards

### Kubernetes
Provides `kubectl` commands you can copy/paste

### Rails Console
Shows safe Rails console queries for diagnostics

### Database
Provides PostgreSQL diagnostic queries

## Safety Features

The bot will:
- ✅ Provide commands but NOT execute them
- ✅ Warn about destructive operations
- ✅ Recommend escalation when needed
- ✅ Reference documentation for verification

You remain in control:
- You review commands before running
- You decide when to escalate
- You make production changes

## Customization

Want to add incident patterns? Edit:
```
~/github/.claude/commands/on-call.md
```

Add new sections following the existing format:
```markdown
### 🔴 New Incident Type

**Symptoms**: [what you see]
**Immediate Action**: [commands to run]
**Common Causes**: [root cause patterns]
**Fix Patterns**: [resolution steps]
**Escalate if**: [when to get help]
**Reference**: [doc URL]
```

## Accuracy Standard

**100% accuracy is required on 100% of output.** Every command example, capability description, and reference link must be current and correct.

## Feedback

Found an issue or want to add incident patterns?
- Edit `~/github/.claude/commands/on-call.md`
- Commit and push to share with team
