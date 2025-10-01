<!-- XSLT package for getting a part of a document as required by DTS document endpoint

-->
<xsl:package name="https://scdh.github.io/dts-transformations/xsl/document.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:dts="https://distributed-text-services.github.io/specifications/"
  xmlns:cut="https://distributed-text-services.github.io/specifications/cut#"
  exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0"
  default-mode="document">

  <xsl:mode name="document" on-no-match="fail" visibility="final"/>

  <xsl:use-package name="https://scdh.github.io/dts-transformations/xsl/tree.xsl"
    package-version="1.0.0"/>

  <xsl:use-package name="https://scdh.github.io/dts-transformations/xsl/cut.xsl"
    package-version="1.0.0"/>

  <xsl:template name="xsl:initial-template" visibility="public">
    <xsl:apply-templates mode="document" select="doc($resource)"/>
  </xsl:template>

  <xsl:template mode="document" match="document-node(element(TEI))">
    <xsl:choose>
      <xsl:when test="not($ref or $start or $end)">
        <xsl:copy-of select="."/>
      </xsl:when>
      <xsl:when test="exists($ref)">
        <!--
          Elements wrapped in dts:member/dts:wrapper have lost their
          document context. However, we can get them in context by
          roundtripping with path expressions.
        -->
        <xsl:variable name="context" as="node()" select="."/>
        <xsl:variable name="referenced" as="node()*">
          <xsl:for-each select="dts:members(., -1, true())[1]/dts:ref-xpath ! string(.)">
            <xsl:evaluate as="node()?" context-item="$context" xpath="."/>
          </xsl:for-each>
        </xsl:variable>
        <TEI>
          <dtsc:wrapper xmlns:dtsc="https://w3id.org/api/dts#">
            <xsl:sequence select="$referenced"/>
          </dtsc:wrapper>
        </TEI>
      </xsl:when>
      <xsl:when test="$start and $end">
        <xsl:variable name="members" as="element(dts:member)*" select="dts:members(., -1, true())"/>
        <!-- see explaintion for using xpath above -->
        <xsl:variable name="first" as="node()?">
          <xsl:evaluate context-item="." as="node()?"
            xpath="$members[1]/dts:start-xpath => string()"/>
        </xsl:variable>
        <xsl:variable name="last" as="node()?">
          <xsl:evaluate context-item="." as="node()?"
            xpath="$members[last()]/dts:end-xpath => string()"/>
        </xsl:variable>
        <TEI>
          <dtsc:wrapper xmlns:dtsc="https://w3id.org/api/dts#">
            <xsl:sequence select="cut:horizontal($first, $last)"/>
          </dtsc:wrapper>
        </TEI>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:package>
