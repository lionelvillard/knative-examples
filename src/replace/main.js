const express = require("express")
const app = express()
const bodyParser = require("body-parser")
app.use(bodyParser.json());

app.post("/", (req, res) => {
  console.log('receive event')
  console.log(JSON.stringify(req.body))
  res.header(req.header).status(200).send(process.env.REPLACEMENT)
})

app.listen(8080)