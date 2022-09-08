<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->
<!--
        ====================================================================
        
        Replace the review elements like oxy:oxy-comment, oxy:oxy-insert, 
  		a.s.o with divs having class attributes the local names.
  		
        ====================================================================
    -->


<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:oxy="http://www.oxygenxml.com/extensions/author"
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"    
    exclude-result-prefixes="oxy"
    version="2.0">
    
    
    <xsl:template match="oxy:oxy-color-hl" >
        <!--  Move the color to a style attribute-->
        <span style="background-color:{@color};">
            <xsl:call-template name="attributes"/>            
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <xsl:template match="oxy:oxy-comment-hl|
                         oxy:oxy-delete-hl|
                         oxy:oxy-insert-hl|
                         oxy:oxy-range-start|
                         oxy:oxy-range-end" >
        <!--  Move the color to a style attribute-->
        <span>
            <xsl:call-template name="attributes"/>            
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    
    <xsl:template match="oxy:*" >
        <span>
            <xsl:call-template name="attributes"/>
            
            <!-- Deals with the links between the callouts and the content. -->
            <xsl:choose>
                <xsl:when test="@id">
                    <!-- Anchor in the content. -->
                    <a name="{@id}"/>
                </xsl:when>
                <xsl:when test="@href">
                    <!-- Reference from a comment to an area in the content.-->
                    <a href="{@href}">[<xsl:value-of select="@hr_id"/>]</a>
                </xsl:when>
                <xsl:otherwise>
                </xsl:otherwise>
            </xsl:choose>
            
            <xsl:apply-templates/>      
        </span>
    </xsl:template>
    
    
    <xsl:template match="oxy:*/oxy:*" >
        <!-- Reply to comment. Avoid generating links. -->
        <span>
            <xsl:attribute name="class" select="local-name()"/>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <xsl:template name="attributes">
        <xsl:attribute name="class" select="local-name()"/>
        <xsl:copy-of select="@*"/>
    </xsl:template>
    
    <!-- 
        EXM-36374:
          Filter review related content (like author, date, review type) from the
          the HTML metadata elements (meta[@name: description, DC.title, abstract, etc...])
          or the HTML page title element.
    -->
    <xsl:template match="oxy:*" mode="dita-ot:text-only" priority="10"/>
    
    <!-- EXM-36374: Do not filter the highlighted content. -->
    <xsl:template match="oxy:oxy-comment-hl | oxy:oxy-delete-hl | oxy:oxy-insert-hl | oxy:oxy-color-hl" 
        mode="dita-ot:text-only" priority="20">
        <xsl:apply-templates select="text()|*|processing-instruction()" mode="dita-ot:text-only"/>
    </xsl:template>
</xsl:stylesheet>