<?xml version="1.0" encoding="UTF-8"?>
<!--
    Copyright 2001-2017 Syncro Soft SRL. All rights reserved.
--> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">
    
    <xsl:import href="convert-resource-to-reference.xsl"/>
    
    <xsl:template match="*[( self::body or self::conbody or self::refbody or self::taskbody or self::troublebody )]">
        <refbody>
            <xsl:apply-templates select="@*"></xsl:apply-templates>
            <xsl:for-each-group select="child::*" group-adjacent="boolean( self::section or self::refsyn or self::prereq or self::context or self::steps-informal or self::tasktroubleshooting or self::result or self::postreq or self::condition or self::cause or self::remedy )">
                <xsl:choose>
                    <xsl:when test="current-grouping-key()">
                         <xsl:apply-templates select="current-group()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <section>
                             <xsl:apply-templates select="current-group()"/>
                        </section>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </refbody>
    </xsl:template>
    
    <xsl:template match="*[ self::section or self::refsyn or self::prereq or self::context or self::steps-informal or self::tasktroubleshooting or self::result or self::postreq or self::condition or self::cause or self::remedy ]">
        <section>
            <xsl:apply-templates select="@*|node()"/>
        </section>
    </xsl:template>
    
</xsl:stylesheet>