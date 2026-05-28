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

### Option A: One-command install (recommended)

```bash
curl -sL https://raw.githubusercontent.com/Thitic9203/full-test-plugin/main/scripts/install.sh | bash
```

This clones the repo, symlinks the cache, and enables auto-update hooks.
After this, `git pull` = plugin updated automatically.

### Option B: Manual clone

```bash
git clone https://github.com/Thitic9203/full-test-plugin.git ~/.claude/plugins/src/full-test
cd ~/.claude/plugins/src/full-test
bash scripts/setup.sh
```

### Option C: Via Claude Code marketplace

```
/plugin marketplace add Thitic9203/full-test-plugin
/plugin install full-test@full-test-dev
```

### Required skills (install once)

```
/plugin marketplace add anthropics/skills
/plugin install document-skills@anthropics-skills

/plugin marketplace add lackeyjb/playwright-skill
/plugin install playwright-skill@playwright-skill

/plugin marketplace add Jeffallan/claude-skills
/plugin install fullstack-dev-skills@jeffallan-claude-skills
```

### Then restart Claude Code

> Filing bugs in GitHub requires `gh` CLI — the plugin will offer to install it for you.
> Filing bugs in Jira requires the Atlassian MCP plugin — the plugin will detect and fallback to JXA if unavailable.

### Updating

If installed via Option A or B:
```bash
cd ~/.claude/plugins/src/full-test && git pull
```
That's it — cache symlink means the plugin sees new files immediately.

## Usage

```
/full-test
```

The skill will ask for your target URL, test accounts, viewports, and test cases — then run all tests automatically, summarize bugs in a table, draft each one for your confirmation, and open issues for you.

## License

MIT
