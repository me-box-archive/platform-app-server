export cache = {}

export handle = (request, session-ID, callback) !->
  unless session-ID? and session-ID of cache
    callback id: null
    return
  callback cache[session-ID]
