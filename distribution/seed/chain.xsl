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
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    xmlns:seed="http://scdh.wwu.de/transform/seed#" exclude-result-prefixes="#all" version="3.0">

    <xsl:output method="json" indent="true"/>

    <xsl:param name="document-config" as="xs:string" required="true"/>

    <xsl:param name="chained-config" as="xs:string" required="true"/>

    <!-- set this to the empty string or () if you do not want pass on to a mediaType processor -->
    <xsl:param name="media-type-package" as="xs:string" required="true"/>

    <!-- version of the mediaType processor package -->
    <xsl:param name="media-type-package-version" as="xs:string" select="'1.0.0'"/>

    <!-- should be 'template', 'mode', or 'function' -->
    <xsl:param name="media-type-component" as="xs:string" select="'template'"/>

    <!-- name of the template, mode or function used as an entry point for mediaType processing -->
    <xsl:param name="media-type-processor" as="xs:string" select="'post-proc'"/>


    <xsl:template match="document-node()">
        <xsl:sequence select="seed:merge()"/>
    </xsl:template>

    <xsl:template name="xsl:initial-template">
        <xsl:sequence select="seed:merge()"/>
    </xsl:template>

    <xsl:function name="seed:merge" as="map(xs:string, item()*)">
        <xsl:sequence select="
                (
                $document-config => unparsed-text() => parse-json(),
                $chained-config => unparsed-text() => parse-json() => seed:as-library()
                ) => map:merge()"/>
    </xsl:function>

    <xsl:function name="seed:as-library" as="map(xs:string, item()*)" visibility="final">
        <xsl:param name="config" as="map(xs:string, item()*)"/>
        <xsl:variable name="transformation-id" as="xs:string" select="map:keys($config)[1]"/>
        <xsl:variable name="transformation" as="map(*)"
            select="map:get($config, $transformation-id)"/>
        <xsl:variable name="stylesheet" as="map(*)" select="
                (
                map:entry('location', map:get($transformation, 'location')),
                map:entry('asName', $media-type-package),
                map:entry('asVersion', $media-type-package-version)
                ) => map:merge()"/>
        <xsl:variable name="libraries" as="array(*)"
            select="array:join((array {$stylesheet}, map:get($transformation, 'libraries')))"/>
        <xsl:map>
            <xsl:map-entry key="'libraries'" select="$libraries"/>
            <xsl:map-entry key="'parameterDescriptors'"
                select="map:get($transformation, 'parameterDescriptors')"/>
        </xsl:map>
    </xsl:function>

</xsl:stylesheet>
