<script setup>
import { computed } from 'vue'
import { ROLE_LABELS, ROLE_TONE } from '../constants/roles.js'
import { plainPreview } from '../utils/text.js'

const props = defineProps({
  results: { type: Object, default: null },
})

const entries = computed(() =>
  Object.entries(props.results || {})
    .filter(([, data]) => data?.final_report)
    .map(([role, data]) => ({
      role,
      label: ROLE_LABELS[role] || role,
      tone: ROLE_TONE[role] || 'navy',
      file: data.report_file || '',
      preview: plainPreview(data.final_report, 320),
      length: plainPreview(data.final_report, 100000).length,
    }))
)
</script>

<template>
  <section v-if="entries.length" class="saved rise-4">
    <div class="section-head">
      <h2 class="section-title">已保存的分析结果</h2>
      <span class="section-count">{{ entries.length }} 份</span>
    </div>

    <div class="saved-grid">
      <article
        v-for="item in entries"
        :key="item.role"
        class="saved-card"
        :class="`tone-${item.tone}`"
      >
        <header class="saved-head">
          <span class="saved-label">{{ item.label }}</span>
          <span class="saved-size">{{ item.length }} 字</span>
        </header>
        <p class="saved-preview">{{ item.preview }}</p>
        <footer v-if="item.file" class="saved-foot">{{ item.file }}</footer>
      </article>
    </div>
  </section>
</template>

<style scoped>
.saved {
  margin-top: 2.8rem;
}

.section-head {
  display: flex;
  align-items: baseline;
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.section-title {
  font-family: var(--font-body);
  font-size: 0.98rem;
  font-weight: 600;
  letter-spacing: 0;
}

.section-count {
  font-family: var(--font-mono);
  font-size: 0.7rem;
  color: var(--ink-ghost);
}

.saved-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 1rem;
}

.saved-card {
  display: flex;
  flex-direction: column;
  padding: 1.1rem 1.2rem;
  background: var(--paper-raised);
  border: 1px solid var(--line);
  border-left: 3px solid var(--line-strong);
  border-radius: var(--radius);
  box-shadow: var(--shadow-xs);
  transition: box-shadow 0.25s var(--ease-soft), transform 0.25s var(--ease-soft);
}
.saved-card:hover {
  box-shadow: var(--shadow-md);
  transform: translateY(-1px);
}
.saved-card.tone-navy {
  border-left-color: var(--navy-soft);
}
.saved-card.tone-clay {
  border-left-color: var(--clay);
}

.saved-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 0.6rem;
}

.saved-label {
  font-size: 0.85rem;
  font-weight: 600;
}

.saved-size {
  font-family: var(--font-mono);
  font-size: 0.66rem;
  color: var(--ink-ghost);
}

.saved-preview {
  flex: 1;
  font-size: 0.81rem;
  line-height: 1.75;
  color: var(--ink-soft);
  max-height: 132px;
  overflow-y: auto;
}

.saved-foot {
  margin-top: 0.75rem;
  padding-top: 0.6rem;
  border-top: 1px solid var(--line-soft);
  font-family: var(--font-mono);
  font-size: 0.64rem;
  color: var(--ink-ghost);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>
