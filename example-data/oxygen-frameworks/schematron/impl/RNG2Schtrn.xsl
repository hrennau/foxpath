<?xml version="1.0" encoding="UTF-8"?>
<!--
	Stylesheet for extracting Schematron information from a RELAX-NG schema.
	Based on the stylesheet for extracting Schematron information from W3C XML Schema.
	Created by Eddie Robertsson 2002/06/01
-->
<!-- 
	2007/04/24      George Bina: Handle both ISO Schematron and old Schematron schemas
-->
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:sch="http://www.ascc.net/xml/schematron" 
	xmlns:rng="http://relaxng.org/ns/structure/1.0"
	xmlns:iso="http://purl.oclc.org/dsdl/schematron"
	xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
	exclude-result-prefixes="sch iso rng">
	<!-- Set the output to be XML with an XML declaration and use indentation -->
	<xsl:output method="xml" omit-xml-declaration="no" indent="yes" standalone="yes"/>
	<!-- -->
	<!-- match schema and call recursive template to extract included schemas -->
	<!-- -->
	<xsl:template match="/rng:grammar | /rng:element">
		<!-- call the schema definition template ... -->
		<xsl:call-template name="gatherSchemaRNG">
			<!-- ... with current node as the $schemas parameter ... -->
			<xsl:with-param name="schemas" select="."/>
			<!-- ... and any includes in the $include parameter -->
			<xsl:with-param name="includes" select="document(//rng:include/@href
| //rng:externalRef/@href)"/>
		</xsl:call-template>
	</xsl:template>
	<!-- -->
	<!-- gather all included schemas into a single parameter variable -->
	<!-- -->
	<xsl:template name="gatherSchemaRNG">
		<xsl:param name="schemas"/>
		<xsl:param name="includes"/>
		<xsl:choose>
			<xsl:when test="count($schemas) &lt; count($schemas | $includes)">
				<!-- when $includes includes something new, recurse ... -->
				<xsl:call-template name="gatherSchemaRNG">
					<!-- ... with current $includes added to the $schemas parameter ... -->
					<xsl:with-param name="schemas" select="$schemas | $includes"/>
					<!-- ... and any *new* includes in the $include parameter -->
					<xsl:with-param name="includes" select="document($includes/rng:grammar/rng:include/@href
| $includes//rng:externalRef/@href)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- we have the complete set of included schemas, so now let's output the embedded schematron -->
				<xsl:call-template name="outputRNG">
					<xsl:with-param name="schemas" select="$schemas"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- -->
	<!-- output the schematron information -->
	<!-- -->
	<xsl:template name="outputRNG">
		<xsl:param name="schemas"/>
		<!-- -->
		<xsl:choose>
			<xsl:when test="$schemas//iso:*">
				<iso:schema>
					<xsl:attribute name="queryBinding" select="if ($defaultQueryBinding) then $defaultQueryBinding else 'xslt2'"/>
					<!-- get header-type elements - eg title and especially ns -->
					<!-- title (just one) -->
					<xsl:apply-templates mode="copyAndAddLocationAttributes" select="($schemas//iso:title)[1]"/>
					
					<!-- Get the XSL and SQF elements -->
					<xsl:call-template name="getXSLSQFInRNG">
						<xsl:with-param name="schemas" select="$schemas"/>
					</xsl:call-template>
					
					<!-- get remaining schematron schema children -->
					<!-- get non-blank namespace elements, dropping duplicates -->
					<xsl:for-each select="$schemas//iso:ns">
						<xsl:if test="generate-id(.) = generate-id($schemas//iso:ns[@prefix = current()/@prefix][1])">
							<xsl:apply-templates mode="copyAndAddLocationAttributes" select="."/>
						</xsl:if>
					</xsl:for-each>
					<xsl:apply-templates mode="copyAndAddLocationAttributes" select="$schemas//iso:phase"/>
					<xsl:apply-templates mode="copyAndAddLocationAttributes" select="$schemas//iso:pattern"/>
					<xsl:variable name="allDiagnostics" select="$schemas//iso:diagnostics/*"/>
					<xsl:if test="count($allDiagnostics) > 0">
						<iso:diagnostics>
							<xsl:apply-templates mode="copyAndAddLocationAttributes" select="$allDiagnostics"/>
						</iso:diagnostics>
					</xsl:if>
				</iso:schema>
			</xsl:when>
			<xsl:otherwise>
				<sch:schema>
					<!-- get header-type elements - eg title and especially ns -->
					<!-- title (just one) -->
					<xsl:apply-templates mode="copyAndAddLocationAttributes" select="($schemas//sch:title)[1]"/>
					
					<!-- Get the XSL and SQF elements -->
					<xsl:call-template name="getXSLSQFInRNG">
						<xsl:with-param name="schemas" select="$schemas"/>
					</xsl:call-template>
					
					<!-- get remaining schematron schema children -->
					<!-- get non-blank namespace elements, dropping duplicates -->
					<xsl:for-each select="$schemas//sch:ns">
						<xsl:if test="generate-id(.) = generate-id($schemas//sch:ns[@prefix = current()/@prefix][1])">
							<xsl:apply-templates mode="copyAndAddLocationAttributes" select="."/>
						</xsl:if>
					</xsl:for-each>
					<xsl:apply-templates mode="copyAndAddLocationAttributes" select="$schemas//sch:phase"/>
					<xsl:apply-templates mode="copyAndAddLocationAttributes" select="$schemas//sch:pattern"/>
					<xsl:variable name="allDiagnostics" select="$schemas//sch:diagnostics/*"/>
					<xsl:if test="count($allDiagnostics) > 0">
						<sch:diagnostics>
							<xsl:apply-templates mode="copyAndAddLocationAttributes" select="$allDiagnostics"/>
					</sch:diagnostics>
					</xsl:if>
				</sch:schema>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Output the XSL and SQF elements -->
	<xsl:template name="getXSLSQFInRNG">
		<xsl:param name="schemas"/>
		<!-- Get the XSL elements -->
		<xsl:apply-templates select="$schemas//xsl:import" mode="copyAndAddLocationAttributes"/>
		<xsl:apply-templates select="$schemas//xsl:import-schema" mode="copyAndAddLocationAttributes"/>
		<xsl:apply-templates select="$schemas//xsl:strip-space" mode="copyAndAddLocationAttributes"/>
		<xsl:apply-templates select="$schemas//xsl:preserve-space" mode="copyAndAddLocationAttributes"/>
		<xsl:apply-templates select="$schemas//xsl:decimal-format" mode="copyAndAddLocationAttributes"/>
		<xsl:apply-templates select="$schemas//xsl:attribute-set" mode="copyAndAddLocationAttributes"/>
		<xsl:apply-templates select="$schemas//xsl:character-map" mode="copyAndAddLocationAttributes"/>
		<xsl:apply-templates select="$schemas//xsl:key" mode="copyAndAddLocationAttributes"/>
		<xsl:apply-templates select="$schemas//xsl:variable[not(ancestor::xsl:function or
			ancestor::xsl:template)]" mode="copyAndAddLocationAttributes"/>
		<xsl:apply-templates select="$schemas//xsl:function" mode="copyAndAddLocationAttributes"/>
		<xsl:apply-templates select="$schemas//xsl:template" mode="copyAndAddLocationAttributes"/>
		
		<!-- Get the SQF fixes -->
		<xsl:apply-templates select="$schemas//sqf:fixes" mode="copyAndAddLocationAttributes"/>
	</xsl:template>
</xsl:transform>