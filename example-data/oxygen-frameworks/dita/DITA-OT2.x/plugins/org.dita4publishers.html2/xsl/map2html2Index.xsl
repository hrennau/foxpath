<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:df="http://dita2indesign.org/dita/functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:relpath="http://dita2indesign/functions/relpath"
                xmlns:index-terms="http://dita4publishers.org/index-terms"
                xmlns:htmlutil="http://dita4publishers.org/functions/htmlutil"                
                xmlns:local="urn:functions:local"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="local xs df xsl relpath index-terms htmlutil"
  >
  <!-- =============================================================
    
    DITA Map to HTML Transformation
    
    Copyright (c) 2010, 2015 DITA For Publishers
    
    Licensed under Common Public License v1.0 or the Apache Software Foundation License v2.0.
    The intent of this license is for this material to be licensed in a way that is
    consistent with and compatible with the license of the DITA Open Toolkit.
    
    This transform requires XSLT 2.
    ================================================================= -->    

 <!-- NOTE: The index generation code has been moved to the org.dita4publishers.common.html
            plugin. 
   -->
 <xsl:import href="plugin:org.dita4publishers.common.html:xsl/map2htmlIndex.xsl"/>
</xsl:stylesheet>
