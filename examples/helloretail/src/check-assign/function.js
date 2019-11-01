module.exports = (event, params) => {
  if (params.assigned === "true" && event.data.assigned)
    return event

  if (params.assigned === "false" && !event.data.assigned)
    return event

  return null
}