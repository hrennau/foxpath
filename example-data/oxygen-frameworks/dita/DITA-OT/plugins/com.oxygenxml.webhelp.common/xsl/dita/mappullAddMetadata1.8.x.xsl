<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mappull="http://dita-ot.sourceforge.net/ns/200704/mappull"
    exclude-result-prefixes="mappull"
    version="2.0">
    <xsl:include href="addResourceID.xsl"/>
	<xsl:template name="getmetadata" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs">
		<xsl:param name="type"/>
		<xsl:param name="scope">#none#</xsl:param>
		<xsl:param name="format">#none#</xsl:param>
		<xsl:param name="file"/>
		<xsl:param name="topicpos"/>
		<xsl:param name="topicid"/>
		<xsl:param name="classval"/>
		<xsl:param name="navtitle"/>
		
		<!-- OXYGEN PATCH START  EXM-27369 -->
		<xsl:if test="$format='#none#' or $format='' or $format='dita'">
			<xsl:call-template name="addResourceID">
				<xsl:with-param name="doc" select="document($file, /)"/>
				<xsl:with-param name="topicid" select="$topicid"/>
			</xsl:call-template>
		</xsl:if>
		<!-- OXYGEN PATCH END  EXM-27369 -->
		
		<!--navtitle-->
		<xsl:choose>
			<xsl:when test="not($navtitle='#none#')">
				<navtitle class="- topic/navtitle ">
					<xsl:copy-of select="$navtitle"/>
				</navtitle>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates
					select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]"
				/>
			</xsl:otherwise>
		</xsl:choose>
		<!--linktext-->
		<xsl:apply-templates select="." mode="mappull:getmetadata_linktext">
			<xsl:with-param name="type" select="$type"/>
			<xsl:with-param name="scope" select="$scope"/>
			<xsl:with-param name="format" select="$format"/>
			<xsl:with-param name="file" select="$file"/>
			<xsl:with-param name="topicpos" select="$topicpos"/>
			<xsl:with-param name="topicid" select="$topicid"/>
			<xsl:with-param name="classval" select="$classval"/>
		</xsl:apply-templates>
		<!--shortdesc-->
		<xsl:apply-templates select="." mode="mappull:getmetadata_shortdesc">
			<xsl:with-param name="type" select="$type"/>
			<xsl:with-param name="scope" select="$scope"/>
			<xsl:with-param name="format" select="$format"/>
			<xsl:with-param name="file" select="$file"/>
			<xsl:with-param name="topicpos" select="$topicpos"/>
			<xsl:with-param name="topicid" select="$topicid"/>
			<xsl:with-param name="classval" select="$classval"/>
		</xsl:apply-templates>
		<!--metadata to be written - if we add logic at some point to pull metadata from topics into the map-->
		<xsl:apply-templates
			select="*[contains(@class, ' map/topicmeta ')]/*[not(contains(@class, ' map/linktext '))][not(contains(@class, ' map/shortdesc '))][not(contains(@class, ' topic/navtitle '))]|
			*[contains(@class, ' map/topicmeta ')]/processing-instruction()"
		/>
	</xsl:template>
    
</xsl:stylesheet>