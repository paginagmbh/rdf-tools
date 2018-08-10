{ PassThrough } = require "stream"
{ URL } = require "url"
fs = require "fs"
zlib = require "zlib"

N3 = require "n3"
request = require "request"
parseUnzip = (require "unzip").Parse
miss = require "mississippi"

nt2nq = (graph) -> miss.through.obj ({subject, predicate, object}, _, cb) ->
    cb null, { graph, subject, predicate, object }

module.exports =
    read: (options) ->
        { url, path, gzip, gunzip, unzip, unzipFilter, parsed, graph } = options
        { pathname }  = if url then (new URL url) else { pathname: path }

        unzip ?= false
        parsed ?= true

        gzPath = pathname.endsWith ".gz"
        gzip ?= not gzPath
        gunzip ?= gzPath

        stream = (if url then request { url, gzip } else fs.createReadStream path)

        stream = stream.pipe zlib.createGunzip() if gunzip

        if unzip
            parser = if parsed then N3.StreamParser() else new PassThrough()

            stream.pipe parseUnzip()
                .on "entry", (entry) ->
                    if unzipFilter and not unzipFilter entry
                        entry.autodrain()
                        return
                    entry.pipe parser, { end: false }
                .on "error", (err) -> parser.emit "error", err
                .on "finish", () -> parser.end()

            stream = parser
        else if parsed
            stream = stream.pipe N3.StreamParser()

        if parsed and graph?
            stream = stream.pipe (nt2nq graph)

        stream

    write: (options) -> N3.StreamWriter options