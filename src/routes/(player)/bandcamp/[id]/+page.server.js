import { error } from '@sveltejs/kit'
import { decode as decode_html_entities } from 'html-entities'
import probe from 'probe-image-size'

/**
 * @param {string} track_id
 * @param {typeof fetch} fetch
 */
async function fetch_player_data(track_id, fetch) {
	const request = await fetch(`https://bandcamp.com/EmbeddedPlayer/track=${track_id}`)

	if (!request.ok) throw error(500, 'failed to load soundcloud embed')

	const text = await request.text()

	const match = text.match(/data-player-data="([^"]*)"/)?.[1]

	if (!match) throw error(500, 'could not get player data')

	const json = decode_html_entities(match)

	return JSON.parse(json)
}

/** @type {import('./$types').PageServerLoad} */
export async function load({ params, url, fetch }) {
	const t = url.searchParams.get('t')

	const data = await fetch_player_data(params.id, fetch)
	const track = data.tracks[0]

	const album_art = await probe(data.album_art_lg)

	if (!track.track_streaming) throw error(403, 'track does not support streaming')

	return {
		timestamp: t ? Number(t) : undefined,
		album_title: data.album_title,
		album_art,
		track: track.file,
		track_artist: track.artist,
		track_title: track.title,
		track_duration: track.duration
	}
}
