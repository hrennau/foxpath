<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Copyright 2001-2011 Syncro Soft SRL. All rights reserved.
 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="urn:doxsl:documentation:1.0"
    xmlns:i="http://www.oxygenxml.com/ns/doc/xsl-internal">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>Stylesheet that processes <xd:b>doxsl</xd:b> documentation format.</xd:p>
            <xd:p><xd:b>Note:</xd:b> Not all <xd:i>doxsl</xd:i> elements are supported. The elements
                that are processed are listed below:</xd:p>
            <xd:p>
                <xd:ul>
                    <xd:li>
                        <xd:p><xd:i>documentation</xd:i></xd:p>
                    </xd:li>
                    <xd:li>
                        <xd:p><xd:i>docContent</xd:i></xd:p>
                    </xd:li>
                    <xd:li>
                        <xd:p><xd:i>attribute-set</xd:i></xd:p>
                    </xd:li>
                    <xd:li>
                        <xd:p><xd:i>function</xd:i></xd:p>
                    </xd:li>
                    <xd:li>
                        <xd:p><xd:i>module</xd:i></xd:p>
                    </xd:li>
                    <xd:li>
                        <xd:p><xd:i>parameter</xd:i></xd:p>
                    </xd:li>
                    <xd:li>
                        <xd:p><xd:i>template</xd:i></xd:p>
                    </xd:li>
                    <xd:li>
                        <xd:p><xd:i>codefrag</xd:i></xd:p>
                    </xd:li>
                    <xd:li>
                        <xd:p><xd:i>description</xd:i></xd:p>
                    </xd:li>
                    <xd:li>
                        <xd:p><xd:i>para</xd:i></xd:p>
                    </xd:li>
                    <xd:li>
                        <xd:p><xd:i>link</xd:i></xd:p>
                    </xd:li>
                    <xd:li>
                        <xd:p><xd:i>list</xd:i></xd:p>
                    </xd:li>
                    <xd:li>
                        <xd:p><xd:i>listitem</xd:i>.</xd:p>
                    </xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
        xmlns:xss="http://www.CraneSoftwrights.com/ns/xslstyle">
        <xd:desc>
            <xd:p>Template processing the <xd:i>doxsl</xd:i>
                <xd:b>documentation</xd:b> element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="i:docSchema/documentation" mode="documentation">
        <xsl:apply-templates select="attribute-set|function|module|parameter|template" mode="documentation"/>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
        xmlns:xss="http://www.CraneSoftwrights.com/ns/xslstyle">
        <xd:desc>
            <xd:p>Template processing the <xd:i>doxsl</xd:i>
                <xd:b>docContent</xd:b> element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="docContent">
        <xsl:param name="component" as="xs:string"/>
        <div>
            <h3><xsl:value-of select="$component"/> description</h3>
            <xsl:apply-templates mode="documentation"/>
        </div>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
        xmlns:xss="http://www.CraneSoftwrights.com/ns/xslstyle">
        <xd:desc>
            <xd:p>Template processing the <xd:i>doxsl</xd:i>
                <xd:b>attribute-set</xd:b> element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="attribute-set" mode="documentation">
        <xsl:call-template name="docContent">
            <xsl:with-param name="component">Attribute set</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
        xmlns:xss="http://www.CraneSoftwrights.com/ns/xslstyle">
        <xd:desc>
            <xd:p>Template processing the <xd:i>doxsl</xd:i>
                <xd:b>function</xd:b> element which is used to document a XSL function.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="function" mode="documentation">
        <xsl:call-template name="docContent">
            <xsl:with-param name="component">Function</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
        xmlns:xss="http://www.CraneSoftwrights.com/ns/xslstyle">
        <xd:desc>
            <xd:p>Template processing the <xd:i>doxsl</xd:i>
                <xd:b>module</xd:b> element which is used to document a stylesheet module.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="module" mode="documentation">
        <xsl:call-template name="docContent">
            <xsl:with-param name="component">Module</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
        xmlns:xss="http://www.CraneSoftwrights.com/ns/xslstyle">
        <xd:desc>
            <xd:p>Template processing the <xd:i>doxsl</xd:i>
                <xd:b>parameter</xd:b> element which is used to document global XSL
                parameters.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="documentation/parameter" mode="documentation">
        <xsl:call-template name="docContent">
            <xsl:with-param name="component">Parameter</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
        xmlns:xss="http://www.CraneSoftwrights.com/ns/xslstyle">
        <xd:desc>
            <xd:p>Template processing the <xd:i>doxsl</xd:i>
                <xd:b>template</xd:b> element which is used to document a XSL template.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="template" mode="documentation">
        <xsl:call-template name="docContent">
            <xsl:with-param name="component">Template</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
        xmlns:xss="http://www.CraneSoftwrights.com/ns/xslstyle">
        <xd:desc>
            <xd:p>Template processing the <xd:i>doxsl</xd:i>
                <xd:b>parameter</xd:b> element  which is used to document the parameters of a XSL
                template or function.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="parameter" mode="documentation">
        <xsl:if test="not(preceding-sibling::parameter)">
            <!-- First param -->
            <h4>Parameters</h4>
        </xsl:if>
        <p>
            <b>
                <xsl:value-of select="@name"/>
                <span style="white-space:pre;"><xsl:text>  </xsl:text></span>
            </b>
            <xsl:apply-templates mode="documentation"/>
        </p>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
        xmlns:xss="http://www.CraneSoftwrights.com/ns/xslstyle">
        <xd:desc>
            <xd:p>Template processing the <xd:i>doxsl</xd:i>
                <xd:b>codefrag</xd:b> element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="codefrag" mode="documentation">
        <pre>
            <xsl:apply-templates mode="documentation"/>
        </pre>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
        xmlns:xss="http://www.CraneSoftwrights.com/ns/xslstyle">
        <xd:desc>
            <xd:p>Template processing the <xd:i>doxsl</xd:i>
                <xd:b>description</xd:b>  and <xd:b>para</xd:b> elements.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="description|para" mode="documentation">
        <p><xsl:apply-templates mode="documentation"/></p>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
        xmlns:xss="http://www.CraneSoftwrights.com/ns/xslstyle">
        <xd:desc>
            <xd:p>Template processing the <xd:i>doxsl</xd:i>
                <xd:b>link</xd:b> element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="link" mode="documentation">
        <a href="{@href}">
            <xsl:apply-templates mode="documentation"/>
        </a>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
        xmlns:xss="http://www.CraneSoftwrights.com/ns/xslstyle">
        <xd:desc>
            <xd:p>Template processing the <xd:i>doxsl</xd:i>
                <xd:b>list</xd:b> element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="list" mode="documentation">
        <ul>
            <xsl:apply-templates select="listitem" mode="documentation"/>
        </ul>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
        xmlns:xss="http://www.CraneSoftwrights.com/ns/xslstyle">
        <xd:desc>
            <xd:p>Template processing the <xd:i>doxsl</xd:i>
                <xd:b>listitem</xd:b> element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="listitem" mode="documentation">
        <li class="doc">
            <xsl:apply-templates mode="documentation"/>
        </li>
    </xsl:template>
</xsl:stylesheet>
