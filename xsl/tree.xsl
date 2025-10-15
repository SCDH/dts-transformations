<!-- XSLT package for shared components related to citation trees

-->
<xsl:package name="https://scdh.github.io/dts-transformations/xsl/tree.xsl" package-version="1.0.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:dts="https://distributed-text-services.github.io/specifications/"
  exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

  <xsl:param name="ref" as="xs:string?" select="()"/>

  <xsl:param name="start" as="xs:string?" select="()"/>

  <xsl:param name="end" as="xs:string?" select="()"/>

  <xsl:param name="tree" as="xs:string?" select="()"/>

  <!-- experimental: When true(), members at level 2 and above have the boolean
    property dts:inParentSubtree. It indicates, if the constructed subtree is
    contained in the constructed subtree of the parent member. -->
  <xsl:param name="marked-virtual-children" as="xs:boolean" select="false()"/>

  <xsl:use-package name="https://scdh.github.io/dts-transformations/xsl/resource.xsl"
    package-version="1.0.0">
    <xsl:accept component="variable" names="resource" visibility="public"/>
    <xsl:accept component="function" names="dts:validate-resource-parameter#1" visibility="public"/>
  </xsl:use-package>

  <xsl:use-package name="https://scdh.github.io/dts-transformations/xsl/errors.xsl"
    package-version="1.0.0"/>

  <xsl:use-package name="https://scdh.github.io/dts-transformations/xsl/dts.xsl"
    package-version="1.0.0"/>

  <xsl:function name="dts:validate-parameters" as="map(xs:string, item())" visibility="final">
    <xsl:param name="context" as="node()"/>
    <xsl:variable name="parms" as="map(xs:string, item())">
      <xsl:map>
        <xsl:choose>
          <xsl:when test="$ref and ($start or $end)">
            <xsl:message terminate="yes" error-code="{$dts:http400 => dts:error-to-eqname()}">
              <xsl:value-of xml:space="preserve">ERROR: bad parameter combination: when ref is used, start and end must not</xsl:value-of>
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
            <xsl:message terminate="yes" error-code="{$dts:http400 => dts:error-to-eqname()}">
              <xsl:value-of xml:space="preserve">ERROR: bad parameter combination: start required end and vice versa</xsl:value-of>
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$tree">
          <xsl:map-entry key="'tree'" select="$tree"/>
        </xsl:if>
      </xsl:map>
    </xsl:variable>
    <xsl:sequence select="map:merge(($parms, dts:validate-resource-parameter($context)))"/>
  </xsl:function>


  <!-- returns the members in the context document based on the given parameters -->
  <xsl:function name="dts:members" as="element(dts:member)*" visibility="final">
    <xsl:param name="context" as="document-node()"/>
    <xsl:param name="down" as="xs:integer?"/>
    <xsl:param name="wrap-content" as="xs:boolean"/>
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
    <xsl:assert test="count(dts:get-citation-tree($context, $tree)) eq 1"
      error-code="{$dts:http404 => dts:error-to-eqname()}">
      <xsl:value-of xml:space="preserve">ERROR: citetation tree '<xsl:value-of select="$tree"/>' not found</xsl:value-of>
    </xsl:assert>
    <xsl:variable name="members" as="element(dts:member)*">
      <xsl:apply-templates mode="members" select="dts:get-citation-tree($context, $tree)">
        <xsl:with-param name="parentId" as="xs:string?" tunnel="true" select="()"/>
        <xsl:with-param name="parentContext" as="node()" tunnel="true" select="root($context)"/>
        <xsl:with-param name="in-requested-range" as="xs:boolean" tunnel="true"
          select="$range-requested"/>
        <xsl:with-param name="level" as="xs:integer" tunnel="true" select="1"/>
        <xsl:with-param name="wrap-content" as="xs:boolean" tunnel="true" select="$wrap-content"/>
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
                select="$members-in-requested-range[1]/dts:level ! xs:integer(.) + $down"/>
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
          select="$members-in-requested-range [xs:integer(dts:level/text()) le $deepest]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$members-in-requested-range"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- returns the right refsDecl in the context based on $name -->
  <xsl:function name="dts:get-citation-tree" as="element(refsDecl)*" visibility="public">
    <xsl:param name="context" as="node()"/>
    <xsl:param name="name" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="not($name)">
        <xsl:sequence select="$context/*/teiHeader/encodingDesc/refsDecl[@default eq 'true']"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$context/*/teiHeader/encodingDesc/refsDecl[@n eq $name]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:mode name="members" on-no-match="shallow-skip" visibility="public"/>

  <xsl:template mode="members" match="citeStructure">
    <xsl:param name="parentId" as="xs:string?" tunnel="true"/>
    <xsl:param name="parentContext" as="node()" tunnel="true"/>
    <xsl:param name="in-requested-range" as="xs:boolean" tunnel="true"/>
    <xsl:param name="level" as="xs:integer" tunnel="true"/>
    <xsl:param name="wrap-content" as="xs:boolean" tunnel="true"/>
    <xsl:variable name="members" as="node()*">
      <xsl:evaluate context-item="$parentContext" xpath="@match" namespace-context="."/>
    </xsl:variable>
    <xsl:sequence select="dts:cite-structure-member(
      $members,
      $in-requested-range,
      false(),
      .,
      $parentContext,
      $parentId,
      $level,
      $wrap-content
      )"/>
  </xsl:template>

  <!-- recursive function doing all the work -->
  <xsl:function name="dts:cite-structure-member" as="element(dts:member)*">
    <xsl:param name="members" as="node()*"/>
    <xsl:param name="in-requested-range-before" as="xs:boolean"/>
    <xsl:param name="last-was-requested-end" as="xs:boolean"/>
    <xsl:param name="citeStructureContext" as="element(citeStructure)"/>
    <xsl:param name="parentContext" as="node()"/>
    <xsl:param name="parentId" as="xs:string?"/>
    <xsl:param name="level" as="xs:integer"/>
    <xsl:param name="wrap-content" as="xs:boolean"/>
    <xsl:choose>
      <xsl:when test="not(exists($members))"/>
      <xsl:otherwise>
        <xsl:variable name="memberContext" as="node()" select="head($members)"/>
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
        <xsl:message use-when="system-property('debug') eq 'true'">
          <xsl:text>member state </xsl:text>
          <xsl:value-of select="$identifier"/>
          <xsl:text> is head of </xsl:text>
          <xsl:value-of select="count($members)"/>
          <xsl:text> members; in-requested-range-before=</xsl:text>
          <xsl:value-of select="$in-requested-range-before"/>
          <xsl:text>   last-end=</xsl:text>
          <xsl:value-of select="$last-was-requested-end"/>
          <xsl:text>   include=</xsl:text>
          <xsl:value-of select="$include"/>
        </xsl:message>
        <xsl:variable name="children" as="element(dts:member)*">
          <xsl:apply-templates mode="members" select="$citeStructureContext/node()">
            <xsl:with-param name="parentId" as="xs:string?" tunnel="true" select="$identifier"/>
            <xsl:with-param name="parentContext" as="node()" tunnel="true" select="$memberContext"/>
            <xsl:with-param name="in-requested-range" as="xs:boolean" tunnel="true"
              select="$include"/>
            <xsl:with-param name="level" as="xs:integer" tunnel="true" select="$level + 1"/>
            <xsl:with-param name="wrap-content" as="xs:boolean" tunnel="true" select="$wrap-content"
            />
          </xsl:apply-templates>
        </xsl:variable>
        <!-- output member -->
        <dts:member>
          <!-- <dts:in-requested-range> keeps the state -->
          <dts:in-requested-range>
            <xsl:sequence
              select="$include and (every $child in $children satisfies dts:is-in-requested-range($child))"
            />
          </dts:in-requested-range>
          <!-- <dts:start/> keeps track of state by demarking the $start member -->
          <xsl:if test="$start and $identifier eq $start">
            <xsl:message use-when="system-property('debug') eq 'true'">
              <xsl:text>this is requrested START </xsl:text>
              <xsl:value-of select="$identifier"/>
              <xsl:text> Is it in the requested range? </xsl:text>
              <xsl:value-of
                select="$include and (every $child in $children satisfies dts:is-in-requested-range($child))"
              />
            </xsl:message>
            <dts:start/>
          </xsl:if>
          <!-- <dts:end> keeps the state by demarking the $end member -->
          <xsl:if test="$end and $identifier eq $end">
            <xsl:message use-when="system-property('debug') eq 'true'">
              <xsl:text>this is requrested END </xsl:text>
              <xsl:value-of select="$identifier"/>
              <xsl:text> Is it in the requested range? </xsl:text>
              <xsl:value-of
                select="$include and (every $child in $children satisfies dts:is-in-requested-range($child))"
              />
            </xsl:message>
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
          <!-- evaluate citeData -->
          <xsl:for-each select="$citeStructureContext/citeData">
            <dts:citeData>
              <xsl:attribute name="property" select="@property"/>
              <xsl:evaluate context-item="$memberContext" xpath="@use" namespace-context="."/>
            </dts:citeData>
          </xsl:for-each>
          <!-- experimantal information if contained in parent's constructed subtree -->
          <dts:containedInParentSubtree>
            <xsl:variable name="parent-element-id" as="xs:string"
              select="$parentContext => generate-id()"/>
            <xsl:value-of
              select="some $id in $memberContext/ancestor-or-self::node() ! generate-id() satisfies $id eq $parent-element-id"
            />
          </dts:containedInParentSubtree>
          <!-- optionally wrap all the member content nodes and paths to the nodes -->
          <xsl:if test="$wrap-content">
            <dts:wrapper>
              <xsl:copy-of select="$memberContext"/>
            </dts:wrapper>
          </xsl:if>
          <!--
            Elements copied to dts:member/dts:wrapper loose their document
            context. In order to regain them in document context, we do
            roundtripping with path expressions. Which method would be more
            performant?

            citeStructure/@match may select multiple nodes. For $ref,
            regaining them all is required! For $start and $end, only the
            edges are required; however, since $start and $end may equal,
            we have to use different elements to store them!
        -->
          <dts:xpath>
            <xsl:value-of select="path($memberContext)"/>
          </dts:xpath>
          <!-- hook for additional custom data -->
          <xsl:apply-templates mode="member-metadata" select="$memberContext"/>
        </dts:member>
        <!-- output children members -->
        <xsl:sequence select="$children"/>
        <!-- pass state to the next iteration -->

        <xsl:variable name="next-in-requested-range-before" as="xs:boolean">
          <xsl:choose>
            <xsl:when test="$start and $identifier eq $start">
              <xsl:message use-when="system-property('debug') eq 'true'">
                <xsl:text>START setting next</xsl:text>
              </xsl:message>
              <xsl:sequence select="true()"/>
            </xsl:when>
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
        </xsl:variable>
        <xsl:message use-when="system-property('debug') eq 'true'">
          <xsl:text>next member gets $in-requested-range-before=</xsl:text>
          <xsl:value-of select="$next-in-requested-range-before"/>
        </xsl:message>
        <!-- 
          <xsl:param name="members" as="node()*"/>
          <xsl:param name="in-requested-range-before" as="xs:boolean"/>
          <xsl:param name="last-was-requested-end" as="xs:boolean"/>
          <xsl:param name="citeStructureContext" as="element(citeStructure)"/>
          <xsl:param name="parentContext" as="element()"/>
          <xsl:param name="parentId" as="xs:string"/>
          <xsl:param name="level" as="xs:integer"/>
          <xsl:param name="wrap-content" as="xs:boolean"/> 
        -->
        <xsl:sequence select="dts:cite-structure-member(
          $members[position() gt 1],
          $next-in-requested-range-before,
          ($end and $identifier eq $end),
          $citeStructureContext,
          $parentContext,
          $parentId,
          $level,
          $wrap-content
          )"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- tests if an intermediate <dts:member> has the property that indicates that it is in the requested range -->
  <xsl:function name="dts:is-in-requested-range" as="xs:boolean" visibility="final">
    <xsl:param name="member" as="element(dts:member)"/>
    <xsl:sequence select="$member/dts:in-requested-range => xs:boolean()"/>
  </xsl:function>

  <!-- make a Member JSON-LD object from an intermediate <dts:member> element -->
  <xsl:function name="dts:member-json" as="map(xs:string, item()*)?" visibility="final">
    <xsl:param name="member" as="element(dts:member)"/>
    <!-- xpaths on $member highly depend on making of $member, see above -->
    <xsl:map>
      <xsl:map-entry key="'identifier'" select="$member/dts:identifier/text()"/>
      <xsl:map-entry key="'@type'">CitableUnit</xsl:map-entry>
      <xsl:map-entry key="'level'" select="$member/dts:level => xs:integer()"/>
      <xsl:map-entry key="'parent'" select="$member/dts:parent/text()"/>
      <xsl:map-entry key="'citeType'" select="$member/dts:citeType/text()"/>
      <xsl:if test="$marked-virtual-children and $member/dts:level => xs:integer() gt 1">
        <xsl:map-entry key="'dts:inParentSubtree'"
          select="$member/dts:containedInParentSubtree => xs:boolean()"/>
      </xsl:if>
    </xsl:map>
  </xsl:function>

  <!-- make map from properties declared with <citeData> -->
  <xsl:function name="dts:cite-data-json" as="map(xs:string, item()*)" visibility="public">
    <xsl:param name="member" as="element(dts:member)"/>
    <!-- TODO: Do we need to treat dcterms meta data in a special way? -->
    <xsl:map>
      <xsl:for-each select="$member/dts:citeData">
        <xsl:map-entry key="@property => string() => dts:compact()">
          <xsl:variable name="val" as="xs:string">
            <xsl:value-of select="."/>
          </xsl:variable>
          <xsl:sequence select="dts:compact($val)"/>
        </xsl:map-entry>
      </xsl:for-each>
    </xsl:map>
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
