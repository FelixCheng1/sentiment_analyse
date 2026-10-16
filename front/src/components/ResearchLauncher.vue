<script setup>
import { EXAMPLE_TOPICS } from '../constants/roles.js'

defineProps({
  query: { type: String, default: '' },
  running: { type: Boolean, default: false },
  disabled: { type: Boolean, default: false },
  locked: { type: Boolean, default: false },
})

const emit = defineEmits(['update:query', 'start'])
</script>

<template>
  <section class="launcher rise-2">
    <form class="launcher-main" @submit.prevent="emit('start')">
      <label class="field-label" for="research-query">研究主题</label>
      <div class="query-row">
        <div class="query-box">
          <svg class="query-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round">
            <circle cx="11" cy="11" r="7.2" />
            <path d="M20.5 20.5l-4.6-4.6" />
          </svg>
          <input
            id="research-query"
            :value="query"
            class="query-input"
            type="text"
            placeholder="输入要研判的事件、话题或关键词…"
            :disabled="running"
            autocomplete="off"
            @input="emit('update:query', $event.target.value)"
          />
        </div>
        <button
          class="btn btn--accent start-btn"
          type="submit"
          :disabled="!query.trim() || running || disabled"
        >
          <span v-if="running" class="spinner"></span>
          <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M5 12h13M12 5l7 7-7 7" />
          </svg>
          {{ running ? '下发中…' : '开始分析' }}
        </button>
      </div>

      <div class="examples">
        <span class="examples-label">示例</span>
        <button
          v-for="topic in EXAMPLE_TOPICS"
          :key="topic"
          class="chip"
          type="button"
          :disabled="running"
          @click="emit('update:query', topic)"
        >
          {{ topic }}
        </button>
        <span v-if="locked" class="locked-note">已有分析在进行，完成后可发起新研究</span>
      </div>
    </form>
  </section>
</template>

<style scoped>
.launcher {
  background: var(--paper-raised);
  border: 1px solid var(--line);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  padding: 1.4rem 1.5rem 1.2rem;
  margin-bottom: 1.8rem;
}

.field-label {
  display: block;
  font-family: var(--font-mono);
  font-size: 0.64rem;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  color: var(--ink-faint);
  margin-bottom: 0.6rem;
}

.query-row {
  display: flex;
  gap: 0.6rem;
}

.query-box {
  flex: 1;
  min-width: 0;
  display: flex;
  align-items: center;
  gap: 0.6rem;
  padding: 0 0.9rem;
  background: var(--paper);
  border: 1px solid var(--line-strong);
  border-radius: var(--radius);
  transition: border-color 0.2s var(--ease-soft), box-shadow 0.2s var(--ease-soft);
}
.query-box:focus-within {
  border-color: var(--navy-soft);
  background: var(--paper-raised);
  box-shadow: 0 0 0 3px rgba(44, 79, 115, 0.12);
}

.query-icon {
  width: 17px;
  height: 17px;
  color: var(--ink-ghost);
  flex-shrink: 0;
}

.query-input {
  flex: 1;
  min-width: 0;
  border: none;
  background: none;
  box-shadow: none;
  padding: 0.8rem 0;
  font-size: 0.95rem;
}
.query-input:focus {
  box-shadow: none;
  border: none;
}

.start-btn {
  padding: 0 1.4rem;
  font-size: 0.88rem;
}

.examples {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.45rem;
  margin-top: 0.9rem;
}

.examples-label {
  font-size: 0.74rem;
  color: var(--ink-ghost);
  margin-right: 0.15rem;
}

.chip {
  padding: 0.22rem 0.7rem;
  font-size: 0.76rem;
  color: var(--ink-soft);
  background: var(--paper);
  border: 1px solid var(--line);
  border-radius: 999px;
}
.chip:hover:not(:disabled) {
  color: var(--clay-deep);
  border-color: rgba(189, 106, 55, 0.4);
  background: var(--clay-tint);
}

.locked-note {
  margin-left: auto;
  font-size: 0.74rem;
  color: var(--ink-ghost);
}

@media (max-width: 620px) {
  .query-row {
    flex-direction: column;
  }
  .start-btn {
    padding: 0.7rem 1.4rem;
  }
  .locked-note {
    margin-left: 0;
  }
}
</style>
