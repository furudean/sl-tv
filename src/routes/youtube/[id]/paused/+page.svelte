<script>
	/** @type {import('./$types').PageData} */
	export let data

	const background = `url(https://i3.ytimg.com/vi/${data.id}/maxresdefault.jpg)`
</script>

<main class="container" style:--bg={background}>
	<span>paused</span>
</main>

<style>
	.container {
		position: relative;
		width: 100vw;
		height: auto;
		aspect-ratio: 16 / 9;
    }

	.container::before {
		content: "";
		position: absolute;
		inset: 0;
		background: var(--bg);
		background-size: 100%;
		background-repeat: no-repeat;
		filter: blur(4px);
	}

	.container::after {
		content: "";
		position: absolute;
		inset: 0;
		background: rgba(0, 0, 0, 0.75);
		background-size: 100%;
		background-repeat: no-repeat;
	}

	span {
		z-index: 1;
		position: absolute;
		top: 50%;
		left: 50%;
		transform: translate(-50%, -50%);
		font-size: 4em;
		text-align: center;
	}
</style>
