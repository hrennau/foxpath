<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">  
  
  <xsl:include href="common.xsl"/>
    
  <xsl:template match="/*:Submitter[not(*:FirstName)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="*:Identifier"> 
          <xsl:apply-templates select="node()" mode="insertAfterTarget">
            <xsl:with-param name="target" select="(*:Identifier)[last()]" tunnel="yes"/>
          </xsl:apply-templates>        
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="addElement"/>
          <xsl:apply-templates select="node()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="addElement">
    <xsl:element name="FirstName" namespace="{namespace-uri()}">${caret}</xsl:element>
  </xsl:template>
   
</xsl:stylesheet>