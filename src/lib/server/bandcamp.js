import { duration_to_seconds } from '$lib/date'
import { text } from '@sveltejs/kit'

/** @param {string} url */
async function get_track_details(url) {
	const res = await fetch(url)
	const html = await res.text()

	// there's a bit of JSON hidden in a <span> of the page. we can pick this up to extract some
	// data about this track
	const match = html.match(/({"@type":"MusicRecording".*})/)?.[1]

	if (match) {
		return JSON.parse(match)
	}

	throw new Error('failed to parse track details')
}

/**
 * @param {{ query: string }} params
 * @returns {Promise<ResolveResponse | Response>}
 */
export async function get_bandcamp_response({ query }) {
	let track
	try {
		track = await get_track_details(query)
	} catch (e) {
		return text('failed to fetch bandcamp track details', { status: 500 })
	}

	const track_id = track.additionalProperty.find(
		(/** @type {{ name: string; }} */ prop) => prop.name === 'track_id'
	).value

	// track.duration is someting like P00H04M02S, missing the 'T'
	const fixed_duration = 'PT' + track.duration.slice(1)

	return {
		player_url: `/bandcamp/${track_id}`,
		source_url: track.mainEntityOfPage,
		title: track.name,
		user: track.byArtist.name,
		duration: duration_to_seconds(fixed_duration)
	}
}
