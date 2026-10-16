<script setup>
import { computed, ref } from 'vue'
import { startResearch, getLatestResults, stopHost, startHost } from '../composables/api.js'
import { ROLE_LABELS, ROLE_SUBTITLE, ROLE_TONE, RESEARCH_ROLE_ORDER } from '../constants/roles.js'
import PageHeading from '../components/PageHeading.vue'
import ResearchLauncher from '../components/ResearchLauncher.vue'
import EngineCard from '../components/EngineCard.vue'
import SavedResults from '../components/SavedResults.vue'

const props = defineProps({
  roleProgress: { type: Object, default: () => ({}) },
  roleResults: { type: Object, default: () => ({}) },
})

const emit = defineEmits(['research-started'])

const query = ref('')
const researching = ref(false)
const results = ref(null)
const loadingLatest = ref(false)
const researchStarted = ref(false)

const hasActiveResearch = computed(
  () =>
    Object.keys(props.roleProgress || {}).length > 0 ||
    Object.keys(props.roleResults || {}).length > 0
)
const researchDisabled = computed(() => researchStarted.value || hasActiveResearch.value)

async function handleResearch() {
  if (!query.value.trim() || researching.value || researchDisabled.value) return
  researching.value = true
  researchStarted.value = true
  results.value = null
  emit('research-started')
  try {
    // 新查询前重置研判会话：stop 清空旧 Session（_done / pair_store），start 创建新 Session。
    // 必须先于 startResearch，确保 host 已订阅 SECTION_READY 事件再放 agent 发事件。
    await stopHost()
    await startHost()
    await startResearch(query.value.trim())
  } catch (e) {
    console.error('Research start failed:', e)
  } finally {
    researching.value = false
  }
}

async function loadLatest() {
  loadingLatest.value = true
  try {
    const data = await getLatestResults()
    if (data?.results) results.value = data.results
  } catch {}
  loadingLatest.value = false
}
</script>

<template>
  <div class="research-view">
    <PageHeading
      kicker="Research"
      title="深度舆情研究"
      desc="双引擎并行研判：数据挖掘检索私域库，舆情分析扫描公开网络，最终由主持人按维度对齐结论。"
    >
      <template #actions>
        <button class="btn btn--ghost" :disabled="loadingLatest" @click="loadLatest">
          <span v-if="loadingLatest" class="spinner"></span>
          <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
            <path d="M3 12a9 9 0 1 0 2.6-6.4M3 4v5h5" />
          </svg>
          {{ loadingLatest ? '载入中…' : '载入最近结果' }}
        </button>
      </template>
    </PageHeading>

    <ResearchLauncher
      v-model:query="query"
      :running="researching"
      :disabled="researchDisabled"
      :locked="researchDisabled && !researching"
      @start="handleResearch"
    />

    <section class="engines rise-3">
      <div class="engines-head">
        <h2 class="section-title">双引擎进度</h2>
        <span class="section-hint">实时推送</span>
      </div>
      <div class="engine-grid">
        <EngineCard
          v-for="role in RESEARCH_ROLE_ORDER"
          :key="role"
          :role="role"
          :label="ROLE_LABELS[role]"
          :subtitle="ROLE_SUBTITLE[role]"
          :tone="ROLE_TONE[role]"
          :progress="roleProgress?.[role]"
          :result="roleResults?.[role]"
        />
      </div>
    </section>

    <SavedResults :results="results" />
  </div>
</template>

<style scoped>
.engines {
  margin-top: 0.4rem;
}

.engines-head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  margin-bottom: 0.9rem;
}

.section-title {
  font-family: var(--font-body);
  font-size: 0.98rem;
  font-weight: 600;
  letter-spacing: 0;
}

.section-hint {
  font-family: var(--font-mono);
  font-size: 0.66rem;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: var(--ink-ghost);
}

.engine-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 1.1rem;
}

@media (max-width: 780px) {
  .engine-grid {
    grid-template-columns: 1fr;
  }
}
</style>
