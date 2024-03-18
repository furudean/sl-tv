import { text } from '@sveltejs/kit'

const API_BASE = 'https://api-v2.soundcloud.com'

/** @type {string | undefined} */
let client_id

/**
 * based on youtube-dl's soundcloud extractor
 *
 * https://github.com/ytdl-org/youtube-dl/blob/57802e632f5a741df6fd9b30a455c32632944489/youtube_dl/extractor/soundcloud.py#L277-L289
 *
 * @returns {Promise<string | undefined>}
 */
async function extract_client_id() {
	const SCRIPT_TAG_SRC = /<script[^>]+src="([^"]+)"/g
	const CLIENT_ID = /client_id\s*:\s*"([0-9a-zA-Z]{32})/

	// load the soundcloud home page html
	const homepage = await fetch('https://soundcloud.com').then((response) => response.text())

	// get the urls of all script tags on the page
	const script_urls = [...homepage.matchAll(SCRIPT_TAG_SRC)].map((match) => match[1]).reverse()

	for (const url of script_urls) {
		// download script
		const script = await fetch(url).then((response) => response.text())

		// find the client id in the source
		const match = script.match(CLIENT_ID)?.[1]

		if (match) {
			return match
		}
	}
}

/**
 * @param {{ query: string }} params
 * @returns {Promise<ResolveResponse | Response>}
 */
export async function get_soundcloud_response({ query }, attempts = 1) {
	if (!client_id) {
		client_id = await extract_client_id()
	}

	// handle shortened urls
	if (new URL(query).hostname === 'on.soundcloud.com') {
		const res = await fetch(query, { redirect: 'manual' })
		const location = res.headers.get('Location')

		if (res.status === 302 && location) {
			return get_soundcloud_response({ query: location })
		}

		return text('failed to handle redirect for ' + query, { status: 500 })
	}

	const url = `${API_BASE}/resolve?url=${encodeURIComponent(query)}&client_id=${client_id}`
	const res = await fetch(url)

	if (res.status !== 200) {
		console.log('failed to query soundcloud api', res)
		if (attempts > 3) return text('failed to contact soundcloud api', { status: 500 })

		client_id = undefined
		return get_soundcloud_response({ query }, attempts + 1)
	}

	const data = await res.json()

	if (!data.uri) return text('track not found', { status: 404 })
	if (!data.streamable) return text('url can not be streamed', { status: 403 })

	const id = data.urn.split(':')[2]

	const response = {
		player_url: `/soundcloud/${id}`,
		source_url: data.permalink_url,
		title: data.title,
		user: data.user.username,
		duration: Math.floor(data.full_duration / 1000)
	}

	return response
}
