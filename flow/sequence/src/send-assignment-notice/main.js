

const express = require("express")
const app = express()
const bodyParser = require("body-parser")
app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())

app.post("/", (req, res) => {
  console.log('send assignment notice')

  const event = req.body
  console.log(`Hello ${event.photographer.name}! Please snap a pic of: ${event.name} Created by: ${event.brand}`)

  res.set(req.headers)
  res.status(200).send(req.body)
})

app.listen(8080)


