<script setup>
defineProps({
  kicker: { type: String, default: '' },
  title: { type: String, default: '' },
  desc: { type: String, default: '' },
})
</script>

<template>
  <header class="page-head rise-1">
    <div class="head-copy">
      <p class="kicker">{{ kicker }}</p>
      <h1 class="head-title">{{ title }}</h1>
      <p v-if="desc" class="head-desc">{{ desc }}</p>
    </div>
    <div v-if="$slots.actions" class="head-actions">
      <slot name="actions" />
    </div>
  </header>
</template>

<style scoped>
.page-head {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 1.5rem;
  flex-wrap: wrap;
  padding-bottom: 1.4rem;
  margin-bottom: 1.6rem;
  /* 标题下方一条由深到浅的细线，替代满宽分割线 */
  border-bottom: 1px solid var(--line);
  position: relative;
}
.page-head::after {
  content: '';
  position: absolute;
  left: 0;
  bottom: -1px;
  width: 64px;
  height: 2px;
  background: var(--clay);
}

.head-title {
  font-size: clamp(1.5rem, 2.6vw, 1.95rem);
  margin-top: 0.35rem;
}

.head-desc {
  margin-top: 0.45rem;
  font-size: 0.87rem;
  color: var(--ink-faint);
  max-width: 62ch;
}

.head-actions {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  padding-bottom: 0.15rem;
}
</style>
