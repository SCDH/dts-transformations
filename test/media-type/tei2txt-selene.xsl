<!-- a simple transformation from TEI to plain text with Selene node tracking capability -->
<xsl:package name="http://example.com/xsl/tei2txt-selene" package-version="1.0.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:trace="http://wwu.de/scdh/selection-engine/node-tracing"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.1">

  <xsl:output method="text"/>

  <xsl:use-package name="http://wwu.de/scdh/selection-engine/node-tracing" package-version="1.0.0"/>

  <xsl:use-package name="http://example.com/xsl/tei2txt" package-version="1.0.0">
    <xsl:override>
      <xsl:template mode="tei verse prose" match="text()" priority="5">
        <xsl:call-template name="trace:text"/>
      </xsl:template>
    </xsl:override>
  </xsl:use-package>


  <xsl:template name="entry" visibility="public">
    <xsl:param name="nodes" as="node()*"/>
    <xsl:param name="mediaType" as="xs:string?" tunnel="true"/>
    <xsl:param name="resource" as="xs:string?" tunnel="true"/>
    <xsl:param name="tree" as="xs:string?" tunnel="true"/>
    <xsl:param name="ref" as="xs:string?" tunnel="true"/>
    <xsl:param name="start" as="xs:string?" tunnel="true"/>
    <xsl:param name="end" as="xs:string?" tunnel="true"/>
    <xsl:param name="document-root" as="document-node()" tunnel="true"/>

    <xsl:document>
      <xsl:apply-templates mode="tei" select="$nodes"/>
    </xsl:document>

  </xsl:template>

</xsl:package>
