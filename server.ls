#!/usr/bin/env lsc

require! [ http, url, querystring, connect, fs, './user.ls', './app.ls', './session.ls' ]

handlers = {}

user-handlers <-! user.get-handlers
app-handlers  <-! app.get-handlers

handlers <<<< user-handlers
handlers <<<< app-handlers

on-request = (request, response) !->
  url-obj = url.parse request.url, true
  action = url-obj.pathname.slice 1

  if action not of handlers
    response.write-head 404
    response.end!
    return

  handle = (session, data)!->
    res = {} <-! handlers[action] session, data
    if res.redirect?
      response.write-head 302 \Location: res.redirect
      response.end!
      return
    response.write-head 200,
      \Access-Control-Allow-Origin : request.headers.origin
      \Content-Type : \application/json
    response.end JSON.stringify res

  data = null

  if request.method is \GET
     handle null url-obj.query
  else if request.method is \POST
    body = ''
    request
      ..on \data, !->
        body += it

        if body.length > 1e6
          request.connection.destroy!

      ..on \end, !->
        query = querystring.parse body
        session <-! session.handle request, query.session-ID
        data = query.data
        try
          data = JSON.parse data
        catch
          response.write-head 400
          response.end!
          return
        handle session, data

#err, data <-! fs.read-file 'data/session-cookie-keys.txt', encoding: \utf8

connect!
  ..use on-request
  http.create-server ..
    .listen(8080)
