<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<!-- 
    Used to expand Webhelp macros like: oxygen-webhelp-output-dir.  
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:oxy="http://www.oxygenxml.com/functions"
    xmlns:relpath="http://dita2indesign/functions/relpath"
    xmlns:whc="http://www.oxygenxml.com/webhelp/components"
    xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc"
    xmlns:oxygen="http://www.oxygenxml.com/functions"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:index="http://www.oxygenxml.com/ns/webhelp/index"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!--
        Expand the macro: oxygen-webhelp-output-dir.
        
        Fix the relative locations to the output directory 
    -->
    <xsl:template 
        match="@*[contains(., '${oxygen-webhelp')]" 
        mode="expand_macro copy_template"
        priority="10">
        <xsl:attribute name="{name()}">
            <xsl:value-of select="oxy:expandMacros(.)"/>            
        </xsl:attribute>
    </xsl:template>
        
    <!-- Copy template for the 'expand_macro' mode -->
    <xsl:template match="node() | @*" mode="expand_macro">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="expand_macro"/>
        </xsl:copy>
    </xsl:template>

    <!--
    Include in the output an HTML fragment. It is used to extand webhelp.fragment parameters. 
  -->
    <xsl:template name="includeCustomHTMLContent">
        <xsl:param name="hrefURL"/>
        
        <xsl:variable name="content" select="doc($hrefURL)"/>
        <xsl:variable name="selectedNodes">
            <xsl:choose>
                <xsl:when test="$content/*:html/*:body">
                    <xsl:copy-of select="$content/*:html/*:body/node()"/>
                </xsl:when>
                <xsl:when test="$content/*:body">
                    <xsl:copy-of select="$content/*:body/node()"/>
                </xsl:when>
                <xsl:when test="$content/*:html/*:head">
                    <xsl:copy-of select="$content/*:html/*:head/node()"/>
                </xsl:when>
                <xsl:when test="$content/*:head">
                    <xsl:copy-of select="$content/*:head/node()"/>
                </xsl:when>
                <xsl:when test="$content/*:html">
                    <xsl:copy-of select="$content/*:html/node()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$content"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- Apply templates in 'copy_template' mode to expand macros -->
        <xsl:variable name="expanded">
            <xsl:apply-templates select="$selectedNodes" mode="fixup_XHTML_NS"/>
        </xsl:variable>
        
        <!--<xsl:apply-templates select="$expanded" mode="copy_template"/>-->
        <xsl:call-template name="copyExternalScript">
            <xsl:with-param name="scriptContent" select="$expanded"></xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    <!-- Template used to expand macros from external script -->
    <xsl:template name="copyExternalScript">
        <xsl:param name="scriptContent"/>
        <xsl:apply-templates select="$scriptContent" mode="expand_macro"/>
    </xsl:template>
    
    <!--
        Functions used to expand oXygen macros.
    -->
    <xsl:function name="oxy:expandMacros">
        <xsl:param name="value" as="xs:string"/>
        
        <!-- Expand ${oxygen-webhelp-assets-dir} macro -->
        <xsl:variable name="expandedValue" select="oxy:expandWebHelpAssetsDir($value)"/>
        
        <!-- Expand ${oxygen-webhelp-template-dir} macro -->
        <xsl:variable name="expandedValue" select="oxy:expandWebHelpTemplatesDir($expandedValue)"/>
        
        <!-- Expand ${oxygen-webhelp-output-dir} macro -->
        <xsl:variable name="expandedValue" select="oxy:expandWebHelpOutputDir($expandedValue)"/>
        
        <!-- Expand TIMESTAMP macro -->
        <xsl:variable name="expandedValue" select="oxy:expandWebHelpTimestampMacro($expandedValue)"/>
        
        <!-- Expand BUILD_NUMBER macro -->
        <xsl:variable name="expandedValue" select="oxy:expandWebHelpBuildNumber($expandedValue)"/>
        
        <xsl:value-of select="$expandedValue"/>
    </xsl:function>
    
    <!--
        Function to expand ${oxygen-webhelp-assets-dir} macro.
    -->
    <xsl:function name="oxy:expandWebHelpAssetsDir">
        <xsl:param name="attrValue" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="starts-with($attrValue, '${oxygen-webhelp-assets-dir}')">
                <xsl:value-of
                    select="
                    concat(
                    $PATH2PROJ,
                    'oxygen-webhelp',
                    substring-after($attrValue, '${oxygen-webhelp-assets-dir}'))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$attrValue"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!--
        Function to expand ${oxygen-webhelp-template-dir} macro.
    -->
    <xsl:function name="oxy:expandWebHelpTemplatesDir">
        <xsl:param name="attrValue" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="starts-with($attrValue, '${oxygen-webhelp-template-dir}')">
                <xsl:value-of
                    select="
                    concat(
                    $PATH2PROJ,
                    'oxygen-webhelp/template/',
                    substring-after($attrValue, '${oxygen-webhelp-template-dir}/'))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$attrValue"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!--
        Function to expand ${oxygen-webhelp-output-dir} macro.
    -->
    <xsl:function name="oxy:expandWebHelpOutputDir">
        <xsl:param name="attrValue" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="starts-with($attrValue, '${oxygen-webhelp-output-dir}/')">
                <xsl:value-of
                    select="
                    concat(
                    $PATH2PROJ,                    
                    substring-after($attrValue, '${oxygen-webhelp-output-dir}/'))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$attrValue"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!--
        Function to expand ${oxygen-webhelp-timestamp} macro.
    -->
    <xsl:function name="oxy:expandWebHelpTimestampMacro">
        <xsl:param name="attrValue" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="ends-with($attrValue, '${oxygen-webhelp-timestamp}')">
                <xsl:value-of
                    select="
                    concat(
                        substring-before($attrValue, '${oxygen-webhelp-timestamp}'), 
                        $WEBHELP_UNIQUE_ID)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$attrValue"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!--
        Function to expand ${oxygen-webhelp-build-number} macro.
    -->
    <xsl:function name="oxy:expandWebHelpBuildNumber">
        <xsl:param name="attrValue" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="ends-with($attrValue, '${oxygen-webhelp-build-number}')">
                <xsl:value-of
                    select="
                    concat(
                    substring-before($attrValue, '${oxygen-webhelp-build-number}'), 
                    $WEBHELP_BUILD_NUMBER)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$attrValue"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>