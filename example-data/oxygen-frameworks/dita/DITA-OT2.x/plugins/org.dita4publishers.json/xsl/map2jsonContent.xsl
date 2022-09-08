<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:df="http://dita2indesign.org/dita/functions" 
	xmlns:json="http://json.org/" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:relpath="http://dita2indesign/functions/relpath" 
	xmlns:htmlutil="http://dita4publishers.org/functions/htmlutil" 
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
	exclude-result-prefixes="df xs relpath htmlutil xd" 
	version="2.0">
  <!-- =============================================================
    
    DITA Map to json Transformation: Content Generation Module
    
    Copyright (c) 2010 DITA For Publishers
    
    This module generates output HTML files for each topic referenced
    from the incoming map.
    
    =============================================================  -->
<xsl:template name="commonattributes">
  <xsl:param name="default-output-class"/>
  <xsl:apply-templates select="@xml:lang"/>
  <xsl:apply-templates select="@dir"/>
  <xsl:apply-templates select="@audience"/>
  <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]/@outputclass" mode="add-ditaval-style"/>
  <xsl:apply-templates select="." mode="set-output-class">
    <xsl:with-param name="default" select="$default-output-class"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="@audience">
  <xsl:attribute name="audience"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

  <xsl:template match="*[df:class(., 'map/map')]" mode="generate-json-content">
    <xsl:param name="uniqueTopicRefs" as="element()*" tunnel="yes"/>
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>
    
    <xsl:message> + [INFO] Generating json content...</xsl:message>
    
    <xsl:apply-templates select="$uniqueTopicRefs" mode="#current"/>

    <xsl:message> + [INFO] JSON content generated.</xsl:message>
  
  </xsl:template>


  <xsl:template mode="generate-json-content"
                match="*[df:isTopicRef(.)]
                          [not(@scope = ('peer', 'external'))]">
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>
     <xsl:param name="collected-data" as="element()" tunnel="yes"/>
    <xsl:variable name="topic" select="df:resolveTopicRef(.)" as="element()*"/>

    <xsl:choose>
      <xsl:when test="not($topic)">
        <xsl:message> + [WARNING] generate-content: Failed to resolve topic reference to href "<xsl:sequence
            select="string(@href)"/>"</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="topicResultUri" select="htmlutil:getTopicResultUrl($outdir, root($topic), $rootMapDocUrl)"
          as="xs:string"/>
        <xsl:variable name="topicRelativeUri" select="htmlutil:getTopicResultUrl('', root($topic), $rootMapDocUrl)"
          as="xs:string"/>

        <xsl:variable name="tempTopic" as="document-node()">
	      <xsl:document>
          <xsl:apply-templates select="$topic" mode="href-fixup">
            <xsl:with-param name="topicResultUri" select="$topicResultUri" tunnel="yes"/>
          </xsl:apply-templates>
		 </xsl:document>
        </xsl:variable>

        <xsl:apply-templates select="$tempTopic" mode="#current">
          <xsl:with-param name="topicref" as="element()*" select="." tunnel="yes"/>
          <xsl:with-param name="collected-data" select="$collected-data" as="element()" tunnel="yes"/>
          <xsl:with-param name="resultUri" select="$topicResultUri" tunnel="yes"/>
          <xsl:with-param name="topicRelativeUri" select="$topicRelativeUri" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="*[df:class(., 'topic/topic')]" mode="generate-json-content">
    <!-- This template generates the output file for a referenced topic.
    -->
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>
    <!-- The topicref that referenced the topic -->
    <xsl:param name="topicref" as="element()*" tunnel="yes"/>
    <!-- Enumerables structure: -->
    <xsl:param name="collected-data" as="element()" tunnel="yes"/>

    <xsl:param name="baseUri" as="xs:string" tunnel="yes"/>
    <!-- Result URI to which the document should be written. -->
    <xsl:param name="resultUri" as="xs:string" tunnel="yes"/>

    <xsl:variable name="docUri" select="relpath:toUrl(@xtrf)" as="xs:string"/>
    <xsl:variable name="parentDocUri" select="relpath:getParent($resultUri)" as="xs:string"/>

    <xsl:variable name="parentPath" select="$outdir" as="xs:string"/>
    <!--xsl:variable name="parentPath" select="relpath:getParent($baseUri)" as="xs:string"/-->
    <xsl:variable name="relativePath" select="concat(relpath:getRelativePath($parentDocUri, $parentPath), '')"
      as="xs:string"/>
      
    <xsl:message> + [INFO] Writing topic <xsl:sequence select="document-uri(root(.))"/> to json file "<xsl:sequence
        select="$resultUri"/>"...</xsl:message>

    <xsl:result-document format="json" href="{$resultUri}">
     <xsl:value-of select="json:generate(.)"/>
     </xsl:result-document>
  </xsl:template>

 



</xsl:stylesheet>
