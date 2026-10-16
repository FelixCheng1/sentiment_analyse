<script setup>
import { computed } from 'vue'
import { plainPreview } from '../utils/text.js'

const props = defineProps({
  role: { type: String, required: true },
  label: { type: String, default: '' },
  subtitle: { type: String, default: '' },
  tone: { type: String, default: 'navy' },
  progress: { type: Object, default: null },
  result: { type: Object, default: null },
})

const report = computed(() => props.result?.final_report || '')
const percent = computed(() => props.progress?.progress_pct || 0)

const status = computed(() => {
  if (report.value) return 'done'
  if (percent.value > 0) return 'running'
  return 'idle'
})

const statusText = computed(
  () => ({ idle: '待命', running: '分析中', done: '已完成' })[status.value]
)

const statusClass = computed(
  () => ({ idle: 'badge--idle', running: 'badge--busy', done: 'badge--live' })[status.value]
)
</script>

<template>
  <article class="engine" :class="[`tone-${tone}`, `is-${status}`]">
    <header class="engine-head">
      <span class="engine-mark" aria-hidden="true">
        <svg v-if="role === 'insight'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round">
          <ellipse cx="12" cy="6" rx="7.5" ry="3.2" />
          <path d="M4.5 6v12c0 1.8 3.4 3.2 7.5 3.2s7.5-1.4 7.5-3.2V6" />
          <path d="M4.5 12c0 1.8 3.4 3.2 7.5 3.2s7.5-1.4 7.5-3.2" />
        </svg>
        <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="8.5" />
          <path d="M3.5 12h17" />
          <path d="M12 3.5c2.4 2.4 3.6 5.3 3.6 8.5s-1.2 6.1-3.6 8.5c-2.4-2.4-3.6-5.3-3.6-8.5S9.6 5.9 12 3.5z" />
        </svg>
      </span>
      <div class="engine-id">
        <h3 class="engine-name">{{ label }}</h3>
        <p class="engine-sub">{{ subtitle }}</p>
      </div>
      <span class="badge" :class="statusClass">
        <span class="dot" :class="{ 'dot--busy': status === 'running', 'dot--live': status === 'done' }"></span>
        {{ statusText }}
      </span>
    </header>

    <div class="engine-body">
      <!-- 待命 -->
      <div v-if="status === 'idle'" class="state-idle">
        <div class="idle-rule"></div>
        <p>等待研究任务下发</p>
        <span class="idle-hint">启动研究后自动进入分析</span>
      </div>

      <!-- 分析中 -->
      <div v-else-if="status === 'running'" class="state-running">
        <div class="meter">
          <div class="meter-fill" :style="{ width: Math.min(percent, 100) + '%' }"></div>
        </div>
        <p class="running-msg">{{ progress?.message || '正在检索与分析…' }}</p>
        <p class="running-num">
          {{ percent }}<span class="unit">%</span>
        </p>
      </div>

      <!-- 已完成 -->
      <div v-else class="state-done">
        <div class="done-flag">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
            <path d="M20 6L9 17l-5-5" />
          </svg>
          分析完成
        </div>
        <p class="done-preview">{{ plainPreview(report, 260) }}</p>
        <p v-if="result?.report_file" class="done-file">{{ result.report_file }}</p>
      </div>
    </div>
  </article>
</template>

<style scoped>
.engine {
  display: flex;
  flex-direction: column;
  background: var(--paper-raised);
  border: 1px solid var(--line);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  overflow: hidden;
  transition: border-color 0.3s var(--ease-soft), box-shadow 0.3s var(--ease-soft);
}

/* 顶部一道色条标记引擎身份 */
.engine::before {
  content: '';
  height: 3px;
  background: var(--line-strong);
  transition: background 0.35s var(--ease-soft);
}
.tone-navy::before {
  background: var(--navy-soft);
}
.tone-clay::before {
  background: var(--clay);
}

/* 分析中：底色微微透出该引擎的色调 */
.engine.is-running {
  border-color: var(--line-strong);
  box-shadow: var(--shadow-md);
}
.engine.tone-navy.is-running {
  border-color: rgba(44, 79, 115, 0.35);
}
.engine.tone-clay.is-running {
  border-color: rgba(189, 106, 55, 0.35);
}

.engine-head {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1.1rem 1.25rem 0.9rem;
}

.engine-mark {
  width: 34px;
  height: 34px;
  flex-shrink: 0;
  display: grid;
  place-items: center;
  border-radius: 8px;
}
.engine-mark svg {
  width: 19px;
  height: 19px;
}
.tone-navy .engine-mark {
  color: var(--navy-soft);
  background: var(--navy-tint);
}
.tone-clay .engine-mark {
  color: var(--clay-deep);
  background: var(--clay-tint);
}

.engine-id {
  flex: 1;
  min-width: 0;
}

.engine-name {
  font-family: var(--font-body);
  font-size: 0.95rem;
  font-weight: 600;
  letter-spacing: 0;
}

.engine-sub {
  font-size: 0.74rem;
  color: var(--ink-faint);
}

.engine-body {
  flex: 1;
  padding: 0 1.25rem 1.25rem;
  min-height: 148px;
  display: flex;
  flex-direction: column;
}

/* —— 待命 —— */
.state-idle {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 0.3rem;
  color: var(--ink-faint);
  font-size: 0.83rem;
}
.idle-rule {
  height: 1px;
  margin-bottom: 0.9rem;
  background: repeating-linear-gradient(
    90deg,
    var(--line-strong) 0 6px,
    transparent 6px 12px
  );
}
.idle-hint {
  font-size: 0.74rem;
  color: var(--ink-ghost);
}

/* —— 分析中 —— */
.state-running {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 0.55rem;
}

.meter {
  height: 4px;
  border-radius: 3px;
  background: var(--paper-sunken);
  overflow: hidden;
}
.meter-fill {
  height: 100%;
  border-radius: 3px;
  position: relative;
  transition: width 0.6s var(--ease);
}
.tone-navy .meter-fill {
  background: linear-gradient(90deg, var(--navy-soft), var(--navy));
}
.tone-clay .meter-fill {
  background: linear-gradient(90deg, var(--clay), var(--clay-deep));
}
/* 进度条上的流光，只在运行时出现 */
.meter-fill::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.55), transparent);
  animation: shimmer 1.9s var(--ease-soft) infinite;
}

.running-msg {
  font-size: 0.8rem;
  color: var(--ink-soft);
  min-height: 2.6em;
}

.running-num {
  font-family: var(--font-mono);
  font-size: 2rem;
  font-weight: 500;
  line-height: 1;
  letter-spacing: -0.02em;
}
.tone-navy .running-num {
  color: var(--navy);
}
.tone-clay .running-num {
  color: var(--clay-deep);
}
.running-num .unit {
  font-size: 0.9rem;
  margin-left: 0.15em;
  color: var(--ink-ghost);
}

/* —— 已完成 —— */
.state-done {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.7rem;
}

.done-flag {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  font-size: 0.76rem;
  font-weight: 600;
  color: var(--green);
}
.done-flag svg {
  width: 14px;
  height: 14px;
}

.done-preview {
  flex: 1;
  font-size: 0.81rem;
  line-height: 1.75;
  color: var(--ink-soft);
  max-height: 168px;
  overflow-y: auto;
  padding-right: 0.35rem;
}

.done-file {
  font-family: var(--font-mono);
  font-size: 0.66rem;
  color: var(--ink-ghost);
  padding-top: 0.6rem;
  border-top: 1px solid var(--line-soft);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>
