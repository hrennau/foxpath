<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    
    <sch:pattern>
        <sch:rule context="*:target">
            <sch:report test="deep-equal(./node(), ../*:source/node())" role="warn">
                Source and target content are the same, probably the content is not translated!
            </sch:report>            
        </sch:rule>
    </sch:pattern>
    
</sch:schema>