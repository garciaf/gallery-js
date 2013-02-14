fs = require "fs"
Picture = require "#{__dirname}/../lib/picture"
Album = require "#{__dirname}/../lib/album"
config = require "#{__dirname}/../config/config.json"

exports.index = (req, res) ->
  res.render "index",
    title: config.title
    description: config.description

exports.albums = (req, res) ->
  Album.find (err, albums)->
    res.render "albums",
      name: "Albums"
      title: config.title
      albums: albums

exports.album = (req, res) ->
  Picture.find {folder: req.params.folder}, (err, pictures) ->
    albumName = req.params.folder
    res.render "album",
      name: albumName
      title: config.title
      images: pictures

exports.save = (req, res) ->
  folder = req.body.folder
  file = req.files.image
  Picture.save file, folder, (err, picture)->
    console.log picture
    res.redirect "/post"

exports.post = (req, res) ->
  res.render "post",
    title: config.title
