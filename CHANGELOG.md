# Changes

## 0.5.5

- makes `mediaTypes` for DTS Resources in SPARQL queries for the
  collection endpoint work with SEED's parameter injection
- adjusts `mediaType` config parameter for document endpoint
- updates default context with a current copy from the spec's context
- adds a context map to the SEED package

## 0.5.4

- fixes some aspects of the SPARQL and JSON-LD framing for the collection endpoint
  - `member` is container (array) even when there's only one member
  - adds extension property `requested` which is semantically
    meaningless but is required for getting JSON-LD framing for the
    SPARQL result working: We need an exclusive property to
    distinguish the request resource and the members, otherwise
    framing does not work.
  - adds `mediaType` for DTS Resources, with `application/tei+xml` as
    default value
  - revision of some context properties:
	- `citationTrees` is a container (array)
	- `citeStructure` is a container (array)
	- `identifier` for citeable units is now unprotected
	- properties for URI templates are now unprotected

## 0.5.3

- fixes parameters of SPARQL for collection endpoint 
- adds `nav` and `page` parameters because they are in the specs

## 0.5.2

- fixes JSON-LD frame for making the collection endpoint's JSON output

## 0.5.1

- adds the SPARQL queries for the collection endpoint to the testing SEED configuration
- fixes the modularized context list for the SEED config of the
  collection endpoint: a remote context cannot have a list to other
  remote contexts

## 0.5.0

- adds SPARQL queries for getting data for the collection endpoint
  from a graph with all the DTS collection metadata.

## 0.4.12

- SEED configurations support transformation types
- the `DtsDocumentProcessor` type is assigned to `document.xsl` and to
  chained transformations

## 0.4.11

- adds utilities for generating SEED config for chained transformations (fixes issue #20)
- adds a testing package for SEED with chained transformation

## 0.4.10

- adds saxon config for SEED with assertions enabled (fixes issue #18)
- changes transformation type in SEED config (see issue #16 again)
- send HTTP status code in terminating message like required by SEED (see issue #19)

## 0.4.9

- fixes transformation type in SEED config (see issue #16)

## 0.4.8

- do not fail for documents without citation tree declaration in `<refsDecl>` (fixes issue #13)
- improved project infrastructure:
  - unit tests independend of volatile upstream specs (fixes issue #15)
  - improves package building
  - adds missing yaml config file to SEED package (fixes issue #14)

## 0.4.7

- adds modular context in `xsl/context/modules`

## 0.4.6

- make output for test suite with gist
  [`https://gist.github.com/lueck/d1476d00e07969685df5856518cdd053`](https://gist.github.com/lueck/d1476d00e07969685df5856518cdd053)

## 0.4.5

- fixes issue #11
- output of community test cases stored in `test/community-cases.txt`
  is stored as a release asset for simple comparison with other
  implementations

## 0.4.4

- fixes issue #7

## 0.4.3

- fixes issue #6

## 0.4.2

- fixes issue #4

## 0.4.0

- allows customization of the relation of `resource` and the document
  location by replacing the `.../resource.xsl` XSLT package via a
  Saxon configuration file
- fixes the Oxygen transformation scenarios, which were still behind
  version 0.1.1

## 0.3.0

- fixes issue #2 by providing a package for URL templates with query parameters
- introduces alternative URL templates with path parameters

## 0.2.0

- introduces function `dts:compact($s as xs:string)` for making URI's
  or prefixed values compact according to the configured `@context`
- support `<citeData>` for the navigation endpoint
  - uses compaction function for compacting the property's name and value
  - does not yet treat dublin core metadata in any special way
- adds experimental stylesheet parameter
  `marked-virtual-children`. When set to `true()`, this adds a boolean
  property `dts:inParentSubtree` to each member, indicating whether
  its constructed subtree is a descendant of the root of the subtree
  that is constructed for the parent member.

## 0.1.2

- fixes issue #3
- corrects name *URL templates* to *URI templates* and changes paths
  accordingly

## 0.1.1

- choose default citation tree and names of other trees on the basis
  of `refsDecl/@default` and `refsDecl/@n`
- assert that there's exactly one default citation tree by declaration
- assert that all other citation trees are labelled

## 0.1.0

- introduces configurable error codes that deployments can catch in
  order to return HTTP 4XX error codes
- makes the URL template configurable by static parameters
- makes the `@context` URL configurable
- `<dts:wrapper>` has the `dts` name prefix, test assured
- XSLT packages for navigation and document endpoints available
  through Saxon config

## 0.0.2

- latest release's contents available on pages for remote processing

## 0.0.1

- XLST for navigation and document endpoints
- oxygen framework with transformation scenarios
- URL templates are the most obvious issue
