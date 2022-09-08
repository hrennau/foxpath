<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Copyright 2001-2011 Syncro Soft SRL. All rights reserved.
 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="#all"
    version="2.0" xmlns:db5="http://docbook.org/ns/docbook" xmlns="http://www.w3.org/1999/xhtml">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>Processes XSL documentation in <xd:b>Docbook</xd:b> format. It transforms the
                Docbook documentation section into HTML language. </xd:p>
            <xd:p>There are supported several common Docbook elements: <xd:ul>
                    <xd:li>
                        <xd:p><xd:i>section</xd:i></xd:p>
                    </xd:li>
                    <xd:li>
                        <xd:p><xd:i>title</xd:i></xd:p>
                    </xd:li>
                    <xd:li>
                        <xd:p><xd:i>sect1, sect2, sect3, sect4, sect5</xd:i></xd:p>
                    </xd:li>
                    <xd:li>
                        <xd:p><xd:i>itemizedlist</xd:i></xd:p>
                    </xd:li>
                    <xd:li>
                        <xd:p><xd:i>orderedlist</xd:i></xd:p>
                    </xd:li>
                    <xd:li>
                        <xd:p><xd:i>listitem</xd:i></xd:p>
                    </xd:li>
                    <xd:li>
                        <xd:p><xd:i>para</xd:i></xd:p>
                    </xd:li>
                    <xd:li>
                        <xd:p><xd:i>emphasis</xd:i></xd:p>
                    </xd:li>
                    <xd:li>
                        <xd:p><xd:i>programlisting</xd:i></xd:p>
                    </xd:li>
                    <xd:li>
                        <xd:p><xd:i>ulink</xd:i>.</xd:p>
                    </xd:li>
                </xd:ul></xd:p>
            <xd:p><xd:b>Note:</xd:b> If the documentation section contains Docbook elements other
                than those listed above they will be copied to the output file without any
                processing.</xd:p>
        </xd:desc>
    </xd:doc>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Template that transforms the Docbook <xd:b>title</xd:b> element into a HTML
                    <xd:b>h4</xd:b> section.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="title|db5:title" mode="documentation">
        <h4>
            <xsl:apply-templates mode="documentation"/>
        </h4>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Template that transforms the Docbook <xd:b>title</xd:b> element that is child of a
                    <xd:b>section</xd:b> into a HTML <xd:b>h1</xd:b> section.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="section/title|db5:section/db5:title" mode="documentation">
        <h1>
            <xsl:apply-templates mode="documentation"/>
        </h1>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Template that transforms the Docbook <xd:b>title</xd:b> element that is child of a
                        <xd:b>sect<xd:i>X</xd:i></xd:b> into a HTML <xd:b>h<xd:i>(X+1)</xd:i></xd:b>
                section, where <xd:i>X</xd:i> is the number of the subsection element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template
        match="sect1/title|sect2/title|sect3/title|sect4/title|sect5/title|
        db5:sect1/db5:title|db5:sect2/db5:title|db5:sect3/db5:title|db5:sect4/db5:title|db5:sect5/db5:title"
        mode="documentation">
        <xsl:element name="h{number(substring-after(local-name(..), 'sect'))+1}"
            namespace="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates mode="documentation"/>
        </xsl:element>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Template that transforms the Docbook <xd:b>itemizedlist</xd:b> element into a HTML
                    <xd:b>ul</xd:b> section.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="itemizedlist|db5:itemizedlist" mode="documentation">
        <ul>
            <xsl:apply-templates mode="documentation"/>
        </ul>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Template that transforms the Docbook <xd:b>emphasis</xd:b> element having the
                    <xd:i>@role</xd:i> attribute set to <xd:i>"underline"</xd:i> into a HTML
                    <xd:b>u</xd:b> section.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="emphasis[@role='underline']|db5:emphasis[@role='underline']"
        mode="documentation">
        <u>
            <xsl:apply-templates mode="documentation"/>
        </u>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Template that transforms the Docbook <xd:b>emphasis</xd:b> element having the
                    <xd:i>@role</xd:i> attribute set to <xd:i>"bold"</xd:i> into a HTML
                    <xd:b>b</xd:b> section.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="emphasis[@role='bold']|db5:emphasis[@role='bold']" mode="documentation">
        <b>
            <xsl:apply-templates mode="documentation"/>
        </b>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Template that transforms the Docbook <xd:b>emphasis</xd:b> element into a HTML
                    <xd:b>i</xd:b> section.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="emphasis|db5:emphasis" mode="documentation">
        <i>
            <xsl:apply-templates mode="documentation"/>
        </i>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Template that transforms the Docbook <xd:b>listitem</xd:b> element into the
                corresponding HTML <xd:b>li</xd:b> section.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="listitem|db5:listitem" mode="documentation">
        <li class="doc">
            <xsl:apply-templates mode="documentation"/>
        </li>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Template that transforms the Docbook <xd:b>orderedlist</xd:b> element into a HTML
                    <xd:b>ol</xd:b> section.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="orderedlist|db5:orderedlist" mode="documentation">
        <ol>
            <xsl:apply-templates mode="documentation"/>
        </ol>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Template that transforms the Docbook <xd:b>programlisting</xd:b> element into a
                HTML <xd:b>pre</xd:b> section.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="programlisting|db5:programlisting" mode="documentation">
        <pre>
            <xsl:apply-templates mode="documentation"/>
        </pre>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Template that transforms the Docbook <xd:b>para</xd:b> element into a HTML
                    <xd:b>p</xd:b> section.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="para|db5:para" mode="documentation">
        <p>
            <xsl:apply-templates mode="documentation"/>
        </p>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Template that transforms the Docbook <xd:b>ulink</xd:b> element into a HTML
                    <xd:b>a</xd:b> section.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="ulink|db5:ulink" mode="documentation">
        <a href="{@url}">
            <xsl:apply-templates mode="documentation"/>
        </a>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Template that transforms any of the Docbook <xd:b>section, sect1, sect2, sect3,
                    sect4, sect5</xd:b> elements into a HTML <xd:b>div</xd:b> section.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="section|sect1|sect2|sect3|sect4|sect5|
        db5:section|db5:sect1|db5:sect2|db5:sect3|db5:sect4|db5:sect5" mode="documentation">
        <div>
            <xsl:apply-templates mode="documentation"/>
        </div>
    </xsl:template>
</xsl:stylesheet>
