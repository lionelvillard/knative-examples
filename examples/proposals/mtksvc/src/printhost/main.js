const http = require('http')

function handleRequest(req, res) {
  console.log(req.headers)
  console.log
  res.statusCode = 200
  res.end()
}

const server = http.createServer(handleRequest)
server.listen(process.env.PORT || 8080)
