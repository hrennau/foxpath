<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:     Conditional processing
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    xsl:if instruction enables conditional processing.  -->
<xsl:stylesheet version = '1.0' 
     xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>

<xsl:template match="list"> 
     <xsl:for-each select="entry"> 
          <xsl:value-of select="@name"/> 
          <xsl:if test="not (position()=last())"> 
               <xsl:text>, </xsl:text> 
          </xsl:if> 
     </xsl:for-each> 
</xsl:template>


</xsl:stylesheet> 
