<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="2.0"
    xpath-default-namespace="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
    
    <xsl:output omit-xml-declaration="yes"/>
    
    <xsl:template match="//sheetData">
        <xsl:for-each select="row">
            <xsl:for-each select="c">
                <xsl:choose>
                    <xsl:when test="@t = 's'">
                        <!-- It is a reference to the shared strings. -->
                        <xsl:variable name="string-index" select="number(normalize-space(v)) + 1"/>
                        <xsl:value-of select="document('../sharedStrings.xml',.)/sst/si[position() =  $string-index]/t"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="v"/>
                    </xsl:otherwise>
                </xsl:choose> 
                <xsl:text>,&#9;</xsl:text>
            </xsl:for-each>
        <xsl:text>
            
        </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet>
