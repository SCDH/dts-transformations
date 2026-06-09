<?xml version="1.0" encoding="UTF-8"?>
<!-- Merges SEED configuration files in JSON format

USAGE:
target/bin/xslt.sh \
    -xsl:distribution/seed/merge.xsl \
    -s:pom.xml \
    json-collection="file:$(realpath target/generated-resources/)?select=*.seed.json;recurse=yes"

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" exclude-result-prefixes="#all"
    version="3.0">

    <xsl:output method="json" indent="true"/>

    <xsl:param name="json-files-csv" as="xs:string?" select="()"/>

    <xsl:param name="json-collection" as="xs:anyURI?" select="()"/>

    <xsl:param name="base" as="xs:string?" select=". ! base-uri(.)"/>

    <xsl:param name="json-files" as="xs:string*">
        <xsl:choose>
            <xsl:when test="$json-files-csv and $base and $base ne ''">
                <xsl:sequence select="tokenize($json-files-csv, ',') ! resolve-uri(., $base)"/>
            </xsl:when>
            <xsl:when test="$json-collection">
                <xsl:message>
                    <xsl:text>collection URI: </xsl:text>
                    <xsl:value-of select="$json-collection"/>
                </xsl:message>
                <xsl:sequence select="uri-collection($json-collection)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">No JSON files</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>

    <xsl:template match="document-node()">
        <xsl:message>
            <xsl:text>JSON files: </xsl:text>
            <xsl:value-of select="$json-files"/>
        </xsl:message>
        <xsl:sequence select="($json-files ! unparsed-text(.) ! parse-json(.)) => map:merge()"/>
    </xsl:template>

    <xsl:template name="xsl:initial-template">
        <xsl:message>
            <xsl:text>JSON files: </xsl:text>
            <xsl:value-of select="$json-files"/>
        </xsl:message>
        <xsl:sequence select="($json-files ! unparsed-text(.) ! parse-json(.)) => map:merge()"/>
    </xsl:template>

</xsl:stylesheet>
