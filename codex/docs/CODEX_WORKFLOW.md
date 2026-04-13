# Codex 工作流

Codex 版不依赖仓库内 slash command 自动注册。

建议直接这样用：
- 生成 PRD：让 Codex 读取 `AGENTS.md`、`docs/STATE.md`、`docs/TODO.md` 后产出 `docs/PRD.md`
- 拆 TODO：让 Codex 读取 `docs/PRD.md`、`docs/TDD.md`、`docs/TODO.md`、`docs/STATE.md` 后更新 TODO 与 STATE
- 执行 TODO：直接让 Codex 按 `AGENTS.md` 执行当前 TODO，或运行 `bash scripts/codex_loop.sh`
- 查看状态：让 Codex 只读 `docs/TODO.md`、`docs/STATE.md`、`docs/FEEDBACK.md` 和 `bug_fix/`

MCP 配置方式：
- `codex mcp list`
- `codex mcp add <name> --url <url>`
- `codex mcp add <name> -- <command> ...`
