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

    isBlocked:
      type: Sequelize.BOOLEAN
      defaultValue: false

  rawQuery = (sql, onError, onSuccess) ->
    sequelize.query(sql, null, raw: true).success(onSuccess).error(onError)

  Term.options.classMethods =

    unBlockAll: (onSuccess, onError) ->
      unblockTerms = "UPDATE #{Term.tableName} SET isBlocked=false";
      rawQuery unblockTerms, onError, onSuccess

    letters: (onSuccess, onError) ->
      letterList =
       "SELECT upper(left(title, 1)) AS l, title AS t FROM #{Term.tableName} GROUP BY l"
      rawQuery letterList, onError, (list) ->
        onSuccess ({ letter: letter.l, title: letter.t } for letter in list)

  Term
