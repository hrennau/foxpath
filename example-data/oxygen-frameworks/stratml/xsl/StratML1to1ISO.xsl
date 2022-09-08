<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0"
  xmlns:p1="http://www.stratml.net"
  xmlns:p2="urn:ISO:std:iso:17469:tech:xsd:stratml_core">

  <!-- Copy comments, processing instructions and attributes -->
  <xsl:template match="comment() | processing-instruction() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Do not copy xsi:schemaLocation because this points to the old schema -->
  <xsl:template match="/*/@xsi:schemaLocation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>

  <!-- Copy elements updating the element namespace -->
  <xsl:template match="*">
    <xsl:element name="{local-name()}" namespace="urn:ISO:std:iso:17469:tech:xsd:stratml_core">
      <xsl:apply-templates select="node() | @*"/>
    </xsl:element>
  </xsl:template>

  
  <!-- Handle element name changes for names -->
  <xsl:template match="*:FirstName">
    <xsl:element name="GivenName" namespace="urn:ISO:std:iso:17469:tech:xsd:stratml_core">
      <xsl:apply-templates select="node() | @*"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="*:LastName">
    <xsl:element name="Surname" namespace="urn:ISO:std:iso:17469:tech:xsd:stratml_core">
      <xsl:apply-templates select="node() | @*"/>
    </xsl:element>
  </xsl:template>
    
</xsl:stylesheet>
