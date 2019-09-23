

const express = require("express")
const app = express()
const bodyParser = require("body-parser")
app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())

app.post("/", (req, res) => {
  console.log('wait for photo')
  setTimeout(() => {
    res.set(req.headers)
    res.status(200).send(req.body)
  }, 2000)
})

app.listen(8080)


