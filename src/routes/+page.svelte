<script>
    import texture_options from "./texture_options.png";
</script>

<svelte:head>
    <title>sl-tv</title>
</svelte:head>

<main class="prose">
    <h1>sl-tv</h1>
    <p>
        sl-tv is an open source video player system for second life. it allows you to play youtube 
        videos in a somewhat synchronized fashion with other users in-world.
    </p>

    <ul>
        <li>supports youtube videos</li>
        <li>has queuing system</li>
        <li>controls to skip to the next song or stop playback</li>
    </ul>

    <p>
        visit <a href="https://github.com/furudean/sl-tv">github.com/furudean/sl-tv</a> for complete documentation
    </p>

    <h2>screen info</h2>
    <ul>
        <li>
            the prim the media is projected on should be a 16:9 aspect ratio to display correctly. you can start with something like <code>&lt;7.11, 0.1, 4.0&gt;</code> and then use the corner handles to scale things how you like them. see texture mappings on the image below.
        </li>
        <li>
            media will always play from face 3 (which usually corresponds to forward), if you need something else, it can be changed in the script.
        </li>
        <li>
            when the screen is playing something, the texture named <code>on</code> in the prim will be shown on the default media face. conversely, the texture <code>off</code> will be shown when nothing is playing. this is to let people with autoplay disabled know that something is playing, and how they can join in.
        </li>
    </ul>

    <figure>
        <img src={texture_options} alt="second life texture mapping" width="292" height="214">
        <figcaption>
            for optimal results, these settings should be applied on the texture tab on the media face. this corresponds to a 16:9 aspect ratio.
        </figcaption>
    </figure>

    <h2>communication protocol</h2>
    <p>
        the <b>remote</b> object sends commands to the <b>screen</b> via chat, on the channel <code>-333</code>, which is hidden to avatars. you don't need a remote to operate things, for example try 
        <code>/-333 https://youtu.be/tN-C8-YZy24</code> in chat to add something to the queue.
    </p>
    <p>
        visit <a href="https://github.com/furudean/sl-tv">github.com/furudean/sl-tv</a> for more details on functions.
    </p>
</main>
