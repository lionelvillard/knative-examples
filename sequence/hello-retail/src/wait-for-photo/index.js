

const express = require("express")
const app = express()
const bodyParser = require("body-parser")
app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())

app.post("/", (req, res) => {
  console.log('wait for photo')
  res.set(req.headers)
  res.status(200).send(req.body)
})

app.listen(8080)


