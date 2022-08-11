<?xml version="1.0" encoding="UTF-8"?>
<!--   Sample from Zvon Schematron tutorial (www.zvon.org)  
    Description: The sum of values of all relevant elements equals 100.-->
<schema xmlns="http://www.ascc.net/xml/schematron">
     <pattern name="Sum equals 100%.">
          <rule context="Total">
               <assert test="sum(//Percent) = 100">The values do not sum to 100%. </assert>
          </rule>
     </pattern>
</schema>
