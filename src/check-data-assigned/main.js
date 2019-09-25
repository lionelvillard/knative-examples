const express = require("express")
const app = express()
const bodyParser = require("body-parser")
app.use(bodyParser.json());

app.post("/", (req, res) => {
  if (req.body.assigned) {
    res.set(req.headers).status(200).send(req.body)
  } else {
    res.status(200)
  }
})

app.listen(8080)