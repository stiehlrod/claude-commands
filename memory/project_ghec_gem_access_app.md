---
name: GHEC-US vets-api-gem-access app installation
description: Post-migration task to install the gem access GitHub App on all migrated gem repos so CI bundle install works
type: project
---

After migration, gem repos will be internal-visibility on GHEC-US. The `vets-api-gem-access` GitHub App must be installed on each gem repo so `bundle install` in vets-api CI can clone them.

**Why:** On github.com, gem repos are public so bundle install works without auth. On GHEC-US, internal-visibility repos require authentication. Without the app installed, CI fails with "Repository not found / Authentication failed."

**How to apply:** Before declaring migration complete, submit an install request for each gem repo.

## App Details
- **App name:** vets-api-gem-access
- **App ID:** 7521
- **Installation ID:** 38301 (current, for govdelivery-tms-ruby)
- **Owner:** software org (transferred from Jennica-Stiehl personal namespace)
- **Permission:** Repository → Contents → Read-only
- **CI usage:** `actions/create-github-app-token@v3` generates short-lived tokens for `bundle install`

## Installation Status
- govdelivery-tms-ruby — installed
- betamocks — needs installation
- vets-json-schema — needs installation
- fhir_client — needs installation
- bgs_ext — needs installation
- apivore — needs installation
- breakers — needs installation

## Request Process
Submit at: `https://va.ghe.com/github-admin/support/issues/new?template=install-app.yml`
Request: Install `vets-api-gem-access` (App ID: 7521) on the above repos in the `software` org.

## References
- Original support ticket: `https://va.ghe.com/github-admin/support/issues/1540`
- Rebecca Tolmach opened the original request (Mar 24, 2026)
- Paul Wideman (GitHub admin) confirmed the approach
