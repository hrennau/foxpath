<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
      xmlns:xs="http://www.w3.org/2001/XMLSchema"
      xmlns:local="urn:local-functions"
      xmlns:relpath="http://dita2indesign/functions/relpath"
      xmlns:df="http://dita2indesign.org/dita/functions"
      exclude-result-prefixes="xs local df relpath"
      version="2.0">
  
  <!-- =====================================================================
       DITA Map to InCopy Articles
       
       Generates one or more InCopy articles (.icml) from a DITA map.
       
       The rules for generating ICML files from the input map or
       topics is determined by the chunkStrategy and sidebarChunkStrategy
       parameters.
       
       The direct output of the transform is an XML manifest file that
       lists the InCopy articles generated.
    
       Copyright (c) 2013, 2015 DITA for Publishers
    
    ===========
    Parameters:
    
    chunkStrategy: Indicates how result topics are to be organized into
                   ICML files. Provides some basic options as an alternative
                   to creating custom overrides.
                   
                   Values are:
                   
                   - perTopicDoc  — Each topic document ("chunk" in the DITA sense)
                                    results in a new ICML file. This is the default.
                                    
                   - perChapter   - Each top-level topic in the map structure generates
                                    a new ICML file. For BookMap and PubMap, part and
                                    chapter topicrefs result in new chunks. 
                                    
                   - perMap       - The entire map results in a single ICML file
                   
    sidebarChunkStrategy: Indicates how to handle sidebar topics in the result ICML:
    
                   - normal   - Handled like any other topic. The active chunkStrategy 
                                is used.
                                
                   - toFile   - Generate a new ICML file for each sidebar topic
                   
                   - toAnchoredFrame - Put the sidebar in an anchored frame. If
                                       there is a D4P sidebar anchor to the sidebar
                                       it is anchored at that point, otherwise it
                                       is anchored at the point where it occurs in the
                                       main topic sequence.
    
    debug - Turns template debugging on and off: 
    
      'true' - Turns debugging on
      'false' - Turns it off (the default)
      
      FIXME: Handle @chunk attributes on topicrefs
    =====================================================================-->
    
  <xsl:include href="topic2icmlImpl.xsl"/>
  <xsl:include href="generateResultDocs.xsl"/>
  <xsl:include href="lib/resolve-map.xsl"/>
  
  <xsl:param name="WORKDIR" as="xs:string" select="''"/>
  <xsl:param name="PATH2PROJ" as="xs:string" select="''"/>
  <xsl:param name="KEYREF-FILE" as="xs:string" select="''"/>
  

  <xsl:param name="platform" select="'unknown'" as="xs:string"/>
  <xsl:param name="outdir" select="'./indesign'"/>
  <xsl:param name="tempdir" select="'./temp'"/>
  <xsl:param name="titleOnlyTopicClassSpec" select="'- topic/topic '" as="xs:string"/>
  
  <xsl:param name="titleOnlyTopicTitleClassSpec" select="'- topic/title '" as="xs:string"/>
  
  <xsl:param name="chunkStrategy" select="'perTopicDoc'"/>
  <xsl:variable name="effectiveChunkStrategy" as="xs:string"
    select="if (matches($chunkStrategy, 'perTopicDoc|perMap|perChapter', 'i'))
               then $chunkStrategy
               else 'perTopicDoc'"
  />
  
  <xsl:param name="sidebarChunkStrategy" select="'normal'"/>
  <xsl:variable name="effectiveSidebarChunkStrategy" as="xs:string"
    select="if (matches($sidebarChunkStrategy, 'normal|toFile|toAnchoredFrame', 'i'))
               then $sidebarChunkStrategy
               else 'normal'"
  />
  
  <xsl:param name="debug" select="'false'"/>
  <xsl:variable name="debugBoolean" 
    select="matches($debug,'true|1|on|yes', 'i')" as="xs:boolean"
  />
  
  <!-- 
    The direct output of the transform is an XML manifest file
    that lists all the files generated.
  -->
  <xsl:output encoding="UTF-8"
    indent="yes"
    method="xml"
  />
  
  <!--NOTE: topic2icmlImpl.xsl defines the icml output type -->
  
  <xsl:template match="/">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
    <xsl:param name="isRoot" as="xs:boolean" select="true()" tunnel="yes"/>
    
    <xsl:choose>
      <xsl:when test="$isRoot">
        <xsl:apply-templates select="." mode="report-parameters"/>
        <manifest>&#x0020;
          <xsl:apply-templates>
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            <xsl:with-param name="articleType" select="'topic'" as="xs:string" tunnel="yes"/>
            <xsl:with-param name="isRoot" tunnel="yes" as="xs:boolean" select="false()"/>
          </xsl:apply-templates>
        </manifest>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates>
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
          <xsl:with-param name="articleType" select="'topic'" as="xs:string" tunnel="yes"/>
          <xsl:with-param name="isRoot" tunnel="yes" as="xs:boolean" select="false()"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="report-parameters" match="*" mode="report-parameters">
    <xsl:param name="effectiveCoverGraphicUri" select="''" as="xs:string" tunnel="yes"/>
    <xsl:message> 
      ==========================================
      Plugin version: ^version^ - build ^buildnumber^ at ^timestamp^
      
      Parameters:
      
      + outdir          = "<xsl:sequence select="$outdir"/>"
      + tempdir         = "<xsl:sequence select="$tempdir"/>"
      + linksPath       = "<xsl:sequence select="$linksPath"/>"
      + chunkStrategy   = "<xsl:sequence select="$chunkStrategy"/>"
      + sidebarChunkStrategy = "<xsl:sequence select="$sidebarChunkStrategy"/>"
      
      
      + WORKDIR         = "<xsl:sequence select="$WORKDIR"/>"
      + PATH2PROJ       = "<xsl:sequence select="$PATH2PROJ"/>"
      + KEYREF-FILE     = "<xsl:sequence select="$KEYREF-FILE"/>"
      + debug           = "<xsl:sequence select="$debug"/>"
      
      Global Variables:
      
      + platform         = "<xsl:sequence select="$platform"/>"
      + debugBoolean     = "<xsl:sequence select="$debugBoolean"/>"
      
      ==========================================
    </xsl:message>
  </xsl:template>
  
  <xsl:template name="validate-parameters">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
    <xsl:if test="not(matches($chunkStrategy, 'perTopicDoc|perMap|perChapter', 'i'))">
      <xsl:message> + [WARN] Unexpected value "<xsl:value-of select="$chunkStrategy"/>" for chunkStrategy parameter. Expected "perTopicDoc", "perChapter", or "perMap". Using "perTopicDoc".</xsl:message>
    </xsl:if>
    <xsl:if test="not(matches($sidebarChunkStrategy, 'normal|toFile|toAnchoredFrame', 'i'))">
      <xsl:message> + [WARN] Unexpected value "<xsl:value-of select="$sidebarChunkStrategy"/>" for sidebarChunkStrategy parameter. Expected "normal", "toFile", or "toAnchoredFrame". Using "normal".</xsl:message>
    </xsl:if>
  </xsl:template>

  <xsl:template match="/*[df:class(., 'map/map')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
    
    <!-- The map-level processing is done in two 
         stages:
         
         Stage 1: Processes the entire map and produces a
                  single result XML structure that represents
                  all ICML articles to be generated.
                  
                  Each article is bounded by a local:result-document
                  element, which is the same as xsl:result-document 
                  but in the local namespace. The result documents
                  may be nested.
                  
                  This processing is done in the default mode.
                  
                  NOTE: the mode "result-docs" is now mapped to
                        the default mode for backward compatibility.
                  
         Stage 2: The result of stage 1 is processed to generate all
                  the result documents.
                  
      -->
    <xsl:message> + [INFO] Stage 1: Processing map to construct intermediate ICML data file with result documents marked...</xsl:message>
    
    <xsl:variable name="resolvedMap" as="node()*">
      <xsl:document>
        <xsl:apply-templates select="." mode="resolve-map">
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
          <xsl:with-param name="parentHeadLevel" as="xs:integer" tunnel="yes" select="0"/>
          <xsl:with-param name="map-base-uri" as="xs:string" tunnel="yes" select="document-uri(root(.))"/>
        </xsl:apply-templates>
      </xsl:document>
    </xsl:variable>
    
    <xsl:if test="$doDebug">
      <xsl:variable name="tempMapURI" as="xs:string" select="relpath:newFile($outputPath, 'resolved-map.ditamap')"/>
      <xsl:message> + [DEBUG] Writing resolved map to "<xsl:value-of select="$tempMapURI"/>" </xsl:message>
      <xsl:result-document href="{$tempMapURI}">
        <xsl:sequence select="$resolvedMap"/>
      </xsl:result-document>
        
    </xsl:if>
    
    <xsl:variable name="icmlDataWithResultDocsMarked" as="node()*">
      <xsl:choose>
        <xsl:when test="matches($effectiveChunkStrategy, 'perMap', 'i')">
          <xsl:variable name="articleIcmlData" as="node()*">
            <xsl:apply-templates mode="process-map" select="$resolvedMap/*/*">
              <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            </xsl:apply-templates>
          </xsl:variable>
          <local:result-document 
            href="{relpath:newFile($outputPath, local:getArticleUrlForTopic(.))}"
          >
            <xsl:call-template name="makeInCopyArticle">
              <!-- content parameter is source elements to be processed
                   in normal model, which we don't want.
                -->
              <xsl:with-param name="content" select="()" as="node()*"/>
              <!-- Leading paragraphs are ICML paragraphs. -->
              <xsl:with-param name="leadingParagraphs" 
                select="$articleIcmlData" as="node()*"
              />
            </xsl:call-template>
          </local:result-document>
        </xsl:when>
        <xsl:otherwise>
          <local:root>
            <xsl:apply-templates mode="process-map" select="$resolvedMap/*/*">
              <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            </xsl:apply-templates>
          </local:root>
        </xsl:otherwise>
      </xsl:choose>      
    </xsl:variable>
    
    <xsl:if test="$doDebug">
      <xsl:variable name="tempFileURI" as="xs:string" 
        select="relpath:newFile($outputPath, 'intermediateIcml.xml')"/>
      <xsl:message> + [DEBUG] Writing intermediate ICML data to <xsl:value-of select="$tempFileURI"/></xsl:message>
      <xsl:result-document href="{$tempFileURI}">
        <xsl:sequence select="$icmlDataWithResultDocsMarked"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:message> + [INFO] Stage 2: Generating result documents...</xsl:message>
    <xsl:apply-templates select="$icmlDataWithResultDocsMarked"
      mode="generate-result-docs">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    <xsl:message> + [INFO] Stage 3: Generating manifest entries...</xsl:message>
    <xsl:apply-templates select="$icmlDataWithResultDocsMarked"
      mode="generate-manifest-entries">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template mode="process-map" match="*[df:class(., 'map/topicref')][@href]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
    <!-- Handle references to topics -->
    <xsl:variable name="targetTopic" select="df:resolveTopicRef(.)" as="element()?"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] topicref[@href]: targetTopic="<xsl:value-of select="name($targetTopic)"/>"</xsl:message>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="not($targetTopic)">
        <xsl:message> + [ERROR] Failed to resolve topicref to URL "<xsl:sequence select="string(@href)"/>".</xsl:message>
      </xsl:when>
      <xsl:when test="df:class($targetTopic, 'map/map')">
        <xsl:if test="$doDebug">
          <xsl:message> + [DEBUG] topicref[@href]: Got a map, applying templates to its topicref children...</xsl:message>
        </xsl:if>
        <xsl:apply-templates select="$targetTopic/*[df:class(., 'map/topicref')]" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message> + [INFO] process-map: Processing topic <xsl:sequence select="document-uri(root($targetTopic))"/> in default mode...</xsl:message>
        <!-- Apply templates to the root node of the topic, rather than
             the topic doc, so we don't have each topic match the "/"
             template.
          -->
        <xsl:variable name="doDebug" as="xs:boolean" select="false()"/>
        <xsl:apply-templates select="$targetTopic">
          <!-- Give the topic access to its referencing topicref so it can know where it 
               lives in the map structure, what the topicref properties were, etc.
            -->
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
          <xsl:with-param name="topicref" as="element()" tunnel="yes" select="."/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
    
    <!-- NOTE: subordinate topicrefs are handled in the template for topics so
               that topics can implement automatic chunking of nested topics
               to single ICML files.
      -->
  </xsl:template>
  
  <xsl:template mode="process-map" 
    match="*[df:class(.,'map/topicref')]
    [not(@href) and 
     df:hasSpecifiedNavtitle(.)]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
    <!-- Handle topicrefs with only navtitles -->
    <xsl:apply-templates mode="#current">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="process-map"
    match="*[df:class(.,'map/topicref')]
    [not(@href) and 
     not(df:hasSpecifiedNavtitle(.))]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
    <xsl:apply-templates mode="#current">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="process-map" match="text()">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
  </xsl:template><!-- Suppress text in process-map mode -->
  
  <xsl:template 
    match="
    *[df:class(.,'topic/title')] |
    *[df:class(.,'map/topicmeta')]
    " 
    mode="process-map">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>    
  </xsl:template>  
  
  <xsl:template match="text()" mode="process-map">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
    <!-- Suppress all text within the map: there should be no output 
      resulting from the input map itself.
    -->
  </xsl:template>  
  
  <xsl:template mode="process-map" match="*" priority="-1">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
    <xsl:message> + [WARNING] dita2indesignImpl.xsl: (process-map mode): Unhandled element <xsl:sequence select="name(..)"/>/<xsl:sequence select="name(.)"/></xsl:message>
  </xsl:template>

  <!-- Evaluates the context topic and its context against the
       chunk-control parameters to determine if the topic should
       start a new chunk.
    -->
  <xsl:function name="local:isChunkRoot" as="xs:boolean">    
    <xsl:param name="context" as="element()"/><!-- Topicref element -->
    <xsl:param name="topicref" as="element()"/><!-- Topicref to the topic 
                                                    (or its nearest ancestor topic) -->
    
    <xsl:variable name="result" as="xs:boolean"
        select="(matches($effectiveChunkStrategy, 'perTopicDoc', 'i') and
                 not($context/parent::*[df:class(., 'topic/topic')])) or
                (matches($effectiveChunkStrategy, 'perChapter', 'i') and
                 not($context/parent::*[df:class(., 'topic/topic')]) and
                 ((count($topicref/ancestor::*[df:isTopicRef(.)]) = 0) or
                  (contains($topicref/@class, '/part ') or 
                   contains($topicref/@class, '/chapter ')))) or
                ((df:class($context, 'sidebar/sidebar') or
                  contains($topicref/@class, '/sidebar ')) and
                  matches($effectiveSidebarChunkStrategy, 'toFile', 'i'))
          "
      />
    <xsl:sequence select="$result"/>
  </xsl:function>

</xsl:stylesheet>
