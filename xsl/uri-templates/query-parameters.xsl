<!-- An implementation of the required uri-templates following the all-query-parameters pattern

-->
<xsl:package
  name="https://scdh.github.io/dts-transformations/xsl/uri-templates/query-parameters.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:dts="https://distributed-text-services.github.io/specifications/"
  exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

  <xsl:use-package name="https://scdh.github.io/dts-transformations/xsl/uri-templates/base.xsl"
    package-version="1.0.0">
    <xsl:accept component="function" names="dts:*" visibility="public"/>
    <xsl:override>

      <xsl:function name="dts:navigation-uri" as="xs:anyURI?" visibility="public">
        <xsl:param name="resource" as="document-node()"/>
        <xsl:param name="parameters" as="map(xs:string, item()*)"/>
        <xsl:sequence
          select="($api-base-uri || $navigation-path || '?' || dts:query-parameters($parameters)) => xs:anyURI()"
        />
      </xsl:function>

      <xsl:function name="dts:collection-uri-template-on-resource" as="xs:anyURI?"
        visibility="public">
        <xsl:param name="resource" as="document-node()"/>
        <xsl:param name="parameters" as="map(xs:string, item()*)"/>
        <xsl:sequence
          select="($api-base-uri || $collection-path || '?resource=' || (map:get($parameters, 'resource') => $encode()) || '{&amp;page,nav}') => xs:anyURI()"
        />
      </xsl:function>

      <xsl:function name="dts:navigation-uri-template-on-resource" as="xs:anyURI?"
        visibility="public">
        <xsl:param name="resource" as="document-node()"/>
        <xsl:param name="parameters" as="map(xs:string, item()*)"/>
        <xsl:sequence
          select="($api-base-uri || $navigation-path || '?resource=' || (map:get($parameters, 'resource') => $encode()) || '{&amp;ref,down,start,end,tree,page}') => xs:anyURI()"
        />
      </xsl:function>

      <xsl:function name="dts:document-uri-template-on-resource" as="xs:anyURI?" visibility="public">
        <xsl:param name="resource" as="document-node()"/>
        <xsl:param name="parameters" as="map(xs:string, item()*)"/>
        <xsl:sequence
          select="($api-base-uri || $document-path ||'?resource=' || (map:get($parameters, 'resource') => $encode()) || '{&amp;ref,start,end,tree,mediaType}') => xs:anyURI()"
        />
      </xsl:function>

    </xsl:override>
  </xsl:use-package>

  <xsl:function name="dts:query-parameters" as="xs:string" visibility="private">
    <xsl:param name="parameters" as="map(xs:string, item()*)"/>
    <xsl:sequence
      select="map:for-each($parameters, function ($k, $v) { $k || '=' || $encode($v) }) => string-join('&amp;')"
    />
  </xsl:function>

  <xsl:function name="dts:query-templates" as="xs:string" visibility="private">
    <xsl:param name="parameters" as="map(xs:string, item()*)"/>
    <xsl:sequence
      select="'{&amp;' || map:for-each($parameters, function ($k, $v) { $k }) => string-join(',') || '}'"
    />
  </xsl:function>

</xsl:package>
