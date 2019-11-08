module.exports = (event, params) => {
    console.log(`waiting ${params.seconds}`)
    return new Promise( resolve => setTimeout(() => resolve(event), params.seconds * 1000) )
}