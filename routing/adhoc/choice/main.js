const express = require("express")
const app = express()
const bodyParser = require("body-parser")
app.use(bodyParser.json());

app.post("/", (req, res) => {
  if (req.body.assigned) {
    res.status(200).send(["default/routing-assigned"])
  } else {
    res.status(200).send(["default/routing-notassigned"])
  }
})

app.listen(8080)