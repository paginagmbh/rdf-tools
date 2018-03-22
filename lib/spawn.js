const { assign } = Object;

const cp = require("child_process");

const Promise = require("bluebird");

module.exports = function(options, arg0, ...args) {
    const command = [arg0].concat(args).join(" ");
    const spawned = cp.spawn(arg0, args, options);

    const result = { command };

    ["stdout", "stderr"].forEach(stream => {
        if (spawned[stream]) {
            result[stream] = "";
            spawned[stream].on("data", (data) => result[stream] += data);
        }
    });

    let cmd = new Promise((resolve, reject) => {
        spawned.on("close", (code) => {
            assign(result, { code });
            return code == 0 ? resolve(result) : reject(result);
        });
    });

    const { logger } = options;
    if (logger) {
        cmd = cmd.then(
            (result) => { logger.trace({ result }, command); return result; },
            (err) => { logger.error({ err }, command); return Promise.reject(err); }
        );
    }

    return cmd;
};
