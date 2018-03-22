#!/usr/bin/env node

const assert = require("assert");
const path = require("path");

const xfs = require("fs-extra");

const args = require("minimist")(process.argv.slice(2));

const cli = require("../lib/cli");
const spawn = require("../lib/spawn");

const { test } = args;
const [ database ] = args._;
assert.ok(database, "No database specified");

const cwd = process.cwd();

const databases = path.resolve(process.env["FUSEKI_BASE"] || cwd, "databases");
const [ backup, dest, live] = [".old", ".new", ""]
      .map(suffix => path.resolve(databases, [database, suffix].join("")));

function remove(dir) {
    return xfs.remove(dir).then(() => dir, () => dir);
}

cli(() => {
    const loaded = remove(dest)
          .then(() => xfs.ensureDir(dest))
          .then(() => spawn(
              { stdio: "inherit" },
              "tdbloader", "--loc", dest
          ));

    if (test) {
        return loaded;
    }

    const stopped = loaded
          .then(() => spawn(
              { stdio: "inherit" },
              "sudo", "systemctl", "stop", "fuseki.service"
          ));

    const exchanged = stopped
          .then(() => remove(backup))
          .then(() => xfs.ensureDir(live))
          .then(() => xfs.move(live, backup))
          .then(() => xfs.move(dest, live));

    const restarted = exchanged
          .then(() => spawn(
              { stdio: "inherit" },
              "sudo", "systemctl", "start", "fuseki.service"
          ));

    return restarted;
});
