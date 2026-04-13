# Claude Loop Template

> 从一句话想法到可运行代码的 AI 开发工作流框架。思考层 + 执行层，覆盖项目全生命周期。

---

## 这是什么

一套覆盖 **想法 → 设计 → 拆分 → 执行 → 反馈** 全链路的 AI Agent 工作流模板。

核心理念：**文件即状态，Slash Command 即工作流**。

- **思考层**：`/brainstorm` → `/plan`，从模糊想法生成结构化 PRD，再拆分为可执行 TODO
- **执行层**：`/execute` 交互执行 或 `claude_loop.sh` 自动循环，TDD 驱动逐个完成
- **反馈层**：`bug_fix/` 热修收件箱 + `FEEDBACK.md` 持续约束，形成闭环
- **可观测**：`/status` 随时查看进度，所有状态通过 Git 文件追踪，可审计、可回溯

## 冷启动一个项目

只需 3 步，从零开始：

```bash
# 1. 初始化（自动创建全部目录结构）
mkdir my_project
bash /path/to/claude-loop-template/init.sh my_project
cd my_project && git init

# 2. 编辑 CLAUDE.md 填写项目目标和技术栈

# 3. 启动 Claude Code，用一句话开始
claude
```

进入 Claude Code 后：

```
你: /brainstorm 我想做一个 XXX

Claude: 向你提问 → 探索方案 → 生成 PRD 草稿

你: 审核 PRD，改状态为 approved

你: /plan

Claude: 拆分 TODO → 写入 TODO.md + STATE.md

你: /execute（交互逐个执行）
    或 bash scripts/claude_loop.sh（自动循环）
```

**不需要手写 TODO、不需要手写 PRD、不需要提前规划任务拆分。** 全部由 AI 完成，你只需审核和确认。

---

## 工作流全景

```
┌─────────────────────────────────────────────────────────┐
│                     思考层（交互模式）                     │
│                                                         │
│  /brainstorm "想法"                                     │
│      │  交互式澄清 → 方案探索 → PRD 草稿                 │
│      ▼                                                  │
│  用户审核 PRD → approved                                 │
│      │                                                  │
│  /plan                                                  │
│      │  PRD → TDD 配对拆分 → TODO.md + STATE.md          │
│      ▼                                                  │
├─────────────────────────────────────────────────────────┤
│                     执行层                               │
│                                                         │
│  方式 A：/execute（交互模式，逐个确认）                    │
│  方式 B：bash scripts/claude_loop.sh（无人值守自动循环）   │
│                                                         │
│      ┌────────────────────────────┐                     │
│      │  每轮执行：                 │                     │
│      │  0. 扫 bug_fix/（最高优先） │                     │
│      │  1. 读 TODO/STATE/FEEDBACK │                     │
│      │  2. TDD: RED → GREEN       │                     │
│      │  3. 更新 STATE.md          │                     │
│      │  4. 标记完成               │                     │
│      └────────────────────────────┘                     │
│                                                         │
├─────────────────────────────────────────────────────────┤
│                     反馈层（随时）                        │
│                                                         │
│  /status ──→ 进度概览                                    │
│  bug_fix/*.md ──→ 热修，下轮最高优先级处理                 │
│  docs/FEEDBACK.md ──→ 持续约束，Agent 每轮遵守            │
└─────────────────────────────────────────────────────────┘
```

---

## Slash Commands

模板内置 5 个 slash command，Claude Code 启动时自动注册：

| 命令 | 用途 | 输入 | 输出 |
|------|------|------|------|
| `/brainstorm` | 从想法到 PRD | 一句话需求 | `docs/PRD.md`（draft） |
| `/plan` | 从 PRD 到 TODO | PRD（approved） | `docs/TODO.md` + `docs/STATE.md` |
| `/execute` | 逐个 TDD 执行 | TODO 列表 | 代码 + 测试 + 状态更新 |
| `/status` | 项目进度概览 | 无 | 结构化进度报告 |
| `/sync-context` | 同步 MCP 数据到本地缓存 | 无 / `db` / `api` / `kb` | `docs/DB_SCHEMA.md` 等 |

Skill 文件位于 `.claude/commands/`，可自行扩展。编写规范见 `docs/SKILL_TEMPLATE.md`。

---

## 快速开始

### 方式 A：新项目从零开始

```bash
# 用 init.sh 初始化到新目录（自动创建结构）
mkdir my_project
bash /path/to/claude-loop-template/init.sh my_project
cd my_project && git init

# 编辑 CLAUDE.md → 填写项目目标、技术栈
# 然后 claude 进入交互模式，/brainstorm 开始
```

### 方式 B：已有项目接入

```bash
cd your_existing_project

# 一键初始化（不覆盖已有文件）
bash /path/to/claude-loop-template/init.sh .
```

或手动复制：

```bash
cp -r /path/to/claude-loop-template/scripts/ scripts/
cp -r /path/to/claude-loop-template/prompts/ prompts/
cp -r /path/to/claude-loop-template/docs/ docs/
cp -r /path/to/claude-loop-template/.claude/commands/ .claude/commands/
cp /path/to/claude-loop-template/.claude/settings.json.example .claude/settings.json.example
cp /path/to/claude-loop-template/CLAUDE.md .
cp /path/to/claude-loop-template/agent.md .
cp /path/to/claude-loop-template/AGENTS.md .
mkdir -p bug_fix/resolved .claude/out .claude/logs

# 编辑 CLAUDE.md 填写你的项目信息
```

---

## 日常使用

### 交互模式（推荐起步）

```bash
cd my_project && claude
# /brainstorm, /plan, /execute, /status 随时可用
```

### 自动循环（无人值守）

```bash
bash scripts/claude_loop.sh            # 自动逐个执行
bash scripts/claude_loop.sh T101       # 指定某个 TODO
MAX_ITERS=5 bash scripts/claude_loop.sh  # 限制轮数
```

### 提交反馈

编辑 `docs/FEEDBACK.md`，在 Open 段落追加：

```markdown
### F001 — 简短标题
- **status**: open
- **date**: YYYY-MM-DD
- **category**: code-quality | docs | deps | workflow | bug | other
- **description**: 具体问题
- **action**: 要求 Agent 怎么做
```

### 报告 Bug

在 `bug_fix/` 下创建 `.md` 文件，下轮会被最高优先级处理：

```markdown
# 报错
[完整错误日志]

# 问题分析
[你的分析]

# 修复建议
[建议的修法]

# 如何验证
[验证方法]
```

### 管理输入型文档

**命名规范**：`YYYYMMDD_主题关键词.md`（如 `20260327_kickoff.md`）

每个文档头部有生命周期标记，控制 AI 是否读取：

```html
<!--
status: active      ← AI 按需读取（文件名/tags 相关时）
date: 2026-03-27
tags: [auth, login]
-->
```

| status | 含义 | AI 行为 |
|--------|------|---------|
| `active` | 当前有效 | 按相关性读取 |
| `reference` | 已完成但保留参考 | 仅在被明确提及时读取 |
| `done` | 已过期 | **自动移入 `_archive/`**，不再消耗 token |

**你只需做一件事**：文档用完后把 `status` 改为 `done`，下次执行任意 slash command 时 AI 会自动归档它。

### 查看执行结果

```bash
ls -t .claude/out/*.json | head -5       # 最近输出
cat .claude/logs/20260314_T101.log       # 某轮日志
# 批量查看摘要
for f in .claude/out/*.json; do
  jq -r '"[\(.active_todo)] \(.run_status) - \(.summary)"' "$f" 2>/dev/null
done
```

---

## 文件职责速查

### 规范与配置

| 文件 | 职责 |
|------|------|
| `CLAUDE.md` | 项目唯一规范源，Claude Code / claude -p 自动加载 |
| `agent.md` | Codex 兼容垫片 |
| `AGENTS.md` | Codex 入口，指向 CLAUDE.md |
| `docs/RULES.md` | 语言特定编码规则参考库 |
| `docs/TDD.md` | TDD 流程规范 |
| `docs/SKILL_TEMPLATE.md` | Skill 编写模板 |

### 状态与任务

| 文件 | 职责 |
|------|------|
| `docs/PRD.md` | PRD 模板，新功能设计先行 |
| `docs/TODO.md` | 任务清单，唯一任务源 |
| `docs/STATE.md` | 进度追踪，每轮更新 |
| `docs/FEEDBACK.md` | 反馈日志，open 条目为强制约束 |
| `docs/MEMORY.md` | 项目级经验沉淀库 |
| `docs/DB_SCHEMA.md` | 数据库 schema 缓存（MySQL MCP 同步） |
| `docs/API_SPEC.md` | YAPI 接口文档缓存（YAPI MCP 同步） |
| `docs/KB.md` | 团队知识库缓存（knowledge-base MCP 同步） |

### 输入型文档

| 目录 | 职责 | 联动命令 |
|------|------|----------|
| `docs/meetings/` | 会议记录，按 `YYYYMMDD_主题.md` 命名 | `/brainstorm` |
| `docs/design/` | 技术/架构设计文档 | `/plan`、`/execute` |
| `docs/research/` | 调研笔记、竞品分析 | `/brainstorm` |
| `docs/specs/` | 原始需求规格、外部文档整理 | `/brainstorm`、`/plan` |

每个目录下有 `_template.md`（永远跳过，不读取）；过期文档自动归档到 `_archive/`。
文档头部 `status: active / reference / done` 控制是否被 AI 读取，详见"管理输入型文档"。

### 执行基础设施

| 文件 | 职责 |
|------|------|
| `scripts/claude_loop.sh` | 循环执行脚本 |
| `prompts/claude_loop_prompt.txt` | 循环 prompt 模板 |
| `bug_fix/*.md` | Bug 热修收件箱 |
| `bug_fix/resolved/` | Bug 归档 |
| `.claude/out/` | 每轮输出 JSON |
| `.claude/logs/` | 每轮执行日志 |

### Slash Commands

| 文件 | 职责 |
|------|------|
| `.claude/commands/brainstorm.md` | `/brainstorm` — 头脑风暴生成 PRD |
| `.claude/commands/plan.md` | `/plan` — PRD 拆分为 TODO |
| `.claude/commands/execute.md` | `/execute` — TDD 逐个执行 TODO |
| `.claude/commands/status.md` | `/status` — 项目进度概览 |
| `.claude/commands/sync-context.md` | `/sync-context` — 同步 MCP 数据到本地缓存 |
| `.claude/settings.json.example` | MCP 服务器配置模板（复制为 settings.json 使用） |

---

## 开发流程

### 新功能：完整流程

```
/brainstorm → PRD(draft) → 审核 → PRD(approved) → /plan → TODO → /execute → 完成
```

每一步都有对应的 slash command 驱动，也可以手动编辑文件走传统流程。

### Bug 修复：快速通道

```
bug_fix/xxx.md → /execute（或 claude_loop.sh）→ 自动优先处理 → 归档到 resolved/
```

Bug 修复可跳过 PRD，但仍需先写测试复现 → 修复 → 验证通过。

---

## 模型兼容性

本模板的工作流对模型能力有明确要求。**核心约束**：循环模式（`claude -p`）要求模型在无人值守下严格输出结构化 JSON、遵循 5 步协议、正确操作文件——这属于 **harness 级别的能力**，不是所有模型都能可靠做到。

### 推荐模型

| 模式 | 推荐 | 也可以 | 说明 |
|------|------|--------|------|
| 循环模式 `claude -p` | **Sonnet 4.6** | Opus 4.6、Sonnet 4.5 | Sonnet 4.6 性价比最优；Opus 最稳但 token 消耗大；Sonnet 4.5 可用，复杂任务偶有丢步骤 |
| 交互模式 `/brainstorm` 等 | **Sonnet 4.5+** | Opus 4.6、Haiku 4.5 | 有人在回路中容错高，Sonnet 4.5 即可胜任，Haiku 4.5 简单任务可用 |
| Codex 模式 `agent.md` | **OpenAI Codex** | — | 通过 agent.md 垫片兼容 |

**省钱建议**：日常开发用 **Sonnet 4.5 / 4.6** 跑循环，遇到复杂多文件重构再切 Opus。交互模式下 Sonnet 4.5 完全够用。

### 模型能力要求

循环模式对模型有以下硬性要求（不满足会导致循环卡死或产出无效）：

1. **结构化输出**：每轮必须输出符合 schema 的 JSON，不夹带 markdown 或额外文本
2. **多步骤指令遵循**：STEP 0-5 协议中有条件分支（如 bug_fix/ 存在时优先处理），模型需准确执行
3. **文件操作可靠性**：正确读取 TODO/STATE/FEEDBACK，写回时不破坏格式
4. **约束遵守**：FEEDBACK open 条目的 action 是强制约束，模型不能忽略
5. **单任务边界**：不合并多个 TODO、不越界修改，这对模型自律性要求高

交互模式（slash commands）容错更高——有人在回路中，模型犯错可以纠正。

### 不推荐

- **Haiku 4.5 跑循环模式**：JSON 输出不够稳定，多步骤指令容易丢步骤，交互模式下可用
- **非 Claude 模型直接跑 `claude_loop.sh`**：脚本硬编码了 `claude -p`，且 prompt 针对 Claude 优化
- 如果要适配其他模型，需要修改 `scripts/claude_loop.sh` 中的调用命令和 `prompts/claude_loop_prompt.txt` 中的 prompt 格式

### Token 优化（可选）

推荐使用 [RTK (Rust Token Killer)](https://github.com/rtk-ai/rtk) 减少 token 消耗。RTK 是一个本地 CLI 代理，在 Bash 命令输出到达 LLM 上下文前做压缩过滤，实测平均压缩率 89%。

```bash
# 安装
curl -fsSL https://rtk-ai.app/install.sh | bash

# 配置 Claude Code hook（一次性）
rtk init -g

# 查看节省了多少 token
rtk gain
```

**工作原理**：通过 Claude Code 的 PreToolUse hook，将 `git status` 等命令透明重写为 `rtk git status`，输出经压缩后再返回给 Claude。本地运行、开源（MIT）、零依赖、可随时卸载。

**适用范围**：

| 场景 | 收益 |
|------|------|
| 交互模式（频繁 Bash 命令） | 高，token 节省显著 |
| 循环模式（TODO 涉及大量 git/npm/测试命令） | 中等 |
| 循环模式（以文件读写为主） | 有限，Read/Grep/Glob 等内置工具绕过 hook |

> **注意**：RTK 是可选优化，模板不强依赖它。项目较年轻（2026-01 创建），长期维护性待观察。

---

## MCP 集成（MySQL / YAPI / 团队知识库）

模板内置对三个 MCP 服务器的支持，覆盖后端 AI-Coding 的核心上下文需求。

### 快速配置

```bash
# 1. 复制配置模板
cp .claude/settings.json.example .claude/settings.json

# 2. 编辑 settings.json，填写真实的 DB 连接信息和 YAPI Token
#    （此文件已在 .gitignore 中，不会提交）

# 3. 在 CLAUDE.md 中填写 yapi_project_ids

# 4. 同步上下文到本地缓存文件（此后 Claude 读文件，不重复调 MCP）
/sync-context
```

### 三个 MCP 的用途

| MCP | 用途 | 配置项 |
|-----|------|--------|
| `project-mysql` | 查询 DB 结构和数据，生成 schema 缓存 | DB_HOST / USER / PASSWORD / DATABASE |
| `yapi-mcp` | 获取 YAPI 接口文档，生成本地 API 缓存 | URL, Bearer Token |
| `knowledge-base` | 读写团队知识库（存储在 docs/memory/） | KB_STORAGE_DIR |

### Token 节省策略

MCP 工具调用成本高（schema dump 可达数千 token）。本模板采用 **静态优先** 策略：

```
/sync-context（一次）
    ↓ 写入本地文件
docs/DB_SCHEMA.md   ← Claude 读这里，而不是每次调 MySQL MCP
docs/API_SPEC.md    ← Claude 读这里，而不是每次调 YAPI MCP
docs/KB.md          ← Claude 读这里，而不是每次调 knowledge-base MCP
```

只有以下情况才直接调 MCP：
- 本地缓存文件不存在（首次）
- 需要执行实际 SQL 查询（非结构查询）
- 明确知道 schema/接口有更新

### 本地缓存文件

| 文件 | 来源 | 更新方式 |
|------|------|----------|
| `docs/DB_SCHEMA.md` | MySQL schema dump | `/sync-context db` 或手动维护 |
| `docs/API_SPEC.md` | YAPI 接口文档 | `/sync-context api` 或手动维护 |
| `docs/KB.md` | 团队知识库 | `/sync-context kb` 或手动添加 |

---

## 配置参数

| 变量 | 默认值 | 说明 |
|---|---|---|
| `MAX_ITERS` | 999999 | 最大执行轮数 |
| `RETRY_DELAY` | 10 | 失败重试间隔（秒） |
| `PROMPT_TEMPLATE` | prompts/claude_loop_prompt.txt | prompt 模板路径 |

---

## 定制指南

### CLAUDE.md 是核心

模板中的 `CLAUDE.md` 包含通用骨架，你需要根据项目定制：

1. **项目目标** — 替换为你的项目描述
2. **项目概况** — 填写技术栈、关键路径
3. **编码规范** — 根据项目调整
   - 代码风格：参考 `docs/RULES.md` 选择语言特定规则
   - 安全/性能/Git 规则：已内置通用规则，按需调整
4. **修改边界** — 定义哪些目录可改、哪些谨慎、哪些禁止
5. **实现优先级** — 定义你的 Phase 推进顺序

### 扩展 Slash Commands

在 `.claude/commands/` 下新建 `.md` 文件即可注册新 slash command。编写规范见 `docs/SKILL_TEMPLATE.md`。

### 循环脚本

`scripts/claude_loop.sh` 和 `prompts/claude_loop_prompt.txt` 通常无需修改。如需定制 prompt，编辑 `claude_loop_prompt.txt` 中的 STEP 3 部分。

---

## 注意事项

1. **TODO 编号全局唯一**，不要跨 Phase 重复
2. **不要手动编辑 STATE.md**，除非纠正 Agent 的错误记录
3. **FEEDBACK open 条目是强制约束**，Agent 无法忽略；不再需要时请手动移到 Resolved
4. **bug_fix/ 下的文件会被优先处理**，不想被处理就别放这个目录
5. **claude_loop.sh 无状态**，随时 Ctrl+C，下次继续从第一个未完成 TODO 开始
6. **每轮执行隔离**，`claude -p` 每次全新会话，不保留上一轮对话上下文
7. **.claude/ 目录中 out/ 和 logs/ 建议加入 .gitignore**，commands/ 应提交
