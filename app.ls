require! [ './db.ls' ]

apps = null

handlers =

  #########################################################################

  # TODO: Limit info length and further validate input
  post: (session, data, callback) !->
    unless session.user?
      callback error: 22
      return

    # TODO: Only let verified users post
    # TODO: Consider marking all apps hidden to public by default (or warning)

    entry =
      data
      poster:
        id:       session.user._id
        username: session.user.username
      upload-date: new Date!
      queries: 0

    unless entry.data?
      callback error: 21
      return

    # TODO: Copy needed values from data; this is dangerous
    err <-! apps.insert entry
    if err then throw err

    callback success: true

  #########################################################################

  list: (session, data, callback) !->
    err, docs <-! apps.find!.sort $natural: 1 .to-array!
    if err then throw err

    callback apps: docs

  #########################################################################

export get-handlers = (callback) !-> if apps? then callback handlers else db.collection \apps !-> apps := it; callback handlers
