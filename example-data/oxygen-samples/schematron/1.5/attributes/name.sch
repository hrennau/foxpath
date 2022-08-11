<?xml version="1.0" encoding="UTF-8"?>
<!--   Sample from Zvon Schematron tutorial (www.zvon.org)  
    Description:    If an element contains an attribute , the attribute name must be id.. -->
<schema xmlns="http://www.ascc.net/xml/schematron">
     <pattern name="id is the only permited attribute name">
          <rule context="*">
               <report test="@*[not(name()='id')]">Atrribute <name path="@*[not(name()='id')]"/> is
                    forbidden in element <name/>
               </report>
          </rule>
     </pattern>
</schema>
