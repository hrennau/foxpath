<?xml version="1.0" encoding="UTF-8"?>
<!--   Sample from Zvon Schematron tutorial (www.zvon.org)  
    Description:    Specification of required attribute. -->
<schema xmlns="http://www.ascc.net/xml/schematron">
     <pattern name="Attribute test">
          <rule context="CCC">
               <assert test="@name">attribute name is not present</assert>
               <report test="@name">attribute name is present</report>
          </rule>
     </pattern>
</schema>
