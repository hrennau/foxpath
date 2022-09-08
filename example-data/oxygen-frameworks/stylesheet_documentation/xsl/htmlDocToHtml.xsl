<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Copyright 2001-2011 Syncro Soft SRL. All rights reserved.
 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns:h="http://www.w3.org/1999/xhtml">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Template processing elements from the XHTML namespace.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:template match="@*" mode="documentation">
        <xsl:copy>
            <xsl:apply-templates mode="documentation" select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="h:*" mode="documentation">
        <xsl:element name="{ local-name(.) }" namespace="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates mode="documentation" select="@*|node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="h:li" mode="documentation">
        <li class="doc">
            <xsl:apply-templates mode="documentation" select="@*|node()"/>
        </li>
    </xsl:template>
</xsl:stylesheet>
