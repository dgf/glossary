Sequelize = require 'sequelize'

module.exports = (sequelize) ->

  Term = sequelize.define 'Term',

    title:
      type: Sequelize.STRING
      allowNull: false
      unique: true
      validate:
        notEmpty: true

    definition:
      type: Sequelize.TEXT
      allowNull: false
      validate:
        notEmpty: true

    isDone: Sequelize.BOOLEAN

  Term.options.classMethods =
    letters: (onSuccess, onError) ->
      letterList = 'SELECT distinct upper(left(title, 1)) AS letter FROM ' + Term.tableName
      sequelize.query(letterList, null, raw: true).error(onError).success (list) ->
        onSuccess (l.letter for l in list)

  Term
