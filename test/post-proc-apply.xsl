<!-- example XSLT package for post-processing using a mode as entry point

The template set from the mode declared as media-type-processor is applied to
the nodes extracted by dts:cut-ref($ref) dts:cut-start-end($start, $end) or
the whole document.

If no mode is declared as media-type-processor, the package's default mode
(here 'post-proc') is used. Also see post-proc-apply.xspec!

Note, that templates have access to the following tunnel parameters:

    <xsl:param name="mediaType" as="xs:string?" tunnel="true"/>
    <xsl:param name="resource" as="xs:string?" tunnel="true"/>
    <xsl:param name="tree" as="xs:string?" tunnel="true"/>
    <xsl:param name="ref" as="xs:string?" tunnel="true"/>
    <xsl:param name="start" as="xs:string?" tunnel="true"/>
    <xsl:param name="end" as="xs:string?" tunnel="true"/>
    <xsl:param name="document-root" as="document-node()" tunnel="true"/>

-->
<xsl:package name="https://scdh.github.io/dts-transformations/xsl/post-proc-apply.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all" version="3.0" default-mode="post-proc">

  <xsl:mode name="post-proc" on-no-match="shallow-copy" visibility="public"/>

</xsl:package>
