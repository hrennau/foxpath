<?xml version="1.0" encoding="UTF-8"?>
<!--   Sample from Zvon Schematron tutorial (www.zvon.org)  
    Description:   A paragraph in XML 2 can only start with words specified in XML 1 (file source1.xml).-->
    <schema xmlns="http://www.ascc.net/xml/schematron" >
         <pattern name="Start of paragraph restriction.">
          <rule context="p">
               <assert test="document('source1.xml')//*[name()=substring-before(current(),' ')]">The word at the beginning of sentence is not listed in XML 1.</assert>
          </rule>
     </pattern>
</schema>