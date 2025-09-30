<?xml version="1.0" encoding="UTF-8"?>
<!-- Generate data for DTS navigation endpoint from TEI source document

-->
<xsl:package name="https://scdh.github.io/dts-transformations/xsl/navigation-declared.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:dts="https://distributed-text-services.github.io/specifications/"
    exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0">

    <xsl:output method="json" indent="true"/>

    <xsl:global-context-item as="document-node(element(TEI))"/>

    <xsl:param name="resource" as="xs:string?" select="()"/>

    <xsl:param name="ref" as="xs:string?" select="()"/>

    <xsl:param name="start" as="xs:string?" select="()"/>

    <xsl:param name="end" as="xs:string?" select="()"/>

    <xsl:param name="down" as="xs:integer" select="-1"/>

    <xsl:param name="tree" as="xs:string?" select="()"/>

    <xsl:param name="page" as="xs:integer?" select="()"/>

    <xsl:param name="url-template" as="xs:QName"
        select="xs:QName('dts:navigation-url-with-query-parameters')"/>

    <xsl:variable name="parameters" as="map(xs:string, item())">
        <xsl:map>
            <xsl:choose>
                <xsl:when test="not(empty($resource))">
                    <xsl:message>setting resource</xsl:message>
                    <xsl:map-entry key="'resource'" select="$resource"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message>resource from context item</xsl:message>
                    <xsl:map-entry key="'resource'" select="base-uri(.)"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="$ref and ($start or $end)">
                    <xsl:message terminate="yes">
                        <xsl:text>ERROR: bad parameter combination: when ref is used, start and end must not</xsl:text>
                    </xsl:message>
                </xsl:when>
                <xsl:when test="$ref">
                    <xsl:map-entry key="'ref'" select="$ref"/>
                </xsl:when>
                <xsl:when test="$start and $end">
                    <xsl:map-entry key="'start'" select="$start"/>
                    <xsl:map-entry key="'end'" select="$end"/>
                </xsl:when>
                <xsl:when test="not($start or $end)"/>
                <xsl:otherwise>
                    <xsl:message terminate="yes">
                        <xsl:text>ERROR: bad parameter combination: start required end and vice versa</xsl:text>
                    </xsl:message>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="$down">
                <xsl:map-entry key="'down'" select="$down"/>
            </xsl:if>
            <xsl:if test="$tree">
                <xsl:map-entry key="'tree'" select="$tree"/>
            </xsl:if>
            <xsl:if test="$page">
                <xsl:map-entry key="'page'" select="$page"/>
            </xsl:if>
        </xsl:map>
    </xsl:variable>

    <xsl:variable name="dts:make-navigation-url" as="function(map(xs:string, item())) as xs:anyURI"
        select="function-lookup($url-template, 1)"/>

    <xsl:use-package name="https://scdh.github.io/dts-transformations/xsl/dts.xsl"
        package-version="1.0.0"/>


    <xsl:mode on-no-match="shallow-skip"/>

    <xsl:template match="/">
        <xsl:call-template name="navigation"/>
    </xsl:template>

    <xsl:template name="xsl:initial-template" visibility="public"> </xsl:template>

    <xsl:template name="navigation" as="map(xs:string, item())">
        <xsl:map>
            <xsl:map-entry key="'@context'"
                select="concat('https://distributed-text-services.github.io/specifications/context/', $dts-version,'.json')"/>
            <xsl:map-entry key="'dtsVersion'" select="$dts-version"/>
            <xsl:map-entry key="'@type'">Navigation</xsl:map-entry>
            <xsl:map-entry key="'@id'" select="$dts:make-navigation-url($parameters)"/>
            <xsl:map-entry key="'resource'">
                <xsl:call-template name="resource"/>
            </xsl:map-entry>
            <xsl:map-entry key="'member'">
                <xsl:call-template name="members"/>
            </xsl:map-entry>
        </xsl:map>
    </xsl:template>

    <xsl:template name="resource" as="map(xs:string, item())">
        <xsl:map>
            <xsl:map-entry key="'@id'" select="map:get($parameters, 'resource')"/>
            <xsl:map-entry key="'@type'">Resource</xsl:map-entry>
            <!-- TODO: insert URL templates for all endpoints -->
            <xsl:map-entry key="'citationTrees'">
                <xsl:call-template name="citationTrees"/>
            </xsl:map-entry>
        </xsl:map>
    </xsl:template>


    <!-- citationTrees section -->

    <xsl:template name="citationTrees" as="array(map(xs:string, item()))">
        <xsl:context-item as="document-node()" use="required"/>
        <xsl:variable name="citeStructures" as="map(xs:string, item())*">
            <xsl:for-each select="//refsDecl">
                <xsl:map>
                    <xsl:map-entry key="'@type'">CitationTree</xsl:map-entry>
                    <!--
                        Specs: "If a Resource has multiple CitationTrees,
                        then the first listed in citationTrees is the default
                        CitationTree and cannot have an identifier."
                        How about a Resource with a single CitationTree? Can
                        it have a an identifier? Would the absence of
                        an unnamed (unidenfiable) CitationTree mean, that
                        there's no default CitationTree?
                    -->
                    <xsl:if test="position() > 1">
                        <xsl:map-entry key="'identifier'" select="@xml:id => string()"/>
                    </xsl:if>
                    <xsl:if test="p | ab">
                        <!--
                            Where to get the description from? <refsDecl> may not
                            contain a <desc>!
                        -->
                        <xsl:map-entry key="'description'"
                            select="(p | ab) => string-join() => normalize-space()"/>
                    </xsl:if>
                    <xsl:variable name="trees" as="map(xs:string, item())*">
                        <xsl:apply-templates mode="citationTrees"/>
                    </xsl:variable>
                    <xsl:map-entry key="'citeStructure'">
                        <xsl:sequence select="array { $trees }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="array { $citeStructures }"/>
    </xsl:template>

    <xsl:mode name="citationTrees" on-no-match="shallow-skip"/>

    <xsl:template mode="citationTrees" match="citeStructure">
        <xsl:map>
            <xsl:map-entry key="'@type'">CiteStructure</xsl:map-entry>
            <xsl:map-entry key="'citeType'" select="@unit => string()"/>
            <!-- TODO: how to make this tail-recursive? -->
            <xsl:variable name="citeStructures" as="map(xs:string, item())*">
                <xsl:apply-templates mode="citationTrees"/>
            </xsl:variable>
            <xsl:if test="not(empty($citeStructures))">
                <xsl:map-entry key="'citeStructure'" select="array { $citeStructures }"/>
            </xsl:if>
        </xsl:map>
    </xsl:template>


    <!-- member section -->

    <xsl:template name="members">
        <xsl:context-item as="document-node()" use="required"/>
        <xsl:variable name="members" as="map(xs:string, item()?)*">
            <xsl:choose>
                <xsl:when test="not($tree)">
                    <!-- all members of default citation tree -->
                    <xsl:apply-templates mode="members"
                        select="(//refsDecl[not(@xml:id)] | //refsDecl)[1]">
                        <xsl:with-param name="parentId" as="xs:string?" tunnel="true" select="()"/>
                        <xsl:with-param name="parentContext" as="node()" tunnel="true"
                            select="root(.)"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="$tree">
                    <!-- all members of a named citation tree -->
                    <xsl:apply-templates mode="members" select="id($tree)/self::refsDecl">
                        <xsl:with-param name="parentId" as="xs:string?" tunnel="true" select="()"/>
                        <xsl:with-param name="parentContext" as="node()" tunnel="true"
                            select="root(.)"/>
                    </xsl:apply-templates>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="array { $members }"/>
    </xsl:template>

    <xsl:mode name="members" on-no-match="shallow-skip"/>

    <xsl:template mode="members" match="citeStructure">
        <xsl:param name="parentId" as="xs:string?" tunnel="true"/>
        <xsl:param name="parentContext" as="node()" tunnel="true"/>
        <xsl:variable name="citeStructureContext" as="element(citeStructure)" select="."/>
        <xsl:variable name="members" as="node()*">
            <xsl:evaluate context-item="$parentContext" xpath="@match"
                namespace-context="$citeStructureContext"/>
        </xsl:variable>
        <xsl:for-each select="$members">
            <xsl:variable name="memberContext" as="node()" select="."/>
            <xsl:variable name="use" as="item()*">
                <xsl:evaluate context-item="$memberContext" xpath="$citeStructureContext/@use"
                    namespace-context="$citeStructureContext"/>
            </xsl:variable>
            <xsl:variable name="identifier"
                select="concat($parentId, $citeStructureContext/@delim, $use)"/>
            <xsl:map>
                <xsl:map-entry key="'identifier'" select="$identifier"/>
                <xsl:map-entry key="'@type'">CiteableUnit</xsl:map-entry>
                <xsl:map-entry key="'level'"
                    select="count($citeStructureContext/ancestor-or-self::citeStructure)"/>
                <xsl:map-entry key="'parent'" select="$parentId"/>
                <xsl:map-entry key="'citeType'" select="$citeStructureContext/@unit => string()"/>
                <!-- TODO dcterms -->
            </xsl:map>
            <xsl:apply-templates mode="members" select="$citeStructureContext/node()">
                <xsl:with-param name="parentId" as="xs:string?" tunnel="true" select="$identifier"/>
                <xsl:with-param name="parentContext" as="node()" tunnel="true"
                    select="$memberContext"/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>

</xsl:package>
