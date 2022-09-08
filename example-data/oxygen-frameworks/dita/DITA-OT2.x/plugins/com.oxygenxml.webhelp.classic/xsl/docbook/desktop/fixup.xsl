<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
            xmlns="http://www.w3.org/1999/xhtml"
            xmlns:xhtml="http://www.w3.org/1999/xhtml" 
            xmlns:saxon="http://icl.com/saxon"    
            exclude-result-prefixes="saxon xhtml"
            version="1.0">

  <xsl:import href="../../dita/desktop/common.xsl"/>
  
  <!-- 
    Flag indicating the output is feedback enabled. 
  -->
  <xsl:variable name="IS_FEEDBACK_ENABLED" select="string-length($WEBHELP_PRODUCT_ID) > 0"/>
  
  <!-- 
    Instead of overriding docbook header.navigation template, we add the permalink 
    and navigation directly. 
  -->
  
  <!-- 
    Adds the permalink in each page.
  -->
  <xsl:template match="xhtml:table[@class='docbookNav']/xhtml:tr/xhtml:th[@colspan='3']" mode="fixup_desktop">
    <xsl:copy>
      <xsl:apply-templates mode="fixup_desktop"/>
      <div id="printlink"> 	 
        <a href="javascript:window.print();"> 	 
          <xsl:call-template name="getWebhelpString"> 	 
            <xsl:with-param name="stringName" select="'printThisPage'"/> 	 
          </xsl:call-template> 	 
        </a> 	 
      </div>
      <div id="permalink"><a href="#">
        <xsl:call-template name="getWebhelpString">
          <xsl:with-param name="stringName" select="'linkToThis'"/>
        </xsl:call-template>
      </a></div>
    </xsl:copy>
  </xsl:template>
  
  <!-- 
    Adds search form in each page.
  -->
  <xsl:template match="xhtml:div[@class='navheader']/xhtml:table" mode="fixup_desktop">
    <xsl:copy >
      <xsl:copy-of select="@*"/>
      <tr>
        <td colspan="3">
          <form name="searchForm" id="searchForm" action="javascript:void(0)"
            onsubmit="parent.tocwin.SearchToc(this);">
            <xsl:comment/>
            <xsl:variable name="searchLabel">
              <xsl:for-each select="/*">
                <xsl:call-template name="getWebhelpString">
                  <xsl:with-param name="stringName" select="'webhelp.search'"/>
                </xsl:call-template>
              </xsl:for-each>
            </xsl:variable>
            
            <input type="text" id="textToSearch" name="textToSearch" class="textToSearch"
              size="30" placeholder="{$searchLabel}"/>
            <xsl:comment/>
          </form>
        </td>
      </tr>
      <xsl:apply-templates mode="fixup_desktop"/>  
    </xsl:copy>
  </xsl:template>
  
  
  <xsl:template match="xhtml:td/xhtml:a[@accesskey='p']" mode="fixup_desktop">
    <span class="navprev">
      <xsl:copy>
        <xsl:apply-templates select="node() | @*" mode="fixup_desktop"/>
      </xsl:copy>
    </span>
  </xsl:template>  
  
  
  <xsl:template match="xhtml:td/xhtml:a[@accesskey='n']" mode="fixup_desktop">
    <span class="navnext">
      <xsl:copy>
        <xsl:apply-templates select="node() | @*" mode="fixup_desktop"/>
      </xsl:copy>
    </span>
  </xsl:template>
  
  
  <!-- 
    Adds body attributes. 
  -->
    <xsl:template match="xhtml:body" mode="fixup_desktop">
    <xsl:copy>
      <xsl:if test="not($IS_FEEDBACK_ENABLED)">
        <xsl:attribute name="onload">highlightSearchTerm()</xsl:attribute>
      </xsl:if>
      <xsl:attribute name="class">frmBody</xsl:attribute>
      <xsl:apply-templates select="node() | @*" mode="fixup_desktop"/>
      
      <!-- Injects the feedback div. -->
      <xsl:call-template name="generateFeedbackDiv"/>      
    </xsl:copy>
  </xsl:template>
  
  
  <!--
    Rewrites the head section.
   -->
  <xsl:template match="xhtml:head" mode="fixup_desktop">
    <head>
      <!-- All default metas.-->
      <xsl:apply-templates select="node() | @*" mode="fixup_desktop"/>
      <xsl:text xml:space="preserve">        
      </xsl:text>
      <xsl:call-template name="jsAndCSS">
        <xsl:with-param name="namespace" select="'http://www.w3.org/1999/xhtml'"/>
      </xsl:call-template>
    </head>
  </xsl:template>
  
  <xsl:template name="customHeadScript"/>
  
  
  <!-- 
    Generic copy. 
  -->
  <xsl:template match="node() | @*" mode="fixup_desktop">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="fixup_desktop"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!--
    <xsl:template match="/">
        <xsl:apply-templates mode="fixup_desktop"/>
    </xsl:template>
  -->
  
</xsl:stylesheet>