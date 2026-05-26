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

10. **Ask user:**
    - "Test matrix + test cases ทั้งหมดนี้ถูกต้องไหม?"
    - "ต้องการทดสอบ Viewports ไหนบ้าง? (default: Desktop 1920x1080, Tablet 768x1024, Mobile 375x667)"
    - "เปิด issues ที่ GitHub repo ไหน? (format: owner/repo)"

11. **If discovery finds nothing** for any category → ask user directly instead of guessing.

**Do NOT proceed until user confirms both test cases AND test matrix.**

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
