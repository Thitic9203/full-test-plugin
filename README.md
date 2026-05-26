# Full-Test Orchestrator

One command. Full coverage. Real bug reports.

Type `/full-test` and Claude will test your entire web app — every route, every role, every viewport — then file evidence-backed bugs directly in GitHub or Jira.

## Why Use This

- **One command does everything** — no test scripts to write, no tools to switch between, no reports to assemble
- **Full coverage** — every route, role, module, viewport (Desktop/Tablet/Mobile), and mode (light/dark)
- **Evidence-based bugs only** — every bug must have a source file, line number, and clear reasoning. No evidence = no bug filed
- **Files bugs for you** — drafts each bug in chat for your review, then opens issues in GitHub and/or Jira with severity, screenshots, and steps to reproduce
- **Works with any web app** — framework-agnostic. Analyzes the source code of whatever repo you're working in

## Installation

**1. Install required skills:**

```
/plugin marketplace add anthropics/skills
/plugin install document-skills@anthropics-skills

/plugin marketplace add lackeyjb/playwright-skill
/plugin install playwright-skill@playwright-skill

/plugin marketplace add Jeffallan/claude-skills
/plugin install fullstack-dev-skills@jeffallan-claude-skills
```

**2. Install this plugin:**

```
/plugin marketplace add Thitic9203/full-test-plugin
/plugin install full-test@full-test-dev
```

**3. Restart Claude Code**

> Filing bugs in GitHub requires `gh` CLI (`brew install gh` then `gh auth login`)
> Filing bugs in Jira requires the Atlassian MCP plugin

## Usage

```
/full-test
```

The skill will ask for your target URL, test accounts, viewports, and test cases — then run all tests automatically, summarize bugs in a table, draft each one for your confirmation, and open issues for you.

## License

MIT
