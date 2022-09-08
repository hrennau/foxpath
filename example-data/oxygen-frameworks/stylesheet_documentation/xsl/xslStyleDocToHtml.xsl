<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Copyright 2001-2011 Syncro Soft SRL. All rights reserved.
 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns:xss="http://www.CraneSoftwrights.com/ns/xslstyle"
    xmlns:i="http://www.oxygenxml.com/ns/doc/xsl-internal" 
    xmlns="http://www.w3.org/1999/xhtml">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>Stylesheet that processes <xd:b>XSLStyle</xd:b> documentation format.</xd:p>
        </xd:desc>
    </xd:doc>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Template processing elements from the <xd:b>XSLStyle</xd:b> namespace.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="i:docSection/xss:*" mode="documentation">
        <div>
            <xsl:apply-templates mode="documentation"/>
        </div>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Template processing elements from the XSLStyle namespace.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="xss:*" mode="documentation">
        <p>
            <xsl:apply-templates mode="documentation"/>
        </p>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Template for formatting <xd:b>param</xd:b> XSLStyle elements.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="xss:param" mode="documentation">
        <xsl:if test="not(preceding-sibling::xss:param)">
            <!-- First param -->
            <h3>Parameters</h3>
        </xsl:if>
        <p>
            <b>
                <xsl:value-of select="@name"/>
                <span style="white-space:pre;">
                    <xsl:text>  </xsl:text>
                </span>
            </b>
            <xsl:apply-templates mode="documentation"/>
        </p>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Template for formatting <xd:b>title</xd:b> XSLStyle elements.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="xss:title" mode="documentation">
        <h3>
            <xsl:apply-templates mode="documentation"/>
        </h3>
    </xsl:template>
</xsl:stylesheet>
