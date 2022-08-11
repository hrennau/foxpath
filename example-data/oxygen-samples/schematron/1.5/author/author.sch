<?xml version="1.0" encoding="UTF-8"?>
<!--   Sample from Zvon Schematron tutorial (www.zvon.org)  
    Description:    XML 1 (file source1.xml) contains a list of authors. These authors are referred to in XML 2. The Schematron checks if for each referred author in XML 2 exists an entry in XML 1.-->
<schema xmlns="http://www.ascc.net/xml/schematron" >
     <pattern name="Compare with the database">
          <rule context="author">
               <assert test="document('source1.xml')//author[@id=current()/@id]">The author is not in the database </assert>
          </rule>
     </pattern>
</schema>