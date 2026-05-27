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
| **Quick** | `/full-test quick` | Phase 0 (turbo) → 1 → 5 → 6 | Top 5 flows, desktop only, primary role, all defaults |
| **Targeted** | `/full-test module:auth` | All 7 phases | Specified module/route only |

In **Quick** mode: skip Phase 2 (cross-platform) and Phase 3 (strategy). Still apply all constraints.

If ambiguous, ask: "Full test (ทุก route, ทุก role, ทุก viewport) หรือ Quick smoke test (top 5 flows, desktop only)?"

---

## Project Config (`.full-test.json`)

Optional config file ที่ project root — ช่วยให้รันซ้ำไม่ต้องตอบคำถามเดิม

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

**กฎ:**
- **ห้ามบันทึก credentials** (username/password) ลง config — session-only เท่านั้น
- ครั้งแรกที่รัน → ถ้าไม่มี config → เสนอสร้างให้หลัง confirm
- ครั้งถัดไป → โหลด config → แสดงสรุป → confirm ทีเดียว → ถาม credentials → เริ่มเทส
- เพิ่ม `.full-test.json` ใน `.gitignore` อัตโนมัติ (ถ้ามี `.gitignore`)

---

## Workflow

Follow these phases strictly in order:

---

### Phase 0: Discovery & Setup

**Goal:** สอบถามความต้องการ, เช็ค prerequisites ทั้งหมด, วิเคราะห์ source code, สร้าง test matrix, ได้ user confirmation ก่อนเริ่มทดสอบ

**Hard Gate:** Phase 0 MUST produce all 4 outputs below. If ANY is missing, refuse to start Phase 1:
1. Confirmed test cases (from user-specified source)
2. Confirmed test matrix (routes, roles, modules, viewports, modes)
3. Target URL (verified accessible)
4. Test accounts (or explicit "skip role X" from user)

**UX Rules:**
- **ใช้ `AskUserQuestion` tool** สำหรับคำถาม multiple choice ทุกข้อ — ให้กดเลือก ไม่ต้องพิมพ์
- **Smart Defaults** → detect จาก code/git ให้มากที่สุด → แสดงค่าที่เดาได้พร้อมกัน → user confirm/แก้รวบ
- **ถ้ามี `.full-test.json`** → โหลดค่าเดิม → ถามยืนยันทีเดียว → ถ้า OK ข้ามไปถาม credentials เลย
- **Credentials ไม่ cache** — ถามทุกครั้ง (session-only)
- **Pre-flight เช็คตั้งแต่ตอนนี้** — ไม่รอ Phase 6 ถึงค่อยรู้ว่า tools ไม่พร้อม

**Steps:**

0. **ถามความต้องการ** (ถ้า `/full-test` เฉยๆ ไม่ได้ระบุอะไร):

   ใช้ `AskUserQuestion` tool:
   - ทดสอบทิคเกตเฉพาะ (ระบุ ticket key เช่น PROJ-123)
   - ทดสอบทั้ง module / feature (เช่น auth, dashboard)
   - ทดสอบทั้ง project ครบทุก route
   - รีเทสบัคที่เคยเปิดไว้

   **รอ user ตอบก่อน — ห้ามทำอะไรจนกว่าจะได้คำตอบ**

   ถ้า user ระบุ ticket → ดึงรายละเอียดจาก Jira/GitHub → ใช้เป็น scope
   ถ้า user ระบุ module → Targeted mode
   ถ้า user ระบุทั้ง project → Full mode
   ถ้า user ระบุมาพร้อม `/full-test` (เช่น `/full-test PROJ-123`) → ข้ามข้อนี้

1. **Find project root** (silent) — look for `package.json`, `next.config.*`, `vite.config.*`, or similar.

2. **โหลด `.full-test.json`** (ถ้ามีที่ project root):

   **ถ้ามี config → Fast Path:**
   แสดงสรุปค่าจาก config:
   ```
   ━━━ โหลดค่าจาก .full-test.json ━━━
   URL:         http://localhost:3000
   Viewports:   Desktop, Mobile
   Bug Target:  GitHub (owner/repo) + Jira (PROJ)
   Test Cases:  Jira (PROJ)
   Roles:       admin, user, guest
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```
   "ใช้ค่าเดิมได้เลยไหมครับ? หรือต้องการปรับข้อไหน?"
   - ถ้า confirm → **ข้ามไป Step 5** (Pre-flight) → แล้วไป Step 7 (Credentials)
   - ถ้าต้องการปรับ → ใช้ `AskUserQuestion` ถามเฉพาะข้อที่เปลี่ยน

   **ถ้าไม่มี config → ไป Step 3**

3. **Discover** (silent — ไม่ต้องถาม user):
   - **Routes/Pages:** React Router (`<Route`, `path=`), Next.js (`pages/`, `app/`), Vue Router, SvelteKit, generic
   - **Roles:** grep `RoleGuard`, `ProtectedRoute`, `authRequired`, `role ===`, `isAdmin`, `useAuth`, `permissions`
   - **Modules/Features:** scan `src/features/`, `src/modules/`, `src/pages/`, sidebar/nav components
   - **Modes:** grep `darkMode`, `theme`, `colorScheme`, `locale`, `i18n`
   - **URL hint:** อ่าน `package.json` scripts → detect dev/start command + port
   - **Bug Target hint:** อ่าน `git remote -v` → detect owner/repo

4. **Smart Defaults — แสดงทุกค่าพร้อมกัน:**

   รวม discovery + detected hints → แสดงสรุป:
   ```
   ━━━ ค่าที่ตรวจพบ (แก้ได้) ━━━
   Test Cases:  generate จาก code (25 cases)
   URL:         http://localhost:3000 (จาก package.json → "dev")
   Roles:       admin, user, guest (จาก RoleGuard)
   Viewports:   Desktop 1920x1080, Mobile 375x667 (default)
   Bug Target:  GitHub owner/repo (จาก git remote)
   Mode:        Full
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```
   "ค่าด้านบนถูกต้องไหมครับ? ต้องการปรับข้อไหน?"

   → ถ้า confirm ทั้งหมด → ไป Step 5
   → ถ้าต้องการปรับ → ใช้ `AskUserQuestion` ถามเฉพาะข้อที่เปลี่ยน:
     - Test Cases Source → AskUserQuestion (Jira / Confluence / CSV / GitHub Issues / generate / ระบุเอง)
     - URL → ถามพิมพ์
     - Viewports → AskUserQuestion multiSelect (Desktop / Tablet / Mobile)
     - Bug Target → AskUserQuestion multiSelect (GitHub / Jira)
   → ถ้าบางค่า detect ไม่ได้ → ถามเฉพาะข้อนั้น

   **ถ้า Test Case Source ≠ generate → Fetch & normalize test cases → แสดงตาราง → ถาม confirm:**
   ```
   | # | Module     | Test Case                        | Role  | Priority |
   |---|------------|----------------------------------|-------|----------|
   | 1 | auth       | Login with valid credentials     | user  | High     |
   ```
   "เทสเคสทั้งหมด X ข้อ — ถูกต้องครบไหมครับ?"

5. **Pre-flight Checks** (ตรวจสอบ + เซ็ตอัปให้ทันที — ไม่รอ Phase 6):

   **a. URL / Dev server:**
   - ถ้า localhost/127.0.0.1 → ลอง `curl -s -o /dev/null -w '%{http_code}' <URL>`
   - ถ้ายังไม่รัน → อ่าน `package.json` หา start command
   - ถาม: "Dev server ยังไม่รัน — ให้ช่วยรันด้วย `<detected-command>` ให้ไหมครับ?"
   - ถ้า user confirm → รัน background + รอ server ready
   - ถ้า user บอกจะรันเอง → รอจนกว่า server จะ respond
   - ถ้า remote URL → ลอง fetch เช็ค accessible → ถ้าไม่ได้ → แจ้ง + ถามใหม่
   - Note (remote): source code may differ from deployed version

   **b. GitHub CLI** (ถ้า bug target รวม GitHub):
   - `which gh` → ไม่พบ → ถาม: "ให้ติดตั้ง `gh` ด้วย `brew install gh` ไหมครับ?" → confirm → ติดตั้งให้
   - `gh auth status` → ไม่ได้ login → ถาม: "ให้ช่วย login GitHub CLI ไหมครับ?" → confirm → รัน `gh auth login` ให้
   - `gh repo view <owner/repo>` → ไม่พบ → ถาม: "ชื่อ repo ถูกต้องไหมครับ?"
   - สร้าง labels ที่ขาด (bug, severity:*, module:*) ให้อัตโนมัติ
   - ถ้า user ไม่ต้องการ setup → ข้าม GitHub Issues + แจ้ง

   **c. Jira MCP** (ถ้า bug target รวม Jira):
   - ลอง `getVisibleJiraProjects` → ถ้าสำเร็จ → MCP ใช้ได้ ✅
   - ถ้า fail → แจ้ง: "Atlassian MCP ยังเชื่อมต่อไม่ได้ — จะใช้ JXA fallback"
   - เช็ค Chrome + Jira login → ถ้า Chrome ไม่ได้เปิด Jira → ถาม: "เปิด Jira ให้ไหมครับ?" → confirm → เปิดให้
   - ถ้า MCP ใช้ได้ → verify project key + issue types
   - ถ้า project key ไม่พบ → ถาม: "project key ถูกต้องไหมครับ?"

   **แสดงสรุป Pre-flight:**
   ```
   ━━━ Pre-flight ━━━
   URL:    http://localhost:3000 ✅ running
   GitHub: owner/repo ✅ gh authenticated
   Jira:   PROJ ✅ MCP connected
   ━━━━━━━━━━━━━━━━━
   ```

6. **ถามข้อสุดท้ายก่อน credentials — Confirm Test Matrix:**
   แสดง test matrix (ถ้ายังไม่ได้แสดงใน Step 4):
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

7. **ถาม Credentials** (ทุกครั้ง — ไม่ cache):
   ```
   | Role   | Username/Email | Password | Notes      |
   |--------|----------------|----------|------------|
   | admin  | ?              | ?        |            |
   | user   | ?              | ?        |            |
   | guest  | (ไม่ต้อง login) | —        |            |
   ```
   "กรุณาระบุ credentials สำหรับแต่ละ role ที่ต้อง login ครับ"
   **Do NOT store credentials in any file or log — session-only use.**

   **รอ user ตอบก่อน — ห้ามทำอะไรจนกว่าจะได้คำตอบ**

8. **Final Confirm:**
   ```
   ━━━ สรุปก่อนเริ่มทดสอบ ━━━
   Test Cases:  25 ข้อ (จาก Jira PROJ)
   URL:         http://localhost:3000 ✅
   Roles:       admin (a@test.com), user (u@test.com)
   Viewports:   Desktop, Mobile
   Bug Target:  Jira (PROJ) ✅ + GitHub (owner/repo) ✅
   Mode:        Full (ทุก Phase)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```
   "ทั้งหมดถูกต้องครบ — confirm เริ่มทดสอบได้เลยไหมครับ?"

   **รอ user confirm ก่อน — ห้ามเริ่ม Phase 1 จนกว่าจะได้ confirm**

9. **เสนอบันทึก `.full-test.json`** (ถ้ายังไม่มี):
   "ต้องการบันทึกค่าเหล่านี้เป็น `.full-test.json` ไหมครับ? รันครั้งหน้าจะได้ไม่ต้องตอบใหม่"
   - ถ้า confirm → สร้างไฟล์ที่ project root (ไม่รวม credentials) + เพิ่มใน `.gitignore`
   - ถ้าไม่ต้องการ → ข้ามไป Phase 1

10. **If discovery finds nothing** for any category → ask user directly.

**Hard Gate Check:** Do you have all 4 required outputs? If not, ask for the missing ones. Do NOT proceed to Phase 1.

**Quick Mode Shortcut:** ถ้า `/full-test quick`:
- มี `.full-test.json` → โหลด config + ถาม credentials เท่านั้น + confirm → เริ่มเทส (**2 ข้อความ**)
- ไม่มี config → ใช้ Smart Defaults ทั้งหมด + ถาม credentials + confirm → เริ่มเทส (**3 ข้อความ**)

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

   **รอ user ตอบก่อน — ห้ามทำอะไรจนกว่าจะได้คำตอบ**

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

After all drafts: "ร่างบัคทั้งหมด X ตัว — ต้องแก้ไขตัวไหนไหมครับ? หรือ confirm เปิดได้เลย?"

**แสดง draft ให้ user อนุมัติก่อน — รอจนกว่าจะได้คำตอบ**

**Iteration limit:** If user requests revisions 3 times on the same bug → ask: "ข้อไหนที่ยังไม่ตรง? ช่วยระบุให้ชัดเพื่อจะได้แก้ถูกจุด"

**กฎ: ห้ามเปิดบัคจริงโดยไม่ได้รับอนุมัติจาก user — แสดง draft ก่อนเสมอ**

---

#### Phase 6B: GitHub Issues

**Pre-flight:** ปกติเช็คเสร็จแล้วจาก Phase 0 Step 5b — ถ้ายังไม่ได้เช็ค (edge case):
- เช็ค `gh` CLI installed + authenticated → ถ้าไม่พร้อม → ถาม + เซ็ตอัปให้ (ดู Phase 0 Step 5b)
- เช็ค repo accessible → ถ้าไม่พบ → ถามชื่อใหม่
- สร้าง labels ที่ขาด (bug, severity:*, module:*) ให้อัตโนมัติ

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

2. **Pre-flight:** ปกติเช็คเสร็จแล้วจาก Phase 0 Step 5c — ถ้ายังไม่ได้เช็ค (edge case):
   - เช็ค Jira MCP connectivity → ถ้า fail → ใช้ JXA fallback + เปิด Chrome/Jira ให้ (ดู Phase 0 Step 5c)
   - verify project: `getJiraProjectIssueTypesMetadata`, `getJiraIssueTypeMetaWithFields`
   - ถ้า project key ไม่พบ → ถาม: "project key ถูกต้องไหมครับ?"

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

4. **Jira Posting Pipeline** (ลำดับเดียวกับ retest-bug-plugin):

   **Step A — Try Atlassian MCP first:**
   ใช้ `createJiraIssue` MCP tool → ถ้าสำเร็จ → จบ

   **Step B — Fallback: Node.js + JXA + Chrome** (ถ้า MCP return 403 หรือ fail):
   1. Build issue body ด้วย real Thai text
   2. `JSON.stringify` body **ก่อน** escape non-ASCII
   3. Escape non-ASCII **หลัง** stringify:
      ```javascript
      const safe = bodyStr.replace(/[^\x00-\x7F]/g, c =>
        '\\u' + c.charCodeAt(0).toString(16).padStart(4, '0')
      );
      ```
   4. Save file as ASCII: `fs.writeFileSync(path, js, 'ascii')`
   5. Verify: `if (/[^\x00-\x7F]/.test(js)) throw 'STILL HAS NON-ASCII'`
   6. Execute via JXA: `osascript -l JavaScript <file>`

   **ลำดับสำคัญมาก:** Escape Thai ก่อน stringify = พัง. Thai ตรงๆ ใน JS file = encoding corruption.

5. **Pre-post validation checklist** (ต้องผ่านทุกข้อก่อนโพสต์):
   - [ ] Emoji `❌` `✅` เป็น real Unicode — ไม่ใช่ `\\u274c` (double backslash = literal text)
   - [ ] ไม่มี bare ticket keys — wrap ใน `{{PROJ-123}}`
   - [ ] ไม่มี Thai particles (ครับ/ค่ะ) — ใช้ neutral language
   - [ ] Endpoint ตรงกับ format (v2 = wiki, v3 = ADF)
   - [ ] Screenshots uploaded as attachments ก่อน embed `!filename.png|width=600!`
   - [ ] JS file เป็น ASCII-only (ถ้าใช้ JXA fallback)

6. **Dry-run ก่อนโพสต์** (ถ้าใช้ JXA fallback):
   - อ่าน JS file กลับมา
   - Decode `\uXXXX` sequences
   - Verify: emoji ถูกต้อง, Thai text อ่านได้, ไม่มี ticket keys ที่จะ auto-link
   - **ถ้า dry-run fail → แก้ template แล้ว re-generate ก่อนโพสต์ — ห้ามโพสต์แล้วค่อยแก้ทีหลัง**

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

**กฎ: ร่าง draft ทุกอย่างใน chat ให้ user เห็น — ห้าม post โดยไม่ได้รับอนุมัติจาก user**

Show draft in chat:

**Jira comment (ใช้ format ตรงนี้เท่านั้น):**
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

"Draft ด้านบนถูกต้องไหมครับ? ต้องแก้อะไรก่อนอัปเดตจริง?"

**แสดง draft ให้ user อนุมัติก่อน — รอจนกว่าจะได้คำตอบ**

**Iteration limit:** 3 revision rounds → ask "ข้อไหนที่ยังไม่ตรง?" Don't keep tweaking blindly.

**Jira Comment Posting Pipeline** (ใช้วิธีเดียวกับ Phase 6C):

1. **Try Atlassian MCP first:** `addCommentToJiraIssue` with `contentFormat: markdown`
2. **Fallback: Node.js + JXA** ถ้า MCP fail (encoding pipeline เหมือน Phase 6C)
3. **Pre-post validation checklist** ต้องผ่านทุกข้อก่อนโพสต์
4. **Dry-run** ก่อนโพสต์จริง (ถ้าใช้ JXA)
5. **ถ้า dry-run fail → แก้แล้ว re-generate ก่อน — ห้ามโพสต์แล้วค่อยแก้**

**Content rules สำหรับ Jira comments:**
- ห้ามใส่ Thai particles (ครับ/ค่ะ) — ใช้ neutral language
- ใช้ "Test Result: PASSED ✅" หรือ "Test Result: FAILED ❌" เท่านั้น — ห้ามใช้รูปแบบอื่น
- Date format: YYYY-MM-DD
- Full evidence ทุก test case — ห้ามย่อ ห้ามใช้ "same as above"

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

**รอ user confirm ก่อน — ห้ามลงมือทำก่อนได้ confirm รอบสุดท้ายนี้**

เมื่อ user confirm แล้ว → **ทำต่อเนื่องทันทีทุก action ไม่ต้องถามซ้ำ** (transition + assign + label + comment):

Execute in order, show progress:
```
[1/18] ✅ Comment PROJ-101
[2/18] ✅ Comment PROJ-102
...
[18/18] ✅ Done — 18/18 actions completed.
```

**กฎ:** หลัง user confirm ใน Phase 7D แล้ว ทำ transition + assign + label + comment ต่อเนื่องทันที — ไม่ต้องถามอีก

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
