<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:oxy="http://www.oxygenxml.com/extensions/author"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all">
    <xsl:include href="review-pis-to-elements-core.xsl"/>
    <!--
    	
        Default copy template.
		
    -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

	<!-- 
		Adds the before root review PIs into the root.
 	-->
    <xsl:template match="/*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            
            <xsl:call-template name="add-review-pis-for-root"/>
                            
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!--  
        This is the root element, maybe it has Oxygen attribute changes 
        processing instructions related to it, that are placed before the 
        root. Move them into the root.  
    -->
    <xsl:template name="add-review-pis-for-root">    
        <xsl:apply-templates select="preceding-sibling::processing-instruction('oxy_attributes')" mode="processOxygenPIs"/>
    </xsl:template>
    
    
</xsl:stylesheet>