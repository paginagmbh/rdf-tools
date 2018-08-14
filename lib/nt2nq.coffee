N3 = require "n3"
{ namedNode, quad } = N3.DataFactory

miss = require "mississippi"

module.exports = (graph) ->
    graph = namedNode graph
    miss.through.obj (triple, _, cb) ->
        {subject, predicate, object} = triple
        cb null, quad subject, predicate, object, graph