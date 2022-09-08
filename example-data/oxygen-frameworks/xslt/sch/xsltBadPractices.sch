<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns:extr="java:ro.sync.util.xslt.XPathElementsAndAttributesExtractor">
    
    <sch:let name="XSL_NS" value="'http://www.w3.org/1999/XSL/Transform'"/>
    
    <!-- Declare the used namespaces. -->
    <sch:ns uri="http://www.w3.org/1999/XSL/Transform" prefix="xsl"/>
    <sch:ns uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>
    <sch:ns uri="java:ro.sync.util.xslt.XPathElementsAndAttributesExtractor" prefix="extr"/>
    
    <sch:pattern>
        <!-- Check each attribute if has an XPath expression that refers elements with the same name 
            as variables and parameters defined in the context. -->
        <sch:rule context="@*[namespace-uri(parent::node()) = $XSL_NS]">
            <!-- Get the refered element names from the current attribute -->
            <sch:let name="refElemNames" value="extr:getElementNames(local-name(), string())"/>
            <!-- Get the all param and variable names. -->
            <sch:let name="paramVarNames" value="preceding::xsl:param/@name | preceding::xsl:variable/@name"/>
            
            <!-- Check the elements names that conflict with existing parameter of variabiles. -->
            <sch:let name="conflictingNames" value="$refElemNames[. = $paramVarNames]"/>
            <sch:let name="conflictingNamesNo" value="count($conflictingNames)"/>
            
            <!-- Report the conflicting element references in XPath. -->
            <sch:report test="$conflictingNamesNo > 0" role="warn">
                The XPath expression references the 
                '<sch:value-of select="string-join($conflictingNames, ', ')"/>' element(s), 
                but there are already parameters/variables with the same name declared in the current context. 
                It is recommended to use different names to avoid potential problems. 
            </sch:report>
        </sch:rule>
        
        <!-- Check each Text Value Template for -->
        <sch:rule context="text()[(string-length(normalize-space(.)) > 4) and /xsl:stylesheet/@version = '3.0']" >
            <!-- Check if some ancestors have the "expand-text" attribute set, and if so, its value must be 'true', 'yes', '1'... -->
            <sch:let name="lastExpandText" value="ancestor-or-self::*/@expand-text[last()]"/>
            <sch:let name="isTVTEnabled" value="boolean($lastExpandText) and ($lastExpandText = 'yes' or $lastExpandText = 'true' or $lastExpandText = '1')"/>

            <!-- Get the refered element names from the current attribute -->
            <sch:let name="refElemNames" value="extr:getElementNames(local-name(), string())"/>
            <!-- Get the all param and variable names. -->
            <sch:let name="paramVarNames" value="preceding::xsl:param/@name | preceding::xsl:variable/@name"/>
            
            <!-- Check the elements names that conflict with existing parameter of variabiles. -->
            <sch:let name="conflictingNames" value="$refElemNames[. = $paramVarNames]"/>
            <sch:let name="conflictingNamesNo" value="count($conflictingNames)"/>
            
            <!-- Report the conflicting element references in XPath. -->
            <sch:report test="$conflictingNamesNo > 0" role="warn">
                The XPath expression from the text value template references the 
                '<sch:value-of select="string-join($conflictingNames, ', ')"/>' element(s), 
                but there are already parameters/variables with the same name declared in the current context. 
                It is recommended to use different names to avoid potential problems. 
            </sch:report>
            
        </sch:rule>
    </sch:pattern>
</sch:schema>