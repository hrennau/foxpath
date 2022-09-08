<!-- Convert a DITA map to an json data set. 

     Extensions to this transform can override or extend any of those modes.

-->
<xsl:stylesheet version="2.0"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

 <xsl:include href="map2jsonImpl.xsl"/>
   
  <dita:extension id="xsl.transtype-json" 
    behavior="org.dita.dost.platform.ImportXSLAction" 
    xmlns:dita="http://dita-ot.sourceforge.net"/>

</xsl:stylesheet>
