<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:xs="http://www.w3.org/2001/XMLSchema"
      xmlns:local="urn:local-functions"
      xmlns:relpath="http://dita2indesign/functions/relpath"
      xmlns:df="http://dita2indesign.org/dita/functions"
      exclude-result-prefixes="xs local df relpath"
  version="2.0">
  <!-- Implements the generate-result-docs mode for dita2icml -->
  
  <xsl:template mode="generate-result-docs generate-manifest-entries" match="local:root">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template mode="generate-result-docs" match="local:result-document[@format]" priority="10">
    
    <!-- Process any subordinate result-document elements ... -->
<!--    <xsl:apply-templates mode="#current"/>-->
    
    <xsl:message> + [INFO] Generating result document  "<xsl:value-of
      select="relpath:unencodeUri(@href)"/>" for @format <xsl:value-of select="@format"/></xsl:message>
    <xsl:result-document href="{@href}" format="{@format}">
      <xsl:apply-templates mode="#current" select="node() except (local:result-document)"/>
    </xsl:result-document>
  </xsl:template>

  <xsl:template mode="generate-manifest-entries" match="local:result-document">
    <xsl:message> + [INFO] Generating manifest entry  "<xsl:value-of
      select="relpath:unencodeUri(@href)"/>" </xsl:message>
    <xsl:call-template name="constructManifestFileEntry">
      <xsl:with-param name="incopyFileUri" select="@href" as="xs:string"/>
    </xsl:call-template>
    <!-- Process any subordinate result-document elements ... -->
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template mode="generate-result-docs" match="local:result-document">
    <xsl:apply-templates select="local:result-document" mode="#current"/>
    <xsl:message> + [INFO] Generating result document "<xsl:value-of
      select="relpath:unencodeUri(@href)"/>"</xsl:message>
    <xsl:result-document href="{@href}">
      <xsl:apply-templates mode="#current" select="node() except (local:result-document)"/>
    </xsl:result-document>
    <xsl:call-template name="constructManifestFileEntry">
      <xsl:with-param name="incopyFileUri" select="@href" as="xs:string"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template mode="generate-result-docs" 
    match="text() | comment() | processing-instruction() | @*">
    <xsl:sequence select="."/>
  </xsl:template>
  
  <xsl:template mode="generate-manifest-entries" 
    match="text() | comment() | processing-instruction() | @*">
    <!-- Suppress in this mode -->
  </xsl:template>
  
  <xsl:template mode="generate-result-docs" match="Document">
    <xsl:element name="{name(.)}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*" mode="generate-result-docs" priority="-1">
    <xsl:copy exclude-result-prefixes="local">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*" mode="generate-manifest-entries" priority="-1">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
</xsl:stylesheet>