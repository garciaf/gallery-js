fs = require "fs"
md5 = require 'MD5'

imageHandler = require "#{__dirname}/../lib/image"

exports.index = (req, res) ->
  images = imageHandler.getPictures()
  user = md5("fab0670312047@gmail.com")
  res.render "index",
    title: "Express"
    images: images
    user: user

exports.post = (req, res) ->
  res.render "post"
