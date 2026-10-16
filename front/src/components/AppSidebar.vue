<script setup>
defineProps({
  tabs: { type: Array, default: () => [] },
  activeTab: { type: String, default: '' },
  connected: { type: Boolean, default: false },
  completedRoles: { type: Number, default: 0 },
})

const emit = defineEmits(['update:activeTab'])
</script>

<template>
  <aside class="sidebar">
    <div class="brand">
      <span class="brand-mark">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round">
          <circle cx="12" cy="12" r="2.1" fill="currentColor" stroke="none" />
          <path d="M12 5.6a6.4 6.4 0 0 1 6.4 6.4" />
          <path d="M12 1.9A10.1 10.1 0 0 1 22.1 12" />
          <path d="M12 18.4A6.4 6.4 0 0 1 5.6 12" />
          <path d="M12 22.1A10.1 10.1 0 0 1 1.9 12" />
        </svg>
      </span>
      <span class="brand-copy">
        <span class="brand-name">舆情分析助手</span>
        <span class="brand-sub">Sentiment Analysis</span>
      </span>
    </div>

    <nav class="nav">
      <p class="nav-label">工作台</p>
      <button
        v-for="tab in tabs"
        :key="tab.key"
        class="nav-item"
        :class="{ 'is-active': activeTab === tab.key }"
        type="button"
        @click="emit('update:activeTab', tab.key)"
      >
        <span class="nav-icon">
          <svg v-if="tab.icon === 'radar'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round">
            <circle cx="11" cy="11" r="7.2" />
            <path d="M20.5 20.5l-4.6-4.6" />
          </svg>
          <svg v-else-if="tab.icon === 'document'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">
            <path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z" />
            <path d="M14 3v5h5" />
            <path d="M9 13h6M9 17h4" />
          </svg>
          <svg v-else-if="tab.icon === 'dialogue'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">
            <path d="M20 14.5a2 2 0 0 1-2 2H8l-4 3.5V5a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2z" />
            <path d="M8.5 9h7M8.5 12.5h4.5" />
          </svg>
          <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round">
            <path d="M5 7h14M5 12h14M5 17h14" />
            <circle cx="9" cy="7" r="1.9" fill="currentColor" stroke="none" />
            <circle cx="15" cy="12" r="1.9" fill="currentColor" stroke="none" />
            <circle cx="8" cy="17" r="1.9" fill="currentColor" stroke="none" />
          </svg>
        </span>
        <span class="nav-copy">
          <span class="nav-title">{{ tab.label }}</span>
          <span class="nav-desc">{{ tab.desc }}</span>
        </span>
        <span v-if="tab.key === 'research' && completedRoles" class="nav-count">{{ completedRoles }}/2</span>
      </button>
    </nav>

    <div class="sidebar-foot">
      <div class="conn" :class="{ 'is-live': connected }">
        <span class="conn-dot"></span>
        <span class="conn-text">{{ connected ? '实时通道已连接' : '通道断开，重连中' }}</span>
      </div>
      <p class="version">双引擎舆情研判 · v3.0</p>
    </div>
  </aside>
</template>

<style scoped>
.sidebar {
  position: fixed;
  inset: 0 auto 0 0;
  width: var(--sidebar-w);
  z-index: 20;
  display: flex;
  flex-direction: column;
  padding: 1.5rem 0 1.1rem;
  color: rgba(255, 255, 255, 0.74);
  background: linear-gradient(168deg, var(--navy) 0%, var(--navy-deep) 100%);
  border-right: 1px solid rgba(255, 255, 255, 0.06);
}

/* 侧栏右侧一道极淡的高光，避免纯色块发闷 */
.sidebar::after {
  content: '';
  position: absolute;
  top: 0;
  right: 0;
  width: 1px;
  height: 100%;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.14), transparent 45%);
}

/* —— 品牌 —— */
.brand {
  display: flex;
  align-items: center;
  gap: 0.7rem;
  padding: 0 1.35rem 1.6rem;
}

.brand-mark {
  width: 34px;
  height: 34px;
  flex-shrink: 0;
  display: grid;
  place-items: center;
  border-radius: 9px;
  color: #fff;
  background: var(--clay);
  box-shadow: 0 2px 10px rgba(189, 106, 55, 0.4);
}
.brand-mark svg {
  width: 21px;
  height: 21px;
}

.brand-copy {
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.brand-name {
  font-family: var(--font-display);
  font-size: 1rem;
  font-weight: 600;
  color: #fff;
  letter-spacing: 0.01em;
  white-space: nowrap;
}

.brand-sub {
  font-family: var(--font-mono);
  font-size: 0.6rem;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: rgba(255, 255, 255, 0.4);
}

/* —— 导航 —— */
.nav {
  flex: 1;
  padding: 0 0.75rem;
  min-height: 0;
  overflow-y: auto;
}

.nav-label {
  font-family: var(--font-mono);
  font-size: 0.6rem;
  letter-spacing: 0.2em;
  text-transform: uppercase;
  color: rgba(255, 255, 255, 0.32);
  padding: 0 0.6rem 0.6rem;
}

.nav-item {
  position: relative;
  width: 100%;
  display: flex;
  align-items: center;
  gap: 0.7rem;
  padding: 0.6rem 0.7rem;
  margin-bottom: 0.15rem;
  border-radius: var(--radius-sm);
  text-align: left;
  color: rgba(255, 255, 255, 0.68);
}
.nav-item:hover {
  background: rgba(255, 255, 255, 0.06);
  color: #fff;
}
.nav-item.is-active {
  background: rgba(255, 255, 255, 0.1);
  color: #fff;
}

/* 选中态：左侧一道赤陶指示条 */
.nav-item.is-active::before {
  content: '';
  position: absolute;
  left: -0.75rem;
  top: 50%;
  transform: translateY(-50%);
  width: 3px;
  height: 20px;
  border-radius: 0 3px 3px 0;
  background: var(--clay);
}

.nav-icon {
  display: grid;
  place-items: center;
  flex-shrink: 0;
  opacity: 0.85;
}
.nav-item.is-active .nav-icon {
  opacity: 1;
  color: #e8b48c;
}
.nav-icon svg {
  width: 18px;
  height: 18px;
}

.nav-copy {
  display: flex;
  flex-direction: column;
  min-width: 0;
  flex: 1;
}

.nav-title {
  font-size: 0.88rem;
  font-weight: 500;
  line-height: 1.3;
}

.nav-desc {
  font-size: 0.68rem;
  color: rgba(255, 255, 255, 0.38);
  line-height: 1.3;
}
.nav-item.is-active .nav-desc {
  color: rgba(255, 255, 255, 0.55);
}

.nav-count {
  font-family: var(--font-mono);
  font-size: 0.62rem;
  padding: 0.1rem 0.4rem;
  border-radius: 999px;
  background: var(--clay);
  color: #fff;
}

/* —— 底部状态 —— */
.sidebar-foot {
  padding: 1.1rem 1.35rem 0;
  border-top: 1px solid rgba(255, 255, 255, 0.08);
  margin-top: 0.8rem;
}

.conn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.74rem;
  color: rgba(255, 255, 255, 0.5);
}
.conn.is-live {
  color: #7fd1b0;
}

.conn-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.35);
  flex-shrink: 0;
}
.conn.is-live .conn-dot {
  background: #4ec79c;
  box-shadow: 0 0 0 3px rgba(78, 199, 156, 0.18);
  animation: breathe 2.4s var(--ease-soft) infinite;
}

.version {
  margin-top: 0.4rem;
  font-family: var(--font-mono);
  font-size: 0.6rem;
  letter-spacing: 0.06em;
  color: rgba(255, 255, 255, 0.26);
}

/* —— 窄屏：侧栏转为顶部横向条 —— */
@media (max-width: 900px) {
  .sidebar {
    position: static;
    width: 100%;
    flex-direction: row;
    align-items: center;
    gap: 1rem;
    padding: 0.7rem 1rem;
    overflow-x: auto;
  }

  .sidebar::after {
    display: none;
  }

  .brand {
    padding: 0;
    flex-shrink: 0;
  }

  .brand-copy,
  .nav-label,
  .nav-desc,
  .sidebar-foot {
    display: none;
  }

  .nav {
    display: flex;
    gap: 0.25rem;
    padding: 0;
    flex: 0 0 auto;
  }

  .nav-item {
    margin: 0;
    padding: 0.5rem 0.75rem;
  }

  .nav-item.is-active::before {
    left: 50%;
    top: auto;
    bottom: -0.7rem;
    transform: translateX(-50%);
    width: 20px;
    height: 3px;
    border-radius: 3px 3px 0 0;
  }

  .nav-title {
    font-size: 0.82rem;
  }

  .nav-count {
    display: none;
  }
}
</style>
