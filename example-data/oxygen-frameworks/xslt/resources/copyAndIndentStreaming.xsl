<?xml version="1.0" encoding="UTF-8"?>

<!--
    Copy stylesheet that performs an additional indent operation. It runs in the streaming mode.
    
    Note that the result document may be different from the initial one because:
    * the DOCTYPE declaration will not be copied in the result document;
    * all entities will be expanded in the result document;
    * default attributes declared in the DTD may be added to the result document.
    
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:output method="xml" indent="yes"/>
        
    <xsl:mode streamable="yes" on-no-match="shallow-copy"/>    
</xsl:stylesheet>