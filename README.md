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

### One-command install (recommended)

```bash
curl -sL https://raw.githubusercontent.com/Thitic9203/full-test-plugin/main/scripts/install.sh | bash
```

This installs **everything in one step**: required skills (document-skills, playwright-skill, fullstack-dev-skills) + full-test plugin + cache symlinks + auto-update hooks. Then restart Claude Code.

### Alternative: Manual clone

```bash
git clone https://github.com/Thitic9203/full-test-plugin.git ~/.claude/plugins/src/full-test
cd ~/.claude/plugins/src/full-test
bash scripts/setup.sh
```

> Filing bugs in GitHub requires `gh` CLI — the plugin will offer to install it for you.
> Filing bugs in Jira requires the Atlassian MCP plugin — the plugin will detect and fallback to JXA if unavailable.

### Updating

```bash
cd ~/.claude/plugins/src/full-test && git pull
```
Cache symlink = plugin updated instantly. No reinstall needed.

## Usage

```
/full-test
```

The skill will ask for your target URL, test accounts, viewports, and test cases — then run all tests automatically, summarize bugs in a table, draft each one for your confirmation, and open issues for you.

## License

MIT
