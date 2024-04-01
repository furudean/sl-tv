import { get_bandcamp_response } from '$lib/server/bandcamp'
import { get_soundcloud_response } from '$lib/server/soundcloud'
import { get_youtube_response } from '$lib/server/youtube'
import { json, text } from '@sveltejs/kit'

const YOUTUBE_DOMAINS = ['youtube.com', 'youtu.be']
const SOUNDCLOUD_DOMAINS = ['soundcloud.com']
const BANDCAMP_DOMAINS = ['bandcamp.com']

const ALL_DOMAINS = [...YOUTUBE_DOMAINS, ...SOUNDCLOUD_DOMAINS, ...BANDCAMP_DOMAINS]

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
		'Content-Type': 'application/json; charset=utf-8',
		'Cache-Control': 'public, s-maxage=1',
		'CDN-Cache-Control': 'public, s-maxage=60',
		'Vercel-CDN-Cache-Control': 'public, s-maxage=3600'
	}
}

/** @type {import('./$types').RequestHandler} */
export async function GET({ url }) {
	const query = url.searchParams.get('q')
	const requested_by = url.searchParams.get('u') ?? undefined
	const is_play_skip = url.searchParams.get('s') === '1'

	if (query === null) return text('missing parameter q', { status: 400 })

	/** @type {string | undefined} */
	let hostname

	try {
		hostname = new URL(query).hostname
	} catch {
		return text(`not a valid url: ${query}`, { status: 400 })
	}

	const matches_host = host_match(hostname)

	/** @type {ResolveResponse | Response | undefined} */
	let response

	if (YOUTUBE_DOMAINS.some(matches_host)) {
		response = await get_youtube_response({ query })
	}

	if (SOUNDCLOUD_DOMAINS.some(matches_host)) {
		response = await get_soundcloud_response({ query })
	}

	if (BANDCAMP_DOMAINS.some(matches_host)) {
		response = await get_bandcamp_response({ query, fetch })
	}

	if (response instanceof Response) {
		return response
	}

	if (response) {
		response.requested_by = requested_by
		response.play_skip = is_play_skip ? 1 : 0

		return json(response, response_options)
	} else {
		return text(`host ${hostname} is not supported. must be one of [${ALL_DOMAINS.join(', ')}]`, {
			status: 400
		})
	}
}
