<!-- XSLT package that defines error codes
  
The parameter values will be made to QNames in the namespace context of this package.
-->
<xsl:package name="https://scdh.github.io/dts-transformations/xsl/errors.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:dts="https://distributed-text-services.github.io/specifications/"
  xmlns:http="https://www.rfc-editor.org/rfc/rfc9110.html"
  exclude-result-prefixes="#all" version="3.0">

  <xsl:param name="dts:http400" as="xs:string" static="true" select="'http:ERR400'"/>

  <xsl:function name="dts:error-to-eqname" as="xs:QName" visibility="public">
    <xsl:param name="configured-code" as="xs:string"/>
    <xsl:sequence select="$configured-code => xs:QName()"/>
  </xsl:function>

</xsl:package>
