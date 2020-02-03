zlib = require "zlib"

N3 = require "n3"
miss = require "mississippi"
request = require "request"

nt2nq = require "./nt2nq"

url = "http://iconclass.org/data/iconclass.nt.gz"

module.exports =
    stream: (cb) ->
        miss.pipe (request { url }), zlib.createGunzip(), cb

    parsed: () ->
        miss.pipeline.obj new N3.StreamParser(), (nt2nq "http://iconclass.org/")
