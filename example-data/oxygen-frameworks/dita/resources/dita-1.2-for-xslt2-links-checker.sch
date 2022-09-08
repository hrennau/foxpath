<?xml version="1.0" encoding="UTF-8"?>
<!--
  The Syncro Soft SRL License
  
  
  Copyright (c) 1998-2011 Syncro Soft SRL, Romania.  All rights
  reserved.
  
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:
  
  1. Redistribution of source or in binary form is allowed only with
  the prior written permission of Syncro Soft SRL.
  
  2. Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.
  
  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in
  the documentation and/or other materials provided with the
  distribution.
  
  3. The end-user documentation included with the redistribution,
  if any, must include the following acknowledgment:
  "This product includes software developed by the
  Syncro Soft SRL (http://www.sync.ro/)."
  Alternately, this acknowledgment may appear in the software itself,
  if and wherever such third-party acknowledgments normally appear.
  
  4. The names "Oxygen" and "Syncro Soft SRL" must
  not be used to endorse or promote products derived from this
  software without prior written permission. For written
  permission, please contact support@oxygenxml.com.
  
  5. Products derived from this software may not be called "Oxygen",
  nor may "Oxygen" appear in their name, without prior written
  permission of the Syncro Soft SRL.
  
  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED.  IN NO EVENT SHALL THE SYNCRO SOFT SRL OR
  ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
  USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
  OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
  SUCH DAMAGE.
  
  Check broken <xref> or <link> links.
-->
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <pattern id="chekReference">
    <!-- xref of link to DITA resource without "#"-->
    <rule
      context="*[contains(@class, ' topic/xref ') or contains(@class, ' topic/link ')][@href][not(contains(@href, '#'))][not(@scope = 'external')][not(@type) or @type='dita']">
      <assert test="doc-available(resolve-uri(@href, base-uri(.)))">The document pointed by
          <value-of select="local-name()"/> "<value-of select="@href"/>" does not exist!</assert>
    </rule>
    <!-- xref of link to DITA resource with "#"-->
    <rule
      context="*[contains(@class, ' topic/xref ') or contains(@class, ' topic/link ')][@href][contains(@href, '#')][not(@scope = 'external')][not(@type) or @type='dita']">
      <let name="file" value="substring-before(@href, '#')"/>
      <let name="idPart" value="substring-after(@href, '#')"/>
      <let name="topicId"
        value="if (contains($idPart, '/')) then substring-before($idPart, '/') else $idPart"/>
      <let name="id" value="substring-after($idPart, '/')"/>
      <assert test="document($file, .)//*[@id=$topicId]"> Invalid topic id "<value-of
          select="$topicId"/>" </assert>
      <assert test="$id ='' or document($file, .)//*[@id=$id]"> No such id "<value-of select="$id"
        />" is defined! </assert>
      <assert
        test="$id='' or 
        document($file, .)//*[@id=$id][ancestor::*[contains(@class, ' topic/topic ')][1][@id=$topicId]]"
        > The id "<value-of select="$id"/>" is not in the scope of the referred topic id "<value-of
          select="$topicId"/>". </assert>
    </rule>
  </pattern>
</schema>
