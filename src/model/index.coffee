path = require 'path'
crudl = require 'crudl-model'

module.exports = (sequelize, Session) ->

  loadModel = (name) -> require(path.join __dirname, name) sequelize

  User = loadModel('User') Session
  Term = loadModel 'Term'

  Session: crudl Session
  User: crudl User
  Term: crudl Term

  reset: (onSuccess) ->
    sequelize.sync(force: true).success(onSuccess).error (msg) -> throw new Error msg
