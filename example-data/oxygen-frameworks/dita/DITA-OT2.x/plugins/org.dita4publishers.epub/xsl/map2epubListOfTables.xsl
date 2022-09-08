<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:df="http://dita2indesign.org/dita/functions" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:htmlutil="http://dita4publishers.org/functions/htmlutil"
  xmlns:index-terms="http://dita4publishers.org/index-terms" xmlns:local="urn:functions:local"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:enum="http://dita4publishers.org/enumerables"
  xmlns:epubtrans="urn:d4p:epubtranstype"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:template match="/" mode="generate-list-of-tables-html-toc">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] generate-list-of-tables-html-toc: Starting...</xsl:message>
    </xsl:if>
    
    <xsl:apply-templates mode="#current">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>

    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] generate-list-of-tables-html-toc: Done.</xsl:message>
    </xsl:if>
  </xsl:template> 
  
  <xsl:template match="*[df:class(., 'map/map')]" 
    mode="generate-list-of-tables-html-toc">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="collected-data" as="element()*" tunnel="yes"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] generate-list-of-tables-html-toc: collected-data:
<xsl:sequence select="$collected-data"/>      
      </xsl:message>
    </xsl:if>
    
    <xsl:apply-templates mode="#current"
        select="$collected-data/enum:enumerables//*[df:class(., 'topic/table')][enum:title]">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template name="generate-table-list-html-doc">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="collected-data" as="element()*"/>

    <xsl:variable name="resultUri"
      select="relpath:newFile($outdir, concat('list-of-tables_', generate-id(.), $outext))" 
      as="xs:string"
    />
    <xsl:variable name="lot-title" as="node()*">
      <xsl:text>List of Tables</xsl:text><!-- FIXME: Get this string from string config -->
    </xsl:variable>
    <xsl:message> + [INFO] Generating list of tables as "<xsl:sequence select="$resultUri"/>"</xsl:message>
    <xsl:result-document href="{$resultUri}"
      format="html5"
      >
      <html>
        <head>                   
          <title><xsl:sequence select="$lot-title"/></title>
          <xsl:call-template name="constructToCStyle">
            <xsl:with-param name="resultUri" as="xs:string" tunnel="yes" select="$resultUri"/>
          </xsl:call-template>
          <xsl:call-template name="epubtrans:constructJavaScriptReferences">
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            <xsl:with-param name="resultUri" as="xs:string" select="$resultUri"/>
          </xsl:call-template>
        </head>
        <body class="toc-list-of-tables html-toc">
          <h2 class="toc-title"><xsl:sequence select="$lot-title"/></h2>
          <ul  class="html-toc html-toc_1 list-of-tables">
            <xsl:apply-templates select="root(.)" mode="generate-list-of-tables-html-toc">
              <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
              <xsl:with-param 
                name="collected-data" 
                select="$collected-data" 
                tunnel="yes" 
                as="element()"
              />
            </xsl:apply-templates>
          </ul>
        </body>
      </html>
    </xsl:result-document>
    
  </xsl:template>
  
  
  
  <xsl:template mode="generate-list-of-tables-html-toc" 
                match="*[df:class(., 'topic/table')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>
    <xsl:param name="topicref" as="element()?" tunnel="yes"/>
    
    <xsl:variable name="sourceUri" as="xs:string" select="@docUri"/>
    <xsl:variable name="rootTopic" select="document($sourceUri)" as="document-node()?"/>
    <xsl:variable name="targetUri"
      select="htmlutil:getTopicResultUrl2($outdir, $rootTopic, $topicref, $rootMapDocUrl)" 
      as="xs:string"/>
    <xsl:variable name="relativeUri" select="relpath:getRelativePath($outdir, $targetUri)"
      as="xs:string"/>
    <xsl:variable name="enumeratedElement" 
      select="key('elementsByXtrc', string(@xtrc), root($rootTopic))" 
      as="element()?"/>
    <xsl:variable name="containingTopic" as="element()"
      select="df:getContainingTopic($enumeratedElement)"
    />
    <li class="html-toc-entry html-toc-entry_1">
      <!-- FIXME: Here we're replicating ID construction logic implemented elsewhere in the Toolkit.
           This is of course fragile. -->
      <span class="html-toc-entry-text html-toc-entry-text_1"
        ><a href="{$relativeUri}{if (@origId) 
          then concat('#', $containingTopic/@id, '__', @origId) 
          else concat('#', df:generate-dita-id($enumeratedElement))}"
          >
          <xsl:if test="$contenttarget">
            <xsl:attribute name="target" select="$contenttarget"/>
          </xsl:if>
          <!-- Generate a number, if any -->
          <xsl:apply-templates select="." mode="enumeration">
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
          </xsl:apply-templates> 
          <xsl:apply-templates 
            select="$enumeratedElement/*[df:class(., 'topic/title')]" 
            mode="#current">
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
          </xsl:apply-templates></a></span>
    </li>    
  </xsl:template>
  
  
  <xsl:template match="*" mode="generate-list-of-tables-html-toc" priority="-1">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] Fallback in mode generate-list-of-tables-html-toc: <xsl:sequence select="concat(name(..), '/', @class)"/> in mode generate-list-of-tables-html-toc</xsl:message>
    </xsl:if>
    <xsl:apply-templates mode="#current">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="generate-list-of-tables-html-toc" match="text()">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>    
  </xsl:template>
  
  <xsl:template mode="generate-list-of-tables-html-toc" match="*[df:class(., 'topic/title')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:variable name="html" as="node()*">
      <xsl:apply-templates>
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:apply-templates select="$html" mode="html2xhtml">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
</xsl:stylesheet>