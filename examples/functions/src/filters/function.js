module.exports = {
    'is-assigned': event => event.data.assigned ? event : null,
    'is-not-assigned': event => event.data.assigned ? null : event
}