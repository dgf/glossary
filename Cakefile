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

logSuccess = -> log ":)", green

task 'build', 'build coffee', -> build logSuccess

task 'setup', 'sync database schema and setup glossary example data', ->
  glossary = require('crudl-app') require('./app.conf'), __dirname

  createTerm = (term, onSuccess) ->
    glossary.db.Term.create term, onSuccess, (error) -> log error, red

  createTermList = (terms, onSuccess) ->
    if terms.length is 0
      logSuccess()
    else
      [term, residual...] = terms
      createTerm term, -> createTermList residual

  glossary.db.reset -> createTermList require './fixture'
