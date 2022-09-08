Differences between the DITA Open Toolkit bundled with Oxygen and a regular DITA Open Toolkit distribution
downloaded from the DITA-OT project:

http://www.dita-ot.org/

--------ADDITIONAL INSTALLED PLUGINS---------------

plugins/com.oxygenxml.webhelp.classic   ->   Plugin for generating WebHelp Classic output developed and implemented by Oxygen.
plugins/com.oxygenxml.webhelp.responsive   ->   Plugin for generating WebHelp Responsive output developed and implemented by Oxygen.
plugins/com.oxygenxml.highlight   ->   Plugin for highlighting codeblock content developed and implemented by Oxygen.
plugins/com.oxygenxml.media   ->   Plugin for publishing DITA object elements to HTML 5 video, audio and iframe.
plugins/com.oxygenxml.pdf.prince  -> Plugin for building PDF using DITA + CSS.

plugins/com.oxygenxml.html.custom       
    -> Customizes some common HTML behaviors:
       EXM-18109 Put the image in a DIV with a class, so it can be styled from CSS.
       EXM-31371 Using just the "Figure: " static text, without the figure number.
       EXM-33743 Skip img/data-about in XHTML output.
            
plugins/com.oxygenxml.pdf.custom       
   -> Customizes:
       EXM-28510 Use the same icon images for notes (warning, important, tip, caution, danger, etc.) in PDF output as in Author editor and in Webhelp output
       EXM-18109 Also break line before title of figure if the image has a placement break.
                   
plugins/mathml                  ->   Plugin for minimal MathML specialization support implemented by Oxygen.

--------REMOVED RESOURCES----------------
The following directories have been removed:

tools
doc

The following libraries have been removed (and the equivalent ones in "OXYGEN_INSTALL_DIR\lib" are used instead):

lib\saxon\saxon9.jar
lib\saxon\saxon9-dom.jar
lib\xercesImpl.jar
lib\xml-apis.jar
lib\icu4j.jar

The bundled ANT distribution "tools\ant" has been removed and the "OXYGEN_INSTALL_DIR\tools\ant" is used instead.

----------PATCHES---------------------

resource/commonltr.css
resource/commonrtl.css
	EXM-31454 Removed margin-top for top level topics that was added only in pages 
	                   containing more than one topic (created by the attribute chunk="to-content").
	EXM-31508 Make wintitle content bold in output of DITA transformations. 
    EXM-18359, EXM-18138, EXM-17248 Small style changes for HTML output
  

xsl/map2htmlhelp/map2hhpImpl.xsl
xsl/map2htmlhelp/map2hhpImpl.xsl
    EXM-18626 Changes for better CHM rendering
	EXM-31236 Add parameter args.htmlhelp.default.topic in DITA CHM transform that sets the 
	                  path of the topic opened by default in CHM output.
  
xsl/map2javahelpmap.xsl
  EXM-18765 Fixed broken links on children of reused topic refs
  EXM-33812 Look for copy-to attributes.
  
xsl/map2javahelptoc.xsl
  EXM-18359 Correctly look for title of map
  EXM-22437 Removed extra spaces due to frontmatter, toc, backmatter
  EXM-21663 Normalize title text
  EXM-33812 Look for copy-to attributes.
  
xsl/map2javahelpset.xsl
  Normalize map title
  
build_dita2javahelp.xml
  EXM-18027 Correct generated help IDs
  
plugins/org.dita.pdf2/cfg/fo/font-mappings.xml
  EXM-36125 Fallback fonts for asian and RTL languages.

plugins/org.dita.xhtml/xsl/xslhtml/dita2htmlImpl.xsl
  EXM-36339 Fixed for the style attribute generated on TD elements form RTL tables. It aligned the content to the left.
       