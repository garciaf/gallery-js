users = require "./config/user.json"
passport = require 'passport'
LocalStrategy = require("passport-local").Strategy

# asynchronous verification, for effect...
ensureAuthenticated = (req, res, next) ->
  return next()  if req.isAuthenticated()
  res.redirect "/login"

findById = (id, fn) ->
  idx = id - 1
  if users[idx]
    fn null, users[idx]
  else
    fn new Error("User " + id + " does not exist")
findByUsername = (username, fn) ->
  i = 0
  len = users.length

  while i < len
    user = users[i]
    return fn(null, user)  if user.username is username
    i++
  fn null, null

passport.serializeUser (user, done) ->
  done null, user.id

passport.deserializeUser (id, done) ->
  findById id, (err, user) ->
    done err, user



passport.use new LocalStrategy((username, password, done) ->
  
  # asynchronous verification, for effect...
  process.nextTick ->

    findByUsername username, (err, user) ->
      return done(err)  if err
      unless user
        return done(null, false,
          message: "Unknown user " + username
        )
      unless user.password is password
        return done(null, false,
          message: "Invalid password"
        )
      done null, user
)

passport = exports.passport = passport
EnsureAuthenticated = exports.EnsureAuthenticated = ensureAuthenticated