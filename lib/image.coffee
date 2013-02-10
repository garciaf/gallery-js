# Image manipulation
fs = require "fs"
util = require 'util'
md5 = require 'MD5'
im = require 'imagemagick'
config = require "#{__dirname}/../config/user.json"

thumbPath = "#{__dirname}/../#{config.thumb_folder}"
imagePath = "#{__dirname}/../#{config.upload_folder}"

exports.getExtension = (fileName) ->
  i = fileName.lastIndexOf(".")
  (if (i < 0) then "" else fileName.substr(i))

exports.getThumb = (fileName) =>
  if fs.existsSync "#{thumbPath}/#{fileName}"
    return "#{thumbPath}/#{fileName}"
  else 
    exports.generateThumb fileName, (err, thumb) ->
      return thumb

exports.getPictures = ->
  return fs.readdirSync("#{imagePath}")  


exports.generateThumb = (fileName, cb ) =>
  ext = exports.getExtension(fileName)
  unless ext is ".jpeg" or ".jpg" or ".png"
    console.log 'bad ext'
    return false
  src = "#{imagePath}/#{fileName}"
  target = "#{thumbPath}/#{fileName}"
  im.crop
    srcPath: src
    dstPath: target
    width: config.thumb_size
    height: config.thumb_size
    (err, stdout, stderr) ->
      throw err  if err
      cb(err, target)
