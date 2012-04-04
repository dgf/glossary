crudl = require 'crudl-control'
_ = require 'underscore'

# glossary interface
module.exports = (express, everyone, db) ->

  tie = (term) ->
    t = isBlocked: term.isBlocked
    t.title = term.title if term.title
    t.definition = term.definition if term.definition
    t

  detach = (term) ->
    _.extend tie(term),
      id: term.id
      updated: term.updatedAt

  termCrudl = crudl db.Term, tie, detach

  updateLetters = -> db.Term.letters everyone.now.client.letters, (error) -> throw error

  everyone.now.glossary =
    terms: termCrudl.list

    save: (id, values, onSuccess) ->
      publishUpdatedTerm = (msg, term) ->
        onSuccess msg
        everyone.now.client.update _.extend values,
          id: term.id
          updated: term.updated
        updateLetters()
      termCrudl.update.apply @, [id, values, publishUpdatedTerm]

    add: (values, onSuccess) ->
      publishNewTerm = (msg, term) ->
        onSuccess msg
        everyone.now.client.add term
        updateLetters()
      termCrudl.create.apply @, [values, publishNewTerm]

    remove: (id, onSuccess) ->
      publishDeletedTerm = (msg) ->
        onSuccess msg
        everyone.now.client.remove id
        updateLetters()
      termCrudl.delete.apply @, [id, publishDeletedTerm]

    letters: (onSuccess) ->
      db.Term.letters onSuccess, (error) -> throw error
