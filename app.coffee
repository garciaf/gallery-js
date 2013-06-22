express = require "express"
routes = require "./routes"
security= require './routes/security'
passport = require 'passport'
flash = require 'connect-flash'
http = require "http"
path = require "path"
auth = require ('./auth')


lessMiddleware = require 'less-middleware'
formidable = require('formidable')
app = express()
app.configure ->
  app.set "port", process.env.PORT or 3300
  app.set "views", "#{__dirname}/views"
  app.set "view engine", "hbs"
  app.set 'view options',
    layout: false
  app.use express.favicon()
  app.use express.bodyParser(
    keepExtensions: true
  )    
  app.use express.logger()
  app.use express.cookieParser()
  app.use express.methodOverride()
  app.use express.session(secret: "keyboard cat")
  app.use flash()
  
  # Initialize Passport!  Also use passport.session() middleware, to support
  # persistent login sessions (recommended).
  app.use passport.initialize()
  app.use passport.session()
  app.use app.router
  app.use lessMiddleware(
    dest: "#{__dirname}/public/css"
    src: "#{__dirname}/public/less"
    once: true
    prefix: '/css'
    debug: false
    compress: true
  )  
  app.use express.static "#{__dirname}/public"
app.configure "dev", ->
  app.use express.errorHandler()

app.all "/admin/*", auth.EnsureAuthenticated

app.post "/admin/file", routes.save

app.get "/admin/post", routes.post

app.get "/albums", routes.albums

app.get "/login", security.login

app.post "/login", security.authenticate, routes.post

app.get "/logout", security.logout

app.get "/albums/:folder", routes.album

app.get "/", routes.index

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")