<script>
	import PlayerContainer from '$lib/PlayerContainer.svelte'
	import GenericPlayer from '$lib/GenericPlayer.svelte'

	/** @type {import('./$types').PageData} */
	export let data
</script>

<PlayerContainer>
	<GenericPlayer
		src={data.track['mp3-128']}
		title={data.track_title}
		artist={data.track_artist}
		cover={data.cover_art}
		theme_color={data.theme_color}
		start={data.timestamp}
		duration={data.track_duration}
	/>
</PlayerContainer>
