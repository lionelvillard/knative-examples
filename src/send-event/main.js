const express = require("express")
const http = require('http')
const app = express()
const bodyParser = require("body-parser")
app.use(bodyParser.json());

app.post("/", (req, res) => {
  const host = req.headers.target
  console.log(host)
  const data = JSON.stringify(req.body)

  const options = {
    hostname: host,
    method: 'POST',
    headers: {
      'content-type': 'application/json'
    }
  }

  console.log(options)

  const next = http.request(options, response => {
    console.log(response.statusCode)

    let rawData = ''
    response.on('data', chunk => {
      console.log(chunk)
      rawData += chunk
    })
    response.on('end', () => {
      res.header(req.headers).status(response.statusCode).send(rawData)
    })
  })

  next.on('error', error => {
    res.status(400).send(error)
  })
  console.log('write data')
  next.write(data)
  next.end()
})

app.listen(8080)





