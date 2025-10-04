<xsl:package name="https://scdh.github.io/dts-transformations/xsl/dts.xsl" package-version="1.0.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:dts="https://distributed-text-services.github.io/specifications/"
  exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

  <xsl:param name="dts-version" as="xs:string" select="'1.0rc1'"/>

  <xsl:param name="context-url" as="xs:string"
    select="'https://distributed-text-services.github.io/specifications/context/' || $dts-version ||'.json'"/>

  <xsl:variable name="context" visibility="final">
    <xsl:map-entry key="'@context'" select="$context-url"/>
    <xsl:map-entry key="'dtsVersion'" select="$dts-version"/>
  </xsl:variable>

</xsl:package>
