<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:df="http://dita2indesign.org/dita/functions"
  xmlns:index-terms="http://dita4publishers.org/index-terms"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:epubtrans="urn:d4p:epubtranstype"
  exclude-result-prefixes="xs xd df relpath index-terms epubtrans"
  version="2.0">
  
  <!-- =============================================================
    
       DITA Map to Kindle Transformation
       
       Copyright (c) 2010, 2015 DITA For Publishers
       
       Licensed under Common Public License v1.0 or the Apache Software Foundation License v2.0.
       The intent of this license is for this material to be licensed in a way that is
       consistent with and compatible with the license of the DITA Open Toolkit.
       
       This transform requires XSLT 2.
       
       This transform is an extension of the base epub transform and manages any overrides to
       the base epub transform needed for Kindle files. It also allows for users to specify their
       own stylesheets for override via the import xsl extension point of the DITA Open Toolkit.
       
       The input to this transform is a fully-resolved map. All processing of maps
       and topics is driven by references from the map.
       
       ============================================================== -->
  
  <xsl:import href="plugin:org.dita4publishers.epub:xsl/map2epubImpl.xsl"/> <!-- import the D4P epub transform -->
  
  <!-- currently only doing overrides necessary to add the empty kindleExtensions.css file -->
  
  <xsl:template match="*[df:class(., 'map/map')]" mode="generate-opf-manifest-extensions">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <item xmlns="http://www.idpf.org/2007/opf" id="kindleExtensions.css" href="{relpath:newFile($cssOutDir, 'kindleExtensions.css')}" media-type="text/css"/>
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/topic')]" mode="epubtrans:add-additional-css">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <link rel="stylesheet" type="text/css" href="{$PATH2PROJ}{$CSSPATH}kindleExtensions.css" />
  </xsl:template>
  
</xsl:stylesheet>
