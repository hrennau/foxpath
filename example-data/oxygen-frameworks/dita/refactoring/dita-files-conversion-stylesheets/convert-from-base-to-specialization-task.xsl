<?xml version="1.0" encoding="UTF-8"?>
<!--
  Copyright 2001-2017 Syncro Soft SRL. All rights reserved.
 --> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">

    <xsl:import href="convert-resource-to-base-task.xsl"/>


    <xsl:template match="topic">
        <task>
          <xsl:apply-templates select="@*|node()"/>
        </task>
    </xsl:template>

    <xsl:template match="body">
        <taskbody>
          <xsl:apply-templates select="@*|node()"/>
        </taskbody>
    </xsl:template>

    <xsl:template match="section">
        <context>
          <xsl:apply-templates select="@*|node()"/>
        </context>
    </xsl:template>

    <xsl:template match="ol">
        <steps>
          <xsl:apply-templates select="@*|node()"/>
        </steps>
    </xsl:template>

    <xsl:template match="ul">
        <steps-unordered>
          <xsl:apply-templates select="@*|node()"/>
        </steps-unordered>
    </xsl:template>

    <xsl:template match="li">
        <step>
          <xsl:apply-templates select="@*|node()"/>
        </step>
    </xsl:template>

    <xsl:template match="itemgroup">
        <info>
          <xsl:apply-templates select="@*|node()"/>
        </info>
    </xsl:template>

    <xsl:template match="p">
        <responsibleParty>
          <xsl:apply-templates select="@*|node()"/>
        </responsibleParty>
    </xsl:template>

    <xsl:template match="simpletable">
        <choicetable>
          <xsl:apply-templates select="@*|node()"/>
        </choicetable>
    </xsl:template>

    <xsl:template match="sthead">
        <chhead>
          <xsl:apply-templates select="@*|node()"/>
        </chhead>
    </xsl:template>

    <xsl:template match="stentry">
        <info>
          <xsl:apply-templates select="@*|node()"/>
        </info>
    </xsl:template>

    <xsl:template match="strow">
        <chrow>
          <xsl:apply-templates select="@*|node()"/>
        </chrow>
    </xsl:template>

</xsl:stylesheet>