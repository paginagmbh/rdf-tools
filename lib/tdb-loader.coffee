path = require "path"
cp = require "child_process"
xfs = require "fs-extra"
minimist = require "minimist"

args = minimist process.argv[2..]
{ test } = args
[ database ] = args._
process.exit 1 unless database

cwd = process.cwd()
encoding = "utf8"

fusekiBase = process.env.FUSEKI_BASE or cwd
databases = path.resolve fusekiBase, "databases"

spawn = (cmd, args, opts={}) ->
  opts = { cwd, encoding, stdio: "inherit", shell: true, opts... }
  result = cp.spawnSync cmd, args, opts
  process.exit result.status unless result.status is 0
  result

[backup, dest, live] = for suffix in [".old", ".new", ""]
    path.resolve databases, "#{database}#{suffix}"

remove = (dir) -> (xfs.remove dir).then (() -> dir), (() -> dir)

load = () ->
    await remove dest
    await xfs.ensureDir dest

    spawn "tdbloader", ["--loc", dest]

    unless test
        spawn "sudo", ["systemctl", "stop", "fuseki.service"]

        await remove backup
        await xfs.ensureDir live
        await xfs.move live, backup
        await xfs.move dest, live

        spawn "sudo", ["systemctl", "start", "fuseki.service"]

load()