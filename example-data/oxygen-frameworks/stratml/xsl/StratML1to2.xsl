<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0"
  xmlns:p1="http://www.stratml.net"
  xmlns:p2="http://www.stratml.net/PerformancePlanOrReport">

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
    <xsl:element name="{local-name()}" namespace="http://www.stratml.net/PerformancePlanOrReport">
      <xsl:apply-templates select="node() | @*"/>
    </xsl:element>
  </xsl:template>

  <!-- Old root element should be converted to the new root element -->
  <xsl:template match="*:StrategicPlan">
    <xsl:element name="PerformancePlanOrReport" namespace="http://www.stratml.net/PerformancePlanOrReport">
      <xsl:attribute name="Type" select="'Strategic_Plan'"/>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:element>
  </xsl:template>


  <!-- Extract Submitter outside the AdministrativeInformation  -->
  <xsl:template match="*:AdministrativeInformation">
    <xsl:element name="{local-name()}" namespace="http://www.stratml.net/PerformancePlanOrReport">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="node()[not(self::*:Submitter)]"/>
    </xsl:element>
    <xsl:apply-templates select="*:Submitter"/>
  </xsl:template>
  
  <xsl:template match="*:GivenName">
    <xsl:element name="FirstName" namespace="http://www.stratml.net/PerformancePlanOrReport">
      <xsl:apply-templates select="node() | @*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="*:Surname">
    <xsl:element name="LastName" namespace="http://www.stratml.net/PerformancePlanOrReport">
      <xsl:apply-templates select="node() | @*"/>
    </xsl:element>
  </xsl:template>
  
</xsl:stylesheet>
