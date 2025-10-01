<!-- XSLT package for shared components related to citation trees

-->
<xsl:package name="https://scdh.github.io/dts-transformations/xsl/tree.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:dts="https://distributed-text-services.github.io/specifications/"
  exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

  <xsl:param name="resource" as="xs:string?" select="()"/>
  
  <xsl:param name="ref" as="xs:string?" select="()"/>
  
  <xsl:param name="start" as="xs:string?" select="()"/>
  
  <xsl:param name="end" as="xs:string?" select="()"/>
  
  <xsl:param name="tree" as="xs:string?" select="()"/>
  
  
</xsl:package>
