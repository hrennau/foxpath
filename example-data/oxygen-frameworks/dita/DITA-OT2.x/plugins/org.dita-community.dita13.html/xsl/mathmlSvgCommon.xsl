<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:local="urn:namespace:functions:local"
  xmlns:opentopic="http://www.idiominc.com/opentopic"
  exclude-result-prefixes="xs xd m opentopic"
  version="2.0">
  <!--========================================
      Output-independent processing for 
      MathML and SVG elements.
      ======================================== -->
  
<!--======================
    MathML Processing
    ====================== -->
  <xsl:template match="*[contains(@class, ' mathml-d/mathmlref ')]" priority="100">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
        <xsl:message> + [DEBUG] mathml-d/mathmlref, href=<xsl:value-of select="@href"/></xsl:message>
        <xsl:message> + [DEBUG] mathml-d/mathmlref, keyref=<xsl:value-of select="@keyref"/></xsl:message>
    </xsl:if>
    
    <xsl:choose>
      <xsl:when test="not(@href) and not(@keyref)">
        <xsl:message> - [WARN] mathmlref: No value for @href or @keyref attribute.</xsl:message>
      </xsl:when>      
      <xsl:otherwise>
        <xsl:variable name="mathmlDoc" as="document-node()?"
          select="local:resolveRefToDocument(.)"
        />
        <xsl:variable name="fragmentId" as="xs:string?"
          select="local:getFragmentIDForXRef(.)"
        />
        <xsl:choose>
          <xsl:when test="$fragmentId = ''">
            <!-- Root of target document should be an SVG  svg:svg element -->
            <xsl:message> + [INFO] mathmlref: Processing root of document <xsl:value-of select="document-uri($mathmlDoc)"/>...</xsl:message>
            <xsl:apply-templates select="$mathmlDoc/*[1]" mode="validate-mathmldoc"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- Fragment ID should be an element ID and should be the ID 
                 of an m:math element:
              -->
            <xsl:variable name="targetElem" as="element()*" select="$mathmlDoc//*[@id = $fragmentId]"/>
            <xsl:choose>
              <xsl:when test="not($targetElem)">
                <xsl:message> - [WARN] mathmlref: Failed to find element with ID "<xsl:value-of select="$fragmentId"/> in document "<xsl:value-of select="document-uri($mathmlDoc)"/>"</xsl:message>
              </xsl:when>
              <xsl:otherwise>
                <xsl:if test="count($targetElem) > 1">
                  <xsl:message> - [WARN] mathmlref: Found <xsl:value-of select="count($targetElem)"/> elements with ID "<xsl:value-of select="$fragmentId"/> in document "<xsl:value-of select="document-uri($mathmlDoc)"/>". There should be at most one. Using first found.</xsl:message>
                </xsl:if>
                <xsl:message> + [INFO] mathmlref: Processing element with ID "<xsl:value-of select="$fragmentId"/>" in document <xsl:value-of select="document-uri($mathmlDoc)"/>...</xsl:message>
                <xsl:apply-templates mode="validate-mathmldoc" select="$targetElem[1]"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
  <xsl:template mode="validate-mathmldoc" match="m:math" priority="10">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>

    <!-- Must be good, apply templates in normal mode -->
    <xsl:apply-templates mode="#default" select=".">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="validate-mathmldoc" match="*">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>

    <xsl:message> - [WARN] validate-mathmldoc: element <xsl:sequence select="name(.)"/> with ID "<xsl:value-of select="@id"/>" is not a MathML &lt;math&gt; element. &lt;mathmlref&gt; must resolve to a &lt;math&gt; element.</xsl:message>
  </xsl:template>
  
  <xsl:template mode="validate-mathmldoc" match="/*" priority="5">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>

    <xsl:message> - [WARN] validate-mathmldoc: Root element <xsl:sequence select="name(.)"/> is not a MathML &lt;math&gt; element. &lt;mathmlref&gt; must resolve to a &lt;math&gt; element.</xsl:message>
  </xsl:template>
  
<!--=========================
    SVG Processing
    ========================= -->
  
  <xsl:template match="*[contains(@class, ' svg-d/svgref ')]" priority="100">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
        <xsl:message> + [DEBUG] svg-d/svgref, href=<xsl:value-of select="@href"/></xsl:message>
        <xsl:message> + [DEBUG] svg-d/svgref, keyref=<xsl:value-of select="@keyref"/></xsl:message>
    </xsl:if>
    
    <xsl:choose>
      <xsl:when test="not(@href) and not(@keyref)">
        <xsl:message> - [WARN] svgref: No value for @href or @keyref attribute.</xsl:message>
      </xsl:when>      
      <xsl:otherwise>
        <xsl:if test="$doDebug">
          <xsl:message> + [DEBUG] mathmlref: Have @href or @keyref or both</xsl:message>
        </xsl:if>
        <xsl:variable name="svgDoc" as="document-node()?"
          select="local:resolveRefToDocument(.)"
        />
        <xsl:if test="$doDebug">
          <xsl:message> + [DEBUG] count($svgDoc)=<xsl:value-of select="count($svgDoc)"/></xsl:message>
        </xsl:if>
        <xsl:variable name="fragmentId" as="xs:string?"
          select="local:getFragmentIDForXRef(.)"
        />
        <xsl:if test="$doDebug">
          <xsl:message> + [DEBUG] $fragmentId="<xsl:value-of select="$fragmentId"/>"</xsl:message>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="$fragmentId = ''">
            <xsl:if test="$doDebug">
              <xsl:message> + [DEBUG] No fragment ID, processing whole document.</xsl:message>
            </xsl:if>
            <!-- Root of target document should be an SVG  svg:svg element -->
            <xsl:message> + [INFO] svgref: Processing root of document <xsl:value-of select="document-uri($svgDoc)"/>...</xsl:message>
            <xsl:apply-templates select="$svgDoc/*[1]" mode="validate-svgdoc">
              <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="$doDebug">
              <xsl:message> + [DEBUG] Fragment ID, attempting to find the element with the ID.</xsl:message>
            </xsl:if>
            <!-- Fragment ID should be an element ID and should be the ID 
                 of an svg:svg element:
              -->
            <xsl:variable name="targetElem" as="element()*" select="$svgDoc//*[@id = $fragmentId]"/>
            <xsl:choose>
              <xsl:when test="not($targetElem)">
                <xsl:message> - [WARN] svgref: Failed to find element with ID "<xsl:value-of select="$fragmentId"/> in document "<xsl:value-of select="document-uri($svgDoc)"/>"</xsl:message>
              </xsl:when>
              <xsl:otherwise>
                <xsl:if test="count($targetElem) > 1">
                  <xsl:message> - [WARN] svgref: Found <xsl:value-of select="count($targetElem)"/> elements with ID "<xsl:value-of select="$fragmentId"/> in document "<xsl:value-of select="document-uri($svgDoc)"/>". There should be at most one. Using first found.</xsl:message>
                </xsl:if>
                <xsl:message> + [INFO] svgref: Processing element with ID "<xsl:value-of select="$fragmentId"/>" in document <xsl:value-of select="document-uri($svgDoc)"/>...</xsl:message>
                <xsl:apply-templates mode="validate-svgdoc" select="$targetElem[1]">
                  <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
                </xsl:apply-templates>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="validate-svgdoc" match="svg:svg" priority="10">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>

    <!-- Must be good, apply templates in normal mode -->
    <xsl:apply-templates mode="#default" select=".">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="validate-svgdoc" match="*">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>

    <xsl:message> - [WARN] validate-svgdoc: element <xsl:sequence select="name(.)"/> with ID "<xsl:value-of select="@id"/>" is not an SVG &lt;svg&gt; element. &lt;svgref&gt; must resolve to an &lt;svg&gt; element.</xsl:message>
  </xsl:template>
  
  <xsl:template mode="validate-svgdoc" match="/*" priority="5">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>

    <xsl:message> - [WARN] validate-svgdoc: Root element <xsl:sequence select="name(.)"/> is not an SVG &lt;svg&gt; element. &lt;svgref&gt; must resolve to an &lt;svg&gt; element.</xsl:message>
  </xsl:template>
    
  <xsl:template mode="svg:copy-svg" match="svg:*">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="useNSPrefix" as="xs:boolean" tunnel="yes" select="false()"/>

    <!-- NOTE: It appears that at least Antenna House requires that the svg: prefix be used
               on the elements: just having the SVG namespace does not appear to be enough.
      -->
    <xsl:element name="{if ($useNSPrefix) then concat('svg:', local-name(.)) else local-name(.)}"
      namespace="http://www.w3.org/2000/svg"
      >
      <xsl:apply-templates select="@*,node()" mode="#current">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </xsl:element>
    
  </xsl:template>
  
  <xsl:template mode="svg:copy-svg" match="*" priority="-1">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:apply-templates select="." mode="svg:non-svg-in-svg">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="svg:non-svg-in-svg" match="*">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- By default, ignore non-SVG elements within SVG -->
  </xsl:template>
  
  <xsl:template mode="svg:copy-svg" match="@* | processing-instruction() | text()">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:sequence select="."/>
  </xsl:template>

  
  
</xsl:stylesheet>