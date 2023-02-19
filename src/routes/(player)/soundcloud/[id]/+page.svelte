<script>
	import { onMount } from 'svelte'
	import PlayerContainer from '$lib/PlayerContainer.svelte'

	/** @type {import('./$types').PageData} */
	export let data

	const query =
		`https://api.soundcloud.com/tracks/${data.id}` +
		'&auto_play=true' +
		'&show_comments=true' +
		'&show_teaser=true' +
		'&visual=true'

	/** @type {HTMLIFrameElement} */
	let widget_element

	/** @type {any} */
	let widget

	onMount(() => {
		widget = SC.Widget(widget_element)

		widget.bind(SC.Widget.Events.READY, () => {
			if (data.timestamp) {
				widget.seekTo(data.timestamp * 1000)
			}
		})
	})
</script>

<svelte:head>
	<script src="https://w.soundcloud.com/player/api.js" defer></script>
</svelte:head>

<PlayerContainer>
	<iframe
		title="SoundCloud music player"
		src="https://w.soundcloud.com/player/?url={query}"
		width="560"
		height="315"
		scrolling="no"
		frameborder="no"
		allow="autoplay"
		bind:this={widget_element}
	/>
</PlayerContainer>

<style>
	iframe {
		display: block;
		width: 100%;
		height: 100%;
	}
</style>
