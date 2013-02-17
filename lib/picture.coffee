  fs = require "fs"
  util = require 'util'
  md5 = require 'MD5'
  im = require 'imagemagick'
  _ = require 'underscore'

  async = require 'async'
  config = require "#{__dirname}/../config/config.json"
  
  class Picture

    @thumbSize: config.thumb_size

    @imageFolder: "image"
    
    @thumbFolder: "thumb"
    
    @path: "/#{config.upload_folder}"

    @thumbPath: "#{__dirname}/../public/#{Picture.path}/#{Picture.thumbFolder}"
    
    @imagePath:"#{__dirname}/../public/#{Picture.path}/#{Picture.imageFolder}"

    @find: (opts, cb) ->
      pictures = []
      folderName = opts.folder
      limit = opts.limit
      unless folderName?
        folderName = ""
      path = "#{Picture.imagePath}/#{folderName}"
      files = fs.readdirSync("#{path}")
      popultatePicture = (fileName, callb) =>
        new Picture(
          {
            fileName: fileName
            folder: folderName
          },
          (err, picture) =>
            if picture?
              return callb(err, picture.toJSON())
            else
              return callb(null, null)
          )
      

      async.map files, popultatePicture, (err, result) =>
        pictures = _.compact(result)
        if limit
          return cb null, _.first(pictures, 1)
        cb(null, pictures)

    @getExtension: (fileName) ->
        i = fileName.lastIndexOf(".")
        return  (if (i < 0) then "" else fileName.substr(i))

    @save: (image, folder, cb) ->
      console.log folder
      if !!folder and !fs.existsSync "#{Picture.imagePath}/#{folder}"
        fs.mkdirSync("#{Picture.imagePath}/#{folder}")

      unless image?.type is "image/jpeg" or "image/png" or "image/gif"
        cb("wrong type of file")

      data = fs.readFileSync image.path
      ext = Picture.getExtension(image.name)  
      md5Name = "#{md5(data)}#{ext}"
      newPath =  "#{Picture.imagePath}/#{folder}/#{md5Name}".replace('//', '/')
      relativePath = "#{folder}/#{md5Name}".replace('//', '/')
      fs.renameSync image.path, newPath
      new Picture(
        {folder: folder
        fileName: md5Name},
        cb
        )
      
    constructor: (@opts, callb) ->
      @fileName = @opts.fileName
      @folder = @opts.folder
      @ext = @getExtension
      if @isPicture()
        @generateThumb (err, @thumb) => 
          callb null, @
      else
        @thumb = "false"
        callb null, null

    
    getFileName: ->
      return @fileName
    getFolder: ->
      return @folder

    getExtension: ->
      return @ext = Picture.getExtension(@getFileName())
    
    toJSON: ->
      return {"thumb": @thumb, "isPicture": @isPicture(), "path": @getPath() ,"fileName": @getFileName(), "folder": @getFolder() }

    getPath: ->
      if @folder? and @folder isnt ""
        return @path =  "#{Picture.path}/#{Picture.imageFolder}/#{@folder}/#{@fileName}"
      return @path = "#{Picture.path}/#{Picture.imageFolder}/#{@fileName}"
    isPicture: ->
      ext = @getExtension()
      lowerExt = "#{ext}".toLowerCase()
      if lowerExt is (".jpg" or ".jpeg" or ".png" or ".bmp" )
        return true
      return false

    generateThumb: (cb) ->
      if @thumb?
        cb(null, @thumb)
        return true
      if fs.existsSync "#{Picture.thumbPath}/#{@fileName}".replace('//', '/')
        @thumb = "#{Picture.path}/#{Picture.thumbFolder}/#{@fileName}".replace('//', '/')
        cb(null, @thumb)
        return true
      unless @isPicture()
        cb(null, 'default')
      src = "#{Picture.imagePath}/#{@folder}/#{@fileName}".replace('//', '/')
      thumbTarget = "#{Picture.thumbPath}/#{@fileName}".replace('//', '/')
      im.crop
        srcPath: src
        dstPath: thumbTarget
        width:  Picture.thumbSize
        height: Picture.thumbSize
        (err, stdout, stderr) =>
          throw err  if err
          @thumb = "#{Picture.path}/#{Picture.thumbFolder}/#{@fileName}".replace('//', '/')
          cb(err, @thumb)
          return true

  module.exports = Picture