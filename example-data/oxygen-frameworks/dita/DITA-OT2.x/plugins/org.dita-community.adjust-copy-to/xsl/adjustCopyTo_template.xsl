<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="xs xd"
  version="2.0">
  
  <!-- ======================================================
       Adjust Copy-To
       
       Processes a resolved map in order to add or adjust @copy-to
       values in order to produce the desired result filenames
       or other deliverable-specific anchor ID values.
       
       Out of the box provides the following naming options:
       
       1. Unique names for reused topics.
       
       Ensures that all navigation references to a given topic
       use a distinct file name. This is required for EPUB in
       particular but may also be needed for HTML or similar
       deliveries where the publication context is important for
       all accesses to a given topic.
       
       2. Use navigation keys to construct result filenames
       
       Use the value of @keys on navigation topicrefs to determine
       result filenames. This allows key names on navigation topicrefs
       to be used to define result filenames irrespective of the
       source topic filename, thus allowing better control of 
       deliverable-specific IDs (e.g., HTML filenames).
       
       The processing can be extended in several ways. The extension
       points are:
       
       - TBD
       - TBD
       - TBD
 
       ====================================================== -->
  
  <xsl:import href="adjustCopyToImpl.xsl"/>
  <xsl:import href="adjustCopyToExtensionsStub.xsl"/>
  
  <dita:extension id="xsl.dcAdjustCopyTo" 
    behavior="org.dita.dost.platform.ImportXSLAction" 
    xmlns:dita="http://dita-ot.sourceforge.net"/>
  
</xsl:stylesheet>