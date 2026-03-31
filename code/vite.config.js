import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";

// 从环境变量获取 FastAPI 地址，默认使用容器名
const fastapiHost = process.env.VITE_FASTAPI_HOST || "http://ai-ks-fastapi:8000";

export default defineConfig({
  plugins: [vue()],
  server: {
    proxy: {
      '/api': {
        target: fastapiHost,
        changeOrigin: true
      }
    }
  }
});
