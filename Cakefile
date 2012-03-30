fs = require 'fs'
{print} = require 'util'
{spawn} = require 'child_process'
jasmineBinary = './node_modules/jasmine-node/bin/jasmine-node'

# ANSI Terminal Colors
bold = '\033[0;1m'
green = '\033[0;32m'
reset = '\033[0m'
red = '\033[0;31m'

log = (message, color) -> console.log color + message + reset

call = (name, options, callback) ->
  proc = spawn name, options
  proc.stdout.on 'data', (data) -> print data.toString()
  proc.stderr.on 'data', (data) -> log data.toString(), red
  proc.on 'exit', callback

build = (callback) -> call 'coffee', ['-c', '-o', 'lib', 'src'], callback

spec = (callback) -> call jasmineBinary, ['spec', '--coffee'], callback

task 'build', 'build coffee', ->
  build (status) -> log ":)", green if status is 0

task 'spec', 'run specifications', ->
  build (buildStatus) ->
    if buildStatus is 0
      spec (testStatus) ->
        log ":)", green if testStatus is 0

task 'setup', 'sync database schema and setup glossary example data', ->
  glossary = require('crudl-app') require('./app.conf'), __dirname

  createTerm = (title, definition, onSuccess) ->
    term = title: title, definition: definition
    glossary.db.Term.create term, onSuccess, (error) ->
      console.error "BARRRRRRRRR"
      log error, red

  glossary.db.reset ->
    createTerm 'Example', 'an example term', ->
      createTerm 'Another Example', 'a second term', -> log ":)", green
