<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:df="http://dita2indesign.org/dita/functions"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:epubtrans="urn:d4p:epubtranstype"
  xmlns:gmap="http://dita4publishers/namespaces/graphic-input-to-output-map"
  exclude-result-prefixes="xs df relpath epubtrans"
  version="2.0"
  xmlns:fn="http://www.example.com/fn">
  
  <!-- =========================================
       Manages embedding of fonts in the 
       generated EPUB.
       
       The embedding is done by adding entries
       to the graphic map so the font files
       are included in the EPUB. 
       
       The fonts to be embedded are defined in 
       an XML font manifest file, the location
       of which is specified as a runtime parameter.
       
       ========================================= -->
  
 
  <xsl:template match="*" mode="additional-graphic-refs" priority="20">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
<!--    <xsl:variable name="doDebug" as="xs:boolean" select="true()"/>-->
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] additional-graphic-refs: embed fonts override: <xsl:value-of select="concat(name(..), '/', name(.))"/></xsl:message>
    </xsl:if>

    <!-- If there is a font manifest specified, process it to add 
         references to each font to the set of graphic references.
      -->
    <xsl:if test="$epubFontManifestUri != ''">
      <xsl:if test="$doDebug">
        <xsl:message> + [DEBUG] additional-graphic-refs: $epubFontManifestUri="<xsl:value-of select="$epubFontManifestUri"/>"</xsl:message>
      </xsl:if>

      <xsl:message> + [INFO] Font manifest specified as "<xsl:value-of select="$epubFontManifestUri"/>"</xsl:message>
      <xsl:message> + [INFO] Processing font manifest...</xsl:message>
      <xsl:variable name="fontManifest" as="document-node()?" 
        select="epubtrans:getFontManifestDoc($epubFontManifestUri, root(.))"/>
      <xsl:choose>
        <xsl:when test="not($fontManifest)">
          <xsl:message> - [WARN] Font manifest file "<xsl:value-of select="$epubFontManifestUri"/>" not parsed. Fonts will not be embedded.</xsl:message>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="$doDebug">
            <xsl:message> + [DEBUG] additional-graphic-refs: Applying templates to font manifest in mode epubtrans:font-graphic-refs...</xsl:message>
          </xsl:if>
          
          <xsl:apply-templates select="$fontManifest/*" mode="epubtrans:font-graphic-refs">
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>              
          </xsl:apply-templates>
          <xsl:if test="$doDebug">
            <xsl:message> + [DEBUG] additional-graphic-refs: Font manifest processing done.</xsl:message>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:message> + [INFO] Font manifest processing complete.</xsl:message>
    </xsl:if>
    <xsl:next-match/><!-- Enable additional extensions -->
  </xsl:template>
  
  <xsl:template mode="epubtrans:font-graphic-refs" match="font-manifest">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>

    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] epubtrans:font-graphic-refs: Element <xsl:value-of select="concat(name(..), '/', name(.))"/></xsl:message>
    </xsl:if>
    
    <xsl:apply-templates mode="#current" select="font-set">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    <!-- Now generate an entry for the font CSS if font CSS creation has been requested. -->
    <xsl:if test="$epubtrans:doGenerateCSSFontRules">
      <!-- NOTE: For now assuming that there's exactly one font-set as we don't have any
                 features for selecting or combining font sets.
        -->
      <xsl:variable name="cssUrl" select="epubtrans:getFontCSSUri((./font-set)[1])"/>
      <gmap:graphic-ref href="{$cssUrl}" filename="{relpath:getName($cssUrl)}" 
        targetDir="{$fontsOutputDir}"
      />
    </xsl:if>
  </xsl:template>

  <xsl:template mode="epubtrans:font-graphic-refs" match="font-set">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] epubtrans:font-graphic-refs: Element <xsl:value-of select="concat(name(..), '/', name(.))"/></xsl:message>
    </xsl:if>
    

    <xsl:apply-templates mode="#current" select="font">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  
  <xsl:template mode="epubtrans:font-graphic-refs" match="font">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] epubtrans:font-graphic-refs: Element <xsl:value-of select="concat(name(..), '/', name(.))"/></xsl:message>
    </xsl:if>

    <xsl:variable name="baseURI" as="xs:string" select="relpath:getParent(string(base-uri(.)))"/>
    <xsl:variable name="uri" as="xs:string" select="@uri"/>
    <xsl:variable name="fontURI" as="xs:string"
      select="if (matches($uri, '^\w+:.+'))
          then $uri
          else relpath:newFile($baseURI, $uri)
      "
    />
    <xsl:message> + [INFO] Font embedding: Including font "<xsl:value-of select="$fontURI"/>"</xsl:message>
    <gmap:graphic-ref href="{$fontURI}" filename="{relpath:getName($fontURI)}">
      <xsl:sequence select="(@obfuscate, ../@obfuscate)[1]"/>
    </gmap:graphic-ref>
  </xsl:template>
  
  <xsl:template mode="epubtrans:font-graphic-refs" match="* | text()" priority="-1">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>

    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] epubtrans:font-graphic-refs: Element <xsl:value-of select="concat(name(..), '/', name(.))"/></xsl:message>
    </xsl:if>
    
    <!-- Ignore by default -->
  </xsl:template>
  
  <!-- ============================================
       Set the MIME types for fonts appropriately
       ============================================ -->
  
  <xsl:template mode="getMimeType" match="gmap:filename[lower-case(@extension) = ('ttf', 'otf', 'ttc')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <!-- NOTE: Per the EPUB 3.1 spec, the core MIME type for
         Open Type fonts is "application/vnd.ms-opentype", which is
         what epubcheck 4.0 expects. However, there is now an official
         MIME type for Open Type fonts, "application/font-sfnt",
         which the EPUB spec will probably be updated to allow.
         
         See https://github.com/IDPF/epubcheck/issues/339
      -->
    <xsl:variable name="font-type" as="xs:string"
      select="if (lower-case(@extension) = ('ttf', 'otf', 'ttc', 'cff')) then 'vnd.ms-opentype'
      else concat('font-', lower-case(@extension))
      "
    />
    <xsl:sequence select="concat('application/', $font-type)"/>
  </xsl:template>
  
  <xsl:template mode="getMimeType" match="gmap:filename[@extension = ('css')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:sequence select="'text/css'"/>
  </xsl:template>
  
  <xsl:template mode="getMimeType" match="gmap:filename[@extension = ('js')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:sequence select="'text/javascript'"/>
  </xsl:template>
  

  <!-- Handle font files specially: Put in font directory -->
  <xsl:template mode="gmap:get-output-url" match="gmap:graphic-ref" priority="10">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
        
    <xsl:variable name="absoluteUrl" as="xs:string" select="@href"/>
    <xsl:variable name="filename" as="xs:string" select="@filename"/>
    <xsl:variable name="namePart" as="xs:string" select="relpath:getNamePart($filename)"/>
    <xsl:variable name="extension" as="xs:string" select="lower-case(relpath:getExtension($filename))"/>
    <xsl:variable name="key"
      select="
      if (count(preceding-sibling::*[@filename = $filename]) > 0)
      then concat($namePart, '-', count(preceding-sibling::*[@filename = $filename]) + 1, '.', $extension)
      else $filename
      "
    />
    <xsl:choose>
      <xsl:when test="$extension = ('ttf', 'ttc', 'otf', 'otc', 'cff', 'woff')">
        <xsl:sequence select="relpath:newFile($fontsOutputPath, $key)"/>        
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Make encryption.xml entries for obfuscated fonts. 
    
       This template should only be called if obfuscation is turned
       on.
       
    -->
  <xsl:template mode="epubtrans:makeEncryptionXml" match="font-manifest">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] epubtrans:makeEncryptionXml: font-manifest. </xsl:message>
      <xsl:message> + [DEBUG] epubtrans:makeEncryptionXml: Have <xsl:value-of 
        select="count(.//font[@obfuscate = ('obfuscate')])"/> obfuscated fonts.</xsl:message>
    </xsl:if>
    
    <xsl:apply-templates select=".//font[@obfuscate = ('obfuscate')]"
      mode="#current"
      >
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="epubtrans:makeEncryptionXml" match="font[@obfuscate = ('obfuscate')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:variable name="fontFilename" as="xs:string"
      select="relpath:getName(string(@uri))"
    />
    
    <xsl:variable name="fontUri" as="xs:string"
      select="relpath:newFile($fontsOutputDir, $fontFilename)"
    />
    
    <enc:EncryptedData xmlns:enc="http://www.w3.org/2001/04/xmlenc#"> 
      <enc:EncryptionMethod Algorithm="http://www.idpf.org/2008/embedding"/>
      <enc:CipherData> 
        <enc:CipherReference URI="{$fontUri}"/> 
      </enc:CipherData>
    </enc:EncryptedData> 
  </xsl:template>
  
  
  
  <!-- Apply font obfuscation if the obfuscate attribute is set to true -->
  <xsl:template mode="gmap:generate-copy-target" match="gmap:graphic-map-item[@obfuscate = ('obfuscate')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="targetId" as="xs:string" tunnel="yes"/>
    <xsl:param name="sourceDir" as="xs:string" tunnel="yes"/>
    <xsl:param name="toFile" as="xs:string" tunnel="yes"/>
    <xsl:param name="epubBookID" as="xs:string" tunnel="yes" select="'epub-bookid-not-specified'"/>
    
<!--    <xsl:variable name="doDebug" as="xs:boolean" select="true()"/>-->
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] gmap:generate-copy-target: Override for font processing. </xsl:message>
    </xsl:if>

    
    <xsl:variable name="doObfuscation" as="xs:boolean" select="@obfuscate = ('obfuscate')"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] gmap:generate-copy-target: obfuscate="<xsl:value-of select="$doObfuscation"/>. </xsl:message>
    </xsl:if>
    
    <xsl:variable name="sourceFile" 
      as="xs:string" 
      select="@input-url"
    />
    
    <xsl:choose>
      <xsl:when test="$epubtrans:doObfuscateFonts and $doObfuscation">
        <xsl:message> + [INFO] Obfuscating embedded font "<xsl:value-of select="$sourceFile"/>"</xsl:message>
        <target name="copy-{$targetId}" depends="check-{$targetId}, report-{$targetId}" if="is-{$targetId}">
          <ant target="epub-obfuscate-font" antfile="${{dita.dir}}/build.xml">
            <property name="font.obfuscate.obfuscationkey" value="{$epubBookID}"/>
            <property name="font.obfuscate.inputfont" value="{$sourceFile}"/>
            <property name="font.obfuscate.resultfont" value="{$toFile}"/>
          </ant>
        </target>
        
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
    
  <!-- ============================================
       Generate CSS @font-face rules
       ============================================ -->
  
  <xsl:template name="epubtrans:generateCSSFontRules">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$epubFontManifestUri != ''">
      <xsl:if test="$doDebug">
        <xsl:message> + [DEBUG] additional-graphic-refs: $epubFontManifestUri="<xsl:value-of select="$epubFontManifestUri"/>"</xsl:message>
      </xsl:if>
      
      <xsl:message> + [INFO] Font manifest specified as "<xsl:value-of select="$epubFontManifestUri"/>"</xsl:message>
      <xsl:message> + [INFO] Processing font manifest...</xsl:message>
      <xsl:variable name="fontManifest" as="document-node()?" 
        select="epubtrans:getFontManifestDoc($epubFontManifestUri, root(.))"/>
      <xsl:choose>
        <xsl:when test="not($fontManifest)">
          <xsl:message> - [WARN] Font manifest file "<xsl:value-of select="$epubFontManifestUri"/>" not parsed. Fonts will not be embedded.</xsl:message>
        </xsl:when>
        <xsl:otherwise>
                
          <xsl:message> + [INFO] Generating CSS @font-rules...</xsl:message>
          
          <xsl:apply-templates select="$fontManifest/*" mode="epubtrans:generateCSSFontRules">
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
          </xsl:apply-templates>
          <xsl:message> + [INFO] CSS @font-rules generated.</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="epubtrans:generateCSSFontRules" match="font-manifest">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:apply-templates mode="#current" select="font-set[1]">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="epubtrans:generateCSSFontRules" match="font-set">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:variable name="resultUrl" select="epubtrans:getFontCSSUri(.)"/>
    
    <xsl:message> + [INFO] Generating @font-face CSS file "<xsl:value-of select="$resultUrl"/>"...</xsl:message>
    <xsl:result-document href="{$resultUrl}" method="text">
      <xsl:text>/*----------------------------------------------------------- 
  Font face rules for </xsl:text><xsl:value-of select="../title"
      /><xsl:text>&#x0a;  -----------------------------------------------------------*/&#x0a;</xsl:text>
<!--      <xsl:variable name="doDebug" as="xs:boolean" select="true()"/>-->
      <xsl:if test="$doDebug">
        <xsl:message> + [DEBUG] epubtrans:generateCSSFontRules: font-set - Applying templates to font elements...</xsl:message>
      </xsl:if>
      <xsl:apply-templates mode="#current" select="font">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
      <xsl:if test="$doDebug">
        <xsl:message> + [DEBUG] epubtrans:generateCSSFontRules: font-set - Done applying templates to font elements.</xsl:message>
      </xsl:if>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template mode="epubtrans:generateCSSFontRules" match="font[css-rules]" priority="10">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] epubtrans:generateCSSFontRules: font <xsl:value-of select="@uri"/> with css-rules child.</xsl:message>
    </xsl:if>
    
    <xsl:variable name="fontUrl" as="xs:string" select="@uri"/>
    
    <xsl:variable name="fontFamily" as="xs:string" 
      select="
      if (@css-font-family-name != '') 
         then @css-font-family-name 
         else relpath:getNamePart($fontUrl)"
    />

    <xsl:apply-templates mode="#current" select="css-rules">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      <xsl:with-param name="fontUrl" as="xs:string" tunnel="yes" select="$fontUrl"/>
      <xsl:with-param name="fontFamily" as="xs:string" tunnel="yes" select="$fontFamily"/>
    </xsl:apply-templates>
        
  </xsl:template>
  
  <xsl:template mode="epubtrans:generateCSSFontRules" match="css-rules">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>

    <xsl:apply-templates mode="#current" select="font-face">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template> 
    
  <xsl:template mode="epubtrans:generateCSSFontRules" match="font-face">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="fontUrl" as="xs:string" tunnel="yes"/>
    <xsl:param name="fontFamily" as="xs:string" tunnel="yes"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] epubtrans:generateCSSFontRules: font-face: <xsl:sequence select="."/></xsl:message>
    </xsl:if>
    
    <xsl:text>&#x0a;@font-face {&#x0a;</xsl:text>
    <xsl:value-of select="concat('  font-family: ''',$fontFamily,''';&#x0a;')"/>
    <xsl:value-of select="concat('  src: url(',$fontUrl,');&#x0a;')"/>
    <xsl:apply-templates mode="#current" select="@*">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    <xsl:text>}&#x0a;</xsl:text>    
    
  </xsl:template> 
  
  <xsl:template mode="epubtrans:generateCSSFontRules" match="@*">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] epubtrans:generateCSSFontRules: <xsl:sequence select="."/></xsl:message>
    </xsl:if>
    
    <!-- FIXME: Not sure if there's any need to quote any values here. -->
    <xsl:value-of select="concat('  ', name(.), ': ', string(.), ';&#x0a;')"/>
  </xsl:template>
  
  <xsl:template mode="epubtrans:generateCSSFontRules" match="font">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>

    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] epubtrans:generateCSSFontRules: Default font rule for font <xsl:value-of select="@uri"/></xsl:message>
    </xsl:if>
    
    <xsl:variable name="fontUrl" as="xs:string" select="@uri"/>
    
    <xsl:variable name="fontFamily" as="xs:string" 
      select="
      if (@css-font-family-name != '') 
      then @css-font-family-name 
      else relpath:getNamePart($fontUrl)"
    />
    
    <xsl:text>&#x0a;@font-face {&#x0a;</xsl:text>
    <xsl:value-of select="concat('  font-family: ''',$fontFamily,''';&#x0a;')"/>
    <xsl:value-of select="concat('  src: url(',$fontUrl,');&#x0a;')"/>
    <xsl:text>}&#x0a;</xsl:text>
  </xsl:template>
  
  <!-- Gets the font manifest file, if a URI has been specified, otherwise
       returns an empty sequence.
    -->
  <xsl:function name="epubtrans:getFontManifestDoc" as="document-node()?">
    <xsl:param name="epubFontManifestURI" as="xs:string"/>
    <xsl:param name="baseNode" as="node()"/>
    
    <xsl:variable name="result" as="document-node()?" 
      select="if ($epubFontManifestUri != '') 
                 then document($epubFontManifestUri, $baseNode)
                 else ()"
    />
    <xsl:if test="$epubFontManifestUri != '' and not($result)">
      <xsl:message> - [WARN] epubtrans:getFontManifestDoc(): Failed to find font manifest at URI "<xsl:value-of select="$epubFontManifestUri"/>".</xsl:message>
    </xsl:if>
    <xsl:sequence select="$result"/>
    
  </xsl:function>
  
  <!-- Construct the result URI for the font CSS file. Takes a font-set element
       as input.
    -->
  <xsl:function name="epubtrans:getFontCSSUri">
    <xsl:param name="context" as="element(font-set)"/>

    <xsl:variable name="cssUrl" as="xs:string" 
      select="if ($context/@css-url != '') then $context/@css-url else 'fonts.css'"
    />
    <xsl:variable name="resultUrl" as="xs:string"
      select="relpath:newFile(relpath:newFile($outdir, $fontsOutputDir), $cssUrl)"
    />
    <xsl:sequence select="$resultUrl"/>
  </xsl:function>
    
</xsl:stylesheet>