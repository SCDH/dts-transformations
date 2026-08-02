<xsl:package name="http://wwu.de/scdh/selection-engine/node-tracing" package-version="1.0.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:trace="http://wwu.de/scdh/selection-engine/node-tracing" exclude-result-prefixes="#all"
  version="3.0">

  <xsl:template name="trace:source-id" as="attribute()?" visibility="final">
    <xsl:context-item as="node()" use="required"/>
  </xsl:template>

  <xsl:template name="trace:text" as="node()" visibility="final">
    <xsl:context-item as="text()" use="required"/>
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template name="trace:root" as="item()*" visibility="final">
    <xsl:apply-templates mode="#current"
      select="node() | attribute() | comment() | processing-instruction()"/>
  </xsl:template>

</xsl:package>
