<xsl:package name="https://scdh.github.io/dts-transformations/xsl/resource/uri.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:dts="https://distributed-text-services.github.io/specifications/"
  exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

  <!-- turn this to false() to make processing DTS endpoint conformant -->
  <xsl:param name="absent-resource-from-baseuri" as="xs:boolean" static="true" select="true()"/>

  <xsl:use-package name="https://scdh.github.io/dts-transformations/xsl/errors.xsl"
    package-version="1.0.0"/>

  <xsl:use-package name="https://scdh.github.io/dts-transformations/xsl/resource.xsl"
    package-version="1.0.0">

    <xsl:accept component="variable" names="resource" visibility="public"/>

    <xsl:override>

      <!-- used as part of the parameter validation -->
      <xsl:function name="dts:validate-resource-parameter" as="map(xs:string, item())"
        visibility="public">
        <xsl:param name="context" as="node()"/>
        <xsl:map>
          <xsl:choose>
            <xsl:when test="not(empty($resource))">
              <xsl:map-entry key="'resource'" select="$resource"/>
            </xsl:when>
            <xsl:when test="$absent-resource-from-baseuri">
              <xsl:map-entry key="'resource'" select="base-uri($context)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message terminate="yes" error-code="{$dts:http400 => dts:error-to-eqname()}">
                <xsl:value-of xml:space="preserve">ERROR: resource parameter missing</xsl:value-of>
              </xsl:message>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:map>
      </xsl:function>

      <!-- Maps the resource parameter to a URI. This implementation is identity. -->
      <xsl:function name="dts:resource-uri" as="xs:string?" visibility="public">
        <xsl:sequence select="$resource"/>
      </xsl:function>

    </xsl:override>
  </xsl:use-package>

</xsl:package>
