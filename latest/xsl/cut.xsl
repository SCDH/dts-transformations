<xsl:package name="https://scdh.github.io/dts-transformations/xsl/cut.xsl" package-version="1.0.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:cut="https://distributed-text-services.github.io/specifications/cut#"
  exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

  <!-- returns all trees in the forrest between $start and $end nodes -->
  <xsl:function name="cut:horizontal" as="node()*" visibility="final">
    <xsl:param name="start" as="node()?"/>
    <xsl:param name="end" as="node()?"/>
    <xsl:choose>
      <xsl:when test="not(exists($start)) or not(exists($end))">
        <!-- at most one node, so we can return the sequence -->
        <xsl:sequence select="($start, $end)"/>
      </xsl:when>
      <xsl:when test="generate-id($start) eq generate-id($end)">
        <!-- start and end are the same node -->
        <xsl:sequence select="$start"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- start and end parameters are inclusive -->
        <xsl:sequence
          select="$start, $start/following::node() intersect $end/preceding::node(), $end"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- for given a sequence of nodes, filter away (drop) those nodes,
        that are descendants of other nodes in the sequence

        This is the same as outermost(). So, use outermost()! -->
  <xsl:function name="cut:drop-descendants" as="node()*" visibility="final">
    <xsl:param name="nodes" as="node()*"/>
    <xsl:variable name="ids" as="xs:string*" select="
      for $n in $nodes
      return
      generate-id($n)"/>
    <!-- TODO: what if ./parent::* is () ? -->
    <xsl:sequence select="
      $nodes[let $parent-id := generate-id(./parent::*)
      return
      every $id in $ids
      satisfies $id ne $parent-id]"/>
  </xsl:function>

</xsl:package>
