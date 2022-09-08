<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">
    
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="simpletable[not(@conref) and not(@conkeyref)]">
        <table>
            <xsl:apply-templates select="@*" mode="convert"/>
            <tgroup>
                <xsl:if test="@relcolwidth">
                    <xsl:attribute name="cols" select="count(tokenize(@relcolwidth, '\s'))"/>
                    <xsl:analyze-string select="@relcolwidth" regex="\s">
                        <xsl:non-matching-substring>
                            <colspec colname="c{(position()+1) div 2}" colwidth="{.}"/>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:if>
                <xsl:apply-templates select="sthead" mode="convert"/>
                <tbody>
                    <xsl:apply-templates select="strow" mode="convert"/>
                </tbody>
            </tgroup>
        </table>
    </xsl:template>
    
    <xsl:template match="sthead" mode="convert">
        <thead>
            <row>
                <xsl:apply-templates select="@*|node()" mode="convert"/>
            </row>
        </thead>
    </xsl:template>
    <xsl:template match="strow" mode="convert">
        <row>
            <xsl:apply-templates select="@*|node()" mode="convert"/>
        </row>
    </xsl:template>
    
    <xsl:template match="stentry" mode="convert">
        <entry>
            <xsl:apply-templates select="@*|node()" mode="convert"/>
        </entry>
    </xsl:template>
    <xsl:template match="@keycol" mode="convert"/>
    <xsl:template match="@refcol" mode="convert"/>
    <xsl:template match="@relcolwidth" mode="convert"/>
    <xsl:template match="@class" mode="convert"/>
</xsl:stylesheet> 