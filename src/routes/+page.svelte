<script>
	import texture_options from './texture_options.png'

	const payload = JSON.stringify(
		{
			player_url: '/youtube/-zAbSroLfOs',
			source_url: 'https://youtu.be/-zAbSroLfOs',
			title: 'Bright Future Original Soundtrack - Jellyfish Theme',
			user: 'Jasdko Sasjlas',
			duration: 280
		},
		null,
		'\t'
	)
</script>

<svelte:head>
	<title>sl-tv</title>
</svelte:head>

<main class="prose">
	<h1>sl-tv</h1>
	<p>
		sl-tv is an open source media player for second life. it allows you to play youtube videos in a
		somewhat synchronized fashion with other users in-world.
	</p>

	<ul>
		<li>supports youtube, bandcamp and soundcloud</li>
		<li>has queueing and history system</li>
		<li>controls to skip to the next song or stop playback</li>
		<li>can be controlled via chat commands</li>
	</ul>

	<p>
		visit <a href="https://github.com/furudean/sl-tv">github.com/furudean/sl-tv</a> for complete documentation
	</p>

	<h2>how it works</h2>
	<p>
		you send commands to the screen by sending a message in chat.<br /> the format is
		<code>/&lt;channel&gt; &lt;command&gt;</code>. for example, <code>/-1312 seek 1:30</code> will seek
		the current playback to 90 seconds.
	</p>

	<p>
		once the screen receives a command, it will parse the message and execute the command. for some
		commands, this means contacting a web server to fetch information about the media you want to
		play. an example of this is the play command, which will fetch the media's metadata on the
		endpoint <a href="/resolve?q=https://youtu.be/-zAbSroLfOs"
			><code>/resolve?q=https://youtu.be/-zAbSroLfOs</code></a
		>, which responds with a payload like so:
	</p>

	<pre><code>{payload}</code></pre>

	<p>
		the player will then go to the url specified in the <code>player_url</code>. in this case, that
		would be <a href="/youtube/-zAbSroLfOs">/youtube/-zAbSroLfOs</a>. this is a slim page that
		embeds a youtube video.
	</p>

	<h2>commands</h2>

	<p>
		the screen listens for chat messages in chat, on a specific channel. by default, this channel is <code
			>-1312</code
		>. you can change it if you need to by editing the script.
	</p>

	<ul>
		<li>
			<code>&lt;url&gt;</code> - play media from a url. example:
			<code>/-1312 https://youtu.be/tN-C8-YZy24</code>
		</li>
		<li>
			<code>np</code> - show what's currently playing
		</li>
		<li>
			<code>pause</code> - pause the current playback
		</li>
		<li>
			<code>resume</code> - resume the current playback
		</li>
		<li>
			<code>stop</code> - stop the current playback
		</li>
		<li>
			<code>seek &lt;time&gt;</code> - seek the current playback to a time. example:
			<code>/-1312 seek 1:30</code>
		</li>
		<li>
			<code>skip</code> - jump to the next media in the queue
		</li>
		<li>
			<code>sync</code> - sync all listeners to the current timestamp. this is useful if someone's lagging
			behind.
		</li>
		<li>
			<code>queue</code>/<code>q</code> - add a media to the queue
		</li>
		<li>
			<code>history</code>/<code>h</code> - show the last 10 played media
		</li>
	</ul>

	<h2>screen info</h2>
	<ul>
		<li>
			the face the media is projected on should have its dimensions set to a 16:9 aspect ratio to
			display correctly. for example, <code>&lt;7.11, 1.0, 4.0&gt;</code>.
		</li>
		<li>
			media will play from face 3 by default (which usually corresponds to forward). the texture
			should also be set to have a 16:9 aspect ratio.
			<figure>
				<img src={texture_options} alt="second life texture mapping" width="292" height="214" />
				<figcaption>an example of how to apply the texture to the projected surface</figcaption>
			</figure>
		</li>
		<li>
			when the screen is playing something, the texture named <code>on</code> in the prim will be
			shown on the default media face. conversely, the texture <code>off</code> will be shown when nothing
			is playing. this is to let people with autoplay disabled know that something is playing.
		</li>
	</ul>
</main>
