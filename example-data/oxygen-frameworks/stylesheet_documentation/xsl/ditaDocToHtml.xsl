<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Copyright 2001-2011 Syncro Soft SRL. All rights reserved.
 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:i="http://www.oxygenxml.com/ns/doc/xsl-internal">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>
                <xd:p xmlns:db5="http://docbook.org/ns/docbook">Processes XSL documentation in
                        <xd:b>DITA</xd:b> format. It transforms the DITA documentation section into
                    HTML language. </xd:p>
                <xd:p xmlns:db5="http://docbook.org/ns/docbook">There are supported several common
                    DITA elements: <xd:ul>
                        <xd:li>
                            <xd:p><xd:i>concept, topic, task</xd:i></xd:p>
                        </xd:li>
                        <xd:li>
                            <xd:p><xd:i>title</xd:i></xd:p>
                        </xd:li>
                        <xd:li>
                            <xd:p><xd:i>p</xd:i></xd:p>
                        </xd:li>
                        <xd:li>
                            <xd:p><xd:i>b, i, u</xd:i></xd:p>
                        </xd:li>
                        <xd:li>
                            <xd:p><xd:i>pre</xd:i></xd:p>
                        </xd:li>
                        <xd:li>
                            <xd:p><xd:i>ol, steps</xd:i></xd:p>
                        </xd:li>
                        <xd:li>
                            <xd:p><xd:i>ul, sl</xd:i></xd:p>
                        </xd:li>
                        <xd:li>
                            <xd:p><xd:i>codeblock</xd:i></xd:p>
                        </xd:li>
                        <xd:li>
                            <xd:p><xd:i>pre</xd:i></xd:p>
                        </xd:li>
                        <xd:li>
                            <xd:p><xd:i>xref</xd:i></xd:p>
                        </xd:li>
                        <xd:li>
                            <xd:p><xd:i>li, step, sli</xd:i></xd:p>
                        </xd:li>
                    </xd:ul></xd:p>
                <xd:p xmlns:db5="http://docbook.org/ns/docbook"><xd:b>Note:</xd:b> If the
                    documentation section contains DITA elements other than those listed above they
                    will be copied to the output file without any processing.</xd:p>
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:db5="http://docbook.org/ns/docbook">
        <xd:desc>
            <xd:p>Template that transforms the DITA <xd:b>concept, task, topic</xd:b> elements into
                a HTML <xd:b>div</xd:b> section.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="concept|topic|task" mode="documentation">
        <div>
            <xsl:apply-templates mode="documentation"/>
        </div>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:db5="http://docbook.org/ns/docbook">
        <xd:desc>
            <xd:p>Template that transforms the DITA <xd:b>title</xd:b> element into a HTML
                    <xd:b>h3</xd:b> section.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="title" mode="documentation">
        <h3>
            <xsl:apply-templates mode="documentation"/>
        </h3>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:db5="http://docbook.org/ns/docbook">
        <xd:desc>
            <xd:p>Template that transforms the DITA <xd:b>p, b, i, u, ol, ul, pre</xd:b> elements
                into their HTML corespondents.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="p|b|i|u|ol|ul|pre" mode="documentation">
        <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates mode="documentation"/>
        </xsl:element>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:db5="http://docbook.org/ns/docbook">
        <xd:desc>
            <xd:p>Template that transforms the DITA <xd:b>codeblock</xd:b> element into a HTML
                    <xd:b>pre</xd:b> section.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="codeblock" mode="documentation">
        <pre>
            <xsl:apply-templates mode="documentation"/>
        </pre>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:db5="http://docbook.org/ns/docbook">
        <xd:desc>
            <xd:p>Template that transforms the DITA <xd:b>sl</xd:b> element into a HTML
                    <xd:b>ul</xd:b> section.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="sl" mode="documentation">
        <ul>
            <xsl:apply-templates mode="documentation"/>
        </ul>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:db5="http://docbook.org/ns/docbook">
        <xd:desc>
            <xd:p>Template that transforms the DITA <xd:b>sli, step, li</xd:b> elements into a HTML
                    <xd:b>li</xd:b> section.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="sli|step|li" mode="documentation">
        <li class="doc">
            <xsl:apply-templates mode="documentation"/>
        </li>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:db5="http://docbook.org/ns/docbook">
        <xd:desc>
            <xd:p>Template that transforms the DITA <xd:b>steps</xd:b> element into a HTML
                    <xd:b>ol</xd:b> section.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="steps" mode="documentation">
        <ol>
            <xsl:apply-templates mode="documentation"/>
        </ol>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:db5="http://docbook.org/ns/docbook">
        <xd:desc>
            <xd:p>Template that transforms the DITA <xd:b>xref</xd:b> element having the
                    <xd:i>href</xd:i> attribute into a HTML <xd:b>a</xd:b> section.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="xref[@href]" mode="documentation">
        <a>
            <xsl:attribute name="href" select="@href"/>
            <xsl:apply-templates mode="documentation"/>
        </a>
    </xsl:template>
</xsl:stylesheet>
