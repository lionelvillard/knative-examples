module.exports = (event, params) => { if (params.data) event.data = params.data; return event }
