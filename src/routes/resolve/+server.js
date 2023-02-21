import { get_soundcloud_response } from '$lib/server/soundcloud'
import { get_youtube_response } from '$lib/server/youtube'
import { error, json } from '@sveltejs/kit'

const YOUTUBE_DOMAINS = ['youtube.com', 'youtu.be']
const SOUNDCLOUD_DOMAINS = ['soundcloud.com']

/**
 * @param {string} hostname
 * @returns {(test: string) => boolean}
 */
function host_match(hostname) {
	return (test) => hostname.endsWith(test)
}

const response_options = {
	headers: {
		// second life is fickle when it comes to headers! without this header the response will be
		// interpereted as ascii instead of utf-8...
		'Content-Type': 'application/json; charset=utf-8'
	}
}

/** @type {import('./$types').RequestHandler} */
export async function GET({ url }) {
	const query = url.searchParams.get('q')
	const requested_by = url.searchParams.get('u')

	if (query === null) throw error(400, 'missing parameter q')
	if (requested_by === null) throw error(400, 'missing parameter u')

	let hostname

	try {
		hostname = new URL(query).hostname
	} catch {
		throw error(400, 'invalid url in query')
	}

	const matches_host = host_match(hostname)

	if (YOUTUBE_DOMAINS.some(matches_host)) {
		const response = await get_youtube_response({ query, requested_by })
		return json(response, response_options)
	}

	if (SOUNDCLOUD_DOMAINS.some(matches_host)) {
		const response = await get_soundcloud_response({ query, requested_by })
		return json(response, response_options)
	}

	throw error(400, 'no supported url found in query')
}
