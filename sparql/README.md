# SPARQL for the DTS Collection Endpoint

The **collection** endpoint serves metadata. In contrast to the
evaluation of `<tei:citeStructure>`, there cannot be a general
implementation for generating DCTerms or FRBR metadata from TEI
documents. There could only be conventions, like in the
[DoTS](https://github.com/dots-suite/dots) implementation.

Thus, this endpoint is supported by a different approach: The [SEED
DTS service implementation](https://github.com/SCDH/seed-xc/dts), for
which the DTS Transformations are developed for, has to be configured
with a large JSON-LD file containing all the metadata for Collections
and Resources served through the collection endpoint. DTS
Transformations offer SPARQL queries, that construct the required
response bodies from this JSON-LD metadata file. The structure of this
metadata file is described in detail in the documentation of the [SEED
DTS
service](https://github.com/SCDH/seed-xc/blob/main/doc/dts-records.md).

- **children.rq**: a SPARQL query for constructing a RDF graph with `nav` = `children`.
- **parents.rq**: a SPARQL query for constructing a RDF graph with `nav` = `parents`.
- **frame.json**: a JSON-LD frame for framing the RDF graph to the
  required JSON-LD response body

Can we support generating the big JSON-LD metadata file with XSLT
recipes? Yes, we can! Coming soon ...
