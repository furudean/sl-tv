// See https://kit.svelte.dev/docs/types#app
// for information about these interfaces
declare global {
	namespace App {
		// interface Error {}
		// interface Locals {}
		// interface PageData {}
		// interface Platform {}
	}

	// soundcloud widget global
	// types some day maybe probably not
	declare const SC: any

	declare interface ResolveResponse {
		player_url: string
		source_url: string
		title: string
		user: string
		duration: number
		requested_by?: string
		play_skip: boolean
	}
}

export {}
