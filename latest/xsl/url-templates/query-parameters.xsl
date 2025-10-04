<!-- An implementation of the required url-templates following the all-query-parameters pattern

-->
<xsl:package
  name="https://scdh.github.io/dts-transformations/xsl/url-templates/query-parameters.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:dts="https://distributed-text-services.github.io/specifications/"
  exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

  <xsl:param name="api-base-url" as="xs:string" select="'https://example.org/api/dts'"/>

  <xsl:function name="dts:url-template-map-entries" as="item()*" visibility="public">
    <xsl:param name="resource" as="document-node()"/>
    <xsl:param name="parameters" as="map(xs:string, item()*)"/>
    <xsl:map-entry key="'collection'" select="dts:collection-url($resource, $parameters)"/>
    <xsl:map-entry key="'navigation'" select="dts:navigation-url($resource, $parameters)"/>
    <xsl:map-entry key="'document'" select="dts:document-url($resource, $parameters)"/>
  </xsl:function>

  <xsl:function name="dts:collection-url" as="xs:anyURI?" visibility="public">
    <xsl:param name="resource" as="document-node()"/>
    <xsl:param name="parameters" as="map(xs:string, item()*)"/>
    <xsl:sequence select="dts:navigation-url-with-query-parameters($resource, $parameters)"/>
  </xsl:function>

  <xsl:function name="dts:collection-url-with-query-parameters" as="xs:anyURI?" visibility="final">
    <xsl:param name="resource" as="document-node()"/>
    <xsl:param name="parameters" as="map(xs:string, item()*)"/>
    <xsl:variable name="ps" as="xs:string"
      select="map:for-each($parameters, function ($k, $v) { $k || '=' || $v }) => string-join('&amp;')"/>
    <xsl:sequence select="($api-base-url || '/collections/?' || $ps ) => xs:anyURI()"/>
  </xsl:function>

  <xsl:function name="dts:navigation-url" as="xs:anyURI?" visibility="public">
    <xsl:param name="resource" as="document-node()"/>
    <xsl:param name="parameters" as="map(xs:string, item()*)"/>
    <xsl:sequence select="dts:navigation-url-with-query-parameters($resource, $parameters)"/>
  </xsl:function>

  <xsl:function name="dts:navigation-url-with-query-parameters" as="xs:anyURI?" visibility="final">
    <xsl:param name="resource" as="document-node()"/>
    <xsl:param name="parameters" as="map(xs:string, item()*)"/>
    <xsl:variable name="ps" as="xs:string"
      select="map:for-each($parameters, function ($k, $v) { $k || '=' || $v }) => string-join('&amp;')"/>
    <xsl:sequence select="($api-base-url || '/navigation/?' || $ps ) => xs:anyURI()"/>
  </xsl:function>

  <xsl:function name="dts:document-url" as="xs:anyURI?" visibility="public">
    <xsl:param name="resource" as="document-node()"/>
    <xsl:param name="parameters" as="map(xs:string, item()*)"/>
    <xsl:sequence select="dts:navigation-url-with-query-parameters($resource, $parameters)"/>
  </xsl:function>

  <xsl:function name="dts:document-url-with-query-parameters" as="xs:anyURI?" visibility="final">
    <xsl:param name="resource" as="document-node()"/>
    <xsl:param name="parameters" as="map(xs:string, item()*)"/>
    <xsl:variable name="ps" as="xs:string"
      select="map:for-each($parameters, function ($k, $v) { $k || '=' || $v }) => string-join('&amp;')"/>
    <xsl:sequence select="($api-base-url || '/documents/?' || $ps ) => xs:anyURI()"/>
  </xsl:function>

</xsl:package>
