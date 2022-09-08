<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc"
    xmlns:oxygen="http://www.oxygenxml.com/functions"
    xmlns:index="http://www.oxygenxml.com/ns/webhelp/index"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="createMainFiles.xsl"/>
    <xsl:import href="common-mobile.xsl"/>

    <!-- Using the "mobile skin "-->
    <xsl:template name="get-skin-name">
        <xsl:param name="withFrames"/> mobile </xsl:template>


    <!-- Inhibit the creation of the TOC for the frames version. -->
    <xsl:template name="create-toc-frames-file">
        <xsl:param name="toc"/>
        <xsl:param name="title"/>
        <!-- Do nothing. -->
    </xsl:template>

    <xsl:template name="create-navigation">
        <xsl:param name="selected"/>
        <xsl:param name="title"/>

            <div data-role="navbar">
                <ul>
                    <li><a href="#tocPage" data-role="tab" data-icon="grid" aria-selected="true">
                        <xsl:if test="$selected = 'tocPage'">
                            <xsl:attribute name="class">ui-btn-active</xsl:attribute>
                        </xsl:if>
                        <xsl:for-each select="/*">
                                <xsl:call-template name="getWebhelpString">
                                    <xsl:with-param name="stringName" select="'webhelp.content'"/>
                                </xsl:call-template>
                        </xsl:for-each>
                        </a></li>
                    <li><a href="#searchPage" data-role="tab" data-icon="search" aria-selected="false">
                        <xsl:if test="$selected = 'searchPage'">
                            <xsl:attribute name="class">ui-btn-active</xsl:attribute>
                        </xsl:if>
                        <xsl:for-each select="/*">
                            <xsl:call-template name="getWebhelpString">
                                <xsl:with-param name="stringName" select="'webhelp.search'"/>
                            </xsl:call-template>
                        </xsl:for-each>
                        </a></li>
                    <xsl:if test="count($index/*) > 0">
                        <li><a href="#indexPage" data-role="tab" data-icon="info" aria-selected="false">
                            <xsl:if test="$selected = 'indexPage'">
                                <xsl:attribute name="class">ui-btn-active</xsl:attribute>
                            </xsl:if>
                            <xsl:for-each select="/*">
                                    <xsl:call-template name="getWebhelpString">
                                        <xsl:with-param name="stringName" select="'Index'"/>
                                    </xsl:call-template>
                            </xsl:for-each>
                            </a></li>
                    </xsl:if>
                </ul>                                 
            </div>
        
    </xsl:template>

    <!-- 
    Common part for TOC creation.
  -->
    <xsl:template name="create-toc-common-file">
        <xsl:param name="toc"/>
        <xsl:param name="title" as="node()"/>
        <xsl:param name="fileName"/>
        <!-- toc.xml pt frame-uri, index.html pentru no frames.-->
        <xsl:param name="withFrames" as="xs:boolean"/>

        <xsl:result-document 
                href="{$fileName}" 
                method="xhtml" 
                indent="no" 
                encoding="UTF-8"
                doctype-system="about:legacy-compat"
                omit-xml-declaration="yes" 
                exclude-result-prefixes="#all">
            <html>
                <xsl:call-template name="setTopicLanguage"/>
                <head>
                    <title>
                        <xsl:value-of select="$title"/>
                    </title>
                    <xsl:call-template name="jsAndCSS">
                      <xsl:with-param name="namespace" select="''"/>
                    </xsl:call-template>
                </head>
                <body>
                    <xsl:if test="not($withFrames)">
                        <!-- Custom JavaScript code set by param webhelp.body.script -->
                        <xsl:call-template name="jsInBodyStart"/>
                    </xsl:if>
                    <!-- toc -->
                    <div data-role="page">
                        <div data-role="header" data-theme="c">
                            <xsl:if test="$fileName != 'index.html'">
                                <xsl:attribute name="data-position" select="'value'"/>
                            </xsl:if>
                            <h1><xsl:copy-of select="$title"/></h1>            
                        </div>
                        <div data-role="tabs" >
                          <xsl:call-template name="create-navigation">
                              <xsl:with-param name="selected" select="'tocPage'"/>
                              <xsl:with-param name="title" select="$title"/>
                          </xsl:call-template>
                          
                          <div id="tocPage" role="tabpanel" >
                              <div data-role="content">
                                  <ul data-role="listview" data-theme="c">
                                      <xsl:apply-templates select="$toc/toc:topic" mode="create-toc"/>
                                  </ul>
                              </div>
                          </div>
                          
                          <!-- search -->
                          <div id="searchPage" role="tabpanel">
                              <div data-role="content">
                                  <!-- The .blur function hides the virtual keyboard. -->
                                  <form name="searchForm" id="searchForm" 
                                      action="javascript:void(0)" 
                                      onsubmit="return executeQuery(this);">
                                      <xsl:for-each select="/*">
                                              <xsl:call-template name="getWebhelpString">
                                                  <xsl:with-param name="stringName" select="'webhelp.search'"/>
                                              </xsl:call-template>
                                      </xsl:for-each>
                                      <xsl:text>: </xsl:text>
                                      <xsl:comment/>
                                      <input type="text" id="textToSearch" name="textToSearch" class="textToSearch" size="30"/>
                                      <xsl:comment/>
                                      <xsl:variable name="searchLabel">
                                          <xsl:for-each select="/*">
                                                  <xsl:call-template name="getWebhelpString">
                                                      <xsl:with-param name="stringName" select="'webhelp.search'"/>
                                                  </xsl:call-template>
                                          </xsl:for-each>
                                      </xsl:variable>
                                      <input type="submit" value="{$searchLabel}" name="Search"
                                          class="searchButton"/>
                                  </form>
                                  <div id="searchResults">
                                      <xsl:comment/>
                                      <!-- Google Custom Search code set by param webhelp.search.result -->
                                      <xsl:choose>
                                          <xsl:when test="string-length($WEBHELP_SEARCH_RESULT) > 0 and string-length($WEBHELP_SEARCH_SCRIPT) > 0">
                                              <xsl:value-of select="unparsed-text($WEBHELP_SEARCH_RESULT)" disable-output-escaping="yes"/>
                                          </xsl:when>
                                          <xsl:otherwise>
                                              <xsl:if test="string-length($WEBHELP_SEARCH_SCRIPT) > 0">
                                                  <xsl:text disable-output-escaping="yes">&lt;gcse:searchresults-only linkTarget=&quot;frm&quot;&gt;&lt;/gcse:searchresults-only&gt;</xsl:text>
                                              </xsl:if>
                                          </xsl:otherwise>
                                      </xsl:choose>
                                  </div>
                              </div>
                          </div>
                          
                          <!-- index -->
                          <xsl:if test="count($index/*) > 0">
                              <div id="indexPage"  role="tabpanel">
                                  <div data-role="content">
                                      <xsl:apply-templates select="$index" mode="create-index"/>
                                  </div>
                              </div>
                          </xsl:if>
                          
                          <xsl:variable name="legalSection">
                              <xsl:call-template name="create-legal-section"/>
                          </xsl:variable>
                          <xsl:if test="count($legalSection/*) > 0">
                              <div data-role="footer">
                                  <xsl:copy-of select="$legalSection"/>
                              </div>                                                    
                          </xsl:if>
                        </div>
                    </div>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <!-- 
        Recursive generation of the TOC. Only top level links are displayed - level 1 chapters, 
        with one exception: topic groups. 
    -->
    <xsl:template match="toc:topic" mode="create-toc">
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="toc:title">
                    <xsl:apply-templates select="toc:title/node()" mode="copy-xhtml-without-links"/>
                </xsl:when>
                <xsl:when test="@title">
                    <xsl:value-of select="@title"/>
                </xsl:when>
                <xsl:when test="@navtitle">
                    <xsl:value-of select="@navtitle"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <li>
            <xsl:if test="@outputclass">
                <xsl:attribute name="class"><xsl:value-of select="@outputclass"/></xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="@href">
                    <a href="{if (contains(@href, '#')) then substring-before(@href, '#') else @href}" 
                            onclick="return true;">
                        <xsl:if test="@scope='external' or @scope='peer'">
                            <xsl:attribute name="target">_blank</xsl:attribute>
                        </xsl:if>
                        <xsl:if test="@data-id">
                            <xsl:attribute name="data-id" select="@data-id"/>
                        </xsl:if>
                        <xsl:copy-of select="$title"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$title"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="toc:topic and @href='javascript:void(0)'">
                <!-- Descend into the the child topics only if the parent does not have a norma HREF (is a topic group) -->
                <ul>
                    <xsl:apply-templates select="toc:topic" mode="create-toc"/>
                </ul>
            </xsl:if>
        </li>
    </xsl:template>

    <!-- Change from a hierarchy to a flat list.-->
    <xsl:template match="index:index" mode="create-index">
        <ul id="indexList" data-role="listview" data-filter="true">
            <xsl:for-each select="//index:target">
                <li>
                <a href="{.}">
                    <xsl:for-each select="ancestor-or-self::index:term">
                        <xsl:value-of select="@name" />
                        <xsl:if test="position() != last()">, </xsl:if>
                    </xsl:for-each> 
                </a>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>
    
    
    <xsl:template name="customBodyScriptMobile">
        <!-- Custom JavaScript code set by param webhelp.body.script -->
    </xsl:template>
    
    
    <xsl:template name="customHeadScriptMobile">
        <!-- Custom JavaScript code set by param webhelp.head.script -->
    </xsl:template>    
</xsl:stylesheet>
