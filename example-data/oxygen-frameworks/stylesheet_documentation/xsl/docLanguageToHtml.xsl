<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Copyright 2001-2011 Syncro Soft SRL. All rights reserved.
 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="#all"
    xmlns:xdi="http://www.oxygenxml.com/ns/doc/xsl-internal"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    version="2.0">

    <xd:doc scope="stylesheet">
        <xd:desc>Generates XHTML output from the oXygen XSL documentation format.</xd:desc>
    </xd:doc>

    <xd:doc>
        <xd:desc>Generate documentation for a component.</xd:desc>
    </xd:doc>
    <xsl:template match="doc" mode="documentation">
        <div>
            <!-- EXM-38817 Add ids for anchors. -->
            <xsl:copy-of select="@id"/>
            <xsl:apply-templates mode="documentation" select="desc"/>
            <xsl:variable name="params" select="param"/>
            <xsl:if test="not(empty($params))">
                <table>
                    <xsl:for-each select="$params">
                        <tr>
                            <xsl:call-template name="param"/>
                        </tr>
                    </xsl:for-each>
                </table>
            </xsl:if>
            <xsl:apply-templates mode="documentation" select="return"/>
        </div>
    </xsl:template>

    <xd:doc>
        <xd:desc>Generate content for the description of a component.</xd:desc>
    </xd:doc>
    <xsl:template match="desc" mode="documentation">
        <h3>Description</h3>
        <xsl:apply-templates mode="documentation"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>Generate content for a parameter of a function.</xd:desc>
    </xd:doc>
    <xsl:template name="param" match="param" mode="documentation">
        <xsl:if test="not(preceding-sibling::param)">
            <!-- First param -->
            <h4>Parameters</h4>
        </xsl:if>
        <td class="paramName">
            <b><xsl:value-of select="@name"/></b>
        </td>
        <td>
            <xsl:apply-templates mode="documentation">
                <xsl:with-param name="class" tunnel="yes">paramDesc</xsl:with-param>
            </xsl:apply-templates>
        </td>
    </xsl:template>

    <xd:doc>
        <xd:desc>Generate content for the return statement of a function.</xd:desc>
    </xd:doc>
    <xsl:template match="return" mode="documentation">
        <h4>Return</h4>
        <xsl:apply-templates mode="documentation"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>Generate content for paragraphs, for whitespace preserve elements, for bold, italic and for unordered lists.</xd:desc>
    </xd:doc>
    <xsl:template match="p|pre|b|i|ul" mode="documentation">
        <xsl:param name="class" tunnel="yes"/>
        <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml">
            <xsl:if test="string-length($class) != 0">
                <xsl:attribute name="class" select="$class"/>
            </xsl:if>
            <xsl:apply-templates mode="documentation"/>
        </xsl:element>
    </xsl:template>

    <xd:doc>
        <xd:desc>Generate content for a list item.</xd:desc>
    </xd:doc>
    <xsl:template match="li" mode="documentation">
        <li class="doc">
            <xsl:apply-templates mode="documentation"/>
        </li>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Construct a link to another component. Attribute <xd:i>@xdi:location</xd:i> gives
                us the location of the component and attribute <xd:i>@xdi:componentid</xd:i> gives
                us the component's unique id.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="ref" mode="documentation">
        <a
            href="{concat(substring-before(@xdi:location, $intermediateXmlExtension), $extension, '#', @xdi:componentid)}"
            target="{$target}">
            <xsl:if test="not(*|text())">
                <xsl:value-of select="@name"/>
            </xsl:if>
            <xsl:apply-templates mode="documentation"/>
        </a>
    </xsl:template>

    <xd:doc>
        <xd:desc>Construct a link with respect to the following rules: <xd:ul>
                <xd:li>
                    <xd:p>If <xd:i>@docid</xd:i> attribute exists than we consider it to be a link
                        to another documentation block. The location of the documentation block in
                        the output files structure is taken from <xd:i>@xdi:location</xd:i>
                        attribute. </xd:p>
                </xd:li>
                <xd:li>
                    <xd:p>If <xd:i>@docid</xd:i> doesn't exist we consider the link to be
                        external.</xd:p>
                </xd:li>
            </xd:ul>
        </xd:desc>
    </xd:doc>
    <xsl:template match="a" mode="documentation">
        <xsl:element name="a">
            <xsl:choose>
                <xsl:when test="@docid">
                    <xsl:attribute name="href"
                        select="concat(substring-before(@xdi:location, $intermediateXmlExtension), $extension, '#', @docid)"/>
                    <xsl:attribute name="target" select="$target"/>
                    <xsl:if test="not(*|text())">
                        <xsl:value-of select="@docid"/>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="href" select="@href"/>
                    <xsl:attribute name="target" select="'_blank'"/>
                    <xsl:if test="not(*|text())">
                        <xsl:value-of select="@href"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates mode="documentation"/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
