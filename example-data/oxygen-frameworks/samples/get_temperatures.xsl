<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns:tg="http://www.oxygenxml.com/ns/samples/travel-guide"
    xmlns:math="java:java.lang.Math"
    version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 3, 2014</xd:p>
            <xd:p>This stylesheet is being applied from an XSLTOperation in an author action.
            This action is then bounded on a form control.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output indent="yes"/>
   
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>This templates matches on the temperatures table and outputs a new table with 
            updates temperatures. The temperatures are read from a file but an alternative would be to
            connect to a REST service that gives an XML response.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tg:infoTable">
        <xsl:variable name="temps" select="doc('temperatures.xml')/temperatures/country[@name='Greece']/city[@name='Thira']"/>
        <xsl:variable name="months" select="//tg:month"></xsl:variable>
        <!-- 
            We want to make sure the temperatures change a bit any time the user will invoke the transfomation.
            This way he will have a direct feedback that something changes every time he presses the button form control.
        -->
        <xsl:variable name="seed" as="xs:integer">
            <xsl:choose>
                <xsl:when test="xs:integer(*:tr[2]/*:airT[1]/text()) &lt;= 7">3</xsl:when>
            <xsl:otherwise>-3</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
            
        <infoTable xmlns="http://www.oxygenxml.com/ns/samples/travel-guide">
            <tr>
                <th>Month</th>
                <th>Water temperature</th>
                <th>Air temperature</th>
            </tr>
            <xsl:for-each select="$months">
                <xsl:variable name="pos" select="position()"/>
                <tr>
                    <month>
                        <xsl:value-of select="."/>
                    </month>
                   <waterT>
                        <xsl:value-of select="round($temps/waterTemps/double[$pos]) + $seed"/>
                    </waterT>
                    <airT>
                        <xsl:value-of select="round($temps/airTemps/double[$pos]) + $seed"/>
                    </airT>
                </tr>
            </xsl:for-each>
        </infoTable>
    </xsl:template>
</xsl:stylesheet>