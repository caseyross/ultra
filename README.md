(**Status**: Usable, but longer under active development, due to Reddit's 2023 API changes.)

# ultrareddit

## description

Ultrareddit is a Reddit UI ("client") written in JavaScript.

It aims to provide a minimalist, highly refined interface that includes only essential features and avoids needless complications.

## feedback

If you have feedback, please open an issue or a discussion here. I can't promise to address all feedback but I would love to hear from anyone using the app.

## privacy

The app collects no data, and I don't have the ability to see any of your Reddit activity. After loading the app code, your connection is exclusively to Reddit's servers.

## self-host info

The app is a static site with all functionality provided via JavaScript. If desired, you can self-host it through the following steps (which can also be automated, as they're pretty standard):

1) Download the repository code.
2) Add a file named `.env` to the root of repository with the following line: `API_CLIENT_ID=<your-client-id>` (replace `<your-client-id>` with your own Reddit API client ID). You can also use an environment variable to accomplish the same thing.
3) In your terminal, run `npm` in the code directory to install needed NPM modules.
4) Run `npm run build` to generate all needed site files, which will appear in the `dist` directory.
5) Upload the contents of the `dist` directory to a web hosting platform of your choice.
6) Configure your web hosting platform to route all incoming requests for the site to `index.html`.
