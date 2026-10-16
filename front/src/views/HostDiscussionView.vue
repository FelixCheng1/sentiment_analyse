<script setup>
import { computed, nextTick, onUnmounted, ref } from 'vue'
import { startHost, stopHost, getHostDiscussionLog } from '../composables/api.js'
import { DEFAULT_RESEARCH_DIMENSIONS } from '../constants/roles.js'
import PageHeading from '../components/PageHeading.vue'
import HostControls from '../components/HostControls.vue'
import DimensionPanel from '../components/DimensionPanel.vue'
import FinalJudgements from '../components/FinalJudgements.vue'

const messages = ref([])
const researchDimensions = ref(DEFAULT_RESEARCH_DIMENSIONS)
const loading = ref(false)
const hostRunning = ref(false)
const error = ref('')
let pollTimer = null

const finalHostMessages = computed(() =>
  messages.value.filter((msg) => msg.source === 'host' && !msg.dimension_key)
)

const dimensionRows = computed(() =>
  researchDimensions.value.map((dimension) => {
    const scoped = messages.value.filter((msg) => msg.dimension_key === dimension.key)
    return {
      ...dimension,
      insight: latestBySpeaker(scoped, 'insight'),
      media: latestBySpeaker(scoped, 'media'),
      host: latestBySpeaker(scoped, 'host'),
      count: scoped.length,
    }
  })
)

const hasStructuredMessages = computed(
  () => finalHostMessages.value.length || dimensionRows.value.some((row) => row.count)
)

const settledCount = computed(() => dimensionRows.value.filter((row) => row.host).length)

function latestBySpeaker(items, source) {
  return [...items].reverse().find((msg) => msg.source === source) || null
}

function normalizeDiscussionRecords(data) {
  const records = data?.discussion_records || data?.parsed_messages || []
  return records.map((record) => ({
    source: record.source || '',
    message_text: record.message_text || record.content || '',
    sent_at: record.sent_at || record.timestamp || '',
    dimension_key: record.dimension_key || record.section_key || '',
  }))
}

async function handleStart() {
  error.value = ''
  try {
    await startHost()
    hostRunning.value = true
    startPolling()
  } catch (e) {
    error.value = '启动主持人失败'
  }
}

async function handleStop() {
  hostRunning.value = false
  stopPolling()
  try {
    await stopHost()
  } catch (e) {
    error.value = '停止主持人失败'
  }
}

async function refreshLog() {
  loading.value = true
  try {
    const data = await getHostDiscussionLog()
    const nextMessages = normalizeDiscussionRecords(data)
    const shouldUpdate = hasDiscussionChanged(nextMessages)
    const shouldFollow = isNearBottom()
    if (shouldUpdate) {
      messages.value = nextMessages
      await nextTick()
      if (shouldFollow) scrollToBottom()
    }
    if (isDiscussionComplete()) {
      hostRunning.value = false
      stopPolling()
    }
  } catch {}
  loading.value = false
}

function startPolling() {
  stopPolling()
  pollTimer = setInterval(refreshLog, 3000)
}

function stopPolling() {
  if (pollTimer) {
    clearInterval(pollTimer)
    pollTimer = null
  }
}

function isDiscussionComplete() {
  return finalHostMessages.value.length > 0 && dimensionRows.value.every((row) => row.host)
}

function hasDiscussionChanged(nextMessages) {
  if (nextMessages.length !== messages.value.length) return true
  const currentLast = messages.value[messages.value.length - 1]
  const nextLast = nextMessages[nextMessages.length - 1]
  return JSON.stringify(currentLast) !== JSON.stringify(nextLast)
}

function isNearBottom() {
  const el = document.querySelector('.discussion-scroll')
  if (!el) return true
  return el.scrollHeight - el.scrollTop - el.clientHeight < 80
}

function scrollToBottom() {
  const el = document.querySelector('.discussion-scroll')
  if (el) el.scrollTop = el.scrollHeight
}

onUnmounted(stopPolling)

refreshLog()
</script>

<template>
  <div class="host-view">
    <PageHeading
      kicker="Host"
      title="主持人研判讨论"
      desc="主持人按五个研究维度对齐双引擎输出，沉淀阶段裁判与最终研判结论。"
    >
      <template #actions>
        <span v-if="messages.length" class="progress-chip">
          阶段裁判 {{ settledCount }}/{{ dimensionRows.length }}
        </span>
      </template>
    </PageHeading>

    <HostControls
      :running="hostRunning"
      :loading="loading"
      @start="handleStart"
      @stop="handleStop"
      @refresh="refreshLog"
    />

    <div v-if="error" class="notice notice--error">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round">
        <circle cx="12" cy="12" r="9" />
        <path d="M12 8v5M12 16h.01" />
      </svg>
      {{ error }}
    </div>

    <div v-if="messages.length" class="discussion-scroll rise-3">
      <FinalJudgements :messages="finalHostMessages" />
      <DimensionPanel v-if="hasStructuredMessages" :rows="dimensionRows" />
    </div>

    <div v-else class="empty-state rise-3">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.3" stroke-linecap="round" stroke-linejoin="round">
        <path d="M20 14.5a2 2 0 0 1-2 2H8l-4 3.5V5a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2z" />
      </svg>
      <p class="empty-title">{{ hostRunning ? '主持人已启动，等待讨论内容' : '主持人尚未启动' }}</p>
      <p class="empty-desc">
        {{ hostRunning ? '双引擎发言后将自动汇聚到这里' : '点击「启动主持人」开始多维研判，或在「研究」页发起分析时自动启动' }}
      </p>
    </div>
  </div>
</template>

<style scoped>
.progress-chip {
  font-family: var(--font-mono);
  font-size: 0.72rem;
  color: var(--navy-soft);
  background: var(--navy-tint);
  border: 1px solid var(--navy-line);
  border-radius: 999px;
  padding: 0.25rem 0.7rem;
}

.discussion-scroll {
  max-height: 68vh;
  overflow-y: auto;
  padding-right: 0.6rem;
  margin-top: 1.2rem;
}

.notice {
  margin-bottom: 1.1rem;
}
</style>
