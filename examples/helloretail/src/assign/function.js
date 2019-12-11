// Mock cloudant
const pgs = {
  find: () => {
    return new Promise((resolve) => {
      setTimeout(() => resolve({
        docs: [
          { name: 'Mike', id: 'mike430', assigned: false }
        ]
      }), 2000)
    })
  }
}

module.exports = async (_, event) => {
  event.data.photographers = event.data.photographers || []

  const doc = await pgs.find()
  if (doc.docs.length == 0) {
    console.log("not found")
    event.data.assigned = false
    return event
  }

  event.data.photographer = doc.docs[0]
  console.log("photographer assigned", event.data.photographer.name)

  event.data.photographers.push(event.data.photographer.id)
  event.data.assigned = true
  event.data.assignmentComplete = false
  return event
}