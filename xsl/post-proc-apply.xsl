<!-- example XSLT package for post-processing using a mode as entry point
-->
<xsl:package name="https://scdh.github.io/dts-transformations/xsl/post-proc-apply.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all" version="3.0" default-mode="post-proc">

  <xsl:mode name="post-proc" on-no-match="shallow-copy" visibility="public"/>

</xsl:package>
