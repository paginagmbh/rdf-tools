const path = require("path");

const Promise = require("bluebird");

module.exports = function(transform) {
    const [, command] = process.argv;
    const name = path.basename(command, ".js");
    const logger = require("bunyan").createLogger({
        name,
        streams: [ process.env["RDF_DEBUG"]
                   ? { path: `${name}.log` }
                   : { stream: process.stderr } ],
        level: process.env["RDF_DEBUG"] ? "trace" : "info"
    });

    return Promise.resolve(transform(logger))
        .catch(
            { code: "EPIPE"},
            () => {
                process.exit(0);
            }
        )
        .then(
            (result) => {
                process.exitCode = 0;
                return result;
            },
            (err) => {
                logger.fatal({ err }, err);
                process.exitCode = 1;
            }
        );
};