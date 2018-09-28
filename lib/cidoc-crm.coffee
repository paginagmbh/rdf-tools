N3 = require "n3"
miss = require "mississippi"
request = require "request"

{ RdfXmlParser } = require "rdfxml-streaming-parser"
nt2nq = require "./nt2nq"

url = "http://erlangen-crm.org/ontology/ecrm/ecrm_170309.owl"

module.exports =
    stream: () ->
        request { url }

    parsed: () ->
        miss.pipeline.obj new RdfXmlParser(),
            (nt2nq "http://erlangen-crm.org/170309/")