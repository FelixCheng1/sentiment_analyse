<script setup>
defineProps({
  messages: { type: Array, default: () => [] },
})
</script>

<template>
  <section v-if="messages.length" class="finals">
    <div class="finals-head">
      <span class="kicker">最终研判</span>
      <span class="finals-count">{{ messages.length }} 条</span>
    </div>

    <blockquote v-for="(msg, i) in messages" :key="`final-${i}`" class="final">
      <p class="final-text">{{ msg.message_text }}</p>
      <footer class="final-foot">
        <span class="final-src">主持人</span>
        <span class="final-time">{{ msg.sent_at }}</span>
      </footer>
    </blockquote>
  </section>
</template>

<style scoped>
.finals {
  margin-bottom: 1.6rem;
}

.finals-head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  margin-bottom: 0.75rem;
}

.finals-count {
  font-family: var(--font-mono);
  font-size: 0.68rem;
  color: var(--ink-ghost);
}

.final {
  position: relative;
  padding: 1.2rem 1.4rem 1rem;
  margin-bottom: 0.75rem;
  background: var(--navy-tint);
  border: 1px solid var(--navy-line);
  border-left: 3px solid var(--navy);
  border-radius: var(--radius);
}

.final-text {
  font-size: 0.88rem;
  line-height: 1.85;
  color: var(--ink);
  white-space: pre-wrap;
  word-break: break-word;
}

.final-foot {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 0.8rem;
  padding-top: 0.6rem;
  border-top: 1px solid var(--navy-line);
}

.final-src {
  font-size: 0.76rem;
  font-weight: 600;
  color: var(--navy);
}

.final-time {
  font-family: var(--font-mono);
  font-size: 0.66rem;
  color: var(--ink-faint);
}
</style>
