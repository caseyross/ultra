<template lang="pug">
</template>

<style type="text/stylus">
</style>

<script type="text/coffeescript">
    # docs: https://github.com/reddit-archive/reddit/wiki/OAuth2#application-only-oauth
    # docs: https://www.reddit.com/dev/api
    (() ->
        body = new FormData()
        body.append('grant_type', 'https://oauth.reddit.com/grants/installed_client')
        body.append('device_id', 'DO_NOT_TRACK_THIS_DEVICE')
        response = await fetch('https://www.reddit.com/api/v1/access_token', {
            method: 'POST'
            headers:
                'Authorization': 'Basic SjZVcUg0a1lRTkFFVWc6'
            body
        })
        { token_type, access_token } = await response.json()
        response = await fetch('https://oauth.reddit.com/best', {
            method: 'GET'
            headers:
                'Authorization': token_type + ' ' + access_token
        })
        { data } = await response.json()
        console.log data
    )()
</script>