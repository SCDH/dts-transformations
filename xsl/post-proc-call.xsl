<!-- example XSLT package for post-processing using a named template as entry point
-->
<xsl:package name="https://scdh.github.io/dts-transformations/xsl/post-proc-call.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="3.0">

  <!-- entry point called from document.xsl -->
  <xsl:template name="post-proc" visibility="public">
    <xsl:param name="nodes" as="node()*"/>
    <xsl:param name="mediaType" as="xs:string" tunnel="true"/>
    <xsl:param name="resource" as="xs:string?" tunnel="true"/>
    <xsl:param name="document-root" as="document-node()" tunnel="true"/>

    <!-- do what ever you want -->
    <xsl:sequence select="$nodes"/>

  </xsl:template>

</xsl:package>
