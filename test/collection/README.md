# Collecton Endpoint Examples

There is an example collection metadata dataset in `collection.json`.

The following manual steps simulate what is done on SEED XC for
getting `/collection&id=agrapha&nav=parents` from the sample
collection.


## Manual Steps

### Preparation

Install all required tools:

```
./mvnw package
```
Convert Collection metadata dataset:

```shell
target/bin/riot.sh --syntax=jsonld --out=ntriples --base='http://example.com/' test/collection/collection.json > test/collection/collection.n3
```
### Per Request

#### Edit Query

uncomment `BIND(<http://example.com/agrapha> as ?resource ) .` in `sparql/parents.rq` with editor

#### Run SPARQL query

```shell
target/bin/sparql.sh --data=test/collection.n3 --query=sparql/parents.rq > test/collection/output/agrapha-parents.ttl
```

#### Converting to JSON-LD for Titanium

```shell
target/bin/riot.sh --out=JSONLD test/collection/output/agrapha-parents.ttl > test/collection/output/agrapha-parents.json
```

#### Framing to the collection endpoint's JSON output

```shell
target/bin/ld-cli frame --input=file:$(realpath test/collection/output/agrapha-parents.json)  file:$(realpath sparql/frame.json) --pretty --omit-graph
```

## Identifiers

### Findings from Experiments

Using `@base` in the `@context` is important when not writing IRIs
into `@id` of the collection metadata file.


- `"@base": "data:"` works and leads to IRIs `<data:...>`
- `"@base": ""` will expand relative IDs based on the filename => no good idea!
- `"@base": null` will make the JSON-LD processor keep relative IRIs,
  like section 4.1.3 of the JSON-LD specs says: "Setting @base to null
  will prevent relative IRI references from being expanded to IRIs."
  https://www.w3.org/TR/json-ld11/#base-iri . However, the RDF parser,
  which reads the output stream of the JSON-LD processor will resolve
  the relative IRIs against a base URI.

