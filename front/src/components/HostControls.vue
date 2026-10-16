<script setup>
defineProps({
  running: { type: Boolean, default: false },
  loading: { type: Boolean, default: false },
})

defineEmits(['start', 'stop', 'refresh'])
</script>

<template>
  <div class="controls rise-2">
    <div class="controls-left">
      <button class="btn btn--primary" :disabled="running" @click="$emit('start')">
        <svg viewBox="0 0 24 24" fill="currentColor">
          <path d="M7 4.5l12 7.5-12 7.5z" />
        </svg>
        启动主持人
      </button>
      <button class="btn btn--danger" :disabled="!running" @click="$emit('stop')">
        <svg viewBox="0 0 24 24" fill="currentColor">
          <rect x="6" y="6" width="12" height="12" rx="1.5" />
        </svg>
        停止
      </button>
    </div>

    <div class="controls-right">
      <span class="state" :class="running ? 'is-live' : 'is-idle'">
        <span class="dot" :class="{ 'dot--live': running }"></span>
        {{ running ? '监听中，每 3 秒同步一次' : '已停止' }}
      </span>
      <button class="btn btn--ghost" :disabled="loading" @click="$emit('refresh')">
        <span v-if="loading" class="spinner"></span>
        <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
          <path d="M3 12a9 9 0 1 0 2.6-6.4M3 4v5h5" />
        </svg>
        {{ loading ? '同步中…' : '刷新' }}
      </button>
    </div>
  </div>
</template>

<style scoped>
.controls {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  flex-wrap: wrap;
  padding: 0.85rem 1.15rem;
  background: var(--paper-raised);
  border: 1px solid var(--line);
  border-radius: var(--radius);
  box-shadow: var(--shadow-xs);
  margin-bottom: 1.4rem;
}

.controls-left,
.controls-right {
  display: flex;
  align-items: center;
  gap: 0.55rem;
}

.state {
  display: flex;
  align-items: center;
  gap: 0.45rem;
  font-size: 0.78rem;
  margin-right: 0.3rem;
}
.state.is-live {
  color: var(--green);
}
.state.is-idle {
  color: var(--ink-ghost);
}

@media (max-width: 620px) {
  .controls {
    justify-content: flex-start;
  }
  .controls-right {
    width: 100%;
    justify-content: space-between;
  }
}
</style>
