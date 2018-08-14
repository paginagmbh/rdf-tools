# ECMAScript Tools for RDF datasets

## License

BSD

## Usage

### Streaming RDF datasets

``` shell
$ rdf-stream iconclass
$ curl https://net.org/xyz.gz | gunzip | rdf-stream --graph urn:test -
```

### Loading datasets into Apache Jena TDB

``` shell
$ rdf-stream iconclass | rdf-tdb-loader authority-db
```

## Author Information

This library was created in 2018 by [Pagina GmbH](https://www.pagina.gmbh/).
