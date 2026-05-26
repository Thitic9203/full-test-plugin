# Full-Test Orchestrator

Generic web testing plugin for Claude Code — ทดสอบเว็บครบทุกมิติแล้วเปิดบัคใน GitHub/Jira ให้อัตโนมัติ

## Installation

**1. ติดตั้ง required skills:**

```
/plugin marketplace add anthropics/skills
/plugin install document-skills@anthropics-skills

/plugin marketplace add lackeyjb/playwright-skill
/plugin install playwright-skill@playwright-skill

/plugin marketplace add Jeffallan/claude-skills
/plugin install fullstack-dev-skills@jeffallan-claude-skills
```

**2. ติดตั้ง plugin นี้:**

```
/plugin marketplace add Thitic9203/full-test-plugin
/plugin install full-test@full-test-dev
```

**3. Restart Claude Code**

> เปิดบัคใน GitHub ต้องมี `gh` CLI (`brew install gh` → `gh auth login`)
> เปิดบัคใน Jira ต้องมี Atlassian MCP plugin

## Usage

```
/full-test
```

Skill จะถาม URL, test accounts, viewports, test cases แล้วรันเทสให้ทั้งหมด — สรุปบัคเป็นตาราง → ร่าง draft ให้ confirm → เปิด issues ให้

## License

MIT
