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
    part: ['snippet'],
  })

  if (data.pageInfo?.totalResults !== 1) {
    throw error(404, 'video not found')
  }

  const snippet = data.items?.[0].snippet

  const response = {
    id: watch_id,
    title: snippet?.title,
    channel_title: snippet?.channelTitle
  }

  return json(response, response_options);
}
