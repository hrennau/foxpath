<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:local="urn:namespace:functions:local"

  exclude-result-prefixes="xs m local"
  >
  <!-- MathML elements to HTML -->
  
  <xsl:template match="*[contains(@class, ' mathml-d/mathml ')]">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="m:math">
    <xsl:param name="blockOrInline" as="xs:string" tunnel="yes" select="'inline'"/>
    <fo:instream-foreign-object>
      <m:math      
        >
        <xsl:if test="$blockOrInline = 'block'">
          <xsl:attribute name="display" select="'block'"/>
        </xsl:if>
        <xsl:sequence select="node()"/><!-- Just copy the math to the output -->
      </m:math>
    </fo:instream-foreign-object>
  </xsl:template>
  
  
</xsl:stylesheet>
