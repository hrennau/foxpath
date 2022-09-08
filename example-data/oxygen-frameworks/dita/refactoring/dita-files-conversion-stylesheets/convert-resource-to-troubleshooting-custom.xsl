<?xml version="1.0" encoding="UTF-8"?>
<!--
  Copyright 2001-2017 Syncro Soft SRL. All rights reserved.
 --> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">
    
    <xsl:import href="convert-resource-to-troubleshooting.xsl"/>
    
    <!-- Wrap groups formed by not section specializations with  troubleSolution-->
    <xsl:template match="*[( self::body or self::conbody or self::refbody or self::taskbody or self::troublebody )]">
        <troublebody>
            <xsl:choose>
                <xsl:when test=" child::section or child::refsyn or child::prereq or child::context or child::steps-informal or child::tasktroubleshooting or child::result or child::postreq or child::condition or child::cause or child::remedy ">
                    <xsl:apply-templates select="@*"/>

                    <xsl:for-each-group select="child::*" group-adjacent="boolean(preceding-sibling::*[ self::section or self::refsyn or self::prereq or self::context or self::steps-informal or self::tasktroubleshooting or self::result or self::postreq or self::condition or self::cause or self::remedy ])">
                        <xsl:choose>
                            <xsl:when test="current-grouping-key()">
                                <troubleSolution>
                                    <xsl:apply-templates select="current-group()"/>
                                </troubleSolution>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="current-group()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each-group>
                    
                </xsl:when>
                <xsl:otherwise>
                    <troubleSolution>
                        <cause>
                            <xsl:apply-templates select="@*|node()"/>
                        </cause>
                    </troubleSolution>
                </xsl:otherwise>
            </xsl:choose>
        </troublebody>
    </xsl:template>    
    <xsl:template match="*[ self::bodydiv or self::conbodydiv or self::troubleSolution ]">
        <troubleSolution>
            <xsl:choose>
                <xsl:when test="child::*[ self::p or self::responsibleParty ]">
                    <cause>
                        <xsl:apply-templates select="@*|node()"/>
                    </cause>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </troubleSolution>
    </xsl:template>
    
    <xsl:template match="*[ self::section or self::refsyn or self::prereq or self::context or self::steps-informal or self::tasktroubleshooting or self::result or self::postreq or self::condition or self::cause or self::remedy ]">
        <xsl:variable name="count-preceding-section-siblings" select="count(preceding-sibling::*[ self::section or self::refsyn or self::prereq or self::context or self::steps-informal or self::tasktroubleshooting or self::result or self::postreq or self::condition or self::cause or self::remedy ])"/>
        <xsl:variable name="count-following-section-siblings" select="count(following-sibling::*[ self::section or self::refsyn or self::prereq or self::context or self::steps-informal or self::tasktroubleshooting or self::result or self::postreq or self::condition or self::cause or self::remedy ])"/>

        <xsl:choose>
            <xsl:when test="$count-preceding-section-siblings = 0">
                <condition>
                    <xsl:apply-templates select="@*|node()"></xsl:apply-templates>
                </condition>
            </xsl:when>
            <xsl:when test="$count-preceding-section-siblings = 1">
                <xsl:choose>
                    <xsl:when test="$count-following-section-siblings = 0 and not(following-sibling::*[ self::ol or self::steps or self::substeps  or  self::ul or self::steps-unordered or self::choices ])">
                        <remedy>
                            <xsl:apply-templates select="@*|node()"></xsl:apply-templates>
                        </remedy>
                    </xsl:when>
                    <xsl:otherwise>
                        <cause>
                            <xsl:apply-templates select="@*|node()"></xsl:apply-templates>
                        </cause>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <remedy>
                    <xsl:apply-templates select="@*|node()"></xsl:apply-templates>
                </remedy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="*[ self::ol or self::steps or self::substeps  or  self::ul or self::steps-unordered or self::choices ]">
        <xsl:choose>
            <xsl:when test="parent::*[1][ self::body or self::conbody or self::refbody or self::taskbody or self::troublebody ]">
                <remedy>
                    <steps>
                        <xsl:apply-templates select="@*|node()"/>
                    </steps>
                </remedy>
            </xsl:when>
            <xsl:otherwise>
                <steps>
                    <xsl:apply-templates select="@*|node()"/>
                </steps>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="*[ self::li or self::step or self::stepsection or self::substep or self::choice ]">
        <step>
            <xsl:choose>
                <xsl:when test="child::*[ self::cmd ]">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:when>
                <xsl:otherwise>
                    <cmd>
                        <xsl:apply-templates select="@*|node()"/>
                    </cmd>
                </xsl:otherwise>
            </xsl:choose>
        </step>
    </xsl:template>
    
	 <xsl:template match="p">
        <p>
            <xsl:apply-templates select="@*|node()"/>
        </p>
    </xsl:template>
</xsl:stylesheet>