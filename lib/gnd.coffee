zlib = require "zlib"

N3 = require "n3"
miss = require "mississippi"
request = require "request"

nt2nq = require "./nt2nq"

url = [
    "http://datendienst.dnb.de/cgi-bin/mabit.pl"
    "?cmd=fetch&userID=opendata&pass=opendata&mabheft=GND.ttl.gz"].join ""

module.exports =
    stream: () -> miss.pipe [
        request { url }
         zlib.createGunzip()]

    parsed: () ->
        miss.pipeline.obj N3.StreamParser(), (nt2nq "http://d-nb.info/gnd/")
