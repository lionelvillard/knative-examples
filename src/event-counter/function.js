var counter = 0
var inflight = 0

module.exports = (context, event) => {
   inflight ++
   counter ++

  if (context.params.seconds) {
    let w = Math.random() * parseInt(context.params.seconds) * 1000
    return new Promise(resolve => setTimeout(() => { inflight -- ; resolve() }, w))
  }

  inflight --
}

setInterval(() => console.log(`event received: ${counter}, inflight: ${inflight}`), 1000)
