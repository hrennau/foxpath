<?xml version="1.0" encoding="UTF-8"?>
<!--   Sample from Zvon Schematron tutorial (www.zvon.org)  
    Description:    Value of the attribute is two or three character abbreviation. -->
<schema xmlns="http://www.ascc.net/xml/schematron">
     <pattern name="Number of characters in an abbreviation">
          <rule context="BBB">
               <report test="string-length(@bbb) &lt; 2">There is not enough letters in the
                    abbreviation</report>
               <report test="string-length(@bbb) > 3">There is too much letters in the abbreviation
               </report>
          </rule>
     </pattern>
</schema>
