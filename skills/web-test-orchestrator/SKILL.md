---
name: web-test-orchestrator
description: Use when running comprehensive web testing across all roles, modules, features, platforms, and modes — orchestrates 4 testing skills sequentially then reports bugs as GitHub issues with evidence
---

# Web Test Orchestrator

Comprehensive web testing orchestrator that runs 4 testing skills in sequence, consolidates findings, and opens GitHub issues with evidence-backed bug reports.

## When to Use

- User wants to test a web application thoroughly
- User invokes `/full-test`
- User asks for comprehensive QA / regression testing
- User wants to find bugs across all roles, modules, platforms

## Hard Rules

- **NEVER open a GitHub issue without evidence from real code or measurable errors**
- **NEVER skip Phase 0 discovery** — always confirm test matrix with user before testing
- **NEVER run tests before user confirms the test matrix**
- **ALWAYS ask user to confirm bugs before opening GitHub issues**
- **ALWAYS include file path + line number in every bug report**
- **ALWAYS run skills in order** — do not skip or reorder phases
- **NEVER say "cannot test because there is no test data"** — if test data is needed, CREATE it yourself (see Test Data Rules below)

## Test Data Rules

**ห้ามหยุดเทสเพราะ "ไม่มีข้อมูลทดสอบ" เด็ดขาด** — ถ้าต้องการข้อมูลเพื่อทดสอบ ให้หาทางสร้างเองให้ได้:

1. **Form / Input testing:** สร้าง test data เองตาม field type:
   - Email → `test-<timestamp>@example.com`
   - Phone → `0800000001`
   - Name → `Test User`, `ทดสอบ ระบบ`
   - Date → วันนี้, อดีต, อนาคต
   - Number → 0, 1, -1, boundary values, max
   - Text → short, long (>255 chars), special chars, emoji, HTML tags
   - File upload → สร้าง dummy file ด้วย Playwright (small PNG, PDF)

2. **CRUD testing:** ถ้าต้องมี record ในระบบก่อนถึงจะเทสได้:
   - สร้าง record ใหม่ผ่าน UI ก่อน (create flow) → แล้วค่อยเทส read/update/delete
   - ถ้ามี API → สร้าง data ผ่าน API ก่อน test
   - ถ้ามี seed script → รัน seed ก่อน test

3. **Role-based testing:** ถ้า role ไหนไม่มี account:
   - ถาม user ว่าสร้าง account ใหม่ได้ไหม
   - ถ้าได้ → สร้างผ่าน signup flow หรือ admin panel
   - ถ้าไม่ได้ → note ไว้ว่า "ไม่ได้ทดสอบ role X — ต้องการ account จาก admin" แต่ยังทดสอบ role อื่นต่อ ห้ามหยุดทั้งหมด

4. **Empty state testing:** ถ้าหน้าว่างเพราะไม่มีข้อมูล:
   - นี่คือสิ่งที่ต้องเทส — empty state ต้องแสดงผลถูกต้อง
   - เทส empty state ก่อน → สร้าง data → เทส populated state

5. **Search / Filter testing:** สร้าง data หลากหลายก่อน แล้วค่อยเทส search/filter

**ลำดับความสำคัญในการหา test data:**
1. สร้างผ่าน UI ของแอปเอง (ดีที่สุด — เทส create flow ไปด้วย)
2. สร้างผ่าน API (เร็ว แต่ข้าม UI validation)
3. รัน seed/fixture script (ถ้ามีใน project)
4. ถาม user ขอ data / ขอ access — **ถามเฉพาะเมื่อทำเองไม่ได้จริงๆ**

**ห้ามเด็ดขาด:**
- ห้ามข้ามเทสเคสเพราะ "ไม่มีข้อมูล"
- ห้ามบอก user ว่า "ไม่สามารถทดสอบได้" โดยไม่ลองหาทางสร้างข้อมูลก่อน
- ห้ามสมมติว่า data ไม่สำคัญ — ทุกเทสเคสต้องรันด้วย data จริง

## Workflow

Follow these 7 phases strictly in order:

---

### Phase 0: Discovery

**Goal:** Analyze the source code to build a test matrix, then get user confirmation.

**Steps:**

1. **Find the project root** — look for `package.json`, `next.config.*`, `vite.config.*`, or similar in the current working directory or the repo the user pointed to.

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
   - Scan directory structure: `src/features/`, `src/modules/`, `src/pages/`, `src/views/`
   - Read navigation/sidebar components to find menu items
   - List distinct functional areas

5. **Discover Modes:**
   - grep for: `darkMode`, `theme`, `colorScheme`, `locale`, `i18n`, `dir=`, `rtl`
   - Check for theme provider/context

6. **Ask for Test Case Source:**

   ถาม user ว่าเทสเคสมาจากไหน:
   - "เทสเคสที่ต้องการใช้มาจากไหน?"
     - **Jira** — ระบุ project key หรือ filter/JQL (เช่น `project = MERIT AND type = "Test Case"`)
     - **Confluence** — ระบุ page URL ที่มี test cases
     - **Spreadsheet/CSV** — ระบุ path ไฟล์
     - **GitHub Issues** — ระบุ repo + label (เช่น `label:test-case`)
     - **ให้ generate จาก code** — ใช้ test matrix ที่ discover ได้สร้าง test cases อัตโนมัติ
     - **ระบุเอง** — user พิมพ์ test cases ใน chat

7. **Fetch & Review Test Cases:**

   ไปดึงเทสเคสจากแหล่งที่ user ระบุ:
   - **Jira:** ใช้ Atlassian MCP tools (`searchJiraIssuesUsingJql`) ดึง test cases → แปลงเป็นรายการ
   - **Confluence:** ใช้ Atlassian MCP tools (`getConfluencePage`) อ่านหน้า test cases
   - **Spreadsheet/CSV:** อ่านไฟล์ด้วย Read tool
   - **GitHub Issues:** ใช้ `gh issue list --label test-case` ดึง issues
   - **Generate จาก code:** สร้าง test cases จาก routes × roles × modules ที่ discover ได้
   - **ระบุเอง:** รับจาก user message

   แปลง test cases ทั้งหมดให้อยู่ในรูปแบบเดียวกัน:
   ```
   | # | Module     | Test Case                        | Role  | Priority |
   |---|------------|----------------------------------|-------|----------|
   | 1 | auth       | Login with valid credentials     | user  | High     |
   | 2 | auth       | Login with wrong password        | user  | High     |
   | 3 | dashboard  | View dashboard after login       | admin | Medium   |
   ```

8. **Confirm Test Cases with user:**

   แสดงรายการเทสเคสทั้งหมดที่ได้มา แล้วถาม:
   - "เทสเคสทั้งหมด X ข้อ ตามตารางด้านบน — ถูกต้องครบไหม? ต้องเพิ่ม/ลด/แก้ข้อไหน?"
   - รอ user ยืนยันหรือแก้ไข → อัปเดตรายการตามที่ user ต้องการ
   - **ห้ามรัน test ก่อน user ยืนยัน test cases**

9. **Present Test Matrix** to user in this format:

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
    - "URL ของเว็บที่จะเทสคืออะไร? (เช่น http://localhost:3000, https://staging.example.com)"
    - ถ้า user ให้ localhost → ถาม: "Dev server รันอยู่แล้วหรือยัง? ถ้ายังต้องใช้คำสั่งอะไรรัน?"
    - ถ้า user ให้ remote URL → note ไว้ว่า source code อาจไม่ตรง 100% กับ deployed version

11. **Ask test accounts:**
    - "มี account สำหรับเทสแต่ละ role ไหม?"
    - แสดงตาราง roles ที่ discover ได้:
      ```
      | Role   | Username/Email | Password | Notes      |
      |--------|----------------|----------|------------|
      | admin  | ?              | ?        |            |
      | user   | ?              | ?        |            |
      | guest  | (ไม่ต้อง login) | —        |            |
      ```
    - "กรุณาระบุ credentials สำหรับแต่ละ role ที่ต้อง login"
    - ถ้า user ไม่มี account สำหรับ role ใด → ข้าม role นั้น note ไว้ว่า "ไม่ได้ทดสอบ role X เพราะไม่มี account"
    - **ห้ามเก็บ credentials ลง file หรือ log ใดๆ — ใช้ในเทสระหว่าง session เท่านั้น**

12. **Confirm everything:**
    - "Test matrix + test cases + URL + accounts ทั้งหมดนี้ถูกต้องไหม?"
    - "ต้องการทดสอบ Viewports ไหนบ้าง? (default: Desktop 1920x1080, Tablet 768x1024, Mobile 375x667)"
    - "เปิด issues ที่ GitHub repo ไหน? (format: owner/repo)"

13. **If discovery finds nothing** for any category → ask user directly instead of guessing.

**Do NOT proceed until user confirms test cases, test matrix, URL, AND accounts.**

---

### Phase 1: Recon (webapp-testing)

**Goal:** Initial reconnaissance — visit every route, capture screenshots, find obvious errors.

**Invoke:** `webapp-testing` skill (Anthropic official)

**Instructions to pass:**
- Visit each route from the confirmed test matrix
- For each route:
  - Wait for `networkidle`
  - Take a screenshot
  - Check browser console for errors/warnings
  - Check for broken images, missing assets
  - Check for JS exceptions
  - Note HTTP error responses (4xx, 5xx)
- Test with each role if authentication is involved
- Record all findings with route, role, and error details

**Collect findings** as a structured list:
```
Finding: [description]
Route: [path]
Role: [role or N/A]
Type: [console-error | broken-asset | js-exception | http-error | visual]
Evidence: [error message or screenshot path]
```

---

### Phase 2: Cross-platform (playwright-skill)

**Goal:** Test responsive layout across all confirmed viewports.

**Invoke:** `playwright-skill:playwright-skill` skill (lackeyjb)

**Instructions to pass:**
- Test each route from the test matrix at every confirmed viewport
- For each route x viewport combination:
  - Check for horizontal overflow / scrollbar
  - Check for overlapping elements
  - Check for text truncation that hides content
  - Check for touch targets too small on mobile (< 44x44px)
  - Check for elements that disappear or break layout
  - Take screenshots at each viewport for comparison
- If roles exist: test key pages per role at each viewport
- If modes exist (dark/light): test at each mode

**Collect findings** in the same structured format as Phase 1, adding:
```
Viewport: [Desktop 1920x1080 | Tablet 768x1024 | Mobile 375x667]
Mode: [light | dark | N/A]
```

---

### Phase 3: Strategy & Analysis (test-master)

**Goal:** Analyze findings from Phase 1-2, identify coverage gaps, assign severity.

**Invoke:** `fullstack-dev-skills:test-master` skill (Jeffallan)

**Instructions to pass:**
- Review all findings from Phase 1 and Phase 2
- Identify gaps that weren't tested:
  - Edge cases (empty states, long text, special characters)
  - Error handling (network failures, invalid input)
  - Form validation (required fields, format validation)
  - Navigation flows (back button, deep linking)
  - State persistence (refresh, tab switching)
- Assign severity to every finding:
  - **Critical:** Unusable — crash, data loss, security hole, blank page
  - **High:** Core feature broken — form submit fails, login broken, navigation broken
  - **Medium:** Secondary feature issue — layout shift, responsive break, poor UX
  - **Low:** Cosmetic — typo, spacing, minor color issue, console warning
- Run additional targeted tests for identified gaps
- Produce a rated findings report

**Collect findings** — merge with Phase 1-2 findings, add:
```
Severity: [Critical | High | Medium | Low]
Category: [functional | responsive | accessibility | security | edge-case]
```

---

### Phase 4: Deep E2E (playwright-expert)

**Goal:** Test critical user flows end-to-end with robust patterns.

**Invoke:** `fullstack-dev-skills:playwright-expert` skill (Jeffallan)

**Instructions to pass:**
- Identify the top user flows from the test matrix (login, CRUD operations, navigation, key business flows)
- For each flow:
  - Use role-based selectors (`getByRole`, `getByLabel`) — not CSS classes
  - Test the happy path completely
  - Test error paths (wrong password, invalid input, network error)
  - Check for race conditions (double-click, rapid navigation)
  - Check for flaky behavior (retry each test mentally)
- Test cross-role flows if applicable (e.g., admin creates → user views)
- Use Page Object Model thinking for structured testing

**Collect findings** in the same structured format.

---

### Phase 5: Consolidate

**Goal:** Merge all findings, deduplicate, split by confidence, get user approval.

**Steps:**

1. **Merge** all findings from Phase 1-4 into a single list.

2. **Deduplicate** — if multiple findings point to the same root cause:
   - Keep one entry
   - Note which phases found it (e.g., "Found by: Phase 1, Phase 2")
   - Use the highest severity assigned

3. **Assign confidence:**
   - **High confidence:** Has console error, network error, JS exception, or clearly broken UI vs the rest of the app
   - **Medium confidence:** Has visual evidence (screenshot) + code reference showing the likely cause
   - **Low confidence:** Subjective assessment, might be intentional design, no hard error

4. **Look up source code** for every finding:
   - Find the file and line number responsible
   - Quote the relevant code
   - Write a clear reason why this is a bug (not a subjective opinion)
   - If you cannot find code evidence → mark as Low confidence

5. **Display two tables** in chat:

   **Confirmed Bugs (High/Medium confidence):**
   ```
   | # | Severity | Module   | Bug                          | Confidence | Found by     |
   |---|----------|----------|------------------------------|------------|--------------|
   | 1 | Critical | auth     | Login form crash on empty    | High       | Phase 1, 4   |
   | 2 | High     | dashboard| Chart overflow on mobile     | Medium     | Phase 2      |
   ```

   **Needs Review (Low confidence):**
   ```
   | # | Severity | Module   | Bug                          | Confidence | Found by     |
   |---|----------|----------|------------------------------|------------|--------------|
   | 1 | Low      | settings | Color might be wrong         | Low        | Phase 2      |
   ```

6. **Ask user:**
   - "Confirmed bugs ทั้งหมดนี้จะเปิดบัคให้เลยไหม?"
   - "Needs Review รายการไหนที่ต้องการเปิดด้วย?"
   - "เปิดบัคที่ไหน? — **GitHub Issues** หรือ **Jira** หรือ **ทั้งคู่**?"
   - ถ้าเลือก Jira → ถาม:
     - "Jira board URL หรือ project key? (เช่น https://team.atlassian.net/jira/software/projects/PROJ/board/1 หรือ PROJ)"
     - "Issue type ที่ต้องใช้? (เช่น Bug, Task, Story)"
     - "ต้องการ custom fields อะไรบ้าง? (เช่น Sprint, Component, Priority mapping)"
   - ถ้าเลือก GitHub → ถาม repo (format: owner/repo)
   - Wait for user confirmation.

---

### Phase 6: Open Bug Reports

**Goal:** Open one bug report per confirmed finding — ใน GitHub Issues, Jira, หรือทั้งคู่ ตามที่ user เลือก

**สำคัญ: ร่างบัคทุกตัวใน chat ให้ user confirm ก่อนเปิดจริงเสมอ**

---

#### Phase 6A: Draft Bugs in Chat

**ก่อนเปิดบัคจริง** ต้องร่างทุกตัวใน chat ให้ user ดูก่อน:

สำหรับแต่ละ bug แสดง draft:

```
━━━ Bug #1 ━━━
Title: [Severity] Module — Short description
Severity: Critical | High | Medium | Low
Module: auth
Confidence: High | Medium

Description:
[อธิบายปัญหา]

Steps to Reproduce:
1. ไปที่ ...
2. คลิก ...
3. สังเกต ...

Expected: [ควรเป็นอย่างไร]
Actual: [เกิดอะไรขึ้นจริง]

Evidence:
- File: src/components/Foo.tsx:42
- Code: [relevant snippet]
- Reason: [ทำไมเป็น bug]

Environment: Desktop 1920x1080, Chromium
Screenshot: [path ถ้ามี]
━━━━━━━━━━━━━━
```

หลังแสดง draft ทุกตัว ถาม:
- "ร่างบัคทั้งหมด X ตัวด้านบน — ต้องแก้ไขตัวไหนไหม? หรือ confirm เปิดได้เลย?"
- **ห้ามเปิดบัคจริงก่อน user confirm**

---

#### Phase 6B: GitHub Issues (ถ้า user เลือก)

1. Verify `gh` CLI is authenticated: `gh auth status`
2. Verify target repo exists: `gh repo view <owner/repo>`
3. For each approved bug, create an issue:

```bash
gh issue create --repo <owner/repo> \
  --title "[Severity] Module — Short description" \
  --label "bug,severity:<level>,module:<name>" \
  --body "$(cat <<'ISSUE_EOF'
## Description

[Clear description of the bug]

## Steps to Reproduce

1. Go to [route]
2. [Action]
3. Observe [problem]

## Expected Behavior

[What should happen]

## Actual Behavior

[What actually happens]

## Evidence & Root Cause

**File:** `[file path:line number]`
**Code:**
```
[relevant code snippet]
```

**Why this is a bug:**
[Clear reasoning — e.g., contradicts behavior in another part of the app, console error, WCAG violation, CSS conflict]

**Confidence:** [High / Medium / Low]

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

#### Phase 6C: Jira Issues (ถ้า user เลือก)

1. **ดึงข้อมูล project:** ใช้ Atlassian MCP tools:
   - `getVisibleJiraProjects` — verify project key ถูกต้อง
   - `getJiraProjectIssueTypesMetadata` — ดู issue types ที่ใช้ได้
   - `getJiraIssueTypeMetaWithFields` — ดู fields ที่ต้องกรอก

2. **Map severity → Jira priority:**
   | Severity | Jira Priority |
   |----------|---------------|
   | Critical | Highest       |
   | High     | High          |
   | Medium   | Medium        |
   | Low      | Low           |

3. **สร้าง issue ทีละตัว** ด้วย `createJiraIssue`:
   - **Project:** ตาม project key ที่ user ระบุ
   - **Issue Type:** ตาม type ที่ user เลือก (default: Bug)
   - **Summary:** `[Severity] Module — Short description`
   - **Priority:** ตาม mapping ด้านบน
   - **Labels:** `bug`, `module:<name>`, `auto-tested`
   - **Description** (Jira markup):

   ```
   h2. Description
   [อธิบายปัญหา]

   h2. Steps to Reproduce
   # ไปที่ [route]
   # [Action]
   # สังเกต [problem]

   h2. Expected Behavior
   [ควรเป็นอย่างไร]

   h2. Actual Behavior
   [เกิดอะไรขึ้นจริง]

   h2. Evidence & Root Cause
   *File:* {{file path:line number}}
   *Code:*
   {code}
   [relevant code snippet]
   {code}

   *Why this is a bug:*
   [reasoning]

   *Confidence:* High / Medium / Low

   h2. Environment
   * Viewport: [viewport]
   * Browser: Chromium (Playwright)
   * URL: [route URL]

   h2. Found By
   Phase [X] — [skill name]
   Tested on: [date]
   ```

   - **Component:** ตาม module (ถ้า Jira project มี components ตรง)
   - **Custom fields:** ตามที่ user ระบุ (Sprint, Epic Link, etc.)

---

#### Phase 6D: Summary

หลังเปิดบัคทุกตัวแล้ว แสดงสรุป:

```
| # | Target | Issue URL/Key              | Severity | Module   |
|---|--------|----------------------------|----------|----------|
| 1 | Jira   | PROJ-123                   | Critical | auth     |
| 2 | Jira   | PROJ-124                   | High     | dashboard|
| 3 | GitHub | github.com/o/r/issues/1    | Medium   | settings |
```

Report total: "Created X bugs (Y Critical, Z High, W Medium, V Low) — Jira: A issues, GitHub: B issues"

---

### Phase 7: Post-Test Actions

**Goal:** Update test results to the destination user specifies, and optionally update Jira tickets.

**สำคัญ: ร่างทุกอย่างใน chat ให้ user confirm ก่อนลงมือทำจริงเสมอ**

---

#### Phase 7A: Ask Where to Record Results

ถาม user:
- "ต้องการให้อัปเดตผลการทดสอบไว้ที่ไหน?"
  - **Jira** — comment ผลเทสลง ticket (ระบุ ticket key หรือ filter)
  - **Google Sheets** — ระบุ URL ของ sheet
  - **File (CSV/Markdown)** — ระบุ path
  - **Confluence** — ระบุ page URL
  - **ไม่ต้อง** — ข้ามไป

ถ้า user เลือก **Google Sheets หรือ File**:
- "ให้อัปเดตคอลัมน์/ฟิลด์ไหนบ้าง? (เช่น Status, Result, Tester, Date, Notes)"
- "format ของผลเทสที่ต้องการ? (เช่น PASSED/FAILED, Pass/Fail, ✅/❌)"

---

#### Phase 7B: Draft Result Updates

สร้าง draft สิ่งที่จะอัปเดต แสดงใน chat:

**ถ้า Jira comment:**
```
━━━ Ticket PROJ-101 ━━━
Comment:
  Test Result: PASSED ✅
  Tested on: 2026-05-27
  Viewport: Desktop 1920x1080, Mobile 375x667
  Notes: All scenarios passed — login, dashboard, CRUD
━━━━━━━━━━━━━━━━━━━━━━━
```

**ถ้า Google Sheets / File:**
```
━━━ Row updates ━━━
| Test Case          | Status | Tester | Date       | Notes           |
|--------------------|--------|--------|------------|-----------------|
| Login valid creds  | PASSED | Claude | 2026-05-27 | No issues found |
| Login wrong pass   | PASSED | Claude | 2026-05-27 | Error shown OK  |
| Dashboard overflow | FAILED | Claude | 2026-05-27 | Bug PROJ-123    |
━━━━━━━━━━━━━━━━━━━━
```

**ถ้า Confluence:**
```
━━━ Page update ━━━
Page: [page title]
Section to add/update: Test Results
Content: [summary table with pass/fail counts and bug links]
━━━━━━━━━━━━━━━━━━━
```

ถาม: "Draft ด้านบนถูกต้องไหม? ต้องแก้อะไรก่อนอัปเดตจริง?"

**ห้ามอัปเดตจริงก่อน user confirm**

---

#### Phase 7C: Jira Ticket Actions (ถ้าเทสตาม Jira tickets)

ถ้า test cases มาจาก Jira tickets → ถามเพิ่ม:

1. "ต้องการให้ปรับสถานะ ticket ด้วยไหม?"
   - ถ้าใช่ → ใช้ `getTransitionsForJiraIssue` ดู transitions ที่ใช้ได้ แล้วถาม:
   - "Ticket ที่ PASSED ให้ transition ไปสถานะอะไร? (เช่น Done, Closed, Ready for Release)"
   - "Ticket ที่ FAILED ให้ transition ไปสถานะอะไร? (เช่น Reopen, In Progress, To Do)"

2. "ต้องการเปลี่ยน assignee ไหม?"
   - ถ้าใช่ → ถาม: "Assign ให้ใคร? (ระบุ email หรือ username)"

3. "ต้องการเพิ่ม label ไหม?"
   - ถ้าใช่ → ถาม: "Label อะไร? (เช่น tested, qa-passed, qa-failed, regression-tested)"

4. "มีอย่างอื่นที่ต้องการทำกับ tickets เหล่านี้อีกไหม?"

---

#### Phase 7D: Confirm & Execute

**สรุปทวนทุกอย่างที่จะทำ** ใน chat ก่อนลงมือ:

```
━━━ สรุปสิ่งที่จะดำเนินการ ━━━

1. อัปเดตผลเทส:
   - Jira: comment ผลเทสลง 5 tickets (PROJ-101 ~ PROJ-105)
   - Google Sheets: อัปเดต 10 rows ในคอลัมน์ Status, Date, Notes

2. ปรับ Jira tickets:
   - PROJ-101, PROJ-102, PROJ-104 (PASSED) → transition เป็น "Done"
   - PROJ-103, PROJ-105 (FAILED) → transition เป็น "Reopen"
   - เพิ่ม label "qa-passed" ให้ tickets ที่ PASSED
   - เพิ่ม label "qa-failed" ให้ tickets ที่ FAILED

3. เปิดบัคใหม่:
   - 3 issues ใน Jira (PROJ board)

Total actions: 18
━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

ถาม: "ทั้งหมดนี้ถูกต้องครบแล้ว — confirm ให้ดำเนินการได้เลยไหม?"

**ห้ามลงมือทำก่อน user confirm รอบสุดท้ายนี้**

เมื่อ user confirm แล้ว → execute ทุก action ตามลำดับ:
1. อัปเดตผลเทส (Jira comment / Sheets / File / Confluence)
2. Transition tickets
3. Update assignee / labels
4. เปิดบัคใหม่ (ถ้ายังไม่ได้เปิดใน Phase 6)

แสดง progress ระหว่างทำ:
```
[1/18] ✅ Comment ผลเทสลง PROJ-101
[2/18] ✅ Comment ผลเทสลง PROJ-102
...
[18/18] ✅ เปิดบัค PROJ-130

Done — 18/18 actions completed.
```

---

## Formatting Rules (Jira & Google Sheets)

Learned from production experience — follow strictly to avoid re-posts and encoding corruption.

### Jira Comment Format

**Step 1: Decide format BEFORE writing — lock in for entire session:**

| Bug Type | API Endpoint | Markup | When to Use |
|----------|-------------|--------|-------------|
| **API / Logic bug** | v3 (`addCommentToJiraIssue` with `contentFormat: markdown`) | ADF (JSON) | No screenshots needed |
| **FE / UI bug** | v2 (`/rest/api/2/issue/<KEY>/comment`) | Wiki Markup | Screenshots must be inline |

**Cannot switch mid-session.** Decide at the start based on whether screenshots are needed.

**Step 2: Use correct markup per format:**

**v2 Wiki Markup (FE bugs with screenshots):**
```
*Retest Result: PASSED ✅*

*Tested on:* <YYYY-MM-DD>
*Viewport:* <viewport>
*URL:* {{<url>}}

----

||Test Case||Result||Status||
|<case description>|<result>|✅|
|<case description>|<result>|❌|

----

*Evidence:*
!screenshot-filename.png|width=600!

*Notes:* <observations>
```

**v3 ADF (API bugs, no screenshots):**
Use `addCommentToJiraIssue` with `contentFormat: markdown` — write in Markdown, Jira converts automatically.

**Step 3: Pre-post validation checklist:**

Before posting ANY Jira comment, verify ALL of these:
- [ ] Emoji `❌` `✅` are **real Unicode characters** — NOT `\\u274c` (double backslash = literal text)
- [ ] No bare ticket keys like `PROJ-123` in free text — wrap in `{{PROJ-123}}` (monospace) to prevent auto-linking
- [ ] No Thai particles (ครับ/ค่ะ) — use neutral language in Jira
- [ ] Endpoint matches format (v2 = wiki markup, v3 = ADF)
- [ ] Screenshots uploaded as attachments BEFORE embedding with `!filename.png|width=600!`

### Thai Text Encoding (Critical for Jira)

If posting via JXA/JavaScript to Jira:

1. Generate body with real Thai text first
2. `JSON.stringify` BEFORE escaping non-ASCII
3. Escape non-ASCII AFTER stringify:
   ```javascript
   const safe = bodyStr.replace(/[^\x00-\x7F]/g, c =>
     '\\u' + c.charCodeAt(0).toString(16).padStart(4, '0')
   );
   ```
4. Save file as ASCII — verify: `!/[^\x00-\x7F]/.test(content)`
5. Dry-run: decode `\uXXXX` back and check emoji + Thai render correctly

**Order matters:** Escape Thai BEFORE `JSON.stringify` = broken. Thai directly in JS file = encoding corruption.

### Jira Wiki Markup Quick Reference

| Element | Syntax |
|---------|--------|
| Bold | `*text*` |
| Monospace | `{{text}}` |
| Line separator | `----` |
| Table header | `\|\|Header\|\|` |
| Table cell | `\|cell\|` |
| Inline image | `!filename.png\|width=600!` |
| Link | `[label\|url]` |
| Emoji | Write real characters: `✅` `❌` |

### Google Sheets Formatting

When updating Google Sheets:

1. **Read the sheet first** — check existing column headers, data format, and conventions before writing
2. **Match existing format exactly:**
   - If existing rows use `PASSED` / `FAILED` → use same (not `Pass`/`Fail` or `✅`/`❌`)
   - If dates are `DD/MM/YYYY` → don't write `YYYY-MM-DD`
   - If cells are Thai → write Thai; if English → write English
3. **Never overwrite existing data** without user confirmation
4. **Column mapping:** Always confirm which columns to update before writing — don't assume column positions
5. **Batch updates:** Collect all row changes, show as a table in chat, confirm with user, then write in one batch

### Common Formatting Mistakes (Don't Do These)

| Mistake | Result | Fix |
|---------|--------|-----|
| `\\u274c` (double backslash) | Shows literal `❌` text | Use real `❌` character |
| Bare `PROJ-123` in text | Jira auto-links to wrong ticket | Wrap: `{{PROJ-123}}` |
| v2 wiki markup on v3 endpoint | Format breaks | Match endpoint to markup type |
| Thai directly in JS file | Encoding corruption `±πÅ` | Escape to `\uXXXX` after stringify |
| Assumed column positions | Overwrites wrong data | Read sheet headers first |
| Mixed date formats | Inconsistent sheet | Match existing format |

---

## Anti-Hallucination Rules

These rules are non-negotiable:

1. **No evidence = no issue.** If you cannot point to a specific file, line number, or measurable error (console error, network error, screenshot of broken UI), do NOT report it as a bug.

2. **Code reference required.** Every bug must include the source file and line that causes or contributes to the problem.

3. **Reason required.** Every bug must explain WHY it is a bug — not just "this looks wrong" but a specific justification:
   - Contradicts a spec or requirement
   - Behavior differs from other parts of the same app
   - Console error or network error is logged
   - Accessibility violation per WCAG guidelines
   - CSS/logic values conflict with each other
   - Runtime exception is thrown

4. **Low confidence = quarantine.** If you're not sure something is a bug, put it in the "Needs Review" table. Never auto-open issues for Low confidence findings.

5. **No duplicate issues.** Before opening an issue, check if the same root cause is already covered by another finding. Deduplicate aggressively.

6. **Severity must be justified.** Don't inflate severity. A cosmetic issue is Low, not Medium. A minor UX annoyance is Medium, not High. Only mark Critical if the app is literally unusable.

## Severity Criteria

| Severity     | Criteria                                                                 |
|-------------|--------------------------------------------------------------------------|
| **Critical** | App unusable — crash, data loss, security vulnerability, blank page      |
| **High**     | Core feature broken — form submit fails, login broken, nav broken        |
| **Medium**   | Secondary feature issue — layout shift, responsive break, poor UX        |
| **Low**      | Cosmetic — typo, spacing, minor color, console warning                   |
