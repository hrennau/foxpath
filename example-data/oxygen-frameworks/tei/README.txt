<oXygen/> Text Encoding Initiative (TEI) framework 
===============================================================================

This project contains all the files required by oXygen XML Editor in order to
provide specific support for editing TEI documents.


Adding oxygen.jar inside the lib folder
===============================================================================

You have to copy oxygen.jar from the lib folder of an oXygen installation inside the 
project ../../lib folder. As an alternative, if the project is checked out inside the
frameworks directory of an oXygen installation, the ANT will use the oxygen.jar 
from that oXygen installation.  


Editing the TEI framework configuration file
===============================================================================

The configuration files are "tei4.framework", "tei5.framework", "teip5jtei.framework", and "teip5odd.framework". These can be edited using oXygen itself using the following steps: 
- open "Preferences"/"Global" page
- check "Use custom frameworks (Document Type Association) framework".
- at "Framework directory" specify the parent of the "tei" project.
- restart oXygen
- open "Preferences"/"Document Type Association" page. The TEI document types presented
are the ones from the "tei" project. You can edit them using the "Edit" action.

Alternatively, if the project is checked out inside the frameworks directory of 
an oXygen installation, oXygen will automatically load the framework. 


Building the distribution
===============================================================================

The project uses Apache ANT to build the distribution. The "build.xml" file
contains the ant targets. In order to obtain a distribution run "ant" inside 
a command line or use Eclipse to "Run as->Ant build" over the build file.


Deployment
===============================================================================

After building the project, you must unzip the resulting "dist/tei.zip" file inside
oXygen frameworks folder. By default this is "{oXygenInstallationDir}/frameworks" folder but 
it can be changed as described at step "Editing the TEI framework configuration file". 
oXygen will automatically load the framework. 