<?xml version="1.0" encoding="UTF-8"?>
<!--
        based on an original transform by Eddie Robertsson
        2001/04/21      fn: added support for included schemas
        2001/06/27      er: changed XMl Schema prefix from xsd: to xs: and changed to the Rec namespace
-->
<!-- 
        2007/04/24      George Bina: Handle both ISO Schematron and old Schematron schemas
-->
<xsl:transform version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
        xmlns:sch="http://www.ascc.net/xml/schematron" 
        xmlns:iso="http://purl.oclc.org/dsdl/schematron"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
        exclude-result-prefixes="sch iso xs"
        >
        <!-- Set the output to be XML with an XML declaration and use indentation -->
        <xsl:output method="xml" omit-xml-declaration="no" indent="yes" standalone="yes"/>
        <!-- -->
        <!-- match schema and call recursive template to extract included schemas -->
        <!-- -->
        <xsl:template match="/xs:schema">
                <!-- call the schema definition template ... -->
                <xsl:call-template name="gatherSchemaXSD">
                        <!-- ... with current current root as the $schemas parameter ... -->
                        <xsl:with-param name="schemas" select="/"/>
                        <!-- ... and any includes in the $include parameter -->
                        <xsl:with-param name="includes" 
                                select="document(/xs:schema/xs:*[self::xs:include or self::xs:import or self::xs:redefine or self::xs:override]/@schemaLocation)"/>
                </xsl:call-template>
        </xsl:template>
        <!-- -->
        <!-- gather all included schemas into a single parameter variable -->
        <!-- -->
        <xsl:template name="gatherSchemaXSD">
                <xsl:param name="schemas"/>
                <xsl:param name="includes"/>
                <xsl:choose>
                        <xsl:when test="count($schemas) &lt; count($schemas | $includes)">
                                <!-- when $includes includes something new, recurse ... -->
                                <xsl:call-template name="gatherSchemaXSD">
                                        <!-- ... with current $includes added to the $schemas parameter ... -->
                                        <xsl:with-param name="schemas" select="$schemas | $includes"/>
                                        <!-- ... and any *new* includes in the $include parameter -->
                                        <xsl:with-param name="includes" 
                                                select="document($includes/xs:schema/xs:*[self::xs:include or self::xs:import or self::xs:redefine or self::xs:override]/@schemaLocation)"/>
                                </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                                <!-- we have the complete set of included schemas, 
                                        so now let's output the embedded schematron -->
                                <xsl:call-template name="outputXSD">
                                        <xsl:with-param name="schemas" select="$schemas"/>
                                </xsl:call-template>
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:template>
        <!-- -->
        <!-- output the schematron information -->
        <!-- -->
        <xsl:template name="outputXSD">
                <xsl:param name="schemas"/>
                <!-- -->
                <xsl:choose>
                        <!-- Check if we have elements in the ISO namespace -->
                        <xsl:when test="$schemas//iso:*">
                                <iso:schema>
                                        <xsl:attribute name="queryBinding" select="if ($defaultQueryBinding) then $defaultQueryBinding else 'xslt2'"/>
                                        
                                        <!-- get header-type elements - eg title and especially ns -->
                                        <!-- title (just one) -->
                                        <xsl:apply-templates select="$schemas//xs:appinfo/iso:title[1]" mode="copyAndAddLocationAttributes"/>
                                        
                                        <!-- Get the XSL and SQF elements -->
                                        <xsl:call-template name="getXSLSQFInXSD">
                                                <xsl:with-param name="schemas" select="$schemas"/>
                                        </xsl:call-template>
                                        
                                        <!-- get remaining schematron schema children -->
                                        <!-- get non-blank namespace elements, dropping duplicates -->
                                        <xsl:for-each select="$schemas//xs:appinfo/iso:ns">
                                                <xsl:if test="generate-id(.) = 
                                                        generate-id($schemas//xs:appinfo/iso:ns[@prefix = current()/@prefix][1])">
                                                        <xsl:apply-templates select="." mode="copyAndAddLocationAttributes"/>
                                                </xsl:if>
                                        </xsl:for-each>
                                        <xsl:apply-templates select="$schemas//xs:appinfo/iso:phase" mode="copyAndAddLocationAttributes"/>
                                        <xsl:apply-templates select="$schemas//xs:appinfo/iso:pattern" mode="copyAndAddLocationAttributes"/>
                                        <iso:diagnostics>
                                                <xsl:apply-templates select="$schemas//xs:appinfo/iso:diagnostics/*" mode="copyAndAddLocationAttributes"/>
                                        </iso:diagnostics>
                                </iso:schema>
                        </xsl:when>
                        <xsl:otherwise>
                                <sch:schema>
                                        <!-- Get the XSL and SQF elements -->
                                        <xsl:call-template name="getXSLSQFInXSD">
                                                <xsl:with-param name="schemas" select="$schemas"/>
                                        </xsl:call-template>
                                        
                                        <!-- get header-type elements - eg title and especially ns -->
                                        <!-- title (just one) -->
                                        <xsl:apply-templates select="$schemas//xs:appinfo/sch:title[1]" mode="copyAndAddLocationAttributes"/>
                                        <!-- get remaining schematron schema children -->
                                        <!-- get non-blank namespace elements, dropping duplicates -->
                                        <xsl:for-each select="$schemas//xs:appinfo/sch:ns">
                                                <xsl:if test="generate-id(.) = 
                                                        generate-id($schemas//xs:appinfo/sch:ns[@prefix = current()/@prefix][1])">
                                                        <xsl:apply-templates select="." mode="copyAndAddLocationAttributes"/>
                                                </xsl:if>
                                        </xsl:for-each>
                                        <xsl:apply-templates select="$schemas//xs:appinfo/sch:phase" mode="copyAndAddLocationAttributes"/>
                                        <xsl:apply-templates select="$schemas//xs:appinfo/sch:pattern" mode="copyAndAddLocationAttributes"/>
                                        <sch:diagnostics>
                                                <xsl:apply-templates select="$schemas//xs:appinfo/sch:diagnostics/*" mode="copyAndAddLocationAttributes"/>
                                        </sch:diagnostics>
                                </sch:schema>                
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:template>
        
        <!-- Output the XSL and SQF elements -->
        <xsl:template name="getXSLSQFInXSD">
                <xsl:param name="schemas"/>
                <!-- Get the XSL elements -->
                <xsl:apply-templates select="$schemas//xs:appinfo/xsl:import" mode="copyAndAddLocationAttributes"/>
                <xsl:apply-templates select="$schemas//xs:appinfo/xsl:import-schema" mode="copyAndAddLocationAttributes"/>
                <xsl:apply-templates select="$schemas//xs:appinfo/xsl:strip-space" mode="copyAndAddLocationAttributes"/>
                <xsl:apply-templates select="$schemas//xs:appinfo/xsl:preserve-space" mode="copyAndAddLocationAttributes"/>
                <xsl:apply-templates select="$schemas//xs:appinfo/xsl:decimal-format" mode="copyAndAddLocationAttributes"/>
                <xsl:apply-templates select="$schemas//xs:appinfo/xsl:attribute-set" mode="copyAndAddLocationAttributes"/>
                <xsl:apply-templates select="$schemas//xs:appinfo/xsl:character-map" mode="copyAndAddLocationAttributes"/>
                <xsl:apply-templates select="$schemas//xs:appinfo/xsl:key" mode="copyAndAddLocationAttributes"/>
                <xsl:apply-templates select="$schemas//xs:appinfo/xsl:variable" mode="copyAndAddLocationAttributes"/>
                <xsl:apply-templates select="$schemas//xs:appinfo/xsl:function" mode="copyAndAddLocationAttributes"/>
                <xsl:apply-templates select="$schemas//xs:appinfo/xsl:template" mode="copyAndAddLocationAttributes"/>
                
                <!-- Get the SQF fixes -->
                <xsl:apply-templates select="$schemas//xs:appinfo/sqf:fixes" mode="copyAndAddLocationAttributes"/>
        </xsl:template>
        <!-- -->
</xsl:transform>