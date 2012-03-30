Sequelize = require 'sequelize'

setSession = (User, Session) -> (userOptions, sessionOptions, onSuccess, onError) ->
  onSessionFind = (user) -> (session) -> # set user session
    if session?
      user.setSession(session).error(onError).success(onSuccess)
    else
      onError 'session not found'
  onUserFind = (user) -> # search session
    if user?
      Session.find(sessionOptions).error(onError).success onSessionFind(user)
    else
      onError 'user not found'
  # search user
  User.find(userOptions).error(onError).success onUserFind

module.exports = (sequelize) ->

  User = sequelize.define 'User',

    name:
      type: Sequelize.STRING
      allowNull: false
      unique: true
      validate:
        notEmpty: true
        len:
          args: [3, 27]

    login:
      type: Sequelize.STRING
      allowNull: false
      unique: true
      validate:
        notEmpty: true
        len:
          args: [1, 13]

    mail:
      type: Sequelize.STRING
      allowNull: false
      validate:
        isEmail: true

    password:
      type: Sequelize.STRING
      allowNull: false
      validate:
        notEmpty: true
        len:
          args: [7, 27]

    isAdmin:
      type: Sequelize.BOOLEAN
      allowNull: false
      defaultValue: false

  (Session) ->
    User.hasOne Session
    User.options.classMethods =
      setSession: setSession User, Session

    User
