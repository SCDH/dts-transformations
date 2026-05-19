<?xml version="1.0" encoding="UTF-8"?>
<!-- Generate a configuration file for the SEED XML Transformer

The transformations given as the "transformation" parameter is
resolved relative to the URI given in the transformation-saxon-config-uri. The
saxon-config-uri is resolved relative to the stylesheet URI, aka
as static-base-uri().

The parameter upload-uri can be used to set a base URL for all
relevant locations.

USAGE EXAMPLES:

target/bin/xslt.sh -xsl:distribution/seed/seed-config.xsl -s:xsl/projects/alea/prose-page saxon-config-uri=../../saxon.xml

target/bin/xslt.sh -xsl:distribution/seed/seed-config.xsl -it saxon-config-uri=../../saxon.xml transformations=xsl/projects/alea/prose-page.xsl

target/bin/xslt.sh -xsl:distribution/seed/seed-config.xsl saxon-config-uri=https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/seed-tei-transformations/saxon.xml transformations=xsl/projects/alea/prose-page.xsl -it

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:cfg="http://saxon.sf.net/ns/configuration" xmlns:seed="http://scdh.wwu.de/transform/seed#"
    xpath-default-namespace="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="#all"
    version="3.0">

    <xsl:output method="json" encoding="UTF-8" indent="true"/>

    <xsl:param name="seed-config-xsl" as="xs:string" select="'seed-config.xsl'" static="true"/>

    <xsl:import _href="{$seed-config-xsl}"/>

    <xsl:param name="dts-root" as="xs:string" select="resolve-uri('../../', static-base-uri())"/>

    <!-- document.xsl stylesheet -->
    <xsl:param name="document-xsl" as="xs:string"
        select="resolve-uri('xsl/document.xsl', $dts-root)"/>

    <xsl:variable name="document-transformation" as="document-node()" select="doc($document-xsl)"/>

    <!-- URI of the saxon configuration file of the DTS project -->
    <xsl:param name="dts-saxon-config-uri" as="xs:string"
        select="resolve-uri('saxon-local.xml', $dts-root)"/>

    <!-- Relative links to packages in the saxon config are based on this.
        Defaults to the base URI of the Saxon configuration's document node. -->
    <xsl:variable name="dts-base-uri" as="xs:string" select="base-uri($dts-saxon-config)"/>

    <xsl:variable name="dts-saxon-config" as="document-node()" select="doc($dts-saxon-config-uri)"/>

    <xsl:variable name="chained-transformation" as="document-node()" select="."/>

    <xsl:template name="xsl:initial-template">
        <xsl:map>
            <xsl:for-each select="$transformations">
                <xsl:variable name="location" select="resolve-uri(., $base-uri)"/>
                <xsl:variable name="stylesheet" as="document-node()" select="doc($location)"/>
                <xsl:apply-templates select="$stylesheet" mode="transformation">
                    <xsl:with-param name="transformation-id" tunnel="true"
                        select="seed:get-transformation-id(., $stylesheet)"/>
                    <xsl:with-param name="location" tunnel="true" select="."/>
                </xsl:apply-templates>
            </xsl:for-each>
        </xsl:map>
    </xsl:template>

    <xsl:template match="document-node()">
        <xsl:map>
            <!-- start with document.xsl -->
            <xsl:variable name="document-relative-path"
                select="substring($document-xsl, string-length(resolve-uri('.', base-uri($dts-saxon-config))) + 1)"/>
            <xsl:apply-templates mode="transformation" select="$document-transformation">
                <xsl:with-param name="transformation-id"
                    select="seed:get-transformation-id($document-relative-path, .)" tunnel="true"/>
                <xsl:with-param name="location" select="$document-relative-path" tunnel="true"/>
            </xsl:apply-templates>
            <!-- on with chained transformation given as source -->
            <xsl:variable name="transformation-relative-path"
                select="substring(base-uri(), string-length(resolve-uri('.', $base-uri)) + 1)"/>
            <xsl:apply-templates mode="libraries" select="."/>
        </xsl:map>
    </xsl:template>

    <xsl:template name="seed:libraries" as="item()">
        <xsl:param name="stylesheet" as="document-node()" select="."/>
        <xsl:map-entry key="'libraries'">
            <xsl:variable name="libs" as="map(*)*">
                <xsl:apply-templates mode="libraries" select="$stylesheet"/>
                <xsl:apply-templates mode="libraries" select="$chained-transformation"/>
            </xsl:variable>
            <xsl:sequence select="array {$libs => reverse() => seed:distinct-maps-in-order(())}"/>
        </xsl:map-entry>
    </xsl:template>

    <xsl:template name="seed:parameter-descriptors" as="item()">
        <xsl:param name="stylesheet" as="document-node()" select="."/>
        <xsl:map-entry key="'parameterDescriptors'">
            <xsl:variable name="params" as="map(*)*">
                <xsl:apply-templates mode="stylesheet-params" select="$stylesheet"/>
                <xsl:apply-templates mode="stylesheet-params" select="$chained-transformation"/>
            </xsl:variable>
            <xsl:sequence select="map:merge($params, $merge-options)"/>
        </xsl:map-entry>
    </xsl:template>



</xsl:stylesheet>
