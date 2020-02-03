path = require "path"

miss = require "mississippi"
N3 = require "n3"
{ namedNode, quad } = N3.DataFactory

defaultArgs = { format: "N-Quads" }
args = (require "minimist") process.argv[2..]

{ format } = { defaultArgs..., args... }

[ ontology ] = args._
process.exit 2 unless ontology

owl = require "./owl"
crm = require "./cidoc-crm"

to = miss.pipeline.obj new N3.StreamWriter({ format }), process.stdout
cb = (err) ->
    console.error err if err?
    process.exitCode = if err? then 1 else 0

cidocCrm = () ->
    ontology = await new Promise (resolve, reject) ->
        miss.pipe crm.stream(),
            crm.parsed(),
            owl.model(resolve),
            miss.to.obj((triple, _, next) -> next())
            (err) -> reject err if err?

    source = new N3.StreamParser()
    target = new N3.StreamWriter({ format })

    reasoner = miss.duplex.obj target, source
    reasoner.on "data", (stmt, _, next) ->
        { subject, predicate, object, graph } = stmt
        for inverse of (ontology.inversed[predicate.value] ? {})
            inverse = namedNode inverse
            reasoner.write quad(object, inverse, subject, graph)

    miss.pipe process.stdin, source, cb
    miss.pipe target, process.stdout, cb

try
    switch ontology
        when "cidoc-crm" then cidocCrm()
        else cb "Unknown ontology: #{ontology}"
catch err
    cb err
