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


getExtension = (filename) ->
  i = filename.lastIndexOf(".")
  (if (i < 0) then "" else filename.substr(i))

app.get "/pictures", (req, res) ->
  
  pictures = fs.readdirSync("#{imagePath}")
  for fileName in pictures
    do (fileName) =>

      imageHandler.generateThumb fileName, (err, res)->
        if err? then console.log err
  res.send config

app.post "/file", (req, res) ->
  image = req.files.image
  unless image?.type is "image/jpeg"
    res.send 404 
  data = fs.readFileSync image.path
  

  ext = imageHandler.getExtension(image.name)  
  md5Name = "#{md5(data)}#{ext}"
  console.log ext
  newPath =  "#{imagePath}/#{md5Name}"
  console.log newPath
  fs.renameSync req.files.image.path, newPath
  imageHandler.generateThumb md5Name, (err, image) ->
    res.redirect "/"

app.get "/post", routes.post

app.get "/", routes.index

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")