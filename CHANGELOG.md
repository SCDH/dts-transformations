# Changes

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
