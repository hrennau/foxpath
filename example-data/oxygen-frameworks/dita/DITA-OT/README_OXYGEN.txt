Differences between the DITA Open Toolkit bundled with Oxygen and a regular DITA Open Toolkit distribution
downloaded from the DITA-OT project:

http://sourceforge.net/projects/dita-ot/files/

--------ADDITIONAL INSTALLED PLUGINS---------------

plugins/com.oxygenxml.webhelp   ->   Plugin for generating WebHelp output developed and implemented by Oxygen.
plugins/com.oxygenxml.highlight   ->   Plugin for highlighting codeblock content developed and implemented by Oxygen.
plugins/com.oxygenxml.pdf.prince  -> Plugin for building PDF using DITA + CSS.
plugins/mathml                  ->   Plugin for minimal MathML specialization support implemented by Oxygen.
plugins/com.oxygenxml.media   ->   Plugin for publishing DITA object elements to HTML 5 video, audio and iframe.

plugins/net.sourceforge.dita4publishers.*  -> Plugins from the Dita For Publishers project used to generate EPUB output.

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

The following patches have been made:

plugins/org.dita.pdf2/xsl/fo/commons.xsl
  EXM-18109 Also break line before title of figure if the image has a placement break.
  EXM-18138 Add a little extra space after inline image
 
plugins/org.dita.pdf2/build_xep.xml
plugins/org.dita.pdf2/build.xml
  EXM-10624 Also reference Java Classpath in order to load Oxygen patches 

plugins/org.dita.pdf2/build.xml
plugins/org.dita.pdf2/build_template.xml
plugins/org.dita.pdf2/cfg/common/vars/en.xml
plugins/org.dita.pdf2/cfg/common/vars/de.xml
plugins/org.dita.pdf2/cfg/common/vars/es.xml
plugins/org.dita.pdf2/cfg/common/vars/fi.xml
plugins/org.dita.pdf2/cfg/common/vars/fr.xml
plugins/org.dita.pdf2/cfg/common/vars/he.xml
plugins/org.dita.pdf2/cfg/common/vars/it.xml
plugins/org.dita.pdf2/cfg/common/vars/ja.xml
plugins/org.dita.pdf2/cfg/common/vars/nl.xml
plugins/org.dita.pdf2/cfg/common/vars/ro.xml
plugins/org.dita.pdf2/cfg/common/vars/ru.xml
plugins/org.dita.pdf2/cfg/common/vars/sv.xml
plugins/org.dita.pdf2/cfg/common/vars/zh_CN.xml
  EXM-28510 Use the same icon images for notes (warning, important, tip, caution, danger, etc.) in PDF output as in Author editor and in Webhelp output
  
resource/commonltr.css
  EXM-18359, EXM-18138, EXM-17248 Small style changes for HTML output
    
xsl/map2htmlhelp/map2hhpImpl.xsl
  EXM-18626 Changes for better CHM rendering
  
xsl/xslhtml/dita2htmlImpl.xsl
  EXM-18109 Put the image in a DIV with a class, so it can be styled from CSS.
  EXM-23575 Use either proportional or fixed column widths
  EXM-31371 Using just the "Figure: " static text, without the figure number.
  
xsl/contexts.xsl
    EXM-18224  Create "contexts.xml" for Eclipse Help

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
  
build_init.xml 
  EXM-21393 Do not specify the JVM architecture, set value forced to empty
  EXM-23321 display warning if Saxon EE not licensed because not run from Oxygen
  EXM-17248 Added 'clean.output' parameter
  
build_preprocess_template.xml
  EXM-17248 Added 'clean.output' parameter
  
build_template.xml
  EXM-17248 Added 'clean.output' parameter
  
plugins/org.dita.pdf2/build_fop.xml
    EXM-27325 Added the macro runFOPInExternalJVM for running Apache FOP in external JVM 

plugins/org.dita.pdf2/cfg/fo/font-mappings.xml
    EXM-28875 Set fallback fonts for Asian and RTL languages for PDF output.
    
xsl/xslhtml/dita2htmlImpl.xsl
    EXM-29036 Use <img> for all types of images including SVG.

lib/dost.jar
	EXM-25343 Create correctly Next and Prev links.
	
plugins/net.sourceforge.dita4publishers.epub/build_transtype-epub.xml
plugins/net.sourceforge.dita4publishers.epub/build_transtype-epub_template.xml
	EXM-28673 Updated ANT to version 1.9.3.

plugins/org.dita.xhtml/xsl/xslhtml/dita2htmlImpl.xsl
	EXM-30742 Include figure title and figure description in the same paragraph.

plugins/org.dita.xhtml/xsl/xslhtml/dita2htmlImpl.xsl
	EXM-30937 Compute the correct value for DITA2PROJECT variable necessary for path of default CSSs.
	
plugins/org.dita.xhtml/xsl/xslhtml/dita2htmlImpl.xsl
	EXM-30897 Keep the lang and xml:lang attributes on the <html> root element in XHTML output files.
	
plugins/org.dita.htmlhelp/build_dita2htmlhelp.xml
plugins/org.dita.htmlhelp/xsl/map2htmlhelp/map2hhpImpl.xsl
	EXM-31236 Add parameter args.htmlhelp.default.topic in DITA CHM transform that sets the 
	                  path of the topic opened by default in CHM output.
	
plugins/org.dita.xhtml/resource/commonltr.css
plugins/org.dita.xhtml/resource/commonrtl.css
	EXM-31454 Removed margin-top for top level topics that was added only in pages 
	                   containing more than one topic (created by the attribute chunk="to-content").

plugins/org.dita.xhtml/resource/commonltr.css
plugins/org.dita.xhtml/resource/commonrtl.css
	EXM-31508 Make wintitle content bold in output of DITA transformations. 

plugins/org.dita.xhtml/xsl/xslhtml/dita2htmlImpl.xsl
	EXM-31572 Normalize space in tooltip text of glossary term.
	
plugins/org.dita.eclipsehelp/xsl/contexts.xsl
	EXM-31974 Avoid parsing binary resource files as XHTML files.
	
plugins/org.dita.xhtml/xsl/xslhtml/dita2htmlImpl.xsl
	EXM-33743 Skip img/data-about in XHTML output.
	
Added documentation annotations to DTDs in "dtd" folder.