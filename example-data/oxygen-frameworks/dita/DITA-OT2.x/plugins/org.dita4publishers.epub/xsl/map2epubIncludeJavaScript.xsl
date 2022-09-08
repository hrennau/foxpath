<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:df="http://dita2indesign.org/dita/functions"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:epubtrans="urn:d4p:epubtranstype"
  xmlns:gmap="http://dita4publishers/namespaces/graphic-input-to-output-map"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all"
  version="2.0"
  xmlns:fn="http://www.example.com/fn">
  
  <!-- =========================================
       Manages embedding of JavaScript files in the 
       generated EPUB.
       
       The embedding is done by adding entries
       to the graphic map so the JavaScript files
       are included in the EPUB. 
       
       
       ========================================= -->
  
 
  <xsl:template match="*" mode="additional-graphic-refs" priority="30">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
       
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] additional-graphic-refs: include JavaScript override: <xsl:value-of select="concat(name(..), '/', name(.))"/></xsl:message>
    </xsl:if>

    <!-- If there is a font manifest specified, process it to add 
         references to each font to the set of graphic references.
      -->
    <xsl:if test="$javaScriptSourceFile != ''">
      <xsl:if test="$doDebug">
        <xsl:message> + [DEBUG] additional-graphic-refs: $javaScriptSourceFile="<xsl:value-of select="$javaScriptSourceFile"/>"</xsl:message>
      </xsl:if>
      <xsl:variable name="javaScriptUri" as="xs:string"
        select="relpath:toUrl($javaScriptSourceFile)"
      />

      <xsl:message> + [INFO] Including JavaScript file "<xsl:value-of select="$javaScriptSourceFile"/>" in EPUB package...</xsl:message>
      <xsl:variable name="javaScript" as="xs:string" 
        select="unparsed-text($javaScriptUri)"/>
      <xsl:choose>
        <xsl:when test="not($javaScript)">
          <xsl:message> - [WARN] JavaScript file "<xsl:value-of select="$javaScriptSourceFile"/>" not found. JavaScript will not be embedded.</xsl:message>
        </xsl:when>
        <xsl:otherwise>
          <gmap:graphic-ref 
            id="{concat('javascript-', relpath:getNamePart($javaScriptSourceFile))}"
            href="{$javaScriptUri}" 
            filename="{relpath:getName($javaScriptUri)}"
            
          />
          
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:next-match/><!-- Enable additional extensions -->
  </xsl:template>
  
  
  
  <!-- Handle JavaScript files specially: Put in JavaScript directory -->
  <xsl:template mode="gmap:get-output-url" match="gmap:graphic-ref" priority="20">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
        
    <xsl:variable name="filename" as="xs:string" select="@filename"/>
    <xsl:variable name="extension" as="xs:string" select="lower-case(relpath:getExtension($filename))"/>
    <xsl:choose>
      <xsl:when test="$extension = ('js')">
        <xsl:sequence select="relpath:newFile($javascriptOutputPath, $filename)"/>        
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="epubtrans:constructJavaScriptReferences">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="resultUri" as="xs:string"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] epubtrans:constructJavaScriptReferences: resultUri="<xsl:value-of select="$resultUri"/>"</xsl:message>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="$javaScriptSourceFile != ''">
        <xsl:variable name="javaScriptPath" as="xs:string" 
          select="relpath:newFile($javaScriptOutputDir, relpath:getName($javaScriptSourceFile))"/>
        <xsl:variable name="relPathToJavascript" as="xs:string"
          select="relpath:getRelativePath($resultUri, $javaScriptPath)"
        />
        <script src="{$relPathToJavascript}"></script>
      </xsl:when>
    </xsl:choose>
    
  </xsl:template>
  
  <!-- This mode is called from dita2htmlImpl.xsl chapterhead template -->
  <xsl:template mode="gen-user-scripts" match="*">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$javaScriptSourceFile != ''">
      <xsl:variable name="javaScriptPath" as="xs:string" 
        select="relpath:newFile($javascriptOutputPath, relpath:getName($javaScriptSourceFile))"/>
      <script src="{$javaScriptPath}"></script>
    </xsl:if>
    
  </xsl:template>
  
  <!-- Return true() if the element's output file will be
       scripted (have a reference to one or more JavaScript
       files.
    -->
  <xsl:function name="epubtrans:isScripted" as="xs:boolean">
    <xsl:param name="topic" as="element()"/>

    <xsl:variable name="result" as="xs:boolean"
      select="if ($javaScriptSourceFile != '') then true() else false()"
    />
    <xsl:sequence select="$result"/>
  </xsl:function>
  
    
</xsl:stylesheet>