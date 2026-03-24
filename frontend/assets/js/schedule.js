export const dayToColumnMap = {
  Mon: 1,
  Tue: 2,
  Wed: 3,
  Thu: 4,
  Fri: 5,
  Sat: 6,
  Sun: 7
}

export const scheduleFormatExample = 'Use values like "Mon1-2" or "Fri3-4".'

export function parseScheduleUnit(unit) {
  const normalized = String(unit || '').trim()
  const match = normalized.match(/^(Mon|Tue|Wed|Thu|Fri|Sat|Sun)(\d+)-(\d+)$/)

  if (!match) {
    throw new Error(`Invalid class time format. ${scheduleFormatExample}`)
  }

  const start = Number(match[2])
  const end = Number(match[3])

  if (start < 1 || start > 13 || end < 1 || end > 13 || start > end) {
    throw new Error(`Invalid class time format. ${scheduleFormatExample}`)
  }

  return {
    day: match[1],
    column: dayToColumnMap[match[1]],
    start,
    end,
    normalized
  }
}

export function iterateScheduleUnits(classTimes, visit) {
  const items = Array.isArray(classTimes) ? classTimes : [classTimes]

  for (let courseIndex = 0; courseIndex < items.length; courseIndex++) {
    const units = String(items[courseIndex] || '').trim().split(/\s+/).filter(Boolean)

    for (let unitIndex = 0; unitIndex < units.length; unitIndex++) {
      const parsed = parseScheduleUnit(units[unitIndex])

      for (let slot = parsed.start; slot <= parsed.end; slot++) {
        if (visit(slot, parsed.column, courseIndex, unitIndex, parsed)) {
          return
        }
      }
    }
  }
}
