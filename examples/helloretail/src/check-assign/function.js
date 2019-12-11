module.exports = (context, event) => {
  if (context.params.assigned === "true" && event.data.assigned)
    return event

  if (context.params.assigned === "false" && !event.data.assigned)
    return event

  return null
}