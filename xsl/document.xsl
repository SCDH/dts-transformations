<!-- XSLT package for getting a part of a document as required by DTS document endpoint

Post-processing for returning another mediaType than application/tei+xml can be customized
by the static parameters $media-type-package, $media-type-package-version and $media-type-mode.

If you prefer to evaluate the mediaType parameter by chained transformations, set the
$media-type-package parameter to a false value, i.e. either () or ''. In this case, the result
of the $ref or $start+$end processing <TEI><dts:wrapper>...</dts:wrapper></TEI> is returned
no matter what the $mediaType parameter is set to.
-->
<xsl:package name="https://scdh.github.io/dts-transformations/xsl/document.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:dts="https://distributed-text-services.github.io/specifications/"
  xmlns:cut="https://distributed-text-services.github.io/specifications/cut#"
  exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0"
  default-mode="document">

  <xsl:param name="mediaType" as="xs:string?" select="()"/>

  <xsl:param name="default-media-types" as="xs:string+" static="true"
    select="'application/tei+xml', 'application/xml', 'text/xml', 'text/tei+xml'"/>

  <!-- set this to the empty string or () if you do not want pass on to a mediaType processor -->
  <xsl:param name="media-type-package" as="xs:string?" static="true"
    select="'https://scdh.github.io/dts-transformations/xsl/post-proc.xsl'"/>

  <xsl:param name="media-type-package-version" as="xs:string?" static="true" select="'1.0.0'"/>

  <xsl:param name="media-type-mode" as="xs:string?" static="true" select="'post-proc'"/>

  <xsl:mode name="document" on-no-match="fail" visibility="public"/>

  <xsl:use-package name="https://scdh.github.io/dts-transformations/xsl/tree.xsl"
    package-version="1.0.0"/>

  <xsl:use-package name="https://scdh.github.io/dts-transformations/xsl/cut.xsl"
    package-version="1.0.0"/>

  <xsl:use-package _name="{$media-type-package}" _package-version="{$media-type-package-version}"
    use-when="$media-type-package">
    <xsl:accept component="mode" _names="{$media-type-mode}" visibility="private"/>
  </xsl:use-package>

  <xsl:template name="xsl:initial-template" visibility="public">
    <xsl:apply-templates mode="document" select="doc($resource)"/>
  </xsl:template>

  <xsl:template mode="document" match="document-node(element(TEI))" use-when="$media-type-package">
    <xsl:choose>
      <xsl:when test="not($mediaType) or ($mediaType and $mediaType = $default-media-types)">
        <xsl:call-template name="document"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="transform"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="document" match="document-node(element(TEI))"
    use-when="not($media-type-package)">
    <xsl:call-template name="document"/>
  </xsl:template>

  <xsl:template name="document" visibility="final">
    <xsl:context-item as="document-node(element(TEI))" use="required"/>
    <xsl:choose>
      <xsl:when test="not($ref or $start or $end)">
        <xsl:copy-of select="."/>
      </xsl:when>
      <xsl:when test="exists($ref)">
        <TEI>
          <dtsc:wrapper xmlns:dtsc="https://w3id.org/api/dts#">
            <xsl:sequence select="dts:cut-ref(.)"/>
          </dtsc:wrapper>
        </TEI>
      </xsl:when>
      <xsl:when test="$start and $end">
        <TEI>
          <dtsc:wrapper xmlns:dtsc="https://w3id.org/api/dts#">
            <xsl:sequence select="dts:cut-start-end(.)"/>
          </dtsc:wrapper>
        </TEI>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="transform" visibility="final" use-when="$media-type-package">
    <xsl:context-item as="document-node()" use="required"/>
    <xsl:choose>
      <xsl:when test="not($ref or $start or $end)">
        <xsl:apply-templates _mode="{$media-type-mode}" select=".">
          <xsl:with-param name="mediaType" as="xs:string" tunnel="true" select="$mediaType"/>
          <xsl:with-param name="resource" as="xs:string" tunnel="true" select="$resource"/>
          <xsl:with-param name="document-root" as="document-node()" tunnel="true" select="."/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="exists($ref)">
        <xsl:apply-templates _mode="{$media-type-mode}" select="dts:cut-ref(.)">
          <xsl:with-param name="mediaType" as="xs:string" tunnel="true" select="$mediaType"/>
          <xsl:with-param name="resource" as="xs:string" tunnel="true" select="$resource"/>
          <xsl:with-param name="document-root" as="document-node()" tunnel="true" select="."/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$start and $end">
        <xsl:apply-templates _mode="{$media-type-mode}" select="dts:cut-start-end(.)">
          <xsl:with-param name="mediaType" as="xs:string" tunnel="true" select="$mediaType"/>
          <xsl:with-param name="resource" as="xs:string" tunnel="true" select="$resource"/>
          <xsl:with-param name="document-root" as="document-node()" tunnel="true" select="."/>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>

  </xsl:template>

  <xsl:function name="dts:cut-ref" as="node()*" visibility="final">
    <xsl:param name="doc" as="document-node()"/>
    <!--
      Elements wrapped in dts:member/dts:wrapper have lost their
      document context. However, we can get them in context by
      roundtripping with path expressions.
    -->
    <xsl:for-each select="dts:members($doc, -1, true())[1]/dts:ref-xpath ! string(.)">
      <xsl:evaluate as="node()?" context-item="$doc" xpath="."/>
    </xsl:for-each>
  </xsl:function>

  <xsl:function name="dts:cut-start-end" as="node()*" visibility="final">
    <xsl:param name="doc" as="document-node()"/>
    <xsl:variable name="members" as="element(dts:member)*" select="dts:members($doc, -1, true())"/>
    <!-- see explaintion for using xpath above -->
    <xsl:variable name="first" as="node()?">
      <xsl:evaluate context-item="$doc" as="node()?" xpath="$members[1]/dts:start-xpath => string()"
      />
    </xsl:variable>
    <xsl:variable name="last" as="node()?">
      <xsl:evaluate context-item="$doc" as="node()?"
        xpath="$members[last()]/dts:end-xpath => string()"/>
    </xsl:variable>
    <xsl:sequence select="cut:horizontal($first, $last)"/>
  </xsl:function>

</xsl:package>
