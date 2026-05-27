# Formatting Rules (Jira & Google Sheets)

Production-tested rules — follow strictly to avoid re-posts and encoding corruption.

## Jira Comment Format

### Step 1: Lock Format Before Writing

Decide format at session start. **Cannot switch mid-session.**

| Bug Type | API Endpoint | Markup | When to Use |
|----------|-------------|--------|-------------|
| **API / Logic bug** | v3 (`addCommentToJiraIssue` with `contentFormat: markdown`) | ADF (JSON) | No screenshots needed |
| **FE / UI bug** | v2 (`/rest/api/2/issue/<KEY>/comment`) | Wiki Markup | Screenshots must be inline |

### Step 2: Correct Markup Per Format

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
Use `addCommentToJiraIssue` with `contentFormat: markdown` — write Markdown, Jira converts automatically.

### Step 3: Pre-Post Validation Checklist

Before posting ANY Jira comment, verify ALL:

- [ ] Emoji `❌` `✅` are **real Unicode** — NOT `\\u274c` (double backslash = literal text)
- [ ] No bare ticket keys like `PROJ-123` — wrap in `{{PROJ-123}}`
- [ ] No Thai particles (ครับ/ค่ะ) — use neutral language
- [ ] Endpoint matches format (v2 = wiki, v3 = ADF)
- [ ] Screenshots uploaded as attachments BEFORE `!filename.png|width=600!`

## Thai Text Encoding (Critical for Jira)

If posting via JXA/JavaScript:

1. Generate body with real Thai text first
2. `JSON.stringify` BEFORE escaping non-ASCII
3. Escape non-ASCII AFTER stringify:
   ```javascript
   const safe = bodyStr.replace(/[^\x00-\x7F]/g, c =>
     '\\u' + c.charCodeAt(0).toString(16).padStart(4, '0')
   );
   ```
4. Save as ASCII — verify: `!/[^\x00-\x7F]/.test(content)`
5. Dry-run: decode `\uXXXX` back, check emoji + Thai render correctly

**Order matters:** Escape Thai BEFORE stringify = broken. Thai directly in JS = encoding corruption.

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

## Google Sheets Formatting

1. **Read the sheet first** — check headers, format, conventions before writing
2. **Match existing format exactly:**
   - Existing `PASSED` / `FAILED` → use same (not `Pass`/`Fail` or `✅`/`❌`)
   - Dates `DD/MM/YYYY` → don't write `YYYY-MM-DD`
   - Thai cells → write Thai; English → write English
3. **Never overwrite** without user confirmation
4. **Confirm column mapping** before writing — don't assume positions
5. **Batch updates:** Collect all changes, show table in chat, confirm, write once

## Common Formatting Mistakes

| Mistake | Result | Fix |
|---------|--------|-----|
| `\\u274c` (double backslash) | Shows literal `❌` text | Use real `❌` character |
| Bare `PROJ-123` in text | Auto-links to wrong ticket | Wrap: `{{PROJ-123}}` |
| v2 wiki on v3 endpoint | Format breaks | Match endpoint to markup |
| Thai directly in JS file | Encoding corruption | Escape to `\uXXXX` after stringify |
| Assumed column positions | Overwrites wrong data | Read sheet headers first |
| Mixed date formats | Inconsistent sheet | Match existing format |
