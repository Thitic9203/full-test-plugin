# Anti-Hallucination Rules & Falsification Protocol

These rules are non-negotiable constraints the agent carries at all times.

## Core Rules

1. **No evidence = no issue.** Cannot point to a specific file, line, or measurable error (console error, network error, broken UI screenshot)? Do NOT report it as a bug.

2. **Code reference required.** Every bug must include the source file and line that causes or contributes to the problem.

3. **Reason required.** Every bug must explain WHY it is a bug — not "this looks wrong" but specific justification:
   - Contradicts a spec or requirement
   - Behavior differs from other parts of the same app
   - Console error or network error is logged
   - Accessibility violation per WCAG guidelines
   - CSS/logic values conflict with each other
   - Runtime exception is thrown

4. **Low confidence = quarantine.** Not sure something is a bug? → "Needs Review" table. Never auto-open issues for Needs Review findings.

5. **No duplicate issues.** Before opening, check if same root cause already covered. Deduplicate aggressively.

6. **Severity must be justified.** Don't inflate severity. See SEVERITY.md for criteria.

## Falsification Protocol (Phase 5)

Before confirming any finding as a bug, the agent MUST attempt to disprove it:

### Step 1: Challenge the Finding

For each finding, ask:
- "Could this be intentional design?"
- "Does this behavior match other parts of the app?"
- "Am I comparing against the right expectation?"

### Step 2: Disproof Attempt

Run at least ONE disproof test:

| Finding Type | Disproof Method |
|-------------|----------------|
| Visual bug | Check other pages — is the same pattern used intentionally elsewhere? |
| Console error | Is this error caught/handled upstream? Does it affect user experience? |
| Layout break | Check the design — is this a deliberate responsive behavior? |
| Missing element | Check other roles/states — is this conditional by design? |
| Form issue | Check validation rules in code — is the behavior defined? |

### Step 3: Classify

- **Disproof failed** (bug survived) → Confirmed, open issue
- **Disproof succeeded** (not a bug) → Drop silently
- **Inconclusive** → Needs Review table with honest note about what you tried

### The Self-Check

After falsification, ask: "If the developer who wrote this code saw my bug report, would they agree it's a bug or say it's working as intended?"

If the answer is likely "working as intended" → Needs Review, not Confirmed.

## AFK-Ready Bug Descriptions

Write bug reports that remain useful even if the codebase changes before someone fixes them:

### Do

- Describe **behavior**: "Login form submits even when email field is empty"
- Describe **user impact**: "Users can submit invalid data, causing server-side errors"
- Include **reproduction steps** that work regardless of code structure
- Reference **file:line** as supplementary info, not the primary description

### Don't

- Write bugs that ONLY reference file:line with no behavioral description
- Assume the file/line will still be correct when someone reads the bug
- Use internal variable names as the primary bug title
- Describe implementation details instead of user-facing behavior

### Template

```
Title: [Severity] [Module] — [Behavioral description]

What happens: [Observable behavior from user perspective]
What should happen: [Expected behavior]
User impact: [Who is affected and how]

Steps to Reproduce:
1. [User action — not code path]
2. [User action]
3. [Observation]

Code Reference (supplementary):
- File: [path:line]
- Relevant code: [snippet]
- Root cause: [why the code produces this behavior]
```
