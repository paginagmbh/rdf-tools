// Generated by CoffeeScript 2.3.1
(function() {
  var N3, args, cb, dataset, defaultArgs, format, getty, gnd, graph, iconclass, miss, nt2nq, path, subset, to;

  path = require("path");

  miss = require("mississippi");

  N3 = require("n3");

  defaultArgs = {
    format: "N-Quads"
  };

  args = (require("minimist"))(process.argv.slice(2));

  ({format, subset, graph} = {...defaultArgs, ...args});

  [dataset] = args._;

  if (!dataset) {
    process.exit(2);
  }

  nt2nq = require("./nt2nq");

  iconclass = require("./iconclass");

  gnd = require("./gnd");

  getty = require("./getty");

  to = miss.pipeline.obj(new N3.StreamWriter({format}), process.stdout);

  cb = function(err) {
    if (err != null) {
      console.error(err);
    }
    return process.exitCode = err != null ? 1 : 0;
  };

  switch (dataset) {
    case "iconclass":
      miss.pipe(iconclass.stream(), iconclass.parsed(), to, cb);
      break;
    case "gnd":
      miss.pipe(gnd.stream(), gnd.parsed(), to, cb);
      break;
    case "getty":
      to = miss.pipeline.obj(getty.parsed(), to);
      subset = (function() {
        switch (subset) {
          case "subjects":
            return getty.subjects;
          case "hierarchy":
            return getty.hierarchy;
        }
      })();
      getty.aat(to, subset);
      to.on("error", cb);
      break;
    case "-":
      if (graph != null) {
        to = miss.pipeline.obj(nt2nq(graph), to);
      }
      miss.pipe(process.stdin, new N3.StreamParser(), to, cb);
      break;
    default:
      cb(`Unknown dataset: ${dataset}`);
  }

}).call(this);

//# sourceMappingURL=stream.js.map
