<?xml version="1.0" encoding="UTF-8"?>
<!--   Sample from Zvon Schematron tutorial (www.zvon.org)  
    Description:    The element must have the attribute, if it is inside another one, but it must not have the one otherwise. -->
<schema xmlns="http://www.ascc.net/xml/schematron">
     <pattern name="Test attribute">
          <rule context="CCC">
               <report test="parent::BBB and not(@id)">Attribute id is missing</report>
               <report test="not(parent::BBB) and @id">Attribute id is used in wrong context
               </report>
          </rule>
     </pattern>
</schema>
