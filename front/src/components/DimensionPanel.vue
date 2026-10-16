<script setup>
import { ref } from 'vue'
import { SENDER_STYLE } from '../constants/roles.js'

defineProps({
  rows: { type: Array, default: () => [] },
})

/* 记录哪些维度展开了双引擎摘要 */
const expanded = ref({})

function toggle(key) {
  expanded.value = { ...expanded.value, [key]: !expanded.value[key] }
}

function stateOf(row) {
  if (row.host) return { text: '阶段裁判已出', tone: 'done' }
  if (row.count) return { text: '等待主持人裁决', tone: 'waiting' }
  return { text: '暂无该维度发言', tone: 'idle' }
}
</script>

<template>
  <section class="dimensions">
    <article
      v-for="row in rows"
      :key="row.key"
      class="dimension"
      :class="`tone-${stateOf(row).tone}`"
    >
      <header class="dim-head">
        <span class="dim-index">{{ row.index }}</span>
        <h3 class="dim-title">{{ row.title }}</h3>
        <span class="dim-state">
          <span
            class="dot"
            :class="{ 'dot--live': stateOf(row).tone === 'done', 'dot--busy': stateOf(row).tone === 'waiting' }"
          ></span>
          {{ stateOf(row).text }}
        </span>
      </header>

      <!-- 主持人阶段裁判 -->
      <div v-if="row.host" class="judgement">
        <div class="msg-meta">
          <span class="speaker" :style="{ color: SENDER_STYLE.host.color }">主持人</span>
          <span class="msg-time">{{ row.host.sent_at }}</span>
        </div>
        <p class="msg-text">{{ row.host.message_text }}</p>
      </div>

      <p v-else class="judgement-pending">该维度的主持裁判尚未生成</p>

      <!-- 双引擎摘要 -->
      <button class="expand-btn" type="button" @click="toggle(row.key)">
        <svg class="caret" :class="{ open: expanded[row.key] }" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M6 9l6 6 6-6" />
        </svg>
        双引擎原文摘要
        <span class="expand-count">{{ [row.insight, row.media].filter(Boolean).length }}/2 已就位</span>
      </button>

      <div v-if="expanded[row.key]" class="agent-grid">
        <div class="agent" :class="{ 'is-empty': !row.insight }">
          <p class="agent-title" :style="{ color: SENDER_STYLE.insight.color }">数据挖掘</p>
          <p v-if="row.insight" class="agent-text">{{ row.insight.message_text }}</p>
          <p v-else class="agent-empty">尚未收到该维度摘要</p>
        </div>
        <div class="agent" :class="{ 'is-empty': !row.media }">
          <p class="agent-title" :style="{ color: SENDER_STYLE.media.color }">舆情分析</p>
          <p v-if="row.media" class="agent-text">{{ row.media.message_text }}</p>
          <p v-else class="agent-empty">尚未收到该维度摘要</p>
        </div>
      </div>
    </article>
  </section>
</template>

<style scoped>
.dimensions {
  display: flex;
  flex-direction: column;
  gap: 0.85rem;
}

.dimension {
  padding: 1.1rem 1.25rem;
  background: var(--paper-raised);
  border: 1px solid var(--line);
  border-left: 3px solid var(--line-strong);
  border-radius: var(--radius);
  box-shadow: var(--shadow-xs);
  transition: border-color 0.25s var(--ease-soft);
}
.dimension.tone-done {
  border-left-color: var(--green);
}
.dimension.tone-waiting {
  border-left-color: var(--clay);
}

.dim-head {
  display: flex;
  align-items: center;
  gap: 0.7rem;
  margin-bottom: 0.85rem;
}

.dim-index {
  font-family: var(--font-mono);
  font-size: 0.7rem;
  font-weight: 500;
  color: var(--navy);
  background: var(--navy-tint);
  border-radius: 5px;
  padding: 0.15rem 0.45rem;
}

.dim-title {
  flex: 1;
  font-family: var(--font-body);
  font-size: 0.95rem;
  font-weight: 600;
  letter-spacing: 0;
}

.dim-state {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.74rem;
  color: var(--ink-faint);
}

/* —— 裁判 —— */
.judgement {
  padding: 0.85rem 1rem;
  background: var(--paper);
  border-radius: var(--radius-sm);
}

.msg-meta {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 0.4rem;
}

.speaker {
  font-size: 0.78rem;
  font-weight: 600;
}

.msg-time {
  font-family: var(--font-mono);
  font-size: 0.66rem;
  color: var(--ink-ghost);
}

.msg-text {
  font-size: 0.84rem;
  line-height: 1.8;
  color: var(--ink-soft);
  white-space: pre-wrap;
  word-break: break-word;
}

.judgement-pending {
  padding: 0.85rem 1rem;
  font-size: 0.8rem;
  color: var(--ink-ghost);
  border: 1px dashed var(--line-strong);
  border-radius: var(--radius-sm);
}

/* —— 展开 —— */
.expand-btn {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  width: 100%;
  margin-top: 0.7rem;
  padding: 0.35rem 0;
  font-size: 0.78rem;
  color: var(--ink-faint);
  text-align: left;
}
.expand-btn:hover {
  color: var(--navy);
}

.caret {
  width: 13px;
  height: 13px;
  transition: transform 0.2s var(--ease-soft);
}
.caret.open {
  transform: rotate(180deg);
}

.expand-count {
  margin-left: auto;
  font-family: var(--font-mono);
  font-size: 0.66rem;
  color: var(--ink-ghost);
}

.agent-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 0.7rem;
  margin-top: 0.7rem;
}

.agent {
  padding: 0.8rem 0.9rem;
  background: var(--paper);
  border: 1px solid var(--line-soft);
  border-radius: var(--radius-sm);
  min-height: 96px;
}
.agent.is-empty {
  border-style: dashed;
  background: transparent;
}

.agent-title {
  font-size: 0.75rem;
  font-weight: 600;
  margin-bottom: 0.4rem;
}

.agent-text {
  font-size: 0.8rem;
  line-height: 1.75;
  color: var(--ink-soft);
  white-space: pre-wrap;
  word-break: break-word;
  max-height: 220px;
  overflow-y: auto;
}

.agent-empty {
  font-size: 0.78rem;
  color: var(--ink-ghost);
}

@media (max-width: 720px) {
  .agent-grid {
    grid-template-columns: 1fr;
  }
  .dim-head {
    flex-wrap: wrap;
  }
}
</style>
