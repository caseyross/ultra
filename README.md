Ultra is a minimalist, performance-focused UI ("client") for reddit.com. It runs in your web browser as a static webpage.

## Data policy

Ultra does not collect or store any user data, except for a minimal amount of configuration data that never leaves your computer. Your usage is conducted entirely between you and reddit.com servers.

## Self-host guide

Ultra is deployed as a static website with all functionality provided through client-side JS. You can self-host it through the following steps. This process is easily automatable for deployments on cloud services.

1) Clone the repository.
2) Using `npm` or a similar tool, execute `npm run build` in the root directory (where this README is located), which will build the website files from source and place them in the `dist` folder.
3) Upload the contents of the `dist` folder to any web server, and configure the web server to route all incoming requests to `/` (index.html).

## Future roadmap

Unlikely, due to loss of confidence in reddit.com as a platform after 2023 API changes.