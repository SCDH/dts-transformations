<?xml version="1.0" encoding="UTF-8"?>
<xsl:package name="http://example.com/xsl/tei2html-selene" package-version="1.0.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:trace="http://wwu.de/scdh/selection-engine/node-tracing"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.0">

    <xsl:output method="html" indent="false"/>

    <xsl:use-package name="http://wwu.de/scdh/selection-engine/node-tracing" package-version="1.0.0"/>

    <xsl:mode on-no-match="shallow-skip"/>

    <xsl:mode name="toc" on-no-match="deep-skip"/>

    <xsl:template mode="toc #unnamed" match="text()">
        <xsl:call-template name="trace:text"/>
    </xsl:template>

    <xsl:template name="entry" visibility="public">
        <xsl:param name="nodes" as="node()*"/>
        <xsl:param name="mediaType" as="xs:string?" tunnel="true"/>
        <xsl:param name="resource" as="xs:string?" tunnel="true"/>
        <xsl:param name="tree" as="xs:string?" tunnel="true"/>
        <xsl:param name="ref" as="xs:string?" tunnel="true"/>
        <xsl:param name="start" as="xs:string?" tunnel="true"/>
        <xsl:param name="end" as="xs:string?" tunnel="true"/>
        <xsl:param name="document-root" as="document-node()" tunnel="true"/>

        <xsl:document>
            <html>
                <head>
                    <title>
                        <xsl:apply-templates select="$document-root//teiHeader//title"/>
                    </title>
                </head>
                <body>
                    <xsl:if
                        test="count($nodes) eq 1 and ($nodes[self::TEI] or $nodes[self::document-node()])">
                        <div class="toc" style="font-size:0.8em; background-color:lightgray">
                            <h1>Table of contents:</h1>
                            <xsl:for-each select="//text//head">
                                <xsl:value-of select="position()"/>
                                <xsl:text>. </xsl:text>
                                <xsl:apply-templates mode="toc" select="."/>
                            </xsl:for-each>
                        </div>
                    </xsl:if>
                    <hr/>
                    <div class="content">
                        <xsl:apply-templates select="$nodes"/>
                    </div>
                </body>
            </html>
        </xsl:document>

    </xsl:template>


    <xsl:template mode="toc #unnamed" match="lg | div">
        <div>
            <xsl:call-template name="trace:source-id"/>
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template mode="toc #unnamed" match="l | p">
        <p>
            <xsl:call-template name="trace:source-id"/>
            <xsl:apply-templates mode="#current"/>
        </p>
    </xsl:template>

    <xsl:template match="lem | sic | corr" mode="toc #unnamed">
        <span>
            <xsl:call-template name="trace:source-id"/>
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <xsl:template match="caesura" mode="toc #unnamed">
        <span style="margin-left:2em">
            <xsl:call-template name="trace:source-id"/>
        </span>
    </xsl:template>

    <xsl:template mode="toc #unnamed" match="head">
        <xsl:variable name="level" as="xs:integer" select="count(ancestor::div | ancestor::lg) + 1"/>
        <xsl:element name="{'h' || $level}">
            <xsl:call-template name="trace:source-id"/>
            <xsl:attribute name="style">display:inline</xsl:attribute>
            <xsl:apply-templates mode="#current"/>
        </xsl:element>
        <br/>
    </xsl:template>

    <xsl:template match="app" mode="toc #unnamed">
        <xsl:apply-templates select="lem" mode="#current"/>
    </xsl:template>

    <xsl:template match="choice[sic and corr]" mode="toc #unnamed">
        <xsl:apply-templates select="corr" mode="#current"/>
    </xsl:template>


</xsl:package>
