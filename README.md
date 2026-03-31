# ai-ks-vue

使用 Terraform（Docker provider）在本地拉起 **Node 24** 容器，挂载 `code/` 运行 **Vue 3 + Vite** 开发服务器（CSR）。

## 前置条件

- [Terraform](https://www.terraform.io/) ≥ 1.x
- Docker
- Provider：`kreuzwerker/docker` 3.9.0

## 快速开始

```bash
chmod +x tf_apply.sh tf_destroy.sh
./tf_apply.sh                    # 默认端口 20001
./tf_apply.sh 13001              # 指定宿主机端口
./tf_apply.sh 13001 code -node-100   # 端口 + 代码目录 + 容器名后缀

./tf_destroy.sh
```

`--clean` / `-c`：先 `destroy` 再 `apply`。

### 插件目录

与 [ai-ks-fastapi](https://github.com/Szy1227/ai-ks-fastapi) 相同：支持 `TF_INIT_PLUGIN_DIR` 或上级 `../../plugins`；[ai-ks-design](https://github.com/Szy1227/ai-ks-design) 编排时使用 `ai-ks-tools/terraform/plugins`。

## 项目结构

```
.
├── main.tf           # Docker 镜像与容器
├── tf_apply.sh
├── tf_destroy.sh
└── code/
    ├── package.json
    ├── vite.config.js
    ├── start.sh      # 容器内：npm install（如需）+ npm run dev
    └── src/
```

Vite 在容器内使用 **5173**，映射到 `external_port`。开发命令：`vite --host 0.0.0.0 --port 5173`。

## 相关仓库

- [ai-ks-design](https://github.com/Szy1227/ai-ks-design)
- [ai-ks-fastapi](https://github.com/Szy1227/ai-ks-fastapi)
- [ai-ks-ssh-claude](https://github.com/Szy1227/ai-ks-ssh-claude)
