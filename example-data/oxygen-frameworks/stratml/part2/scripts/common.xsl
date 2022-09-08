<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  version="2.0">

  <xsl:template match="node() | @*" mode="#all">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="text()" mode="clear"/>
  <xsl:template match="*:Identifier" mode="clear">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:call-template name="generateID"/>
    </xsl:copy>
  </xsl:template>
  
  
  <xsl:template name="addElementAsFirstChild">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="addElement"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*" mode="insertAfterTarget">
    <xsl:param name="target" as="node()" tunnel="yes"/>
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
    <xsl:if test="generate-id($target) = generate-id(.)">
      <xsl:call-template name="addElement"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="addElement"/>

  <xsl:template name="generateID">
    <xsl:text>ID-${uuid}</xsl:text>
  </xsl:template>

</xsl:stylesheet>