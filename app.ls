require! [ './db.ls' ]

apps = null

handlers =

  #########################################################################

  # TODO: Limit info length and further validate input
  post-app: (session, data, callback) !->
    unless session.id?
      callback error: 22
      return

    entry =
      data
      uploader:
        id:       session.user._id
        username: session.user.username
      upload-date: new Date!
      downloads: 0

    unless entry.data?
      callback error: 21
      return

    # TODO: Copy needed values from data; this is dangerous
    err <-! apps.insert entry
    if err then throw err

    callback success: true

  #########################################################################

  get-all-apps: (session, data, callback) !->
    err, docs <-! apps.find!.sort $natural: 1 .to-array!
    if err then throw err

    callback apps: docs

  #########################################################################

export get-handlers = (callback) !-> if apps? then callback handlers else db.collection \apps !-> apps := it; callback handlers
