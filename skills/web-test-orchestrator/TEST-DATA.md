# Test Data Rules

**Constraint:** The agent MUST create test data itself. "No test data" is never a valid reason to skip a test case.

## How to Create Test Data

### 1. Form / Input Testing

Create data matching field types:

| Field Type | Example Data |
|------------|-------------|
| Email | `test-<timestamp>@example.com` |
| Phone | `0800000001` |
| Name | `Test User`, `ทดสอบ ระบบ` |
| Date | Today, past, future |
| Number | 0, 1, -1, boundary values, max |
| Text | Short, long (>255 chars), special chars, emoji, HTML tags |
| File upload | Create dummy file via Playwright (small PNG, PDF) |

### 2. CRUD Testing

If records must exist before testing:

1. Create record via UI first (create flow) — then test read/update/delete
2. If API exists — create data via API before test
3. If seed script exists — run seed before test

### 3. Role-Based Testing

If a role has no account:

1. Ask user: can we create a new account?
2. If yes — create via signup flow or admin panel
3. If no — note "Role X not tested — need account from admin" but **continue testing other roles. Never stop entirely.**

### 4. Empty State Testing

Empty pages ARE test targets:

1. Test empty state first — must render correctly
2. Create data — test populated state

### 5. Search / Filter Testing

Create diverse data first, then test search/filter.

## Priority Order for Getting Test Data

1. **Create via app UI** (best — tests create flow too)
2. **Create via API** (fast, skips UI validation)
3. **Run seed/fixture script** (if project has one)
4. **Ask user** — only when self-creation is truly impossible

## Absolute Prohibitions

- NEVER skip a test case because "no data"
- NEVER tell user "cannot test" without trying to create data first
- NEVER assume data is unimportant — every test case must run with real data
