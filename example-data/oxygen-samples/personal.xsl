<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:p="http://www.oxygenxml.com/ns/samples/personal"
    exclude-result-prefixes="p">
    <xsl:template match="/">
        <html>
            <head>
                <title>Employees</title>
                <style type="text/css">
                    body {
                        font-family: Helvetica, Arial, sans-serif;
                    }

                    .header {
                        color: #FFFFFF;
                    }
                </style>
            </head>
                
            <xsl:element name="table">
                <xsl:attribute name="border">1</xsl:attribute>
                <tr class="header">
                    <xsl:attribute name="bgcolor">#336666</xsl:attribute>
                    <xsl:attribute name="align">center</xsl:attribute>
                    <td>
                        <font face="Arial" size="3">
                            <b>Name</b>
                        </font>
                    </td>
                    <td>
                        <font face="verdana" size="3">
                            <b>Email</b>
                        </font>
                    </td>
                    <td>
                        <font face="verdana" size="3">
                            <b>Link</b>
                        </font>
                    </td>
                </tr>
                <xsl:apply-templates/>
            </xsl:element>
        </html>
    </xsl:template>
    <xsl:template match="//p:person">
        <xsl:element name="tr">
            <xsl:attribute name="align">center</xsl:attribute>
            <xsl:element name="td">
                <xsl:attribute name="width">120</xsl:attribute>
                <font face="verdana" size="3">
                    <i>
                        <xsl:value-of select="p:name/p:family/text()"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="p:name/p:given/text()"/>
                    </i>
                </font>
            </xsl:element>
            <xsl:element name="td">
                <xsl:attribute name="width">120</xsl:attribute>
                <font face="verdana" size="3">
                    <xsl:value-of select="p:email/text()"/>
                </font>
            </xsl:element>
            <xsl:element name="td">
                <font color="black" face="verdana" size="3">
                    <xsl:value-of select="./p:link/@subordinates"/>
                    <xsl:value-of select="./p:link/@manager"/>
                </font>
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
