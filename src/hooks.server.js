/** @type {import('@sveltejs/kit').Handle} */
export async function handle({ event, resolve }) {
	const response = await resolve(event)

	if (
		['/bandcamp', '/soundcloud', '/youtube'].some((domain) => event.url.pathname.startsWith(domain))
	) {
		response.headers.append('Cache-Control', 'public, s-maxage=3600')
	}

	return response
}
