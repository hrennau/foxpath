<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:df="http://dita2indesign.org/dita/functions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:htmlutil="http://dita4publishers.org/functions/htmlutil"
  xmlns:d4p="http://dita4publishers.org"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:enum="http://dita4publishers.org/enumerables"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="df xs relpath htmlutil opf dc xd enum d4p"
  version="2.0">

  <xsl:param name="d4p.numberTables" as="xs:string" select="'xxxx'"/>
  <xsl:variable name="d4p:doNumberTables" as="xs:boolean"
    select="matches($d4p.numberTables, 'yes|true|on|1', 'i')"
  />
  <xsl:param name="d4p.numberFigures" as="xs:string" select="'true'"/>
  <xsl:variable name="d4p:doNumberFigures" as="xs:boolean"
    select="matches($d4p.numberFigures, 'yes|true|on|1', 'i')"
  />

  <!-- Enumeration handling for HTML outputs -->

  <xsl:template mode="enumeration"  match="*[df:class(., 'topic/fig')][enum:title]">
    <xsl:param name="ancestorlang" as="xs:string" select="'en'"/>
    <!-- Context item should be enum:* from the collected-data

         NOTE: Within the collected data, all titles are normalized
         to enum:title with no @class attribute.
    -->
    <xsl:if test="$d4p:doNumberFigures">
      <xsl:variable name="figNumber">
        <xsl:number count="*[df:class(., 'topic/fig')][enum:title]"
          level="any"
          format="1."
        />
      </xsl:variable>
      <span class="enumeration fig-enumeration">
         <xsl:choose>      <!-- Hungarian: "1. Figure " -->
          <xsl:when test="((string-length($ancestorlang) = 5 and contains($ancestorlang, 'hu-hu')) or
                           (string-length($ancestorlang) = 2 and contains($ancestorlang, 'hu')) )">
           <xsl:value-of select="$figNumber"/><xsl:text>. </xsl:text>
           <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'Figure'"/>
           </xsl:call-template><xsl:text> </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="getVariable">
             <xsl:with-param name="id" select="'Figure'"/>
            </xsl:call-template>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$figNumber"/>
           </xsl:otherwise>
         </xsl:choose>
        <xsl:text>&#xa0;</xsl:text>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="enumeration"  match="*[df:class(., 'topic/table')][enum:title]">
    <xsl:param name="ancestorlang" as="xs:string" select="'en'"/>

    <!-- Context item should be enum:* from the collected-data

         NOTE: Within the collected data, all titles are normalized
         to enum:title with no @class attribute.
    -->
    <xsl:variable name="tableNumber">
      <xsl:number count="*[df:class(., 'topic/table')][enum:title]"
        level="any"
        format="1."
      />
    </xsl:variable>
    <xsl:if test="$d4p:doNumberTables">
      <span class="enumeration table-enumeration">
         <xsl:choose>      <!-- Hungarian: "1. Table " -->
          <xsl:when test="((string-length($ancestorlang) = 5 and contains($ancestorlang, 'hu-hu')) or
                           (string-length($ancestorlang) = 2 and contains($ancestorlang, 'hu')) )">
           <xsl:value-of select="$tableNumber"/><xsl:text>. </xsl:text>
           <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'Table'"/>
           </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
           <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'Table'"/>
           </xsl:call-template>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$tableNumber"/>
          </xsl:otherwise>
         </xsl:choose>
        <xsl:text> </xsl:text>
        <xsl:text>&#xa0;</xsl:text>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="enumeration" match="*[df:class(., 'pubmap-d/part')]"
    priority="10">
    <span class='enumeration_part'>
        <xsl:call-template name="getVariable">
          <xsl:with-param name="id" select="'Part'"/>
        </xsl:call-template>
      <!-- When maps are merged, if there are two root topicrefs, both get the class of the referencing
           topicref, e.g., <keydefs/><part/> as the children of the target map becomes two mapref topicrefs in the
           merged result. -->
      <xsl:number count="*[df:class(., 'pubmap-d/part')][not(@processing-role = 'resource-only')]" format="I" level="single"/>
      <xsl:text>. </xsl:text>
    </span>
  </xsl:template>

  <xsl:template mode="enumeration"
    match="*[df:class(., 'pubmap-d/pubbody')]//*[df:class(., 'pubmap-d/chapter')]"
    >
    <span class='enumeration_chapter'>
        <xsl:call-template name="getVariable">
          <xsl:with-param name="id" select="'Chapter'"/>
        </xsl:call-template>
      <xsl:number
        count="*[df:class(., 'pubmap-d/chapter')][not(@processing-role = 'resource-only')]"
        format="1."
        level="any"
        from="*[df:class(., 'pubmap-d/pubbody')]"/>
      <xsl:text> </xsl:text>
    </span>
  </xsl:template>

  <xsl:template mode="enumeration"
    match="*[df:class(., 'pubmap-d/frontmatter')]//*[df:class(., 'pubmap-d/chapter')] |
           *[df:class(., 'pubmap-d/backmatter')]//*[df:class(., 'pubmap-d/chapter')]">
    <!-- Frontmatter and backmatter chapters are not enumerated -->
  </xsl:template>

  <xsl:template mode="enumeration"
    match="*[df:class(., 'pubmap-d/appendix')] |
    *[df:class(., 'pubmap-d/appendixes')]/*[df:isTopicRef(.)]
    ">
    <span class='enumeration_chapter'>
        <xsl:call-template name="getVariable">
          <xsl:with-param name="id" select="'Appendix'"/>
        </xsl:call-template>
      <xsl:number
        count="*[df:class(., 'map/topicref')][not(@processing-role = 'resource-only')]"
        format="A."
        level="single"
        from="*[df:class(., 'pubmap-d/appendixes')]"/>
      <xsl:text> </xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="*" mode="report-parameters" priority="-1">
    <xsl:message>
      Common HTML Enumeration Parameters:

      + d4p.numberFigures = "<xsl:sequence select="$d4p.numberFigures"/>" (<xsl:value-of select="$d4p:doNumberFigures"/>)
      + d4p.numberTables = "<xsl:sequence select="$d4p.numberTables"/>"  (<xsl:value-of select="$d4p:doNumberTables"/>)
    </xsl:message>
  </xsl:template>


</xsl:stylesheet>
