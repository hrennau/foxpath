<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  >
 <!--  HTML output support for the DITA 1.3 Troubleshooting topic type and troubleshooting
       domain.
   -->
   
   <!--  Put required processing here. -->
  
  <xsl:template match="*[contains(@class, ' topic/note ')][@type = 'trouble']" mode="process.note">
    
    <!-- WEK: Note that there's a design bug in the 1.8.5 OT in that 
              string files contributed by plugins are never consulted.
              Thus even though this plugin provides a string file that
              defines a mapping for "Trouble", it is never used.
              
              Also, the formatting of the title is controlled by the CSS,
              using @class value "{type}title}. But there is no extension
              point for extending the CSS to add additional entries.
              
      -->
  <xsl:apply-templates select="." mode="process.note.common-processing">
    <!-- Force the type to note, in case new unrecognized values are added
         before translations exist (such as Warning) -->
    <xsl:with-param name="type" select="string(@type)"/>
  </xsl:apply-templates>
</xsl:template>

</xsl:stylesheet>
