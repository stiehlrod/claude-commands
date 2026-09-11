---
name: help
description: Draft a detailed prompt asking an external LLM (or another knowledgeable reviewer) for help with a specific problem. Include all relevant code context so the prompt is self-contained. Use when stuck, when you want to sanity-check an approach, or when another model's perspective would help.
argument-hint: "<description of the problem>"
---

# Help

Draft a self-contained prompt the user can paste into another LLM (or share with a colleague) to get a second perspective on a problem.

## Instructions

Write a detailed prompt that explains the problem and includes all the context the external reader needs to give a useful answer. The user will paste your output elsewhere and bring back the response — so the prompt must be self-contained.

### Mandatory: redact before output

The output will leave the project boundary. Before producing the final prompt, redact:

- **Secrets and credentials** — API keys, tokens, passwords, OAuth client secrets, JWT signing keys, AWS access keys, database URIs with embedded credentials, anything from `.env`, `config/credentials*`, `config/master.key`
- **Customer / user identifiers** — real email addresses, names, phone numbers, account IDs, organization IDs, PII of any kind
- **Internal hostnames or URLs** — staging/prod hostnames that aren't public, internal-tooling URLs
- **Proprietary identifiers** — internal product codenames, customer-specific slugs, contract IDs

Replace each with a clearly-fake placeholder (`<API_KEY>`, `user@example.com`, `acct_PLACEHOLDER`). If you find anything sensitive that doesn't have an obvious generic substitute, **stop and ask the user before continuing** rather than guessing.

### Prompt content

- **State the problem first** — one or two sentences on what's happening and what you've tried
- **Include the relevant code verbatim** — file paths and the actual snippets (after redaction), not paraphrases. The external reader cannot grep this repo
- **Include the error or unexpected output** if there is one (after redaction)
- **State what you've already ruled out** so the reader doesn't suggest things you've tried
- **Ask a specific question** at the end — not "what do you think" but "is X the right approach, and if not, what would you do instead"
- **Stay provider-agnostic** in the prompt body — don't address the prompt to "ChatGPT" or "Gemini" by name. The user may route it anywhere

Output the prompt as plain text, no preamble, no follow-up commentary — just the prompt itself, ready to copy-paste.
