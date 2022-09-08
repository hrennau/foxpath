<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template match="@* | node()" mode="merge">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="merge"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- In case user does not copy a paragraph, match the parent: always the body element.. -->
    <!-- doc.google.com and onedrive.live.com -->
    <xsl:template match="*:body
        [child::node()[contains(@id, 'docs-internal-guid') or ./child::node()[contains(@id, 'docs-internal-guid')]] or 
        child::node()[contains(@class, 'TextRun') or ./child::node()[contains(@class, 'TextRun')]]]" 
        mode="merge">
        <xsl:call-template name="mergeCourierNewSpansToCodeElements"/>
    </xsl:template>   
    
    <!-- Match the paragraph. -->
    <xsl:template match="*:p[not(contains(@class, 'MsoListParagraph'))]
        [contains(@id, 'docs-internal-guid') or contains(@class, 'Paragraph') or preceding-sibling::*:br[contains(@id, 'docs-internal-guid')] or preceding-sibling::*:p[contains(@id, 'docs-internal-guid')]]" mode="merge">
        <xsl:call-template name="mergeCourierNewSpansToCodeElements"/>
    </xsl:template>     
    
    <!--
        Merge inidividual spans formatted with Courier New font into "code" elements.
    -->
    <xsl:template name="mergeCourierNewSpansToCodeElements">
        <xsl:copy>
            <!-- Copy attributes of the match element -->
            <xsl:copy-of select="@* except(@class, @paraeid, @paraid)"/>
            <!-- Group siblings code elements-->
            <xsl:for-each-group select="*" group-adjacent="boolean(self::*:code)">
                <xsl:choose>
                    <!-- Merge -->
                    <xsl:when test="current-grouping-key()">
                        <code xmlns="http://www.w3.org/1999/xhtml">
                            <xsl:apply-templates select="current-group()/node()" mode="merge"/>
                        </code>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()" mode="merge"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>