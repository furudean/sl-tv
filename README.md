# sl-tv

sl-tv is an open source media player for second life. it allows you to play video & audio in a
somewhat synchronized fashion with other users in-world.

- supports youtube, bandcamp and soundcloud
- playing, skipping, queueing
- can list what's playing, queue and history on request
- controlled via chat commands

## system

the system consists of three components;

- a web frontend that embeds content from hosts
- LSL scripts that open & control said embeds as shared media in-world
- helpful APIs for parsing video metadata from provided URLs

how this works exactly is better detailed on [the homepage](https://tv.himawari.fun/)

## developing

in order to run the website and APIs, first install dependencies with
`npm install`.

start a development server:

```bash
npm run dev

# or start the server and open the app in a new browser tab
npm run dev -- --open
```

## Building

to create a production version of web and APIs:

```bash
npm run build
```

this spits out a node version of the app, but multiple adapters are supported.
check out [kit.svelte.dev/docs/adapters](https://kit.svelte.dev/docs/adapters)
for more information.

you can preview the production build with `npm run preview`.
