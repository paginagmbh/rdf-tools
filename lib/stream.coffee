path = require "path"
{ PassThrough } = require "stream"

cliArgs = (require "minimist") process.argv[2..]

cli = require "./cli"
n3Stream = require "./n3-stream"

standardDatasets = path.resolve __dirname, "..", "lib", "datasets"

optional = (spec) ->
    try
        require spec
    catch err
        undefined

resolvers = [
    (spec) -> optional spec,
    (spec) -> optional path.resolve standardDatasets, spec
    (url) -> if (url.search /^https?:\/\//) is 0 then { url } else undefined
    (path) -> { path }
    ]

resolve = (spec) -> resolvers.reduce ((res, resolver) -> res ?= resolver spec), null

{ unparsed, format } = { unparsed: false, format: "N-Quads", cliArgs... }

parsed = not unparsed
datasets = (resolve ds for ds in cliArgs._)
datasets = ({ parsed, ds... } for ds in datasets when ds?)

process.exit 0 if datasets.length is 0

cli () ->
    source = new PassThrough { objectMode: parsed }
    stream = source

    stream = stream.pipe (n3Stream.write { format }) if parsed

    stream = stream.pipe process.stdout, { end: false }

    n3Stream.read datasets.shift()
        .on "end", () ->
            next = datasets.shift()
            if next
                (n3Stream.read next).pipe source, { end: false}
            else
                source.end()
        .pipe source, { end: false }
        .on "error", (err) -> source.emit "error", err

    new Promise (resolve, reject) ->
        stream.on "finish", resolve
        stream.on "error", reject