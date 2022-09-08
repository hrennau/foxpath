<?xml version="1.0" encoding="UTF-8"?>
<!--
  Copyright 2001-2017 Syncro Soft SRL. All rights reserved.
 --> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">

    <xsl:import href="copy-template.xsl"/>


    <xsl:template match="concept">
        <topic>
          <xsl:apply-templates select="@*|node()"/>
        </topic>
    </xsl:template>

    <xsl:template match="conbody">
        <body>
          <xsl:apply-templates select="@*|node()"/>
        </body>
    </xsl:template>

    <xsl:template match="conbodydiv">
        <bodydiv>
          <xsl:apply-templates select="@*|node()"/>
        </bodydiv>
    </xsl:template>

    <xsl:template match="reference">
        <topic>
          <xsl:apply-templates select="@*|node()"/>
        </topic>
    </xsl:template>

    <xsl:template match="refbody">
        <body>
          <xsl:apply-templates select="@*|node()"/>
        </body>
    </xsl:template>

    <xsl:template match="refsyn">
        <section>
          <xsl:apply-templates select="@*|node()"/>
        </section>
    </xsl:template>

    <xsl:template match="properties">
        <simpletable>
          <xsl:apply-templates select="@*|node()"/>
        </simpletable>
    </xsl:template>

    <xsl:template match="prophead">
        <sthead>
          <xsl:apply-templates select="@*|node()"/>
        </sthead>
    </xsl:template>

    <xsl:template match="proptypehd">
        <stentry>
          <xsl:apply-templates select="@*|node()"/>
        </stentry>
    </xsl:template>

    <xsl:template match="propvaluehd">
        <stentry>
          <xsl:apply-templates select="@*|node()"/>
        </stentry>
    </xsl:template>

    <xsl:template match="propdeschd">
        <stentry>
          <xsl:apply-templates select="@*|node()"/>
        </stentry>
    </xsl:template>

    <xsl:template match="property">
        <strow>
          <xsl:apply-templates select="@*|node()"/>
        </strow>
    </xsl:template>

    <xsl:template match="proptype">
        <stentry>
          <xsl:apply-templates select="@*|node()"/>
        </stentry>
    </xsl:template>

    <xsl:template match="propvalue">
        <stentry>
          <xsl:apply-templates select="@*|node()"/>
        </stentry>
    </xsl:template>

    <xsl:template match="propdesc">
        <stentry>
          <xsl:apply-templates select="@*|node()"/>
        </stentry>
    </xsl:template>

    <xsl:template match="troublebody">
        <body>
          <xsl:apply-templates select="@*|node()"/>
        </body>
    </xsl:template>

    <xsl:template match="condition">
        <section>
          <xsl:apply-templates select="@*|node()"/>
        </section>
    </xsl:template>

    <xsl:template match="troubleSolution">
        <bodydiv>
          <xsl:apply-templates select="@*|node()"/>
        </bodydiv>
    </xsl:template>

    <xsl:template match="cause">
        <section>
          <xsl:apply-templates select="@*|node()"/>
        </section>
    </xsl:template>

    <xsl:template match="troubleshooting">
        <topic>
          <xsl:apply-templates select="@*|node()"/>
        </topic>
    </xsl:template>

    <xsl:template match="remedy">
        <section>
          <xsl:apply-templates select="@*|node()"/>
        </section>
    </xsl:template>

    <xsl:template match="steps-informal">
        <section>
          <xsl:apply-templates select="@*|node()"/>
        </section>
    </xsl:template>

    <xsl:template match="steps-unordered">
        <ul>
          <xsl:apply-templates select="@*|node()"/>
        </ul>
    </xsl:template>

    <xsl:template match="stepsection">
        <li>
          <xsl:apply-templates select="@*|node()"/>
        </li>
    </xsl:template>

    <xsl:template match="choices">
        <ul>
          <xsl:apply-templates select="@*|node()"/>
        </ul>
    </xsl:template>

</xsl:stylesheet>