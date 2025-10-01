<!-- XSLT package for getting a part of a document as required by DTS document endpoint

-->
<xsl:package name="https://scdh.github.io/dts-transformations/xsl/document.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:dts="https://distributed-text-services.github.io/specifications/"
  exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0"
  default-mode="document">

  <xsl:mode name="document" on-no-match="fail" visibility="final"/>

  <xsl:use-package name="https://scdh.github.io/dts-transformations/xsl/tree.xsl"
    package-version="1.0.0"/>

  <xsl:template name="xsl:initial-template" visibility="public">
    <xsl:apply-templates mode="document" select="doc($resource)"/>
  </xsl:template>

  <xsl:template mode="document" match="document-node()">
    <xsl:choose>
      <xsl:when test="not(exists($ref) or exists($start) or exists($end))">
        <xsl:copy-of select="."/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:package>
