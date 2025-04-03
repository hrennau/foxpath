# Foxpath
Reference implementation of Foxpath 3.0, an extended version of XPath 3.0 supporting file system navigation. 
XPath has been extended by the new Foxpath expression, which allows you to navigate the file system in a way 
which is very similar to node tree navigation supported by the familiar path expression. For example, the 
following expression
<pre>\xsdbase\niem*\\*.xsd[file-size() le 900]</pre>
returns the file paths of all XSD documents found at any depth under any folder niem* under folder xsdbase, 
excluding all XSDs with a size greater than 900 bytes.

The XQuery modules are accompanied by the shell script fox. The script is used with a single parameter, 
which is a Foxpath expression, or a file containing a Foxpath expression. The script returns the value 
of the expression. Unless option -b is used, the path operator (standard: /) and the Foxpath operator 
(standard: \\) are swapped, so that the following two calls would be equivalent:  
<pre>fox "/xsdbase/niem*//*.xsd[\*\@targetNamespace\matches(., 'gml')]"</pre>
and this: 
<pre>fox -b "\xsdbase\niem*\\*.xsd[/*/@targetNamespace/matches(., 'gml')]"</pre>
The swapping of operators is thought to enable more convenient use of Foxpath when used in command-line 
parameters.

Foxpath contains a great number of utility functions available alongside with the functions defined
by the XPath 3.0 standard. Example: the following call returns the frequency distribution of document
root names in Clark notation, found in the XML documents contained by the Oxygen folder $oxygen/frameworks/dita:
<pre>fox "/programm*/*oxy*/frameworks/dita//*.xml\*[namespace-uri(.)]\cname() => freq()"</pre>
Result:
<pre>
Q{http://oxygenxml.com/dita/blockElements}blockElements ........................... (1)
Q{http://www.oxygenxml.com/ns/author/external-action}authorAction ................. (22)
Q{http://www.oxygenxml.com/ns/ccfilter/annotations}contentCompletionElementsMap ... (1)
Q{http://www.oxygenxml.com/ns/ccfilter/config}config .............................. (5)
Q{http://www.oxygenxml.com/ns/xmlRefactoring}refactoringOperationDescriptor ....... (19)
Q{http://www.reallysi.com/namespaces/indesign_style_catalog}InDesign_Style_Catalog  (1)
Q{http://www.w3.org/1999/xhtml}footer ............................................. (1)
Q{http://www.w3.org/1999/xhtml}header ............................................. (1)
Q{https://www.dita-ot.org/project}project ......................................... (1)
Q{urn:oasis:names:tc:entity:xmlns:xml:catalog}catalog ............................. (81)
Q{urn:public:dita4publishers.org:namespaces:word2dita:style2tagmap}style2tagmap ... (2)
</pre>
Take a look at doc/foxpath-intro.pdf for a general introduction to Foxpath: concepts, relationship to XPath 3.0 
and many examples of increasing complexity. The library of extension functions is described by 
doc/foxpath-extension-functions.docx.

The implementation is written in the XQuery language, version 3.1. The current version of the language requires 
the use of the BaseX processor ( http://basex.org/products/download/all-downloads/ ), version 9.6 or higher.
