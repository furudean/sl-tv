<script>
	/** @type {import('./$types').PageData} */
	export let data
</script>

<div class="video">
	<span>loading youtube embed...</span>
	<iframe
		width="560"
		height="315"
		src="https://www.youtube-nocookie.com/embed/{data.id}?autoplay=1"
		title="YouTube video player"
		frameborder="0"
		allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
		allowfullscreen
	/>
</div>

<style>
	.video {
		position: relative;
		width: 100vw;
		height: auto;
		aspect-ratio: 16 / 9;
    }

	span {
		position: absolute;
		z-index: -1;
		top: 50%;
		left: 50%;
		transform: translate(-50%, -50%);
		font-size: 2em;
		text-align: center;
		opacity: 50%;
	}

	iframe {
		display: block;
		width: 100%;
		height: 100%;
	}
</style>
