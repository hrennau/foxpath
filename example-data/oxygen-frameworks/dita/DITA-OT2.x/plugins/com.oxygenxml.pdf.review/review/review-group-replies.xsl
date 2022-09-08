<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:saxon="http://saxon.sf.net/"
    xmlns:ImageInfo="java:ImageInfo" exclude-result-prefixes="#all ">


    
    <xsl:param name="show.changes.and.comments" select="'no'"/>
    
    <xsl:template match="/">
        <xsl:apply-templates mode="structureReplies"/>
    </xsl:template>
    
    <xsl:variable name="hrid2nr">
            <xsl:for-each
                select="//*:oxy-range-start[not(@hr_id = following-sibling::*:oxy-comment[*:oxy-comment-parent-id]/@hr_id)]">                
                <mapping id="{@hr_id}" nr="{position()}"/>
            </xsl:for-each>
    </xsl:variable>
    
    <!-- Do not generate anything for the replies. These are processed by 
         the main/initial comments or changes. -->
    <xsl:template
        match="*[*:oxy-comment-parent-id]"
        mode="structureReplies"/>


    <!-- Remove oxy-range-start/oxy-range-end that belong to replies. Are not relevant. -->
    <xsl:template
        match="*:oxy-range-start[@hr_id = following-sibling::*:oxy-comment[*:oxy-comment-parent-id]/@hr_id]"
        mode="structureReplies"/>  
    <xsl:template match="*:oxy-range-end"
        mode="structureReplies">
        <xsl:variable name="hr_id" select="@hr_id"/>
        <xsl:choose>
            <xsl:when test="//*:oxy-comment[*:oxy-comment-parent-id][@hr_id  = $hr_id]">
                <!-- Belongs to a reply. Not relevant -->
            </xsl:when>
            <xsl:otherwise>
                <!-- Normal range end, copy and renumber -->
                <xsl:call-template name="copyAndRenumber"/>
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:template>    

    <!-- Renumber the remaining ranges. -->
    <xsl:template match="*:oxy-range-start" mode="structureReplies">
        <xsl:call-template name="copyAndRenumber"/>
    </xsl:template>
    
    <xsl:template name="copyAndRenumber">
        <xsl:copy>            
            <xsl:call-template name="copyAttributesAndRenumber"/>
            <xsl:copy-of select="*"/>            
        </xsl:copy>        
    </xsl:template>
    
    <xsl:template name="copyAttributesAndRenumber" >
        <xsl:copy-of select="@*[not(name() = 'hr_id')]"/>
        <xsl:variable name="hrid" select="@hr_id"/>
        <!--EXM-37601 take only the first matched ID, there can be more...-->
        <xsl:variable name="nr" select="($hrid2nr/mapping[@id = $hrid]/@nr)[1]"/>
        <xsl:attribute name="hr_id" select="$nr"/>
    </xsl:template>
    
    
    
    <!-- Match a main comment or a change that does not have a parentID , 
        but defines an ID. -->    
    <xsl:template
        match="
        *[
        local-name() = 'oxy-comment' or 
        local-name() = 'oxy-insert' or 
        local-name() = 'oxy-delete' or 
        local-name() = 'oxy-attributes']
        [*:oxy-comment-id][not(*:oxy-comment-parent-id)]"
        mode="structureReplies">


        <!-- Put in a variable the range of possible replies, i.e all the oxy metainformation adjacent to the change. -->
        <xsl:variable name="range"
            select="
                . |
                following-sibling::*:oxy-comment[
                    preceding-sibling::*[1][starts-with(local-name(), 'oxy-')]
                    ] |                
                preceding-sibling::*:oxy-comment[
                    following-sibling::*[1][starts-with(local-name(), 'oxy-')]
                    ]                
                "/>


        <!-- Now select all the replies. -->
        <xsl:copy>
            <xsl:call-template name="copyAttributesAndRenumber"/>
            <xsl:copy-of select="*"/>

            <xsl:call-template name="addReplies">
                <xsl:with-param name="range" select="$range"/>
                <xsl:with-param name="pid" select="*:oxy-comment-id"/>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- All other main comments or changes without replies should be copied as they are, but renumbered. -->
    <xsl:template
        match="
        *[
            local-name() = 'oxy-comment' or 
            local-name() = 'oxy-insert' or 
            local-name() = 'oxy-delete' or 
            local-name() = 'oxy-attributes']
        [not(*:oxy-comment-id)][not(*:oxy-comment-parent-id)]"
        mode="structureReplies">        
        
        <xsl:call-template name="copyAndRenumber"/>
    </xsl:template>
    

    <!-- Adds the reply having a specific parent id -->
    <xsl:template name="addReplies">
        <xsl:param name="range"/>
        <xsl:param name="pid"/>

        <xsl:if test="$pid">
            <xsl:for-each select="$range[*:oxy-comment-parent-id = $pid]">
                <xsl:sort order="ascending"
                    select="
                        xs:dateTime(
                        concat(
                        replace(*:oxy-date, '/', '-'),
                        'T',
                        string(*:oxy-hour),
                        string(*:oxy-tz)
                        ))"/>

                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:copy-of select="*"/>

                    <xsl:call-template name="addReplies">
                        <xsl:with-param name="range" select="$range"/>
                        <xsl:with-param name="pid" select="*:oxy-comment-id"/>
                    </xsl:call-template>
                </xsl:copy>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*|node()" mode="structureReplies">        
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="structureReplies"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
