<main class="container">
	<div class="prose">
		<h1>(media paused)</h1>
		<p class="shy">play with <code>resume</code> command</p>
	</div>
</main>

<style>
	.container {
		position: relative;
		width: 100vw;
		height: auto;
		aspect-ratio: 16 / 9;
		overflow: hidden;
	}

	.container::before {
		content: '';
		position: absolute;
		inset: 0;
		background: var(--bg);
		background-size: 100%;
		background-repeat: no-repeat;
		filter: blur(6px);
	}

	.container::after {
		content: '';
		position: absolute;
		inset: 0;
		background: rgba(0, 0, 0, 0.75);
		background-size: 100%;
		background-repeat: no-repeat;
	}

	div {
		z-index: 1;
		position: absolute;
		top: 50%;
		left: 50%;
		transform: translate(-50%, -50%);
		text-align: center;
	}

	.shy {
		opacity: 0.75;
	}
</style>
