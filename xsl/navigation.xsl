<?xml version="1.0" encoding="UTF-8"?>
<!-- Generate a dts:Navigation JSON-LD object as is required by a DTS navigation endpoint

USAGE with TEI document as source document:
target/bin/xslt.sh \
    -config:saxon.he.xml
    -xsl:xsl/navigation.xsl
    -s:test/matt.xml

USAGE with initial template:
target/bin/xslt.sh \
    -config:saxon.he.xml \
    -xsl:xsl/navigation.xsl \
    -it \
    resource=test/matt.xml

Use 'java -cp $CLASSPATH saxon-10.9.jar' instead of 'target/bin/xslt.sh'.

This package has overridable components for adding metadata to member objects.
See the section at the end of the package.
-->
<xsl:package name="https://scdh.github.io/dts-transformations/xsl/navigation.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:dts="https://distributed-text-services.github.io/specifications/"
    exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0" default-mode="navigation">

    <xsl:output method="json" indent="true"/>

    <xsl:param name="down" as="xs:integer?" select="-1"/>

    <xsl:param name="page" as="xs:integer?" select="()"/>

    <!-- more parameters defined in tree.xsl -->

    <xsl:function name="dts:validate-navigation-parameters" as="map(xs:string, item())"
        visibility="final">
        <xsl:param name="context" as="node()"/>
        <xsl:assert test="empty(($down, $ref, $start, $end)) => not()"
            error-code="{$dts:http400 => dts:error-to-eqname()}">
            <xsl:value-of xml:space="preserve">ERROR: bad parameter combination: $down, $ref, $start+$end may not all be absent</xsl:value-of>
        </xsl:assert>
        <xsl:assert test="not(exists($down) and $down eq 0 and empty($ref))"
            error-code="{$dts:http400 => dts:error-to-eqname()}">
            <xsl:value-of xml:space="preserve">ERROR: bad parameter combination: $down = 0 requires $ref set</xsl:value-of>
        </xsl:assert>
        <xsl:variable name="navigation-specific" as="map(xs:string, item()*)">
            <xsl:map>
                <xsl:if test="$down">
                    <xsl:map-entry key="'down'" select="$down"/>
                </xsl:if>
                <xsl:if test="$page">
                    <xsl:map-entry key="'page'" select="$page"/>
                </xsl:if>
            </xsl:map>
        </xsl:variable>
        <xsl:sequence select="map:merge(($navigation-specific, dts:validate-parameters($context)))"
        />
    </xsl:function>

    <xsl:use-package name="https://scdh.github.io/dts-transformations/xsl/dts.xsl"
        package-version="1.0.0"/>

    <xsl:use-package name="https://scdh.github.io/dts-transformations/xsl/url-templates.xsl"
        package-version="1.0.0"/>

    <xsl:use-package name="https://scdh.github.io/dts-transformations/xsl/tree.xsl"
        package-version="1.0.0"/>

    <xsl:use-package name="https://scdh.github.io/dts-transformations/xsl/errors.xsl"
        package-version="1.0.0"/>

    <!-- entry point with initial template and resource URL from stylesheet parameter -->
    <xsl:template name="xsl:initial-template" as="map(xs:string, item())" visibility="public">
        <xsl:assert test="$resource" error-code="{$dts:http400 => dts:error-to-eqname()}">
            <xsl:value-of xml:space="preserve">ERROR: resource parameter missing</xsl:value-of>
        </xsl:assert>
        <xsl:apply-templates mode="navigation" select="doc($resource)"/>
    </xsl:template>

    <!-- the navigation mode is the entry point with a global context node -->
    <xsl:mode name="navigation" on-no-match="fail" visibility="final"/>

    <!-- make the Navigation JSON-LD object for the given context document -->
    <xsl:template mode="navigation" match="document-node()" as="map(xs:string, item())">
        <!-- Calling dts:validate-navigation-parameters() results only then in a validation
            when the returned result is also used for making the transformation's output,
            since XSLT is lazy! So we use the output, even if we could do the rest without.
        -->
        <xsl:variable name="parameters" as="map(xs:string, item()*)"
            select="dts:validate-navigation-parameters(.)"/>
        <xsl:map>
            <xsl:map-entry key="'@context'"
                select="concat('https://distributed-text-services.github.io/specifications/context/', $dts-version,'.json')"/>
            <xsl:map-entry key="'dtsVersion'" select="$dts-version"/>
            <xsl:map-entry key="'@type'">Navigation</xsl:map-entry>
            <xsl:map-entry key="'@id'" select="dts:navigation-url($parameters)"/>
            <xsl:map-entry key="'resource'">
                <xsl:call-template name="resource">
                    <xsl:with-param name="parameters" select="$parameters"/>
                </xsl:call-template>
            </xsl:map-entry>
            <xsl:variable name="members" as="element(dts:member)*"
                select="dts:members(., $down, false())"/>
            <!--
                The non-empty parameter of the to-json function is important for catching errors
                Thus, we definitly want to declare it here, not only in a possibly overridden function.
            -->
            <xsl:variable name="to-jsonld"
                as="function (element(dts:member)) as map(xs:string, item()*)"
                select="function ($x) { map:merge((dts:member-json($x), dts:member-meta-json($x)))}"/>
            <xsl:if test="exists($down)">
                <!-- specs on absent $down:
                    "No member property in the Navigation object."
                -->
                <xsl:map-entry key="'member'" select="array { $members ! $to-jsonld(.) }"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$ref and exists($down) and $down eq 0">
                    <!-- specs on $down=0 and given $ref:
                        "Information about the CitableUnit identified by ref
                        along with a member property that is an array of
                        CitableUnits that are siblings (sharing the same
                        parent) including the current CitableUnit identified
                        by ref."
                        This $members sequence does not contain *ref at start,
                        so we have to filter the correct element.
                    -->
                    <xsl:map-entry key="'ref'"
                        select="$members[dts:identifier/text() eq $ref] => $to-jsonld()"/>
                </xsl:when>
                <xsl:when test="$ref">
                    <xsl:map-entry key="'ref'" select="$members[1] => $to-jsonld()"/>
                </xsl:when>
                <xsl:when test="$start and $end">
                    <xsl:map-entry key="'start'" select="$members[1] => $to-jsonld()"/>
                    <xsl:map-entry key="'end'" select="$members[last()] => $to-jsonld()"/>
                </xsl:when>
            </xsl:choose>
        </xsl:map>
    </xsl:template>

    <xsl:template name="resource" as="map(xs:string, item())" visibility="final">
        <xsl:param name="parameters" as="map(xs:string, item()*)" required="true"/>
        <xsl:map>
            <xsl:map-entry key="'@id'" select="map:get($parameters, 'resource')"/>
            <xsl:map-entry key="'@type'">Resource</xsl:map-entry>
            <xsl:map-entry key="'collection'" select="dts:collection-url($parameters)"/>
            <xsl:map-entry key="'navigation'" select="dts:navigation-url($parameters)"/>
            <xsl:map-entry key="'document'" select="dts:document-url($parameters)"/>
            <xsl:map-entry key="'citationTrees'">
                <xsl:call-template name="citationTrees"/>
            </xsl:map-entry>
        </xsl:map>
    </xsl:template>


    <!-- citationTrees section -->

    <xsl:template name="citationTrees" as="array(map(xs:string, item()))" visibility="final">
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

    <xsl:mode name="citationTrees" on-no-match="shallow-skip" visibility="public"/>

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

</xsl:package>
