<!-- XSLT package for customizing the generation of the citation tree

For customization, replace this package via your saxon-config file and
add some overrides.
-->
<xsl:package name="https://scdh.github.io/dts-transformations/xsl/tree-hook.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dts="https://distributed-text-services.github.io/specifications/" version="3.0">

  <xsl:use-package name="https://scdh.github.io/dts-transformations/xsl/tree.xsl"
    package-version="1.0.0">

    <!-- components subject to possible overrides -->
    <xsl:accept component="variable" names="resource ref start end tree" visibility="public"/>
    <xsl:accept component="variable" names="marked-virtual-children" visibility="public"/>
    <xsl:accept component="mode" names="members member-metadata" visibility="public"/>
    <xsl:accept component="function" names="dts:get-citation-tree#2" visibility="public"/>
    <xsl:accept component="function" names="dts:cite-data-json#1" visibility="public"/>
    <xsl:accept component="function" names="dts:member-meta-json#1" visibility="public"/>

    <!-- final in tree.xsl -->
    <xsl:accept component="function" names="dts:validate-parameters#1" visibility="final"/>
    <xsl:accept component="function" names="dts:members#3" visibility="final"/>
    <xsl:accept component="function" names="dts:member-json#1" visibility="final"/>
    <xsl:accept component="function" names="dts:is-in-requested-range#1" visibility="final"/>

    <!--
    <xsl:override>

      <xsl:function name="dts:get-citation-tree" as="element(refsDecl)*" visibility="public">
        <xsl:param name="context" as="node()"/>
        <xsl:param name="name" as="xs:string?"/>
        <!-/- do some stuff -/->
      </xsl:function>

    </xsl:override>
    -->

  </xsl:use-package>

</xsl:package>
