<?xml version="1.0" encoding="UTF-8"?>
<!--
  Copyright 2001-2017 Syncro Soft SRL. All rights reserved.
 --> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">

    <xsl:import href="convert-from-base-to-specialization-task.xsl"/>


    <xsl:template match="concept">
        <task>
          <xsl:apply-templates select="@*|node()"/>
        </task>
    </xsl:template>

    <xsl:template match="reference">
        <task>
          <xsl:apply-templates select="@*|node()"/>
        </task>
    </xsl:template>

    <xsl:template match="troubleshooting">
        <task>
          <xsl:apply-templates select="@*|node()"/>
        </task>
    </xsl:template>

    <xsl:template match="conbody">
        <taskbody>
          <xsl:apply-templates select="@*|node()"/>
        </taskbody>
    </xsl:template>

    <xsl:template match="refbody">
        <taskbody>
          <xsl:apply-templates select="@*|node()"/>
        </taskbody>
    </xsl:template>

    <xsl:template match="troublebody">
        <taskbody>
          <xsl:apply-templates select="@*|node()"/>
        </taskbody>
    </xsl:template>

    <xsl:template match="refsyn">
        <postreq>
          <xsl:apply-templates select="@*|node()"/>
        </postreq>
    </xsl:template>

    <xsl:template match="condition">
        <postreq>
          <xsl:apply-templates select="@*|node()"/>
        </postreq>
    </xsl:template>

    <xsl:template match="cause">
        <postreq>
          <xsl:apply-templates select="@*|node()"/>
        </postreq>
    </xsl:template>

    <xsl:template match="remedy">
        <postreq>
          <xsl:apply-templates select="@*|node()"/>
        </postreq>
    </xsl:template>

    <xsl:template match="steps-informal">
        <postreq>
          <xsl:apply-templates select="@*|node()"/>
        </postreq>
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

    <xsl:template match="stepsection">
        <choice>
          <xsl:apply-templates select="@*|node()"/>
        </choice>
    </xsl:template>

    <xsl:template match="properties">
        <choicetable>
          <xsl:apply-templates select="@*|node()"/>
        </choicetable>
    </xsl:template>

    <xsl:template match="prophead">
        <chhead>
          <xsl:apply-templates select="@*|node()"/>
        </chhead>
    </xsl:template>

    <xsl:template match="proptypehd">
        <chdeschd>
          <xsl:apply-templates select="@*|node()"/>
        </chdeschd>
    </xsl:template>

    <xsl:template match="propvaluehd">
        <chdeschd>
          <xsl:apply-templates select="@*|node()"/>
        </chdeschd>
    </xsl:template>

    <xsl:template match="propdeschd">
        <chdeschd>
          <xsl:apply-templates select="@*|node()"/>
        </chdeschd>
    </xsl:template>

    <xsl:template match="property">
        <chrow>
          <xsl:apply-templates select="@*|node()"/>
        </chrow>
    </xsl:template>

    <xsl:template match="proptype">
        <chdesc>
          <xsl:apply-templates select="@*|node()"/>
        </chdesc>
    </xsl:template>

    <xsl:template match="propvalue">
        <chdesc>
          <xsl:apply-templates select="@*|node()"/>
        </chdesc>
    </xsl:template>

    <xsl:template match="propdesc">
        <chdesc>
          <xsl:apply-templates select="@*|node()"/>
        </chdesc>
    </xsl:template>

</xsl:stylesheet>