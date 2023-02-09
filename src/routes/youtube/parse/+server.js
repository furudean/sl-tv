import { error, json } from '@sveltejs/kit';
import { youtube } from "$lib/server/youtube.js";
import { GOOGLE_CLOUD_API_KEY } from '$env/static/private'

const WATCH_ID_FROM_URL = /^.*(youtu.be\/|v\/|e\/|u\/\w+\/|embed\/|v=)([^#\&\?]*).*/

const response_options = {
  headers: {
    // second life is fickle when it comes to headers! without this header the response will be 
    // interpereted as ascii instead of utf-8...
    "Content-Type": "application/json; charset=utf-8"
  }
}

/** 
 * @param {string | null | undefined} date 
 * @returns {number}
 */
function iso_8601_to_seconds(date) {
  const regexp = /P(?:(?<days>\d*)D)?T(?:(?<hours>\d*)H)?(?:(?<minutes>\d*)M)?(?:(?<seconds>\d*)S)/g
  const as_number = (/** @type {string | undefined} */ x) => Number(x) || 0

  if (!date) return 0

  let [_, days, hours, minutes, seconds] = [...date.matchAll(regexp)][0].map(as_number)

  seconds += minutes * 60
  seconds += hours * 60 * 60
  seconds += days * 60 * 60 * 24

  return seconds
}

/** @type {import('./$types').RequestHandler} */
export async function GET({ url }) {
  const query = url.searchParams.get('q')

  if (query === null) throw error(400, 'missing parameter q')

  const watch_id = query.match(WATCH_ID_FROM_URL)?.[2];

  if (watch_id === undefined) throw error(400, 'no video id found in query')

  // query youtube for metadata
  const { data } = await youtube.videos.list({
    key: GOOGLE_CLOUD_API_KEY,
    id: [watch_id],
    part: ['snippet', 'contentDetails'],
  })

  if (data.pageInfo?.totalResults !== 1) {
    throw error(404, 'video not found')
  }

  const item = data.items?.[0]
  
  const response = {
    id: watch_id,
    title: item?.snippet?.title,
    channel_title: item?.snippet?.channelTitle,
    duration: iso_8601_to_seconds(item?.contentDetails?.duration)
  }

  return json(response, response_options);
}
