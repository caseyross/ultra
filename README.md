# Arc: a modern, user-friendly UI for reddit

## Try it

https://arc-ui.com

## Features

- Clean, user-friendly UI
- Extremely fast (faster than old.reddit.com)
- Carefully optimized for ease of reading
- Video player that works
- Self-hostable

## Self-hosting

Arc is a static HTML site with lots of JavaScript. You can self-host it via the following steps:

- Download the code. Run `npm` in the code directory to install needed NPM modules. Then, run `npm run build` to generate all needed site files, which will appear in the /dist directory. The contents of this directory can then be uploaded to any web hosting platform of your choice. You will need to configure such platform to route all incoming requests to the site to `index.html`.

(Optional) You can "bake-in" your reddit API credentials to the build so that it does not automatically run in Demo Mode. To do this, add a file named `.env` to the root directory with a line stating `API_CLIENT_ID=<your-client-id>`, then build the site files as normal.

## Privacy policy

Arc collects no data from you --- zero.

If you use arc-ui.com, you will appear in my web host's anonymized analytics (current web host: Cloudflare).

Reddit collects lots of data from you, so be aware.