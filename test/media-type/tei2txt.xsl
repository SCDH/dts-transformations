<!-- a simple transformation from TEI to plain text -->
<xsl:package name="http://example.com/xsl/tei2txt" package-version="1.0.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0" default-mode="tei">

  <xsl:output method="text"/>

  <xsl:mode name="tei" on-no-match="shallow-skip"/>

  <xsl:mode name="prose" on-no-match="shallow-skip"/>

  <xsl:mode name="verse" on-no-match="shallow-skip"/>

  <xsl:template mode="#all" match="TEI">
    <xsl:apply-templates mode="#current" select="text"/>
  </xsl:template>

  <xsl:template mode="#all" match="p | ab | head">
    <xsl:apply-templates mode="prose"/>
    <xsl:text>&#xa;&#xa;</xsl:text>
  </xsl:template>

  <xsl:template mode="#all" match="div | div1 | div2 | div3 | div4 | div5 | div6 | div7">
    <xsl:apply-templates mode="#current" select="*"/>
  </xsl:template>

  <xsl:template mode="#all" match="l">
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates mode="verse"/>
  </xsl:template>

  <xsl:template mode="verse" match="caesura">
    <xsl:text>&#x9;</xsl:text>
  </xsl:template>

  <xsl:template mode="#all" match="lg">
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates mode="#current" select="*"/>
  </xsl:template>


  <xsl:template mode="#all" match="app[//variantEncoding/@method eq 'parallel-segmenation']">
    <xsl:apply-templates mode="#current" select="lem"/>
  </xsl:template>

  <xsl:template mode="#all" match="app[//variantEncoding/@method ne 'parallel-segmenation']"/>

  <xsl:template mode="#all" match="note[@type eq 'editorial']"/>

  <xsl:template mode="#all" match="span | interp"/>


  <!-- handling of text leafs -->

  <!-- shrinks multiple linebreaks to a single one -->
  <xsl:template mode="prose" match="text()">
    <xsl:analyze-string select="." regex="(&#xa;&#xd;?)(\s*&#xa;&#xd;?)*">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)"/>
        <xsl:text>&#xa;</xsl:text>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>

  <!-- a verse is to be printed in one line -->
  <xsl:template mode="verse" match="text()">
    <xsl:analyze-string select="." regex="(&#xa;&#xd;?|\s+)">
      <xsl:matching-substring>
        <xsl:text>&#x20;</xsl:text>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>

  <xsl:template mode="tei" match="text()[normalize-space(.) ne '']">
    <xsl:message>
      <xsl:text>dropping text in </xsl:text>
      <xsl:value-of select="name(..)"/>
      <xsl:text>: '</xsl:text>
      <xsl:value-of select="tokenize(.)[1 or last()] => string-join(' ... ')"/>
      <xsl:text>'</xsl:text>
    </xsl:message>
  </xsl:template>

</xsl:package>
