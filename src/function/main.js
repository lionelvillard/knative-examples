const http = require('http')
const handler = require('./___handler')
const server = http.createServer(handler)
server.listen(8080)