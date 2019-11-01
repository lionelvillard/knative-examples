module.exports = (event, params) =>
    new Promise( resolve => setTimeout(() => resolve(event), params.seconds * 1000) )