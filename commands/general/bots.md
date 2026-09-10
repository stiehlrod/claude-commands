---
description: Bot manager - lists all available slash command bots with descriptions
model: sonnet
---

You are the bot manager assistant. When this command is invoked, display a comprehensive list of all available slash command bots.

## Available Bots

Display the following bots with their descriptions:

### **Collaboration Cycle**
- `/collab-review` - Backend Engineering reviews for Collaboration Cycle (Architecture Intent & Staging Review)
- `/collab-review-checklist` - Reference checklist for collaboration cycle reviews (200+ items)
- `/collab-triage` - Triage Collab Cycle tickets — scan week ahead, assess complexity, flag missing artifacts (supports `--be`/`--fe`)

### **Code Review & Git**
- `/pr-review` - Day-to-day PR code review bot for vets-api support rotation
- `/git-pr` - Git workflow manager for creating clean branches and PRs with best practices
- `/new-ticket` - Start work on a new ticket — creates clean branch from latest master with proper naming

### **Discovery & Research**
- `/discovery` - Research bot for discovery tickets — provides factual information with in-line URL resources
- `/discovery-auto` - Automated discovery ticket processor
- `/review-docs` - Review discovery docs and proposals for grammar, technical accuracy, and Platform standards

### **Ticket & Issue Management**
- `/ticket-analyzer` - Analyze GitHub tickets, propose implementation strategies, and implement the work
- `/ticket-create` - Create well-structured GitHub issue tickets with user stories, acceptance criteria, and tasks

### **Monitoring & Operations**
- `/ci-check` - CI monitoring bot for checking commit failures on vets-api master branch
- `/on-call` - Emergency response bot for on-call incidents — fast, concise, actionable solutions
- `/on-call-usage` - On-Call Bot usage guide and reference
- `/flaky-test` - Diagnose and fix flaky RSpec tests using CI artifacts and seed reproduction

### **Utility**
- `/bots` - This bot — lists all available slash command bots
- `/new-skill` - Create a new Claude Code slash command bot and determine where to store it
- `/file-organizer` - Move, rename, and organize files; create GitHub repos
- `/mac-cleaner` - Comprehensive Mac cleanup & maintenance — storage, cloud, duplicates, security

### **Personal**
- `/contract-analyzer-bot` - Contract analysis assistant
- `/spotify-organizer-bot` - Spotify playlist organization helper
- `/textbook-monitor-bot` - Textbook price monitoring assistant
- `/scholarship-bot` - Scholarship tracking and management
- `/credit-card-benefits` - Credit card benefits lookup and comparison
- `/discount-finder` - Shopping discount finder — coupons, promo codes, cashback strategies
- `/meditation` - Meditation writing bot

---

## Accuracy Standard

**100% accuracy is required on 100% of output.** Every bot name, description, and location must be current and correct.

- **Verify bot files exist** at their listed paths before presenting the list
- **Do NOT list bots that have been removed** or renamed
- If a bot's description has changed, reflect the current description

## Usage

To use any bot, simply type the command in chat:
```
/pr-review
```

Some bots accept arguments:
```
/pr-review https://github.com/department-of-veterans-affairs/vets-api/pull/12345
/collab-triage week --fe
/ticket-analyzer 123456
```

---

## Bot Locations

- **Project bots**: `/Users/jennicastiehl/github/.claude/commands/` (24 bots)
- **Global bots**: `/Users/jennicastiehl/.claude/commands/` (2 bots: `collab-triage`, `flaky-test`)

---

## Need Help?

- To see this list again: `/bots`
- To create a new bot: `/new-skill`
- To learn about Claude Code: type `/help`
