<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc"
  xmlns:index="http://www.oxygenxml.com/ns/webhelp/index" xmlns:File="java:java.io.File"
  xmlns:oxygen="http://www.oxygenxml.com/functions" xmlns:d="http://docbook.org/ns/docbook"
  xmlns:whc="http://www.oxygenxml.com/webhelp/components"
  xmlns="http://www.w3.org/1999/xhtml"    
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:html="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all" version="2.0">
  
  <xsl:import href="mainPageLinks.xsl"/> 
  
  <!--
    Template used to expand the whc:webhelp_tiles component.
  -->
  <xsl:template match="whc:webhelp_tiles" mode="copy_template">
    <xsl:if test="oxygen:getParameter('webhelp.show.main.page.tiles') = 'yes'">
      <div>
        <xsl:call-template name="generateComponentClassAttribute">
          <xsl:with-param name="compClass">wh_tiles</xsl:with-param>
        </xsl:call-template>
        <xsl:copy-of select="@* except @class"/>
        
        <xsl:apply-templates select="$toc" mode="create-tiles">
          <xsl:with-param name="tileTemplate" select="whc:webhelp_tile"/>
        </xsl:apply-templates>        
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="html:html" mode="copy_template">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="lang" select="oxygen:getParameter('webhelp.language')"/>
      <xsl:attribute name="dir" select="oxygen:getParameter('webhelp.page.direction')"/>
      
      <!-- Copy elements -->
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Inghibit output of text in the navigation tree. -->
  <xsl:template match="text()" mode="create-tiles"/>
  
  <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
    <xd:desc>
      Used to output a TOC entry for each topic.
    </xd:desc>
    
    <xd:param name="tileTemplate">The template for generating the main page tile.</xd:param>
  </xd:doc>
  <xsl:template match="toc:topic" mode="create-tiles">
    <xsl:param name="tileTemplate"/>
    
    <xsl:variable name="title" select="oxygen:getTopicTitle(.)"/>
    <xsl:choose>
      <xsl:when test="$tileTemplate">
        <xsl:apply-templates select="$tileTemplate" mode="copy_tile_template">
          <xsl:with-param name="title" select="$title"/>
          <xsl:with-param name="cTopic" select="."/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="oxygen:shouldDisplayTile(.)">
          <div>
            <xsl:variable name="tileOutputClass" select="toc:topicmeta/toc:data[@name='wh-tile']/@outputclass"/>
            <xsl:choose>
              <xsl:when test="$tileOutputClass">
                <xsl:attribute name="class" select="concat(' wh_tile ', $tileOutputClass)">                  
                </xsl:attribute>  
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="class" select="' wh_tile '"/>
              </xsl:otherwise>
            </xsl:choose>
            
            
            <xsl:call-template name="generateTileImage">
              <xsl:with-param name="cTopic" select="."/>
              <xsl:with-param name="title" select="$title"/>
            </xsl:call-template>
            
            <div class=" wh_tile_title ">
              <xsl:call-template name="createTOCContent">
                <xsl:with-param name="cTopic" select="."/>
                <xsl:with-param name="title" select="$title"/>
              </xsl:call-template>
            </div>
            
            <xsl:if test="toc:shortdesc">
              <div class=" wh_tile_shortdesc ">
                <xsl:apply-templates select="toc:shortdesc/node()"/>
              </div>
            </xsl:if>
            
          </div>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--
    Template used to generate the image for the main page tile. 
   -->
  <xsl:template name="generateTileImage">
    <xsl:param name="title"/>
    <xsl:param name="cTopic"/>
    <xsl:param name="imageTemplateElem" as="element()*"/>
    
    <xsl:variable 
      name="dataImage" 
      select="$cTopic/toc:topicmeta/toc:data[@name='wh-tile']/toc:data[@name='image'][@href]"/>
    <xsl:if test="$dataImage">
      <div>
        <xsl:choose>
          <xsl:when test="exists($imageTemplateElem) and $imageTemplateElem/@class">
            <xsl:attribute name="class" select="concat('wh_tile_image', ' ', $imageTemplateElem/@class)"
            />
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="class"> wh_tile_image </xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>

        <img src="{concat($PATH2PROJ, $dataImage[1]/@href)}" alt="{$title}">
          <xsl:variable name="attrWidth" select="$dataImage/toc:data[@name = 'attr-width'][@value]"/>
          <xsl:if test="$attrWidth">
            <xsl:attribute name="width" select="$attrWidth/@value"/>
          </xsl:if>
          
          <xsl:variable name="attrHeight" select="$dataImage/toc:data[@name = 'attr-height'][@value]"/>
          <xsl:if test="$attrHeight">
            <xsl:attribute name="height" select="$attrHeight/@value"/>
          </xsl:if>
        </img>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="node() | @*" mode="copy_tile_template">
    <xsl:param name="title"/>
    <xsl:param name="cTopic"/>  
    
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="copy_tile_template">
        <xsl:with-param name="title" select="$title"/>
        <xsl:with-param name="cTopic" select="$cTopic"/>          
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <!-- Test if a tile will be outputed for a topic -->
  <xsl:function name="oxygen:shouldDisplayTile" as="xs:boolean">
    <xsl:param name="cTopic"/>
    
    <xsl:value-of select="not($cTopic/toc:topicmeta/toc:data[@name='wh-tile']/toc:data[@name='hide']/@value = 'yes')"/>
  </xsl:function>
  
  <!--
    Template used to expand the whc:webhelp_tile component.
  -->
  <xsl:template match="whc:webhelp_tile" mode="copy_tile_template">
    <xsl:param name="title"/>
    <xsl:param name="cTopic"/>  
    
    <!-- Test if tile will be included in the output -->
    <xsl:if test="oxygen:shouldDisplayTile($cTopic)">
      <div>        
        <xsl:call-template name="generateComponentClassAttribute">
          <xsl:with-param name="compClass" 
            select="concat(
              'wh_tile ', 
              $cTopic/toc:topicmeta/toc:data[@name='wh-tile']/@outputclass)"/>
        </xsl:call-template>      
  
        <!-- Copy the topic ID to an attribute, so we can style it later from CSS. -->
        <xsl:if test="$cTopic/@data-id">
          <xsl:attribute name="data-id" select="$cTopic/@data-id"/>   
        </xsl:if>
        
        
        <xsl:copy-of select="@* except @class"/>
        
        <xsl:if test="@outputclass">
          <xsl:attribute name="class">
            <xsl:value-of select="@outputclass"/>
          </xsl:attribute>
        </xsl:if>
        
        <xsl:apply-templates mode="copy_tile_template">
          <xsl:with-param name="title" select="$title"/>
          <xsl:with-param name="cTopic" select="$cTopic"/>
        </xsl:apply-templates>        
      </div>
    </xsl:if>
    
  </xsl:template>
  
  <!--
    Template used to expand the whc:webhelp_tile component.
  -->
  <xsl:template match="whc:webhelp_tile_title" mode="copy_tile_template">
    <xsl:param name="title"/>
    <xsl:param name="cTopic"/>
    
    <div>
      <xsl:call-template name="generateComponentClassAttribute">
        <xsl:with-param name="compClass">wh_tile_title</xsl:with-param>
      </xsl:call-template>      
      <xsl:copy-of select="@* except @class"/>
      
      <xsl:call-template name="createTOCContent">
        <xsl:with-param name="cTopic" select="$cTopic"/>
        <xsl:with-param name="title" select="$title"/>
      </xsl:call-template>
              
    </div>
  </xsl:template>
  
  <!-- Skip template comments -->    
  <xsl:template match="comment()" mode="copy_tile_template" priority="10"/>
  
  <!--
    Template used to expand the whc:webhelp_tile component.
  -->
  <xsl:template match="whc:webhelp_tile_shortdesc" mode="copy_tile_template">
    <xsl:param name="title"/>
    <xsl:param name="cTopic"/>
    
    <xsl:call-template name="generateTopicShortDesc">
      <xsl:with-param name="cTopic" select="$cTopic"/>
      <xsl:with-param name="class" select="'wh_tile_shortdesc'"/>
    </xsl:call-template>
  </xsl:template>
  
  <!--
    Generate short description for a topic
  -->
  <xsl:template name="generateTopicShortDesc">
    <xsl:param name="cTopic"/>
    <xsl:param name="class" select="'wh_tile_shortdesc'"/>
    <xsl:if test="$cTopic/toc:shortdesc">
      <div>
        <xsl:call-template name="generateComponentClassAttribute">
          <xsl:with-param name="compClass" select="$class"></xsl:with-param>
        </xsl:call-template>
        <xsl:copy-of select="@* except (@class | @wh-toc-id)"/>
        <xsl:apply-templates select="$cTopic/toc:shortdesc"/>
      </div>
    </xsl:if>
  </xsl:template>
  
  <!--
    Template used to expand the whc:webhelp_tile component.
  -->
  <xsl:template match="whc:webhelp_tile_image" mode="copy_tile_template">
    <xsl:param name="title"/>
    <xsl:param name="cTopic"/>    
    
    <xsl:call-template name="generateTileImage">
      <xsl:with-param name="cTopic" select="$cTopic"/>
      <xsl:with-param name="title" select="$title"/>
      <xsl:with-param name="imageTemplateElem" select="."/>
    </xsl:call-template>
    
  </xsl:template>
  
  <!--
    Template used to expand the whc:webhelp_tiles component.
  -->
  <xsl:template match="whc:webhelp_main_page_toc" mode="copy_template">
    <xsl:if test="oxygen:getParameter('webhelp.show.main.page.toc') = 'yes'">
      
      <xsl:variable name="main_page_toc">
        <div>
          <xsl:call-template name="generateComponentClassAttribute">
            <xsl:with-param name="compClass">wh_main_page_toc</xsl:with-param>
          </xsl:call-template>
          <xsl:copy-of select="@* except @class"/>
          
          <xsl:apply-templates select="$toc" mode="create-main-page-toc">
            <xsl:with-param name="applyRecursion" select="true()"/>
          </xsl:apply-templates>
        </div>
      </xsl:variable>
      
      <xsl:call-template name="outputComponentContent">
        <xsl:with-param name="compContent" select="$main_page_toc"/>
        <xsl:with-param name="compName" select="local-name()"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <!-- Inghibit output of text in the navigation tree. -->
  <xsl:template match="text()" mode="create-main-page-toc"/>
  
  <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
    <xd:desc>
      Used to output a TOC entry for each topic.
    </xd:desc>
  </xd:doc>
  <xsl:template match="toc:topic" mode="create-main-page-toc">
    <xsl:param name="applyRecursion" select="false()"/>
    
    <xsl:variable name="title" select="oxygen:getTopicTitle(.)"/>
    <xsl:variable name="hasChildTopics" select="count(toc:topic) > 0"/>
    
    <xsl:choose>
      <xsl:when test="$applyRecursion and $hasChildTopics">
        <div class=" wh_main_page_toc_accordion_header ">          
          <xsl:call-template name="createTOCContent">
            <xsl:with-param name="cTopic" select="."/>
            <xsl:with-param name="title" select="$title"/>
          </xsl:call-template>
          <xsl:call-template name="generateTopicShortDesc">
            <xsl:with-param name="cTopic" select="."/>
            <xsl:with-param name="class" select="'wh_toc_shortdesc'"/>
          </xsl:call-template>          
        </div>
        <div class=" wh_main_page_toc_accordion_entries ">
          <xsl:apply-templates mode="#current"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <div class=" wh_main_page_toc_entry ">
          <xsl:call-template name="createTOCContent">
            <xsl:with-param name="cTopic" select="."/>
            <xsl:with-param name="title" select="$title"/>
          </xsl:call-template>
          
          <xsl:call-template name="generateTopicShortDesc">
            <xsl:with-param name="cTopic" select="."/>
            <xsl:with-param name="class" select="'wh_toc_shortdesc'"/>
          </xsl:call-template>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>