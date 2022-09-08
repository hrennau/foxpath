<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc"
  xmlns:index="http://www.oxygenxml.com/ns/webhelp/index" 
  xmlns:File="java:java.io.File"
  xmlns:oxygen="http://www.oxygenxml.com/functions" xmlns:d="http://docbook.org/ns/docbook"
  xmlns:whc="http://www.oxygenxml.com/webhelp/components" xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
  
  
  <!-- Triggers the display of the comments and change tracking -->
  <xsl:param name="show.changes.and.comments" select="'no'"/>
    
  <!-- The path of index.xml -->
  <xsl:param name="INDEX_XML_FILEPATH" select="'in/index.xml'"/>    

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

  <!-- The URL for the search template. -->
  <xsl:param name="WEBHELP_SEARCH_TEMPLATE_URL"/>

  <!-- The URL for the main page template. -->
  <xsl:param name="WEBHELP_INDEX_HTML_URL"/>

  <!-- The URL for the Index page template. -->
  <xsl:param name="WEBHELP_INDEXTERMS_TEMPLATE_URL"/>
  
  <!-- 
    An unique(timestamp) ID for the current WebHelp transformation 
  -->
  <xsl:param name="WEBHELP_UNIQUE_ID"/>
  
  <!-- 
    Current oXygen build number. 
  -->
  <xsl:param name="WEBHELP_BUILD_NUMBER"/>

  <!--
     This parameter can be used to test the Webhelp distribution.
   -->  
  <xsl:param name="WEBHELP_DISTRIBUTION" select="'responsive'"/>

  <!-- 
     If this parameter is set to 'false' then the relevance stars are not 
     added anymore for the search results displayed on the Search tab.
     By default this parameter is set to true.
   -->
  <xsl:param name="WEBHELP_SEARCH_RANKING" select="'true'"/>

  <!-- Parameter used for computing the relative path of the topic. 
  	  In case of docbook, this should be empty. -->
  <xsl:param name="PATH2PROJ" select="''"/>

  <!-- The path of toc.xml -->
  <xsl:param name="TOC_XML_FILEPATH" select="'in/toc.xml'"/>

  <!-- Custom CSS set in DITA-OT params for custom CSS. -->
  <xsl:param name="CSS" select="''"/>
  <xsl:param name="CSSPATH" select="''"/>

  <!-- File path of image used as favicon -->
  <xsl:param name="WEBHELP_FAVICON" select="''"/>

  <!-- Google Custom Search code set by param webhelp.search.script -->
  <xsl:param name="WEBHELP_SEARCH_SCRIPT" select="''"/>

  <!-- Google Custom Search code set by param webhelp.search.results -->
  <xsl:param name="WEBHELP_SEARCH_RESULT" select="''"/>

  <!-- Oxygen version that created the WebHelp pages. -->
  <xsl:param name="WEBHELP_VERSION"/>

  <!-- File path of image with the company logo. -->
  <xsl:param name="WEBHELP_LOGO_IMAGE" select="''"/>

  <!-- URL that will be opened when the logo image set with 
         the webhelp.logo.image parameter is clicked in the Webhelp page. -->
  <xsl:param name="WEBHELP_LOGO_IMAGE_TARGET_URL" select="''"/>

  <xsl:param name="WEBHELP_DEBUG_DITA_OT_OUTPUT" select="'no'"/>

  <xsl:param name="WEBHELP_DITAMAP_URL"/>

  <xsl:param name="WEBHELP_TRIAL_LICENSE" select="'no'"/>

  <!-- Namespace in which to output TOC links -->
  <xsl:param name="namespace" select="'http://www.w3.org/1999/xhtml'"/>
  
</xsl:stylesheet>