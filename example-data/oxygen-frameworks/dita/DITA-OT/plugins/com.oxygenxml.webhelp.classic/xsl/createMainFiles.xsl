<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc"
  xmlns:index="http://www.oxygenxml.com/ns/webhelp/index" xmlns:File="java:java.io.File"
  xmlns:oxygen="http://www.oxygenxml.com/functions" 
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">

  <!-- Localization of text strings displayed in Webhelp output. -->
  <xsl:import href="localization.xsl"/>
  <xsl:import href="functions.xsl"/>
  <xsl:import href="toc_common.xsl"/>
  <xsl:import href="dita/desktop/fixupNS.xsl"/>

  <xsl:include href="macroExpander.xsl"/>

  <!-- Triggers the display of the comments and change tracking -->
  <xsl:param name="show.changes.and.comments" select="'no'"/>
  
  <!-- The folder with the XHTML files -->
  <xsl:param name="XHTML_FOLDER"/>

  <!-- Folder with output files. -->
  <xsl:param name="OUTPUTDIR"/>

  <!-- Base folder of Webhelp module. -->
  <xsl:param name="BASEDIR"/>

  <!-- Default file extension for HTML output files. -->
  <xsl:param name="OUTEXT" select="'.html'"/>

  <!-- Language for localization of strings in output page. -->
  <xsl:param name="DEFAULTLANG">en-us</xsl:param>

  <!-- Copyright notice inserted by user that runs transform. -->
  <xsl:param name="WEBHELP_COPYRIGHT"/>

  <!-- Name of product displayed in title of email notification sent to users. -->
  <xsl:param name="WEBHELP_PRODUCT_NAME"/>

  <!-- 
     If this parameter is set to 'false' then the relevance stars are not 
     added anymore for the search results displayed on the Search tab.
     By default this parameter is set to true.
   -->
  <xsl:param name="WEBHELP_SEARCH_RANKING" select="'true'"/>

  <!-- Parameter used for computing the relative path of the topic. 
  	  In case of docbook, this should be empty. -->
  <xsl:param name="PATH2PROJ" select="''"/>

  <!-- The path of index.xml -->
  <xsl:param name="INDEX_XML_FILEPATH" select="'in/index.xml'"/>

  <!-- The path of toc.xml -->
  <xsl:param name="TOC_XML_FILEPATH" select="'in/toc.xml'"/>

  <!-- Custom CSS set in DITA-OT params for custom CSS. -->
  <xsl:param name="CSS" select="''"/>
  <xsl:param name="CSSPATH" select="''"/>

  <!-- CSS that is set as Webhelp skin in the DITA Webhelp transform. -->
  <xsl:param name="WEBHELP_SKIN_CSS" select="''"/>
  
  <!-- File path of image used as favicon -->
  <xsl:param name="WEBHELP_FAVICON" select="''"/>

  <!-- File path of image with the company logo. -->
  <xsl:param name="WEBHELP_LOGO_IMAGE" select="''"/>

  <!-- URL that will be opened when the logo image set with 
         the webhelp.logo.image parameter is clicked in the Webhelp page. -->
  <xsl:param name="WEBHELP_LOGO_IMAGE_TARGET_URL" select="''"/>

  <!-- Custom JavaScript code set by param webhelp.head.script -->
  <xsl:param name="WEBHELP_HEAD_SCRIPT" select="''"/>

  <!-- Google Custom Search code set by param webhelp.search.script -->
  <xsl:param name="WEBHELP_SEARCH_SCRIPT" select="''"/>

  <!-- Google Custom Search code set by param webhelp.search.results -->
  <xsl:param name="WEBHELP_SEARCH_RESULT" select="''"/>

  <!-- Custom JavaScript code set by param webhelp.body.script -->
  <xsl:param name="WEBHELP_BODY_SCRIPT" select="''"/>

  <!-- Oxygen version that created the WebHelp pages. -->
  <xsl:param name="WEBHELP_VERSION"/>

  <!-- 
    An unique(timestamp) ID for the current WebHelp transformation 
  -->
  <xsl:param name="WEBHELP_UNIQUE_ID"/>
  
  <!-- 
    Current oXygen build number. 
  -->
  <xsl:param name="WEBHELP_BUILD_NUMBER"/>
  

  <!-- Loads the additional XML documents. -->
  <xsl:variable name="index" select="document(oxygen:makeURL($INDEX_XML_FILEPATH))/index:index"/>
  <xsl:variable name="toc" select="document(oxygen:makeURL($TOC_XML_FILEPATH))/toc:toc"/>

  <xsl:template match="/">
    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="$toc/toc:title">
          <xsl:apply-templates select="$toc/toc:title/node()" mode="copy-xhtml-without-links"/>
        </xsl:when>
        <xsl:when test="$toc/@title">
          <xsl:value-of select="$toc/@title"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="create-main-files">
      <xsl:with-param name="toc" select="$toc"/>
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
    <xsl:call-template name="create-localization-files"/>
  </xsl:template>


  <!-- Creates the set of main files: the TOC (for the version with 
    and without frames) and the index.html. Extracted to template 
    so it can be overriden from other stylesheets. -->
  <xsl:template name="create-main-files">
    <xsl:param name="toc"/>
    <xsl:param name="title"/>
    <xsl:call-template name="create-toc-frames-file">
      <xsl:with-param name="toc" select="$toc"/>
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
    <xsl:call-template name="create-toc-noframes-file">
      <xsl:with-param name="toc" select="$toc"/>
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
    <xsl:call-template name="create-index-file">
      <xsl:with-param name="toc" select="$toc"/>
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Creates the localization files. -->
  <xsl:template name="create-localization-files">
    <xsl:variable name="jsFileName" select="'oxygen-webhelp/resources/localization/strings.js'"/>
    <xsl:variable name="jsURL"
      select="concat(File:toURI(File:new(string($OUTPUTDIR))), $jsFileName)"/>
    <xsl:variable name="phpFileName" select="'oxygen-webhelp/resources/localization/strings.php'"/>
    <xsl:variable name="phpURL"
      select="concat(File:toURI(File:new(string($OUTPUTDIR))), $phpFileName)"/>
    <xsl:for-each select="/*">
      <xsl:call-template name="generateLocalizationFiles">
        <xsl:with-param name="jsURL" select="$jsURL"/>
        <xsl:with-param name="phpURL" select="$phpURL"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <!--
    Generates the content/search/index tabs.
  -->
  <xsl:template name="create-tabs-divs">
    <div id="tocMenu">
      <xsl:variable name="contentTabName">
        <xsl:for-each select="/*">
          <xsl:call-template name="getWebhelpString">
            <xsl:with-param name="stringName" select="'webhelp.content'"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:variable>
      <div class="tab" id="content" title="{$contentTabName}">
        <span onclick="showMenu('content')" id="content.label">
          <xsl:value-of select="$contentTabName"/>
        </span>
      </div>
      <xsl:variable name="searchTabName">
        <xsl:for-each select="/*">
          <xsl:call-template name="getWebhelpString">
            <xsl:with-param name="stringName" select="'SearchResults'"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:variable>
      <div class="tab" id="search" title="{$searchTabName}">
        <span onclick="showMenu('search')" id="search.label">
          <xsl:value-of select="$searchTabName"/>
        </span>
      </div>
      <xsl:if test="count($index/*) > 0">
        <xsl:variable name="indexTabName">
          <xsl:for-each select="/*">
            <xsl:call-template name="getWebhelpString">
              <xsl:with-param name="stringName" select="'webhelp.index'"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:variable>
        <div class="tab" id="index" title="{$indexTabName}">
          <span onclick="showMenu('index')" id="index.label">
            <xsl:value-of select="$indexTabName"/>
          </span>
        </div>
      </xsl:if>
    </div>
  </xsl:template>

  <!--
    Creates the TOC file for the version with frames.
  -->
  <xsl:template name="create-toc-frames-file">
    <xsl:param name="title"/>
    <xsl:param name="toc"/>
    <xsl:call-template name="create-toc-common-file">
      <xsl:with-param name="title" select="$title"/>
      <xsl:with-param name="toc" select="$toc"/>
      <xsl:with-param name="withFrames" select="true()"/>
      <xsl:with-param name="fileName" select="concat('toc', $OUTEXT)"/>
    </xsl:call-template>
  </xsl:template>

  <!-- 
    Creates the TOC file for the version with no frames. In fact this page will contain the entire content.
  -->
  <xsl:template name="create-toc-noframes-file">
    <xsl:param name="title"/>
    <xsl:param name="toc"/>
    <xsl:call-template name="create-toc-common-file">
      <xsl:with-param name="title" select="$title"/>
      <xsl:with-param name="toc" select="$toc"/>
      <xsl:with-param name="withFrames" select="false()"/>
      <xsl:with-param name="fileName" select="concat('index', $OUTEXT)"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Gets the name of the skin for the main file. -->
  <xsl:function name="oxygen:getSkinName" as="xs:string">
    <xsl:param name="withFrames"/>

    <xsl:variable name="skinName">
      <xsl:call-template name="get-skin-name">
        <xsl:with-param name="withFrames" select="$withFrames"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="normalize-space($skinName)"/>

  </xsl:function>

  <!-- Extracted to a template so it can be overriden from other stylesheets. -->
  <xsl:template name="get-skin-name">
    <xsl:param name="withFrames"/>
    <xsl:choose>
      <xsl:when test="$withFrames"> desktop-frames </xsl:when>
      <xsl:otherwise> desktop </xsl:otherwise>
    </xsl:choose>
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
    <!--true pentru frame-uri, false pentru no frames. -->

    <xsl:variable name="skinName" select="oxygen:getSkinName($withFrames)"/>

    <xsl:result-document href="{$fileName}" method="xhtml" indent="no" encoding="UTF-8"
      doctype-system="about:legacy-compat" omit-xml-declaration="yes" exclude-result-prefixes="#all">
      <html>

        <xsl:call-template name="setTopicLanguage">
          <xsl:with-param name="withFrames" select="$withFrames"/>
        </xsl:call-template>
        <head>

          <!-- Add the comment 'Generated with Oxygen build number....' -->
          <xsl:choose>
            <xsl:when test="contains($WEBHELP_VERSION, '$')">
              <xsl:comment>  Generated with Oxygen build number <xsl:value-of select="$WEBHELP_BUILD_NUMBER"/>.  </xsl:comment>
            </xsl:when>
            <xsl:otherwise>
              <xsl:comment>  Generated with Oxygen version <xsl:value-of select="$WEBHELP_VERSION"/>, build number <xsl:value-of select="$WEBHELP_BUILD_NUMBER"/>.  </xsl:comment>
            </xsl:otherwise>
          </xsl:choose>

          <!-- Page title -->
          <title>
            <xsl:value-of select="$title"/>
          </title>

          <!-- Various meta-information for browser -->
          <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
          <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>

          <script type="text/javascript">
              
              <xsl:if test="contains($fileName, 'index')">
                var withFrames=false;
              
                try {
                  var parentWindow = window.name;
                } catch (e) {
                  debug("Exception: " + e);
                }
                if (parentWindow == "frm" || parentWindow == "contentwin") {
                  var link = window.location.href; 
                  var firstAnchor = link.search("#");
                 
                  window.location.href = link.substr(0,firstAnchor) + link.substr(firstAnchor+1);
                }
              </xsl:if>
              <xsl:if test="contains($fileName, 'toc') and $withFrames">
                var withFrames=true;
              </xsl:if>
                var webhelpSearchRanking = <xsl:value-of select="$WEBHELP_SEARCH_RANKING"/>;
            </script>

          <!-- Specify where to open the links from TOC (needed only for frameset rendering) -->
          <xsl:if test="$withFrames">
            <base target="contentwin"/>
          </xsl:if>

          <!-- Link the favicon -->
          <xsl:if test="string-length($WEBHELP_FAVICON) > 0">
            <link rel="shortcut icon">
              <xsl:attribute name="href">
                <xsl:value-of select="$WEBHELP_FAVICON"/>
              </xsl:attribute>
              <xsl:comment/>
            </link>
            <link rel="icon">
              <xsl:attribute name="href">
                <xsl:value-of select="$WEBHELP_FAVICON"/>
              </xsl:attribute>
              <xsl:comment/>
            </link>
          </xsl:if>

          <!-- Add some CSS for custom rendering -->
          <link rel="stylesheet" type="text/css" href="oxygen-webhelp/resources/css/commonltr.css?buildId={$WEBHELP_BUILD_NUMBER}">
            <xsl:comment/>
          </link>
          <link rel="stylesheet" type="text/css" href="oxygen-webhelp/resources/css/toc.css?buildId={$WEBHELP_BUILD_NUMBER}">
            <xsl:comment/>
          </link>
          <link rel="stylesheet" type="text/css"
            href="oxygen-webhelp/resources/skins/{$skinName}/toc_custom.css?buildId={$WEBHELP_BUILD_NUMBER}">
            <xsl:comment/>
          </link>
          <link rel="stylesheet" type="text/css"
            href="oxygen-webhelp/resources/css/webhelp_topic.css?buildId={$WEBHELP_BUILD_NUMBER}">
            <xsl:comment/>
          </link>
          <xsl:if test="$show.changes.and.comments='yes'">
            <link rel="stylesheet" type="text/css"
              href="oxygen-webhelp/resources/css/p-side-notes.css?buildId={$WEBHELP_BUILD_NUMBER}">
              <xsl:comment/>
            </link>
          </xsl:if>

          <!-- Impose a Webhelp skin. -->
          <xsl:if test="string-length($WEBHELP_SKIN_CSS) > 0">
            <link rel="stylesheet" type="text/css" href="{$PATH2PROJ}{$WEBHELP_SKIN_CSS}?buildId={$WEBHELP_BUILD_NUMBER}">
              <xsl:comment/>
            </link>
          </xsl:if>
          
          <xsl:call-template name="generateCustomCSSLink"/>

          <!-- Add links to the JS files -->
          <xsl:call-template name="create-js-scripts">
            <xsl:with-param name="withFrames" select="$withFrames"/>
          </xsl:call-template>

          <!-- Imposes a skin. -->
          <script type="text/javascript" src="oxygen-webhelp/resources/skins/{$skinName}/toc_driver.js?buildId={$WEBHELP_BUILD_NUMBER}"><xsl:comment/></script>

        </head>
        
        
        <body onload="javascript:initializeTabsMenu();" style="overflow: hidden;">
          <noscript>
            <style type="text/css">
              #searchBlock,
              #preload,
              #indexBlock,
              #tocMenu{
                  display:none
              }
              
              #tab_nav_tree,
              #contentBlock ul li ul{
                  display:block;
              }
              #contentBlock ul li span{
                  padding:0px 5px 0px 5px;
              }
              #contentMenuItem:before{
                  content:"Content";
              }</style>
            <xsl:if test="not($withFrames)">
              <div style="width: 100%; vertical-align: middle; text-align: center; height: 100%;">
                <div style="position: absolute; top:45%; left:25%;width: 50%; "> You must enable
                  javascript in order to view this page or you can go <a
                    href="{concat('index_frames', $OUTEXT)}">here</a> to view the webhelp. </div>
              </div>
            </xsl:if>
          </noscript>
          
          <xsl:if test="not($withFrames)">
            <!-- Custom JavaScript code set by param webhelp.body.script -->
            <xsl:if test="string-length($WEBHELP_BODY_SCRIPT) > 0">
              <xsl:call-template name="includeCustomHTMLContent">
                <xsl:with-param name="hrefURL" select="$WEBHELP_BODY_SCRIPT"/>
              </xsl:call-template>
            </xsl:if>
          </xsl:if>

          <div id="header">
            <div id="lHeader">
              <div id="productTitle">
                
                <!-- Product LOGO -->
                <a id="customLogo">
                  <xsl:if test="string-length($WEBHELP_LOGO_IMAGE) > 0">
                    <xsl:attribute name="style">background-image:url('<xsl:value-of
                        select="$WEBHELP_LOGO_IMAGE"/>'); display:inline-block</xsl:attribute>
                  </xsl:if>
                  <xsl:if test="string-length($WEBHELP_LOGO_IMAGE_TARGET_URL) > 0">
                    <xsl:attribute name="href" select="$WEBHELP_LOGO_IMAGE_TARGET_URL"/>
                  </xsl:if>
                </a>
                
                <!-- Webhelp title taken from DITA or Docbook publication -->
                <h1>
                  <xsl:copy-of select="$title"/>
                </h1>
                
                <xsl:if test="not($withFrames)">
                  <div class="framesLink">
                    <!-- Print link. -->
                    <xsl:variable name="printLinkText">
                      <xsl:for-each select="/*">
                        <xsl:call-template name="getWebhelpString">
                          <xsl:with-param name="stringName" select="'printThisPage'"/>
                        </xsl:call-template>
                      </xsl:for-each>
                    </xsl:variable>
                    
                    <xsl:variable name="oldFramesLinkText">
                      <xsl:for-each select="/*">
                        <xsl:call-template name="getWebhelpString">
                          <xsl:with-param name="stringName" select="'oldFrames'"/>
                        </xsl:call-template>
                      </xsl:for-each>
                    </xsl:variable>
                    
                    <!-- Print link widget -->
                    <div id="printlink">
                      <a onclick="printFrame('frm')" title="{$printLinkText}"/>
                    </div>
                    
                    <!-- Switch between frame and frameless styles -->
                    <div>
                      <a href="{concat('index_frames', $OUTEXT)}" id="oldFrames"
                        title="{$oldFramesLinkText}"/>
                    </div>
                  </div>
                </xsl:if>
              </div>

              <!-- Table with breadcrumb, navigation buttons and content/index tabs-->
              <table class="tool" cellpadding="0" cellspacing="0">
                <tr>
                  <!-- Content/Search Result/Index tabs -->
                  <td>
                    <xsl:call-template name="create-tabs-divs"/>
                  </td>
                  
                  <td>
                    <!-- Breadcrumb  -->
                    <div id="productToolbar">
                      <div id="breadcrumbLinks">
                        <xsl:comment> </xsl:comment>
                      </div>
                      
                      <!-- Navigation buttons (Parent/Previous/Next buttons) -->
                      <div id="navigationLinks">
                        <xsl:comment> </xsl:comment>
                      </div>
                    </div>
                  </td>
                </tr>
              </table>
              
            </div>
            
            <!-- Horizontal space to separate header from content.  -->
            <div id="space">
              <xsl:comment/>
            </div>
          </div>
          
          <!-- Lower part with TOC and topic content -->
          <div id="splitterContainer">
            <!-- Left pane that displays TOC, Search Result and Index. -->
            <div id="leftPane">
              <div id="bck_toc">
                <!-- Section for displaying the Search Results -->
                <div id="searchBlock" style="display:none;">
                  <div id="searchResults">
                    <xsl:comment/>
                    <!-- Google Custom Search code set by param webhelp.search.result -->
                    <xsl:choose>
                      <xsl:when
                        test="string-length($WEBHELP_SEARCH_RESULT) > 0 and string-length($WEBHELP_SEARCH_SCRIPT) > 0">
                        <xsl:value-of select="unparsed-text($WEBHELP_SEARCH_RESULT)"
                          disable-output-escaping="yes"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:if test="string-length($WEBHELP_SEARCH_SCRIPT) > 0">
                          <xsl:text disable-output-escaping="yes">&lt;gcse:searchresults-only linkTarget=&quot;frm&quot;&gt;&lt;/gcse:searchresults-only&gt;</xsl:text>
                        </xsl:if>
                      </xsl:otherwise>
                    </xsl:choose>
                  </div>
                </div>
                
                <!-- Section for displaying a progress marker when search operation took a long time -->
                <div id="preload">
                  <xsl:if test="not($withFrames)">
                    <xsl:attribute name="style">display: none;</xsl:attribute>
                  </xsl:if>
                  <xsl:for-each select="/*">
                    <xsl:call-template name="getWebhelpString">
                      <xsl:with-param name="stringName" select="'Loading, please wait ...'"/>
                    </xsl:call-template>
                  </xsl:for-each>
                  <p>
                    <img src="oxygen-webhelp/resources/img/spinner.gif" alt="Loading"/>
                  </p>
                </div>
                
                <!-- Expand and Collapse widgets -->
                <div id="contentBlock">
                  <div id="tab_nav_tree_placeholder">
                    <div id="expnd">
                      <a href="javascript:void(0);" onclick="collapseAll();" id="collapseAllLink"
                        title="CollapseAll"> </a>
                      <a href="javascript:void(0);" onclick="expandAll();" id="expandAllLink"
                        title="ExpandAll"> </a>
                    </div>
                    <div id="tab_nav_tree" class="visible_tab">
                      <div id="tree">
                        <ul>
                          <xsl:apply-templates select="$toc" mode="create-toc"/>
                        </ul>
                      </div>
                    </div>
                  </div>
                </div>
                
                <!-- Index section -->
                <xsl:if test="count($index/*) > 0">
                  <div id="indexBlock" style="display:none;">
                    <form action="javascript:void(0)" id="indexForm">
                      <fieldset>
                        <xsl:variable name="localizedMessage">
                          <xsl:for-each select="/*">
                            <xsl:call-template name="getWebhelpString">
                              <xsl:with-param name="stringName" select="'IndexFilterPlaceholder'"/>
                            </xsl:call-template>
                          </xsl:for-each>
                        </xsl:variable>
                        <input type="text" name="search" value="" id="id_search"
                          placeholder="{$localizedMessage}"/>
                      </fieldset>
                    </form>
                    <div id="iList">
                      
                      <xsl:choose>
                        <xsl:when test="$withFrames">
                          <xsl:variable name="indexterms">
                                <script type="text/javascript">
                                  <xsl:comment> var indextermsLoaded=true; </xsl:comment>
                                </script>
                                <ul id="indexList">
                                  <xsl:apply-templates select="$index" mode="create-index"/>
                                </ul>
                          </xsl:variable>
                          <xsl:copy-of select="$indexterms"/>
                        </xsl:when>
                        <xsl:otherwise>                          
                          <xsl:variable name="indexterms">
                            <ul id="indexList">
                              <xsl:apply-templates select="$index" mode="create-index"/>
                            </ul>
                          </xsl:variable>
                          
                          <xsl:message>Write indexterm in file: oxygen-webhelp/indexterms.js</xsl:message>
                          
                          <xsl:variable name="indexTermsString">
                            var indexTerms = '<xsl:apply-templates select="$indexterms" mode="indexTermJS"/>';
                            
                            $("#indexBlock #iList").html(indexTerms);
                            
                            $('#indexList li a').each(function() {
                            var old = $(this).attr('href');
                            if (withFrames) {
                            $(this).attr('href', normalizeLink(old));
                            } else {
                            $(this).attr('href', '#' + normalizeLink(old));
                            $(this).removeAttr("target");
                            }
                            });
                          </xsl:variable>
                          
                          <xsl:result-document href="oxygen-webhelp/indexterms.js"
                            method="text" indent="yes" encoding="UTF-8" omit-xml-declaration="yes"
                            exclude-result-prefixes="#all">
                            <xsl:value-of select="normalize-space(translate($indexTermsString, '&#10;&#13;', ''))"/>
                          </xsl:result-document>
                        </xsl:otherwise>
                      </xsl:choose>
                    </div>
                  </div>
                </xsl:if>
              </div>
              
              <div class="footer">
                <xsl:call-template name="create-legal-section"/>
              </div>
            </div>
            
            <!-- Right pane with topic content -->
            <xsl:if test="not($withFrames)">
              <div id="rightPane">
                <iframe id="frm" src="./oxygen-webhelp/noScript.html" frameborder="0">
                  <p>Your browser does not support iframes.</p>
                </iframe>
              </div>
            </xsl:if>
          </div>
          
          <script type="text/javascript">
            <xsl:comment>
             $(function () {
                  $('input#id_search').keyup(function(){
                    $("ul#indexList li").hide();
                    if ($("input#id_search").val() != '' ) {
                      var sk=$("input#id_search").val();
                      $('ul#indexList').removeHighlight();
                      $('ul#indexList').highlight(sk,"highlight");

                      $("div:contains('"+sk+"')").each(function(){
                        if ($(this).parents("#indexList").length>0){                          
                          $(this).show();
                          $(this).parentsUntil('#indexList').show();
                          $(this).parent().find('ul').show();
                          if ($(this).find('a').length==0){
                            $(this).parent().find('ul li').show();                            
                          }                                                    
                        }
                      });
                    }else{
                      $("ul#indexList li").show();
                      $('ul#indexList').removeHighlight();
                    }
                  });
                });
              </xsl:comment>
          </script>
        </body>
      </html>
    </xsl:result-document>
  </xsl:template>
  
  <!-- Adds the legal stuff, the copyright and the legal notice. -->
  <xsl:template name="create-legal-section">
    <xsl:if
      test="
      $WEBHELP_COPYRIGHT != '' or
        string-length($toc/toc:copyright) > 0 or
        string-length($toc/toc:legalnotice) > 0
        ">
      <div class="legal">
        <div class="legalCopyright">
          <xsl:value-of select="$WEBHELP_COPYRIGHT"/>
          <xsl:if test="string-length($toc/toc:copyright) > 0">
            <br/>
            <xsl:copy-of select="$toc/toc:copyright/*"/>
          </xsl:if>
        </div>
        <xsl:if test="string-length($toc/toc:legalnotice) > 0">
          <div class="legalnotice">
            <xsl:copy-of select="$toc/toc:legalnotice/*"/>
          </div>
        </xsl:if>
      </div>
    </xsl:if>
  </xsl:template>
  
  <!-- 
    Generates the JS scripts. Extracted to template so it can be overriden from other stylesheet. 
  -->
  <xsl:template name="create-js-scripts" exclude-result-prefixes="#all">
    <xsl:param name="withFrames"/>
    <script type="text/javascript" src="oxygen-webhelp/resources/js/jquery-3.1.1.min.js"><xsl:comment/></script>
    <script type="text/javascript" src="{$PATH2PROJ}oxygen-webhelp/resources/js/jquery.cookie.js"><xsl:comment/></script>
    
    <xsl:if test="string-length($WEBHELP_SEARCH_SCRIPT) = 0">
      <script type="text/javascript" charset="utf-8" src="oxygen-webhelp/resources/js/jquery.highlight-3.js"><xsl:comment/></script>
      <script type="text/javascript" src="oxygen-webhelp/search/nwSearchFnt.js?uniqueId={$WEBHELP_UNIQUE_ID}"><xsl:comment/></script>
      <script type="text/javascript" src="oxygen-webhelp/search/searchCommon.js?buildId={$WEBHELP_BUILD_NUMBER}"><xsl:comment/></script>
      <script type="text/javascript" src="oxygen-webhelp/search/classic/search.js?buildId={$WEBHELP_BUILD_NUMBER}"><xsl:comment/></script>
      
      <xsl:variable name="LANG" select="lower-case(substring($DEFAULTLANG, 1, 2))"/>
      <xsl:if test="$LANG = 'en' or $LANG = 'fr' or $LANG = 'de'">
        <script type="text/javascript" src="oxygen-webhelp/search/stemmers/{$LANG}_stemmer.js?uniqueId={$WEBHELP_UNIQUE_ID}"><xsl:comment/></script>
      </xsl:if>

      <xsl:if test="$withFrames">
        <xsl:call-template name="create-search-js-scripts"/>
      </xsl:if>
    </xsl:if>
    <script type="text/javascript" charset="utf-8" src="oxygen-webhelp/resources/localization/strings.js?uniqueId={$WEBHELP_UNIQUE_ID}"><xsl:comment/></script>
    <script type="text/javascript" charset="utf-8" src="oxygen-webhelp/resources/js/localization.js?buildId={$WEBHELP_BUILD_NUMBER}"><xsl:comment/></script>
    <script src="./oxygen-webhelp/resources/js/browserDetect.js?buildId={$WEBHELP_BUILD_NUMBER}" type="text/javascript"><xsl:comment/></script>

    <script type="text/javascript" charset="utf-8" src="oxygen-webhelp/resources/js/parseuri.js?buildId={$WEBHELP_BUILD_NUMBER}"><xsl:comment/></script>
    <xsl:if test="not($withFrames)">
      <script type="text/javascript" charset="utf-8" src="oxygen-webhelp/resources/js/jquery.ba-hashchange.min.js"><xsl:comment/></script>
      <script type="text/javascript" src="oxygen-webhelp/resources/js/splitter.js?buildId={$WEBHELP_BUILD_NUMBER}"><xsl:comment/></script>
    </xsl:if>

    <script type="text/javascript" src="oxygen-webhelp/resources/js/log.js?buildId={$WEBHELP_BUILD_NUMBER}"><xsl:comment/></script>
    <script type="text/javascript" src="oxygen-webhelp/resources/js/toc.js?buildId={$WEBHELP_BUILD_NUMBER}"><xsl:comment/></script>
    
    
    <xsl:message> --- Create MAIN FILES: head-script=|<xsl:value-of select="$WEBHELP_HEAD_SCRIPT"/>|</xsl:message>
    <xsl:message> --- Create MAIN FILES: $withFrames=|<xsl:value-of select="$withFrames"/>| <!-- -\- 
      as boolean: <xsl:value-of select="boolean($withFrames)"/>   -\- not: <xsl:value-of select="not($withFrames)"/>--></xsl:message>

    <xsl:if test="not($withFrames)">
      <!-- Custom JavaScript code set by param webhelp.head.script -->
      <xsl:variable name="webhelpHeadContent">
        
        <xsl:if test="string-length($WEBHELP_HEAD_SCRIPT) > 0">
          <xsl:call-template name="includeCustomHTMLContent">
            <xsl:with-param name="hrefURL" select="$WEBHELP_HEAD_SCRIPT"/>
          </xsl:call-template>       
        </xsl:if>
      </xsl:variable>
      <xsl:copy-of select="$webhelpHeadContent"/>
      
      <xsl:message>---------------- $webhelpHeadContent ---------------------</xsl:message>
      <xsl:message><xsl:copy-of select="$webhelpHeadContent"/></xsl:message>
      <xsl:message>-------------------------------------</xsl:message>
    </xsl:if>

    <!-- Google Custom Search code set by param webhelp.search.script -->
    <xsl:if test="string-length($WEBHELP_SEARCH_SCRIPT) > 0">
      <xsl:value-of select="unparsed-text($WEBHELP_SEARCH_SCRIPT)" disable-output-escaping="yes"/>
    </xsl:if>
    
    <!-- Search autocomplete -->
    <!--<script type="text/javascript" src="oxygen-webhelp/search/keywords.js?uniqueId={$WEBHELP_UNIQUE_ID}"><!-\-\-\-></script>
    <script type="text/javascript" src="oxygen-webhelp/search/searchAutocomplete.js?buildId={$WEBHELP_BUILD_NUMBER}"><!-\-\-\-></script>-->
  </xsl:template>

  <xsl:template name="create-search-js-scripts" exclude-result-prefixes="#all">    
    <script type="text/javascript" src="oxygen-webhelp/search/htmlFileInfoList.js?uniqueId={$WEBHELP_UNIQUE_ID}"><xsl:comment/></script>
    <script type="text/javascript" src="oxygen-webhelp/search/index-1.js?uniqueId={$WEBHELP_UNIQUE_ID}"><xsl:comment/></script>
    <script type="text/javascript" src="oxygen-webhelp/search/index-2.js?uniqueId={$WEBHELP_UNIQUE_ID}"><xsl:comment/></script>
    <script type="text/javascript" src="oxygen-webhelp/search/index-3.js?uniqueId={$WEBHELP_UNIQUE_ID}"><xsl:comment/></script>
  </xsl:template>

  
  <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
    <xd:desc>
      Used to output a TOC entry for each topic.
    </xd:desc>
    <xd:param name="multilevel">If is true then the TOC generation is multilevel</xd:param>
  </xd:doc>
  <xsl:template match="toc:topic" mode="create-toc">
    <xsl:variable name="title" select="oxygen:getTopicTitle(.)"/>
    
    <li>
      <xsl:if test="@outputclass">
        <xsl:attribute name="class">
          <xsl:value-of select="@outputclass"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:call-template name="createTOCContent">
        <xsl:with-param name="cTopic" select="."/>
        <xsl:with-param name="title" select="$title"/>
      </xsl:call-template>
      
      <xsl:if test="toc:topic">
        <ul>
          <xsl:apply-templates select="toc:topic" mode="create-toc"/>
        </ul>
      </xsl:if>
    </li>
  </xsl:template>
  
  <!-- Inghibit output of text in the navigation tree. -->
  <xsl:template match="text()" mode="create-toc"/>
  <xsl:template match="index:term" mode="create-index">
    <li>
      <div>
        <xsl:choose>
          <xsl:when test="count(index:target) = 1">
            <a href="{index:target}" target="contentwin">
              <xsl:value-of select="@name"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@name"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:for-each select="index:target">
          <xsl:text>  </xsl:text>
          <a href="{.}" target="contentwin">[<xsl:value-of select="position()"/>]</a>
          <xsl:text>  </xsl:text>
        </xsl:for-each>
      </div>
      <xsl:if test="index:term">
        <ul>
          <xsl:apply-templates select="index:term" mode="create-index"/>
        </ul>
      </xsl:if>
    </li>
  </xsl:template>

  <xsl:template match="b | strong | i | em | u | sub | sup">
    <xsl:apply-templates select="." mode="copy-xhtml"/>
  </xsl:template>


  <xsl:template name="create-index-file">
    <xsl:param name="toc"/>
    <xsl:param name="title" as="node()"/>
    <xsl:variable name="firstTopic"
      select="($toc//toc:topic[@href and not(contains(@href, 'javascript'))])[1]/@href"/>
    <xsl:message> write index frames in: <xsl:value-of select="concat('index_frames', $OUTEXT)"/>
    </xsl:message>
    <xsl:result-document href="{concat('index_frames', $OUTEXT)}" method="xhtml" indent="no"
      encoding="UTF-8" doctype-system="about:legacy-compat" omit-xml-declaration="yes"
      exclude-result-prefixes="#all">
      <html>
        <xsl:call-template name="setTopicLanguage">
          <xsl:with-param name="withFrames" select="true()"/>
        </xsl:call-template>
        <head>
          <xsl:comment>  Generated with Oxygen version <xsl:value-of select="$WEBHELP_VERSION"/>, build number <xsl:value-of select="$WEBHELP_BUILD_NUMBER"/>.  </xsl:comment>
          <title>
            <xsl:value-of select="$title"/>
          </title>
          <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
          <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
          <script type="text/javascript">
                var withFrames = true; 
                var webhelpSearchRanking = <xsl:value-of select="$WEBHELP_SEARCH_RANKING"/>;
          </script>
  
          <!-- Link the favicon -->
          <xsl:if test="string-length($WEBHELP_FAVICON) > 0">
            <link rel="shortcut icon">
              <xsl:attribute name="href">
                <xsl:value-of select="$WEBHELP_FAVICON"/>
              </xsl:attribute>
              <xsl:comment/>
            </link>
            <link rel="icon">
              <xsl:attribute name="href">
                <xsl:value-of select="$WEBHELP_FAVICON"/>
              </xsl:attribute>
              <xsl:comment/>
            </link>
          </xsl:if>
  
          <link rel="stylesheet" type="text/css" href="oxygen-webhelp/resources/css/commonltr.css?buildId={$WEBHELP_BUILD_NUMBER}">
            <xsl:comment/>
          </link>
          <link rel="stylesheet" type="text/css"
            href="oxygen-webhelp/resources/css/webhelp_topic.css?buildId={$WEBHELP_BUILD_NUMBER}">
            <xsl:comment/>
          </link>
          <!-- Impose a Webhelp skin. -->
          <xsl:if test="string-length($WEBHELP_SKIN_CSS) > 0">
            <link rel="stylesheet" type="text/css" href="{$PATH2PROJ}{$WEBHELP_SKIN_CSS}?buildId={$WEBHELP_BUILD_NUMBER}">
              <xsl:comment/>
            </link>
          </xsl:if>
          <!-- user custom CSS -->
          <xsl:if test="string-length($CSS) > 0">
            <xsl:variable name="urltest">
              <!-- test for URL -->
              <xsl:call-template name="url-string-oxy-internal">
                <xsl:with-param name="urltext">
                  <xsl:value-of select="concat($CSSPATH, $CSS)"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$urltest = 'url'">
                <link rel="stylesheet" type="text/css" href="{$CSSPATH}{$CSS}">
                  <xsl:comment/>
                </link>
              </xsl:when>
              <xsl:otherwise>
                <link rel="stylesheet" type="text/css" href="{$PATH2PROJ}{$CSSPATH}{$CSS}">
                  <xsl:comment/>
                </link>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>

          <script type="text/javascript">
            <xsl:comment>
                        function getContextId() {
                           var page = window.location.search.substr(1);
                           
                           <xsl:value-of select="concat('var getParameters = page.length>0 ? &quot;toc', $OUTEXT,'?&quot; + page : &quot;toc', $OUTEXT,'&quot;;')"/>
                   
                           return getParameters;
                       }
              </xsl:comment>
          </script>
        </head>
        <xsl:variable name="lang-attribute">
          <lang>
            <xsl:call-template name="setTopicLanguage">
              <xsl:with-param name="withFrames" select="true()"/>
            </xsl:call-template>
          </lang>
        </xsl:variable>
        <xsl:choose>
          <xsl:when
            test="
              starts-with($lang-attribute/lang/@xml:lang, 'ar')
              or starts-with($lang-attribute/lang/@xml:lang, 'he')
              or starts-with($lang-attribute/lang/@xml:lang, 'ur')
              or starts-with($lang-attribute/lang/@xml:lang, 'fa')
              or starts-with($lang-attribute/lang/@xml:lang, 'iw')
              or starts-with($lang-attribute/lang/@xml:lang, 'ota')
              ">
            <frameset cols="*,25%" onload="frames.tocwin.location = getContextId()">
              <frame name="contentwin" id="contentwin" src="./oxygen-webhelp/noScript.html"/>
              <frame name="tocwin" id="tocwin" src=""/>
            </frameset>
          </xsl:when>
          <xsl:otherwise>
            <frameset cols="25%,*" onload="frames.tocwin.location = getContextId()">
              <frame name="tocwin" id="tocwin" src=""/>
              <frame name="contentwin" id="contentwin" src="./oxygen-webhelp/noScript.html"/>
            </frameset>
          </xsl:otherwise>
        </xsl:choose>
      </html>
    </xsl:result-document>
  </xsl:template>

  <!-- Serialize element when generating indexterms.js -->
  <xsl:template match="*" mode="indexTermJS">
    <!-- Element name -->
    &lt;<xsl:value-of select="local-name()"/>
    <!-- Attributes -->
    <xsl:apply-templates select="@*" mode="#current"/>&gt;
    <!-- serialize children nodes -->
    <xsl:apply-templates select="node()" mode="#current"/>
    <!-- end element -->
    &lt;/<xsl:value-of select="local-name()"/>&gt;
  </xsl:template>
  
  <!-- Serialize attribute when generating indexterms.js -->
  <xsl:template match="@*" mode="indexTermJS">
    <!-- space before attribute + attribute name -->
    <xsl:text> </xsl:text><xsl:value-of select="local-name()"/>
    <xsl:text>="</xsl:text>
    <!-- write attribute value. escape single quote in its value -->
    <xsl:value-of select="oxygen:escapeQuote(.)"/><xsl:text>"</xsl:text>
  </xsl:template>
  
  <!-- Serialize text nodes when generating indexterms.js -->
  <xsl:template match="text()" mode="indexTermJS">
    <!-- escape single quote -->
    <xsl:value-of select="normalize-space(oxygen:escapeQuote(.))"/>
  </xsl:template>
  
  <!-- Generate link to custom CSS -->
  <xsl:template name="generateCustomCSSLink">
    <xsl:if test="string-length($CSS) > 0">
      <xsl:variable name="urltest">
        <!-- test for URL -->
        <xsl:call-template name="url-string-oxy-internal">
          <xsl:with-param name="urltext">
            <xsl:value-of select="concat($CSSPATH, $CSS)"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$urltest = 'url'">
          <link rel="stylesheet" type="text/css" href="{$CSSPATH}{$CSS}"
            data-css-role="args.css">
            <xsl:comment/>
          </link>
        </xsl:when>
        <xsl:otherwise>
          <link rel="stylesheet" type="text/css" href="{$PATH2PROJ}{$CSSPATH}{$CSS}"
            data-css-role="args.css">
            <xsl:comment/>
          </link>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="url-string-oxy-internal">
    <xsl:param name="urltext"/>
    <xsl:choose>
      <xsl:when test="contains($urltext, 'http://')">url</xsl:when>
      <xsl:when test="contains($urltext, 'https://')">url</xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
