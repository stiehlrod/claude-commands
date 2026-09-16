---
name: OOB Single-Commit Deploy Strategy
description: Strategy for deploying individual commits to prod OOB instead of all accumulated commits — vets-api on EKS
type: project
---

## Problem
When a vets-api OOB is deployed, it deploys all prior merged commits since the last prod deploy. Goal is to deploy a single commit to prod when needed.

## Current Pipeline (vets-api on EKS)
- PR merges to master → Docker image built (tagged with SHA) → pushed to ECR → manifest updated in `vsp-infra-application-manifests` → ArgoCD syncs
- dev/staging: ArgoCD autosync (immediate)
- prod/sandbox: scheduled ArgoCD sync
- Uses rolling update pattern, Helm charts, bulkhead pattern in prod
- Every commit already has its own Docker image in ECR tagged by SHA

## Proposed Solution
Pin the prod manifest to a specific image tag instead of latest:

1. Engineer triggers a GitHub Actions workflow (`oob-deploy.yml`) with a commit SHA
2. Workflow verifies that SHA's image exists in ECR
3. Workflow updates **only the prod values** in the manifest repo to that specific image tag
4. ArgoCD syncs prod with just that image
5. After OOB, resume normal promotion flow

## Requirements
- GitHub Actions workflow accepting commit SHA as input
- Decouple prod manifest image tag from dev/staging
- "Resume normal" step to point prod back to latest after freeze lifts
- No cherry-pick branches needed — images already built per-commit

**Why:** Reduces risk of OOB deploys pulling in unrelated changes. Leverages existing per-commit images in ECR.

**How to apply:** When working on OOB deploy pipeline changes, this is the agreed-upon strategy. Reference `vsp-infra-application-manifests` for manifest structure.
