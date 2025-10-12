<xsl:package name="https://scdh.github.io/dts-transformations/xsl/resource.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:dts="https://distributed-text-services.github.io/specifications/"
  exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

  <xsl:param name="resource" as="xs:string?" select="()"/>

  <!-- used as part of the parameter validation -->
  <xsl:function name="dts:validate-resource-parameter" as="map(xs:string, item())"
    visibility="abstract">
    <xsl:param name="context" as="node()"/>
  </xsl:function>

  <!-- maps the resource parameter to a URI -->
  <xsl:function name="dts:resource-uri" as="xs:string?" visibility="abstract"/>

</xsl:package>
