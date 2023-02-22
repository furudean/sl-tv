import { Temporal } from 'temporal-polyfill'

/**
 * @param {string} duration
 * @returns {number}
 */
export function duration_to_seconds(duration) {
	return Temporal.Duration.from(duration).total('seconds')
}

/** @param {number} s */
export function fmt_duration(s) {
	const total_seconds = Math.floor(s)
	const total_minutes = Math.floor(total_seconds / 60)

	const seconds = total_seconds % 60
	const minutes = total_minutes % 60
	const hours = Math.floor(total_minutes / 60)

	let value = ''

	if (hours > 0) value += hours + ':'

	if (hours > 0) value += '0'

	value += minutes + ':'

	if (seconds < 10) value += '0'
	value += seconds

	return value
}
