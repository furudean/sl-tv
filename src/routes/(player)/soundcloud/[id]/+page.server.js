/** @type {import('./$types').PageServerLoad} */
export async function load({ params, url }) {
	const t = url.searchParams.get('t')
	return {
		id: params.id,
		timestamp: t ? Number(t) : undefined
	}
}
