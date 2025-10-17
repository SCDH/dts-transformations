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

    <xsl:param name="uri-templates-package" as="xs:string" static="true"
        select="'https://scdh.github.io/dts-transformations/xsl/uri-templates/query-parameters.xsl'"/>

    <xsl:param name="uri-templates-package-version" as="xs:string" static="true" select="'1.0.0'"/>

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

    <xsl:use-package name="https://scdh.github.io/dts-transformations/xsl/resource.xsl"
        package-version="1.0.0">
        <xsl:accept component="function" names="dts:resource-uri#0" visibility="public"/>
        <xsl:accept component="*" names="*" visibility="hidden"/>
    </xsl:use-package>

    <xsl:use-package _name="{$uri-templates-package}"
        _package-version="{$uri-templates-package-version}">
        <!-- an URI templates package must provide two functions -->
        <xsl:accept component="function" names="dts:uri-template-map-entries#2" visibility="public"/>
        <xsl:accept component="function" names="dts:navigation-uri#2" visibility="public"/>
    </xsl:use-package>

    <xsl:use-package name="https://scdh.github.io/dts-transformations/xsl/tree-hook.xsl"
        package-version="1.0.0"/>

    <xsl:use-package name="https://scdh.github.io/dts-transformations/xsl/errors.xsl"
        package-version="1.0.0"/>

    <!-- entry point with initial template and resource URL from stylesheet parameter -->
    <xsl:template name="xsl:initial-template" as="map(xs:string, item())" visibility="public">
        <xsl:assert test="$resource" error-code="{$dts:http400 => dts:error-to-eqname()}">
            <xsl:value-of xml:space="preserve">ERROR: resource parameter missing</xsl:value-of>
        </xsl:assert>
        <xsl:apply-templates mode="navigation" select="dts:resource-uri() => doc()"/>
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
            <xsl:map-entry key="'@id'" select="dts:navigation-uri(., $parameters)"/>
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
                select="function ($x) { map:merge((dts:member-json($x), dts:cite-data-json($x), dts:member-meta-json($x)))}"/>
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
                    <xsl:try>
                        <xsl:map-entry key="'ref'"
                            select="$members[dts:identifier/text() eq $ref] => $to-jsonld()"/>
                        <xsl:catch>
                            <xsl:message terminate="yes"
                                error-code="{$dts:http404 => dts:error-to-eqname()}">
                                <xsl:value-of xml:space="preserve">ERROR: $ref '<xsl:value-of select="$ref"/>' not found</xsl:value-of>
                            </xsl:message>
                        </xsl:catch>
                    </xsl:try>
                </xsl:when>
                <xsl:when test="$ref">
                    <xsl:try>
                        <xsl:map-entry key="'ref'"
                            select="$members[1][string(dts:identifier) eq $ref] => $to-jsonld()"/>
                        <!-- XPTY0004 -->
                        <xsl:catch>
                            <xsl:message terminate="yes"
                                error-code="{$dts:http404 => dts:error-to-eqname()}">
                                <xsl:value-of xml:space="preserve">ERROR: $ref '<xsl:value-of select="$ref"/>' not found</xsl:value-of>
                            </xsl:message>
                        </xsl:catch>
                    </xsl:try>
                </xsl:when>
                <xsl:when test="$start and $end">
                    <xsl:try>
                        <xsl:map-entry key="'start'"
                            select="$members[dts:start][string(dts:identifier) eq $start] => $to-jsonld()"/>
                        <xsl:catch>
                            <xsl:message terminate="yes"
                                error-code="{$dts:http404 => dts:error-to-eqname()}">
                                <xsl:value-of xml:space="preserve">ERROR: $start '<xsl:value-of select="$start"/>' not found</xsl:value-of>
                            </xsl:message>
                        </xsl:catch>
                    </xsl:try>
                    <xsl:try>
                        <xsl:map-entry key="'end'"
                            select="$members[dts:end][string(dts:identifier) eq $end] => $to-jsonld()"/>
                        <xsl:catch>
                            <xsl:message terminate="yes"
                                error-code="{$dts:http404 => dts:error-to-eqname()}">
                                <xsl:value-of xml:space="preserve">ERROR: $end '<xsl:value-of select="$end"/>' not found</xsl:value-of>
                            </xsl:message>
                        </xsl:catch>
                    </xsl:try>
                </xsl:when>
            </xsl:choose>
        </xsl:map>
    </xsl:template>

    <xsl:template name="resource" as="map(xs:string, item())" visibility="final">
        <xsl:context-item as="document-node()" use="required"/>
        <xsl:param name="parameters" as="map(xs:string, item()*)" required="true"/>
        <xsl:map>
            <xsl:map-entry key="'@id'" select="map:get($parameters, 'resource')"/>
            <xsl:map-entry key="'@type'">Resource</xsl:map-entry>
            <xsl:sequence select="dts:uri-template-map-entries(., $parameters)"/>
            <xsl:map-entry key="'citationTrees'">
                <xsl:call-template name="citationTrees"/>
            </xsl:map-entry>
        </xsl:map>
    </xsl:template>


    <!-- citationTrees section -->

    <xsl:template name="citationTrees" as="array(map(xs:string, item()))" visibility="final">
        <xsl:context-item as="document-node()" use="required"/>
        <!--
            Specs: "If a Resource has multiple CitationTrees,
            then the first listed in citationTrees is the default
            CitationTree and cannot have an identifier."
            How about a Resource with a single CitationTree? Can
            it have a an identifier? Would the absence of
            an unnamed (unidenfiable) CitationTree mean, that
            there's no default CitationTree?

            Interpretation: This is a statement about the order
            of the citation trees in the json ld output of the
            navigation endpoint, not about the order or naming
            of refsDecl elements in the resource.
        -->
        <xsl:assert
            test="count(/*/teiHeader/encodingDesc/refsDecl) eq 1 or count(/*/teiHeader/encodingDesc/refsDecl[@default eq 'true']) eq 1"
            error-code="{$dts:http404 => dts:error-to-eqname()}">
            <xsl:value-of xml:space="preserve">ERROR: there must be exactly 1 citation tree or 1 default citation tree by declaration, but found <xsl:value-of select="count(/*/teiHeader/encodingDesc/refsDecl[@default eq 'true'])"/></xsl:value-of>
        </xsl:assert>
        <xsl:assert
            test="count(/*/teiHeader/encodingDesc/refsDecl) eq 1 or (/*/teiHeader/encodingDesc/refsDecl[empty(@default) or @default eq 'false'][empty(@n)] => exists() => not())"
            error-code="{$dts:http404 => dts:error-to-eqname()}">
            <xsl:value-of xml:space="preserve">ERROR: there are unlabelled refsDecl which are not the default citation tree</xsl:value-of>
        </xsl:assert>
        <xsl:variable name="citeStructures" as="map(xs:string, item())*">
            <xsl:choose>
                <xsl:when test="count(/*/teiHeader/encodingDesc/refsDecl) eq 1">
                    <!-- single citation tree: the one is the default,
                        no matter if it is declare by @default or if it has an @n label -->
                    <xsl:call-template name="citation-tree">
                        <xsl:with-param name="refsDecl" select="/*/teiHeader/encodingDesc/refsDecl"/>
                        <xsl:with-param name="is-default" select="true()"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <!-- multiple citation trees: default must come first -->
                    <xsl:call-template name="citation-tree">
                        <xsl:with-param name="refsDecl"
                            select="/*/teiHeader/encodingDesc/refsDecl[@default eq 'true']"/>
                        <xsl:with-param name="is-default" select="true()"/>
                    </xsl:call-template>
                    <xsl:for-each
                        select="/*/teiHeader/encodingDesc/refsDecl[not(@default eq 'true')]">
                        <xsl:call-template name="citation-tree">
                            <xsl:with-param name="is-default" select="false()"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="array { $citeStructures }"/>
    </xsl:template>

    <xsl:template name="citation-tree" as="map(xs:string, item())" visibility="final">
        <xsl:param name="refsDecl" as="element(refsDecl)" required="false" select="."/>
        <xsl:param name="is-default" as="xs:boolean" required="true"/>
        <xsl:map>
            <xsl:map-entry key="'@type'">CitationTree</xsl:map-entry>
            <xsl:if test="not($is-default)">
                <xsl:map-entry key="'identifier'" select="$refsDecl/@n => string()"/>
            </xsl:if>
            <xsl:if test="$refsDecl/(p | ab)">
                <!--
                            Where to get the description from? <refsDecl> may not
                            contain a <desc>!
                        -->
                <xsl:map-entry key="'description'"
                    select="$refsDecl/(p | ab) => string-join() => normalize-space()"/>
            </xsl:if>
            <xsl:variable name="tree" as="map(xs:string, item())*">
                <xsl:apply-templates mode="citationTrees" select="$refsDecl"/>
            </xsl:variable>
            <xsl:map-entry key="'citeStructure'">
                <xsl:sequence select="array { $tree }"/>
            </xsl:map-entry>
        </xsl:map>
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
