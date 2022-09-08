<?xml version="1.0" encoding="UTF-8"?>
<!--
  Copyright 2001-2017 Syncro Soft SRL. All rights reserved.
 --> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:xr="http://www.oxygenxml.com/ns/xmlRefactoring"
    xmlns:xrf="http://www.oxygenxml.com/ns/xmlRefactoring/functions"
    xmlns:r="http://www.oxygenxml.com/ns/xmlRefactoring/functions/regex"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" version="3.0">

    <xsl:import href="reg-ex.xsl"/>
    <xsl:param name="schema-location"/>
    <xsl:param name="xml-model-location"/>
    
    <!-- 
        Converts to target-topic the xsd schema locatin.
    -->
    <xsl:template name="convert-schema-location">
        <xsl:attribute name="xsi:noNamespaceSchemaLocation">
            <xsl:choose>
                <xsl:when test="$schema-location">
                    <xsl:value-of select="$schema-location"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="value">
                        <xsl:value-of select="."/>
                    </xsl:variable>
                    <xsl:value-of select="replace($value, '[a-zA-Z]+\.xsd', concat($root-element, '.xsd'))"/>        
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <!--
         Converts to target-topic the DOCTYPE and xml-model declaration.
    -->
    <xsl:template name="convert-header">
        
        <xsl:if test="not(/*/@xsi:noNamespaceSchemaLocation)">
            <xsl:variable name="header" as="xs:string" select="xrf:get-content-before-root()"/>

            <xsl:choose>
                <!-- DOCTYPE -->
                <xsl:when test="contains($header, '!DOCTYPE')">

                    <!-- Convert the DOCTYPE -->
                    <xsl:variable name="converted-header">
                        <xsl:analyze-string select="$header" regex="{r:doctype-regex()}" flags="ims">
                            <xsl:matching-substring>
                                <xsl:variable name="doctype" select="." as="xs:string"/>

                                <!-- Extract the internal subset within the DOCTYPE !-->
                                <xsl:variable name="internal-subset" as="xs:string">
                                    <xsl:choose>
                                        <xsl:when test="contains($doctype, '[')">
                                            <xsl:analyze-string select="." regex="\[[^\]]*\]">
                                                <xsl:matching-substring>
                                                    <xsl:value-of select="concat(' ', .)"/>
                                                </xsl:matching-substring>
                                            </xsl:analyze-string>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="''"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>

                                <xsl:value-of
                                    select="concat('&lt;!DOCTYPE ', $root-element, ' PUBLIC &quot;', $public-literal-target, '&quot; &quot;', $system-literal-target, '&quot;', $internal-subset, '&gt;')"
                                />
                            </xsl:matching-substring>

                            <!-- Copy everything else -->
                            <xsl:non-matching-substring>
                                <xsl:value-of select="."/>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:variable>
                    
                    <xsl:comment>
                    <xsl:value-of
                        select="xrf:set-content-before-root(string-join($converted-header))"/>
                    </xsl:comment>
                </xsl:when>


                <!-- xml-model -->
                <xsl:otherwise>
                    <xsl:variable name="converted-header">
                        <xsl:analyze-string select="$header" regex="{r:xml-model-pi-regex()}" flags="ims">
                            <xsl:matching-substring>
                                <xsl:variable name="sq">'</xsl:variable>
                                <xsl:variable name="href" select="concat('href\s*=\s*', '(', $sq, '[^', $sq, ']+\.rng', $sq, ') |', '(&quot;[^&quot;]+\.rng&quot;)')"/>
                                
                                <xsl:choose>
                                    <xsl:when test="matches(., $href)">
                                        <xsl:choose>
                                            <xsl:when test="$xml-model-location">
                                                <xsl:value-of select="replace(., 'href.+\.rng.', concat('href=', '&quot;', $xml-model-location, '&quot;'))"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="replace(., '[a-zA-Z]+\.rng', concat($root-element, '.rng'))"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- Copy everything else -->
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:matching-substring>

                            <!-- Copy everything else -->
                            <xsl:non-matching-substring>
                                <xsl:value-of select="."/>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:variable>
                    <xsl:comment>
                        <xsl:value-of select="xrf:set-content-before-root(string-join($converted-header))"/>
                    </xsl:comment>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
