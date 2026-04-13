#!/usr/bin/env bash
set -euo pipefail

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-.}"

if [[ ! -d "${TARGET_DIR}" ]]; then
  echo "Target directory does not exist: ${TARGET_DIR}"
  exit 1
fi

TARGET_DIR="$(cd "${TARGET_DIR}" && pwd)"
echo "Initializing codex-loop workflow in: ${TARGET_DIR}"

mkdir -p "${TARGET_DIR}"/{docs,docs/meetings,docs/design,docs/research,docs/specs,scripts,prompts,bug_fix/resolved}

copy_if_not_exists() {
  local src="$1"
  local dst="$2"
  if [[ -f "${dst}" ]]; then
    echo "SKIP: ${dst#${TARGET_DIR}/}"
  else
    /bin/cp "${src}" "${dst}"
    echo "COPY: ${dst#${TARGET_DIR}/}"
  fi
}

copy_if_not_exists "${TEMPLATE_DIR}/AGENTS.md" "${TARGET_DIR}/AGENTS.md"
copy_if_not_exists "${TEMPLATE_DIR}/agent.md" "${TARGET_DIR}/agent.md"
copy_if_not_exists "${TEMPLATE_DIR}/README.md" "${TARGET_DIR}/README.md"

for file in TODO.md STATE.md FEEDBACK.md MEMORY.md PRD.md TDD.md RULES.md SKILL_TEMPLATE.md DB_SCHEMA.md API_SPEC.md KB.md CODEX_WORKFLOW.md; do
  copy_if_not_exists "${TEMPLATE_DIR}/docs/${file}" "${TARGET_DIR}/docs/${file}"
done

copy_if_not_exists "${TEMPLATE_DIR}/scripts/codex_loop.sh" "${TARGET_DIR}/scripts/codex_loop.sh"
copy_if_not_exists "${TEMPLATE_DIR}/scripts/codex_loop_output.schema.json" "${TARGET_DIR}/scripts/codex_loop_output.schema.json"
copy_if_not_exists "${TEMPLATE_DIR}/prompts/codex_loop_prompt.txt" "${TARGET_DIR}/prompts/codex_loop_prompt.txt"

copy_if_not_exists "${TEMPLATE_DIR}/docs/meetings/_template.md" "${TARGET_DIR}/docs/meetings/_template.md"
copy_if_not_exists "${TEMPLATE_DIR}/docs/design/_template.md" "${TARGET_DIR}/docs/design/_template.md"
copy_if_not_exists "${TEMPLATE_DIR}/docs/research/_template.md" "${TARGET_DIR}/docs/research/_template.md"
copy_if_not_exists "${TEMPLATE_DIR}/docs/specs/_template.md" "${TARGET_DIR}/docs/specs/_template.md"
copy_if_not_exists "${TEMPLATE_DIR}/bug_fix/resolved/.gitkeep" "${TARGET_DIR}/bug_fix/resolved/.gitkeep"

/bin/chmod +x "${TARGET_DIR}/scripts/codex_loop.sh"

echo "Done"
