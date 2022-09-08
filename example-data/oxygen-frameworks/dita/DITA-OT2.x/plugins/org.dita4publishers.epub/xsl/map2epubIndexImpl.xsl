<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:df="http://dita2indesign.org/dita/functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:relpath="http://dita2indesign/functions/relpath"
                xmlns:htmlutil="http://dita4publishers.org/functions/htmlutil"
                xmlns:index-terms="http://dita4publishers.org/index-terms"
                xmlns:local="urn:functions:local"
                xmlns:epubtrans="urn:d4p:epubtranstype"
                exclude-result-prefixes="#all"
  >
  <!-- Generate a back-of-the-book index for inclusion in the EPUB. -->
  

  <xsl:output indent="yes" name="ncx" method="xml"/>


  <xsl:template match="*[df:class(., 'map/map')]" mode="generate-index">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="index-terms" as="element()"/>
    

    <xsl:if test="$generateIndexBoolean">
      
      <xsl:variable name="pubTitle" as="xs:string*">
        <xsl:apply-templates select="*[df:class(., 'topic/title')] | @title" mode="pubtitle"/>
      </xsl:variable>           
      <xsl:variable name="resultUri" 
        select="relpath:newFile($outdir, concat('generated-index', $outext))" 
        as="xs:string"/>

      <xsl:message> + [INFO] Generating index file "<xsl:sequence select="$resultUri"/>"...</xsl:message>

      <xsl:result-document href="{$resultUri}" format="html5"
        exclude-result-prefixes="index-terms"
        >
        <html xmlns="http://www.w3.org/1999/xhtml">
          <head>
            <title>Index</title>
            <xsl:call-template name="epubtrans:constructJavaScriptReferences">
              <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
              <xsl:with-param name="resultUri" as="xs:string" select="$resultUri"/>
            </xsl:call-template>
          </head>
          <body>
            <h1>Index</h1>
            <div class="index-list">
              <xsl:for-each-group select="$index-terms/index-terms:index-term"
                group-by="local:construct-index-group-key(.)"
                >
                <xsl:sort select="local:construct-index-group-sort-key(.)"/>
                <xsl:message> + [DEBUG] Index group "<xsl:sequence select="current-grouping-key()"/>"</xsl:message>
                <div class="index-group">
                  <h2><xsl:sequence select="local:construct-index-group-label(current-group()[1])"/></h2>
                  <ul class="index-terms">
                    <xsl:for-each-group select="current-group()" 
                      group-by="normalize-space(./index-terms:label)">
                      <xsl:sort select="normalize-space(./index-terms:label)"/>
                      <xsl:apply-templates select="current-group()" mode="generate-index"/>
                    </xsl:for-each-group>
                  </ul>
                </div>
              </xsl:for-each-group>
            </div>
          </body>
        </html>
      </xsl:result-document>  
      <xsl:message> + [INFO] Index generation done.</xsl:message>
      
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="generate-index" match="index-terms:index-term">
    <li class="index-term"  xmlns="http://www.w3.org/1999/xhtml">
      <span class="label"><xsl:apply-templates select="index-terms:label"/></span>
      <!-- Generate links here. -->
      <xsl:if test="index-terms:index-term">
        <ul class="index-terms"  xmlns="http://www.w3.org/1999/xhtml">
          <xsl:for-each-group select="index-terms:index-term" 
            group-by="normalize-space(./index-terms:label)">
            <xsl:sort select="normalize-space(./index-terms:label)"/>
            <xsl:apply-templates select="current-group()" mode="generate-index"/>
          </xsl:for-each-group>
        </ul>
      </xsl:if>
    </li>    
  </xsl:template>
  
  <xsl:template match="index-terms:label">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template mode="gather-index-terms" 
    match="*[df:class(.,'map/topicmeta')] | *[df:class(., 'topic/topic')]">
    <xsl:apply-templates select=".//*[df:class(.,'topic/indexterm')]" mode="generate-index"/>
  </xsl:template>
  
  <xsl:template mode="gather-index-terms" match="*[df:class(.,'topic/topic')]//*[df:class(.,'topic/indexterm')]">
    <xsl:param name="targetUri" as="xs:string" tunnel="yes"/>
    <index-term xmlns="http://dita4publishers.org/index-terms">
      <label><xsl:apply-templates select="*[not(df:class(., 'topic/indexterm'))]|text()"/></label>
      <target>[URI of the thing the index entry should point to goes here]</target>
      <item-id><xsl:sequence select="generate-id()"/></item-id>
      <xsl:apply-templates select="*[df:class(., 'topic/indexterm')]" mode="gather-index-terms"/>
    </index-term>
  </xsl:template>
  
  <xsl:template match="text()" mode="gather-index-terms" priority="-1"/>    
  
  <xsl:template match="*[df:isTopicRef(.)]" mode="gather-index-terms">
     <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>

    <xsl:variable name="topic" select="df:resolveTopicRef(.)" as="element()*"/>
      <xsl:choose>
        <xsl:when test="not($topic)">
          <!-- Do nothing. Unresolveable topics will already have been reported. -->
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="targetUri" 
            select="htmlutil:getTopicResultUrl2($outdir, root($topic), ., $rootMapDocUrl)" 
            as="xs:string"/>
          <xsl:variable name="relativeUri" select="relpath:getRelativePath($outdir, $targetUri)" as="xs:string"/>
            <!-- Any subordinate topics in the currently-referenced topic are
              reflected in the ToC before any subordinate topicrefs.
            -->
            <xsl:apply-templates mode="#current" 
              select="$topic//*[df:class(., 'topic/indexterm')], *[df:class(., 'map/topicref')]">
              <xsl:with-param name="targetUri" as="xs:string" tunnel="yes"
                select="$targetUri"
              />
            </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>    
        
  </xsl:template>
  
  <xsl:function name="local:construct-index-group-key" as="xs:string">
    <xsl:param name="index-term" as="element()"/>
    <!-- FIXME: This is a very quick-and-dirty grouping key implementation.
      
         A full implementation must be extensible and must be locale-specific.
      -->
    <xsl:variable name="label" select="normalize-space($index-term/index-terms:label)" as="xs:string"/>
    <xsl:variable name="key" as="xs:string">
      <xsl:choose>
        <xsl:when test="matches($label, '^[0-9]')">
          <xsl:sequence select="'#numeric'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="lower-case(substring($label,1,1))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:sequence select="$key"/>
  </xsl:function>

  <xsl:function name="local:construct-index-group-sort-key" as="xs:string">
    <xsl:param name="index-term" as="element()"/>
    <!-- FIXME: This is a very quick-and-dirty sorting key implementation.
      
      A full implementation must be extensible and must be locale-specific.
      
      Need to control whether non-alpha items come first or last in collation
      order.
    -->
    <xsl:variable name="label" select="normalize-space($index-term/index-terms:label)" as="xs:string"/>
    <xsl:variable name="key" as="xs:string">
      <xsl:choose>
        <xsl:when test="matches($label, '^[0-9]')">
          <xsl:sequence select="'#numeric'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="lower-case(substring($label,1,1))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:sequence select="$key"/>
  </xsl:function>
  
  <xsl:function name="local:construct-index-group-label" as="xs:string">
    <xsl:param name="index-term" as="element()"/>
    <!-- FIXME: This is a very quick-and-dirty label implementation.
      
      A full implementation must be extensible and must be locale-specific.
      
      Need to control whether non-alpha items come first or last in collation
      order.
    -->
    <xsl:variable name="label" select="normalize-space($index-term/index-terms:label)" as="xs:string"/>
    <xsl:variable name="groupLabel" as="xs:string">
      <xsl:choose>
        <xsl:when test="matches($label, '^[0-9]')">
          <xsl:sequence select="'Numeric'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="upper-case(substring($label,1,1))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:sequence select="$groupLabel"/>
  </xsl:function>
  
  
</xsl:stylesheet>
