<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:template name="addResourceID">
        <xsl:param name="doc"/>
        <xsl:param name="topicid"/>
        
        <!-- Fix the value for the $topicid. It is "#none#" for non-chunked topics. -->
        <xsl:variable name="currentTopicId" as="xs:string">
            <xsl:choose>
                <!-- In case of stand-alone topics (non-chunked) the $topicid is '#none#' -->
                <xsl:when test="$topicid = '#none#'">
                    <xsl:value-of select="$doc/*[contains(@class, ' topic/topic ')]/@id"/>
                </xsl:when>
                <!-- In case of chunked topics the $topicid hold the id of the current subtopic (the one corresponding to the topicref context node) -->
                <xsl:otherwise>
                    <xsl:value-of select="$topicid"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- Generate an attribute containig the topic id. -->
        <xsl:attribute name="data-topic-id" select="$currentTopicId"/>
        
        <!-- The URI of the document where the resource ID was declared. -->
        <!-- Used to distinguish between resource IDs declared in the topic or in the DITA map. -->
        <xsl:variable name="sourceUri" as="xs:string">
            <xsl:value-of select="$doc//*[contains(@class, ' topic/topic ')][@id=$currentTopicId]/@xtrf"/>
        </xsl:variable>
        
        <!-- The sequence containing resource IDs declared in both DITA map and topic. -->
        <xsl:variable name="resourceIds">
            <xsl:sequence select="$doc//*[contains(@class, ' topic/topic ')][@id=$currentTopicId]/*[contains(@class, ' topic/prolog ')]/*[contains(@class, ' topic/resourceid ')]"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="count($resourceIds/*) > 0">
                <!-- Select only those resource IDs that were declared in the DITA topic (not in the DITA map). -->
                <xsl:apply-templates select="$resourceIds/*[@xtrf = $sourceUri]" mode="copy-resourceID"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- If there is no resource ID declared in the DITA Map or in the current topic, fallback to the topic ID.  -->
                <resourceid class="- topic/resourceid " oxy-source="topic">
                    <xsl:attribute name="appid" select="$currentTopicId"/>
                </resourceid>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Copy templates -->
    <xsl:template match="*[contains(@class, ' topic/resourceid ')]" mode="copy-resourceID" priority="10">
        <xsl:copy>
            <xsl:attribute name="oxy-source">topic</xsl:attribute>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="copy-resourceID">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>