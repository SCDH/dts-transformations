<?xml version="1.0" encoding="UTF-8"?>
<!-- Makes a SEED configuration from the document config and a config of a transformation to be chained to it

USAGE:
target/bin/xslt.sh \
    -xsl:distribution/seed/chain.xsl \
    -it \
    document-config-uri=PATH_TO_DOCUMENT.json \
    chained-config-uri=PATH_TO_CHAINED.json \
    media-type-package=CHAINED_PACKAGE_NAME

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    xmlns:seed="http://scdh.wwu.de/transform/seed#" exclude-result-prefixes="#all" version="3.0">

    <xsl:output method="json" indent="true"/>

    <!-- PATH to JSON config file for XSLT for document endpoint -->
    <xsl:param name="document-config-uri" as="xs:string" required="true"/>

    <xsl:param name="document-config" as="map(*)"
        select="$document-config-uri => unparsed-text() => parse-json()"/>

    <!-- PATH to JSON config file fof XSLT to be chained to document endpoint XSLT -->
    <xsl:param name="chained-config-uri" as="xs:string" required="true"/>

    <xsl:param name="chained-config" as="map(*)"
        select="$chained-config-uri => unparsed-text() => parse-json()"/>

    <!-- name (ID) of the resulting transformation -->
    <xsl:param name="name" as="xs:string">
        <xsl:value-of
            select="seed:transformation-id($document-config) || '+' || seed:transformation-id($chained-config)"
        />
    </xsl:param>

    <!-- set this to the empty string or () if you do not want pass on to a mediaType processor -->
    <xsl:param name="media-type-package" as="xs:string" required="true"/>

    <!-- version of the mediaType processor package -->
    <xsl:param name="media-type-package-version" as="xs:string" select="'1.0.0'"/>

    <!-- should be 'template', 'mode', or 'function' -->
    <xsl:param name="media-type-component" as="xs:string" select="'template'"/>

    <!-- name of the template, mode or function used as an entry point for mediaType processing -->
    <xsl:param name="media-type-processor" as="xs:string" select="'post-proc'"/>

    <xsl:variable name="media-type-parameters" as="map(xs:string, item()*)*">
        <xsl:map>
            <xsl:map-entry key="'name'">media-type-package</xsl:map-entry>
            <xsl:map-entry key="'value'" select="$media-type-package"/>
            <xsl:map-entry key="'type'">xs:string?</xsl:map-entry>
        </xsl:map>
        <xsl:map>
            <xsl:map-entry key="'name'">media-type-package-version</xsl:map-entry>
            <xsl:map-entry key="'value'" select="$media-type-package-version"/>
            <xsl:map-entry key="'type'">xs:string</xsl:map-entry>
        </xsl:map>
        <xsl:map>
            <xsl:map-entry key="'name'">media-type-component</xsl:map-entry>
            <xsl:map-entry key="'value'" select="$media-type-component"/>
            <xsl:map-entry key="'type'">xs:string</xsl:map-entry>
        </xsl:map>
        <xsl:map>
            <xsl:map-entry key="'name'">media-type-processor</xsl:map-entry>
            <xsl:map-entry key="'value'" select="$media-type-processor"/>
            <xsl:map-entry key="'type'">xs:string</xsl:map-entry>
        </xsl:map>
    </xsl:variable>

    <xsl:template match="document-node()">
        <xsl:sequence select="seed:chain()"/>
    </xsl:template>

    <xsl:template name="xsl:initial-template">
        <xsl:sequence select="seed:chain()"/>
    </xsl:template>

    <xsl:variable name="document-bare-config" as="map(xs:string, item()*)"
        select="seed:bare-config($document-config)"/>

    <xsl:variable name="chained-bare-config" as="map(xs:string, item()*)"
        select="seed:bare-config($chained-config)"/>


    <xsl:function name="seed:chain" as="map(xs:string, item()*)" visibility="final">
        <xsl:map>
            <xsl:map-entry key="$name">
                <xsl:sequence select="
                        map:merge((map:remove($chained-bare-config, ('location', 'requiresSource')), $document-bare-config), map {'duplicates': 'use-first'}) =>
                        map:put('libraries', array:join((map:get($document-bare-config, 'libraries'), seed:as-library($chained-config) => map:get('libraries')))) =>
                        map:put('parameterDescriptors', map:merge((map:get($document-bare-config, 'parameterDescriptors'), seed:as-library($chained-config) => map:get('parameterDescriptors')))) =>
                        map:put('compileTimeParameters', array {$media-type-parameters}) =>
                        map:put('description', concat(seed:transformation-id($chained-config), ' chained to ', seed:transformation-id($document-config), ': ', map:get($chained-bare-config, 'description')))"
                />
            </xsl:map-entry>
        </xsl:map>
    </xsl:function>

    <xsl:function name="seed:transformation-id" as="xs:string">
        <xsl:param name="named-config" as="map(xs:string, map(xs:string, item()*))"/>
        <xsl:value-of select="map:keys($named-config)[1]"/>
    </xsl:function>

    <xsl:function name="seed:bare-config" as="map(xs:string, item()*)">
        <xsl:param name="named-config" as="map(xs:string, map(xs:string, item()*))"/>
        <xsl:sequence select="map:get($named-config, seed:transformation-id($named-config))"/>
    </xsl:function>

    <xsl:function name="seed:as-library" as="map(xs:string, item()*)" visibility="final">
        <xsl:param name="config" as="map(xs:string, item()*)"/>
        <xsl:variable name="transformation" as="map(*)" select="seed:bare-config($config)"/>
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
