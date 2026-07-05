<!-- An implementation of the required uri-templates for the DTS implementation of SEED XC

Templates are simply passed in.

-->
<xsl:package name="https://scdh.github.io/dts-transformations/xsl/uri-templates/seed-xc.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:dts="https://distributed-text-services.github.io/specifications/"
  exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

  <xsl:param name="collection-uri-template" as="xs:string" select="'...'"/>

  <xsl:param name="navigation-uri-template" as="xs:string" select="'...'"/>

  <xsl:param name="document-uri-template" as="xs:string" select="'...'"/>

  <xsl:use-package name="https://scdh.github.io/dts-transformations/xsl/uri-templates/base.xsl"
    package-version="1.0.0">
    <xsl:accept component="function" names="dts:*" visibility="public"/>
    <xsl:override>

      <xsl:function name="dts:navigation-uri" as="xs:string?" visibility="public">
        <xsl:param name="resource" as="document-node()"/>
        <xsl:param name="parameters" as="map(xs:string, item()*)"/>
        <xsl:value-of select="map:get($parameters, 'resource')"/>
      </xsl:function>

      <xsl:function name="dts:collection-uri-template-on-resource" as="xs:string?"
        visibility="public">
        <xsl:param name="resource" as="document-node()"/>
        <xsl:param name="parameters" as="map(xs:string, item()*)"/>
        <xsl:value-of select="$collection-uri-template"/>
      </xsl:function>

      <xsl:function name="dts:navigation-uri-template-on-resource" as="xs:string?"
        visibility="public">
        <xsl:param name="resource" as="document-node()"/>
        <xsl:param name="parameters" as="map(xs:string, item()*)"/>
        <xsl:value-of select="$navigation-uri-template"/>
      </xsl:function>

      <xsl:function name="dts:document-uri-template-on-resource" as="xs:string?" visibility="public">
        <xsl:param name="resource" as="document-node()"/>
        <xsl:param name="parameters" as="map(xs:string, item()*)"/>
        <xsl:value-of select="$document-uri-template"/>
      </xsl:function>

    </xsl:override>
  </xsl:use-package>

</xsl:package>
