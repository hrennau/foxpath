<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:f="http://www.oxygenxml.com/xsl/functions"
    exclude-result-prefixes="xs f"
    version="2.0">
    
    <xsl:template match="node() | @*" mode="code">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="code"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
        ===============================
         Convert "Courier New" fonts into "html:code" elements. Later, the code elements will be converted to codeblocks 
        or codeph elements..
        ===============================
    -->
    <xsl:template match="xhtml:span[f:hasFontStyle(@style, $stylesPropMap('monospaced'), $stylesValMap('monospaced'))]"
        mode="code">
        
        <xsl:choose>
            <!-- I am a span, my parent is a list and my child is a list bullet...do nothing..let other stylesheet handle it.  -->
            <xsl:when test="(parent::xhtml:p[contains(@class, 'MsoList') or contains(@style, 'level')] and child::xhtml:span[matches(@style, 'mso-list\s*:\s*Ignore')]) or 
                (node()[matches(@style, 'mso-list\s*:\s*Ignore')] or child::xhtml:span[matches(@style, 'mso-list\s*:\s*Ignore')])
                or (string-length(string-join(text(), '')) = 0 and count(following-sibling::xhtml:span) = 0)">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <code xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:copy>
                        <xsl:apply-templates select="@* | node()" mode="code"/>
                    </xsl:copy>
                </code>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>