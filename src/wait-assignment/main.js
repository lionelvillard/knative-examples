const express = require("express")
const app = express()
const bodyParser = require("body-parser")
app.use(bodyParser.json());

app.post("/", (req, res) => {
  console.log(`wait for assigment`)
  res.set(req.headers).status(200).send(req.body)
})

app.listen(8080)