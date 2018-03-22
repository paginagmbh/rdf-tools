## Usage

### Streaming RDF datasets

``` shell
$ rdf-stream\
    iconclass\
    getty-aat-hierarchy\
    ./local/data.ttl\
    http://authority.net/dump.nq\
    >combined-dataset.nq
```

### Loading datasets into Apache Jena TDB

``` shell
$ rdf-stream gnd getty-aat iconclass | tdbloader --loc authority-db
```