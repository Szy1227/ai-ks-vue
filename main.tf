terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.9.0"
    }
  }
}

# 下载慢时可使用本地插件目录初始化:
# terraform init -plugin-dir=./plugins
provider "docker" {}

variable "external_port" {
  type        = number
  default     = 13000
  description = "宿主机映射端口"
}

variable "code_host_dir" {
  type        = string
  default     = "code"
  description = "Vue 代码目录（相对 path.module）"
}

variable "code_container_dir" {
  type        = string
  default     = "/app"
  description = "容器内挂载目录"
}

variable "stack_suffix" {
  type        = string
  default     = ""
  description = "容器名后缀，多节点时传如 -node-100，避免 Docker 名称冲突"
}

variable "network_name" {
  type        = string
  default     = ""
  description = "Docker 网络名，用于与 FastAPI 联动"
}

variable "fastapi_host" {
  type        = string
  default     = "http://ai-ks-fastapi:8000"
  description = "FastAPI 服务地址（容器名:端口）"
}

variable "username" {
  type        = string
  default     = "ai-ks"
  description = "容器内运行用户名称"
}

variable "user_uid" {
  type        = number
  description = "容器内运行用户 UID（建议使用宿主机 id -u）"
}

variable "user_gid" {
  type        = number
  description = "容器内运行用户 GID（建议使用宿主机 id -g）"
}

resource "docker_image" "vue_dev" {
  name = "ai-ks-vue-dev:latest"
  build {
    context    = path.module
    dockerfile = "${path.module}/Dockerfile"
    build_args = {
      USERNAME = var.username
      USERUID  = tostring(var.user_uid)
      USERGID  = tostring(var.user_gid)
    }
  }
  keep_locally = true
}

resource "docker_container" "vue3_csr" {
  name        = "ai-ks-vue${var.stack_suffix}"
  image       = docker_image.vue_dev.image_id
  restart     = "unless-stopped"
  working_dir = var.code_container_dir

  ports {
    internal = 5173
    external = var.external_port
  }

  volumes {
    host_path      = abspath("${path.module}/${var.code_host_dir}")
    container_path = var.code_container_dir
    read_only      = false
  }

  # 环境变量：FastAPI 地址，供 vite.config.js 使用
  env = [
    "VITE_FASTAPI_HOST=${var.fastapi_host}"
  ]

  # 加入 Docker 网络（与 FastAPI 同一网络）
  dynamic "networks_advanced" {
    for_each = var.network_name != "" ? [var.network_name] : []
    content {
      name = networks_advanced.value
    }
  }

  command = [
    "sh",
    "${var.code_container_dir}/start.sh"
  ]
}
