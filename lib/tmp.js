const Promise = require("bluebird");

const del = require("del");
const tmp = require("tmp");

const tmpName = Promise.promisify(tmp.tmpName);

module.exports = {
    name(options={}) {
        const { logger } = options;
        return tmpName(options).disposer(
            tmpFile => del(tmpFile, { force: true }).catch(
                err => (logger ? logger.info({ err }, tmpFile) : tmpFile)
            )
        );
    }
};