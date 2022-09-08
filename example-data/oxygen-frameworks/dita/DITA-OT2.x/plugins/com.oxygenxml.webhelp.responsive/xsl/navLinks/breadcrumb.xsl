<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc" 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs toc" version="2.0">

    <xsl:template match="/toc:toc" mode="breadcrumb">
        <xsl:apply-templates mode="breadcrumb"/>
    </xsl:template>
    
    <!-- 
        Processes the current topic node and generates the breadcrumb for it in a temporary file
        next to the refenced topic file.
        
        @param parentHTML The HTML content that has been generated for the parent 
                          node of the current topic.
    -->
    <xsl:template match="toc:topic" mode="breadcrumb">
        <xsl:param name="parentHTML" tunnel="yes" as="node()*" select="()"/>

        <xsl:variable name="breadcrumb" as="node()*">
            <xsl:apply-templates select="$parentHTML" mode="copy-parent-breadcrumb"/>
            <xsl:apply-templates select="." mode="breadcrumb-html">
                <xsl:with-param name="currentNode" select="true()" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:variable>
        
        
        <!-- 
            Write the breadcrumb for the current node in a temporary file 
            next to file of its referenced target topic. 
        -->
        
        <xsl:if test="not(@href = $VOID_HREF) and not(@scope = 'external') and (not(@format) or @format = 'dita')">
            <!-- WH-1469: Handle the case when there are topicrefs with duplicate hrefs without @copy-to. -->
            <xsl:variable name="nodes" select="key('tocHrefs', tokenize(@href, '#')[1])"/>
            <xsl:if test="count($nodes) lt 2 or deep-equal(.,  $nodes[1])">
                <xsl:variable name="outputHref">
                    <xsl:value-of select="$TEMP_DIR_URL"/>
                    <xsl:call-template name="replace-extension">
                        <xsl:with-param name="extension" select="'.brdcrmb'"/>
                        <xsl:with-param name="filename" select="@href"/>
                        <xsl:with-param name="ignore-fragment" select="true()"/>
                        <xsl:with-param name="forceReplace" select="true()"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:result-document format="html" href="{$outputHref}">
                    <ol class="hidden-print">
                        <xsl:copy-of select="$breadcrumb"/>
                    </ol>
                </xsl:result-document>
            </xsl:if>
        </xsl:if>
        
        <!-- 
            Recursively generate the breadcrumb for the child nodes only if this is not a chunked topic.
            Pass down the HTML content generated for the current node.
        -->
        <xsl:if test="not(contains(@chunk, 'to-content'))">
            <xsl:apply-templates select="toc:topic" mode="breadcrumb">
                <xsl:with-param name="parentHTML" select="$breadcrumb" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template match="html:li[@class='active']" mode="copy-parent-breadcrumb">
        <xsl:copy>
            <xsl:apply-templates select="@* except @class" mode="copy-parent-breadcrumb"/>
            <xsl:apply-templates select="node()" mode="copy-parent-breadcrumb"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="copy-parent-breadcrumb">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="copy-parent-breadcrumb"/>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- Generates the HTML content for the current topic node. -->
    <xsl:template match="toc:topic" mode="breadcrumb-html">
        <li>
            <xsl:attribute name="class">active</xsl:attribute>
            <span>
                <xsl:attribute name="class">
                    <xsl:value-of select="'topicref'"/>
                    <xsl:if test="@outputclass">
                        <xsl:value-of select="concat(' ', @outputclass)"/>
                    </xsl:if>
                </xsl:attribute>
                
                <xsl:variable name="hrefValue">
                    <xsl:call-template name="computeHrefAttr"/>
                </xsl:variable>
                
                <span class="title">
                    <a href="{$hrefValue}">
                        <xsl:if test="@scope='external'">
                            <!-- Mark the current link as being external to the DITA map. -->
                            <xsl:attribute name="data-scope">external</xsl:attribute>
                        </xsl:if>
                        <xsl:copy-of select="toc:title/node()"/>
                    </a>
                    <xsl:apply-templates select="toc:shortdesc" mode="breadcrumb-html"/>
                </span>
            </span>
        </li>
    </xsl:template>
    
    <!-- Compute the href attribute to be used when compute link to topic  -->
    <xsl:template name="computeHrefAttr">
        <xsl:choose>
            <xsl:when test="@href and @href != $VOID_HREF">
                <xsl:value-of select="@href"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- EXM-38925 Select the href of the first descendant topic ref -->
                <xsl:value-of select="descendant::toc:topic[@href and @href != $VOID_HREF][1]/@href"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="toc:shortdesc" mode="breadcrumb-html">
        <span class="wh-tooltip">
            <xsl:copy-of select="node()"/>
        </span>
    </xsl:template>
    
	<xsl:template match="text()" mode="breadcrumb"/>
</xsl:stylesheet>
