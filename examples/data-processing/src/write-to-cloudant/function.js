/**
 * Copyright 2017 IBM Corp. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License")
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

var request = require('request')
var Cloudant = require('@cloudant/cloudant')

var LOGO_URL = "https://upload.wikimedia.org/wikipedia/commons/thumb/5/51/IBM_logo.svg/512px-IBM_logo.svg.png"
var CONTENT_TYPE = "image/png"
var IMAGE_NAME_PREFIX = "IBM_logo"
var IMAGE_NAME_POSTFIX = ".png"

/**
 * This action downloads an IBM logo, and returns an object to be written to a cloudant database.
 * This action is idempotent. If it fails, it can be retried.
 *
 * @param   event.data.database               Cloudant database to store the file to
 * @return  the downloaded image object
 */
module.exports = async event => {
    var cloudant = new Cloudant(process.env.CLOUDANT_URL)

    try {
        await cloudant.db.get(event.data.database)
    } catch (e) {
        // Create
        console.log(`creating database ${event.data.database}`)
        try {
            await cloudant.db.create(event.data.database)
        } catch (e) {
            console.log(`failed creating database ${event.data.database}: ${e}`)
            return null
        }
    }

    var database = cloudant.db.use(event.data.database)

    // Generate a random name to trigger the database change feed
    var imageName = IMAGE_NAME_PREFIX + getRandomInt(1, 100000) + IMAGE_NAME_POSTFIX

    return new Promise(function (resolve, reject) {
        request({
            uri: LOGO_URL,
            method: 'GET',
            encoding: null
        }, function (err, response, body) {
            if (err) {
                reject()
            } else {
                database.multipart.insert({
                    _id: imageName
                }, [{
                    name: imageName,
                    data: body,
                    content_type: CONTENT_TYPE
                }],
                    imageName,
                    function (err, body) {
                        if (err && err.statusCode != 409) {
                            console.log("Error with file insert." + err)
                            reject()
                        } else {
                            console.log("Success with file insert.")
                            resolve()
                        }
                    }
                )
            }
        })
    })
}

function getRandomInt(min, max) {
    min = Math.ceil(min)
    max = Math.floor(max)
    return Math.floor(Math.random() * (max - min)) + min
}