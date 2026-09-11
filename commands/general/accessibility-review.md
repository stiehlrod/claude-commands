---
name: accessibility-review
description: Perform an accessibility-focused review of the current branch. Targets WCAG 2.1 AA compliance across web, iOS, and Android.
---

# Accessibility Review

Perform an accessibility-focused review of the code in the branch we're currently in.

## Git Context — Auto-Detect

Before reviewing, detect your git context:
```bash
if [ "$(git rev-parse --git-dir 2>/dev/null)" = "$(git rev-parse --git-common-dir 2>/dev/null)" ]; then echo "NORMAL"; else echo "WORKTREE"; fi
```
- **NORMAL**: Use `git diff main...HEAD` for branch changes
- **WORKTREE**: Use `git diff HEAD` — do NOT assume `main` exists or that merge-base is meaningful. Do NOT run destructive git commands. Prefer inspecting the working tree directly.

## Platform Context

Identify which platforms this project targets (e.g., web only, web + mobile web, web + native iOS/Android via Hotwire Native or similar hybrid frameworks). Prioritize the platforms the user actually ships to.

If the project includes native or hybrid mobile, **prioritize mobile accessibility** — its constraints (touch targets, screen-reader behavior, keyboard types) are stricter than desktop and frequently overlooked.

## Instructions

This is an **accessibility review**, not a general PR review.

Target compliance: **WCAG 2.1 AA**. Prioritize issues by **user impact and frequency**.

Actively look for:

### Semantic HTML & Structure

- Missing or incorrect landmark roles (`<main>`, `<nav>`, `<aside>`, `<header>`, `<footer>`)
- Heading hierarchy violations (skipped levels, multiple `<h1>`, non-semantic heading styles)
- Lists not using `<ul>/<ol>/<dl>` elements
- Tables missing `<caption>`, `<th>`, `scope`, or `headers` attributes
- Non-semantic divs/spans used for interactive elements

### Keyboard Navigation

- Interactive elements not focusable (missing `tabindex`, non-button clickables)
- Focus traps (modals, dropdowns that don't return focus)
- Missing or illogical focus order
- No visible focus indicators (or removed outlines without replacement)
- Skip links missing or broken

### Screen Reader Support

- Images missing `alt` text (or decorative images missing `alt=""`)
- Form inputs missing associated `<label>` or `aria-label`/`aria-labelledby`
- Missing `aria-describedby` for error messages and help text
- Dynamic content changes not announced (`aria-live`, `role="alert"`, `role="status"`)
- Icon-only buttons/links missing accessible names
- Complex widgets missing ARIA roles/states (`aria-expanded`, `aria-selected`, `aria-checked`)

### Forms & Validation

- Required fields not indicated (missing `aria-required` or visual + text indicator)
- Error messages not associated with inputs
- Form errors not announced to screen readers
- Fieldsets/legends missing for related inputs (radio groups, address fields)
- Autocomplete attributes missing for common fields (name, email, address)

### Color & Visual

- Color as only means of conveying information (errors, status, required fields)
- Insufficient color contrast (< 4.5:1 for text, < 3:1 for large text/UI)
- Focus indicators with insufficient contrast
- Information lost when CSS is disabled

### Motion & Timing

- Animations without `prefers-reduced-motion` support
- Auto-advancing content without pause controls
- Time limits without extensions
- Flashing/strobing content

### Modals & Dynamic Content

- Modals not trapping focus properly
- Focus not returned to trigger element on close
- Modal content not hidden from screen readers when closed
- Dynamic content injections not announced
- Infinite scroll without alternatives

### Touch & Mobile (High Priority)

- Touch targets smaller than 44x44px (iOS) / 48x48dp (Android Material)
- Gestures without alternatives (swipe-only actions)
- Hover-only interactions on touch devices
- Text too small on mobile (< 16px base causes iOS zoom on focus)
- Inputs that trigger wrong keyboard type (missing `inputmode`, `type`)
- Horizontal scrolling or overflow issues on small screens
- Fixed/sticky elements blocking content or controls
- Pinch-to-zoom disabled (`user-scalable=no` or `maximum-scale=1`)

### Hybrid / Native Wrapper Considerations (if applicable)

Only applies if the project uses a hybrid framework (Hotwire Native, Capacitor, Cordova, React Native WebView, etc.).

- Bridge components not accessible to native screen readers (VoiceOver/TalkBack)
- Navigation transitions that disorient users (missing loading states)
- Native header/tab bar interactions conflicting with web focus
- Pull-to-refresh or native gestures conflicting with web interactions
- Web modals not respecting native accessibility settings
- Deep links landing on inaccessible states
- Form inputs not triggering appropriate native keyboards

## What To Do

1. Enumerate accessibility findings and rank them:
   - 🚨 Critical (blocks users entirely - no keyboard access, missing form labels)
   - ⚠️ High (significant barrier - poor focus management, missing ARIA)
   - 🟡 Medium (degraded experience - contrast issues, missing alt text)
   - 🟢 Low / Enhancement (best practice - landmark optimization, skip link improvements)
2. For each finding:
   - Explain the user impact (who is affected and how)
   - Identify the exact file(s) and code area
   - Propose a specific fix with code example
3. Call out "accessible by default" patterns so we preserve them

Do **not** focus on lint/style. Focus on real user impact.

## Claude Output Format

### Summary

- Overall accessibility posture: ✅ solid / ⚠️ needs work / 🚨 failing
- Top 3 issues (one line each)
- Affected user groups (screen reader, keyboard, low vision, motor, cognitive)

### Findings (ranked)

For each finding:

- Severity
- WCAG criterion (e.g., 1.1.1 Non-text Content, 2.1.1 Keyboard)
- Location (file path)
- User impact
- Recommended fix (with code snippet)

### Quick Wins

- Small changes that improve accessibility significantly

### Testing Recommendations

- Manual tests to verify (keyboard nav, screen reader, contrast checker)
