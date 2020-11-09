module.exports = (context, event) =>
    new Promise( resolve => setTimeout(() => resolve(event), context.params.seconds * 1000) )