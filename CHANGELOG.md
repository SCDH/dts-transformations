# Changes

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
