---
name: Sandbox is a high environment
description: vets-api sandbox is customer-facing and should be treated with the same rigor as prod, not as a throwaway lower env
type: feedback
originSessionId: 7ebeef0b-5d31-4c59-a44c-d53d07205d23
---
Sandbox is used by customers for testing and is considered a **higher environment** — treat it with the same validation rigor as production, not as a lower/throwaway env alongside dev/staging.

**Why:** Customers test in sandbox. Mistakes there are visible externally, not just internally.

**How to apply:**
- Never bundle sandbox changes with staging in the same PR without explicit sandbox-specific validation
- Validate ArgoCD logs in sandbox independently before merging changes that affect it
- When sequencing rollouts (dev → staging → sandbox → prod), treat sandbox as its own gate, not an afterthought
