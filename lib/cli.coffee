path = require "path"

module.exports = (transform) ->
    try
        await transform()
        process.exitCode = 0
    catch err
        process.exit 0 if err.code is "EPIPE"

        console.error err
        process.exitCode = 1