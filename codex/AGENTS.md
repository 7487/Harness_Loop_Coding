# AGENTS

这是 Codex 版模板。Codex 会自动读取本文件作为项目规范入口。

执行前请阅读：
- `docs/TODO.md`
- `docs/STATE.md`
- `docs/FEEDBACK.md`
- `docs/MEMORY.md`

项目初始化后请补充：
- 项目目标
- 技术栈
- 编码规则

工作流约定：
- `bug_fix/` 下未归档的 `.md` 文件优先于普通 TODO
- 每轮只处理一个当前任务
- 只有任务真实完成时才勾选 `docs/TODO.md`
- 每轮结束必须更新 `docs/STATE.md`
- 循环执行入口是 `scripts/codex_loop.sh`
