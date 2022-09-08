<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    This stylesheet generates a file that will conatain on each
    line the path of an HTML topic that should not be indexed.
    The files that should be skipped by the indexer task are 
    determined by the @search="no" attribute specified in the
    source DITA Map. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output media-type="text/plain" omit-xml-declaration="yes"/>
    <xsl:param name="OUT_EXTENSION"/>
    <xsl:template match="topicref[@search='no']">
        <!-- Replace the extension of the input file (eg: "dita") with the output file extension (eg: "html") -->
        <xsl:variable name="inHref" select="@href"/>
        <xsl:variable name="outHref">
            <xsl:variable name="normalizedInHref" select="replace($inHref, '\\', '/')"/>
            <xsl:variable name="inHrefPathElements" select="tokenize($normalizedInHref, '/')"/>
            <xsl:if test="count($inHrefPathElements) > 1">
                <!-- Restore the parent path (the path without the file name) -->
                <xsl:variable name="parentPath" select="string-join($inHrefPathElements[position() != last()], '/')"/>
                <xsl:value-of select="concat($parentPath, '/')"/>
            </xsl:if>
            <xsl:variable name="fileNameWithoutExt">
                <!-- File name -->
                <xsl:variable name="fileName" select="$inHrefPathElements[last()]"/>
                <!-- Split the file name into tokens separated by '.'. If there is only one token, the the file has no extension. -->
                <xsl:variable name="fileNameTokens" select="tokenize($fileName, '\.')"/>
                <!-- Concatenate the tokens excepting the last one (the extension) -->
                <xsl:value-of select="string-join($fileNameTokens[position() != last() or position()=1], '.')"/>
            </xsl:variable>
            <!-- Append the output extension to the input file name. -->
            <xsl:choose>
                <xsl:when test="starts-with($OUT_EXTENSION, '.')">
                    <xsl:value-of select="concat($fileNameWithoutExt, $OUT_EXTENSION)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($fileNameWithoutExt, '.', $OUT_EXTENSION)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($outHref, '&#xa;')"/>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet>