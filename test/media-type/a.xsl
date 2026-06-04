<?xml version="1.0" encoding="UTF-8"?>
<xsl:package name="http://example.com/xsl/a" package-version="1.0.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all" version="3.0" default-mode="identity">

    <xsl:param name="fingers" as="xs:integer" select="10"/>

    <xsl:use-package name="http://example.com/xsl/b" package-version="1.0.0"/>

    <xsl:mode name="identity" on-no-match="shallow-copy"/>

</xsl:package>
