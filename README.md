# Full-Test Orchestrator

One command. Full coverage. Real bug reports.

Type `/full-test` and Claude will test your entire web app — every route, every role, every viewport — then file evidence-backed bugs directly in GitHub or Jira.

## Why Use This

- **One command does everything** — no test scripts to write, no tools to switch between, no reports to assemble
- **Full coverage** — every route, role, module, viewport (Desktop/Tablet/Mobile), and mode (light/dark)
- **Evidence-based bugs only** — every bug must have a source file, line number, and clear reasoning. No evidence = no bug filed
- **Files bugs for you** — drafts each bug in chat for your review, then opens issues in GitHub and/or Jira with severity, screenshots, and steps to reproduce
- **Works with any web app** — framework-agnostic. Analyzes the source code of whatever repo you're working in

## Quick Start

### Install (ครั้งเดียว)

เปิด terminal แล้วรัน:

```bash
curl -sL https://raw.githubusercontent.com/Thitic9203/full-test-plugin/main/scripts/install.sh | bash
```

จากนั้น restart Claude Code

### ใช้งาน

เปิด Claude Code แล้วรัน:

```
/full-test
```

ครั้งแรก skill จะถามข้อมูลโปรเจกต์ทีละข้อแล้วสร้าง config ให้อัตโนมัติ

### อัปเดต (ทุกครั้งที่มีเวอร์ชันใหม่)

เปิด terminal แล้วรัน:

```bash
cd ~/.claude/plugins/src/full-test && git pull
```

แค่นี้ ไม่ต้องรัน reinstall หรือคำสั่งอื่นเพิ่ม

> Filing bugs in GitHub requires `gh` CLI — the plugin will offer to install it for you.
> Filing bugs in Jira requires the Atlassian MCP plugin — the plugin will detect and fallback to JXA if unavailable.

## License

MIT
