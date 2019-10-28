const fn = require('./function')
const dispatch = typeof fn !== 'function'

// handle POST request
async function handleRequest(req, res) {
    if (req.method !== 'POST' || (!dispatch && req.url !== '/') || (dispatch && req.url == '/')) {
        res.statusCode = 404
        res.end()
        return
    }

    // Resolve actual function
    let actualfn = fn
    if (dispatch) {
        const fname = req.url.substr(1)
        actualfn = fn[fname]
        if (!actualfn) {
            res.statusCode = 404
            res.end()
            return
        }
    }

    // http => event
    const event = httptoce(req.headers)

    // Setup event handlers
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
            const reply = await actualfn(event)

            if (reply) {
                const headers = cetohttp(reply)
                if (reply.data) {
                    headers['Content-Type'] = 'application/json'
                }
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

    req.on('error', err => {
        res.statusCode = 500
        res.write(e.toString())
        res.end()
    })
}

// Convert HTTP header to CloudEvents (without data)
function httptoce(headers) {
    return Object.keys(headers).reduce((event, key) => {
        if (key.startsWith('ce-')) {
            event[key.substr(3)] = headers[key]
        }
        return event
    }, {})
}

// Convert CloudEvents attributes to HTTP headers
function cetohttp(ce) {
    return Object.keys(ce).reduce((headers, key) => {
        if (key !== "data")
            headers[`ce-${key}`] = ce[key]
        return headers
    }, {})
}

module.exports = handleRequest