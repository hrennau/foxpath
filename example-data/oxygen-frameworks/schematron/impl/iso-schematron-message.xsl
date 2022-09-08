<?xml version="1.0" ?>
<!-- Implmentation for the Schematron XML Schema Language.
	http://www.ascc.net/xml/resource/schematron/schematron.html
 
 Copyright (c) 2000,2001 Rick Jelliffe and Academia Sinica Computing Center, Taiwan

 This software is provided 'as-is', without any express or implied warranty. 
 In no event will the authors be held liable for any damages arising from 
 the use of this software.

 Permission is granted to anyone to use this software for any purpose, 
 including commercial applications, and to alter it and redistribute it freely,
 subject to the following restrictions:

 1. The origin of this software must not be misrepresented; you must not claim
 that you wrote the original software. If you use this software in a product, 
 an acknowledgment in the product documentation would be appreciated but is 
 not required.

 2. Altered source versions must be plainly marked as such, and must not be 
 misrepresented as being the original software.

 3. This notice may not be removed or altered from any source distribution.
-->

<!-- Schematron message -->

<xsl:stylesheet
   version="2.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias"
   xmlns:iso="http://purl.oclc.org/dsdl/schematron"
   xmlns:xs="http://www.w3.org/2001/XMLSchema">

<xsl:import href="iso_schematron_skeleton.xsl"/>
   
   <!-- Parameter that specifies if the schema language  must be used as default languge -->
   <xsl:param name="useSchemaLang" as="xs:boolean" select="true()"/>
   
   <!-- The language specified in the Schematron schema -->
   <xsl:variable name="schemaLang" select="if(iso:schema/@xml:lang) then iso:schema/@xml:lang else $langCode"/>

   <!-- The diagnostics elements -->  
   <xsl:key name="diag" match="iso:diagnostic" use="@id"/>   
   

   <xsl:template name="process-prolog">
      <axsl:output method="xml"/>
   </xsl:template>

<!-- use default rule for process-root:  copy contents / ignore title -->
<!-- use default rule for process-pattern: ignore name and see -->
<!-- use default rule for process-name:  output name -->
<!-- use default rule for process-assert and process-report:
     call process-message -->

<xsl:template name="process-message">
   <xsl:param name="pattern" />
   <xsl:param name="role"/>
   <xsl:param name="diagnostics"/>
   <xsl:param name="see"/>
  
   <xsl:variable name="actualRole">
     <xsl:choose>
       <xsl:when test="not($role)">
         <xsl:value-of select="../@role"/>
       </xsl:when>
       <xsl:otherwise>
         <xsl:value-of select="$role"/>
       </xsl:otherwise>
     </xsl:choose>
   </xsl:variable>
   <xsl:variable name="r" select="translate($actualRole, 'WARNING FATAL INFORMATION ERROR', 'warning fatal information error')"/>
   <axsl:message>
      <xsl:choose>
         <xsl:when test="@subject">
            <xsl:attribute name="subject" namespace="http://www.oxygenxml.com/ns/schematron">
               <xsl:value-of select="@subject"/>
            </xsl:attribute>
         </xsl:when>
         <xsl:when test="../@subject">
            <xsl:attribute name="subject" namespace="http://www.oxygenxml.com/ns/schematron">
               <xsl:value-of select="../@subject"/>
            </xsl:attribute>
         </xsl:when>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="$r='warning' or $r='warn'">
            <axsl:text>Warning:</axsl:text>
         </xsl:when>
         <xsl:when test="$r='fatal'">
            <axsl:text>Fatal:</axsl:text>
         </xsl:when>
         <xsl:when test="$r='error'">
            <axsl:text>Error:</axsl:text>
         </xsl:when>
         <xsl:when test="$r='info' or $r='information'">
            <axsl:text>Info:</axsl:text>
         </xsl:when>
      </xsl:choose>
      
      <xsl:call-template name="generate-message">
         <xsl:with-param name="langCode" select="$langCode"/>
         <xsl:with-param name="diagnosticsIds" select="$diagnostics"/>
      </xsl:call-template>

      <xsl:if test="$see">
        <axsl:text>&#10;URL:<xsl:value-of select="$see"/></axsl:text>
      </xsl:if>
      <xsl:call-template name="process-message-end"/>
   </axsl:message>
   
   <!-- Skeleton implementatio -->
   <!--<axsl:message>
      <xsl:apply-templates mode="text"  
      /> (<xsl:value-of select="$pattern" />
      <xsl:if test="$role"> / <xsl:value-of select="$role" />
      </xsl:if>)</axsl:message>-->
   </xsl:template>
   
   <!-- Generate the message for the current node, depending on the given langCode.-->
   <xsl:template name="generate-message">
      <xsl:param name="langCode"/>
      <xsl:param name="diagnosticsIds"/>
      
      <xsl:variable name="currentLanguage"
         select="
            if ($langCode = 'default' and $useSchemaLang = true()) then
               ($schemaLang)
            else
               $langCode"/>

      <!-- Get all localization (diagnostics) nodes. -->
      <xsl:variable name="localizationNodes" as="item()*">
         <xsl:if test="$diagnosticsIds != ''">
            <xsl:variable name="assert" select="."/>
            <xsl:for-each select="tokenize($diagnosticsIds, ' ')">
               <xsl:sequence select="key('diag', current(), root($assert))"/>
            </xsl:for-each>
         </xsl:if>
      </xsl:variable>

      <!-- Generate the (localization) diagnostics messages for the current language-->
      <xsl:variable name="localizationMessages" as="item()*">
         <xsl:for-each select="$localizationNodes">
            <xsl:call-template name="getMessage">
               <xsl:with-param name="reqLang" select="$currentLanguage"/>
               <xsl:with-param name="isAddId" select="true()"/>
            </xsl:call-template>
         </xsl:for-each>
      </xsl:variable>

      <!-- Generate the message from assert only if matches the current language -->
      <xsl:variable name="assertMsg" as="item()*">
         <xsl:call-template name="getMessage">
            <xsl:with-param name="reqLang" select="$currentLanguage"/>
         </xsl:call-template>
      </xsl:variable>

      <xsl:choose>
         <xsl:when
            test="not(empty($localizationMessages)) or (not(empty($assertMsg)) and $localizationNodes)">
            <!-- Generate the message for the current language, both from the assertion and from localization nodes  -->
            <xsl:sequence select="$assertMsg"/>
            <xsl:sequence select="$localizationMessages"/>
         </xsl:when>
         <xsl:when test="$currentLanguage != 'default'">
            <!-- If no localization (diagnostics) for a specific language-->
            <xsl:choose>
               <!-- Generate the assertion message for the current language-->
               <xsl:when test="not(empty($assertMsg))">
                  <xsl:sequence select="$assertMsg"/>
               </xsl:when>
               <xsl:otherwise>
                  <!-- Generate the messages for all languages. -->
                  <!-- Print assertion message -->
                  <xsl:variable name="assertMsgDef">
                     <xsl:call-template name="getMessage">
                        <xsl:with-param name="reqLang" select="'default'"/>
                     </xsl:call-template>
                  </xsl:variable>
                  <xsl:sequence select="$assertMsgDef"/>
                  <!-- Print distinct diagnostics messages. -->
                  <xsl:variable name="allMessages" as="item()*">
                     <xsl:for-each select="$localizationNodes">
                        <xsl:call-template name="getMessage">
                           <xsl:with-param name="reqLang" select="'default'"/>
                           <xsl:with-param name="isAddId" select="true()"/>
                        </xsl:call-template>
                     </xsl:for-each>
                  </xsl:variable>
                  <xsl:sequence select="$allMessages"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <!-- Generate the assertion message, if no language match-->
            <xsl:variable name="assertMsgDef">
               <xsl:call-template name="getMessage">
                  <xsl:with-param name="reqLang" select="'default'"/>
               </xsl:call-template>
            </xsl:variable>
            <xsl:sequence select="$assertMsgDef"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <!-- Function used to obtain the message from the current node -->
   <xsl:template name="getMessage">
      <xsl:param name="reqLang" as="xs:string" required="yes"/>
      <xsl:param name="isAddId" as="xs:boolean" select="false()"/>
      
      <xsl:choose>
         <xsl:when test="$reqLang != 'default'">
            <!-- Get the language from the current node -->
            <xsl:variable name="language">
               <xsl:variable name="currentLang" select="(ancestor-or-self::*/@xml:lang)[last()]"/>
               <xsl:value-of select="if ($currentLang) then ($currentLang) else ('#NONE')"/>
            </xsl:variable>
            <!-- Generate the message from assert only if matches the current language -->
            <xsl:if test="starts-with($language, $reqLang)">
               <xsl:if test="$isAddId">[#<xsl:value-of select="@id"/>]</xsl:if>
               <xsl:apply-templates mode="text"/>
            </xsl:if>
         </xsl:when>
         <xsl:otherwise>
            <!-- Generate the message with the language in front. -->
            <xsl:if test="$isAddId">[#<xsl:value-of select="@id"/>]</xsl:if>
            <xsl:if test="@xml:lang">[<xsl:value-of select="@xml:lang"/>]</xsl:if>
            <xsl:apply-templates mode="text"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
 
   <!-- Can be overridden to generate the quick fix ids in the message. -->
   <xsl:template name="process-message-end"/>
   
</xsl:stylesheet>
