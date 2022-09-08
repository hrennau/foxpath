<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:include href="profilerCommons.xsl"/>
    <xsl:param name="imgPixelRed" select="'pixel_red_1.gif'"/>
    <xsl:param name="imgExpandableParent" select="'PArrowUp16.gif'"/>
    <xsl:param name="imgHotspot" select="'Hotspot16.gif'"/>
    
    <!-- Main template -->    
    <xsl:template match="profile">
        <html>
            <head>
                <title>Hot spots</title>
                <style>body, td, th, p, ul, ol, div {font-family: Verdana, Arial, Helvetica, sans-serif;
                    font-size: 10pt;}</style>
            </head>
            <body>
                <h2>Hot spots</h2>
                <table border="0">
                    <xsl:apply-templates mode="header"/>
                </table>
                <hr size="1"/>
                <br/>
                <style>th {border:1px solid #BBBBBB;padding: 3px; margin-bottom: 3px} td
                    {whitespace:nowrap;}</style>
                <table border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse;">
                    <tr>
                        <th width="40">&#160;</th>
                        <th>Instruction</th>
                        <th>Inherent time</th>
                        <th>Location</th>
                        <th>Invocations</th>
                    </tr>
                    <xsl:apply-templates select="hotspot"/>
                </table>
            </body>
        </html>        
    </xsl:template>
   
    <!-- Get the hotspot image -->
    <xsl:template name="getHotspotImage">
        <xsl:value-of select="$oXygenProfilerImages"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="$imgHotspot"/>
    </xsl:template>
    
    <!-- Get the progress bar image -->
    <xsl:template name="getProgressImage">
        <xsl:value-of select="$oXygenProfilerImages"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="$imgPixelRed"/>      
    </xsl:template>
    
    <!-- Handle hotspots -->
    <xsl:template match="hotspot">
        <xsl:variable name="navigationImage">
            <xsl:call-template name="getNavigationImage"/>
        </xsl:variable>
        <xsl:variable name="progressBar" select="2 * time-pct"/>
        <xsl:variable name="additionalMenuImage">
            <xsl:call-template name="getAdditionalMenuImage"/>
        </xsl:variable>
        <xsl:variable name="hotspotImage">
            <xsl:call-template name="getHotspotImage"/>
        </xsl:variable>        
        <xsl:variable name="progressImage">
            <xsl:call-template name="getProgressImage"/>
        </xsl:variable>
        <tr valign="top">
            <td nowrap="nowrap">
                <img height="18" width="18" border="0" align="left" hspace="0" vspace="0"
                    src="{$navigationImage}"/>
                <img height="16" width="16" border="0" align="left" hspace="0" vspace="0"
                    src="{$hotspotImage}"/>
            </td>
            <td><b><xsl:value-of select="node"/></b></td>
            <td>
                <img height="16" width="{$progressBar}" border="0" align="center" hspace="0" vspace="0"
                    src="{$progressImage}"/>&#160; 
                <xsl:value-of select="time"/> <xsl:value-of select="time/@unit"/> (<xsl:value-of select="time-pct"/> %) &#160;
            </td>            
            <td>
                <xsl:call-template name="showLocation"/>    
            </td>
            <td align="right"><xsl:value-of select="calls"/></td>
        </tr>
        <xsl:apply-templates select="content/parent">
            <xsl:with-param name="images" select="$additionalMenuImage"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <!-- Handle reverse invocation tree  -->
    <xsl:template match="parent">
        <xsl:param name="images" select="''"/>
        <xsl:variable name="navigationImage">
            <xsl:call-template name="getNavigationImage"/>
        </xsl:variable>
        <tr valign="top">
            <td nowrap="nowrap" colspan="5">                
                <xsl:call-template name="printImages">
                    <xsl:with-param name="images" select="$images"/>
                </xsl:call-template>                
                <img height="18" width="18" border="0" align="left" hspace="0" vspace="0"
                    src="{$navigationImage}"/>
                <xsl:variable name="parentImage">
                    <xsl:call-template name="getParentImage">
                        <xsl:with-param name="parentImage" select="$imgExpandableParent"/>
                    </xsl:call-template>
                </xsl:variable>
                <img height="16" width="16" border="0" align="left" hspace="0" vspace="0"
                    src="{$parentImage}"/>
                <b> <xsl:value-of select="node"/></b>
                <xsl:text> - (</xsl:text>
                <xsl:value-of select="time-pct"/>
                <xsl:text> %) - </xsl:text>
                <xsl:value-of select="time"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="time/@unit"/>
                <xsl:text> - </xsl:text>
                <xsl:value-of select="calls"/>
                <xsl:text> hot spot inv. </xsl:text>
               
                <font color="lightgray">
                    <xsl:text> from </xsl:text>
                    <xsl:call-template name="showLocation"/>
                </font>
                <xsl:variable name="additionalMenuImage">
                    <xsl:call-template name="getAdditionalMenuImage"/>
                </xsl:variable>
                <xsl:apply-templates select="content/parent">
                    <xsl:with-param name="images" select="concat($images, $imagesSeparator, $additionalMenuImage)"/>
                </xsl:apply-templates>
            </td>
        </tr>
    </xsl:template>
 </xsl:stylesheet>
