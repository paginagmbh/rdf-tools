path = require "path"

miss = require "mississippi"
N3 = require "n3"

defaultArgs = { format: "N-Quads" }
args = (require "minimist") process.argv[2..]

{ format, subset, graph } = { defaultArgs..., args... }

[ dataset ] = args._
process.exit 2 unless dataset

nt2nq = require "./nt2nq"
iconclass = require "./iconclass"
gnd = require "./gnd"
getty = require "./getty"

to = miss.pipeline.obj N3.StreamWriter({ format }), process.stdout
cb = (err) ->
    console.error err if err?
    process.exitCode = if err? then 1 else 0

switch dataset
    when "iconclass"
        miss.pipe iconclass.stream(), iconclass.parsed(), to, cb
    when "gnd"
        miss.pipe gnd.stream(), gnd.parsed(), to, cb
    when "getty"
        to = miss.pipeline.obj getty.parsed(), to
        subset = switch subset
            when "subjects" then getty.subjects
            when "hierarchy" then getty.hierarchy

        getty.aat to, subset
        to.on "error", cb
    when "-"
        to = miss.pipeline.obj nt2nq(graph), to if graph?
        miss.pipe process.stdin, N3.StreamParser(), to, cb
    else
        cb "Unknown dataset: #{dataset}"