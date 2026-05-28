---
name: web-test-orchestrator
description: Use when running comprehensive web testing across all roles, modules, features, platforms, and modes — orchestrates 4 testing skills sequentially then reports bugs as GitHub/Jira issues with evidence. Use when user invokes /full-test, asks for QA testing, or wants to find bugs in a web app.
argument-hint: "quick" for smoke test mode (skip Phase 2-3, top flows only)
---

# Web Test Orchestrator

Comprehensive web testing orchestrator that runs 4 testing skills in sequence, consolidates findings with falsification, and opens evidence-backed bug reports.

## When to Use

- User wants to test a web application thoroughly
- User invokes `/full-test`
- User asks for comprehensive QA / regression testing
- User wants to find bugs across all roles, modules, platforms

## Out of Scope

This plugin does NOT do: performance/load testing, security audit/pen-test, API-only testing (no UI), visual regression (pixel-diff against Figma), full WCAG accessibility audit, CI/CD test automation framework, native mobile app testing. If user asks for any of these, explain the boundary clearly. Exception: obvious security or a11y issues found incidentally during functional testing ARE reported.

---

## AskUserQuestion Rules (MANDATORY — read before any question)

**ALL AskUserQuestion fields MUST be in English only** — Thai characters render as garbled/unreadable text in the AskUserQuestion UI widget. This is a hard constraint that cannot be overridden.

| Field | Rule | Example |
|-------|------|---------|
| `question` | English only | `"Which test scope?"` |
| `header` | English only, max 12 chars | `"Scope"` |
| `label` | English only, short | `"Full test"` |
| `description` | English only | `"Test all routes, roles, and viewports"` |

---

## Core Constraints

These are constraints the agent carries through the entire session — not advice to deliver to the user. If you catch yourself violating any constraint, STOP and correct immediately.

**Recite this block verbatim at the start of Phase 0 (first response only):**

> **Full-Test Orchestrator Constraints:**
> 1. No evidence = no issue
> 2. No test data = create it, never skip
> 3. No user confirmation = no action
> 4. Disprove before confirm
> 5. Every claim traces to code

After recital, the user can say "skip the recital" for future sessions — but the agent still applies all constraints silently.

### Constraint Details

1. **No evidence, no issue.** NEVER open a bug report without evidence from real code or measurable errors. If you catch yourself drafting a bug without a file path, console error, or screenshot — STOP and return to testing.

2. **No skipping for data.** NEVER say "cannot test because there is no test data." CREATE the data yourself. See Test Data Rules section below.

3. **No action without confirmation.** NEVER run tests before user confirms the test matrix. NEVER open issues before user approves drafts. NEVER update tickets before user confirms actions.

4. **Disprove before confirm.** NEVER mark a finding as Confirmed without first attempting to disprove it. See Falsification Protocol section below.

5. **Code traceability.** ALWAYS include file path + line number in every bug report. ALWAYS include behavioral description alongside code reference (AFK-ready format).

6. **Run in order.** ALWAYS run skills in Phase order. Do not skip or reorder phases.

7. **Use controlled vocabulary.** ALWAYS use exact terms from Controlled Vocabulary section below. No synonyms.

---

## Test Data Rules

**Constraint: the agent MUST create test data itself. "No test data" is never a valid reason to skip.**

1. **Form / Input testing:** Create data by field type — Email: `test-<timestamp>@example.com`, Phone: `0800000001`, Name: `Test User`, Date: today/past/future, Number: 0/1/-1/boundary/max, Text: short/long(>255)/special chars/emoji/HTML, File: dummy PNG/PDF via Playwright.

2. **CRUD testing:** Create record via UI first (tests create flow too) → then test read/update/delete. If API exists → create via API. If seed script → run seed.

3. **Role-based testing:** No account for a role? Ask user if we can create one. If yes → signup flow or admin panel. If no → note "Role X not tested — need account from admin" but continue testing other roles. Never stop entirely.

4. **Empty state testing:** Empty pages ARE test targets. Test empty state first → create data → test populated state.

5. **Search / Filter testing:** Create diverse data first, then test search/filter.

**Priority order:** UI creation (best) → API → seed script → ask user (last resort).

**Absolute prohibitions:** Never skip test case for "no data." Never tell user "cannot test" without trying to create data first. Never assume data is unimportant.

---

## Graduated Rigor

Not every run needs full ceremony. The user can control depth:

| Mode | Trigger | Phases | Scope |
|------|---------|--------|-------|
| **Full** (default) | `/full-test` | All 7 phases | All routes, roles, viewports, modes |
| **Quick** | `/full-test quick` | Phase 0 (turbo) → 1 → 5 → 6 | Top 5 flows, desktop only, primary role, all defaults |
| **Targeted** | `/full-test module:auth` | All 7 phases | Specified module/route only |

In **Quick** mode: skip Phase 2 (cross-platform) and Phase 3 (strategy). Still apply all constraints.

If ambiguous, ask: "Full test (all routes, all roles, all viewports) or Quick smoke test (top 5 flows, desktop only)?"

---

## Project Config (`.full-test.json`)

Optional config file at project root — saves answers so repeat runs skip redundant questions.

```json
{
  "url": "http://localhost:3000",
  "startCommand": "pnpm dev",
  "viewports": ["Desktop 1920x1080", "Mobile 375x667"],
  "bugTarget": {
    "github": "owner/repo",
    "jira": "PROJ"
  },
  "testCaseSource": {
    "type": "jira",
    "projectKey": "PROJ"
  },
  "roles": ["admin", "user", "guest"]
}
```

**Rules:**
- **Never store credentials** (username/password) in config — session-only
- First run with no config → offer to create config after confirm
- Subsequent runs → load config → show summary → single confirm → ask credentials → start tests
- Auto-add `.full-test.json` to `.gitignore` (if `.gitignore` exists)

---

## Workflow

Follow these phases strictly in order:

---

### Phase 0: Discovery & Setup

**Goal:** Gather requirements, check all prerequisites, analyze source code, create test matrix, get user confirmation before starting tests.

**Hard Gate:** Phase 0 MUST produce all 4 outputs below. If ANY is missing, refuse to start Phase 1:
1. Confirmed test cases (from user-specified source)
2. Confirmed test matrix (routes, roles, modules, viewports, modes)
3. Target URL (verified accessible)
4. Test accounts (or explicit "skip role X" from user)

**UX Rules:**
- **Use `AskUserQuestion` tool** for all multiple-choice questions — user clicks, no typing needed
- **Smart Defaults** → detect from code/git as much as possible → show detected values together → user confirms/adjusts in one go
- **If `.full-test.json` exists** → load saved values → ask for single confirmation → if OK, skip to credentials
- **Credentials are never cached** — ask every session (session-only)
- **Pre-flight checks happen now** — do not wait until Phase 6 to discover missing tools

**Steps:**

0. **Ask what to test** (if `/full-test` was invoked with no arguments):

   Use `AskUserQuestion` tool:
   - Test specific ticket(s) (provide ticket key, e.g. PROJ-123)
   - Test a module / feature (e.g. auth, dashboard)
   - Test the entire project (all routes)
   - Retest previously opened bugs

   **Wait for user answer before doing anything.**

   - If user provides ticket → fetch details from Jira/GitHub → use as scope
   - If user provides module → Targeted mode
   - If user provides full project → Full mode
   - If user already included scope with `/full-test` (e.g. `/full-test PROJ-123`) → skip this step

1. **Find project root** (silent) — look for `package.json`, `next.config.*`, `vite.config.*`, or similar.

2. **Load `.full-test.json`** (if it exists at project root):

   **If config found → Fast Path:**
   Display saved config summary:
   ```
   ━━━ Loaded from .full-test.json ━━━
   URL:         http://localhost:3000
   Viewports:   Desktop, Mobile
   Bug Target:  GitHub (owner/repo) + Jira (PROJ)
   Test Cases:  Jira (PROJ)
   Roles:       admin, user, guest
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```
   "Use saved values as-is, or adjust any field?"
   - If confirmed → **skip to Step 5** (Pre-flight) → then Step 7 (Credentials)
   - If adjustment needed → use `AskUserQuestion` for the specific field(s) to change

   **If no config → go to Step 3**

3. **Discover** (silent — no user prompts):
   - **Routes/Pages:** React Router (`<Route`, `path=`), Next.js (`pages/`, `app/`), Vue Router, SvelteKit, generic
   - **Roles:** grep `RoleGuard`, `ProtectedRoute`, `authRequired`, `role ===`, `isAdmin`, `useAuth`, `permissions`
   - **Modules/Features:** scan `src/features/`, `src/modules/`, `src/pages/`, sidebar/nav components
   - **Modes:** grep `darkMode`, `theme`, `colorScheme`, `locale`, `i18n`
   - **URL hint:** read `package.json` scripts → detect dev/start command + port
   - **Bug Target hint:** read `git remote -v` → detect owner/repo

4. **Smart Defaults — show all values at once:**

   Combine discovery + detected hints → display summary:
   ```
   ━━━ Detected values (editable) ━━━
   Test Cases:  generated from code (25 cases)
   URL:         http://localhost:3000 (from package.json "dev" script)
   Roles:       admin, user, guest (from RoleGuard)
   Viewports:   Desktop 1920x1080, Mobile 375x667 (default)
   Bug Target:  GitHub owner/repo (from git remote)
   Mode:        Full
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```
   "Are these values correct? Which (if any) need to change?"

   → If all confirmed → go to Step 5
   → If adjustment needed → use `AskUserQuestion` for specific fields:
     - Test Cases Source → AskUserQuestion (Jira / Confluence / CSV / GitHub Issues / generate / custom)
     - URL → ask user to type it
     - Viewports → AskUserQuestion multiSelect (Desktop / Tablet / Mobile)
     - Bug Target → AskUserQuestion multiSelect (GitHub / Jira)
   → If a value could not be detected → ask only for that field

   **If Test Case Source is not "generate" → Fetch & normalize test cases → display table → confirm:**
   ```
   | # | Module     | Test Case                        | Role  | Priority |
   |---|------------|----------------------------------|-------|----------|
   | 1 | auth       | Login with valid credentials     | user  | High     |
   ```
   "X test cases total — does this look correct and complete?"

5. **Pre-flight Checks** (verify and set up now — do not wait until Phase 6):

   **a. URL / Dev server:**
   - If localhost/127.0.0.1 → try `curl -s -o /dev/null -w '%{http_code}' <URL>`
   - If not running → read `package.json` for start command
   - Ask: "Dev server is not running — should I start it with `<detected-command>`?"
   - If user confirms → run in background + wait for server ready
   - If user will start it manually → wait until server responds
   - If remote URL → try fetch to check accessibility → if not reachable → notify + ask for correct URL
   - Note (remote): source code may differ from deployed version

   **b. GitHub CLI** (if bug target includes GitHub):
   - `which gh` → not found → ask: "Should I install `gh` with `brew install gh`?" → confirm → install
   - `gh auth status` → not logged in → ask: "Should I run `gh auth login` for you?" → confirm → run
   - `gh repo view <owner/repo>` → not found → ask: "Is the repo name correct?"
   - Auto-create missing labels (bug, severity:*, module:*)
   - If user does not want setup → skip GitHub Issues + notify

   **c. Jira MCP** (if bug target includes Jira):
   - Try `getVisibleJiraProjects` → if success → MCP is available ✅
   - If fail → notify: "Atlassian MCP is not connected — will use JXA fallback"
   - Check Chrome + Jira login → if Chrome is not open on Jira → ask: "Should I open Jira for you?" → confirm → open
   - If MCP available → verify project key + issue types
   - If project key not found → ask: "Is the project key correct?"

   **Display Pre-flight summary:**
   ```
   ━━━ Pre-flight ━━━
   URL:    http://localhost:3000 ✅ running
   GitHub: owner/repo ✅ gh authenticated
   Jira:   PROJ ✅ MCP connected
   ━━━━━━━━━━━━━━━━━
   ```

6. **Confirm Test Matrix before asking for credentials:**
   Display test matrix (if not already shown in Step 4):
   ```
   | Category   | Found                         | Count |
   |------------|-------------------------------|-------|
   | Routes     | /, /login, /dashboard, ...    | 12    |
   | Roles      | admin, user, guest            | 3     |
   | Modules    | auth, dashboard, settings     | 5     |
   | Viewports  | Desktop, Mobile               | 2     |
   | Modes      | light / dark                  | 2     |
   | Test Cases | (from source)                 | 25    |
   ```

7. **Ask for Credentials** (every session — never cached):
   ```
   | Role   | Username/Email | Password | Notes         |
   |--------|----------------|----------|---------------|
   | admin  | ?              | ?        |               |
   | user   | ?              | ?        |               |
   | guest  | (no login)     | —        |               |
   ```
   "Please provide credentials for each role that requires login."
   **Do NOT store credentials in any file or log — session-only use.**

   **Wait for user answer before doing anything.**

8. **Final Confirm:**
   ```
   ━━━ Summary before testing ━━━
   Test Cases:  25 (from Jira PROJ)
   URL:         http://localhost:3000 ✅
   Roles:       admin (a@test.com), user (u@test.com)
   Viewports:   Desktop, Mobile
   Bug Target:  Jira (PROJ) ✅ + GitHub (owner/repo) ✅
   Mode:        Full (all phases)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```
   "Everything looks good — ready to start testing?"

   **Wait for user confirmation before starting Phase 1.**

9. **Offer to save `.full-test.json`** (if none exists):
   "Save these values as `.full-test.json` so you don't have to answer again next run?"
   - If confirmed → create file at project root (credentials excluded) + add to `.gitignore`
   - If declined → proceed to Phase 1

10. **If discovery finds nothing** for any category → ask user directly.

**Hard Gate Check:** Do you have all 4 required outputs? If not, ask for the missing ones. Do NOT proceed to Phase 1.

**Quick Mode Shortcut:** If `/full-test quick`:
- Config exists → load config + ask credentials only + confirm → start tests (**2 messages**)
- No config → use all Smart Defaults + ask credentials + confirm → start tests (**3 messages**)

> **Phase 0 Self-Check:** "If I removed this discovery step and ran tests immediately — what would I miss?" If the answer is "nothing" then discovery was too shallow. Go deeper.

---

### Phase 1: Recon (webapp-testing)

**Goal:** Initial reconnaissance — visit every route, capture screenshots, find obvious errors.

**Invoke:** `webapp-testing` skill (Anthropic official)

**Instructions to pass:**
- Visit each route from confirmed test matrix
- For each route:
  - Wait for `networkidle`
  - Take a screenshot
  - Check browser console for errors/warnings
  - Check for broken images, missing assets
  - Check for JS exceptions
  - Note HTTP error responses (4xx, 5xx)
- Test with each role if authentication is involved
- Record all findings with route, role, and error details

**Collect findings:**
```
Finding: [description]
Route: [path]
Role: [role or N/A]
Type: [console-error | broken-asset | js-exception | http-error | visual]
Evidence: [error message or screenshot path]
```

> **Phase 1 Self-Check:** "Has every route × role combination been visited?" Count: expected = routes × roles. If actual < expected, go back.

---

### Phase 2: Cross-Platform (playwright-skill)

*Skip this phase in Quick mode.*

**Goal:** Test responsive layout across all confirmed viewports.

**Invoke:** `playwright-skill:playwright-skill` skill (lackeyjb)

**Instructions to pass:**
- Test each route at every confirmed viewport
- For each route × viewport:
  - Check horizontal overflow / scrollbar
  - Check overlapping elements
  - Check text truncation hiding content
  - Check touch targets too small on mobile (< 44x44px)
  - Check elements that disappear or break layout
  - Take screenshots at each viewport
- If roles exist: test key pages per role at each viewport
- If modes exist (dark/light): test at each mode

**Collect findings** — same format as Phase 1, adding:
```
Viewport: [Desktop 1920x1080 | Tablet 768x1024 | Mobile 375x667]
Mode: [light | dark | N/A]
```

> **Phase 2 Self-Check:** "Has every route × viewport × mode combination been tested?" Count and verify.

---

### Phase 3: Strategy & Analysis (test-master)

*Skip this phase in Quick mode.*

**Goal:** Analyze findings from Phase 1-2, identify coverage gaps, assign severity.

**Invoke:** `fullstack-dev-skills:test-master` skill (Jeffallan)

**Instructions to pass:**
- Review all findings from Phase 1 and Phase 2
- Identify gaps:
  - Edge cases (empty states, long text, special characters)
  - Error handling (network failures, invalid input)
  - Form validation (required fields, format validation)
  - Navigation flows (back button, deep linking)
  - State persistence (refresh, tab switching)
- Assign severity using Severity Criteria below
- Run additional targeted tests for identified gaps
- Produce a rated findings report

**Collect findings** — merge with Phase 1-2, add:
```
Severity: [Critical | High | Medium | Low]
Category: [functional | responsive | accessibility | security | edge-case]
```

> **Phase 3 Self-Check:** "If a developer asked 'did you test edge case X?' — how many would I still have to say no to?" If more than a handful, go test them.

---

### Phase 4: Deep E2E (playwright-expert)

**Goal:** Test critical user flows end-to-end with robust patterns.

**Invoke:** `fullstack-dev-skills:playwright-expert` skill (Jeffallan)

**Instructions to pass:**
- Identify top user flows from test matrix
- For each flow:
  - Use role-based selectors (`getByRole`, `getByLabel`) — not CSS classes
  - Test happy path completely
  - Test error paths (wrong password, invalid input, network error)
  - Check race conditions (double-click, rapid navigation)
  - Check flaky behavior
- Test cross-role flows if applicable
- Use Page Object Model thinking

**Collect findings** in the same structured format.

> **Phase 4 Self-Check:** "Happy path + error path + edge case — have all 3 angles been covered for every flow?" If only happy path was tested, go back.

---

### Phase 5: Consolidate

**Goal:** Merge findings, falsify, deduplicate, assess coverage honestly, get user approval.

**Steps:**

1. **Merge** all findings from Phase 1-4 into a single list.

2. **Falsify each finding** (see Falsification Protocol below) — before confirming any bug, attempt to disprove it:
   - "Could this be intentional design?"
   - "Does this behavior match other parts of the app?"
   - Run at least ONE disproof test per finding
   - Disproof failed → Confirmed
   - Disproof succeeded → Drop
   - Inconclusive → Needs Review

3. **Deduplicate** — if multiple findings share a root cause:
   - Keep one entry
   - Note which phases found it
   - Use the highest severity

4. **Assign confidence** (using controlled vocabulary):
   - **Confirmed:** Has console error, network error, JS exception, or clearly broken UI + disproof attempt failed
   - **Likely:** Has visual evidence + code reference + disproof inconclusive
   - **Needs Review:** Subjective assessment, might be intentional, disproof partially succeeded

5. **Look up source code** for every finding:
   - Find file and line number
   - Quote relevant code
   - Write behavioral description (AFK-ready — see bug format in Phase 6A)
   - If no code evidence → Needs Review

6. **Honest Coverage Statement** — report what was and was NOT tested:
   ```
   ━━━ Coverage Report ━━━
   Tested:
   - Routes: 10/12 (missed: /admin/audit, /api/webhook — no access)
   - Roles: admin, user (missed: super-admin — no account)
   - Viewports: Desktop, Mobile (missed: Tablet — Quick mode)
   - Modes: light only (dark mode not tested — app has no dark mode)
   
   Limitations:
   - Source code may differ from deployed version (remote URL)
   - Role X not tested — need account from admin
   ━━━━━━━━━━━━━━━━━━━━━━━
   ```

7. **Display two tables** in chat:

   **Confirmed Bugs:**
   ```
   | # | Severity | Module   | Bug                          | Confidence | Found by     |
   |---|----------|----------|------------------------------|------------|--------------|
   | 1 | Critical | auth     | Login form crash on empty    | Confirmed  | Phase 1, 4   |
   ```

   **Needs Review:**
   ```
   | # | Severity | Module   | Bug                          | Confidence | Found by     |
   |---|----------|----------|------------------------------|------------|--------------|
   | 1 | Low      | settings | Color might be wrong         | Needs Review | Phase 2    |
   ```

8. **Ask user:**
   - "Open bug reports for all Confirmed bugs?"
   - "Which Needs Review items should also be opened?"
   - "Where to open bugs? — **GitHub Issues**, **Jira**, or **both**?"
   - If Jira → ask board URL/project key, issue type, custom fields
   - If GitHub → ask repo (owner/repo)

   **Wait for user answer before doing anything.**

> **Phase 5 Self-Check:** "Has every Confirmed bug passed falsification? Is the coverage report honest?"

---

### Phase 6: Open Bug Reports

**Goal:** Open one bug report per confirmed finding — GitHub Issues, Jira, or both.

**Important: Draft ALL bugs in chat for user confirmation before opening.**

#### Phase 6A: Draft Bugs in Chat

For each bug, show draft in AFK-ready format (behavioral description as primary, code ref as supplementary):

```
━━━ Bug #1 ━━━
Title: [Severity] Module — Behavioral description
Severity: Critical | High | Medium | Low
Module: auth
Confidence: Confirmed | Likely

What happens: [Observable behavior from user perspective]
What should happen: [Expected behavior]
User impact: [Who is affected and how]

Steps to Reproduce:
1. Go to [route]
2. [User action]
3. Observe [problem]

Code Reference:
- File: src/components/Foo.tsx:42
- Code: [relevant snippet]
- Root cause: [why the code produces this behavior]

Environment: Desktop 1920x1080, Chromium
Screenshot: [path if available]
━━━━━━━━━━━━━━
```

After all drafts: "X bug drafts ready — any changes needed, or should I open them all?"

**Show drafts to user for approval before opening. Wait for answer.**

**Iteration limit:** If user requests revisions 3 times on the same bug → ask: "Which part is still off? Please be specific so I can fix the right thing."

**Rule: Never open a real bug report without user approval — always show draft first.**

---

#### Phase 6B: GitHub Issues

**Pre-flight:** Normally completed in Phase 0 Step 5b — if not yet done (edge case):
- Check `gh` CLI installed + authenticated → if not ready → ask + set up (see Phase 0 Step 5b)
- Check repo accessible → if not found → ask for correct name
- Auto-create missing labels (bug, severity:*, module:*)

1. For each approved bug:

```bash
gh issue create --repo <owner/repo> \
  --title "[Severity] Module — Behavioral description" \
  --label "bug,severity:<level>,module:<name>" \
  --body "$(cat <<'ISSUE_EOF'
## What Happens

[Observable behavior from user perspective]

## What Should Happen

[Expected behavior]

## User Impact

[Who is affected and how]

## Steps to Reproduce

1. Go to [route]
2. [Action]
3. Observe [problem]

## Code Reference

**File:** `[file path:line number]`
**Code:**
```
[relevant code snippet]
```

**Root cause:** [why the code produces this behavior]

**Confidence:** Confirmed

## Environment

- Viewport: [viewport]
- Browser: Chromium (Playwright)
- URL: [route URL]

## Screenshot

[Attach if available]

## Found By

Phase [X] — [skill name]
Tested on: [date]
ISSUE_EOF
)"
```

---

#### Phase 6C: Jira Issues

1. **Lock format at start — cannot switch mid-session:**

   | Bug Type | API Endpoint | Markup |
   |----------|-------------|--------|
   | API / Logic bug | v3 (`addCommentToJiraIssue` with `contentFormat: markdown`) | ADF |
   | FE / UI bug | v2 (`/rest/api/2/issue/<KEY>/comment`) | Wiki Markup |

2. **Pre-flight:** Normally completed in Phase 0 Step 5c — if not yet done (edge case):
   - Check Jira MCP connectivity → if fail → use JXA fallback + open Chrome/Jira (see Phase 0 Step 5c)
   - verify project: `getJiraProjectIssueTypesMetadata`, `getJiraIssueTypeMetaWithFields`
   - If project key not found → ask: "Is the project key correct?"

3. **Create each issue** with `createJiraIssue`:
   - **Summary:** `[Severity] Module — Behavioral description`
   - **Priority:** Map severity → Jira (Critical→Highest, High→High, Medium→Medium, Low→Low)
   - **Labels:** `bug`, `module:<name>`, `auto-tested`

   **v2 Wiki Markup:**
   ```
   h2. What Happens
   [behavioral description]

   h2. What Should Happen
   [expected behavior]

   h2. User Impact
   [who is affected]

   h2. Steps to Reproduce
   # Go to [route]
   # [Action]
   # Observe [problem]

   h2. Code Reference
   *File:* {{file path:line number}}
   *Code:*
   {code}
   [snippet]
   {code}
   *Root cause:* [reasoning]
   *Confidence:* Confirmed

   h2. Environment
   * Viewport: [viewport]
   * Browser: Chromium (Playwright)
   * URL: [route URL]

   h2. Found By
   Phase [X] — [skill name]
   Tested on: [date]
   ```

4. **Jira Posting Pipeline** (same order as retest-bug-plugin):

   **Step A — Try Atlassian MCP first:**
   Use `createJiraIssue` MCP tool → if success → done

   **Step B — Fallback: Node.js + JXA + Chrome** (if MCP returns 403 or fails):
   1. Build issue body with real text
   2. `JSON.stringify` body **before** escaping non-ASCII
   3. Escape non-ASCII **after** stringify:
      ```javascript
      const safe = bodyStr.replace(/[^\x00-\x7F]/g, c =>
        '\\u' + c.charCodeAt(0).toString(16).padStart(4, '0')
      );
      ```
   4. Save file as ASCII: `fs.writeFileSync(path, js, 'ascii')`
   5. Verify: `if (/[^\x00-\x7F]/.test(js)) throw 'STILL HAS NON-ASCII'`
   6. Execute via JXA: `osascript -l JavaScript <file>`

   **Order matters:** Escape before stringify = broken. Non-ASCII directly in JS file = encoding corruption.

5. **Pre-post validation checklist** (all must pass before posting):
   - [ ] Emoji `❌` `✅` are real Unicode — not `\\u274c` (double backslash = literal text)
   - [ ] No bare ticket keys — wrap in `{{PROJ-123}}`
   - [ ] No Thai particles — use neutral language
   - [ ] Endpoint matches format (v2 = wiki, v3 = ADF)
   - [ ] Screenshots uploaded as attachments before embedding `!filename.png|width=600!`
   - [ ] JS file is ASCII-only (if using JXA fallback)

6. **Dry-run before posting** (if using JXA fallback):
   - Read JS file back
   - Decode `\uXXXX` sequences
   - Verify: emoji is correct, text is readable, no ticket keys that will auto-link
   - **If dry-run fails → fix template and re-generate before posting — never post then fix later**

---

#### Phase 6D: Summary

```
| # | Target | Issue URL/Key              | Severity | Module   |
|---|--------|----------------------------|----------|----------|
| 1 | Jira   | PROJ-123                   | Critical | auth     |
| 2 | GitHub | github.com/o/r/issues/1    | Medium   | settings |
```

"Created X bugs (Y Critical, Z High, W Medium, V Low) — Jira: A issues, GitHub: B issues"

---

### Phase 7: Post-Test Actions

**Goal:** Update test results, optionally update Jira tickets, and hand off if needed.

**Important: Draft everything in chat for user confirmation before executing.**

#### Phase 7A: Ask Where to Record Results

"Where should test results be recorded?"
- **Jira** — comment on tickets
- **Google Sheets** — specify URL
- **File (CSV/Markdown)** — specify path
- **Confluence** — specify page URL
- **Skip** — no recording needed

If Sheets/File: ask column mapping + result format (PASSED/FAILED, etc.)

#### Phase 7B: Draft Result Updates

**Rule: Draft everything in chat for user to review — never post without user approval.**

Show draft in chat:

**Jira comment (use this format only):**
```
━━━ Ticket PROJ-101 ━━━
Comment:
  Test Result: PASSED ✅
  Tested on: [date]
  Viewport: Desktop, Mobile
  Notes: All scenarios passed
━━━━━━━━━━━━━━━━━━━━━━━
```

**Sheets/File:**
```
| Test Case          | Status | Tester | Date       | Notes           |
|--------------------|--------|--------|------------|-----------------|
| Login valid creds  | PASSED | Claude | [date]     | No issues found |
| Dashboard overflow | FAILED | Claude | [date]     | Bug PROJ-123    |
```

**Google Sheets rules:** Read sheet first → match existing format exactly (PASSED/FAILED not Pass/Fail, date format, language) → never overwrite without confirmation → confirm column mapping → batch all updates.

"Does the draft look correct? Any changes before updating for real?"

**Show draft to user for approval. Wait for answer.**

**Iteration limit:** 3 revision rounds → ask "Which part is still wrong?" Don't keep tweaking blindly.

**Jira Comment Posting Pipeline** (same approach as Phase 6C):

1. **Try Atlassian MCP first:** `addCommentToJiraIssue` with `contentFormat: markdown`
2. **Fallback: Node.js + JXA** if MCP fails (same encoding pipeline as Phase 6C)
3. **Pre-post validation checklist** must all pass before posting
4. **Dry-run** before posting for real (if using JXA)
5. **If dry-run fails → fix and re-generate first — never post then fix later**

**Content rules for Jira comments:**
- No Thai particles — use neutral language
- Use "Test Result: PASSED ✅" or "Test Result: FAILED ❌" only — no other formats
- Date format: YYYY-MM-DD
- Full evidence for every test case — no abbreviation, no "same as above"

#### Phase 7C: Jira Ticket Actions

If test cases came from Jira tickets:

1. "Do you want to update ticket status?"
   - Use `getTransitionsForJiraIssue` → show available transitions
   - "For PASSED tickets → which status to transition to?"
   - "For FAILED tickets → which status to transition to?"

2. "Do you want to change assignee?"
3. "Do you want to add labels?"
4. "Anything else to do with these tickets?"

#### Phase 7D: Confirm & Execute

**Show full action summary before executing:**

```
━━━ Actions Summary ━━━
1. Update results: Jira comment on 5 tickets
2. Transition: PROJ-101~103 (PASSED) → Done
3. Transition: PROJ-104~105 (FAILED) → Reopen
4. Labels: qa-passed / qa-failed
Total: 18 actions
━━━━━━━━━━━━━━━━━━━━━━━
```

"Everything looks correct — ready to execute all 18 actions?"

**Wait for user confirmation before executing anything.**

Once confirmed → **execute all actions immediately without asking again** (transition + assign + label + comment):

Execute in order, show progress:
```
[1/18] ✅ Comment PROJ-101
[2/18] ✅ Comment PROJ-102
...
[18/18] ✅ Done — 18/18 actions completed.
```

**Rule:** After user confirms in Phase 7D, execute transition + assign + label + comment immediately — no additional prompts.

#### Phase 7E: Handoff (Optional)

After all actions complete, offer handoff if relevant:

- "Want a test summary report for management?" → Invoke `management-talk` skill if available
- "Want to retest the bugs that were opened?" → Invoke `retest-bug` skill if available
- "Want to open a post-mortem for Critical bugs?" → Invoke `post-mortem` skill if available

If no handoff needed → session complete.

> **Phase 7 Self-Check:** "Has every confirmed action been executed? Did any action fail without a retry?"

---

## Anti-Hallucination Rules

These rules are non-negotiable:

1. **No evidence = no issue.** Cannot point to a specific file, line, or measurable error? Do NOT report it.
2. **Code reference required.** Every bug must include source file and line.
3. **Reason required.** Every bug must explain WHY — contradicts spec, differs from other parts of app, console/network error, WCAG violation, CSS/logic conflict, or runtime exception.
4. **Low confidence = quarantine.** Not sure? → Needs Review table. Never auto-open.
5. **No duplicates.** Check root cause overlap before opening. Deduplicate aggressively.
6. **Severity must be justified.** Don't inflate. Cosmetic = Low, not Medium.

## Falsification Protocol

Before confirming any finding as a bug, attempt to disprove it:

**Step 1 — Challenge:** "Could this be intentional?" / "Does this match other parts of the app?" / "Am I comparing against the right expectation?"

**Step 2 — Disproof test** (at least ONE per finding):

| Finding Type | Disproof Method |
|-------------|----------------|
| Visual bug | Check other pages — same pattern used intentionally elsewhere? |
| Console error | Caught/handled upstream? Affects user experience? |
| Layout break | Deliberate responsive behavior? |
| Missing element | Conditional by design for this role/state? |
| Form issue | Validation rules in code match this behavior? |

**Step 3 — Classify:** Disproof failed → Confirmed. Disproof succeeded → Drop. Inconclusive → Needs Review.

**Self-check:** "If the developer who wrote this saw my report, would they agree it's a bug or say it's working as intended?" If likely "working as intended" → Needs Review.

---

## Severity Criteria

| Severity | Criteria |
|----------|----------|
| **Critical** | App unusable — crash, data loss, security vulnerability, blank page |
| **High** | Core feature broken — form submit fails, login broken, nav broken |
| **Medium** | Secondary feature issue — layout shift, responsive break, poor UX |
| **Low** | Cosmetic — typo, spacing, minor color, console warning |

**Self-check:** Before assigning, ask: "If I showed this to the product owner, would they agree with this level?"

## Controlled Vocabulary

Use these exact terms. No synonyms. Consistency across all outputs.

**Confidence:** Confirmed / Likely / Needs Review (never: Verified, Validated, Probable, Uncertain, TBD)

**Status:** PASSED / FAILED / BLOCKED / NOT TESTED (never: Pass, Fail, OK, Skip, N/A, Pending)

**Categories:** functional / responsive / accessibility / security / edge-case / performance (never: feature, layout, a11y, vulnerability, corner case)

---

## Jira Wiki Markup Quick Reference

| Element | Syntax |
|---------|--------|
| Bold | `*text*` |
| Monospace | `{{text}}` |
| Line separator | `----` |
| Table header | `\|\|Header\|\|` |
| Table cell | `\|cell\|` |
| Inline image | `!filename.png\|width=600!` |
| Link | `[label\|url]` |
| Emoji | Real characters: `✅` `❌` |

## Common Formatting Mistakes

| Mistake | Fix |
|---------|-----|
| `\\u274c` double backslash | Use real `❌` character |
| Bare `PROJ-123` in text | Wrap: `{{PROJ-123}}` |
| v2 wiki on v3 endpoint | Match endpoint to markup |
| Non-ASCII text directly in JS file | Escape to `\uXXXX` after stringify |
| Assumed column positions | Read sheet headers first |
| Mixed date formats | Match existing format |
