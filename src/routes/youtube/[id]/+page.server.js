/** @type {import('./$types').PageServerLoad} */
export async function load({ params, url }) {
	return {
		id: params.id,
		timestamp: url.searchParams.get('t')
	}
}
