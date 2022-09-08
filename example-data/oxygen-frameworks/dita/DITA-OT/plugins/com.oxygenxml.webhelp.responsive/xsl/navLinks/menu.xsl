<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs toc"
    xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc"
    xmlns="http://www.w3.org/1999/xhtml"
    version="2.0">
        
    <xsl:template match="toc:toc" mode="menu">
        <xsl:result-document href="{$MENU_TEMP_FILE_URI}" format="html">
            <ul>
                <xsl:apply-templates select="toc:topic" mode="menu"/>
            </ul>
        </xsl:result-document>
    </xsl:template>
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            Used to output a menu entry for each topic.
        </xd:desc>
    </xd:doc>
    <xsl:template match="toc:topic" mode="menu">
        <xsl:variable name="isHidden" as="xs:boolean" 
            select="exists(toc:topicmeta/toc:data[@name='wh-menu']/toc:data[@name='hide'][@value='yes'])"/>
        
        <xsl:if test="not($isHidden)">
            <xsl:variable name="title">
                <xsl:call-template name="getTopicTitle">
                    <xsl:with-param name="topic" select="."/>
                </xsl:call-template>
            </xsl:variable>
            
            <li>
                <xsl:variable name="menuChildCount" select="count(toc:topic[not(toc:topicmeta/toc:data[@name='wh-menu']/toc:data[@name='hide'][@value='yes'])])"/>
                
                <xsl:variable name="currentDepth" select="count(ancestor-or-self::toc:topic)"/>
                <xsl:variable name="maxDepth" select="number($WEBHELP_TOP_MENU_DEPTH)"/>
                
                <!-- Decide if this topic has children for the menu component. -->
                <xsl:variable name="hasChildren" select="$menuChildCount > 0 and ($maxDepth le 0 or $maxDepth > $currentDepth)"/>
                
                <!-- Class attribute: -->
                <!-- Mark the item as having children if this is the case. -->
                <xsl:if test="$hasChildren">
                    <xsl:attribute name="class">has-children</xsl:attribute>
                </xsl:if>
                
                <!-- Set the menu item image -->
                <xsl:apply-templates mode="menu-item-image" select="toc:topicmeta/toc:data[@name='wh-menu']/toc:data[@name='image'][@href]">
                    <xsl:with-param name="title" select="$title"/>
                </xsl:apply-templates>
                
                <xsl:call-template name="getTopicContent">
                    <xsl:with-param name="title" select="$title"/>
                    <xsl:with-param name="hasChildren" select="$hasChildren"/>
                </xsl:call-template>
            </li>
        </xsl:if>
    </xsl:template>
    
    <!--
        Template used to generate the image for a menu item. 
    -->
    <xsl:template match="toc:data[@name='image'][@href]" mode="menu-item-image">    
        <xsl:param name="title"/>
        <span class="topicImg">         
            <img src="{@href}" alt="{$title}">
                <xsl:if test="@scope">
                    <xsl:attribute name="data-scope" select="@scope"/>
                </xsl:if>
                <xsl:variable name="attrWidth" select="toc:data[@name = 'attr-width'][@value]"/>
                <xsl:if test="$attrWidth">
                    <xsl:attribute name="width" select="$attrWidth/@value"/>
                </xsl:if>
                
                <xsl:variable name="attrHeight" select="toc:data[@name = 'attr-height'][@value]"/>
                <xsl:if test="$attrHeight">
                    <xsl:attribute name="height" select="$attrHeight/@value"/>
                </xsl:if>
            </img>
        </span>
    </xsl:template>
    
    <xsl:template name="getTopicContent">
        <xsl:param name="title"/>
        <xsl:param name="hasChildren"/>
        <span data-tocid="{@wh-toc-id}"
            data-state="{if ($hasChildren) then 'not-ready' else 'leaf'}"
            class="{concat(' topicref ', @outputclass)}">
            
            <span class="title">
                <xsl:variable name="hrefLink">
                    <xsl:choose>
                        <xsl:when test="(string-length(@href) eq 0) or (@href eq 'javascript:void(0)') ">
                            <!-- EXM-38925 Select the href of the first descendant topic ref -->
                            <xsl:value-of select="descendant::toc:topic[not(@scope='external')][(string-length(@href) ne 0) and (@href ne 'javascript:void(0)')][1]/@href"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@href"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>    
                <xsl:choose>                
                    <xsl:when test="string-length($hrefLink) > 0">
                        <a href="{$hrefLink}">
                            <xsl:if test="@scope = 'external' or @scope = 'peer'">
                                <xsl:attribute name="data-scope" select="@scope"/>
                                <xsl:attribute name="target">_blank</xsl:attribute>
                            </xsl:if>
                            <xsl:copy-of select="@*[starts-with(name(), 'data-')]"/>
                            <xsl:copy-of select="$title"/>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$title"/>
                    </xsl:otherwise>
                </xsl:choose>
            </span>
        </span>
    </xsl:template>
    
    <xsl:template name="getTopicTitle">
        <xsl:param name="topic"/>
        <xsl:choose>
            <xsl:when test="$topic/toc:title">
                <xsl:apply-templates select="$topic/toc:title/node()" mode="copy-xhtml-without-links"/>
            </xsl:when>
            <xsl:when test="$topic/@title">
                <xsl:value-of select="$topic/@title"/>
            </xsl:when>
            <xsl:when test="$topic/@navtitle">
                <xsl:value-of select="$topic/@navtitle"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*" mode="copy-xhtml-without-links">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="@*" mode="copy-xhtml-without-links">
        <xsl:attribute name="{local-name()}" select="."/>
    </xsl:template>
    
    <!-- Skip HTML 'a' elements from output -->
    <xsl:template match="*:a" mode="copy-xhtml-without-links">
        <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:template>
    
    <!-- Inhibit output of text in the navigation tree. -->
    <xsl:template match="text()" mode="menu #default menu-item-image"/>
</xsl:stylesheet>