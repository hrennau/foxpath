<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:opentopic="http://www.idiominc.com/opentopic"
                xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties"
                xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes"
                xmlns:x="com.elovirta.ooxml"
                version="2.0"
                exclude-result-prefixes="x xs opentopic">
                
  <xsl:template match="/">
    <Properties>
      <Template>Normal.dotm</Template>
      <Application>DITA-OT</Application>
      <Company>Corporation</Company>
      <LinksUpToDate>false</LinksUpToDate>
    </Properties>
  </xsl:template>
  
</xsl:stylesheet>