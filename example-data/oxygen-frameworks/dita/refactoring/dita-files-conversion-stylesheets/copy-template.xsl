<?xml version="1.0" encoding="UTF-8"?>
<!--
  Copyright 2001-2017 Syncro Soft SRL. All rights reserved.
 --> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">

    <xsl:output method="xml"/>

    <xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
    </xsl:template>
    <xsl:template match="@class"/>

</xsl:stylesheet>