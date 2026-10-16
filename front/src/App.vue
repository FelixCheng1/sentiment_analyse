<script setup>
import { computed, onMounted, ref } from 'vue'
import { useSSE } from './composables/useSSE.js'
import { TABS } from './constants/navigation.js'
import AppSidebar from './components/AppSidebar.vue'
import ResearchView from './views/ResearchView.vue'
import ReportView from './views/ReportView.vue'
import HostDiscussionView from './views/HostDiscussionView.vue'
import ConfigView from './views/ConfigView.vue'

const { connected, roleProgress, roleResults, connect, clearResearchState } = useSSE()
const activeTab = ref('research')
const completedRoles = computed(() => Object.keys(roleResults.value).length)

onMounted(() => connect())
</script>

<template>
  <div class="shell">
    <AppSidebar
      v-model:activeTab="activeTab"
      :tabs="TABS"
      :connected="connected"
      :completed-roles="completedRoles"
    />

    <main class="workspace">
      <div class="workspace-inner">
        <ResearchView
          v-show="activeTab === 'research'"
          :role-progress="roleProgress"
          :role-results="roleResults"
          @research-started="clearResearchState"
        />
        <ReportView v-show="activeTab === 'report'" />
        <HostDiscussionView v-show="activeTab === 'host'" />
        <ConfigView v-show="activeTab === 'config'" />
      </div>
    </main>
  </div>
</template>

<style scoped>
.shell {
  display: flex;
  min-height: 100vh;
}

.workspace {
  flex: 1;
  min-width: 0;
  margin-left: var(--sidebar-w);
}

.workspace-inner {
  max-width: 1120px;
  margin: 0 auto;
  padding: 2.6rem 2.4rem 4rem;
}

@media (max-width: 900px) {
  .shell {
    flex-direction: column;
  }

  .workspace {
    margin-left: 0;
  }

  .workspace-inner {
    padding: 1.6rem 1.1rem 3rem;
  }
}
</style>
