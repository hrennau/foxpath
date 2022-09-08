<?xml version="1.0" encoding="UTF-8" ?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<!--
  Extends the default XHTML processing and applies some patches. 
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:File="java:java.io.File" 
  xmlns:oxygen="http://www.oxygenxml.com/functions"
  exclude-result-prefixes="File oxygen">

  <xsl:import href="plugin:org.dita.xhtml:xsl/dita2xhtml.xsl"/>
  <xsl:import href="rel-links.xsl"/>
  <xsl:import href="../util/functions.xsl"/>  
  <xsl:import href="../util/dita-utilities.xsl"/>
  
  <xsl:param name="WEBHELP_TRIAL_LICENSE" select="'no'"/>
  <xsl:param name="WEBHELP_PRODUCT_ID" select="''"/>
  <xsl:param name="WEBHELP_PRODUCT_VERSION" select="''"/>
  
  <xsl:param name="BASEDIR"/>
  <xsl:param name="OUTPUTDIR"/>
  <xsl:param name="LANGUAGE" select="'en-us'"/>
  
  <xsl:output 
            method="xhtml" 
            encoding="UTF-8"
            indent="no"
            doctype-public=""
            doctype-system="about:legacy-compat"
            omit-xml-declaration="yes"/>


  <!-- Transforms oXygen change tracking and review elements to html elements. -->
  <xsl:include href="../review/review-elements-to-html.xsl"/>
  
  <!--  Header navigation.  -->
  <xsl:template match="/|node()|@*" mode="gen-user-header">    
      <!-- Navigation to the next, previous siblings and to the parent. -->
      <span id="topic_navigation_links" class="navheader">              
        <xsl:if test="$NOPARENTLINK = 'no'">
          <xsl:for-each
            select="descendant::*[contains(@class, ' topic/link ')]
            [@role='parent' or @role='previous' or @role='next']">
            <xsl:text>&#10;</xsl:text>
            <xsl:variable name="cls">
              <xsl:choose>
                <xsl:when test="@role = 'parent'">
                  <xsl:text>navparent</xsl:text>
                </xsl:when>
                <xsl:when test="@role = 'previous'">
                  <xsl:text>navprev</xsl:text>
                </xsl:when>
                <xsl:when test="@role = 'next'">
                  <xsl:text>navnext</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>nonav</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <span>
              <xsl:attribute name="class">
                <xsl:value-of select="$cls"/>
              </xsl:attribute>
              <xsl:variable name="textLinkBefore">
                <span class="navheader_label">
                  <xsl:choose>
                    <xsl:when test="@role = 'parent'">
                      <xsl:call-template name="getWebhelpString">
                        <xsl:with-param name="stringName" select="'Parent topic'"/>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="@role = 'previous'">
                      <xsl:call-template name="getWebhelpString">
                        <xsl:with-param name="stringName" select="'Previous topic'"/>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="@role = 'next'">
                      <xsl:call-template name="getWebhelpString">
                        <xsl:with-param name="stringName" select="'Next topic'"/>
                      </xsl:call-template>
                    </xsl:when>
                  </xsl:choose>
                </span>
                <span class="navheader_separator">
                  <xsl:text>: </xsl:text>
                </span>
              </xsl:variable>
              <xsl:call-template name="makelink">
                <xsl:with-param name="label" select="$textLinkBefore"/>
              </xsl:call-template>
            </span>
            <xsl:text>  </xsl:text>
          </xsl:for-each>
        </xsl:if>
      </span>
  </xsl:template>  
  
  
  <!--  Finds all index terms and adds them to the meta element 'indexterms'. (EXM-20576)  -->
    <xsl:template match="*" mode="gen-keywords-metadata">
      <xsl:variable name="indexterms-content">
          <xsl:for-each select="descendant::*[contains(@class,' topic/keywords ')]//*[contains(@class,' topic/indexterm ')]">
              <xsl:value-of select="normalize-space(text()[1])"/>
              <xsl:if test="position() &lt; last()"><xsl:text>, </xsl:text></xsl:if>
          </xsl:for-each>
      </xsl:variable>
      <xsl:if test="string-length($indexterms-content)>0">
          <meta name="indexterms" content="{$indexterms-content}"/>
          <xsl:value-of select="$newline"/>
      </xsl:if>
      <xsl:apply-imports/>
  </xsl:template>
    
  <!-- EXM-31518 Generate something for learning and training lcTime -->
  <xsl:template match="*[contains(@class, ' learningBase/lcTime ')]">
    <span>
      <xsl:call-template name="commonattributes"/>
      <b>Time: </b>
      <xsl:choose>
        <xsl:when test="empty(node())">
          <xsl:value-of select="@value"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>
  
  <!--EXM-32868 Allow data- attributes to pass through -->
  <xsl:template match="@*[starts-with(name(), 'data-')]" mode="add-xhtml-ns" priority="20">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  
  <!-- 
    WH-1485: Add a wrapper for simple tables, in order to avoid
    wide tables overflowing the topic content area. 
  -->
  <xsl:template match="*[contains(@class, ' topic/simpletable ')]">
    <div class="simpletable-container">
      <xsl:next-match/>
    </div>
  </xsl:template>
  
  <!-- the path back to the project. Used for c.gif, delta.gif, css to allow user's to have
     these files in 1 location. -->
  <xsl:param name="PATH2PROJ">
    <!-- OXYGEN PATCH START  EXM-30937 -->
    <xsl:choose>
      <xsl:when test="/processing-instruction('path2project-uri')">        
        <xsl:apply-templates select="/processing-instruction('path2project-uri')[1]" mode="get-path2project"/>
      </xsl:when>
      <xsl:when test="/processing-instruction('path2project')">
        <xsl:apply-templates select="/processing-instruction('path2project')[1]" mode="get-path2project"/>
      </xsl:when>
    </xsl:choose>
    <!-- OXYGEN PATCH END  EXM-30937 -->
  </xsl:param>
  
</xsl:stylesheet>
