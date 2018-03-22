const { assign } = Object;

const fs = require("fs");
const { PassThrough } = require("stream");
const zlib = require("zlib");
const { URL } = require("url");

const N3 = require("n3");
const request = require("request");
const parseUnzip = require("unzip").Parse;
const through = require("through");

function nt2nq(graph) {
    return through(function({ subject, predicate, object }) {
        this.queue({ graph, subject, predicate, object });
    });
}

module.exports = {

    read(options) {
        const { pathname } = options.url
              ? new URL(options.url)
              : { pathname: options.path };

        const { url, path, gzip, gunzip, unzip, unzipFilter, parsed, graph } = assign({
            url: undefined,
            path: undefined,

            gzip: !pathname.endsWith(".gz"),
            gunzip: pathname.endsWith(".gz"),

            unzip: false,
            unzipFilter: undefined,

            parsed: true,
            graph: undefined
        }, options);


        let stream = url ? request({ url, gzip }) : fs.createReadStream(path);

        if (gunzip) {
            stream = stream.pipe(zlib.createGunzip());
        }

        if (unzip) {
            const parser = parsed ? N3.StreamParser() : new PassThrough();

            stream.pipe(parseUnzip())
                .on("entry", (entry) => {
                    if (unzipFilter && !unzipFilter(entry)) {
                        entry.autodrain();
                        return;
                    }

                    entry.pipe(parser, { end: false });
                })
                .on("error", (err) => parser.emit("error", err))
                .on("finish", () => parser.end());

            stream = parser;
        } else if (parsed) {
            stream = stream.pipe(new N3.StreamParser());
        }

        if (parsed && graph) {
            stream = stream.pipe(nt2nq(graph));
        }

        return stream;
    },

    write(options) {
        return new N3.StreamWriter(options);
    }
};