<script>
	import PlayerContainer from '$lib/PlayerContainer.svelte'

	/** @type {import('./$types').PageData} */
	export let data

	const query = '?autoplay=1' + (data.timestamp ? `&start=${data.timestamp}` : '')
</script>

<PlayerContainer>
	<iframe
		width="560"
		height="315"
		src="https://www.youtube-nocookie.com/embed/{data.id}{query}"
		title="YouTube video player"
		frameborder="0"
		allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
		allowfullscreen
	/>
</PlayerContainer>

<style>
	iframe {
		display: block;
		width: 100%;
		height: 100%;
	}
</style>
