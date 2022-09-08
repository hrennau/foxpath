<?xml version="1.0" encoding="UTF-8"?>
<!--
  Copyright 2001-2017 Syncro Soft SRL. All rights reserved.
 --> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">

    <xsl:import href="convert-resource-to-base-concept.xsl"/>


    <xsl:template match="topic">
        <concept>
          <xsl:apply-templates select="@*|node()"/>
        </concept>
    </xsl:template>

    <xsl:template match="body">
        <conbody>
          <xsl:apply-templates select="@*|node()"/>
        </conbody>
    </xsl:template>

    <xsl:template match="bodydiv">
        <conbodydiv>
          <xsl:apply-templates select="@*|node()"/>
        </conbodydiv>
    </xsl:template>

</xsl:stylesheet>