<?xml version="1.0" encoding="UTF-8"?><schema xmlns="http://purl.oclc.org/dsdl/schematron">    
    
    <ns uri="http://www.w3.org/2000/svg" prefix="svg"/>
    
    <pattern id="id-unique">
    <!-- note: assumes that NCName lexical constraints are tested elsewhere -->
    <let name="id-set" value="//*[@id]"/>
    <rule context="*[@id]">
        <assert test="count($id-set[normalize-space(@id) = normalize-space(current()/@id)]) = 1">Duplicate '<value-of select="normalize-space(current()/@id)"/>'</assert>
    </rule>
</pattern>
    <pattern id="svg-fo-re">    
    <rule context="svg:foreignObject[@requiredExtensions]">
        <assert test="@requiredExtensions = 'http://www.idpf.org/2007/ops'">Invalid value (expecting: 'http://www.idpf.org/2007/ops')</assert>
    </rule>
</pattern>
        
</schema>