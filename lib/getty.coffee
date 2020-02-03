N3 = require "n3"
miss = require "mississippi"
request = require "request"
unzipper = require "unzipper"

debug = require "debug"
log = debug "rdf-tools:getty"

nt2nq = require "./nt2nq"

url = "http://vocab.getty.edu/dataset/aat/explicit.zip"

aatFilter = (components...) ->
    matchAll = components.length is 0
    paths = ("AATOut_#{c}.nt" for c in components)
    paths = paths.reduce ((idx, p) -> { idx..., [p]: true }), {}
    ({ path }) -> matchAll or (paths[path] ? false)

aat = (to, filter=aatFilter(), cb) ->
    source = request { url }
    extract = unzipper.Parse()
        .on "entry" , (entry) ->
            if filter entry
                log "+ %o", entry
                entry.pipe to, { end: false }
            else
                log "- %o", entry
                entry.autodrain()
        .on "finish", () -> to.end()

    callback = (err) ->
        log (err ? to)
        cb err if cb

    miss.pipe source, extract, callback

module.exports =
    aat: aat
    aatFilter: aatFilter

    subjects: aatFilter "1Subjects"
    hierarchy: aatFilter "1Subjects", "2Terms", "HierarchicalRels"

    parsed: () ->
        miss.pipeline.obj new N3.StreamParser(), (nt2nq "http://vocab.getty.edu/aat")