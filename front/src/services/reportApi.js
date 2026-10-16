import { request } from './http.js'

export function getReportStatus() {
  return request('GET', '/report/status')
}

export function generateReport(query) {
  return request('POST', '/report/generate', { query })
}

/** 报告未完成时后端返回 4xx，这里直接归一化为 null，调用方无需解析错误体。 */
export async function getReportResult(taskId) {
  const response = await fetch(`/api/report/result/${taskId}`)
  if (!response.ok) return null
  return response.text()
}

export function getReportDownloadUrl(taskId, fileType = 'html') {
  return `/api/report/download/${taskId}/${fileType}`
}

export function getMarkdownUrl(taskId) {
  return getReportDownloadUrl(taskId, 'md')
}
