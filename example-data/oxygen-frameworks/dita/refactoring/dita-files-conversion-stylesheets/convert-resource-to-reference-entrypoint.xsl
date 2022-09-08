<?xml version="1.0" encoding="UTF-8"?>
<!--
  Copyright 2001-2017 Syncro Soft SRL. All rights reserved.
 --> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="xs"
    version="3.0">

    <xsl:output method="xml"/>
    
    <xsl:import href="handle-schema-conversion.xsl"/>
    <xsl:import href="convert-resource-to-reference-custom.xsl"/>
    <xsl:import href="handle-convert-to-self.xsl"/>
    
    <xsl:variable name="root-element" select="'reference'"/>
    <xsl:variable name="public-literal-target" select="'-//OASIS//DTD DITA Reference//EN'"/>
    <xsl:variable name="system-literal-target" select="'reference.dtd'"/>
    
    <!-- Schema-location and xml-model-location variables are optional. 
         When are missing the input locations will be processed
         by replace trailing '\w&.extension' with '$root-element.extension',
         where extension is 'xsd' for schema-location and 'rng' for xml-model -->
    <xsl:variable name="schema-location" select="'urn:oasis:names:tc:dita:xsd:reference.xsd'"/>
    <xsl:variable name="xml-model-location" select="'urn:oasis:names:tc:dita:rng:reference.rng'"/>
    
    <xsl:template match="@xsi:noNamespaceSchemaLocation">
        <xsl:call-template name="convert-schema-location"></xsl:call-template>
    </xsl:template>
</xsl:stylesheet>