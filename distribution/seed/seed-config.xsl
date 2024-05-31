<?xml version="1.0" encoding="UTF-8"?>
<!-- Generate a configuration file for the SEED XML Transformer

The transformations given as the "transformations" parameter are
resolved relative to the URI given in the saxon-config-uri. The
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

    <!-- a prefix for transformation IDs and a leading path segment in relative paths. This is useful for name disambiguition when merging with other projects. -->
    <xsl:param name="id-prefix" as="xs:string" select="''" required="false"/>

    <!-- URI of the saxon configuration file. -->
    <xsl:param name="saxon-config-uri" as="xs:string" required="true"/>

    <!-- sequence of XSL transformations (stylesheets). Only used when the initial template is called. -->
    <xsl:param name="transformations" as="xs:string*" select="()" required="false"/>

    <!-- Relative links to packages in the saxon config are based on this.
        Defaults to the base URI of the Saxon configuration's document node. -->
    <xsl:param name="base-uri" as="xs:string" select="base-uri($saxon-config)"/>

    <!-- Where the SEED XML Transformer will get the packages. Only used if $relative-uris
        is false(). -->
    <xsl:param name="upload-uri" as="xs:string" select="$base-uri"/>

    <!-- If true, then relative URIs from the saxon configuration file are preserved,
        otherwise they are prefixed with $upload-uri. -->
    <xsl:param name="relative-uris" as="xs:boolean" select="true()"/>

    <xsl:param name="class" as="xs:string"
        select="'de.wwu.scdh.seed.xml.transform.saxon.SaxonXslTransformation'"/>

    <xsl:param name="transformation-id" as="xs:string" select="'name'"/>

    <xsl:param name="merge-options" as="map(xs:QName, item()*)" select="
            map {
                QName('http://saxon.sf.net/', 'on-duplicates'): function ($a, $b) {
                    $a
                }
            }"/>

    <xsl:variable name="saxon-config" select="doc($saxon-config-uri)"/>



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
            <xsl:variable name="relative-path"
                select="substring(base-uri(), string-length(resolve-uri('.', $base-uri)) + 1)"/>
            <xsl:apply-templates mode="transformation" select=".">
                <xsl:with-param name="transformation-id"
                    select="seed:get-transformation-id($relative-path, .)" tunnel="true"/>
                <xsl:with-param name="location" select="$relative-path" tunnel="true"/>
            </xsl:apply-templates>
        </xsl:map>
    </xsl:template>

    <xsl:mode name="transformation" on-no-match="shallow-skip"/>

    <xsl:template match="document-node()" mode="transformation">
        <xsl:param name="transformation-id" as="xs:string" tunnel="true"/>
        <xsl:param name="location" as="xs:string" tunnel="true"/>
        <xsl:variable name="stylesheet" as="document-node()" select="."/>
        <xsl:map-entry key="$transformation-id">
            <xsl:map>
                <xsl:map-entry key="'description'"
                    select="($stylesheet//comment() => string-join('&#xa;') => tokenize('&#xa;'))[normalize-space() ne ''][1] => normalize-space()"/>
                <xsl:map-entry key="'class'" select="$class"/>
                <xsl:choose>
                    <xsl:when test="$relative-uris and $id-prefix eq ''">
                        <xsl:map-entry key="'location'" select="$location"/>
                    </xsl:when>
                    <xsl:when test="$relative-uris and $id-prefix ne ''">
                        <xsl:map-entry key="'location'" select="concat($id-prefix, '/', $location)"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:map-entry key="'location'" select="resolve-uri($location, $upload-uri)"
                        />
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:map-entry key="'mediaType'" select="seed:media-type($stylesheet)"/>
                <xsl:map-entry key="'requiresSource'"
                    select="exists($stylesheet/global-context-item)"/>

                <!-- libraries (used packages) -->
                <xsl:map-entry key="'libraries'">
                    <xsl:variable name="libs" as="map(*)*">
                        <xsl:apply-templates mode="libraries" select="$stylesheet"/>
                    </xsl:variable>
                    <xsl:sequence
                        select="array {$libs => reverse() => seed:distinct-maps-in-order(())}"/>
                </xsl:map-entry>

                <!-- parameters -->
                <xsl:map-entry key="'parameterDescriptors'">
                    <xsl:variable name="params" as="map(*)*">
                        <xsl:apply-templates mode="stylesheet-params" select="$stylesheet"/>
                    </xsl:variable>
                    <xsl:sequence select="map:merge($params, $merge-options)"/>
                </xsl:map-entry>

            </xsl:map>
        </xsl:map-entry>
    </xsl:template>

    <xsl:mode name="libraries" on-no-match="shallow-skip"/>
    <xsl:mode name="stylesheet-params" on-no-match="shallow-skip"/>

    <!-- recurse into imported and included stylesheets -->
    <xsl:template mode="libraries stylesheet-params" match="import | include">
        <xsl:apply-templates mode="#current" select="doc(resolve-uri(@href, base-uri(.)))"/>
    </xsl:template>

    <xsl:template mode="libraries stylesheet-params" match="use-package">
        <xsl:variable name="name" select="@name"/>
        <xsl:variable name="version" select="@package-version"/>
        <!-- There may be several packages configured for the same @name and @version.
            In this case we disambiguate using @priority. -->
        <xsl:variable name="pkgs" as="element()*">
            <xsl:perform-sort
                select="$saxon-config/cfg:configuration/cfg:xsltPackages/cfg:package[@name eq $name and @version eq $version]">
                <xsl:sort select="@priority"/>
            </xsl:perform-sort>
        </xsl:variable>
        <xsl:variable name="pkg" as="element()" select="$pkgs[last()]"/>
        <xsl:variable name="pkg-uri" select="resolve-uri($pkg/@sourceLocation, base-uri($pkg))"/>
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>searching for package </xsl:text>
            <xsl:value-of select="@name"/>
            <xsl:text> in configuration </xsl:text>
            <xsl:value-of select="base-uri($saxon-config)"/>
        </xsl:message>
        <xsl:if test="not($pkg)">
            <xsl:message terminate="yes">
                <xsl:text>ERROR: package not found in config: </xsl:text>
                <xsl:value-of select="$name"/>
                <xsl:text> version </xsl:text>
                <xsl:value-of select="$version"/>
            </xsl:message>
        </xsl:if>
        <xsl:if test="not(doc-available($pkg-uri))">
            <xsl:message terminate="yes">
                <xsl:text>ERROR: package URI not available: </xsl:text>
                <xsl:value-of select="$pkg-uri"/>
            </xsl:message>
        </xsl:if>
        <xsl:variable name="package" select="doc($pkg-uri)" as="document-node()"/>
        <!-- make entry for this package -->
        <xsl:apply-templates mode="#current" select="$pkg">
            <xsl:with-param name="name" select="$pkg/@name" tunnel="true"/>
            <xsl:with-param name="version" select="$pkg/@version" tunnel="true"/>
            <xsl:with-param name="package" select="$package" tunnel="true"/>
        </xsl:apply-templates>
        <!-- recurse into packages used by the package -->
        <xsl:apply-templates mode="#current" select="$package"/>
    </xsl:template>

    <xsl:template mode="libraries" match="cfg:package">
        <xsl:param name="name" as="xs:string" tunnel="true"/>
        <xsl:param name="version" as="xs:string" tunnel="true"/>
        <xsl:param name="package" as="document-node()" tunnel="true"/>
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>making entry for package </xsl:text>
            <xsl:value-of select="@name"/>
        </xsl:message>
        <xsl:map>
            <xsl:choose>
                <xsl:when test="$relative-uris and $id-prefix eq ''">
                    <xsl:map-entry key="'location'" select="string(@sourceLocation)"/>
                </xsl:when>
                <xsl:when test="$relative-uris and $id-prefix ne ''">
                    <xsl:map-entry key="'location'"
                        select="concat($id-prefix, '/', @sourceLocation)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:map-entry key="'location'"
                        select="resolve-uri(@sourceLocation, $upload-uri)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:map>
        <!-- the package may be registered with another name or version -->
        <xsl:if
            test="$name ne $package/package/@name or $version ne $package/package/@package-version">
            <xsl:map-entry key="'name'" select="$name"/>
            <xsl:map-entry key="'version'" select="$version"/>
        </xsl:if>
    </xsl:template>

    <xsl:template mode="stylesheet-params" match="package/param | stylesheet/param">
        <xsl:variable name="fqn" as="xs:string">
            <xsl:choose>
                <xsl:when test="matches(@name, ':')">
                    <xsl:variable name="ns" as="xs:anyURI"
                        select="substring-before(@name, ':') => namespace-uri-for-prefix(@name/parent::*)"/>
                    <xsl:variable name="local-name" as="xs:string"
                        select="substring-after(@name, ':')"/>
                    <xsl:sequence select="concat('{', $ns, '}', $local-name, '')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="xs:string(@name)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:map>
            <xsl:map-entry key="$fqn">
                <xsl:map>
                    <xsl:map-entry key="'required'">
                        <xsl:choose>
                            <xsl:when
                                test="@required eq 'true' or @required eq 'yes' or @required eq '1'">
                                <xsl:sequence select="true()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="false()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:map-entry>
                    <xsl:map-entry key="'type'">
                        <xsl:value-of select="@as"/>
                    </xsl:map-entry>
                    <xsl:if test="exists(@select)">
                        <xsl:map-entry key="'default'">
                            <xsl:value-of select="@select"/>
                        </xsl:map-entry>
                    </xsl:if>
                </xsl:map>
            </xsl:map-entry>
        </xsl:map>
    </xsl:template>


    <!-- filter out duplicates from a sequence of maps -->
    <xsl:function name="seed:distinct-maps" as="map(xs:string, item()*)*">
        <!-- FIXME: keep order! -->
        <xsl:param name="maps" as="map(xs:string, item()*)*"/>
        <xsl:variable name="named-maps" as="map(xs:string, map(xs:string, item()*))*">
            <xsl:for-each select="$maps">
                <xsl:map>
                    <xsl:variable name="mp" select="."/>
                    <xsl:variable name="name-values">
                        <xsl:for-each select="map:keys($mp)">
                            <xsl:value-of select="concat(., ':', xs:string(map:get($mp, .)))"/>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:map-entry key="string-join($name-values, ';')" select="."/>
                </xsl:map>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="unique-maps" select="map:merge($named-maps, $merge-options)"
            as="map(xs:string, map(xs:string, item()*))"/>
        <xsl:for-each select="map:keys($unique-maps)">
            <xsl:variable name="n" select="."/>
            <xsl:sequence select="map:get($unique-maps, $n)"/>
        </xsl:for-each>
    </xsl:function>

    <!-- filter out duplicate maps while keeping the order of the original sequence of maps -->
    <xsl:function name="seed:distinct-maps-in-order" as="map(xs:string, item()*)*">
        <xsl:param name="maps" as="map(xs:string, item()*)*"/>
        <xsl:param name="seen" as="xs:string*"/>
        <xsl:variable name="head" as="map(xs:string, item()*)?" select="$maps[1]"/>
        <xsl:if test="exists($head)">
            <xsl:variable name="name-values">
                <xsl:for-each select="map:keys($head)">
                    <xsl:value-of select="concat(., ':', seed:to-string(map:get($head, .)))"/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="unique-name" select="string-join($name-values, ';')"/>
            <xsl:choose>
                <xsl:when test="
                        every $mp in $seen
                            satisfies $mp ne $unique-name">
                    <xsl:sequence
                        select="($head, seed:distinct-maps-in-order($maps[position() gt 1], ($seen, $unique-name)))"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence
                        select="seed:distinct-maps-in-order($maps[position() gt 1], $seen)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>

    <xsl:function name="seed:to-string" as="xs:string">
        <xsl:param name="var"/>
        <xsl:value-of select="$var"/>
    </xsl:function>



    <xsl:function name="seed:get-transformation-id" as="xs:string">
        <xsl:param name="transformation" as="xs:string"/>
        <xsl:param name="stylesheet" as="document-node()"/>
        <xsl:variable name="segments"
            select="($transformation => tokenize('\.'))[1] => tokenize('/')"/>

        <xsl:choose>
            <xsl:when test="$id-prefix eq ''">
                <xsl:sequence select="string-join($segments, '-')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="string-join(($id-prefix, $segments), '-')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- you may want to override this, e.g., if output format is encoded in the path -->
    <xsl:function name="seed:media-type" as="xs:string">
        <xsl:param name="stylesheet" as="document-node()"/>
        <xsl:choose>
            <xsl:when test="$stylesheet/*/output/@method eq 'text'">
                <xsl:text>text/plain</xsl:text>
            </xsl:when>
            <xsl:when test="$stylesheet/*/output/@method eq 'html'">
                <xsl:text>text/html</xsl:text>
            </xsl:when>
            <xsl:when test="$stylesheet/*/output/@method eq 'json'">
                <xsl:text>application/json</xsl:text>
            </xsl:when>
            <xsl:when test="$stylesheet/*/output/@method eq 'xml'">
                <xsl:text>text/xml</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>text/xml</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
