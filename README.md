# Full-Test Orchestrator

พิมพ์ `/full-test` แค่คำสั่งเดียว — Claude จะทดสอบเว็บให้ครบทุกมิติแล้วเปิดบัคให้อัตโนมัติ

## ทำไมต้องใช้

- **ครบจบในคำสั่งเดียว** — ไม่ต้องเขียน test script เอง ไม่ต้องสลับ tool ไม่ต้องจัดการ report
- **ครอบคลุมทุกมุม** — ทุก route, ทุก role, ทุก module, ทุก viewport (Desktop/Tablet/Mobile), ทุก mode (light/dark)
- **หาบัคจากโค้ดจริง ไม่มโน** — ทุกบัคต้องมีหลักฐาน: ไฟล์ บรรทัด เหตุผล ถ้าไม่มีหลักฐานจะไม่เปิดบัค
- **เปิดบัคให้เลย** — ร่าง draft ให้ดูก่อน confirm แล้วก็เปิดใน GitHub Issues หรือ Jira ให้ พร้อม severity, screenshot, steps to reproduce ครบ
- **ใช้ได้กับเว็บอะไรก็ได้** — ไม่ผูกกับ framework หรือ project ใด วิเคราะห์จาก source code ของ repo ที่ทำงานอยู่

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
