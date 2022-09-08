<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    xmlns:oxy="http://www.oxygenxml.com/extensions/author"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:ImageInfo="java:ImageInfo" exclude-result-prefixes="#all">
    <!-- 
    
        Bookmap: Frontmatter and Backmatter
    
    
    -->
    <xsl:key name="ids_in_frontmatter_backmatter"
        match="
            //*[contains(@class, ' bookmap/frontmatter ')]//*[contains(@class, ' map/topicref ')] |
            //*[contains(@class, ' bookmap/backmatter ')]//*[contains(@class, ' map/topicref ')]
            "
        use="@id"/>
    
    <!-- Remove the frontmatter/backmatter from the TOC -->
    <xsl:template match="opentopic:map/*[contains(@class, ' bookmap/frontmatter ')]"  priority="100"/>
    <xsl:template match="opentopic:map/*[contains(@class, ' bookmap/backmatter ')]" priority="100"/>
    
    <!-- 
        Remove the frontmatter/backmatter referred topics from the content.
        @param remove  Because we are using the default mode for expanding topicrefs in the frontmatter/backmatter,
        we need a way to disable this removal.
    -->
    <xsl:template
        match="*[contains(@class, ' topic/topic ')][@id][key('ids_in_frontmatter_backmatter', @id)]"
        priority="100">
        <xsl:param name="remove" select="true()" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$remove"/>
            <xsl:otherwise><xsl:next-match/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Expand the topicrefs from the frontmatter/backmatter -->    
    <xsl:template match="*[contains(@class, ' map/topicref ')][@href]" mode="expand">
        <xsl:variable name="href" select="substring-after(@href, '#')"/>
        <!-- Using apply templates instead of copy-of in order for the other fixes to work. -->
        <xsl:apply-templates select="//*[contains(@class, 'topic/topic ')][@id = $href]" >
            <!-- Disable removal, leave the default templates copy the topics as they are -->
            <xsl:with-param name="remove" select="false()" tunnel="yes"/>
        </xsl:apply-templates>        
    </xsl:template>
    
    <xsl:template match="*|@*" mode="expand" >
        <xsl:apply-templates mode="expand"/>
    </xsl:template>
    <xsl:template match="text()" mode="expand" priority="200"/>
</xsl:stylesheet>