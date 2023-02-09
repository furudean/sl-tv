/** 
 * @param {string | null | undefined} date 
 * @returns {number}
 */
export function iso_8601_to_seconds(date) {
    const regexp = /P(?:(?<days>\d*)D)?T(?:(?<hours>\d*)H)?(?:(?<minutes>\d*)M)?(?:(?<seconds>\d*)S)/g
    const as_number = (/** @type {string | undefined} */ x) => Number(x) || 0

    if (!date) return 0

    let [_, days, hours, minutes, seconds] = [...date.matchAll(regexp)][0].map(as_number)
    seconds += minutes * 60
    seconds += hours * 60 * 60
    seconds += days * 60 * 60 * 24

    return seconds
}