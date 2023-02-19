<div class="container">
	<span>waiting for player...</span>
	<slot />
</div>

<style>
	.container {
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
		font-size: 1.5rem;
		text-align: center;
		opacity: 50%;
	}
</style>
