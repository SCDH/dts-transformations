<?xml version="1.0" encoding="UTF-8"?>
<!-- Generate the /transformations JSON resource for the SEF package
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:array=" http://www.w3.org/2005/xpath-functions/array" exclude-result-prefixes="#all"
    version="3.0">

    <!-- output of components for the SEF package -->
    <xsl:param name="sef-output-base" as="xs:anyURI" required="true"/>

    <!-- the intial template generates the /transformation resource -->
    <xsl:template name="xsl:initial-template">
        <!-- writing the file api.json
            This asserts that we $sef-output-base exists.
        -->
        <xsl:result-document href="{resolve-uri('api.json', $sef-output-base)}" indent="true"
            encoding="UTF-8" method="json">
            <xsl:sequence select="map {}"/>
        </xsl:result-document>
        <!-- make an array of all the IDs of the compiled transformations that exist in the package. -->
        <xsl:variable name="directories"
            select="for $path in uri-collection(concat($sef-output-base, '?select=info&amp;recurse=yes')) return tokenize($path, '/')[last() - 1]"/>
        <xsl:message>
            <xsl:text>SEF directories: </xsl:text>
            <xsl:value-of select="$directories"/>
        </xsl:message>
        <xsl:result-document href="{resolve-uri('transformations', $sef-output-base)}"
            encoding="UTF-8" indent="true" method="json">
            <xsl:sequence select="array{$directories}"/>
        </xsl:result-document>
    </xsl:template>

    <!-- if we pass an a source document, we just call the initial template -->
    <xsl:template match="document-node()">
        <xsl:call-template name="xsl:initial-template"/>
    </xsl:template>

</xsl:stylesheet>
