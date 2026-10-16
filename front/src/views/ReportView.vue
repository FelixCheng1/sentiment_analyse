<script setup>
import { onMounted, ref } from 'vue'
import {
  getReportStatus,
  generateReport,
  getReportResult,
  getReportDownloadUrl,
  getMarkdownUrl,
} from '../composables/api.js'
import PageHeading from '../components/PageHeading.vue'

const status = ref(null)
const generating = ref(false)
const reportQuery = ref('智能舆情分析报告')
const taskId = ref('')
const reportHtml = ref('')
const error = ref('')
const elapsed = ref(0)
const showFiles = ref(false)

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms))

async function refreshStatus() {
  try {
    status.value = await getReportStatus()
  } catch {}
}

async function startReport() {
  if (!status.value?.prepared) {
    error.value = '输入文件未准备就绪，请先完成一次舆情研究'
    return
  }
  generating.value = true
  error.value = ''
  reportHtml.value = ''
  elapsed.value = 0
  try {
    const res = await generateReport(reportQuery.value)
    if (res?.task_id) {
      taskId.value = res.task_id
      pollResult(res.task_id)
    } else {
      error.value = '任务创建失败，未返回任务号'
      generating.value = false
    }
  } catch (e) {
    error.value = e.message || '报告生成失败'
    generating.value = false
  }
}

async function pollResult(tid) {
  const maxPolls = 90
  for (let i = 0; i < maxPolls; i++) {
    await sleep(2000)
    elapsed.value = (i + 1) * 2
    const html = await getReportResult(tid).catch(() => null)
    if (html) {
      reportHtml.value = html
      generating.value = false
      return
    }
  }
  error.value = '报告生成超时，请稍后重试'
  generating.value = false
}

function downloadReport() {
  window.open(getReportDownloadUrl(taskId.value), '_blank')
}

function downloadMarkdown() {
  window.open(getMarkdownUrl(taskId.value), '_blank')
}

function formatElapsed(seconds) {
  const m = Math.floor(seconds / 60)
  const s = seconds % 60
  return m ? `${m}分${String(s).padStart(2, '0')}秒` : `${s} 秒`
}

onMounted(refreshStatus)
</script>

<template>
  <div class="report-view">
    <PageHeading
      kicker="Report"
      title="综合报告生成"
      desc="汇总主持人最终裁判与双引擎证据，由 LLM 生成结构化舆情研究报告，可导出 HTML 或 Markdown。"
    >
      <template #actions>
        <button class="btn btn--ghost" @click="refreshStatus">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
            <path d="M3 12a9 9 0 1 0 2.6-6.4M3 4v5h5" />
          </svg>
          刷新状态
        </button>
      </template>
    </PageHeading>

    <!-- 输入就绪状态 -->
    <div class="status-strip rise-2">
      <div class="status-item">
        <span class="status-key">输入数据</span>
        <span class="status-val" :class="status?.prepared ? 'is-ok' : 'is-off'">
          <span class="dot" :class="{ 'dot--live': status?.prepared }"></span>
          {{ status?.prepared ? '已就绪' : '未就绪' }}
        </span>
      </div>
      <div class="status-item">
        <span class="status-key">可用文件</span>
        <button
          class="status-val is-link"
          type="button"
          :disabled="!status?.found_files?.length"
          @click="showFiles = !showFiles"
        >
          {{ status?.found_files?.length || 0 }} 个
          <svg v-if="status?.found_files?.length" class="caret" :class="{ open: showFiles }" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M6 9l6 6 6-6" />
          </svg>
        </button>
      </div>
      <div v-if="generating" class="status-item">
        <span class="status-key">已用时</span>
        <span class="status-val is-busy">{{ formatElapsed(elapsed) }}</span>
      </div>
      <p v-if="!status?.prepared" class="status-tip">
        报告输入取自最近一次研究结果，请先在「研究」页完成分析
      </p>
    </div>

    <ul v-if="showFiles && status?.found_files?.length" class="file-list rise-2">
      <li v-for="file in status.found_files" :key="file">{{ file }}</li>
    </ul>

    <!-- 生成 -->
    <section class="generate rise-3">
      <label class="field-label" for="report-query">报告主题</label>
      <div class="generate-row">
        <input
          id="report-query"
          v-model="reportQuery"
          class="generate-input"
          type="text"
          placeholder="例如：AI 换脸诈骗舆情分析报告"
          :disabled="generating"
        />
        <button
          class="btn btn--primary"
          :disabled="generating || !reportQuery.trim() || !status?.prepared"
          @click="startReport"
        >
          <span v-if="generating" class="spinner"></span>
          <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
            <path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z" />
            <path d="M14 3v5h5" />
          </svg>
          {{ generating ? '生成中…' : '生成报告' }}
        </button>
      </div>
      <p class="generate-hint">生成过程约需 1–3 分钟，期间可切换到其他页面，任务不会中断。</p>
    </section>

    <div v-if="error" class="notice notice--error rise-3">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round">
        <circle cx="12" cy="12" r="9" />
        <path d="M12 8v5M12 16h.01" />
      </svg>
      {{ error }}
    </div>

    <!-- 生成中的占位 -->
    <section v-if="generating && !reportHtml" class="panel generating-panel rise-3">
      <div class="generating-body">
        <span class="spinner big"></span>
        <div>
          <p class="generating-title">正在生成报告</p>
          <p class="generating-desc">LLM 正在整合主持人裁判与双引擎证据，请稍候…</p>
        </div>
      </div>
      <div class="scan-bar"><span></span></div>
    </section>

    <!-- 结果 -->
    <section v-if="reportHtml" class="output rise-4">
      <div class="output-bar">
        <h2 class="output-title">报告预览</h2>
        <div class="output-actions">
          <button class="btn btn--ghost" @click="downloadReport">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <path d="M12 3v12M7 11l5 5 5-5M5 21h14" />
            </svg>
            下载 HTML
          </button>
          <button class="btn btn--ghost" @click="downloadMarkdown">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z" />
              <path d="M14 3v5h5M9 14h6M9 17h3" />
            </svg>
            导出 Markdown
          </button>
        </div>
      </div>
      <div class="report-frame">
        <div class="prose" v-html="reportHtml"></div>
      </div>
    </section>
  </div>
</template>

<style scoped>
/* —— 状态条 —— */
.status-strip {
  display: flex;
  align-items: center;
  gap: 2.2rem;
  flex-wrap: wrap;
  padding: 0.9rem 1.3rem;
  background: var(--paper-raised);
  border: 1px solid var(--line);
  border-radius: var(--radius);
  box-shadow: var(--shadow-xs);
  margin-bottom: 1.6rem;
}

.status-item {
  display: flex;
  align-items: center;
  gap: 0.6rem;
}

.status-key {
  font-size: 0.76rem;
  color: var(--ink-faint);
}

.status-val {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  font-family: var(--font-mono);
  font-size: 0.78rem;
  color: var(--ink-soft);
}
.status-val.is-ok {
  color: var(--green);
}
.status-val.is-off {
  color: var(--ink-ghost);
}
.status-val.is-busy {
  color: var(--clay-deep);
}
.status-val.is-link {
  color: var(--navy-soft);
  border-bottom: 1px dashed var(--line-strong);
}
.status-val.is-link:hover:not(:disabled) {
  color: var(--clay-deep);
}

.caret {
  width: 12px;
  height: 12px;
  transition: transform 0.2s var(--ease-soft);
}
.caret.open {
  transform: rotate(180deg);
}

.status-tip {
  margin-left: auto;
  font-size: 0.76rem;
  color: var(--clay-deep);
}

.file-list {
  list-style: none;
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
  margin: -1rem 0 1.6rem;
}
.file-list li {
  font-family: var(--font-mono);
  font-size: 0.68rem;
  color: var(--ink-faint);
  background: var(--paper-sunken);
  border-radius: 4px;
  padding: 0.2rem 0.55rem;
}

/* —— 生成区 —— */
.generate {
  background: var(--paper-raised);
  border: 1px solid var(--line);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  padding: 1.3rem 1.4rem 1.2rem;
  margin-bottom: 1.6rem;
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

.generate-row {
  display: flex;
  gap: 0.6rem;
}

.generate-input {
  flex: 1;
  min-width: 0;
  padding: 0.72rem 0.9rem;
  font-size: 0.92rem;
  background: var(--paper);
  border-color: var(--line-strong);
  border-radius: var(--radius);
}
.generate-input:focus {
  background: var(--paper-raised);
}

.generate-hint {
  margin-top: 0.75rem;
  font-size: 0.75rem;
  color: var(--ink-ghost);
}

/* —— 生成中 —— */
.generating-panel {
  margin-top: 1.4rem;
  overflow: hidden;
}

.generating-body {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.6rem 1.5rem;
}

.spinner.big {
  width: 22px;
  height: 22px;
  border-width: 2.5px;
  color: var(--navy-soft);
  flex-shrink: 0;
}

.generating-title {
  font-size: 0.92rem;
  font-weight: 600;
}

.generating-desc {
  font-size: 0.79rem;
  color: var(--ink-faint);
}

/* 底部一条来回扫描的光带，比转圈更能表达"长任务进行中" */
.scan-bar {
  height: 2px;
  background: var(--paper-sunken);
  overflow: hidden;
}
.scan-bar span {
  display: block;
  width: 34%;
  height: 100%;
  background: linear-gradient(90deg, transparent, var(--clay), transparent);
  animation: scan 1.7s var(--ease-soft) infinite;
}

@keyframes scan {
  0% {
    transform: translateX(-100%);
  }
  100% {
    transform: translateX(320%);
  }
}

/* —— 结果 —— */
.output {
  margin-top: 0.5rem;
}

.output-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  flex-wrap: wrap;
  margin-bottom: 0.9rem;
}

.output-title {
  font-family: var(--font-body);
  font-size: 0.98rem;
  font-weight: 600;
  letter-spacing: 0;
}

.output-actions {
  display: flex;
  gap: 0.5rem;
}

.report-frame {
  background: var(--paper-raised);
  border: 1px solid var(--line);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  padding: 2.2rem 2.4rem;
  max-height: 74vh;
  overflow-y: auto;
}

@media (max-width: 620px) {
  .generate-row {
    flex-direction: column;
  }
  .status-strip {
    gap: 1.2rem;
  }
  .status-tip {
    margin-left: 0;
  }
  .report-frame {
    padding: 1.4rem 1.1rem;
  }
}
</style>
