<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs saxon oxy"
    version="2.0"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:oxy="http://www.oxygenxml.com/extensions/author">
    <xsl:include href="review-utils.xsl"/>
    <xsl:param name="show.changes.and.comments" select="'no'"/>
    
<!-- defining the formatting of modifications  -->
    <xsl:attribute-set name="insert">
        <xsl:attribute name="color">blue</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="change">
        <xsl:attribute name="background-color">yellow</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="delete">
        <xsl:attribute name="color">red</xsl:attribute>
        <xsl:attribute name="text-decoration">line-through</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="comment">
    </xsl:attribute-set>
    <xsl:attribute-set name="footnote_font_size">
        <xsl:attribute name="font-size">75%</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="footnote_style" use-attribute-sets="footnote_font_size">
        <xsl:attribute name="start-indent">0</xsl:attribute>
        <xsl:attribute name="font-style">normal</xsl:attribute>
        <xsl:attribute name="font-weight">100</xsl:attribute>
        <xsl:attribute name="text-align">left</xsl:attribute>
        <xsl:attribute name="text-align-last">left</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="footnote_char_style">
        <xsl:attribute name="baseline-shift">super</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="footnote_body_style" use-attribute-sets="footnote_style">
        <xsl:attribute name="font-size">12pt</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="footnote_body_content_style">
    </xsl:attribute-set>

    <xsl:template match="oxy:*">
        <!-- Usually ignore contents -->
    </xsl:template>
    
    <xsl:template match="oxy:oxy-range-end[not(ancestor::*[local-name() = 'marker' or local-name() = 'footnote'])]">
        <xsl:call-template name="generateFootnote">
            <xsl:with-param name="elem" select="oxy:findHighlightInfoElement(.)"/>
            <xsl:with-param name="color" select="'black'"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- INSERT CHANGE, USE UNDERLINE -->
    <xsl:template match="oxy:oxy-insert-hl[
        not(parent::*[local-name() = 'table' or local-name() = 'table-body' or local-name() = 'table-row' or local-name() = 'list-block' or local-name() = 'flow'])]">
        <fo:inline xsl:use-attribute-sets="insert">
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- DELETE CHANGE, USE STRIKEOUT -->
    <xsl:template match="oxy:oxy-delete-hl">
        <fo:inline xsl:use-attribute-sets="delete">
            <xsl:apply-templates/>
        </fo:inline>    
    </xsl:template>
    
    <!-- EXM-38048 Somehow wrap in list items oxy elements which are directly in it. -->
    <xsl:template match="fo:list-block[oxy:*]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            
            <xsl:for-each-group select="*" group-adjacent="namespace-uri() = 'http://www.oxygenxml.com/extensions/author'">
                <xsl:choose>
                    <xsl:when test="namespace-uri(current-group()[1]) = 'http://www.oxygenxml.com/extensions/author'">
                        <xsl:variable name="content">
                            <xsl:apply-templates select="current-group()"/>
                        </xsl:variable>
                        <xsl:if test="normalize-space($content)">
                            <fo:list-item>
                                <fo:list-item-label><fo:block><fo:inline/></fo:block></fo:list-item-label>
                                <fo:list-item-body>
                                    <fo:block>
                                        <fo:inline>
                                            <xsl:copy-of select="$content"/>
                                        </fo:inline>    
                                    </fo:block>
                                </fo:list-item-body>
                            </fo:list-item>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
    <!-- COLOR HIGHLIGHT, USE PROPER BG COLOR -->
    <xsl:template match="oxy:oxy-color-hl" >
        <!--  Move the color to a style attribute-->
        <fo:inline background-color="{@color}">
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- COMMENT CHANGE -->
    <xsl:template match="oxy:oxy-comment-hl">
        <fo:inline xsl:use-attribute-sets="change">
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <xsl:template name="generateFootnote">
        <xsl:param name="elem"/>
        <xsl:param name="color"/>
        <xsl:variable name="number" select="$elem/@hr_id"/>
        <xsl:variable name="commentContent">
            <xsl:apply-templates mode="getCommentContent" select="$elem">
                <xsl:with-param name="number" select="$number"/>
            </xsl:apply-templates>
        </xsl:variable>
        
        <xsl:if test="$commentContent != ''">
            <xsl:variable name="fnid" select="generate-id($elem)"/>
            <fo:basic-link internal-destination="{$fnid}">
                <fo:footnote xsl:use-attribute-sets="footnote_style">
                    <fo:inline color="{$color}" xsl:use-attribute-sets="footnote_char_style">[<xsl:value-of select="$number"/>]</fo:inline>
                    <fo:footnote-body xsl:use-attribute-sets="footnote_body_style">   
                        <fo:block color="{$color}" id="{$fnid}" xsl:use-attribute-sets="footnote_body_content_style">     
                            <xsl:copy-of select="$commentContent"/>                                          
                        </fo:block>
                    </fo:footnote-body>
                </fo:footnote>
            </fo:basic-link>
        </xsl:if>
    </xsl:template>
    
    
    <xsl:template mode="getCommentContent" match="*">
        <xsl:param name="number"/>
        <xsl:param name="indent" select="0"/>
        <fo:block xsl:use-attribute-sets="comment">
            <xsl:choose>
                <!-- Nested replies, indent to the left so that they appear like a conversation..-->
                <xsl:when test="$indent = 1">
                    <xsl:attribute name="margin-left" select="20"/>
                </xsl:when>
                <xsl:when test="$indent > 1">
                    <xsl:attribute name="margin-left" select="$indent * 10"/>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="$number">
                <fo:inline baseline-shift="super" xsl:use-attribute-sets="footnote_font_size">
                    <xsl:value-of select="$number"/>
                </fo:inline>
            </xsl:if>
            <!-- Comment. -->
            <xsl:choose>
                <xsl:when test="local-name() = 'oxy-attributes'">
                    <!-- <oxy:oxy-attributes xmlns:oxy="http://www.oxygenxml.com/extensions/author" href="#sc_1" hr_id="1">
                        <oxy:oxy-attribute-change name="id" type="inserted">
                        <oxy:oxy-author>radu_coravu</oxy:oxy-author>
                        <oxy:oxy-current-value unknown="true"/>
                        <oxy:oxy-date>2016/08/03</oxy:oxy-date>
                        <oxy:oxy-hour>14:27:26</oxy:oxy-hour>
                        <oxy:oxy-tz>+03:00</oxy:oxy-tz>
                        </oxy:oxy-attribute-change>
                        </oxy:oxy-attributes> -->
                    <xsl:for-each select="oxy:oxy-attribute-change">
                        <!-- Take each of the attribute changes (are separated with spaces.) -->
                        <xsl:value-of select="oxy:oxy-author"/>:&#160; <xsl:value-of select="@type"/> attr "<xsl:value-of select="@name"/>"
                        <xsl:if test="oxy:oxy-old-value[@unknown!='true']">old value=</xsl:if><xsl:value-of select="oxy:oxy-old-value"/>&#160;
                        <xsl:if test="oxy:oxy-current-value[@unknown!='true']">current value=</xsl:if><xsl:value-of select="oxy:oxy-current-value"/>
                        &#160;
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="comment-text" select="oxy:oxy-comment-text"/>
                    <!-- Author -->
                    <xsl:variable name="author" select="oxy:oxy-author"/>
                    <xsl:if test="string-length($author) > 0">
                        <xsl:value-of select="$author"/>:&#160;
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="string-length($comment-text) > 0">
                            <xsl:value-of select="$comment-text" disable-output-escaping="yes"/>
                        </xsl:when>
                        <xsl:when test="starts-with(local-name(), 'oxy-insert')">
                            [Insertion]
                        </xsl:when>
                        <xsl:when test="starts-with(local-name(), 'oxy-delete')">
                            [Deletion]
                        </xsl:when>
                        <xsl:otherwise>
                            [Modification]
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
            <!-- RECURSE TO GATHER REPLIES... -->
            <xsl:variable name="gathered">
                <xsl:apply-templates mode="getCommentContent" select="oxy:oxy-comment">
                    <xsl:with-param name="indent" select="$indent + 1"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:if test="$gathered">
                <fo:block>
                    <xsl:copy-of select="$gathered"/>
                </fo:block>
            </xsl:if>
        </fo:block>
    </xsl:template>
    
    <!--
    	
        Default copy template.
		
    -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*:table">
        <!-- Push up all track changes information placed directly in table or table body in order not to break the XSL-FO -->
        <xsl:apply-templates select="node()[namespace-uri() = 'http://www.oxygenxml.com/extensions/author'] | *:table-body/node()[namespace-uri() = 'http://www.oxygenxml.com/extensions/author']
            | *:table-header/node()[namespace-uri() = 'http://www.oxygenxml.com/extensions/author']"/>
        <xsl:copy>
            <xsl:apply-templates select="node()[not(namespace-uri() = 'http://www.oxygenxml.com/extensions/author')] | @*"/>
        </xsl:copy>        
    </xsl:template>
    
    <xsl:template match="*:table-row">
        <xsl:copy>
            <!-- Avoid all track changes information placed directly in row -->
            <xsl:apply-templates select="node()[not(namespace-uri() = 'http://www.oxygenxml.com/extensions/author')] | @*"/>
        </xsl:copy>        
    </xsl:template>
    
    <xsl:template match="*:table-body">
        <xsl:copy>
            <!-- Avoid all track changes information placed directly in table-body -->
            <xsl:apply-templates select="node()[not(namespace-uri() = 'http://www.oxygenxml.com/extensions/author')] | @*"/>
        </xsl:copy>        
    </xsl:template>

    <xsl:template match="*:table-header">
        <xsl:copy>
            <!-- Avoid all track changes information placed directly in table-body -->
            <xsl:apply-templates select="node()[not(namespace-uri() = 'http://www.oxygenxml.com/extensions/author')] | @*"/>
        </xsl:copy>        
    </xsl:template>

    <xsl:template match="*:cell">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <!-- Copy also change tracking information located before the cell. -->
            <xsl:apply-templates select="preceding-sibling::node()[namespace-uri() = 'http://www.oxygenxml.com/extensions/author']"/>    
            <xsl:apply-templates select="node()"/>
            <!-- Copy also change tracking information located after the cell. -->
            <xsl:apply-templates select="following-sibling::node()[namespace-uri() = 'http://www.oxygenxml.com/extensions/author']"/>
        </xsl:copy>        
    </xsl:template>
    
    <!--Avoid directly outputting oxy elements inside it-->
    <xsl:template match="fo:flow[oxy:*]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:for-each-group select="*" group-adjacent="namespace-uri() = 'http://www.oxygenxml.com/extensions/author'">
                <xsl:choose>
                    <xsl:when test="namespace-uri(current-group()[1]) = 'http://www.oxygenxml.com/extensions/author'">
                        <xsl:variable name="content">
                            <xsl:apply-templates select="current-group()"/>
                        </xsl:variable>
                        <xsl:if test="normalize-space($content)">
                            <fo:block>
                                <fo:inline>
                                    <xsl:copy-of select="$content"/>
                                </fo:inline>    
                            </fo:block>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>