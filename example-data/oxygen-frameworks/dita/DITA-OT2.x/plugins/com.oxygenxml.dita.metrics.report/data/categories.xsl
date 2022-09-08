<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Copyright 2001-2017 Syncro Soft SRL. All rights reserved.
    This is licensed under MPL 2.0. 
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:rng="http://relaxng.org/ns/structure/1.0"
    xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
    exclude-result-prefixes="xs rng a"
    version="2.0">

    <xsl:output indent="yes"/>
    <xsl:param name="relax" select="'file:/Users/george/Documents/workspace/dita-ng/RelaxNG/rng/'"/>
    
    
    <xsl:template name="main">
        <xsl:variable name="arg">
            <xsl:value-of select="$relax"/>
            <xsl:text>?select=*.rng;recurse=yes;on-error=ignore</xsl:text>
        </xsl:variable>
        <domains>
            <xsl:for-each-group group-adjacent="tokenize(document-uri(.), '/')[last()-2]" select="collection($arg)">
                <xsl:if test="current-grouping-key() != 'ditaval' and current-grouping-key() != 'xhtml'">
                    <category name="{current-grouping-key()}">
                        <xsl:for-each select="current-group()">
                            <xsl:for-each select=".//rng:element[@name]">
                                <element name="{@name}" definedIn="{substring-before(tokenize(document-uri(/), '/')[last()], '.rng')}">
                                    <xsl:choose>
                                        <xsl:when test="*[1][self::a:documentation]">
                                            <documentation>
                                                <xsl:value-of select="a:documentation"/>
                                            </documentation>
                                        </xsl:when>
                                        <xsl:when test="parent::*/preceding-sibling::node()[not(self::text())][1]
                                            [self::comment()]
                                            [starts-with(normalize-space(.), 'doc:')]">
                                            <documentation>
                                                <xsl:value-of select="substring-after(../preceding-sibling::comment()[1], 'doc:')"/>
                                            </documentation>
                                        </xsl:when>
                                    </xsl:choose>
                                </element>
                            </xsl:for-each>
                        </xsl:for-each>                    
                    </category> 
                </xsl:if>
          </xsl:for-each-group>
        </domains>
    </xsl:template>

</xsl:stylesheet>