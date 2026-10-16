/**
 * 把可能带 HTML 标签的报告正文压成一段纯文本摘要。
 * 直接对 HTML 做 slice 会截断标签，所以先剥标签再截断。
 */
export function plainPreview(source, maxLength = 240) {
  if (!source) return ''
  const text = String(source)
    .replace(/<[^>]*>/g, ' ')
    .replace(/&nbsp;/g, ' ')
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/\s+/g, ' ')
    .trim()
  return text.length > maxLength ? text.slice(0, maxLength) + '…' : text
}
