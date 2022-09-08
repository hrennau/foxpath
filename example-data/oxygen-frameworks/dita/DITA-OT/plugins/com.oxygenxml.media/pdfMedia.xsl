<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:rx="http://www.renderx.com/XSL/Extensions"
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
    version="2.0">
    <!--Treat video, audio or iframe objects as links-->
    <xsl:template match="*[contains(@class,' topic/object ')][@outputclass = 'iframe' or @outputclass = 'audio' 
        or @outputclass = 'video' or local-name() = 'video' or local-name() = 'audio']">
        <xsl:variable name="target">
            <xsl:if test="*[contains(@class,' topic/param ')][@name='src' or local-name() = 'source'] or @data">
                <xsl:choose>
                    <xsl:when test="@data">
                        <xsl:value-of select="@data"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="*[contains(@class,' topic/param ')][@name='src' or local-name() = 'source']/@value"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="baseDir">
            <xsl:call-template name="substring-before-last">
                <xsl:with-param name="text" select="@xtrf"/>
                <xsl:with-param name="delim" select="'/'"/>
            </xsl:call-template>
        </xsl:variable>
        
        <fo:inline xsl:use-attribute-sets="object">
            <xsl:call-template name="commonattributes"/>
            <xsl:if test="exists($target)">
                <!-- Antenna House and XEP have support for embedding media.
                    But for now use links to the media files, this is the most robust approach.
                -->
<!--                <xsl:choose>
                    <xsl:when test="$pdfFormatter='ah'">
                        <fo:external-graphic src="url({concat($baseDir, '/', $target)})" content-type="video/mp4"
                            axf:show-controls="true"/>
                    </xsl:when>
                    <xsl:when test="$pdfFormatter='xep'">
                        <rx:media-object src="url({concat($baseDir, '/', $target)})"/>
                    </xsl:when>
                    <xsl:otherwise>-->
                        <fo:basic-link external-destination="url({$target})" xsl:use-attribute-sets="xref">
                            <xsl:value-of select="$target"/>
                        </fo:basic-link>                        
                    <!--</xsl:otherwise>
                </xsl:choose>-->
            </xsl:if>
        </fo:inline>
    </xsl:template>
</xsl:stylesheet>