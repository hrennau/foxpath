<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc"
    xmlns:oxygen="http://www.oxygenxml.com/functions"
    xmlns:index="http://www.oxygenxml.com/ns/webhelp/index" 
    exclude-result-prefixes="#all"
    version="2.0">
    
  <xsl:import href="tocDitaImpl.xsl"/>

  <!--
    XSLT extension point for the stylesheet used to produce the toc.xml file. 
  -->
  <dita:extension id="com.oxygenxml.webhelp.xsl.createTocXML"
        behavior="org.dita.dost.platform.ImportXSLAction"
        xmlns:dita="http://dita-ot.sourceforge.net"/>
</xsl:stylesheet>
