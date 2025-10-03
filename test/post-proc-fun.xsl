<!-- example XSLT package for post-processing using a named template as entry point
-->
<xsl:package name="https://scdh.github.io/dts-transformations/xsl/post-proc-fun.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dts="https://distributed-text-services.github.io/specifications/"
  exclude-result-prefixes="#all" version="3.0">

  <!-- entry point called from document.xsl -->
  <xsl:function name="dts:post-proc" as="node()*" visibility="public">
    <xsl:param name="nodes" as="node()*"/>
    <xsl:param name="mediaType" as="xs:string"/>
    <xsl:param name="resource" as="xs:string?"/>
    <xsl:param name="document-root" as="document-node()"/>

    <!-- do what ever you want -->
    <xsl:sequence select="$nodes"/>

  </xsl:function>

</xsl:package>
