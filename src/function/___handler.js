const url = require('url')
const fs = require('fs')
const path = require('path')
const querystring = require('querystring')
const fn = require('./function')

const dispatch = typeof fn !== 'function'

const functionConfig = readFunctionConfig()

// handle POST request
async function handleRequest(req, res) {
    const parsedurl = url.parse(req.url)
    if (req.method !== 'POST' || (!dispatch && parsedurl.pathname !== '/') || (dispatch && parsedurl.pathname == '/')) {
        res.statusCode = 404
        res.end()
        return
    }

    // Resolve actual function
    let actualfn = resolvefn(req, res)
    if (!actualfn)
        return

    // http => event
    const event = httptoce(req.headers)

    // apply static bindings
    const staticParams = paramsfromconfig(req.headers['host'])

    // http => params
    const httpParams = httptoparams(parsedurl)

    // Merge
    const params = { ...staticParams, ...httpParams }

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
            const reply = await actualfn(event, params)

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


// Convert HTTP request to parameters
function httptoparams(parsedurl) {
    if (parsedurl.search && parsedurl.search.length >= 1) {
        return querystring.parse(parsedurl.search.substr(1))
    }
    return {}
}

// Get static parameters from given host
function paramsfromconfig(host) {
    if (!functionConfig) {
        return {}
    }

    while (true) {
        const params = functionConfig[host]
        if (params) {
            return params
        }
        host = trimRight(host, '.')
        if (!host) {
            return {}
        }
    }
}

function trimRight(str, ch) {
    const i = str.lastIndexOf(ch)
    return i == -1 ? null : str.substring(0, i)
}

// Resolve actual function
function resolvefn(req, res) {
    if (dispatch) {
        const fname = req.url.substr(1)
        const actualfn = fn[fname]
        if (!actualfn) {
            res.statusCode = 404
            res.end()
            return null
        }
        return actualfn
    }
    return fn
}

function readFunctionConfig() {
    let bytes
    try {
        bytes = fs.readFileSync(path.join(__dirname, '___config.json'))
    } catch (e) {
        console.log('no config file read.')
        return null
    }

    try {
        return JSON.parse(bytes)
    } catch (e) {
        console.error('error parsing the config file')
        console.log(e)
        return null
    }
}

module.exports = handleRequest