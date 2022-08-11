<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:     Variables
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    A variable can hold a result tree fragment. The operations permitted on a result tree fragment
       are a subset of those permitted on a node-set. An operation is permitted on a result tree fragment only if 
       that operation would be permitted on a string (the operation on the string may involve first converting 
       the string to a number or boolean). In particular, it is not permitted to use the /, //, and [] operators 
       on result tree fragments. When a permitted operation is performed on a result tree fragment, it is performed 
       exactly as it would be on the equivalent node-set.  -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:variable name="A1">
        <xsl:copy-of select="//TABLE[1]"/>
    </xsl:variable>
    <xsl:variable name="A2">
        <xsl:copy-of select="//TABLE[2]"/>
    </xsl:variable>
    <xsl:template match="/">
        <xsl:copy-of select="$A2"/>
        <xsl:copy-of select="$A1"/>
        <xsl:copy-of select="$A2"/>
    </xsl:template>
</xsl:stylesheet>
