# Full-Test Orchestrator

Generic web testing orchestrator plugin for Claude Code — runs 4 testing skills sequentially, consolidates findings, and opens bug reports in GitHub Issues and/or Jira with evidence-backed reports.

## What It Does

```
/full-test
  Phase 0: Discovery     — Analyze source code, build test matrix, user confirms
  Phase 1: Recon          — webapp-testing: screenshots, console errors, broken assets
  Phase 2: Cross-platform — playwright-skill: responsive testing across viewports
  Phase 3: Strategy       — test-master: coverage gaps, severity analysis
  Phase 4: Deep E2E       — playwright-expert: user flows, race conditions
  Phase 5: Consolidate    — Deduplicate, split Confirmed vs Needs Review
  Phase 6: Bug Reports    — Draft in chat → user confirms → open in GitHub/Jira
```

## Prerequisites

| # | Requirement | Install |
|---|-------------|---------|
| 1 | Claude Code | Must already have |
| 2 | `gh` CLI (authenticated) | `brew install gh` then `gh auth login` |
| 3 | Atlassian MCP plugin | Only if opening bugs in Jira — configure in Claude Code MCP settings |

### Required Skills (install all 4)

**webapp-testing** (Anthropic official):
```
/plugin marketplace add anthropics/skills
/plugin install document-skills@anthropics-skills
```

**playwright-skill** (lackeyjb):
```
/plugin marketplace add lackeyjb/playwright-skill
/plugin install playwright-skill@playwright-skill
```

**test-master + playwright-expert** (Jeffallan):
```
/plugin marketplace add Jeffallan/claude-skills
/plugin install fullstack-dev-skills@jeffallan-claude-skills
```

## Installation

```
/plugin marketplace add Thitic9203/full-test-plugin
/plugin install full-test@full-test-dev
```

Restart Claude Code.

## Usage

```
/full-test
```

The skill will:
1. Discover routes, roles, modules, and modes from your source code
2. Ask you to confirm the test matrix and viewports
3. Run 4 testing skills in sequence
4. Show a consolidated bug table with severity and confidence ratings
5. Draft every bug in chat for your review
6. After confirmation, open issues in GitHub and/or Jira

## Bug Report Format

Every bug includes:
- **Title:** `[Severity] Module — description`
- **Steps to Reproduce**
- **Expected vs Actual Behavior**
- **Evidence & Root Cause:** file path, line number, code snippet, and reasoning
- **Confidence:** High / Medium / Low
- **Environment:** viewport, browser, URL
- **Screenshot** (when available)

## Anti-Hallucination Rules

- No evidence = no issue (must have file path + measurable error)
- Low confidence bugs are quarantined in "Needs Review" — user decides
- Every bug must explain WHY it's a bug, not just "this looks wrong"
- Severity is never inflated

## License

MIT
