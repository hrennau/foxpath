<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0" xmlns:iso="http://purl.oclc.org/dsdl/schematron">
  
  <xsl:key name="ap" match="iso:pattern[@abstract='true']" use="@id"/>
  
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="iso:pattern[@abstract='true']"/>
  
  <xsl:template match="iso:pattern[@is-a]">
    <xsl:copy>
      <xsl:copy-of select="@*[not(name()='is-a')]"/>
      <xsl:variable name="ap" select="key('ap', @is-a)"/>
      <xsl:if test="not($ap)">
        <xsl:message terminate="no">
          Error: Cannot find abstract pattern <xsl:value-of select="@is-a"/> referred from pattern <xsl:value-of select="@id"/>.
        </xsl:message>
      </xsl:if>
      <xsl:if test="$ap[2]">
        <xsl:message terminate="no">
          Error: More than one definitions for abstract pattern <xsl:value-of select="@is-a"/> referred from pattern <xsl:value-of select="@id"/>.
        </xsl:message>
      </xsl:if>
      
      <xsl:for-each select="iso:param">
        <xsl:variable name="paramLength" select="string-length(@name)"/>
        <xsl:variable name="apos">'</xsl:variable>
        <xsl:if test="@name = $ap[1]//iso:let/@name/substring(., 1, $paramLength)">
          <xsl:message terminate="no">
            Error: Conflict between pattern parameters
            <xsl:if test="../@id">
              referred from pattern '<xsl:value-of select="../@id"/>'  
            </xsl:if>           
            and variables defined in the abstract pattern '<xsl:value-of select="../@is-a"/>': 
            parameter '<xsl:value-of select="@name"/>' and variable(s): 
            <xsl:value-of select="$ap[1]//iso:let[starts-with(@name, current()/@name)]/concat($apos, @name, $apos)" separator=", "/>. 
            Please use variable names that don't start with parameters names.
          </xsl:message>
        </xsl:if>
      </xsl:for-each>
      
      <!-- The parameters passed to the abstract pattern -->
      <xsl:variable name="oxyParams" select="$ap/oxyP:parameters/oxyP:parameter" xmlns:oxyP="http://oxygenxml.com/ns/schematron/params"/>
      <!-- The parameters declarations from the abstract pattern -->
      <xsl:variable name="params" select="iso:param[not(@name = $ap[1]//iso:let/@name)]"/>
      
      <!-- If we have the abstract parameters declarations -->
      <xsl:if test="$oxyParams">
        <xsl:variable name="pattern" select="."/>
        <!-- Check that all parameters are passed to the abstract pattern -->
        <xsl:for-each select="$oxyParams">
          <xsl:if test="not(current()/oxyP:name = $params/@name)" xmlns:oxyP="http://oxygenxml.com/ns/schematron/params">
            <xsl:apply-templates select="$pattern" mode="errorMsg">
              <xsl:with-param name="message">
                Error: The "<xsl:value-of select="current()/oxyP:name"/>" parameter is not passed to the abstract pattern.
              </xsl:with-param>
            </xsl:apply-templates>
          </xsl:if>
        </xsl:for-each>
        
        <!-- Check that the all passed parameters are declared in the abstract pattern-->
        <xsl:for-each select="$params">
          <xsl:if test="not(current()/@name = $oxyParams/oxyP:name)" xmlns:oxyP="http://oxygenxml.com/ns/schematron/params">
            <xsl:apply-templates select="current()" mode="errorMsg">
              <xsl:with-param name="message">
                Error: The "<xsl:value-of select="current()/@name"/>" parameter is not defined in the abstract pattern.
              </xsl:with-param>
            </xsl:apply-templates>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
      
      <xsl:apply-templates
        select="$ap[1]/node()"
        mode="instantiate">
        <xsl:with-param name="params" select="$params"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="* | processing-instruction() | comment()" mode="instantiate">
    <xsl:param name="params"/>
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="instantiate">
        <xsl:with-param name="params" select="$params"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@*" mode="instantiate">
    <xsl:param name="params"/>
    <xsl:choose>
      <xsl:when test="namespace-uri() != 'http://www.oxygenxml.com/schematron/validation' and contains(., '$')">
        <xsl:attribute name="{local-name()}" namespace="{namespace-uri()}">
          <xsl:call-template name="replaceParameters">
            <xsl:with-param name="params" select="$params"/>
            <xsl:with-param name="value" select="."/>
          </xsl:call-template>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="replaceParameters">
    <xsl:param name="params"/>
    <xsl:param name="value"/>
    <xsl:choose>
      <xsl:when test="count($params)=0">
        <xsl:value-of select="$value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="replaceParameters">
          <xsl:with-param name="params" select="$params[position()>1]"/>
          <xsl:with-param name="value">
            <xsl:call-template name="replaceParameter">
              <xsl:with-param name="param" select="$params[1]"/>
              <xsl:with-param name="value" select="$value"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="replaceParameter">
    <xsl:param name="value"/>
    <xsl:param name="param"/>
    <xsl:variable name="pname" select="concat('$',  $param/@name)"/>
    <xsl:choose>
      <xsl:when test="not(contains($value, $pname))">
        <xsl:value-of select="$value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="before" select="substring-before($value, $pname)"/>
        <xsl:variable name="after" select="substring-after($value, $pname)"/>
        <xsl:value-of select="$before"/>
        <xsl:value-of select="$param/@value"/>
        <xsl:if test="matches($after,'^[a-zA-Z0-9_\-]')">
          <xsl:apply-templates select="$param" mode="errorMsg">
            <xsl:with-param name="message">
              Warning: The "<xsl:value-of select="$param/@name"/>" parameter is not used correctly in the following abstract pattern text "<xsl:value-of select="$value"/>". A separator is expected after the parameter name.
            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:if>
        <xsl:call-template name="replaceParameter">
          <xsl:with-param name="param" select="$param"/>
          <xsl:with-param name="value" select="$after"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Show an error message -->
  <xsl:template match="*" mode="errorMsg">
    <xsl:param name="message"/>
    <xsl:message terminate="no"><xsl:value-of select="$message"/></xsl:message>
  </xsl:template>
  
  <!-- Expand variables in text nodes. -->
  <xsl:template match="text()" mode="instantiate">
    <xsl:param name="params"/>
    <xsl:choose>
      <xsl:when test="contains(., '$')">
        <xsl:call-template name="replaceParameters">
          <xsl:with-param name="params" select="$params"/>
          <xsl:with-param name="value" select="."/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
