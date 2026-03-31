FROM node:24-bookworm-slim

ARG USERNAME=ai-ks
ARG USERUID
ARG USERGID

# 创建与宿主机一致的用户，避免挂载目录权限错位
RUN set -eux; \
    test -n "${USERNAME}" || (echo "ERROR: missing build arg USERNAME. 运行 ./tf_apply.sh 或传入 -var username=..." >&2; exit 1); \
    test -n "${USERUID}" || (echo "ERROR: missing build arg USERUID. 运行 ./tf_apply.sh 或传入 -var user_uid=..." >&2; exit 1); \
    test -n "${USERGID}" || (echo "ERROR: missing build arg USERGID. 运行 ./tf_apply.sh 或传入 -var user_gid=..." >&2; exit 1); \
    if ! getent group "${USERGID}" >/dev/null; then \
      groupadd -g "${USERGID}" "${USERNAME}"; \
    fi; \
    if ! getent passwd "${USERUID}" >/dev/null; then \
      useradd -m -u "${USERUID}" -g "${USERGID}" -s /bin/sh "${USERNAME}"; \
    fi; \
    mkdir -p /app; \
    chown -R "${USERUID}:${USERGID}" /app

# 切换到目标用户
USER ${USERUID}:${USERGID}

# 默认命令
CMD ["sh", "/app/start.sh"]
