This is the plugin that generates a Kindle .mobi file. Because the input to Kindlegen can be an epub file, this plugin is simply a thin wrapper for the base epub plugin. It provides a means for the plugin's developer to build in Kindle-specific XSLT extensions and CSS instructions.

Users of the plugin should specify any XSLT extension via the XSLT import extension point (or args.xsl param) and specify their custom CSS through args.css.

Because there is a _template.xml file you need to run the Integrator.

For example, after unzipping, issuing the following 
commands from your DITA directory to create ePub version of the indicated books, 
which are included with the DITA-OT distribution:

java -jar lib\dost.jar /i:doc\DITA-readme.ditamap /transtype:kindle

java -jar lib\dost.jar /i:doc\userguide\DITA-userguide.ditamap /transtype:kindle
