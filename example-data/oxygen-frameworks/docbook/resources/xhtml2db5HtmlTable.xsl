<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:e="http://www.oxygenxml.com/xsl/conversion-elements"
        xmlns:f="http://www.oxygenxml.com/xsl/functions"
        exclude-result-prefixes="xsl e f"
        version="2.0">

  <!-- HTML table conversion -->
  
  <!-- In Docbook 5 the XHTML table elements are transformed to the elements of Docbook table. -->
  <xsl:template match="e:table[$docbook.html.table != 0]">
    <xsl:choose>
      <xsl:when test="empty(e:caption)">
        <informaltable xmlns="http://docbook.org/ns/docbook">
          <xsl:apply-templates select="@* | * | text()"/>
        </informaltable>
      </xsl:when>
      <xsl:otherwise>
        <table xmlns="http://docbook.org/ns/docbook">
          <xsl:apply-templates select="@* | * | text()"/>
        </table>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="e:colgroup[$docbook.html.table != 0]">
    <colgroup xmlns="http://docbook.org/ns/docbook">
      <xsl:if test="@span">
        <xsl:attribute name="span" select="@span"/>
      </xsl:if>
      <xsl:if test="@align">
        <xsl:attribute name="align" select="translate(@align, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
      </xsl:if>
      <xsl:if test="@width">
        <xsl:attribute name="width" select="@width"/>
      </xsl:if>
      <xsl:apply-templates select="@* | node()"/>
    </colgroup>
  </xsl:template>
  
  
  <xsl:template match="e:col[$docbook.html.table != 0]">
    <col xmlns="http://docbook.org/ns/docbook">
      <xsl:if test="@align">
        <xsl:attribute name="align" select="translate(@align, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
      </xsl:if>
      <xsl:if test="@width">
        <xsl:attribute name="width" select="@width"/>
      </xsl:if>
    </col>
  </xsl:template>
  
  <xsl:template match="e:caption[$docbook.html.table != 0] 
                                | e:thead[$docbook.html.table != 0]
                                | e:tfoot[$docbook.html.table != 0]
                                | e:tbody[$docbook.html.table != 0]
                                | e:tr[$docbook.html.table != 0]
                                | e:th[$docbook.html.table != 0]
                                | e:td[$docbook.html.table != 0]">
    <xsl:element name="{local-name()}" namespace= "http://docbook.org/ns/docbook">
      <xsl:if test="number(@rowspan)">
        <xsl:attribute name="rowspan" select="@rowspan"/>
      </xsl:if>
      <xsl:if test="number(@colspan)">
        <xsl:attribute name="colspan" select="@colspan"/>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="@align">
          <xsl:attribute name="align" select="translate(@align, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
        </xsl:when>
        <xsl:when test="e:p/@align">
          <xsl:attribute name="align" select="translate((e:p/@align)[1], 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
        </xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="@valign">
          <xsl:attribute name="valign" select="translate(@valign, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
        </xsl:when>
        <xsl:when test="e:p/@valign">
          <xsl:attribute name="valign" select="translate((e:p/@valign)[1], 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
        </xsl:when>
      </xsl:choose>
      <xsl:call-template name="keepDirection"/>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:element>
  </xsl:template>
  
</xsl:stylesheet>