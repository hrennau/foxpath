<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    xmlns:oxy="http://www.oxygenxml.com/extensions/author"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:ImageInfo="java:ImageInfo" exclude-result-prefixes="#all">

    <xsl:param name="args.draft" select="'no'"/>
    <xsl:param name="input.dir.url"/>
    
    <xsl:include href="review/review-pis-to-elements.xsl"/>    
    <xsl:include href="post-process-create-title-page.xsl"/>
    <xsl:include href="post-process-filtering.xsl"/>    
    <xsl:include href="post-process-toc.xsl"/>
    <xsl:include href="post-process-chapters.xsl"/>
    <xsl:include href="post-process-frontmatter-backmatter.xsl"/>
    <xsl:include href="post-process-images.xsl"/>    
    <xsl:include href="post-process-draft-comments.xsl"/>    
    <xsl:include href="post-process-index.xsl"/>    
    <xsl:include href="post-process-tables.xsl"/>
    <xsl:include href="post-process-links.xsl"/>
    <xsl:include href="post-process-whitespaces.xsl"/>
    
    <xsl:include href="post-process-flagging.xsl"/>
</xsl:stylesheet>
