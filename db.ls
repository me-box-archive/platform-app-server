require! { mongodb, './config.json' }

_db = null

connect = (callback) !->
  err, db <-! mongodb.MongoClient.connect ('mongodb://' + config.mongodb.user + ':' + config.mongodb.pass + '@' + config.mongodb.host + ':' + config.mongodb.port + '/' + config.mongodb.db)
  if err then throw err
  _db := db
  callback db

export mongodb.ObjectID
export collection = (name, callback) !-> if _db? then name |> _db.collection |> callback else connect !-> name |> it.collection |> callback
