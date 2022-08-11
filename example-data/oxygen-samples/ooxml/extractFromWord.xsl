<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xpath-default-namespace="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <xsl:output omit-xml-declaration="yes"/>

  <xsl:template match="/">
    <xsl:text>INSERT ALL </xsl:text>

    <!-- Iterates all the rows from all the tables of the document -->
    <xsl:for-each select="//tr">

      <!-- Skip the table header -->
      <xsl:if test="generate-id(.)!=generate-id(../tr[1])">
        <xsl:text>INTO conversion VALUES(</xsl:text>
        <!-- Extracts the cells -->
        <xsl:for-each select="tc">'<xsl:value-of
            select="replace(normalize-space(.),&quot;&apos;&quot;,&quot;&apos;&apos;&quot;)"
            />'<xsl:if test="position() != last()">,&#9;</xsl:if>
        </xsl:for-each>
        <xsl:text>)</xsl:text>

        <!-- Data row separators -->
        <xsl:text>
        </xsl:text>
      </xsl:if>
    </xsl:for-each>

    <xsl:text>SELECT * FROM dual</xsl:text>

  </xsl:template>

</xsl:stylesheet>
