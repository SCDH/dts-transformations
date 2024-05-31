<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://saxon.sf.net/ns/configuration"
    xpath-default-namespace="http://saxon.sf.net/ns/configuration" exclude-result-prefixes="#all"
    version="3.0">

    <!-- the Saxon edition for which the config is made -->
    <xsl:param name="edition" as="xs:string" select="string()"/>

    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:template match="@edition[$edition ne string()]">
        <xsl:attribute name="edition" select="$edition"/>
    </xsl:template>

</xsl:stylesheet>
