<!-- identity transformation with Selene node tracing capability -->
<xsl:package name="https://scdh.github.io/dts-transformations/xsl/id.xsl" package-version="1.0.0"
  version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:trace="http://wwu.de/scdh/selection-engine/node-tracing"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" default-mode="tei">

  <xsl:mode name="tei" on-no-match="shallow-copy" visibility="public"/>

  <xsl:use-package name="http://wwu.de/scdh/selection-engine/node-tracing" package-version="1.0.0"/>

  <xsl:template match="/">
    <xsl:call-template name="trace:root"/>
  </xsl:template>

  <xsl:template match="element()">
    <xsl:copy>
      <xsl:call-template name="trace:source-id"/>
      <xsl:apply-templates select="node() | attribute() | comment() | processing-instruction()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:call-template name="trace:text"/>
  </xsl:template>

</xsl:package>
