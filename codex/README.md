# Codex Loop Template

面向 Codex CLI 的文件驱动工作流模板。

关键入口：
- 规范入口：`AGENTS.md`
- 初始化脚本：`init.sh`
- 循环执行：`scripts/codex_loop.sh`
- 工作流说明：`docs/CODEX_WORKFLOW.md`

MCP 通过全局命令配置：
- `codex mcp list`
- `codex mcp add <name> --url <url>`
- `codex mcp add <name> -- <command> ...`
