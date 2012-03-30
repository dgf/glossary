# browser interactions
showError = (msg) -> alert msg

# view model
class Glossary

  constructor: ->
    @terms = ko.observableArray([])
    @termsById = {}
    @letters = ko.observableArray([])

    @newTermTitle = ko.observable()
    @newTermDefinition = ko.observable()
    @chosenTermData = ko.observable()

    @incompleteTerms = ko.computed =>
      ko.utils.arrayFilter @terms(), (term) -> not term.isDone()

    @addTermData = (term) =>
      t = ko.mapping.fromJS term
      @termsById[term.id] = t
      @terms.push t

    @updateTermData = (values) =>
      ko.mapping.fromJS values, @termsById[values.id]

    @removeTermData = (id) =>
      @terms.remove @termsById[id]
      delete @termsById[id]

  setLetters: (letters) => @letters.push letter for letter in letters
  setTerms: (terms) => @addTermData term for term in terms
  editTerm: (term) => @chosenTermData term

  addTerm: =>
    values =
      title: @newTermTitle()
      definition: @newTermDefinition()
      isDone: false

    now.glossary.add values, (msg) =>
      console.log msg
      @newTermTitle ''
      @newTermDefinition ''

  saveTerm: =>
    values = ko.mapping.toJS @chosenTermData()
    now.glossary.save values, (msg) ->
      console.log msg

  removeTerm: (term) =>
    now.glossary.remove term.id(), (msg) ->
      console.log msg

# startup
now.ready ->

  # initialize glossary
  glossary = new Glossary
  ko.applyBindings glossary
  now.glossary.terms glossary.setTerms
  now.glossary.letters glossary.setLetters

  # register client handler
  now.client =
    alert: showError
    addTerm: glossary.addTermData
    removeTerm: glossary.removeTermData
    updateTerm: glossary.updateTermData

