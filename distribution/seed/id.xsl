<!-- identity transformation with Selene node tracing capability -->
<xsl:package name="https://scdh.github.io/dts-transformations/distribution/seed/id.xsl" package-version="1.0.0"
  version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:trace="http://wwu.de/scdh/selection-engine/node-tracing" xmlns="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" default-mode="tei">

  <xsl:output method="xml" indent="false"/>

  <xsl:use-package name="http://wwu.de/scdh/selection-engine/node-tracing" package-version="1.0.0"/>

  <xsl:template name="entry" visibility="public">
    <xsl:param name="nodes" as="node()*"/>
    <xsl:param name="mediaType" as="xs:string?" tunnel="true"/>
    <xsl:param name="resource" as="xs:string?" tunnel="true"/>
    <xsl:param name="tree" as="xs:string?" tunnel="true"/>
    <xsl:param name="ref" as="xs:string?" tunnel="true"/>
    <xsl:param name="start" as="xs:string?" tunnel="true"/>
    <xsl:param name="end" as="xs:string?" tunnel="true"/>
    <xsl:param name="document-root" as="document-node()" tunnel="true"/>


    <!-- wrap everything inside xsl:document instead of trace:root -->
    <xsl:document>
      <xsl:choose>
        <xsl:when test="not($ref or $start or $end)">
          <xsl:apply-templates select="$nodes"/>
        </xsl:when>
        <xsl:otherwise>
          <TEI>
            <xsl:if test="$resource">
              <xsl:attribute name="xml:base" select="$resource"/>
            </xsl:if>
            <!--xsl:copy select="$document-root/TEI/@*"/>
            <xsl:apply-templates select="$document-root/TEI/teiHeader"/-->
            <dts:wrapper xmlns:dts="https://w3id.org/api/dts#">
              <xsl:apply-templates select="$nodes"/>
            </dts:wrapper>
          </TEI>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:document>
  </xsl:template>


  <!-- identity transformation with node tracing capability -->
  <xsl:mode name="tei" on-no-match="shallow-copy" visibility="public"/>

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
