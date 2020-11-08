import { SMRPAGE, SRABOUT, USERPAGE, USERABOUT, SINGLEPOST } from '/proc/api.coffee'

base_content =
    PAGE: Promise.resolve []
    ABOUT: Promise.resolve({})
    STORY: Promise.resolve({})

export sync_content = (prev_content, prev_state, state) ->
    content = {
        ...base_content
        ...prev_content
    }
    if JSON.stringify(state.page) isnt JSON.stringify(prev_state.page)
        switch state.page.type
            when 'sm'
                content.PAGE = SMRPAGE state.page
            when 'r'
                content.PAGE = SMRPAGE state.page
                content.ABOUT = SRABOUT state.page
            when 'u'
                content.PAGE = USERPAGE state.page
                content.ABOUT = USERABOUT state.page
    ###
    content.STORY = SINGLEPOST
        id: state.story.id
        comments_root_id: state.story.comments.root.id
        comments_root_parents: state.story.comments.root.parents
    ###
    return content

###
if document.state.object_id
    object.load_comments()
    cache[document.state.object_id] = Date.now() / 1000
###