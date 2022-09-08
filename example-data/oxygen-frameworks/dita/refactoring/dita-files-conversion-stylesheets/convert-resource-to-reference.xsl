<?xml version="1.0" encoding="UTF-8"?>
<!--
  Copyright 2001-2017 Syncro Soft SRL. All rights reserved.
 --> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">

    <xsl:import href="convert-from-base-to-specialization-reference.xsl"/>


    <xsl:template match="concept">
        <reference>
          <xsl:apply-templates select="@*|node()"/>
        </reference>
    </xsl:template>

    <xsl:template match="task">
        <reference>
          <xsl:apply-templates select="@*|node()"/>
        </reference>
    </xsl:template>

    <xsl:template match="troubleshooting">
        <reference>
          <xsl:apply-templates select="@*|node()"/>
        </reference>
    </xsl:template>

    <xsl:template match="conbody">
        <refbody>
          <xsl:apply-templates select="@*|node()"/>
        </refbody>
    </xsl:template>

    <xsl:template match="taskbody">
        <refbody>
          <xsl:apply-templates select="@*|node()"/>
        </refbody>
    </xsl:template>

    <xsl:template match="troublebody">
        <refbody>
          <xsl:apply-templates select="@*|node()"/>
        </refbody>
    </xsl:template>

    <xsl:template match="prereq">
        <refsyn>
          <xsl:apply-templates select="@*|node()"/>
        </refsyn>
    </xsl:template>

    <xsl:template match="context">
        <refsyn>
          <xsl:apply-templates select="@*|node()"/>
        </refsyn>
    </xsl:template>

    <xsl:template match="steps-informal">
        <refsyn>
          <xsl:apply-templates select="@*|node()"/>
        </refsyn>
    </xsl:template>

    <xsl:template match="tasktroubleshooting">
        <refsyn>
          <xsl:apply-templates select="@*|node()"/>
        </refsyn>
    </xsl:template>

    <xsl:template match="result">
        <refsyn>
          <xsl:apply-templates select="@*|node()"/>
        </refsyn>
    </xsl:template>

    <xsl:template match="postreq">
        <refsyn>
          <xsl:apply-templates select="@*|node()"/>
        </refsyn>
    </xsl:template>

    <xsl:template match="condition">
        <refsyn>
          <xsl:apply-templates select="@*|node()"/>
        </refsyn>
    </xsl:template>

    <xsl:template match="cause">
        <refsyn>
          <xsl:apply-templates select="@*|node()"/>
        </refsyn>
    </xsl:template>

    <xsl:template match="remedy">
        <refsyn>
          <xsl:apply-templates select="@*|node()"/>
        </refsyn>
    </xsl:template>

    <xsl:template match="choicetable">
        <properties>
          <xsl:apply-templates select="@*|node()"/>
        </properties>
    </xsl:template>

    <xsl:template match="chhead">
        <prophead>
          <xsl:apply-templates select="@*|node()"/>
        </prophead>
    </xsl:template>

    <xsl:template match="choptionhd">
        <propdeschd>
          <xsl:apply-templates select="@*|node()"/>
        </propdeschd>
    </xsl:template>

    <xsl:template match="chdeschd">
        <propdeschd>
          <xsl:apply-templates select="@*|node()"/>
        </propdeschd>
    </xsl:template>

    <xsl:template match="chrow">
        <property>
          <xsl:apply-templates select="@*|node()"/>
        </property>
    </xsl:template>

    <xsl:template match="choption">
        <propdesc>
          <xsl:apply-templates select="@*|node()"/>
        </propdesc>
    </xsl:template>

    <xsl:template match="chdesc">
        <propdesc>
          <xsl:apply-templates select="@*|node()"/>
        </propdesc>
    </xsl:template>

</xsl:stylesheet>