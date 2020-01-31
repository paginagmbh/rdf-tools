// Generated by CoffeeScript 2.3.1
(function() {
  var N3, miss, nt2nq, request, url, zlib;

  zlib = require("zlib");

  N3 = require("n3");

  miss = require("mississippi");

  request = require("request");

  nt2nq = require("./nt2nq");

  url = "http://iconclass.org/data/iconclass.nt.gz";

  module.exports = {
    stream: function(cb) {
      return miss.pipe(request({url}), zlib.createGunzip(), cb);
    },
    parsed: function() {
      return miss.pipeline.obj(N3.StreamParser(), nt2nq("http://iconclass.org/"));
    }
  };

}).call(this);

//# sourceMappingURL=iconclass.js.map
