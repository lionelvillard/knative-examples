module.exports = {
    'content-filter': event => event.data.filter ? null : event,
    'attr-type-filter': event => event.type === 'my.event.type' ? event : null
}