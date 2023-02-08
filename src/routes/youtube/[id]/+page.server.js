/** @type {import('./$types').PageServerLoad} */
export async function load({ params }) {
	return {
		id: params.id
	}
}
