# Severity Criteria & Controlled Vocabulary

## Severity Levels

| Severity | Criteria | Examples |
|----------|----------|---------|
| **Critical** | App unusable — crash, data loss, security vulnerability, blank page | JS exception crashes page, form loses user data on submit, XSS vulnerability |
| **High** | Core feature broken — primary flow fails | Login fails, form submit returns error, main navigation broken |
| **Medium** | Secondary feature issue — degraded experience | Layout shift on resize, responsive break at tablet, poor UX on edge case |
| **Low** | Cosmetic — no functional impact | Typo, spacing off by pixels, minor color mismatch, console warning |

## Severity Self-Check

Before assigning severity, ask: "If I showed this to the product owner, would they agree with this level?"

- A cosmetic issue is **Low**, not Medium
- A minor UX annoyance is **Medium**, not High
- Only **Critical** if the app is literally unusable for that flow
- Severity inflation wastes engineering time on wrong priorities

## Controlled Vocabulary

Use these exact terms — no synonyms allowed. Consistency across all outputs (chat, GitHub, Jira, Sheets).

### Confidence Levels

| Use | Never use |
|-----|-----------|
| **Confirmed** | Verified, Validated, Proven, Definite |
| **Likely** | Probable, Possible, Maybe |
| **Needs Review** | Uncertain, Unknown, Unclear, TBD |

### Bug Status

| Use | Never use |
|-----|-----------|
| **PASSED** | Pass, OK, Good, Success, ✅ (unless sheet uses it) |
| **FAILED** | Fail, Bad, Error, ❌ (unless sheet uses it) |
| **BLOCKED** | Skipped, N/A, Cannot test |
| **NOT TESTED** | Pending, TODO, TBD |

### Finding Categories

| Use | Never use |
|-----|-----------|
| **functional** | feature, behavior, logic |
| **responsive** | layout, viewport, mobile |
| **accessibility** | a11y, WCAG |
| **security** | vulnerability, exploit |
| **edge-case** | corner case, boundary |
| **performance** | speed, slow |

### Jira Priority Mapping

| Severity | Jira Priority |
|----------|---------------|
| Critical | Highest |
| High | High |
| Medium | Medium |
| Low | Low |
