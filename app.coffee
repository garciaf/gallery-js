express = require "express"
routes = require "./routes"
imageHandler = require "#{__dirname}/lib/image"
http = require "http"
path = require "path"
fs = require "fs"
util = require 'util'
md5 = require 'MD5'
im = require 'imagemagick'
config = require "#{__dirname}/config/user.json"
thumbPath = "#{__dirname}/#{config.thumb_folder}"
imagePath = "#{__dirname}/#{config.upload_folder}"


lessMiddleware = require 'less-middleware'
formidable = require('formidable')
app = express()
app.configure ->
  app.set "port", process.env.PORT or 3000
  app.set "views", "#{__dirname}/views"
  app.set "view engine", "hbs"
  app.set 'view options',
    layout: "layout"
  app.use express.favicon()
  app.use express.logger("dev")
  app.use express.bodyParser(
    keepExtensions: true
  )    
  app.use express.methodOverride()
  app.use express.cookieParser("your secret here")
  app.use express.session()
  app.use app.router
  app.use lessMiddleware(
    dest: "#{__dirname}/public/css"
    src: "#{__dirname}/public/less"
    once: false
    prefix: '/css'
    debug: true
    compress: true
  )  
  app.use express.static "#{__dirname}/public"
app.configure "dev", ->
  app.use express.errorHandler()

app.post "/file", imageHandler.uploadPicture

app.get "/post", routes.post

app.get "/", routes.index

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")