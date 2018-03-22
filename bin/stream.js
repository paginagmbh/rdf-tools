#!/usr/bin/env node

const { assign } = Object;

const path = require("path");
const { PassThrough } = require("stream");
const Promise = require("bluebird");

const cli = require("../lib/cli");
const n3Stream = require("../lib/n3-stream");

const standardDatasets = path.resolve(__dirname, "..", "lib", "datasets");

function optional(spec) {
    try {
        return require(spec);
    } catch (e) {
        return undefined;
    }
}

const resolvers = [
    (spec) => optional(spec),
    (spec) => optional(path.resolve(standardDatasets, spec)),
    (url) => url.search(/^https?:\/\//) == 0 ? { url } : undefined,
    (path) => ({ path })
];

const resolve = (spec) => resolvers.reduce(
    (result, resolver) => result = result || resolver(spec),
    undefined
);

const { unparsed, format, _ } = assign(
    { unparsed: false, format: "N-Quads" },
    require("minimist")(process.argv.slice(2))
);

const parsed = !unparsed;

const datasets = _.map(resolve).filter(ds => ds).map(ds => assign({ parsed }, ds));

if (datasets.length == 0) {
    process.exit(0);
}

cli(() => {
    let source = new PassThrough({ objectMode: parsed });
    let stream = source;

    if (parsed) {
        stream = stream.pipe(n3Stream.write({ format }));
    }

    stream = stream.pipe(process.stdout, { end: false });

    n3Stream.read(datasets.shift())
        .on("end", () => {
            const next = datasets.shift();
            next ? n3Stream.read(next).pipe(source, { end: false }) : source.end();
        })
        .pipe(source, { end: false })
        .on("error", (err) => source.emit("error", err));

    return new Promise(
        (resolve, reject) => stream
            .on("finish",  resolve)
            .on("error", reject)
    );
});