<script setup>
import { computed, onMounted, ref } from 'vue'
import { getConfig, updateConfig } from '../composables/api.js'
import {
  CONFIG_GROUPS,
  GROUP_NOTES,
  SEARCH_TOOL_FIELDS,
  SEARCH_TOOL_OPTIONS,
} from '../constants/configGroups.js'
import PageHeading from '../components/PageHeading.vue'

const config = ref({})
const dirty = ref({})
const saving = ref(false)
const loading = ref(true)
const message = ref('')
const messageType = ref('success')
const maskedKeys = ref({})

const selectedSearchTool = computed(
  () => dirty.value.SEARCH_SWITCH || config.value.SEARCH_SWITCH || 'TavilyAPI'
)

const dirtyCount = computed(() => Object.keys(dirty.value).length)

onMounted(async () => {
  try {
    const res = await getConfig()
    config.value = res?.config || res || {}
  } catch {}
  loading.value = false
})

function setDirty(key, value) {
  dirty.value = { ...dirty.value, [key]: value }
}

function isDirty(key) {
  return dirty.value[key] !== undefined
}

function visibleFields(fields, group) {
  if (group !== '搜索工具') return fields
  const visible = new Set(['SEARCH_SWITCH', ...(SEARCH_TOOL_FIELDS[selectedSearchTool.value] || [])])
  return fields.filter(([key]) => visible.has(key))
}

function fieldValue(key) {
  return isDirty(key) ? dirty.value[key] : config.value[key] || ''
}

function maskValue(val) {
  if (!val) return '未设置'
  if (val.length > 24) return val.slice(0, 10) + '…' + val.slice(-4)
  return val
}

function placeholderFor(key, sensitive) {
  if (sensitive && !maskedKeys.value[key]) {
    return isDirty(key) ? '输入新的密钥以替换' : maskValue(config.value[key])
  }
  return ''
}

function toggleMask(key) {
  maskedKeys.value = { ...maskedKeys.value, [key]: !maskedKeys.value[key] }
}

function resetDirty() {
  dirty.value = {}
  message.value = ''
}

async function save() {
  saving.value = true
  message.value = ''
  try {
    await updateConfig(dirty.value)
    config.value = { ...config.value, ...dirty.value }
    dirty.value = {}
    message.value = '配置已保存，部分变更需重启服务后生效'
    messageType.value = 'success'
  } catch (e) {
    message.value = '保存失败：' + (e.message || '未知错误')
    messageType.value = 'error'
  }
  saving.value = false
}
</script>

<template>
  <div class="config-view">
    <PageHeading
      kicker="Config"
      title="系统配置"
      desc="管理四个角色的模型与密钥、联网搜索工具以及私域数据库连接。密钥仅显示部分内容。"
    >
      <template #actions>
        <span v-if="message" class="notice" :class="`notice--${messageType === 'success' ? 'ok' : 'error'}`">
          {{ message }}
        </span>
      </template>
    </PageHeading>

    <section
      v-for="(fields, group) in CONFIG_GROUPS"
      :key="group"
      class="group rise-2"
    >
      <header class="group-head">
        <h2 class="group-title">{{ group }}</h2>
        <p class="group-note">{{ GROUP_NOTES[group] }}</p>
      </header>

      <div class="fields">
        <div
          v-for="[key, label, sensitive] in visibleFields(fields, group)"
          :key="key"
          class="field"
          :class="{ 'is-dirty': isDirty(key) }"
        >
          <div class="field-top">
            <label :for="'cfg-' + key" class="field-label">{{ label }}</label>
            <span v-if="sensitive" class="badge badge--busy">密钥</span>
            <button
              v-if="sensitive"
              class="peek"
              type="button"
              :title="maskedKeys[key] ? '隐藏输入' : '显示输入'"
              @click="toggleMask(key)"
            >
              {{ maskedKeys[key] ? '隐藏' : '显示' }}
            </button>
          </div>

          <select
            v-if="key === 'SEARCH_SWITCH'"
            :id="'cfg-' + key"
            class="field-control field-select"
            :value="fieldValue(key)"
            @change="setDirty(key, $event.target.value)"
          >
            <option v-for="option in SEARCH_TOOL_OPTIONS" :key="option.value" :value="option.value">
              {{ option.label }}
            </option>
          </select>

          <input
            v-else
            :id="'cfg-' + key"
            class="field-control"
            :value="fieldValue(key)"
            :type="sensitive && !maskedKeys[key] ? 'password' : 'text'"
            :placeholder="placeholderFor(key, sensitive)"
            autocomplete="off"
            spellcheck="false"
            @input="setDirty(key, $event.target.value)"
          />

          <code class="field-key">{{ key }}</code>
        </div>
      </div>
    </section>

    <p v-if="loading" class="loading-note">正在载入配置…</p>

    <!-- 有改动时才出现的保存条 -->
    <Transition name="slide-up">
      <div v-if="dirtyCount" class="save-bar">
        <span class="save-count">{{ dirtyCount }} 项待保存</span>
        <div class="save-actions">
          <button class="btn btn--quiet" :disabled="saving" @click="resetDirty">放弃修改</button>
          <button class="btn btn--primary" :disabled="saving" @click="save">
            <span v-if="saving" class="spinner"></span>
            {{ saving ? '保存中…' : '保存配置' }}
          </button>
        </div>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.group {
  background: var(--paper-raised);
  border: 1px solid var(--line);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  padding: 1.3rem 1.4rem 1.5rem;
  margin-bottom: 1.3rem;
}

.group-head {
  display: flex;
  align-items: baseline;
  gap: 0.9rem;
  flex-wrap: wrap;
  padding-bottom: 0.85rem;
  margin-bottom: 1.15rem;
  border-bottom: 1px solid var(--line-soft);
}

.group-title {
  font-family: var(--font-body);
  font-size: 0.95rem;
  font-weight: 600;
  letter-spacing: 0;
  color: var(--navy);
}

.group-note {
  font-size: 0.77rem;
  color: var(--ink-ghost);
}

.fields {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 1.1rem 1.4rem;
}

.field {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
  min-width: 0;
}

.field-top {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  min-height: 20px;
}

.field-label {
  font-size: 0.8rem;
  font-weight: 500;
  color: var(--ink-soft);
}

.peek {
  margin-left: auto;
  font-size: 0.7rem;
  color: var(--ink-ghost);
  padding: 0 0.2rem;
}
.peek:hover {
  color: var(--navy);
}

.field-control {
  width: 100%;
  padding: 0.55rem 0.75rem;
  font-size: 0.84rem;
  font-family: var(--font-mono);
  background: var(--paper);
  border-color: var(--line);
  border-radius: var(--radius-sm);
}
.field-control:focus {
  background: var(--paper-raised);
}
.field-control::placeholder {
  font-family: var(--font-body);
  color: var(--ink-ghost);
}

.field-select {
  font-family: var(--font-body);
  cursor: pointer;
}

.field-key {
  font-size: 0.63rem;
  letter-spacing: 0.04em;
  color: var(--ink-ghost);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* 被修改的字段：赤陶色描边 + 左侧竖条 */
.field.is-dirty .field-control {
  border-color: rgba(189, 106, 55, 0.5);
  background: var(--clay-tint);
}
.field.is-dirty .field-label {
  color: var(--clay-deep);
}

.loading-note {
  font-size: 0.82rem;
  color: var(--ink-ghost);
}

/* —— 保存条 —— */
.save-bar {
  position: sticky;
  bottom: 1.2rem;
  margin-top: 0.6rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  padding: 0.7rem 0.9rem 0.7rem 1.2rem;
  background: var(--navy-deep);
  color: rgba(255, 255, 255, 0.85);
  border-radius: 999px;
  box-shadow: var(--shadow-lg);
}

.save-count {
  font-size: 0.82rem;
}

.save-actions {
  display: flex;
  align-items: center;
  gap: 0.4rem;
}

.save-bar .btn--quiet {
  color: rgba(255, 255, 255, 0.6);
}
.save-bar .btn--quiet:hover:not(:disabled) {
  color: #fff;
  background: rgba(255, 255, 255, 0.1);
}

.save-bar .btn--primary {
  background: var(--clay);
}
.save-bar .btn--primary:hover:not(:disabled) {
  background: var(--clay-deep);
}

.slide-up-enter-active,
.slide-up-leave-active {
  transition: opacity 0.25s var(--ease-soft), transform 0.25s var(--ease);
}
.slide-up-enter-from,
.slide-up-leave-to {
  opacity: 0;
  transform: translateY(14px);
}

@media (max-width: 700px) {
  .fields {
    grid-template-columns: 1fr;
  }
  .save-bar {
    border-radius: var(--radius);
    padding: 0.8rem 1rem;
  }
}
</style>
