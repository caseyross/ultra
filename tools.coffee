export decode_reddit_html_entities = (text) ->
    text
    .replace(/&amp;/g, '&')
    .replace(/&quot;/g, '"')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')

import gfycat_adjectives from './gfycat-adjectives.json'
import gfycat_animals from './gfycat-animals.json'
export titlecase_gfycat_video_id = (video_id) ->
    match_words = () ->
        for adjective_1 in gfycat_adjectives
            if video_id.startsWith adjective_1
                for adjective_2 in gfycat_adjectives
                    if video_id[adjective_1.length...].startsWith adjective_2
                        for animal in gfycat_animals
                            if video_id[(adjective_1.length + adjective_2.length)...] == animal
                                return [adjective_1, adjective_2, animal]
        return ['', '', '']
    [adjective_1, adjective_2, animal] = match_words()
    if not (adjective_1 and adjective_2 and animal)
        gfycat_adjectives.reverse()
        [adjective_1, adjective_2, animal] = match_words()
        gfycat_adjectives.reverse()
    if not (adjective_1 and adjective_2 and animal)
        return ''
    adjective_1[0].toUpperCase() + adjective_1[1...] + adjective_2[0].toUpperCase() + adjective_2[1...] + animal[0].toUpperCase() + animal[1...]