<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:df="http://dita2indesign.org/dita/functions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:htmlutil="http://dita4publishers.org/functions/htmlutil"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:epubtrans="urn:d4p:epubtranstype"
  
  exclude-result-prefixes="#all"
  version="2.0">
  <!-- =============================================================
    
    DITA Map to EPUB Transformation: Content Generation Module
    
    Copyright (c) 2010, 2015 DITA For Publishers
    
    This module generates output HTML files for each topic referenced
    from the incoming map.
    
    Because all the HTML files may be output to a structure
    different from the source structure, this
    process generates unique (and opaque) filenames for the result
    HTML files. [It would be possible, given more effort, to generate
    distinct names that reflected the original filenames but it doesn't
    appear to be worth the effort.]
    
    The output generation template logs messages that show the
    source-to-result mapping to make it easier to debug issues
    with the generated topics.
    
    =============================================================  -->
  

  <!-- for epub2; epub3 and dual will use @name="html5" from map2epubImpl.xsl;
for epub2, cannot have @doctype-system="about:legacy:compat" (per epubcheck) -->
  <xsl:output name="topic-html-epub2"
    method="xhtml"
    encoding="UTF-8"
    indent="yes"
    include-content-type="no"
  />
  
  <xsl:output name="topic-html"
    method="xhtml"
    encoding="UTF-8"
    indent="yes"
    doctype-system="about:legacy-compat"
    include-content-type="no"
  />
  
  
  
  <xsl:template match="*[df:class(., 'map/map')]" mode="generate-content">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>

    <xsl:message> + [INFO] Generating content...</xsl:message>
    <xsl:variable name="uniqueTopicRefs" as="element()*" select="df:getUniqueTopicrefs(.)"/>
    
    
    <xsl:if test="$doDebug">    
      <xsl:message> + [DEBUG] ------------------------------- 
 + [DEBUG] Unique topics:      
      <xsl:for-each select="$uniqueTopicRefs">
 + [DEBUG] <xsl:sequence select="name(.)"/>: generated id="<xsl:sequence select="generate-id(.)"/>", URI=<xsl:sequence select="document-uri(root(.))"/>                
      </xsl:for-each>
 + [DEBUG] -------------------------------    
      </xsl:message>
    </xsl:if>    
    <xsl:apply-templates select="$uniqueTopicRefs" mode="generate-content"/>
    <xsl:message> + [INFO] Generating title-only topics for topicheads...</xsl:message>
    <xsl:apply-templates select=".//*[df:isTopicHead(.)]" mode="generate-content"/>
    <xsl:message> + [INFO] Content generated.</xsl:message>
  </xsl:template>
  
  <xsl:template match="*[df:isTopicHead(.)]" mode="generate-content">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] Handling topichead "<xsl:sequence select="df:getNavtitleForTopicref(.)"/>" in mode generate-content</xsl:message>
    </xsl:if>
    <xsl:variable name="topicheadFilename" as="xs:string"
      select="normalize-space(htmlutil:getTopicheadHtmlResultTopicFilename(.))" />
    <xsl:variable name="generatedTopic" as="document-node()">
      <xsl:document>
        <topic id="{relpath:getNamePart($topicheadFilename)}"
          xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
          ditaarch:DITAArchVersion="1.2"
          domains="(topic topic)"
          >
          <xsl:attribute name="xml:base"><xsl:value-of select="base-uri()"/></xsl:attribute>
          <xsl:attribute name="class"
            select="$titleOnlyTopicClassSpec"
          />
          <title>
            <xsl:attribute name="xml:base"><xsl:value-of select="base-uri()"/></xsl:attribute>
            <xsl:attribute name="class"
              select="$titleOnlyTopicTitleClassSpec"
            />
            <xsl:sequence select="df:getNavtitleForTopicref(.)"/></title>
        </topic>
      </xsl:document>
    </xsl:variable>
    <xsl:apply-templates select="$generatedTopic" mode="generate-content">
      <xsl:with-param name="topicref" select="." as="element()" tunnel="yes"/>
      <xsl:with-param name="resultUri" select="relpath:newFile($topicsOutputPath, $topicheadFilename)" as="xs:string" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="*[df:isTopicRef(.)]" mode="generate-content">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>
    
<!--    <xsl:variable name="doDebug" as="xs:boolean" select="true()"/>-->
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] Handling topicref to "<xsl:sequence select="string(@href)"/>" in mode generate-content</xsl:message>
    </xsl:if>
    <xsl:variable name="topic" select="df:resolveTopicRef(.)" as="element()*"/>
    <xsl:choose>
      <xsl:when test="not($topic)">
        <xsl:message> + [WARNING] generate-content: Failed to resolve topic reference to href "<xsl:sequence select="string(@href)"/>"</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="topicResultUri" 
          select="htmlutil:getTopicResultUrl2($outdir, root($topic), .,$rootMapDocUrl, $doDebug)"
          as="xs:string"
        />
        <!-- Do href fixup before doing full default-mode processing: -->
        <xsl:variable name="tempTopic" as="document-node()">
          <xsl:document>
            <xsl:apply-templates select="$topic" mode="href-fixup">
              <xsl:with-param name="topicResultUri" select="$topicResultUri"
                tunnel="yes"/>                           
              <xsl:with-param name="topicref" as="element()" select="." tunnel="yes"/>
            </xsl:apply-templates>
          </xsl:document>
        </xsl:variable>
        <!-- Apply templates in default mode to the topic with fixed up hrefs: -->
        <xsl:apply-templates select="$tempTopic" mode="#current">
          <xsl:with-param name="topicref" as="element()" select="." tunnel="yes"/>
          <xsl:with-param name="resultUri" select="$topicResultUri"
           tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>
  
  <xsl:template match="*" mode="generate-content" priority="-1">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] In catchall for generate-content, got 
        <xsl:sequence select="."/></xsl:message>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/topic')]" mode="generate-content">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- This template generates the output file for a referenced topic.
      -->
    <!-- The topicref that referenced the topic -->
    <xsl:param name="topicref" as="element()?" tunnel="yes"/>    
    <!-- Result URI to which the document should be written. -->
    <xsl:param name="resultUri" as="xs:string" tunnel="yes"/>
    
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] generate-content: handling topic <xsl:value-of select="name(.)"/>...</xsl:message>
      <xsl:message> + [DEBUG] generate-content:    Generating base HTML using default-mode HTML generation....</xsl:message>
    </xsl:if>
    <xsl:variable name="htmlNoNamespace" as="node()*">
      <xsl:apply-templates select="." mode="map-driven-content-processing">
        <xsl:with-param name="topicref" select="$topicref" as="element()?" tunnel="yes"/>
      </xsl:apply-templates>      
    </xsl:variable>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] generate-content:    Generating XHTML from base HTML...</xsl:message>
    </xsl:if>
    <xsl:variable name="xhtml" as="node()*">
      <xsl:apply-templates select="$htmlNoNamespace" mode="html2xhtml">
        <xsl:with-param name="topicref" select="$topicref" as="element()?" tunnel="yes"/>   
        <xsl:with-param name="resultUri" as="xs:string" tunnel="yes" select="$resultUri"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] xhtml:
<xsl:sequence select="$xhtml"/></xsl:message>
    </xsl:if>
    <xsl:message> + [INFO] Writing topic <xsl:value-of select="$topicref/@href"/> to HTML file "<xsl:sequence select="$resultUri"/>"...</xsl:message>
    <xsl:choose>
      <xsl:when test="$epubtrans:isEpub3">
        <xsl:result-document format="html5" 
          href="{$resultUri}" 
          exclude-result-prefixes="opf">
          <xsl:sequence select="$xhtml"/>
        </xsl:result-document>
      </xsl:when>
      <xsl:otherwise>
        <xsl:result-document format="topic-html-epub2" 
          href="{$resultUri}" 
          exclude-result-prefixes="opf">
          <xsl:sequence select="$xhtml"/>
        </xsl:result-document>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="map-driven-content-processing"  priority="100"
                match="*[df:class(., 'topic/topic')]" 
                >
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- This template is a general dispatch template that applies
      templates to the topicref in a distinct mode so processors
      can do topic output processing based on the topicref context
      if they want. -->
    <xsl:param name="topicref" as="element()?" tunnel="yes"/>
    
    <xsl:choose>
      <xsl:when test="$topicref">
        <xsl:if test="$doDebug">
          <xsl:message> + [DEBUG] topic/topic, map-driven-content-processing: applying templates to the topicref.</xsl:message>
        </xsl:if>        
        <xsl:apply-templates select="$topicref" mode="topicref-driven-content">
          <xsl:with-param name="topic" select="." as="element()?"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$doDebug">
          <xsl:message> + [DEBUG] topic/topic, map-driven-content-processing: no topicref, doing default processing..</xsl:message>
        </xsl:if>        
        <!-- Do default processing -->
        <xsl:apply-templates select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="topicref-driven-content" match="*[df:class(., 'map/topicref')]">
    <!-- Default topicref-driven content template. Simply applies normal processing
    in the default context to the topic parameter. -->
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="topic" as="element()?"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] topicref-driven-content, map/topicref: topicref="<xsl:sequence select="name(.)"/>, class="<xsl:sequence select="string(@class)"/>"</xsl:message>
    </xsl:if>
    <xsl:variable name="topicref" select="." as="element()"/>
    
    <xsl:for-each select="$topic">
      <!-- Process the topic in the default mode, meaning the base Toolkit-provided
        HTML output processing.
        
        By providing the topicref as a tunneled parameter it makes it available
        to custom extensions to the base Toolkit processing.
      -->
      <xsl:apply-templates select=".">
        <xsl:with-param name="topicref" select="$topicref" as="element()" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="
    *[df:class(., 'topic/body')]//*[df:class(., 'topic/indexterm')] |
    *[df:class(., 'topic/shortdesc')]//*[df:class(., 'topic/indexterm')] |
    *[df:class(., 'topic/abstract')]//*[df:class(., 'topic/indexterm')]
     "
     priority="10"
    >
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>

    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] Found an index item in topic content: [<xsl:sequence select="string(.)"/>]</xsl:message>
    </xsl:if>
    <a id="{generate-id()}" class="indexterm-anchor"/>
  </xsl:template>
  
  <!-- NOTE: the body of this template is taken from the base dita2xhtmlImpl.xsl -->
  <xsl:template match="*[df:class(., 'topic/topic')]/*[df:class(., 'topic/title')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="topicref" select="()" as="element()?" tunnel="yes"/>
    <xsl:param name="headinglevel">
      <xsl:choose>
        <xsl:when test="count(ancestor::*[contains(@class,' topic/topic ')]) > 6">6</xsl:when>
        <xsl:otherwise><xsl:value-of select="count(ancestor::*[contains(@class,' topic/topic ')])"/></xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:variable name="htmlClass"  select="concat('topictitle', $headinglevel)" as="xs:string"/>
    <xsl:element name="h{$headinglevel}">
      <xsl:attribute name="class" select="$htmlClass"/>
      <xsl:call-template name="commonattributes">
        <xsl:with-param name="default-output-class" select="$htmlClass" as="xs:string"/>      
      </xsl:call-template>
      <xsl:if test="not(../ancestor::*[df:class(., 'topic/topic')])">
        <!-- Only do this if we're the topic the topicref actually pointed to. -->
        <xsl:apply-templates select="$topicref" mode="enumeration"/>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>    
  </xsl:template>  
  
  <!-- Enumeration mode manages generating numbers from topicrefs -->
  <xsl:template match="* | text()" mode="enumeration">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:if test="false()">
      <xsl:message> + [DEBUG] enumeration: catch-all template. Element="<xsl:sequence select="name(.)"/></xsl:message>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="text()" mode="generate-content">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'map/topicmeta')]" priority="10">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
  </xsl:template>
  <!--
    The following implements the d4pSidebarAnchor. With the use of keys, it suppresses the location of the anchoredObject (e.g., a sidebar) and instead copies it to the result tree in the location of the d4pSidebarAnchor. Currently commented out pending recommended changes to the d4pSidebarAnchor element. Code does work and is in use at Human Kinetics -->
  <!--
  <xsl:key name="kObjectAnchor" match="*[df:class(.,'topic/xref d4p-formatting-d/d4pSidebarAnchor')]" use="@otherprops"/>
  
  <xsl:key name="kAnchoredObject" match="*" use="@id"/>
  
  <xsl:template match="*[df:class(.,'topic/xref d4p-formatting-d/d4pSidebarAnchor')]" priority="20">
    <xsl:apply-templates select=
      "key('kAnchoredObject', @otherprops)">
      <xsl:with-param name="useNextMatch" select="'true'" as="xs:string" />
    </xsl:apply-templates>
    
  </xsl:template>
  
  <xsl:template match="*[key('kObjectAnchor', @id)]" priority="20">
    <xsl:param name="useNextMatch" select="'false'" as="xs:string" />
    <xsl:choose>
      <xsl:when test="$useNextMatch='true'">
        <xsl:next-match/>
      </xsl:when> 
    </xsl:choose>
  </xsl:template>
  -->
</xsl:stylesheet>
