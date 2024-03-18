<script>
	import texture_options from './texture_options.png'
	import { persistent } from '@furudean/svelte-persistent-store'

	const open = persistent({
		key: 'how-it-works-open',
		start_value: false,
		storage_type: 'localStorage'
	})

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
		<li>playing, skipping, queueing</li>
		<li>can list what's playing, queue and history on request</li>
		<li>controlled via chat commands</li>
	</ul>

	<p>
		visit <a href="https://github.com/furudean/sl-tv">github.com/furudean/sl-tv</a> for code
	</p>

	<h2>commands</h2>

	<p>
		the screen listens for chat messages in chat, on a specific channel. by default, this channel is <code
			>-1312</code
		>. you can change it if you need to by editing the script.
	</p>

	<dl>
		<dt><code>&lt;url&gt;</code></dt>
		<dd>play media from a url</dd>
		<dd>example: <code>/-1312 https://youtu.be/tN-C8-YZy24</code></dd>

		<dt><code>playskip &lt;url&gt;</code></dt>
		<dd>play media from a url immediately, skipping the line</dd>
		<dd>
			example: <code>/-1312 playskip https://youtu.be/tN-C8-YZy24</code>
		</dd>

		<dt><code>np</code></dt>
		<dd>show what's currently playing</dd>

		<dt><code>pause</code></dt>
		<dd>pause the current playback</dd>

		<dt><code>resume</code></dt>
		<dd>resume the current playback</dd>

		<dt><code>stop</code></dt>
		<dd>end the current session. this ejects any queued items.</dd>

		<dt><code>seek &lt;time&gt;</code></dt>
		<dd>seek the current playback to a timestamp</dd>
		<dd>example: <code>/-1312 seek 1:30</code></dd>

		<dt><code>skip</code></dt>
		<dd>jump to the next thing in the queue</dd>

		<dt><code>sync</code></dt>
		<dd>
			sync all listeners to the current timestamp. this is useful if someone's lagging behind.
		</dd>

		<dt><code>history</code>/<code>h</code></dt>
		<dd>show past things that were played</dd>

		<dt>
			<code>about</code>/<code>info</code>/<code>help</code>
		</dt>
		<dd>show information about the screen</dd>
	</dl>

	<h2>setup</h2>
	<p>
		the script <a href="https://github.com/furudean/sl-tv/blob/main/scripts/tv.lsl" rel="external">
			tv.lsl
		</a> should be placed in a prim that you want to be used as the TV. you may want to adjust any settings
		in the script, especially the channel.
	</p>
	<p>
		you may also be interested in the <a
			href="https://github.com/furudean/sl-tv/blob/main/scripts/remote.lsl"
			rel="external">remote.lsl</a
		> script, which is a more user friendly way to control the TV via hud instead of chat.
	</p>

	<p>
		the prim the media is projected on should have its dimensions set to a 16:9 aspect ratio to
		display with the right aspect ratio. for example, <code>&lt;7.11, 1.0, 4.0&gt;</code>.
	</p>
	<p>
		media will play from face 3 by default (which usually corresponds to forward). the texture
		should be set to have a 16:9 aspect ratio. <a
			href="https://wiki.secondlife.com/wiki/Face"
			rel="external">see second life documentation on faces</a
		>
		for more information.
	</p>
	<figure>
		<img src={texture_options} alt="second life texture mapping" width="292" height="214" />
		<figcaption>an example of how to apply the texture to the projected surface</figcaption>
	</figure>
	<p>
		when the screen is playing something, the texture named <code>on</code> in the prim will be
		shown on the media face. conversely, the texture <code>off</code> will be shown when nothing is playing.
		feature helps inform people that something is playing, and how they can join in.
	</p>

	<details bind:open={$open}>
		<summary class="h2">how it works</summary>

		<p>
			once the screen receives a command, it will parse the message and execute it. for some
			commands, this means contacting a web server to fetch information about the media you want to
			play.
		</p>
		<p>
			an example of this is the play command, which will need to match the URL provided against a
			metadata service. we use the endpoint <code
				><a
					href="https://github.com/furudean/sl-tv/blob/main/src/routes/resolve/%2Bserver.js"
					rel="external">/resolve</a
				></code
			>
			to do this, which is hosted on this website. for example,
			<code
				><a href="/resolve?q=https://youtu.be/-zAbSroLfOs">/resolve?q=https://youtu.be/-zAbSroLfO</a
				></code
			> will respond with a payload like this:
		</p>
		<pre><code>{payload}</code></pre>

		<p>
			the script will add this metadata to the queue, and then when its time to play, sets the media
			url to <code>player_url</code>. in this case, that would be
			<a href="/youtube/-zAbSroLfOs">/youtube/-zAbSroLfOs</a>. this is a slim page that embeds the
			youtube video.
		</p>

		<p>all media providers in sl-tv work similarly. here are some examples of hosted players</p>
		<ul>
			<li>
				<a href="/youtube/-zAbSroLfOs">/youtube/-zAbSroLfOs</a> - youtube
			</li>
			<li>
				<a href="/bandcamp/86555894">/bandcamp/86555894</a> - bandcamp
			</li>
			<li>
				<a href="/soundcloud/1594041948">/soundcloud/1594041948</a> - soundcloud
			</li>
		</ul>
	</details>
</main>
