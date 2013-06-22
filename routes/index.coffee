fs = require "fs"
Picture = require "#{__dirname}/../lib/picture"
Album = require "#{__dirname}/../lib/album"
config = require "#{__dirname}/../config/config.json"

exports.index = (req, res) ->
  res.render "index",
    title: config.title
    brand: config.title    
    description: config.description
    layout: 'layout'

exports.albums = (req, res) ->
  Album.find (err, albums)->
    res.render "albums",
      name: "Albums"
      title: "Albums"
      brand: config.title
      description: config.description
      albums: albums
      layout: 'layout'

exports.album = (req, res) ->
  Picture.find {folder: req.params.folder}, (err, pictures) ->
    albumName = req.params.folder
    res.render "album",
      name: albumName
      title: albumName
      brand: config.title
      description: config.description
      images: pictures
      layout: 'layout'

exports.save = (req, res) ->
  folder = req.body.folder
  file = req.files.image
  Picture.save file, folder, (err, picture)->
    console.log picture
    res.redirect "/admin/post"

exports.post = (req, res) ->
  res.render "post",
    title: "Post"
    brand: config.title
    layout: 'layout_admin'
