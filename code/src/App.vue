<template>
  <main class="container">
    <h1>Vue 3 CSR Ready</h1>
    <p>Running in Docker + Terraform.</p>
    <div class="version-info">
      <p>前端版本: {{ frontendVersion }}</p>
      <p>后端版本: {{ backendVersion }}</p>
    </div>
  </main>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const frontendVersion = '0.1.0'
const backendVersion = ref('获取中...')

onMounted(async () => {
  try {
    const response = await fetch('/api/version')
    const data = await response.json()
    backendVersion.value = data.version
  } catch (error) {
    backendVersion.value = '获取失败'
  }
})
</script>

<style scoped>
.container {
  min-height: 100vh;
  display: grid;
  place-content: center;
  gap: 8px;
  text-align: center;
  font-family: sans-serif;
}

h1 {
  margin: 0;
}

p {
  margin: 0;
  color: #666;
}

.version-info {
  margin-top: 20px;
  padding: 15px;
  background: #f5f5f5;
  border-radius: 8px;
}

.version-info p {
  color: #333;
  font-weight: 500;
}
</style>
