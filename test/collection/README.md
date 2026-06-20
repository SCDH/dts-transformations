# Collecton Endpoint Examples

## Manual Steps

### Install all required tools

```
./mvnw package
```

### Edit Query

uncomment `BIND(<http://example.com/agrapha> as ?resource ) .` in `sparql/parents.rq` with editor

### Convert Collection metadata dataset

```shell
target/bin/riot.sh --syntax=jsonld --out=ntriples --base='http://example.com/' test/collection/collection.json > test/collection/collection.n3
```

### Run SPARQL query

```shell
target/bin/sparql.sh --data=test/collection.n3 --query=sparql/parents.rq > test/collection/output/agrapha-parents.ttl
```

### Converting to JSON-LD for Titanium

```shell
target/bin/riot.sh --out=JSONLD test/collection/output/agrapha-parents.ttl > test/collection/output/agrapha-parents.json
```

### Framing to the collection endpoint's JSON output

```shell
target/bin/ld-cli frame --input=file:$(realpath test/collection/output/agrapha-parents.json)  file:$(realpath sparql/frame.json) --pretty --omit-graph
```
