<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:jatskit="https://github.com/wendellpiez/JATSKit/ns"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  type="jatskit:book-web-sequence" name="book-web-sequence">


<!-- XProc pipeline produces outputs for a "web sequence" version of
     a BITS or JATS file.
     
     An input document is split into separate pieces for separate files
     (HTML pages), with functioning links.
     
     An apparatus is also produced - title page, directory page and colophon,
     likewise with links.
     
     The splitting logic is configurable, by modifying the component
     stylesheet ../xslt/web/bits-mark-for-splitting.xsl.
     
     Doesn't yet support JATS! we need to fix that.
  -->
  <p:input port="source"/>
  
  <p:input port="parameters" kind="parameter"/>
  
  <!-- Port for development and debugging. -->
  <!--<p:output primary="false" port="ready-to-split">
    <p:pipe port="result" step="ready-to-split"/>
  </p:output>-->
  
  <!-- Port for development and debugging. -->
  <!-- A 'book-sequence' element aggregating books, each containing a (split) section as a (single) book-part. -->
  <p:output primary="false" port="bookparts-split-document">
    <p:pipe port="result" step="bookparts-split"/>
  </p:output>
  
  <!-- Port for development and debugging. -->
  <!--<p:output primary="false" port="bookparts-xhtml-pages">
    <p:pipe port="result" step="bookparts-xhtml-pages"/>
  </p:output>-->
  
  <!-- Ports for actual (wanted) results go here -->
  <!-- These are captured on the secondary port of the respective
       transformations, which bind the results via xsl:result-document 
       to the indicated baseURI (to be available for zipping later). -->
  <!-- A sequence of HTML pages, one per (split) chunk -->
  
  <p:option name="target-format" select="'epub'"/>
  
  <p:output primary="false" port="page-sequence" sequence="true">
    <p:pipe port="bound-to-URI" step="bookpart-page-sequence"/>
  </p:output>
  
  <p:output primary="false" port="apparatus" sequence="true">
    <p:pipe port="bound-to-URI" step="toc-file"/>
    <p:pipe port="bound-to-URI" step="titlepage-file"/>
    <p:pipe port="bound-to-URI" step="halftitle-file"/>
    <p:pipe port="bound-to-URI" step="colophon-file"/>
  </p:output>
  
  <p:output primary="false" port="graphics-manifest">
    <p:pipe port="result" step="graphics-manifest"/>
  </p:output>
  
  <p:output primary="false" port="support-manifest">
    <p:pipe port="result" step="support-manifest"/>
  </p:output>
  
  <p:output primary="false" port="source-ready" sequence="true">
    <p:pipe port="result" step="marked-for-splitting"/>
  </p:output>
  
  <p:serialization port="page-sequence"            indent="true"/>
  <p:serialization port="apparatus"                indent="true"/>
  <p:serialization port="graphics-manifest"        indent="true"/>
  <p:serialization port="support-manifest"         indent="true"/>
  <p:serialization port="bookparts-split-document" indent="true"/>
  <p:serialization port="source-ready"             indent="true"/>
  
  <p:variable name="documentURI" select="document-uri(/)"/>
  
  <p:import href="xml-bindtoURI.xpl"/>
  
  <!-- First there are a number of small interventions that may also need to be
       performed. -->
  <!-- In this pass we also cast JATS into BITS by wrapping a JATS document
       in a BITS document with a book-part for each article/subarticle ... -->
  <!-- The results of this step are also inputs for steps in subpipelines
       that generate ToC page, etc. -->
  <p:xslt name="ready-to-split">
    <p:input port="stylesheet">
      <p:document href="../xslt/web/jatskit-fixup.xsl"/>
    </p:input>  
  </p:xslt>
  
  <!-- Delivers a copy of the input BITS document, with marks for splitting.
       Can be modified to provide a different splitting logic. -->
  <p:xslt name="marked-for-splitting">
    <!-- Adds a flag where files should be split out. Note: these can nest!
         Splitting will occur recursively.
         
         Complex "chunking" (which may entail not only splitting but also merging)
         is possible iff concerns about metadata propagation and (valid) result element
         construction can be mitigated in the implementation.
                  
         Also adds IDs where there are none, on book-part and sec elements - but
         inputs invalid to the unique ID requirement will result in spazzy outputs.
         The assumption is that all other XIncludes or other inclusion
         mechanism will provide unique identifiers within the *new* (assembled) document scope.
         
     XXX Finally, bits-mark-for-splitting expands relative URIs given on graphic/@href into absolute URIs
         (found relative to the location of the source).
         
         An exception: if subordinate JATS 'article' elements are found, their IDs and @rid values
         are prepended with the JATS @id value for disambiguation.
    -->
    <p:input port="stylesheet">
      <p:document href="../xslt/web/jatskit-mark-for-splitting.xsl"/>
    </p:input>  
  </p:xslt>
  
  <!--<p:identity name="bookparts-split"/>-->
  <!-- Delivers a single jatskit:book-sequence element, containing
       a series of discrete book elements. Each is a complete BITS document containing
       (in its book-body or book-back) a single book-part, with the top-level
       book-meta replicated across the books. Within each book document, the location of other
       split components (for example, nested book-part elements) are indicated with
       jatskit:split elements, whose target IDs are marked as @to.
       -->
  <p:xslt name="bookparts-split">
    <p:input port="stylesheet">
      <p:document href="../xslt/web/jatskit-split.xsl"/>
    </p:input>  
  </p:xslt>
  
  <!-- Next, transpose each of these books into HTML, still in their wrapper -->
  <!-- bits-web-html.xsl also marks @xml:base attributes
       on /jatksit-page-sequence/html, indicating a safe file name for
       the results. Note these are still 'logical' results, not serialized anywhere
       until told to (perhaps in a subsequent pipeline). -->
  <p:xslt name="bookparts-html-pages">
    <!-- These pages will be placed down a level so path-to-root goes back up. -->
    <p:with-param name="path-to-root" select="'..'"/>
    <!-- Target format defaults to 'epub' but can be overridden for other (web) outputs. -->
    <p:with-param name="format" select="$target-format"/>
    <p:input port="stylesheet">
      <p:document href="../xslt/web/jatskit-ebook-html.xsl"/>
    </p:input>
  </p:xslt>
  
  <!-- Before producing, we map no namespace over to XHTML as well. -->
  <p:xslt name="bookparts-xhtml-pages">
    <p:input port="stylesheet">
      <p:document href="../xslt/web/jatskit-cast-xhtml.xsl"/>
    </p:input>  
  </p:xslt>
  
  <!-- Finally we call a step that produces discrete XHTML documents bound
       to target URIs by calling xsl:result-document and reading the secondary port. -->
  <jatskit:xml-bindtoURI name="bookpart-page-sequence"/>
  
  <p:sink/>
  
  <!-- Starting up again - to produce a directory (ToC) page -->
  <p:xslt>
    <p:input port="source">
      <!-- Main source port: the original, unsplit BITS document, after ID cleanup, marked for splitting -->
      <p:pipe port="result" step="marked-for-splitting"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../xslt/web/jatskit-ebook-toc.xsl"/>
      <!-- Note the directory needs to know where files are being split, to
           write links correctly ... hence the usefulness of @jatskit:split markers. -->
    </p:input>  
  </p:xslt>

  <!-- Cast it into XHTML. (We can't produce XHTML directly since we again wish to fall back
       to NLM Preview XSLT for our display, and it produces HTML in no namespace. -->
  <p:xslt name="toc-xhtml-page">
    <p:input port="stylesheet">
      <p:document href="../xslt/web/jatskit-cast-xhtml.xsl"/>
    </p:input>  
  </p:xslt>
  
  <!-- Now, bind it to a URI on a secondary port, and produce that. -->
  <jatskit:xml-bindtoURI name="toc-file"/>

  <p:sink/>
  
  <!-- Next, the same for the title page. -->
  <p:xslt>
    <p:input port="source">
      <!-- Main source port: the original, unsplit BITS document -
           after ID cleanup, marked for splitting -->
      <p:pipe port="result" step="marked-for-splitting"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../xslt/web/jatskit-ebook-titlepage.xsl"/>
    </p:input>  
  </p:xslt>
  
  <p:xslt name="titlepage-xhtml-page">
    <p:input port="stylesheet">
      <p:document href="../xslt/web/jatskit-cast-xhtml.xsl"/>
    </p:input>  
  </p:xslt>
  
  <jatskit:xml-bindtoURI name="titlepage-file"/>
  
  <p:sink/>
  
  <p:xslt>
    <p:input port="source">
      <p:pipe port="result" step="marked-for-splitting"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../xslt/web/jatskit-ebook-halftitle.xsl"/>
    </p:input>  
  </p:xslt>
  
  <p:xslt name="halftitle-xhtml-page">
    <p:input port="stylesheet">
      <p:document href="../xslt/web/jatskit-cast-xhtml.xsl"/>
    </p:input>  
  </p:xslt>
   
  <jatskit:xml-bindtoURI name="halftitle-file"/>
  
  <p:sink/>
  
  <p:xslt>
    <p:input port="source">
      <p:pipe port="result" step="marked-for-splitting"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../xslt/web/jatskit-ebook-colophon.xsl"/>
    </p:input>  
  </p:xslt>
   
  <p:xslt name="colophon-xhtml-page">
    <p:input port="stylesheet">
      <p:document href="../xslt/web/jatskit-cast-xhtml.xsl"/>
    </p:input>  
  </p:xslt>
  
  <jatskit:xml-bindtoURI name="colophon-file"/>
  
  <p:sink/>

  <p:xslt name="graphics-manifest">
    <p:input port="source">
      <p:pipe port="result" step="marked-for-splitting"/>
    </p:input>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0" xmlns:xlink="http://www.w3.org/1999/xlink">
          <!-- Function declarations for here... -->
          <xsl:import href="../xslt/web/jatskit-util.xsl"/>
          <xsl:template match="/">
            <xsl:variable name="target-dir"    select="resolve-uri(jatskit:book-code(),$documentURI)"/>
            <jatskit:kit>
              <!-- Element proxies for graphics files support copying them around. Both @target (a full pathname),
                   and @as (a relative pathname) are available for subsequent pipelines. -->
              <xsl:for-each-group select="//(graphic|inline-graphic)/@xlink:href" group-by=".">
                <xsl:variable name="relative-path" select="concat('graphics/',replace(current-grouping-key(),'^.*/',''))"/>
                <jatskit:graphic href="{resolve-uri(current-grouping-key(),$documentURI)}"
                target="{string-join(($target-dir,$relative-path),'/')}"
                as="{$relative-path}" suffix="{replace(current-grouping-key(),'^.*\.','')}"/>
              </xsl:for-each-group>
            </jatskit:kit>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>

  <!-- Produces a manifest of support files required by all pipeline targets,
       not only particular ones. E.g., CSS files, images for JATSKit branding etc.
       (But not specific to particular targets, such as EPUB) -->
  <!-- This could be static, except the paths to which the resources will be written will vary. -->
  <p:xslt name="support-manifest">
    <p:input port="source">
      <p:pipe port="result" step="marked-for-splitting"/>
    </p:input>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0" xmlns:xlink="http://www.w3.org/1999/xlink">
          <!-- Function declarations for here... -->
          <xsl:import href="../xslt/web/jatskit-util.xsl"/>
          <xsl:template match="/">
            <xsl:variable name="target-dir" select="resolve-uri(jatskit:book-code(),$documentURI)"/>
            <jatskit:kit>
              <jatskit:css as="css/jatskit-epub.css"
                  href="../web-css/jatskit-epub.css"
         target="{$target-dir}/css/jatskit-epub.css"/>
              <jatskit:css as="css/jatskit-simple.css"
                  href="../web-css/jatskit-simple.css"
         target="{$target-dir}/css/jatskit-simple.css"/>
              <jatskit:css as="css/jats-preview.css"
   href="../xslt/jats-preview-xslt/jats-preview.css"
         target="{$target-dir}/css/jats-preview.css"/>
            </jatskit:kit>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>
  

</p:declare-step>

<!-- end of D-hub2epub.xpl -->


