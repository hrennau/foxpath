<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="3.0"
    xmlns:xr="http://www.oxygenxml.com/ns/xmlRefactoring">
    
    <!-- Specify the values as CDATA. Otherwise the values will be double escaped. -->
    <xsl:variable name="xr:ANY-VALUE" as="xs:string"><![CDATA[<ANY>]]></xsl:variable>
    <xsl:variable name="xr:NO-NAMESPACE" as="xs:string"><![CDATA[<NO_NAMESPACE>]]></xsl:variable>
    <xsl:variable name="xr:ADDITIONAL-ATTRIBUTES-NS-URI" as="xs:string"><![CDATA[http://www.oxygenxml.com/ns/xmlRefactoring/additional_attributes]]></xsl:variable>
    
    <!-- Verifies if the namespace URI matches the node's namespace URI. -->
    <xsl:function name="xr:check-namespace-uri" as="xs:boolean">
        <xsl:param name="nsUri" as="xs:string"/>
        <xsl:param name="node" as="node()"/>
        <xsl:variable name="nodeNsUri" select="namespace-uri($node)"/>
        <xsl:variable name="nsUriMatch"
            select="
                (not($nodeNsUri = $xr:ADDITIONAL-ATTRIBUTES-NS-URI) and
                ($nsUri = $xr:ANY-VALUE or ($nsUri = $xr:NO-NAMESPACE and not($nodeNsUri)) or
                $nsUri = $nodeNsUri))"/>
        <xsl:value-of select="$nsUriMatch"/>
    </xsl:function>

    <!-- Verifies if the local name matches the node's local name. -->
    <xsl:function name="xr:check-local-name" as="xs:boolean">
        <xsl:param name="localName" as="xs:string"/>
        <xsl:param name="node" as="node()"/>
        <xsl:param name="acceptsAnyValue" as="xs:boolean"/>

        <xsl:variable name="nodeLocalName" select="local-name($node)"/>
        <xsl:variable name="namesMatch"
            select="
                (($acceptsAnyValue and $localName = $xr:ANY-VALUE) or
                ($nodeLocalName = $localName))"/>
        <xsl:value-of select="$namesMatch"/>
    </xsl:function>
</xsl:stylesheet>
