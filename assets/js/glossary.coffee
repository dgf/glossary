(->
  # browser interactions
  showError = (msg) -> alert msg

  # view model
  class Glossary

    constructor: ->
      @termsById = {}
      @terms = ko.observableArray([])
      @letters = ko.observableArray([])

    sortTerms = (l, r) -> l.title().localeCompare r.title()

    saveTerm = (id, change) -> now.glossary.save id, change, (msg) -> console.log msg

    addChangeListener = (term) ->
      term.editingTitle = ko.observable false
      term.editingDefinition = ko.observable false
      term.editing = ko.computed -> term.editingTitle() or term.editingDefinition()

      term.editTitle = -> term.editingTitle true unless term.isBlocked()
      term.title.subscribe ->
        if term.editingTitle()
          console.log 'publish term title change: ' + term.id()
          saveTerm term.id(), title: term.title()

      term.editDefinition = -> term.editingDefinition true unless term.isBlocked()
      term.definition.subscribe ->
        if term.editingDefinition()
          console.log 'publish term definition change: ' + term.id()
          saveTerm term.id(), definition: term.definition()
      term

    addTermData: (values) =>
      console.log 'add term: ' + values.id
      term = addChangeListener ko.mapping.fromJS values
      term.editing.subscribe (edit) -> saveTerm term.id(), isBlocked: edit
      @termsById[values.id] = term
      @terms.push term

    # ----------------------------------------------- client interface
    addTerm: (values) =>
      @addTermData values
      @terms.sort sortTerms

    removeTerm: (id) =>
      console.log 'remove term: ' + id
      @terms.remove @termsById[id]
      delete @termsById[id]

    updateTerm: (values) =>
      console.log 'update term: ' + values.id
      term = @termsById[values.id]
      unless term.editing()
        ko.mapping.fromJS values, term
        @terms.sort sortTerms

    setTerms: (terms) =>
      @addTermData term for term in terms
      @terms.sort sortTerms

    setLetters: (letters) =>
      @letters.removeAll()
      for letter in letters
        letter.url = '#' + letter.title
        @letters.push letter

    # ----------------------------------------------- binding interactions
    delete: (term) ->
      console.log 'delete term: ' + term.id()
      now.glossary.remove term.id(), (msg) -> console.log msg

    create: ->
      console.log 'create term'
      values =
        title: 'A new term'
        definition: 'with a definition'
        isNew: true
      now.glossary.add values, (msg) => console.log msg

  jQuery ($) ->
    console.log '$ ready'

    # connection flow
    socketStatus = null
    now.core.on 'connect', -> socketStatus = 'connected' if not socketStatus
    now.core.on 'reconnect', -> socketStatus = 'reconnected'
    now.core.on 'disconnect', -> showError 'disconnect from server'
    now.core.on 'connect_failed', -> showError 'socket connect failed'
    now.core.on 'reconnect_failed', -> showError 'reconnect try failed'

    # initialize glossary
    glossary = new Glossary

    # register client handler
    now.client =
      alert: showError
      add: glossary.addTerm
      remove: glossary.removeTerm
      update: glossary.updateTerm
      letters: (letters) ->
        glossary.setLetters letters
        $('body').scrollspy 'refresh'

    # startup
    now.ready ->
      console.log 'now ready'
      initView = ->
        now.glossary.terms (terms) ->
          glossary.setTerms terms
          now.glossary.letters (letters) ->
            glossary.setLetters letters
            $('body').show().scrollspy 'refresh'
      switch socketStatus
        when 'connected', null
          console.log 'startup'
          ko.applyBindings glossary
          initView()
        when 'reconnected'
          console.log 'reconnected'
          initView()
        else showError 'unknow socket connection status: ' + socketStatus
)()
