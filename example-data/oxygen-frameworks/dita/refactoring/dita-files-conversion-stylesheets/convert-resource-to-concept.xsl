<?xml version="1.0" encoding="UTF-8"?>
<!--
  Copyright 2001-2017 Syncro Soft SRL. All rights reserved.
 --> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">

    <xsl:import href="convert-from-base-to-specialization-concept.xsl"/>


    <xsl:template match="reference">
        <concept>
          <xsl:apply-templates select="@*|node()"/>
        </concept>
    </xsl:template>

    <xsl:template match="task">
        <concept>
          <xsl:apply-templates select="@*|node()"/>
        </concept>
    </xsl:template>

    <xsl:template match="troubleshooting">
        <concept>
          <xsl:apply-templates select="@*|node()"/>
        </concept>
    </xsl:template>

    <xsl:template match="refbody">
        <conbody>
          <xsl:apply-templates select="@*|node()"/>
        </conbody>
    </xsl:template>

    <xsl:template match="taskbody">
        <conbody>
          <xsl:apply-templates select="@*|node()"/>
        </conbody>
    </xsl:template>

    <xsl:template match="troublebody">
        <conbody>
          <xsl:apply-templates select="@*|node()"/>
        </conbody>
    </xsl:template>

    <xsl:template match="troubleSolution">
        <conbodydiv>
          <xsl:apply-templates select="@*|node()"/>
        </conbodydiv>
    </xsl:template>

</xsl:stylesheet>