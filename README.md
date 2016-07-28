# foxpath
Reference implementation of FOXpath 3.0, an extended version of XPath 3.0 supporting file system navigation. XPath has been extended by the new foxpath expression, which allows you to navigate the file system in a way which is very similar to node navigation supported by the familiar path expression. For example, the following expression - \xsdbase\niem*\\*.xsd[file-size() lt 900] - returns the file paths of all XSD documents found at any depth under any folder niem* under folder /xsdbase, excluding all XSDs with a size greater than 900 bytes.

The XQuery modules are accompanied by the shell script fox. The script is used with a single parameter, which is a foxpath expression, and it returns the value of the expression. Unless option -b is used, the path operator (standard: /) and the foxpath operator (standard: \) are swapped, so that the following two calls would be equivalent: fox "/xsdbase/niem*//*.xsd[file-size() lt 900]" and this: fox -b "\xsdbase\niem*\\*.xsd[file-size() lt 900]". The swapping of operators is thought to enable more convenient use of foxpath when used in command-line parameters.

Documentation will be added by September 1, 2016. For the time being, please take a look at the PowerPoint presentation found in the doc folder of the project.

The implementation is written in the XQuery language, version 3.1. The current version of the language requires the use of the BaseX processor ( http://basex.org/products/download/all-downloads/ ), version 8.4 or higher. Please contact me if support for other XQuery processors is desired.
