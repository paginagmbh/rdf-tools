// Generated by CoffeeScript 2.3.1
(function() {
  var inverseOf, miss;

  miss = require("mississippi");

  inverseOf = "http://www.w3.org/2002/07/owl#inverseOf";

  module.exports = {
    model: function(cb) {
      var flush, inversed, transform;
      inversed = {};
      transform = function(triple, _, next) {
        var mapping, name, object, predicate, subject;
        ({subject, predicate, object} = triple);
        if (predicate.value === inverseOf) {
          mapping = inversed[name = object.value] != null ? inversed[name] : inversed[name] = {};
          mapping[subject.value] = true;
        }
        return next(null, triple);
      };
      flush = function(next) {
        cb({inversed});
        return next();
      };
      return miss.through.obj(transform, flush);
    }
  };

}).call(this);

//# sourceMappingURL=owl.js.map