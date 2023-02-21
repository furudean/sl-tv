import { Temporal } from 'temporal-polyfill'

/**
 * @param {string} duration
 * @returns {number}
 */
export function duration_to_seconds(duration) {
	return Temporal.Duration.from(duration).seconds
}
