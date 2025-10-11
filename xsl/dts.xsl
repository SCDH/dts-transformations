<xsl:package name="https://scdh.github.io/dts-transformations/xsl/dts.xsl" package-version="1.0.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:dts="https://distributed-text-services.github.io/specifications/"
  exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

  <xsl:param name="dts-version" as="xs:string" select="'1.0rc1'"/>

  <xsl:param name="context-url" as="xs:string"
    select="'https://distributed-text-services.github.io/specifications/context/' || $dts-version ||'.json'"/>

  <xsl:variable name="context" visibility="final">
    <xsl:map-entry key="'@context'" select="$context-url"/>
    <xsl:map-entry key="'dtsVersion'" select="$dts-version"/>
  </xsl:variable>

  <xsl:variable name="context-json" as="map(xs:string, item()*)" visibility="public">
    <xsl:choose>
      <xsl:when
        test="$context-url eq 'https://distributed-text-services.github.io/specifications/context/1.0rc1.json'">
        <xsl:sequence
          select="'./context/1.0rc1.json' => resolve-uri(static-base-uri()) => unparsed-text() => parse-json()"
        />
      </xsl:when>
      <xsl:when test="unparsed-text-available($context-url)">
        <xsl:sequence select="unparsed-text($context-url) => parse-json()"/>
      </xsl:when>
      <xsl:when
        test="concat('context/', $dts-version, '.json') => resolve-uri(static-base-uri()) => unparsed-text-available()">
        <xsl:sequence
          select="concat('context/', $dts-version, '.json') => resolve-uri(static-base-uri()) => unparsed-text() => parse-json()"
        />
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence
          select="'context/1.0rc1.json' => resolve-uri(static-base-uri()) => unparsed-text() => parse-json()"
        />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:function name="dts:parse-context" as="map(*)" visibility="final">
    <xsl:sequence select="$context-json"/>
  </xsl:function>

  <xsl:function name="dts:expand-prefixes" as="xs:string" visibility="final">
    <xsl:param name="value" as="xs:string"/>
    <xsl:param name="context" as="node()"/>
    <xsl:variable name="prefixDefs" as="element(prefixDef)*" select="$context//prefixDef"/>
    <xsl:variable name="prefix" select="tokenize($value, ':')[1]"/>
    <xsl:variable name="rest" select="tokenize($value, ':')[position() gt 1] => string-join(':')"/>
    <xsl:choose>
      <xsl:when test="$prefixDefs[matches(@ident, $prefix) and matches(@matchPattern, $rest)]">
        <xsl:variable name="prefixDef" as="element(prefixDef)"
          select="$prefixDefs[matches(@ident, $prefix) and matches(@matchPattern, $rest)][1]"/>
        <xsl:sequence
          select="replace($rest, $prefixDef/@matchPattern, $prefixDef/@replacementPattern)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- makes a URI or prefixed property more compact based on context from context URL -->
  <xsl:function name="dts:compact" as="xs:string*" visibility="public">
    <xsl:param name="value" as="xs:string"/>
    <xsl:variable name="context" as="map(*)" select="$context-json => map:get('@context')"/>
    <xsl:iterate select="$context => map:keys()">
      <xsl:on-completion>
        <xsl:sequence select="$value"/>
      </xsl:on-completion>
      <xsl:variable name="key" as="xs:string" select="."/>
      <xsl:message use-when="system-property('debug') eq 'true'">
        <xsl:text>testing key </xsl:text>
        <xsl:value-of select="$key"/>
      </xsl:message>
      <xsl:choose>
        <xsl:when test="matches($key, '^dublinCore')">
          <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>dropping dublinCore</xsl:text>
          </xsl:message>
        </xsl:when>
        <xsl:when test="$value eq map:get($context, $key)">
          <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>is mapped property</xsl:text>
          </xsl:message>
          <xsl:sequence select="$key"/>
          <xsl:break/>
        </xsl:when>
        <xsl:when
          test="matches(map:get($context, $key), '[/#]$') and matches($value, concat('^', map:get($context, $key)))">
          <!-- prefix - URI mapping -->
          <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>found prefix mapping</xsl:text>
          </xsl:message>
          <xsl:sequence
            select="($key || ':' || substring($value, string-length(map:get($context, $key)) + 1)) => dts:compact()"/>
          <xsl:break/>
        </xsl:when>
      </xsl:choose>
    </xsl:iterate>
  </xsl:function>

</xsl:package>
