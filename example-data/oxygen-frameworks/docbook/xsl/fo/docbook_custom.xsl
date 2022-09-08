<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:d="http://docbook.org/ns/docbook"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    version="1.0">
    <xsl:import href="profile-docbook.xsl"/>
    <!-- Apply XHLTHL extension. -->
    <xsl:import href="highlight.xsl"/>
    <xsl:import href="../oxygen_custom.xsl"/>
    
    <xsl:template name="graphical.admonition">
        <xsl:variable name="id">
            <xsl:call-template name="object.id"/>
        </xsl:variable>
        
        <fo:block id="{$id}"
            xsl:use-attribute-sets="graphical.admonition.properties">
            <fo:list-block provisional-distance-between-starts="18pt"
                provisional-label-separation="18pt">
                <fo:list-item>
                    <fo:list-item-label end-indent="label-end()">
                        <fo:block>
                            <fo:external-graphic width="auto" height="auto">
                                <xsl:attribute name="src">
                                    <xsl:call-template name="admon.graphic"/>
                                </xsl:attribute>
                            </fo:external-graphic>
                        </fo:block>
                    </fo:list-item-label>
                    <fo:list-item-body start-indent="body-start()">
                        <xsl:if test="$admon.textlabel != 0 or d:title or d:info/d:title">
                            <fo:block xsl:use-attribute-sets="admonition.title.properties">
                                <xsl:apply-templates select="." mode="object.title.markup">
                                    <xsl:with-param name="allow-anchors" select="1"/>
                                </xsl:apply-templates>
                            </fo:block>
                        </xsl:if>
                        <fo:block xsl:use-attribute-sets="admonition.properties">
                            <xsl:apply-templates/>
                        </fo:block>
                    </fo:list-item-body>
                </fo:list-item>
            </fo:list-block>
        </fo:block>
    </xsl:template>
    
</xsl:stylesheet>