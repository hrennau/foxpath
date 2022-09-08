<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
            xmlns:oxygen="http://www.oxygenxml.com/functions"
            exclude-result-prefixes="oxygen"
            version="2.0">
    
    <xsl:import href="plugin:org.dita.base:xsl/common/output-message.xsl"/>
    <xsl:import href="plugin:org.dita.base:xsl/common/dita-utilities.xsl"/>
    
    <xsl:variable name="msgprefix">DOTX</xsl:variable>
    
    <!-- Extension of DITA output files for example .html -->
    <xsl:param name="OUT_EXT" select="'.html'"/>
    
    <!-- productID param in Webhelp-Feedback system. Used only in Webhelp-Feedback transform. -->  
    <xsl:param name="WEBHELP_PRODUCT_ID" select="''"/>
    
    <!-- version number param in Webhelp-Feedback system. Used only in Webhelp-Feedback transform. -->  
    <xsl:param name="WEBHELP_PRODUCT_VERSION" select="''"/>  
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="/">
        <map>
            <xsl:if test="string-length($WEBHELP_PRODUCT_ID) > 0">
                <xsl:attribute name="productID">
                    <xsl:value-of select="$WEBHELP_PRODUCT_ID"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="string-length($WEBHELP_PRODUCT_VERSION) > 0">
                <xsl:attribute name="productVersion">
                    <xsl:value-of select="$WEBHELP_PRODUCT_VERSION"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </map>
    </xsl:template>
    
    <xsl:template match="
        *[contains(@class, ' map/topicref ')]
        [@href]
        [not(@scope) or @scope = 'local']
        [not(@processing-role) or @processing-role = 'normal']
        [not(@format) or @format = 'dita' or @format = 'DITA']">
        
        <!-- The output path for the current topic reference -->
        <xsl:variable name="path">
            <xsl:call-template name="replace-extension">
                <xsl:with-param name="filename" select="@href"/>
                <xsl:with-param name="extension" select="$OUT_EXT"/>
            </xsl:call-template>
        </xsl:variable>
        <!-- @ux-source-priority: Determines which resource ID definitions to use: the one from the map, the ones from the topic or both -->
        <!-- 
            Because the "ux-source-priority" attribute can be declared on each resource ID with different values (and because the specification is not clear on this matter)
            we will use the first declaration.
        -->
        <xsl:variable name="priority" select="(*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/resourceid ')][@ux-source-priority])[1]/@ux-source-priority"/>
        <!-- The set of the resource IDs declarations to use for generating the Context Help Mapping -->
        <xsl:variable name="resourceIds">
            <xsl:choose>
                <!-- Use both DITA Map and Topic resource IDs -->
                <xsl:when test="not($priority) or $priority = 'topic-and-map'">
                    <xsl:sequence select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/resourceid ')]"/>
                </xsl:when>
                <!-- Use only Topic resource IDs -->
                <xsl:when test="$priority = 'topic-only'">
                    <xsl:sequence select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/resourceid ')][@source = 'topic']"/>
                </xsl:when>
                <!-- Use only DITA Map resource IDs -->
                <xsl:when test="$priority = 'map-only'">
                    <xsl:sequence select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/resourceid ')][@source != 'topic']"/>
                </xsl:when>
                <!-- Use the resource IDs declared in the DITA Map. If none, use the ones declared in the topic. -->
                <xsl:when test="$priority = 'map-takes-priority'">
                    <xsl:variable name="mapIds" select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/resourceid ')][@source != 'topic']"/>
                    <xsl:choose>
                        <xsl:when test="$mapIds">
                            <xsl:copy-of select="$mapIds"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/resourceid ')][@source = 'topic']"/>        
                        </xsl:otherwise>
                    </xsl:choose>    
                </xsl:when>
                <xsl:when test="$priority = 'topic-takes-priority'">
                    <!-- Use the resource IDs declared in the DITA topic. If none, use the ones declared in the DITA Map. -->
                    <xsl:variable name="topicIds" select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/resourceid ')][@source = 'topic']"/>
                    <xsl:choose>
                        <xsl:when test="$topicIds">
                            <xsl:copy-of select="$topicIds"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/resourceid ')][@source != 'topic']"/>        
                        </xsl:otherwise>
                    </xsl:choose>    
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- Generate the Context Help mapping -->
        <xsl:apply-templates select="$resourceIds/*" mode="processResourceId">
            <xsl:with-param name="path" select="$path"/>
        </xsl:apply-templates>
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- Generates the Context Help mapping -->
    <xsl:template match="*[contains(@class, ' topic/resourceid ')]" mode="processResourceId">
        <xsl:param name="path"/>
        <appContext>
            <xsl:if test="@appname">
                <xsl:copy-of select="@appname"/>
            </xsl:if>
            <xsl:attribute name="helpID">
                <xsl:choose>
                    <xsl:when test="@appid">
                        <xsl:value-of select="@appid"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@id"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="path" select="$path"/>
        </appContext>
    </xsl:template>
    
    <xsl:template match="text()"/>
</xsl:stylesheet>