# Accessibility Review Criteria

**Issue Prefix**: `A11Y`
**Condition**: Only if frontend changes detected

## Platform Context

Identify which platforms the project targets (e.g., web only, web + mobile web, web + native iOS/Android via a hybrid framework like Hotwire Native or Capacitor). Prioritize the platforms the project actually ships to.

If the project includes native or hybrid mobile, **prioritize mobile accessibility** — its constraints (touch targets, screen-reader behavior, keyboard types) are stricter than desktop and frequently overlooked.

## Target Compliance

**WCAG 2.1 AA**

## Focus Areas

### 1. Semantic HTML & Structure

- Missing or incorrect landmark roles (`<main>`, `<nav>`, `<aside>`, `<header>`, `<footer>`)
- Heading hierarchy violations (skipped levels, multiple `<h1>`, non-semantic heading styles)
- Lists not using `<ul>/<ol>/<dl>` elements
- Tables missing `<caption>`, `<th>`, `scope`, or `headers` attributes
- Non-semantic divs/spans used for interactive elements

### 2. Keyboard Navigation

- Interactive elements not focusable (missing `tabindex`, non-button clickables)
- Focus traps (modals, dropdowns that don't return focus)
- Missing or illogical focus order
- No visible focus indicators (or removed outlines without replacement)
- Skip links missing or broken

### 3. Screen Reader Support

- Images missing `alt` text (or decorative images missing `alt=""`)
- Form inputs missing associated `<label>` or `aria-label`/`aria-labelledby`
- Missing `aria-describedby` for error messages and help text
- Dynamic content changes not announced (`aria-live`, `role="alert"`, `role="status"`)
- Icon-only buttons/links missing accessible names
- Complex widgets missing ARIA roles/states (`aria-expanded`, `aria-selected`, `aria-checked`)

### 4. Forms & Validation

- Required fields not indicated (missing `aria-required` or visual + text indicator)
- Error messages not associated with inputs
- Form errors not announced to screen readers
- Fieldsets/legends missing for related inputs (radio groups, address fields)
- Autocomplete attributes missing for common fields (name, email, address)

### 5. Color & Visual

- Color as only means of conveying information (errors, status, required fields)
- Insufficient color contrast (< 4.5:1 for text, < 3:1 for large text/UI)
- Focus indicators with insufficient contrast
- Information lost when CSS is disabled

### 6. Motion & Timing

- Animations without `prefers-reduced-motion` support
- Auto-advancing content without pause controls
- Time limits without extensions
- Flashing/strobing content

### 7. Modals & Dynamic Content

- Modals not trapping focus properly
- Focus not returned to trigger element on close
- Modal content not hidden from screen readers when closed
- Dynamic content injections not announced
- Infinite scroll without alternatives

### 8. Touch & Mobile (High Priority)

- Touch targets smaller than 44x44px (iOS) / 48x48dp (Android Material)
- Gestures without alternatives (swipe-only actions)
- Hover-only interactions on touch devices
- Text too small on mobile (< 16px base causes iOS zoom on focus)
- Inputs that trigger wrong keyboard type (missing `inputmode`, `type`)
- Horizontal scrolling or overflow issues on small screens
- Fixed/sticky elements blocking content or controls
- Pinch-to-zoom disabled (`user-scalable=no` or `maximum-scale=1`)

### 9. Hybrid / Native Wrapper Considerations (if applicable)

Only applies if the project uses a hybrid framework (Hotwire Native, Capacitor, Cordova, React Native WebView, etc.).

- Bridge components not accessible to native screen readers (VoiceOver/TalkBack)
- Navigation transitions that disorient users (missing loading states)
- Native header/tab bar interactions conflicting with web focus
- Pull-to-refresh or native gestures conflicting with web interactions
- Web modals not respecting native accessibility settings
- Deep links landing on inaccessible states
- Form inputs not triggering appropriate native keyboards

## Severity Classification

| Severity | Criteria |
|----------|----------|
| Critical | Blocks users entirely (no keyboard access, missing form labels, focus trap) |
| High | Significant barrier (poor focus management, missing ARIA, contrast failure) |
| Medium | Degraded experience (missing alt text, suboptimal semantics) |
| Low | Enhancement opportunity (landmark optimization, skip link improvements) |

## Output Format

For each issue found, capture:

```yaml
id: A11Y-001
title: Short description
severity: Critical|High|Medium|Low
file: path/to/file.erb
line: 45
wcag_criterion: "2.1.1 Keyboard"
category: Semantic|Keyboard|ScreenReader|Forms|Color|Motion|Modal|Touch|Hybrid
affected_users: Screen reader users, keyboard users, etc.
description: |
  Detailed explanation of the accessibility issue
recommended_fix: |
  Specific fix with code example
blocked_by: []
```
