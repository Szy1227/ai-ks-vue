#!/usr/bin/env bash
set -euo pipefail

# Terraform apply 脚本
# 用法:
#   ./tf_apply.sh [--clean] [PORT] [CODE_HOST_DIR] [STACK_SUFFIX] [NETWORK_NAME] [FASTAPI_HOST]
#   --clean  先 terraform destroy 再 apply（仅需要彻底重装时用）
#   STACK_SUFFIX  如 -node-100；也可环境变量 TF_VAR_stack_suffix
#   NETWORK_NAME  Docker 网络名，用于与 FastAPI 联动
#   FASTAPI_HOST  FastAPI 服务地址

DESTROY_FIRST=0
if [[ "${1:-}" == "--clean" ]] || [[ "${1:-}" == "-c" ]]; then
  DESTROY_FIRST=1
  shift
fi

PORT="${1:-20001}"
CODE_HOST_DIR="${2:-code}"
STACK_SUFFIX="${TF_VAR_stack_suffix:-${3:-}}"
NETWORK_NAME="${4:-}"
FASTAPI_HOST="${5:-http://ai-ks-fastapi${STACK_SUFFIX}:8000}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

die() {
  echo "错误: $*" >&2
  exit 1
}

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || die "缺少命令: ${cmd}。解决: 请先安装 ${cmd} 并加入 PATH。"
}

detect_current_user_identity() {
  require_cmd id
  local current_uid current_gid
  current_uid="$(id -u 2>/dev/null || true)"
  current_gid="$(id -g 2>/dev/null || true)"

  [[ "$current_uid" =~ ^[0-9]+$ ]] || die "无法获取当前 UID（id -u 结果异常: ${current_uid}）。解决: 在标准 Linux shell 中执行，或手动传 TF_VAR_user_uid。"
  [[ "$current_gid" =~ ^[0-9]+$ ]] || die "无法获取当前 GID（id -g 结果异常: ${current_gid}）。解决: 在标准 Linux shell 中执行，或手动传 TF_VAR_user_gid。"
  echo "${current_uid}:${current_gid}"
}

IDENTITY="$(detect_current_user_identity)"
CURRENT_UID="${IDENTITY%%:*}"
CURRENT_GID="${IDENTITY#*:}"

TF_VAR_EXTERNAL_PORT="external_port=${PORT}"
TF_VAR_CODE_HOST_DIR="code_host_dir=${CODE_HOST_DIR}"
TF_VAR_STACK_SUFFIX="stack_suffix=${STACK_SUFFIX}"
TF_VAR_NETWORK_NAME="network_name=${NETWORK_NAME}"
TF_VAR_FASTAPI_HOST="fastapi_host=${FASTAPI_HOST}"
TF_VAR_USERNAME="username=ai-ks"
TF_VAR_USER_UID="user_uid=${CURRENT_UID}"
TF_VAR_USER_GID="user_gid=${CURRENT_GID}"

tf_init() {
  # 两种：ai-ks-design provision 克隆 ai-ks-tools 后的 workspace/plugins；否则默认 terraform init
  local plugin_dir="${TF_INIT_PLUGIN_DIR:-}"
  if [[ -z "$plugin_dir" || ! -d "$plugin_dir" ]] && [[ -d "${SCRIPT_DIR}/../../plugins" ]]; then
    plugin_dir="$(cd "${SCRIPT_DIR}/../.." && pwd)/plugins"
  fi
  if [[ -n "$plugin_dir" && -d "$plugin_dir" ]]; then
    terraform init -plugin-dir="$plugin_dir"
  else
    terraform init
  fi
}

tf_apply() {
  terraform apply -auto-approve \
    -var "$TF_VAR_EXTERNAL_PORT" \
    -var "$TF_VAR_CODE_HOST_DIR" \
    -var "$TF_VAR_STACK_SUFFIX" \
    -var "$TF_VAR_NETWORK_NAME" \
    -var "$TF_VAR_FASTAPI_HOST" \
    -var "$TF_VAR_USERNAME" \
    -var "$TF_VAR_USER_UID" \
    -var "$TF_VAR_USER_GID"
}

tf_destroy() {
  terraform destroy -auto-approve \
    -var "$TF_VAR_EXTERNAL_PORT" \
    -var "$TF_VAR_CODE_HOST_DIR" \
    -var "$TF_VAR_STACK_SUFFIX" \
    -var "$TF_VAR_NETWORK_NAME" \
    -var "$TF_VAR_FASTAPI_HOST" \
    -var "$TF_VAR_USERNAME" \
    -var "$TF_VAR_USER_UID" \
    -var "$TF_VAR_USER_GID"
}

if [[ "$DESTROY_FIRST" -eq 1 ]]; then
  tf_destroy || true
fi
tf_init
tf_apply
