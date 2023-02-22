<script>
	import { fmt_duration } from '$lib/date'
	import { onMount, onDestroy } from 'svelte'

	/** @type {string} */
	export let src

	/** @type {string} */
	export let title

	/** @type {string} */
	export let artist

	/** @type {{ url: string, width: number, height: number }} */
	export let cover

	/** @type {number} */
	export let duration

	/** @type {number} */
	export let start = 0

	let is_playing = false
	let current_time = start

	/** @type {NodeJS.Timer} */
	let interval

	/** @type {HTMLAudioElement} */
	let audio_element

	function on_play() {
		is_playing = true
		interval = setInterval(() => {
			current_time = audio_element.currentTime
		}, 1000)
	}

	function on_pause() {
		is_playing = false
		clearInterval(interval)
	}

	function toggle_play() {
		audio_element.paused ? audio_element.play() : audio_element.pause()
	}

	onMount(() => {
		audio_element.currentTime = current_time
		audio_element.play()
	})

	onDestroy(() => {
		clearInterval(interval)
	})
</script>

<audio
	{src}
	hidden
	preload="auto"
	on:play={on_play}
	on:pause={on_pause}
	bind:this={audio_element}
/>

<div class="container">
	<button class="player" on:click={toggle_play}>
		<div class="cover-art">
			<img src={cover.url} alt="Cover art" height={cover.height} width={cover.width} />
		</div>
		<div class="details">
			<div class="title-artist">
				<h1>{title}</h1>
				<h2>{artist}</h2>
			</div>

			<div class="progress">
				<span class="current">
					{fmt_duration(current_time)}
				</span>

				<span class="remaining">
					-{fmt_duration(duration - current_time)}
				</span>
				<progress value={Math.floor(current_time)} max={Math.floor(duration)} />
			</div>
		</div>
	</button>
</div>

<style>
	.container {
		font-size: 2vw;
		box-sizing: border-box;
		height: 100%;
		width: 100%;
		position: relative;
		background: black;
		padding: 0 4em;
		display: grid;
		place-items: center center;
	}

	.player {
		all: unset;
		display: flex;
		height: 60%;
		width: 100%;
		max-height: auto;
		gap: 3em;
	}

	.cover-art {
		width: 40%;
	}

	.cover-art img {
		display: block;
		height: 100%;
		width: 100%;
		object-fit: contain;
	}

	.details {
		width: 60%;
		flex: 1 0 auto;
		display: flex;
		flex-direction: column;
		justify-content: center;
	}

	h2 {
		opacity: 0.75;
		margin-top: 0.5em;
	}

	.progress {
		margin-top: 2em;
		font-variant-numeric: slashed-zero tabular-nums;
		width: 100%;
	}

	.remaining {
		float: right;
	}

	progress {
		all: unset;
		display: block;
		width: 100%;
		height: 4px;
		background: grey;
		margin-top: 0.5em;
	}

	::-webkit-progress-bar {
		background: currentColor;
	}
	::-webkit-progress-value {
		background: currentColor;
	}
	::-moz-progress-bar {
		background: currentColor;
	}
</style>
