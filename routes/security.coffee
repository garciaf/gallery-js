#
# * GET home page.
# 
form = require("../form/login")
auth = require("../auth")
config = require "#{__dirname}/../config/config.json"


exports.login = (req, res) ->
  res.render "admin/login",
    form: form.LoginForm.toHTML()
    title: 'login'
    brand: config.title
    layout: 'layout_admin'


exports.authenticate =  auth.passport.authenticate("local",
  successRedirect: '/admin/post'
  failureRedirect: '/login'
)

exports.logout = (req, res) ->
  req.logout()
  res.redirect '/'

