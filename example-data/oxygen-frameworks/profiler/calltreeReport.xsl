<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:import href="profilerCommons.xsl"/>
    <xsl:param name="imgExpandableParent" select="'PArrowDown16.gif'"/>

    <!-- Main template -->
    <xsl:template match="profile">
        <html>
            <head>
                <title>Call Tree</title>
                <style>body, td, th, p, ul, ol, div {font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10pt;}</style>
            </head>
            <body>
                <h2>Call tree</h2>
                <table border="0">
                    <xsl:apply-templates mode="header"/>
                </table>
                <hr size="1"/>
                <br/>
                <style>th {border:1px solid #BBBBBB;padding: 3px; margin-bottom: 3px} td
                    {whitespace:nowrap;}</style>
                <table border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse;">
                    <xsl:apply-templates select="inv-tree"/>
                </table>
            </body>
        </html>        
    </xsl:template>
    
    <xsl:template match="inv-tree">
        <xsl:param name="images" select="''"/>
        <xsl:variable name="navigationImage">
            <xsl:call-template name="getNavigationImage"/>
        </xsl:variable>
        <tr valign="top">
            <td nowrap="nowrap">                
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
                <xsl:value-of select="tree-time-pct"/>
                <xsl:text> % - </xsl:text>
                <xsl:value-of select="time"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="time/@unit"/>
                <xsl:text> - </xsl:text>
                <xsl:value-of select="time-pct"/>
                <xsl:text> % - </xsl:text>
                <xsl:value-of select="calls"/>
                <xsl:text>inv. </xsl:text>                
                <xsl:choose>
                    <xsl:when test="'Others'!=node">
                        <xsl:value-of select="node"/>
                        <xsl:text> </xsl:text>
                        <font color="lightgray">
                            <xsl:text> from </xsl:text>
                            <xsl:call-template name="showLocation"/>
                        </font>
                    </xsl:when>
                    <xsl:otherwise>
                        <i>[Others]</i>
                    </xsl:otherwise>
                </xsl:choose>                
                <xsl:variable name="additionalMenuImage">
                    <xsl:call-template name="getAdditionalMenuImage"/>
                </xsl:variable>
                <xsl:variable name="nextImages">
                    <xsl:value-of select="$images"/>
                    <xsl:if test="string-length($images) > 0">
                        <xsl:value-of select="$imagesSeparator"/>
                    </xsl:if>
                    <xsl:value-of select="$additionalMenuImage"/>
                </xsl:variable>
                <xsl:apply-templates select="content/inv-tree">
                    <xsl:with-param name="images" select="$nextImages"/>
                </xsl:apply-templates>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>
