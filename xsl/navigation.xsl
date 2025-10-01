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
<xsl:package name="https://scdh.github.io/dts-transformations/xsl/navigation-declared.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:dts="https://distributed-text-services.github.io/specifications/"
    exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0" default-mode="navigation">

    <xsl:output method="json" indent="true"/>

    <xsl:param name="resource" as="xs:string?" select="()"/>

    <xsl:param name="ref" as="xs:string?" select="()"/>

    <xsl:param name="start" as="xs:string?" select="()"/>

    <xsl:param name="end" as="xs:string?" select="()"/>

    <xsl:param name="down" as="xs:integer?" select="-1"/>

    <xsl:param name="tree" as="xs:string?" select="()"/>

    <xsl:param name="page" as="xs:integer?" select="()"/>

    <xsl:param name="url-template" as="xs:QName"
        select="xs:QName('dts:navigation-url-with-query-parameters')"/>

    <xsl:function name="dts:validate-parameters" as="map(xs:string, item())">
        <xsl:param name="context" as="node()"/>
        <xsl:map>
            <xsl:choose>
                <xsl:when test="not(empty($resource))">
                    <xsl:message>setting resource</xsl:message>
                    <xsl:map-entry key="'resource'" select="$resource"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message>resource from context item</xsl:message>
                    <xsl:map-entry key="'resource'" select="base-uri($context)"/>
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
    </xsl:function>

    <xsl:variable name="dts:make-navigation-url" as="function(map(xs:string, item())) as xs:anyURI"
        select="function-lookup($url-template, 1)"/>

    <xsl:use-package name="https://scdh.github.io/dts-transformations/xsl/dts.xsl"
        package-version="1.0.0"/>

    <!-- entry point with initial template and resource URL from stylesheet parameter -->
    <xsl:template name="xsl:initial-template" as="map(xs:string, item())" visibility="public">
        <xsl:apply-templates mode="navigation" select="doc($resource)"/>
    </xsl:template>

    <!-- the navigation mode is the entry point with a global context node -->
    <xsl:mode name="navigation" on-no-match="fail" visibility="final"/>

    <!-- make the Navigation JSON-LD object for the given context document -->
    <xsl:template mode="navigation" match="document-node()" as="map(xs:string, item())">
        <xsl:variable name="parameters" as="map(xs:string, item()*)"
            select="dts:validate-parameters(.)"/>
        <xsl:map>
            <xsl:map-entry key="'@context'"
                select="concat('https://distributed-text-services.github.io/specifications/context/', $dts-version,'.json')"/>
            <xsl:map-entry key="'dtsVersion'" select="$dts-version"/>
            <xsl:map-entry key="'@type'">Navigation</xsl:map-entry>
            <xsl:map-entry key="'@id'" select="$dts:make-navigation-url($parameters)"/>
            <xsl:map-entry key="'resource'">
                <xsl:call-template name="resource">
                    <xsl:with-param name="parameters" select="$parameters"/>
                </xsl:call-template>
            </xsl:map-entry>
            <xsl:variable name="members" as="element(dts:member)*" select="dts:members(.)"/>
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
            <!-- TODO: insert URL templates for all endpoints -->
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


    <!-- member section -->

    <!-- returns the members in the context document based on the given parameters -->
    <xsl:function name="dts:members" as="element(dts:member)*" visibility="final">
        <xsl:param name="context" as="document-node()"/>
        <xsl:variable name="range-requested" as="xs:boolean">
            <!--
                whether a specific range of the citation tree in request
                by $ref or $start and $end
            -->
            <xsl:choose>
                <xsl:when test="$ref or ($start and $end)">
                    <xsl:sequence select="false()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="true()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- generate the sequence of members by applying 'members' transformation -->
        <xsl:variable name="members" as="element(dts:member)*">
            <xsl:apply-templates mode="members" select="dts:get-citeation-tree($context, $tree)">
                <xsl:with-param name="parentId" as="xs:string?" tunnel="true" select="()"/>
                <xsl:with-param name="parentContext" as="node()" tunnel="true"
                    select="root($context)"/>
                <xsl:with-param name="in-requested-range" as="xs:boolean" tunnel="true"
                    select="$range-requested"/>
                <xsl:with-param name="level" as="xs:integer" tunnel="true" select="1"/>
            </xsl:apply-templates>
        </xsl:variable>
        <!-- filter for range made up from $ref or $start and $end -->
        <xsl:variable name="members-in-requested-range" as="element(dts:member)*"
            select="$members[dts:is-in-requested-range(.)]"/>
        <!-- filter levels according to $down -->
        <xsl:choose>
            <xsl:when test="exists($down) and $down eq 0">
                <!-- specs about $down=0 with $ref:
                    "Information about the CitableUnit identified by ref along
                    with a member property that is an array of CitableUnits
                    that are siblings (sharing the same parent) including the
                    current CitableUnit identified by ref."
                -->
                <xsl:variable name="ref-parent-id" as="xs:string"
                    select="$members-in-requested-range[1]/dts:parent => string()"/>
                <xsl:sequence select="$members[string(dts:parent) = $ref-parent-id]"/>
            </xsl:when>
            <xsl:when test="$down &gt; 0">
                <!-- specs about $down:
                    "The maximum depth of the citation subtree to be returned,
                    relative to the specified ref, the deeper of the start/end
                    CitableUnit, or if these are not provided relative to the
                    root. […]"
                -->
                <xsl:variable name="deepest" as="xs:integer">
                    <xsl:choose>
                        <xsl:when test="$ref">
                            <xsl:sequence
                                select="$members-in-requested-range[1]/dts:level ! xs:integer(.) + $down"
                            />
                        </xsl:when>
                        <xsl:when test="$start">
                            <xsl:sequence
                                select="$members-in-requested-range[1 or last()]/dts:level ! xs:integer(.) => max() + $down"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="$down"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:sequence
                    select="$members-in-requested-range [xs:integer(dts:level/text()) le $deepest]"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$members-in-requested-range"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- returns the right refsDecl in the context based on $name -->
    <xsl:function name="dts:get-citeation-tree" as="element()?" visibility="public">
        <xsl:param name="context" as="node()"/>
        <xsl:param name="name" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="not($name)">
                <xsl:sequence select="($context//refsDecl[not(@xml:id)] | $context//refsDecl)[1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="id($name, $context)/self::refsDecl"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:mode name="members" on-no-match="shallow-skip" visibility="public"/>

    <xsl:template mode="members" match="citeStructure">
        <xsl:param name="parentId" as="xs:string?" tunnel="true"/>
        <xsl:param name="parentContext" as="node()" tunnel="true"/>
        <xsl:param name="in-requested-range" as="xs:boolean" tunnel="true"/>
        <xsl:param name="level" as="xs:integer" tunnel="true"/>
        <xsl:variable name="citeStructureContext" as="element(citeStructure)" select="."/>
        <xsl:variable name="members" as="node()*">
            <xsl:evaluate context-item="$parentContext" xpath="@match"
                namespace-context="$citeStructureContext"/>
        </xsl:variable>
        <xsl:iterate select="$members">
            <xsl:param name="in-requested-range-before" as="xs:boolean" select="$in-requested-range"/>
            <xsl:param name="last-was-requested-end" as="xs:boolean" select="false()"/>
            <xsl:variable name="memberContext" as="node()" select="."/>
            <xsl:variable name="use" as="item()*">
                <xsl:evaluate context-item="$memberContext" xpath="$citeStructureContext/@use"
                    namespace-context="$citeStructureContext"/>
            </xsl:variable>
            <xsl:variable name="identifier"
                select="concat($parentId, $citeStructureContext/@delim, $use)"/>
            <!-- make intermediate <dts:member> element -->
            <xsl:variable name="include" as="xs:boolean">
                <xsl:choose>
                    <!-- $last=$end,$here -->
                    <xsl:when test="$last-was-requested-end">
                        <xsl:sequence select="false()"/>
                    </xsl:when>
                    <!-- $here=$start -->
                    <xsl:when
                        test="$start and $end and not($in-requested-range-before) and ($identifier eq $start)">
                        <xsl:sequence select="true()"/>
                    </xsl:when>
                    <!-- $here=$ref -->
                    <xsl:when test="$ref and ($identifier eq $ref)">
                        <xsl:sequence select="true()"/>
                    </xsl:when>
                    <!-- keep state as has been before -->
                    <xsl:otherwise>
                        <xsl:sequence select="$in-requested-range-before"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="children" as="element(dts:member)*">
                <xsl:apply-templates mode="members" select="$citeStructureContext/node()">
                    <xsl:with-param name="parentId" as="xs:string?" tunnel="true"
                        select="$identifier"/>
                    <xsl:with-param name="parentContext" as="node()" tunnel="true"
                        select="$memberContext"/>
                    <xsl:with-param name="in-requested-range" as="xs:boolean" tunnel="true"
                        select="$include"/>
                    <xsl:with-param name="level" as="xs:integer" tunnel="true" select="$level + 1"/>
                </xsl:apply-templates>
            </xsl:variable>
            <dts:member>
                <!-- <dts:in-requested-range> keeps the state -->
                <dts:in-requested-range>
                    <xsl:sequence
                        select="$include and (every $child in $children satisfies dts:is-in-requested-range($child))"
                    />
                </dts:in-requested-range>
                <!-- <dts:end> keeps the state by demarking the $end member -->
                <xsl:if test="$end and $identifier eq $end">
                    <dts:end/>
                </xsl:if>
                <dts:identifier>
                    <xsl:value-of select="$identifier"/>
                </dts:identifier>
                <dts:level>
                    <xsl:value-of select="$level"/>
                </dts:level>
                <dts:parent>
                    <xsl:value-of select="$parentId"/>
                </dts:parent>
                <dts:citeType>
                    <xsl:value-of select="$citeStructureContext/@unit"/>
                </dts:citeType>
                <xsl:apply-templates mode="member-metadata" select="$memberContext"/>
            </dts:member>
            <xsl:sequence select="$children"/>
            <xsl:next-iteration>
                <xsl:with-param name="in-requested-range-before" as="xs:boolean">
                    <xsl:choose>
                        <!-- currently in $ref, so $next not in $ref -->
                        <xsl:when test="$ref and $identifier eq $ref">
                            <xsl:sequence select="false()"/>
                        </xsl:when>
                        <!-- $children[1]..$end..$children[last()],$next -->
                        <xsl:when test="exists($children/dts:end)">
                            <xsl:sequence select="false()"/>
                        </xsl:when>
                        <!-- $start..$children[last()],$next..$end -->
                        <xsl:when test="$children[last()] ! dts:is-in-requested-range(.)">
                            <xsl:sequence select="true()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="$include"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="last-was-requested-end" as="xs:boolean"
                    select="$end and $identifier eq $end"/>
            </xsl:next-iteration>
        </xsl:iterate>
    </xsl:template>

    <!-- make a Member JSON-LD object from an intermediate <dts:member> element -->
    <xsl:function name="dts:member-json" as="map(xs:string, item()*)?" visibility="final">
        <xsl:param name="member" as="element(dts:member)"/>
        <!-- xpaths on $member highly depend on making of $member, see above -->
        <xsl:map>
            <xsl:map-entry key="'identifier'" select="$member/dts:identifier/text()"/>
            <xsl:map-entry key="'@type'">CiteableUnit</xsl:map-entry>
            <xsl:map-entry key="'level'" select="$member/dts:level => xs:integer()"/>
            <xsl:map-entry key="'parent'" select="$member/dts:parent/text()"/>
            <xsl:map-entry key="'citeType'" select="$member/dts:citeType/text()"/>
        </xsl:map>
    </xsl:function>

    <!-- tests if an intermediate <dts:member> has the property that indicates that it is in the requested range -->
    <xsl:function name="dts:is-in-requested-range" as="xs:boolean" visibility="final">
        <xsl:param name="member" as="element(dts:member)"/>
        <xsl:sequence select="$member/dts:in-requested-range => xs:boolean()"/>
    </xsl:function>



    <!-- metadata of members -->

    <!-- override this function for making additional JSON-LD properties for an intermediate <dts:member> object -->
    <xsl:function name="dts:member-meta-json" as="map(xs:string, item()*)" visibility="public">
        <xsl:param name="member" as="element(dts:member)"/>
        <xsl:map/>
    </xsl:function>

    <!-- add templates to this mode to make metadata for each member
        to add children to intermediate <dts:member> elements -->
    <xsl:mode name="member-metadata" on-no-match="shallow-skip" visibility="public"/>

</xsl:package>
