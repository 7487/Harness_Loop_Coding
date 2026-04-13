#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

MAX_ITERS="${MAX_ITERS:-999999}"
RETRY_DELAY="${RETRY_DELAY:-10}"
PROMPT_TEMPLATE="${PROMPT_TEMPLATE:-prompts/codex_loop_prompt.txt}"
OUTPUT_SCHEMA="${OUTPUT_SCHEMA:-scripts/codex_loop_output.schema.json}"
RUN_DIR="${RUN_DIR:-.codex-run}"

mkdir -p "${RUN_DIR}/out" "${RUN_DIR}/logs"

command -v codex >/dev/null 2>&1 || { echo "Missing required command: codex"; exit 1; }

pick_next_todo() {
  grep -E '^- \[ \] T[0-9]+' -n docs/TODO.md | head -n 1 | sed -E 's/^.*\[ \] (T[0-9]+).*$/\1/'
}

build_prompt() {
  local todo_id="$1"
  python3 - "$todo_id" "$PROMPT_TEMPLATE" <<'PY'
from pathlib import Path
import sys
text = Path(sys.argv[2]).read_text(encoding='utf-8')
print(text.replace('{{ACTIVE_TODO}}', sys.argv[1]))
PY
}

run_codex_once() {
  local todo_id="$1"
  local ts out_json log_file prompt_file raw_out
  ts="$(date +%Y%m%d_%H%M%S)"
  out_json="${RUN_DIR}/out/${ts}_${todo_id}.json"
  log_file="${RUN_DIR}/logs/${ts}_${todo_id}.log"
  prompt_file="${RUN_DIR}/out/${ts}_${todo_id}.prompt.txt"
  raw_out="${RUN_DIR}/out/${ts}_${todo_id}.raw.txt"

  build_prompt "${todo_id}" > "${prompt_file}"

  set +e
  codex exec -C "${REPO_ROOT}" --skip-git-repo-check --sandbox workspace-write --output-schema "${OUTPUT_SCHEMA}" -o "${out_json}" - < "${prompt_file}" > "${raw_out}" 2> "${log_file}"
  rc=$?
  set -e

  if [[ $rc -ne 0 ]]; then
    echo "Codex exited with non-zero code: ${rc}"
    return $rc
  fi

  [[ -s "${out_json}" ]] || { echo "Codex did not write a valid JSON output"; return 1; }
}

main() {
  local forced_todo="${1:-}"

  for ((i=1; i<=MAX_ITERS; i++)); do
    local todo_id latest_json completed status

    if [[ -n "${forced_todo}" ]]; then
      todo_id="${forced_todo}"
      forced_todo=""
    else
      todo_id="$(pick_next_todo || true)"
    fi

    [[ -n "${todo_id}" ]] || { echo "No unchecked TODO found in docs/TODO.md. Stop."; exit 0; }

    if ! run_codex_once "${todo_id}"; then
      echo "Retrying same TODO in ${RETRY_DELAY}s..."
      sleep "${RETRY_DELAY}"
      forced_todo="${todo_id}"
      continue
    fi

    latest_json="$(ls -t "${RUN_DIR}"/out/*_"${todo_id}".json 2>/dev/null | head -n 1 || true)"
    if [[ -n "${latest_json}" ]]; then
      completed="$(python3 - <<'PY' "$latest_json"
import json,sys
print(json.load(open(sys.argv[1], encoding='utf-8')).get('completed', False))
PY
)"
      status="$(python3 - <<'PY' "$latest_json"
import json,sys
print(json.load(open(sys.argv[1], encoding='utf-8')).get('run_status', ''))
PY
)"
      if [[ "${completed}" != "True" && "${completed}" != "true" || "${status}" == "blocked" || "${status}" == "failed" ]]; then
        forced_todo="${todo_id}"
      fi
    fi
  done
}

main "$@"
