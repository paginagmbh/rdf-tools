zlib = require "zlib"

N3 = require "n3"
miss = require "mississippi"
request = require "request"

nt2nq = require "./nt2nq"

url = "https://data.dnb.de/opendata/authorities-person_lds.ttl.gz"

module.exports =
    stream: (cb) -> miss.pipe request({ url }), zlib.createGunzip(), cb

    parsed: () ->
        miss.pipeline.obj N3.StreamParser(), (nt2nq "http://d-nb.info/gnd/")
