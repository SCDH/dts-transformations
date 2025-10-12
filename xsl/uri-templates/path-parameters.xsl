<!-- An implementation of the required uri-templates following the all-path-parameters pattern

-->
<xsl:package name="https://scdh.github.io/dts-transformations/xsl/uri-templates/path-parameters.xsl"
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
          select="($api-base-uri || $navigation-path || (map:get($parameters, 'resource') => $encode()) || '/' || dts:path-parameters($parameters, ('ref', 'down', 'start', 'end', 'tree', 'page'))) => xs:anyURI()"
        />
      </xsl:function>

      <xsl:function name="dts:collection-uri-template-on-resource" as="xs:anyURI?"
        visibility="public">
        <xsl:param name="resource" as="document-node()"/>
        <xsl:param name="parameters" as="map(xs:string, item()*)"/>
        <xsl:sequence
          select="($api-base-uri || $collection-path || (map:get($parameters, 'resource') => $encode()) || '/{page,nav}') => xs:anyURI()"
        />
      </xsl:function>

      <xsl:function name="dts:navigation-uri-template-on-resource" as="xs:anyURI?"
        visibility="public">
        <xsl:param name="resource" as="document-node()"/>
        <xsl:param name="parameters" as="map(xs:string, item()*)"/>
        <xsl:sequence
          select="($api-base-uri || $navigation-path || (map:get($parameters, 'resource') => $encode()) || '/{ref,down,start,end,tree,page}') => xs:anyURI()"
        />
      </xsl:function>

      <xsl:function name="dts:document-uri-template-on-resource" as="xs:anyURI?" visibility="public">
        <xsl:param name="resource" as="document-node()"/>
        <xsl:param name="parameters" as="map(xs:string, item()*)"/>
        <xsl:sequence
          select="($api-base-uri || $document-path || (map:get($parameters, 'resource') => $encode()) || '/{ref,start,end,tree,mediaType}') => xs:anyURI()"
        />
      </xsl:function>

    </xsl:override>
  </xsl:use-package>

  <xsl:function name="dts:path-parameters" as="xs:string" visibility="private">
    <xsl:param name="parameters" as="map(xs:string, item()*)"/>
    <xsl:param name="order" as="xs:string+"/>
    <xsl:sequence select="($order ! map:get($parameters, .) ! $encode(.)) => string-join('/')"/>
  </xsl:function>

</xsl:package>
