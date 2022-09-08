<?xml version="1.0" encoding="UTF-8"?>
<!--
  Copyright 2001-2017 Syncro Soft SRL. All rights reserved.
 --> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">

    <xsl:import href="convert-resource-to-base-reference.xsl"/>


    <xsl:template match="topic">
        <reference>
          <xsl:apply-templates select="@*|node()"/>
        </reference>
    </xsl:template>

    <xsl:template match="body">
        <refbody>
          <xsl:apply-templates select="@*|node()"/>
        </refbody>
    </xsl:template>

    <xsl:template match="section">
        <refsyn>
          <xsl:apply-templates select="@*|node()"/>
        </refsyn>
    </xsl:template>

    <xsl:template match="simpletable">
        <properties>
          <xsl:apply-templates select="@*|node()"/>
        </properties>
    </xsl:template>

    <xsl:template match="sthead">
        <prophead>
          <xsl:apply-templates select="@*|node()"/>
        </prophead>
    </xsl:template>

    <xsl:template match="stentry">
        <propdesc>
          <xsl:apply-templates select="@*|node()"/>
        </propdesc>
    </xsl:template>

    <xsl:template match="strow">
        <property>
          <xsl:apply-templates select="@*|node()"/>
        </property>
    </xsl:template>

</xsl:stylesheet>