import { parse, toSeconds } from "iso8601-duration";

/** 
 * @param {string} date 
 * @returns {number}
 */
export function iso_8601_to_seconds(date) {
    return toSeconds(parse(date))
}