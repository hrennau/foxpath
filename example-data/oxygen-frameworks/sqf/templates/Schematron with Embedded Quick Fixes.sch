<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
 <sch:pattern>
     <sch:rule context="">
         <sch:assert test="" sqf:fix="fix_id">
            Assertion message.
         </sch:assert>
         
         <sqf:fix id="fix_id">
             <sqf:description>
                 <sqf:title>The fix title</sqf:title>
                 <sqf:p>The fix description</sqf:p>
             </sqf:description>
             <sqf:add node-type="element" target="elementName">
                 Element content.
             </sqf:add>
         </sqf:fix>
     </sch:rule>
 </sch:pattern>   
</sch:schema>