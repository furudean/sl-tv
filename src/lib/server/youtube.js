import { GOOGLE_CLOUD_API_KEY } from '$env/static/private'
import { duration_to_seconds } from '$lib/date'
import { error } from '@sveltejs/kit'
import { google } from 'googleapis'

const youtube = google.youtube('v3')

const YOUTUBE_MATCHER = /^.*(youtu.be\/|v\/|e\/|u\/\w+\/|embed\/|v=)([^#\&\?]*).*/

/**
 * @param {{ query: string }} params
 * @returns {Promise<ResolveResponse>}
 */
export async function get_youtube_response({ query }) {
	const watch_id = query.match(YOUTUBE_MATCHER)?.[2]

	if (!watch_id) throw error(400, 'invalid youtube url')

	// query youtube for metadata
	const { data } = await youtube.videos.list({
		key: GOOGLE_CLOUD_API_KEY,
		id: [watch_id],
		part: ['snippet', 'contentDetails']
	})

	if (data.pageInfo?.totalResults !== 1) {
		throw error(404, 'video not found')
	}

	const item = data.items?.[0]

	return {
		player_url: `/youtube/${watch_id}`,
		source_url: `https://youtu.be/${watch_id}`,
		title: item?.snippet?.title ?? 'unknown',
		user: item?.snippet?.channelTitle ?? 'unknown',
		duration: duration_to_seconds(item?.contentDetails?.duration || 'P0S')
	}
}
