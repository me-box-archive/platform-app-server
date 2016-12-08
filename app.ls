require! { nedb: Datastore }

apps = new Datastore filename: 'data/db/apps.db' autoload: true

#########################################################################

# TODO: Limit info length and further validate input
export post = (session, data, callback) !->
  unless session.user?
    callback error: 22
    return

  # TODO: Only let verified users post
  # TODO: Consider marking all apps hidden to public by default (or warning)

  # TODO: Validate manifest!
  manifest = JSON.parse data?.manifest

  entry =
    manifest: manifest
    poster:
      id:       session.user._id
      username: session.user.username
    post-date: new Date!
    queries: 0

  unless entry.manifest?
    callback error: 21
    return

  # TODO: Copy needed values from data; this is dangerous
  # TODO: Check that version is further on upsert and validate
  err <-! apps.update 'manifest.name': manifest.name, entry, upsert: true
  if err then throw err

  callback success: true

#########################################################################

export list = (session, data, callback) !->
  err, docs <-! apps.find {}
  if err then throw err

  callback apps: docs

#########################################################################

export get = (session, data, callback) !->
  err, doc <-! apps.find-one 'manifest.name': data.name
  if err then throw err

  unless doc?
    callback error: 23
    return

  callback doc
