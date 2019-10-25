const fn = require('./function')

// handle POST request
async function handleRequest(req, res) {
    if (req.method !== 'POST' || req.url !== '/') {
        res.statusCode = 404
        res.end()
        return
    }

    // http => event
    const event = Object.keys(req.headers).reduce((event, key) => {
        if (key.startsWith('ce-')) {
            event[key.substr(3)] = req.headers[key]
        }
        return event
    }, {})

    // read body
    const body = []
    req.on('data', data => {
        body.push(data)
    })

    req.on('end', async () => {
        const raw = Buffer.concat(body).toString()

        if (raw !== "") {
            try {
                event.data = JSON.parse(raw)
            } catch (e) {
                res.statusCode = 400
                res.write(`invalid JSON: ${e.toString()}`)
                res.end()
                return
            }
        }

        try {
            const reply = await fn(event)

            if (reply) {
                const headers = Object.keys(reply).reduce((headers, key) => {
                    if (key !== "data")
                        headers[`ce-${key}`] = reply[key]
                    return headers
                }, reply.data ? { 'Content-Type': 'application/json' } : {})

                res.writeHead(200, headers)
                if (reply.data) {
                    res.write(JSON.stringify(reply.data))
                }
                res.end()
            } else {
                res.statusCode = 200
                res.end()
            }
        } catch (e) {
            res.statusCode = 400
            res.write(`function raised an error: ${e.toString()}`)
            res.end()
            return
        }
    })
}

module.exports = handleRequest