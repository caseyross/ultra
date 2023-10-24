Arc is a carefully crafted, thoughtfully designed, performance-optimized web UI for www.reddit.com.

You can try it out at: https://www.arc-ui.com

## Privacy

I (the developer) don't collect any data from you.

Arc maintains some data on your computer, notably a list of what posts you've read (for your convenience).

Reddit, obviously, collects data based on your usage of the site.

## Self-hosting

You can self-host the application anywhere --- it's just a static site that interfaces with the Reddit API via JS.

To build the site:
```
npm run build
```

Built files will appear in the `dist` directory. These should be uploaded to the root of a web server. Additionally, the server should be configured to serve `index.html` for all paths.

You will need to add your own Reddit application credentials, or the application will remain in "demo mode" and be limited by Reddit terms of use. You can do this by either:

1. (preferred) Create a `.env` file in the root of the code directory prior to building the site, with the following line: `API_CLIENT_ID=<your-client-id-here>`. This client ID will then be baked into the application during the build step.

2. You can simply use the standard Arc "demo-mode" popup to add your own client ID. However, this will only be stored in your browser, so if you clear your browser storage, you will need to configure the client ID again.

If you want to be able to log in, make sure to set your "redirect URI" in the Reddit interface to the URL of where the application is hosted.