export const CONFIG_GROUPS = {
  'LLM 模型': [
    ['INSIGHT_ENGINE_MODEL_NAME', '数据挖掘引擎模型', false],
    ['INSIGHT_ENGINE_MODEL_PROVIDER', '数据挖掘引擎提供方', false],
    ['MEDIA_ENGINE_MODEL_NAME', '舆情分析引擎模型', false],
    ['MEDIA_ENGINE_MODEL_PROVIDER', '舆情分析引擎提供方', false],
    ['REPORT_ENGINE_MODEL_NAME', '报告引擎模型', false],
    ['REPORT_ENGINE_MODEL_PROVIDER', '报告引擎提供方', false],
    ['HOST_MODEL_NAME', '主持人模型', false],
    ['HOST_MODEL_PROVIDER', '主持人提供方', false],
  ],
  'API 密钥': [
    ['INSIGHT_ENGINE_API_KEY', '数据挖掘引擎 API Key', true],
    ['INSIGHT_ENGINE_BASE_URL', '数据挖掘引擎 Base URL', false],
    ['MEDIA_ENGINE_API_KEY', '舆情分析引擎 API Key', true],
    ['MEDIA_ENGINE_BASE_URL', '舆情分析引擎 Base URL', false],
    ['REPORT_ENGINE_API_KEY', '报告引擎 API Key', true],
    ['REPORT_ENGINE_BASE_URL', '报告引擎 Base URL', false],
    ['HOST_API_KEY', '主持人 API Key', true],
    ['HOST_BASE_URL', '主持人 Base URL', false],
  ],
  '搜索工具': [
    ['SEARCH_SWITCH', '搜索工具类型', false],
    ['TAVILY_API_KEY', 'Tavily API Key', true],
    ['ANSPIRE_API_KEY', 'Anspire API Key', true],
    ['ANSPIRE_BASE_URL', 'Anspire Base URL', false],
    ['BOCHA_API_KEY', 'Bocha API Key', true],
    ['BOCHA_BASE_URL', 'Bocha Base URL', false],
  ],
  '数据库': [
    ['DB_HOST', '数据库主机', false],
    ['DB_PORT', '数据库端口', false],
    ['DB_NAME', '数据库名称', false],
    ['DB_USER', '数据库用户', false],
  ],
}

export const GROUP_NOTES = {
  'LLM 模型': '四个角色各自独立配置，需支持 function calling。',
  'API 密钥': '密钥仅显示部分内容，留空表示不修改。',
  '搜索工具': '决定联网检索走哪家服务，切换后需填写对应密钥。',
  '数据库': '数据挖掘引擎检索私域库的连接信息，密码不在此处修改。',
}

export const SEARCH_TOOL_OPTIONS = [
  { value: 'TavilyAPI', label: 'Tavily' },
  { value: 'AnspireAPI', label: 'Anspire' },
  { value: 'BochaAPI', label: 'Bocha' },
]

export const SEARCH_TOOL_FIELDS = {
  TavilyAPI: ['TAVILY_API_KEY'],
  AnspireAPI: ['ANSPIRE_API_KEY', 'ANSPIRE_BASE_URL'],
  BochaAPI: ['BOCHA_API_KEY', 'BOCHA_BASE_URL'],
}
