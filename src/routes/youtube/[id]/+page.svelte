<script>
	/** @type {import('./$types').PageData} */
	export let data
</script>

<iframe
	width="1000"
	height="562"
	src="https://www.youtube-nocookie.com/embed/{data.id}?autoplay=1"
	title="YouTube video player"
	frameborder="0"
	allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
	allowfullscreen
/>

<style>
	iframe {
		display: block; 
		width: 100vw;
		height: auto;
		aspect-ratio: 16 / 9;
    }
</style>
