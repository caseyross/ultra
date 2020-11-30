default_content =
    PAGE: Promise.resolve []
    ABOUT: Promise.resolve({})
    STORY: Promise.resolve({})

export default
    sync: (prev_content, prev_state, state) ->
        content = {
            ...default_content
            ...prev_content
        }
        if JSON.stringify(state.page) isnt JSON.stringify(prev_state.page)
            switch state.page.type
                when 'sm'
                    content.PAGE = Reddit.SMRPAGE state.page
                when 'r'
                    content.PAGE = Reddit.SMRPAGE state.page
                    content.ABOUT = Reddit.SRABOUT state.page
                when 'u'
                    content.PAGE = Reddit.USERPAGE state.page
                    content.ABOUT = Reddit.USERABOUT state.page
        ###
        content.STORY = Reddit.SINGLEPOST
            id: state.story.id
            comments_root_id: state.story.comments.root.id
            comments_root_parents: state.story.comments.root.parents
        ###
        return content