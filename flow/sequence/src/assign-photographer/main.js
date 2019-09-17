const express = require("express")
const app = express()
const bodyParser = require("body-parser")

app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())

// In-Memory Database
const pgs = {
  find: () => {
    return new Promise((resolve) => {
      setTimeout(() => resolve({ docs: [{ id: 'Mike', name: 'Mike' }] }), 100)
    })
  }
}

app.post("/", (req, res) => {
  console.log("assigned photographer")
  console.log(JSON.stringify(req.headers))
  console.log(JSON.stringify(req.body))

  result = req.body
  result.photographers = result.photographers || []

  //find photographer to contact-- database lookup
  pgs.find().then((doc) => {
    if (doc.docs.length == 0) {
      console.log("no photographer found")
      result.assigned = false
    } else {
      result.photographer = doc.docs[0]
      console.log("photographer assigned", result.photographer.name)
      result.photographers.push(result.photographer.id)
      result.assigned = true
      result.assignmentComplete = false
    }

    res.set(req.headers)
    res.status(200).send(result)
  }).catch((err) => {
    console.log(err)
    res.status(400)
  })
})

app.listen(8080)
