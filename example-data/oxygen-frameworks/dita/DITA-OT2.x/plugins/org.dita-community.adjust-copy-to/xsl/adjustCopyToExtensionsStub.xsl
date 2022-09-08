<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:df="http://dita2indesign.org/dita/functions"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:local="urn:local-functions"
  exclude-result-prefixes="xs xd df relpath local"
  version="2.0">
  
  <!-- ========================================================
       Fallback implementation of user extension modes
       
       ======================================================== -->
  
  <xsl:template match="*" mode="generate-result-files">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes"/>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
</xsl:stylesheet>