glossary = require('crudl-app') require('./app.conf'), __dirname
glossary.db.Term.unBlockAll glossary.start, (msg) -> throw new Error msg
