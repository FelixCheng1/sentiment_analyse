export const ROLE_LABELS = {
  insight: '数据挖掘',
  media: '舆情分析',
}

export const ROLE_SUBTITLE = {
  insight: '私域数据库深度检索',
  media: '全媒体舆情监控',
}

export const RESEARCH_ROLE_ORDER = ['insight', 'media']

/* 双引擎配色：一个冷（海军蓝），一个暖（赤陶），进程一眼可分 */
export const ROLE_TONE = {
  insight: 'navy',
  media: 'clay',
}

export const SENDER_STYLE = {
  insight: { color: 'var(--navy-soft)', label: '数据挖掘' },
  media: { color: 'var(--clay)', label: '舆情分析' },
  host: { color: 'var(--ink)', label: '主持人' },
}

export const DEFAULT_RESEARCH_DIMENSIONS = [
  { key: 'background_overview', title: '事件背景与概览', index: '01' },
  { key: 'heat_and_spread', title: '舆情热度与传播', index: '02' },
  { key: 'sentiment_and_opinion', title: '公众情感与观点', index: '03' },
  { key: 'platform_and_group_diff', title: '平台与群体差异', index: '04' },
  { key: 'deep_causes_and_impact', title: '深层原因与影响', index: '05' },
]

/* 输入框下的示例话题，点击即填入 */
export const EXAMPLE_TOPICS = ['AI 换脸诈骗', '网络谣言治理', '直播带货消费维权']
