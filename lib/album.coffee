  fs = require "fs"
  util = require 'util'
  md5 = require 'MD5'
  _ = require 'underscore'
  im = require 'imagemagick'
  async = require 'async'
  config = require "#{__dirname}/../config/user.json"
  Picture = require "#{__dirname}/picture"
  
  class Album
    
    @imageFolder: "image"
        
    @imagePath:"#{__dirname}/../#{config.upload_folder}/#{Picture.imageFolder}"

    @find: (cb) ->
      albums = []
      files = fs.readdirSync("#{Album.imagePath}")
      populateAlbum = (file, callback) ->
        stat = fs.lstatSync("#{Album.imagePath}/#{file}")
        if stat.isDirectory()
          Picture.find {folder: file, limit: true}, (err, pictures) =>
            callback null, {"name": file, "pictures": pictures[0] }
        else
          callback null
      async.map files, populateAlbum, (err, result) =>
        albums = _.compact(result) 
        cb(null, albums)


  module.exports = Album