<?xml version="1.0" encoding="UTF-8"?>
<!--
  Copyright 2001-2017 Syncro Soft SRL. All rights reserved.
 --> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">

    <xsl:import href="convert-resource-to-base-troubleshooting.xsl"/>


    <xsl:template match="body">
        <troublebody>
          <xsl:apply-templates select="@*|node()"/>
        </troublebody>
    </xsl:template>

    <xsl:template match="section">
        <cause>
          <xsl:apply-templates select="@*|node()"/>
        </cause>
    </xsl:template>

    <xsl:template match="bodydiv">
        <troubleSolution>
          <xsl:apply-templates select="@*|node()"/>
        </troubleSolution>
    </xsl:template>

    <xsl:template match="topic">
        <troubleshooting>
          <xsl:apply-templates select="@*|node()"/>
        </troubleshooting>
    </xsl:template>

    <xsl:template match="ul">
        <choices>
          <xsl:apply-templates select="@*|node()"/>
        </choices>
    </xsl:template>

    <xsl:template match="li">
        <stepsection>
          <xsl:apply-templates select="@*|node()"/>
        </stepsection>
    </xsl:template>

</xsl:stylesheet>