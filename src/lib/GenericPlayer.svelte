<script>
	import { fmt_duration } from '$lib/date'
	import { onMount, onDestroy } from 'svelte'
	import tinycolor from 'tinycolor2'

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

	/** @type {string} */
	export let theme_color

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

	$: text_color_class = tinycolor(theme_color)?.isLight() ? 'text-dark' : 'text-light'
</script>

<audio
	{src}
	hidden
	preload="auto"
	on:play={on_play}
	on:pause={on_pause}
	bind:this={audio_element}
/>

<div class="container {text_color_class}" style:--background={theme_color}>
	<button class="player" class:paused={!is_playing} on:click={toggle_play}>
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
				<div class="progress-bar">
					<div
						class="progress-inner"
						style:--width="{Math.floor((current_time / duration) * 100)}%"
					/>
				</div>
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
		background: var(--background);
		padding: 0 4em;
		display: grid;
		place-items: center center;
		color: black;
	}

	.container.text-light {
		color: white;
	}

	.player {
		all: unset;
		display: flex;
		height: 60%;
		width: 100%;
		max-height: auto;
		gap: 3em;
		transform: scale(1);
		transition: transform 200ms cubic-bezier(0.4, 0, 0.2, 1);
	}

	.player.paused {
		transform: scale(0.9);
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

	.progress-bar {
		display: block;
		width: 100%;
		height: 4px;
		margin-top: 0.5em;
		position: relative;
	}

	.progress-bar::after {
		content: '';
		position: absolute;
		inset: 0;
		background: currentColor;
		opacity: 0.5;
	}

	.progress-inner {
		height: 100%;
		width: var(--width);
		background: currentColor;
	}
</style>
