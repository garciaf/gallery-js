fs = require "fs"
imageHandler = require "#{__dirname}/../lib/image"

exports.index = (req, res) ->
  images = imageHandler.getPictures()
  res.render "index",
    title: "Express"
    images: images 

exports.post = (req, res) ->
  res.render "post"
