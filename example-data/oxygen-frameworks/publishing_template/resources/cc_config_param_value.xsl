<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs xd"
    xmlns:f="http://oxygenxml.com/publishing-template/functions"
    version="3.0">
    
    <xsl:include href="cc_config_common.xsl"/>
    
    <xsl:param name="documentSystemID"></xsl:param>
    <xsl:param name="contextElementXPathExpression" as="xs:string"></xsl:param>
    
    <xsl:template name="start">        
        <xsl:variable 
            name="descriptorDoc" 
            select="doc($documentSystemID)"/>
        
        <!-- Find the current edited parameter -->
        <xsl:variable name="currentParam" as="element()*">
            <xsl:evaluate xpath="$contextElementXPathExpression" as="element()*" context-item="$descriptorDoc"/>
        </xsl:variable>
        
        <!-- All declared parameters in WebHelp plugin -->
        <xsl:variable name="allParams" select="f:getAllParams()"/>
        
        <!-- Current parameter declaration -->
        <xsl:variable name="cParamDeclaration" select="$allParams[@name = $currentParam/@name]"/>
        
        <!-- An parameter with enum type. -->
        <xsl:if test="exists($cParamDeclaration) and $cParamDeclaration/@type='enum'">
            <items action="replace">
               <xsl:apply-templates select="$cParamDeclaration/val">
                   <xsl:sort select="val"/>
               </xsl:apply-templates>
           </items>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="val">
        <item 
            value="{text()}">
            <xsl:if test="@default='true'">
                <xsl:attribute name="annotation" select="'Default value'"></xsl:attribute>
            </xsl:if>
        </item>
    </xsl:template>
    
</xsl:stylesheet>