const { assign } = Object;

module.exports = {
    aat(...components) {
        const paths = components.map(c => `AATOut_${c}.nt`);

        return assign({
            url: "http://vocab.getty.edu/dataset/aat/explicit.zip",
            graph: "http://vocab.getty.edu/aat",
            unzip: true,
            unzipFilter: paths.length == 0
                ? undefined
                : ({ path }) => paths.indexOf(path) >= 0
        });
    }

}