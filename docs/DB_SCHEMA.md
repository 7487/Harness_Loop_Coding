# 数据库 Schema

> **维护方式**：运行 `/sync-context db` 从 MySQL MCP 自动同步，或手动维护。
> **最后同步**：未初始化

## 如何初始化

1. 复制 `.claude/settings.json.example` 为 `.claude/settings.json`，填写数据库连接信息
2. 运行 `/sync-context db`，Claude 会自动写入本文件
3. 或手动将建表 DDL 粘贴到下方

## 何时更新

- 新增/删除/修改表结构后，重新运行 `/sync-context db`
- 保持此文件与数据库实际 schema 同步，Claude 会优先读此文件而非直接查库

---

<!-- /sync-context 写入的内容从此处开始 -->
