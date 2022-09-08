<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:e="http://www.oxygenxml.com/xsl/conversion-elements"
        xmlns:f="http://www.oxygenxml.com/xsl/functions"
        exclude-result-prefixes="xsl e f"
        version="2.0">

  <!-- CALS table conversion -->
  <xsl:template match="e:table[$docbook.html.table = 0]">
    <xsl:variable name="tableBody">
      <tgroup>
        <xsl:variable name="columnCount">
          <xsl:for-each select="e:tr | e:tbody/e:tr | e:thead/e:tr">
            <xsl:sort select="count(e:td | e:th)" data-type="number" order="descending"/>
            <xsl:if test="position()=1">
              <xsl:value-of select="count(e:td | e:th)"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:attribute name="cols">
          <xsl:value-of select="$columnCount"/>
        </xsl:attribute>
        <xsl:if test="e:tr/e:td/@rowspan 
          | e:tr/e:td/@colspan
          | e:tbody/e:tr/e:td/@rowspan 
          | e:tbody/e:tr/e:td/@colspan
          | e:thead/e:tr/e:th/@rowspan 
          | e:thead/e:tr/e:th/@colspan">
          <xsl:call-template name="generateColspecs">
            <xsl:with-param name="count" select="number($columnCount)"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates select="e:thead"/>
        <tbody>
          <xsl:apply-templates select="e:tr | e:tbody/e:tr | text() | e:b | e:strong | e:i | e:em | e:u, e:tfoot/e:tr"/>
        </tbody>
      </tgroup>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="empty(e:caption)">
        <informaltable>
          <xsl:apply-templates select="@*"/>
          <xsl:copy-of select="$tableBody"/>
        </informaltable>
      </xsl:when>
      <xsl:otherwise>
        <table>
          <xsl:apply-templates select="@*"/>
          <xsl:copy-of select="$tableBody"/>
        </table>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <xsl:template match="e:caption[$docbook.html.table = 0]">
      <title>
        <xsl:call-template name="keepDirection"/>
        <xsl:apply-templates/>
      </title>
  </xsl:template>
  
  
  <xsl:template match="e:thead[$docbook.html.table = 0]">
    <thead>
      <xsl:apply-templates select="@* | node()"/>
    </thead>
  </xsl:template>
  
  <xsl:template match="e:tr[$docbook.html.table = 0]">
    <row>
      <xsl:apply-templates select="@* | node()"/>
    </row>
  </xsl:template>
  
  
  <xsl:template match="e:th[$docbook.html.table = 0] | e:td[$docbook.html.table = 0]">
    <xsl:variable name="position" select="count(preceding-sibling::*) + 1"/>
    <entry>
      <xsl:if test="number(@colspan) and @colspan > 1">
        <xsl:attribute name="namest">
          <xsl:value-of select="concat('col', $position)"/>
        </xsl:attribute>
        <xsl:attribute name="nameend">
          <xsl:value-of select="concat('col', $position + number(@colspan) - 1)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="number(@rowspan) and @rowspan > 1">
        <xsl:attribute name="morerows">
          <xsl:value-of select="number(@rowspan) - 1"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:call-template name="keepDirection"/>
      <xsl:apply-templates select="@* | node()"/>
    </entry>
  </xsl:template>
  
  
  <xsl:template name="generateColspecs">
    <xsl:param name="count" select="0"/>
    <xsl:param name="number" select="1"/>
    <xsl:choose>
      <xsl:when test="$count &lt; $number"/>
      <xsl:otherwise>
        <colspec>
          <xsl:attribute name="colnum">
            <xsl:value-of select="$number"/>
          </xsl:attribute>
          <xsl:attribute name="colname">
            <xsl:value-of select="concat('col', $number)"/>
          </xsl:attribute>
        </colspec>
        <xsl:call-template name="generateColspecs">
          <xsl:with-param name="count" select="$count"/>
          <xsl:with-param name="number" select="$number + 1"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>