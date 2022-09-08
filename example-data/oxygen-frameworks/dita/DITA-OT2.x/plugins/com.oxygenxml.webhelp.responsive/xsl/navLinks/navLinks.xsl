<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc" 
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="sidetoc.xsl"/>
    <xsl:import href="menu.xsl"/>
    <xsl:import href="navJson.xsl"/>
    <xsl:import href="breadcrumb.xsl"/>
    <xsl:import href="../util/dita-utilities.xsl"/>
    
    <xsl:param name="TEMP_DIR_URL"/>
    <xsl:param name="MENU_TEMP_FILE_URI"/>
    <xsl:param name="WEBHELP_SIDE_TOC_LINKS" select="'chapter'"/>
    <xsl:param name="JSON_OUTPUT_DIR_URI"/>
    <xsl:param name="WEBHELP_TOP_MENU_DEPTH"/>
    
    <xsl:variable name="VOID_HREF" select="'javascript:void(0)'"/>
    <xsl:output name="html" method="xhtml" media-type="text/html" omit-xml-declaration="yes"/>
    
    <xsl:key name="tocHrefs" match="toc:topic[@href][not(@href=$VOID_HREF)][not(@format) or @format = 'dita']" use="tokenize(@href, '#')[1]"/>
    
    <xsl:template match="/toc:toc">
        <xsl:apply-templates mode="side-toc" select="."/>
        <xsl:apply-templates mode="menu" select="."/>
        <xsl:apply-templates mode="nav-json" select="."/>
        <xsl:apply-templates mode="breadcrumb" select="."/>
    </xsl:template>
    
    
</xsl:stylesheet>