<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:oxy="http://www.oxygenxml.com/extensions/author"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all">
    <xsl:include href="review-utils.xsl"/>
    <xsl:param name="show.changes.and.comments" select="'no'"/>
    <xsl:param name="use.alpha.for.highlights" select="'yes'"/>
    
    <xsl:variable name="cmid2nr">
        <xsl:if test="string($show.changes.and.comments) = 'yes'">
            <xsl:for-each
                select="
                //(
                processing-instruction('oxy_attributes') |
                processing-instruction('oxy_comment_start') |
                processing-instruction('oxy_delete') |
                processing-instruction('oxy_insert_start') |
                processing-instruction('oxy_custom_start'))">
                <mapping id="{generate-id()}" nr="{position()}"/>
            </xsl:for-each>
        </xsl:if>
    </xsl:variable>
    
    
    <!--
    	
        Comments.
        
    -->
    
    
    <!-- Transform all the oxygen PI with a comment into comment elements -->
    <xsl:template
        match="
        processing-instruction('oxy_attributes') |
        processing-instruction('oxy_comment_start') |
        processing-instruction('oxy_delete') |
        processing-instruction('oxy_insert_start')">
        <!-- We cannot generate Oxygen elements outside of the root element -->
        <xsl:if test="not(parent::node() = /)">
            <xsl:apply-templates select="." mode="processOxygenPIs"/>
        </xsl:if>
    </xsl:template>
    
    <!-- Transform all the oxygen PI with a comment into comment elements -->
    <xsl:template
        match="
        processing-instruction('oxy_attributes') |
        processing-instruction('oxy_comment_start') |
        processing-instruction('oxy_delete') |
        processing-instruction('oxy_insert_start')" mode="processOxygenPIs">
        
        
        <xsl:if test="$show.changes.and.comments = 'yes'">
            <xsl:variable name="id" select="generate-id()"/>
            <xsl:variable name="comment-nr" select="$cmid2nr//mapping[@id = $id]/@nr"/>
            
            
            <!-- This anchor will remain in the man flow. -->
            <!-- hr_id is the "human readable id" -->
            <oxy:oxy-range-start id="sc_{$comment-nr}" hr_id="{$comment-nr}"/>
            
            
            
            <!-- Put the deleted content in the output -->
            <xsl:if test="name() = 'oxy_delete'">
                <oxy:oxy-delete-hl>
                    <xsl:value-of disable-output-escaping="yes">
                        <xsl:call-template name="get-pi-part">
                            <xsl:with-param name="part" select="'content'"/>
                        </xsl:call-template>
                    </xsl:value-of>
                </oxy:oxy-delete-hl>
                <oxy:oxy-range-end hr_id="{$comment-nr}"/>
            </xsl:if>
            
            
            <xsl:if test="name() = 'oxy_attributes'">
                <oxy:oxy-range-end hr_id="{$comment-nr}"/>
            </xsl:if>
            
            <!-- Map the PI to an XML element name, so it can be styled from the CSS. -->
            <xsl:variable name="elname" as="xs:string">
                <xsl:choose>
                    <xsl:when test="ends-with(name(), '_start')">
                        <xsl:value-of select="substring-before(name(), '_start')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="name()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <!-- The bubble that is be placed on the side of the page -->
            <xsl:element name="oxy:{translate($elname,'_','-')}"
                namespace="http://www.oxygenxml.com/extensions/author">
                <xsl:attribute name="href" select="concat('#sc_', $comment-nr)"/>
                <xsl:attribute name="hr_id" select="$comment-nr"/>      
                
                <xsl:variable name="comment-flag">
                    <xsl:call-template name="get-pi-part">
                        <xsl:with-param name="part" select="'flag'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:if test="string-length($comment-flag) > 0">                         
                    <xsl:attribute name="flag" select="$comment-flag"/>
                </xsl:if>
                
                
                <xsl:choose>
                    <xsl:when test="name() = 'oxy_attributes'">
                        <xsl:copy-of select="oxy:attributesChangeAsNodeset(.)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        
                        <!-- Author -->
                        <xsl:variable name="author">
                            <xsl:call-template name="get-pi-part">
                                <xsl:with-param name="part" select="'author'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:if test="string-length($author) > 0">
                            <oxy:oxy-author>
                                <xsl:value-of select="$author"/>
                            </oxy:oxy-author>
                        </xsl:if>
                        
                        <!-- Comment. -->
                        <xsl:variable name="comment-text">
                            <xsl:call-template name="get-pi-part">
                                <xsl:with-param name="part" select="'comment'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:if test="string-length($comment-text) > 0">
                            <oxy:oxy-comment-text>
                                <xsl:value-of select="$comment-text" disable-output-escaping="yes"/>
                            </oxy:oxy-comment-text>
                        </xsl:if>
                        
                        <!-- Comment ID. Used for replies. -->
                        <xsl:variable name="comment-id">
                            <xsl:call-template name="get-pi-part">
                                <xsl:with-param name="part" select="'id'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:if test="string-length($comment-id) > 0">
                            <oxy:oxy-comment-id>
                                <xsl:value-of select="$comment-id"/>
                            </oxy:oxy-comment-id>
                        </xsl:if>
                        
                        <!-- Comment parent ID. Used for replies. -->
                        <xsl:variable name="comment-parent-id">
                            <xsl:call-template name="get-pi-part">
                                <xsl:with-param name="part" select="'parentID'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:if test="string-length($comment-parent-id) > 0">
                            <oxy:oxy-comment-parent-id>
                                <xsl:value-of select="$comment-parent-id" />
                            </oxy:oxy-comment-parent-id>
                        </xsl:if>
                        
                        <!-- Content. -->
                        <xsl:variable name="content-text">
                            <xsl:choose>
                                <xsl:when test="name() = 'oxy_insert_start'">
                                    <!-- Split or simple insert? -->
                                    <xsl:variable name="type">
                                        <xsl:call-template name="get-pi-part">
                                            <xsl:with-param name="part" select="'type'"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:variable name="nType" select="normalize-space($type)"/>
                                    <xsl:choose>
                                        <xsl:when test="$nType = 'split'">split</xsl:when>
                                        <xsl:when test="$nType = 'surround'">surround</xsl:when>
                                        <xsl:otherwise>insert</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- Deletion -->
                                    <!-- In the callout show only the text, not the markup. -->
                                    <xsl:variable name="deleted">
                                        <xsl:call-template name="get-pi-part">
                                            <xsl:with-param name="part" select="'content'"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:variable name="deleted-content" 
                                        select="string(saxon:parse(concat('&lt;r>', $deleted, '&lt;/r>'))//text())"
                                    />
                                    <!-- Limit to 50 chars.. -->
                                    <xsl:choose>
                                        <xsl:when test="string-length($deleted-content) > 50">
                                            <xsl:value-of select="substring($deleted-content, 0, 50)"/>..                                            
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$deleted-content"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:if test="string-length($content-text) > 0">
                            <oxy:oxy-content>
                                <xsl:value-of select="$content-text"/>
                            </oxy:oxy-content>
                        </xsl:if>
                        
                        <!-- MID -->
                        <xsl:variable name="mid">
                            <xsl:call-template name="get-pi-part">
                                <xsl:with-param name="part" select="'mid'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:if test="string-length($mid) > 0">
                            <oxy:oxy-mid>
                                <xsl:value-of select="$mid"/>
                            </oxy:oxy-mid>
                        </xsl:if>
                        
                        
                        <!-- Timestamp -->
                        <xsl:variable name="timestamp">
                            <xsl:call-template name="get-pi-part">
                                <xsl:with-param name="part" select="'timestamp'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:if test="string-length($timestamp) > 0">
                            <xsl:variable name="ts">
                                <xsl:call-template name="get-pi-part">
                                    <xsl:with-param name="part" select="'timestamp'"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <oxy:oxy-date>
                                <xsl:call-template name="get-date">
                                    <xsl:with-param name="ts" select="$ts"/>
                                </xsl:call-template>
                            </oxy:oxy-date>
                            <oxy:oxy-hour>
                                <xsl:call-template name="get-hour">
                                    <xsl:with-param name="ts" select="$ts"/>
                                </xsl:call-template>
                            </oxy:oxy-hour>
                            <oxy:oxy-tz>
                                <xsl:call-template name="get-tz">
                                    <xsl:with-param name="ts" select="$ts"/>
                                </xsl:call-template>
                            </oxy:oxy-tz>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    
    <!-- Mark the range end -->
    <xsl:template
        match="
        processing-instruction('oxy_comment_end') |
        processing-instruction('oxy_insert_end')">
        <xsl:if test="$show.changes.and.comments = 'yes'">
            <xsl:variable name="start-name"
                select="concat(substring-before(name(), '_end'), '_start')"/>
            
            <!-- In case of nested comments links the end PI to the start PI -->
            <xsl:variable name="start-mid">
                <xsl:call-template name="get-pi-part">
                    <xsl:with-param name="part" select="'mid'"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:variable name="preceding"
                select="
                if (string-length($start-mid) > 0)
                then
                preceding::processing-instruction()
                [name() = $start-name]
                [contains(., concat(' mid=&quot;', $start-mid, '&quot;'))]
                else
                preceding::processing-instruction()
                [name() = $start-name]
                [not(contains(., ' mid=&quot;'))]
                "/>
            
            <xsl:variable name="start-pi" select="$preceding[last()]"/>
            <xsl:variable name="id" select="generate-id($start-pi)"/>
            <xsl:variable name="comment-nr" select="$cmid2nr//mapping[@id = $id]/@nr"/>
            <oxy:oxy-range-end hr_id="{$comment-nr}"/>
        </xsl:if>
    </xsl:template>
    
    
    <!-- 
        The highlight in the editor do not generate anything. 
        The template matching text() is dealing with them. -->
    <xsl:template 
        match="
        processing-instruction('oxy_custom_start') | 
        processing-instruction('oxy_custom_end') "/>
    
    
    
    <xsl:template match="text()" priority="100">
        <xsl:choose>
            <xsl:when test="$show.changes.and.comments = 'yes' and $cmid2nr/mapping">
                <!--  There is at least a comment/change tracking PI -->
                <xsl:variable name="typeAndPI" select="oxy:getHighlightState(.)"/>
                
                <!-- Start building the markup for comments, highlights -->
                <xsl:variable name="fragment">
                    <xsl:copy/>
                </xsl:variable>
                
                <!-- Insert -->
                <xsl:variable name="fragment">
                    <xsl:choose>
                        <xsl:when test="$typeAndPI[1] = 'insert'">
                            <oxy:oxy-insert-hl>
                                <xsl:copy-of select="$fragment"/>
                            </oxy:oxy-insert-hl>                            
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$fragment"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <!-- Comment -->
                <xsl:variable name="fragment">
                    <xsl:choose>
                        <xsl:when test="$typeAndPI[1] = 'comment'">
                            <oxy:oxy-comment-hl>
                                <xsl:copy-of select="$fragment"/>
                            </oxy:oxy-comment-hl>                            
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$fragment"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <!-- Color highlight -->
                <xsl:variable name="fragment">
                    <xsl:choose>
                        <xsl:when test="$typeAndPI[1] = 'highlight'">
                            <xsl:variable name="highlight-color">
                                <xsl:call-template name="get-pi-part">
                                    <xsl:with-param name="part" select="'color'"/>
                                    <xsl:with-param name="data" select="$typeAndPI[2]"/>
                                </xsl:call-template>
                            </xsl:variable>
                            
                            <oxy:oxy-color-hl>
                                <xsl:choose>
                                    <xsl:when test="$use.alpha.for.highlights='yes'">
                                        <xsl:attribute name="color">rgba(<xsl:value-of select="$highlight-color"/>,50)</xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="color">rgb(<xsl:value-of select="$highlight-color"/>)</xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:copy-of select="$fragment"/>
                            </oxy:oxy-color-hl>                            
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$fragment"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:copy-of select="$fragment"/>                
                
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>