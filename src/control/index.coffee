crudl = require 'crudl-control'
_ = require 'underscore'

# glossary interface
module.exports = (express, everyone, db) ->

  express.get '/', (req, resp) -> resp.render 'index', title: 'Startseite'

  map = (term) ->
    title: term.title
    definition: term.definition
    isDone: term.isDone

  termCrudl = crudl db.Term, map, (term) -> _.extend map(term), id: term.id

  everyone.now.glossary =
    terms: termCrudl.list

    save: (values, onSuccess) ->
      publishUpdatedTerm = (msg, term) ->
        onSuccess msg
        everyone.now.client.updateTerm term
      termCrudl.update.apply @, [values.id, values, publishUpdatedTerm]

    add: (values, onSuccess) ->
      publishNewTerm = (msg, term) ->
        onSuccess msg
        everyone.now.client.addTerm term
      termCrudl.create.apply @, [values, publishNewTerm]

    remove: (id, onSuccess) ->
      publishDeletedTerm = (msg) ->
        onSuccess msg
        everyone.now.client.removeTerm id
      termCrudl.delete.apply @, [id, publishDeletedTerm]

    letters: (onSuccess) ->
      db.Term.letters onSuccess, (error) -> throw error

