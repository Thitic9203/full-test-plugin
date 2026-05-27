# Out of Scope

This plugin does NOT do the following. Do not attempt these, and if a user asks, explain the boundary clearly.

## Not Performance Testing

- No load testing, stress testing, or benchmarking
- No Lighthouse/PageSpeed audits
- No Core Web Vitals measurement
- No response time assertions
- **Why:** Performance testing requires dedicated tools (k6, Lighthouse CI, WebPageTest) and controlled environments. This plugin tests functional correctness.

## Not Security Audit

- No penetration testing
- No OWASP Top 10 systematic scan
- No dependency vulnerability scanning (npm audit, Snyk)
- No secrets detection
- **Why:** Security audits require specialized tooling and expertise. This plugin may notice obvious security issues (exposed credentials, missing auth) during functional testing, but it is not a security scanner.
- **Exception:** If a security issue is found incidentally during functional testing, report it as a Critical bug.

## Not API Testing (Backend-Only)

- No testing of REST/GraphQL endpoints without a UI
- No contract testing
- No database integrity checks
- **Why:** This plugin tests web applications through the browser. API-only testing needs different tools (Postman, REST Client, contract testing frameworks).

## Not Visual Regression Testing

- No pixel-perfect comparison against design files (Figma, Sketch)
- No visual regression baseline management
- No screenshot diff tooling
- **Why:** Visual regression requires baseline images and diff tooling (Percy, Chromatic, BackstopJS). This plugin takes screenshots as evidence but does not compare against design baselines.

## Not Accessibility Audit (Full)

- No systematic WCAG 2.1 AA/AAA compliance audit
- No screen reader testing
- No keyboard-only navigation audit
- **Why:** Full accessibility audits require specialized tools (axe, Lighthouse a11y, manual screen reader testing). This plugin checks for obvious accessibility issues (missing alt text, tiny touch targets) but is not a comprehensive a11y scanner.
- **Exception:** Obvious accessibility violations found during testing are reported as bugs.

## Not Test Automation Framework

- No generating reusable test scripts for CI/CD
- No maintaining a test suite across runs
- No test result history/trending
- **Why:** This plugin runs one-time exploratory + scripted testing sessions. For persistent test automation, use Playwright Test, Cypress, or similar frameworks directly.

## Not Mobile App Testing

- No native iOS/Android app testing
- No React Native/Flutter native testing
- **Why:** This plugin uses browser-based Playwright. Mobile testing is simulated via viewport resizing, not actual device/emulator testing.
- **What it does:** Tests responsive web layouts at mobile viewport sizes.
