<?xml version="1.0" ?>
<!--
 | LICENSE: This file is part of the DITA Open Toolkit project hosted on
 |          Sourceforge.net. See the accompanying license.txt file for
 |          applicable licenses.
 *-->
<!--
 | (C) Copyright IBM Corporation 2006. All Rights Reserved.
 *-->
<xsl:stylesheet version="2.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="../ditaWriter/ditabaseOutput.xsl"/>

<xsl:import href="dbReader.xsl"/>

<xsl:output
    method="xml"
    indent="yes"
    omit-xml-declaration="no"
    standalone="no"
    doctype-public="-//OASIS//DTD DITA Composite//EN"
    doctype-system="../../../../dtd/ditabase.dtd"/>

<xsl:template match="/">
  <dita>
    <xsl:apply-templates select="." mode="topic.topic.in"/>
  </dita>
</xsl:template>

</xsl:stylesheet>
