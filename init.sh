#!/usr/bin/env bash
set -euo pipefail
#
# 一键初始化：将 claude-loop 工作流注入到已有项目中。
#
# 用法：
#   bash /path/to/claude-loop-template/init.sh /path/to/your_project
#   bash /path/to/claude-loop-template/init.sh .    # 当前目录
#
# 行为：
#   - 在目标项目中创建工作流目录结构
#   - 复制脚本和 prompt 模板（不覆盖已有文件）
#   - 复制文档模板（不覆盖已有文件）
#   - 提示用户编辑 CLAUDE.md

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-.}"

if [[ ! -d "${TARGET_DIR}" ]]; then
  echo "Target directory does not exist: ${TARGET_DIR}"
  exit 1
fi

TARGET_DIR="$(cd "${TARGET_DIR}" && pwd)"
echo "Initializing claude-loop workflow in: ${TARGET_DIR}"

# 创建目录结构
mkdir -p "${TARGET_DIR}"/{docs,docs/meetings,docs/design,docs/research,docs/specs,scripts,prompts,bug_fix/resolved,.claude/out,.claude/logs,.claude/commands}

# 复制文件（不覆盖已有）
copy_if_not_exists() {
  local src="$1"
  local dst="$2"
  if [[ -f "${dst}" ]]; then
    echo "  SKIP (exists): ${dst#${TARGET_DIR}/}"
  else
    cp "${src}" "${dst}"
    echo "  COPY: ${dst#${TARGET_DIR}/}"
  fi
}

echo ""
echo "Copying workflow files..."

# 核心规范文件
copy_if_not_exists "${TEMPLATE_DIR}/CLAUDE.md" "${TARGET_DIR}/CLAUDE.md"
copy_if_not_exists "${TEMPLATE_DIR}/agent.md" "${TARGET_DIR}/agent.md"
copy_if_not_exists "${TEMPLATE_DIR}/AGENTS.md" "${TARGET_DIR}/AGENTS.md"

# docs
copy_if_not_exists "${TEMPLATE_DIR}/docs/TODO.md" "${TARGET_DIR}/docs/TODO.md"
copy_if_not_exists "${TEMPLATE_DIR}/docs/STATE.md" "${TARGET_DIR}/docs/STATE.md"
copy_if_not_exists "${TEMPLATE_DIR}/docs/FEEDBACK.md" "${TARGET_DIR}/docs/FEEDBACK.md"
copy_if_not_exists "${TEMPLATE_DIR}/docs/MEMORY.md" "${TARGET_DIR}/docs/MEMORY.md"
copy_if_not_exists "${TEMPLATE_DIR}/docs/PRD.md" "${TARGET_DIR}/docs/PRD.md"
copy_if_not_exists "${TEMPLATE_DIR}/docs/TDD.md" "${TARGET_DIR}/docs/TDD.md"
copy_if_not_exists "${TEMPLATE_DIR}/docs/RULES.md" "${TARGET_DIR}/docs/RULES.md"
copy_if_not_exists "${TEMPLATE_DIR}/docs/SKILL_TEMPLATE.md" "${TARGET_DIR}/docs/SKILL_TEMPLATE.md"
copy_if_not_exists "${TEMPLATE_DIR}/docs/DB_SCHEMA.md" "${TARGET_DIR}/docs/DB_SCHEMA.md"
copy_if_not_exists "${TEMPLATE_DIR}/docs/API_SPEC.md" "${TARGET_DIR}/docs/API_SPEC.md"
copy_if_not_exists "${TEMPLATE_DIR}/docs/KB.md" "${TARGET_DIR}/docs/KB.md"

# scripts & prompts
copy_if_not_exists "${TEMPLATE_DIR}/scripts/claude_loop.sh" "${TARGET_DIR}/scripts/claude_loop.sh"
copy_if_not_exists "${TEMPLATE_DIR}/prompts/claude_loop_prompt.txt" "${TARGET_DIR}/prompts/claude_loop_prompt.txt"

# slash commands (skills)
for cmd_file in "${TEMPLATE_DIR}"/.claude/commands/*.md; do
  if [[ -f "${cmd_file}" ]]; then
    cmd_name="$(basename "${cmd_file}")"
    copy_if_not_exists "${cmd_file}" "${TARGET_DIR}/.claude/commands/${cmd_name}"
  fi
done

# 输入型文档模板
copy_if_not_exists "${TEMPLATE_DIR}/docs/meetings/_template.md" "${TARGET_DIR}/docs/meetings/_template.md"
copy_if_not_exists "${TEMPLATE_DIR}/docs/design/_template.md" "${TARGET_DIR}/docs/design/_template.md"
copy_if_not_exists "${TEMPLATE_DIR}/docs/research/_template.md" "${TARGET_DIR}/docs/research/_template.md"
copy_if_not_exists "${TEMPLATE_DIR}/docs/specs/_template.md" "${TARGET_DIR}/docs/specs/_template.md"

# MCP 配置模板
copy_if_not_exists "${TEMPLATE_DIR}/.claude/settings.json.example" "${TARGET_DIR}/.claude/settings.json.example"

# .gitkeep
copy_if_not_exists "${TEMPLATE_DIR}/bug_fix/resolved/.gitkeep" "${TARGET_DIR}/bug_fix/resolved/.gitkeep"
copy_if_not_exists "${TEMPLATE_DIR}/.claude/out/.gitkeep" "${TARGET_DIR}/.claude/out/.gitkeep"
copy_if_not_exists "${TEMPLATE_DIR}/.claude/logs/.gitkeep" "${TARGET_DIR}/.claude/logs/.gitkeep"

# 确保脚本可执行
chmod +x "${TARGET_DIR}/scripts/claude_loop.sh"

echo ""
echo "Done! Next steps:"
echo ""
echo "  1. Edit CLAUDE.md — fill in project goals, tech stack, and coding standards"
echo "     Tip: copy language-specific rules from docs/RULES.md into CLAUDE.md"
echo "  2. (Optional) Set up MCP servers:"
echo "     cp .claude/settings.json.example .claude/settings.json"
echo "     Edit .claude/settings.json — fill in DB credentials and YAPI token"
echo "     Then run /sync-context to populate docs/DB_SCHEMA.md, API_SPEC.md, KB.md"
echo "  3. Edit docs/TODO.md — write your first batch of TODOs"
echo "  4. Edit docs/STATE.md — initialize project state"
echo "  5. (Optional) Edit docs/PRD.md — customize the PRD template for your team"
echo "  6. Try: /brainstorm, /plan, /execute, /status (slash commands)"
echo "  7. Run: bash scripts/claude_loop.sh"
echo ""
