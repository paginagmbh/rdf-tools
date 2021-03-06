// Generated by CoffeeScript 2.5.1
(function() {
  var N3, miss, nt2nq, request, url, zlib;

  zlib = require("zlib");

  N3 = require("n3");

  miss = require("mississippi");

  request = require("request");

  nt2nq = require("./nt2nq");

  url = "https://data.dnb.de/opendata/authorities-person_lds.ttl.gz";

  module.exports = {
    stream: function(cb) {
      return miss.pipe(request({url}), zlib.createGunzip(), cb);
    },
    parsed: function() {
      return miss.pipeline.obj(new N3.StreamParser(), nt2nq("http://d-nb.info/gnd/"));
    }
  };

}).call(this);

//# sourceMappingURL=gnd.js.map
