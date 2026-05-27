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

1. **Form / Input testing:** Create data by field type — Email: `test-<timestamp>@example.com`, Phone: `0800000001`, Name: `Test User` / `ทดสอบ ระบบ`, Date: today/past/future, Number: 0/1/-1/boundary/max, Text: short/long(>255)/special chars/emoji/HTML, File: dummy PNG/PDF via Playwright.

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
| **Quick** | `/full-test quick` | Phase 0 → 1 → 5 → 6 | Top 5 flows, desktop only, primary role |
| **Targeted** | `/full-test module:auth` | All 7 phases | Specified module/route only |

In **Quick** mode: skip Phase 2 (cross-platform) and Phase 3 (strategy). Still apply all constraints.

If ambiguous, ask: "Full test (ทุก route, ทุก role, ทุก viewport) หรือ Quick smoke test (top 5 flows, desktop only)?"

---

## Workflow

Follow these phases strictly in order:

---

### Phase 0: Discovery

**Goal:** Analyze source code to build a test matrix, then get user confirmation.

**Hard Gate:** Phase 0 MUST produce all 4 outputs below. If ANY is missing, refuse to start Phase 1:
1. Confirmed test cases (from user-specified source)
2. Confirmed test matrix (routes, roles, modules, viewports, modes)
3. Target URL (verified accessible)
4. Test accounts (or explicit "skip role X" from user)

**Steps:**

1. **Find the project root** — look for `package.json`, `next.config.*`, `vite.config.*`, or similar.

2. **Discover Routes/Pages:**
   - React Router: grep for `<Route`, `path=`, `createBrowserRouter`
   - Next.js: scan `pages/` or `app/` directory structure
   - Vue Router: grep for `routes:`, `path:`
   - SvelteKit: scan `src/routes/`
   - Generic: grep for URL path patterns in source

3. **Discover Roles:**
   - grep for: `RoleGuard`, `ProtectedRoute`, `authRequired`, `role ===`, `isAdmin`, `userRole`, `useAuth`, `permissions`, `canAccess`
   - Check middleware/guard files
   - Map which roles access which routes

4. **Discover Modules/Features:**
   - Scan: `src/features/`, `src/modules/`, `src/pages/`, `src/views/`
   - Read navigation/sidebar components for menu items
   - List distinct functional areas

5. **Discover Modes:**
   - grep for: `darkMode`, `theme`, `colorScheme`, `locale`, `i18n`, `dir=`, `rtl`
   - Check for theme provider/context

6. **Ask for Test Case Source:**

   "เทสเคสที่ต้องการใช้มาจากไหน?"
   - **Jira** — project key or filter/JQL
   - **Confluence** — page URL with test cases
   - **Spreadsheet/CSV** — file path
   - **GitHub Issues** — repo + label
   - **Generate from code** — auto-create from discovered matrix
   - **Manual** — user types in chat

7. **Fetch & Review Test Cases:**

   Fetch from source, normalize to standard format:
   ```
   | # | Module     | Test Case                        | Role  | Priority |
   |---|------------|----------------------------------|-------|----------|
   | 1 | auth       | Login with valid credentials     | user  | High     |
   ```

8. **Confirm Test Cases:**
   "เทสเคสทั้งหมด X ข้อ ตามตารางด้านบน — ถูกต้องครบไหม? ต้องเพิ่ม/ลด/แก้ข้อไหน?"
   **Wait for confirmation. Do NOT proceed without it.**

9. **Present Test Matrix:**
   ```
   | Category   | Found                         | Count |
   |------------|-------------------------------|-------|
   | Routes     | /, /login, /dashboard, ...    | 12    |
   | Roles      | admin, user, guest            | 3     |
   | Modules    | auth, dashboard, settings     | 5     |
   | Viewports  | Desktop / Tablet / Mobile     | 3     |
   | Modes      | light / dark                  | 2     |
   | Test Cases | (from source above)           | 25    |
   ```

10. **Ask target URL:**
    "URL ของเว็บที่จะเทสคืออะไร?"
    - localhost → "Dev server รันอยู่แล้วหรือยัง?"
    - remote URL → note: source code may differ from deployed version

11. **Ask test accounts:**
    ```
    | Role   | Username/Email | Password | Notes      |
    |--------|----------------|----------|------------|
    | admin  | ?              | ?        |            |
    | user   | ?              | ?        |            |
    | guest  | (no login)     | —        |            |
    ```
    "กรุณาระบุ credentials สำหรับแต่ละ role ที่ต้อง login"
    **Do NOT store credentials in any file or log — session-only use.**

12. **Confirm everything:**
    - "Test matrix + test cases + URL + accounts ถูกต้องครบไหม?"
    - "Viewports ไหนบ้าง? (default: Desktop 1920x1080, Tablet 768x1024, Mobile 375x667)"
    - "เปิด issues ที่ไหน? GitHub repo (owner/repo) หรือ Jira?"

13. **If discovery finds nothing** for any category → ask user directly.

**Hard Gate Check:** Do you have all 4 required outputs? If not, ask for the missing ones. Do NOT proceed to Phase 1.

> **Phase 0 Self-Check:** "ถ้าลบ discovery นี้ออก แล้วรันเทสเลย — จะพลาดอะไร?" If the answer is "nothing" then discovery was too shallow. Go deeper.

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

> **Phase 1 Self-Check:** "ทุก route x role combination ถูก visit แล้วจริงไหม?" Count: expected = routes × roles. If actual < expected, go back.

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

> **Phase 2 Self-Check:** "ทุก route x viewport x mode combination ถูกทดสอบแล้วจริงไหม?" Count and verify.

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

> **Phase 3 Self-Check:** "ถ้า developer ถามว่า 'ทดสอบ edge case X หรือยัง?' — จะตอบ 'ยัง' กี่ข้อ?" If more than a handful, go test them.

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

> **Phase 4 Self-Check:** "Happy path + error path + edge case — ครบทั้ง 3 มุมหรือยังสำหรับทุก flow?" If only happy path tested, go back.

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
   - "Confirmed bugs ทั้งหมดจะเปิดบัคให้เลยไหม?"
   - "Needs Review รายการไหนที่ต้องการเปิดด้วย?"
   - "เปิดบัคที่ไหน? — **GitHub Issues** หรือ **Jira** หรือ **ทั้งคู่**?"
   - If Jira → ask board URL/project key, issue type, custom fields
   - If GitHub → ask repo (owner/repo)
   - **Wait for confirmation.**

> **Phase 5 Self-Check:** "ทุก Confirmed bug ผ่าน falsification แล้วจริงไหม? Coverage report ซื่อสัตย์ไหม?"

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

After all drafts: "ร่างบัคทั้งหมด X ตัว — ต้องแก้ไขตัวไหนไหม? หรือ confirm เปิดได้เลย?"

**Iteration limit:** If user requests revisions 3 times on the same bug → ask: "ข้อไหนที่ยังไม่ตรง? ช่วยระบุให้ชัดเพื่อจะได้แก้ถูกจุด"

**Do NOT open issues before user confirms.**

---

#### Phase 6B: GitHub Issues

1. Verify `gh` CLI authenticated: `gh auth status`
2. Verify repo exists: `gh repo view <owner/repo>`
3. For each approved bug:

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

2. **Verify project:** `getVisibleJiraProjects`, `getJiraProjectIssueTypesMetadata`, `getJiraIssueTypeMetaWithFields`

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

4. **Pre-post validation:**
   - Emoji `❌` `✅` are real Unicode — NOT `\\u274c`
   - No bare ticket keys — wrap in `{{PROJ-123}}`
   - No Thai particles (ครับ/ค่ะ) — neutral language
   - Endpoint matches format (v2 = wiki, v3 = ADF)
   - Screenshots uploaded as attachments BEFORE `!filename.png|width=600!`

5. **Thai text encoding** (if posting via JXA/JavaScript):
   - Generate body with real Thai → `JSON.stringify` BEFORE escaping non-ASCII → escape AFTER stringify → save as ASCII → dry-run decode to verify

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

"ต้องการให้อัปเดตผลการทดสอบไว้ที่ไหน?"
- **Jira** — comment on tickets
- **Google Sheets** — specify URL
- **File (CSV/Markdown)** — specify path
- **Confluence** — specify page URL
- **Skip** — no recording needed

If Sheets/File: ask column mapping + result format (PASSED/FAILED, etc.)

#### Phase 7B: Draft Result Updates

Show draft in chat:

**Jira comment:**
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

"Draft ถูกต้องไหม? ต้องแก้อะไรก่อนอัปเดตจริง?"

**Iteration limit:** 3 revision rounds → ask "ข้อไหนที่ยังไม่ตรง?" Don't keep tweaking blindly.

**Do NOT update before user confirms.**

#### Phase 7C: Jira Ticket Actions

If test cases came from Jira tickets:

1. "ต้องการปรับสถานะ ticket ด้วยไหม?"
   - Use `getTransitionsForJiraIssue` → show available transitions
   - "Ticket PASSED → transition ไปสถานะอะไร?"
   - "Ticket FAILED → transition ไปสถานะอะไร?"

2. "ต้องการเปลี่ยน assignee ไหม?"
3. "ต้องการเพิ่ม label ไหม?"
4. "มีอย่างอื่นที่ต้องทำกับ tickets เหล่านี้อีกไหม?"

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

"ทั้งหมดถูกต้องครบ — confirm ได้เลยไหม?"

**Do NOT execute before final confirmation.**

Execute in order, show progress:
```
[1/18] ✅ Comment PROJ-101
[2/18] ✅ Comment PROJ-102
...
[18/18] ✅ Done — 18/18 actions completed.
```

#### Phase 7E: Handoff (Optional)

After all actions complete, offer handoff if relevant:

- "ต้องการให้สรุปผลเทสเป็นรายงานสำหรับ manager ไหม?" → Invoke `management-talk` skill if available
- "ต้องการ retest bugs ที่เปิดไว้ไหม?" → Invoke `retest-bug` skill if available
- "ต้องการเปิด post-mortem สำหรับ Critical bugs ไหม?" → Invoke `post-mortem` skill if available

If no handoff needed → session complete.

> **Phase 7 Self-Check:** "ทุก action ที่ confirm แล้ว ได้ execute ครบจริงไหม? มี action ไหนที่ fail แล้วไม่ได้ retry?"

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
| Thai directly in JS file | Escape to `\uXXXX` after stringify |
| Assumed column positions | Read sheet headers first |
| Mixed date formats | Match existing format |
