import { duration_to_seconds } from '$lib/date'
import { text } from '@sveltejs/kit'
import { decode as decode_html_entities } from 'html-entities'

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
 * @param {string} track_id
 * @param {typeof fetch} fetch
 */
async function fetch_player_data(track_id, fetch) {
	const request = await fetch(`https://bandcamp.com/EmbeddedPlayer/track=${track_id}`)

	if (!request.ok) throw new Error('failed to load soundcloud embed')

	const text = await request.text()

	const match = text.match(/data-player-data="([^"]*)"/)?.[1]

	if (!match) throw new Error('could not get player data')

	const json = decode_html_entities(match)

	return JSON.parse(json)
}

/**
 * @param {{ query: string, fetch: typeof fetch }} params
 * @returns {Promise<ResolveResponse | Response>}
 */
export async function get_bandcamp_response({ query, fetch }) {
	if (query.includes('/album/')) {
		return text('only supports bandcamp tracks, not albums', { status: 400 })
	}

	let track
	try {
		track = await get_track_details(query)
	} catch (e) {
		return text('failed to fetch bandcamp track details', { status: 500 })
	}

	const track_id = track.additionalProperty.find(
		(/** @type {{ name: string; }} */ prop) => prop.name === 'track_id'
	).value

	let player_data

	try {
		player_data = await fetch_player_data(track_id, fetch)
		console.log(player_data)
		const player_data_track = player_data.tracks[0]
		if (!player_data_track.track_streaming) {
			return text('track is not available for streaming', { status: 403 })
		}
	} catch (e) {
		console.error('failed to fetch player data, continuing', e)
	}

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
