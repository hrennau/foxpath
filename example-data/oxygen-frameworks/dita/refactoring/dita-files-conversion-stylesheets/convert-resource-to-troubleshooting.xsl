<?xml version="1.0" encoding="UTF-8"?>
<!--
  Copyright 2001-2017 Syncro Soft SRL. All rights reserved.
 --> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">

    <xsl:import href="convert-from-base-to-specialization-troubleshooting.xsl"/>


    <xsl:template match="conbody">
        <troublebody>
          <xsl:apply-templates select="@*|node()"/>
        </troublebody>
    </xsl:template>

    <xsl:template match="refbody">
        <troublebody>
          <xsl:apply-templates select="@*|node()"/>
        </troublebody>
    </xsl:template>

    <xsl:template match="taskbody">
        <troublebody>
          <xsl:apply-templates select="@*|node()"/>
        </troublebody>
    </xsl:template>

    <xsl:template match="refsyn">
        <steps-informal>
          <xsl:apply-templates select="@*|node()"/>
        </steps-informal>
    </xsl:template>

    <xsl:template match="prereq">
        <steps-informal>
          <xsl:apply-templates select="@*|node()"/>
        </steps-informal>
    </xsl:template>

    <xsl:template match="context">
        <steps-informal>
          <xsl:apply-templates select="@*|node()"/>
        </steps-informal>
    </xsl:template>

    <xsl:template match="steps-informal">
        <steps-informal>
          <xsl:apply-templates select="@*|node()"/>
        </steps-informal>
    </xsl:template>

    <xsl:template match="tasktroubleshooting">
        <steps-informal>
          <xsl:apply-templates select="@*|node()"/>
        </steps-informal>
    </xsl:template>

    <xsl:template match="result">
        <steps-informal>
          <xsl:apply-templates select="@*|node()"/>
        </steps-informal>
    </xsl:template>

    <xsl:template match="postreq">
        <steps-informal>
          <xsl:apply-templates select="@*|node()"/>
        </steps-informal>
    </xsl:template>

    <xsl:template match="conbodydiv">
        <troubleSolution>
          <xsl:apply-templates select="@*|node()"/>
        </troubleSolution>
    </xsl:template>

    <xsl:template match="concept">
        <troubleshooting>
          <xsl:apply-templates select="@*|node()"/>
        </troubleshooting>
    </xsl:template>

    <xsl:template match="reference">
        <troubleshooting>
          <xsl:apply-templates select="@*|node()"/>
        </troubleshooting>
    </xsl:template>

    <xsl:template match="task">
        <troubleshooting>
          <xsl:apply-templates select="@*|node()"/>
        </troubleshooting>
    </xsl:template>

    <xsl:template match="steps-unordered">
        <choices>
          <xsl:apply-templates select="@*|node()"/>
        </choices>
    </xsl:template>

    <xsl:template match="choices">
        <choices>
          <xsl:apply-templates select="@*|node()"/>
        </choices>
    </xsl:template>

    <xsl:template match="step">
        <stepsection>
          <xsl:apply-templates select="@*|node()"/>
        </stepsection>
    </xsl:template>

    <xsl:template match="stepsection">
        <stepsection>
          <xsl:apply-templates select="@*|node()"/>
        </stepsection>
    </xsl:template>

    <xsl:template match="substep">
        <stepsection>
          <xsl:apply-templates select="@*|node()"/>
        </stepsection>
    </xsl:template>

    <xsl:template match="choice">
        <stepsection>
          <xsl:apply-templates select="@*|node()"/>
        </stepsection>
    </xsl:template>

</xsl:stylesheet>