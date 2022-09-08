<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    <ns uri="http://relaxng.org/ns/structure/1.0" prefix="rng"/>
    <ns uri="http://relaxng.org/ns/compatibility/annotations/1.0" prefix="a"/>
    
    <let name="domains" value="/rng:grammar/rng:define[@name='domains-atts']/rng:optional/rng:attribute[@name='domains']/@a:defaultValue"/>
    
    <pattern id="checkDomainsDefault">
        <rule context="rng:grammar">
            <assert test="rng:define[@name='domains-atts']">
                The domains-atts pattern should de defined.
            </assert>            
        </rule>
        <rule context="rng:define[@name='domains-atts']">
            <assert test="$domains!=''">
                The domains-atts pattern should define an optional domains attribute with a default value.
            </assert>            
        </rule>
    </pattern>
   
    <pattern id="checkIncludedDomains">
        <rule context="rng:include">
            <assert test="document(@href)/rng:grammar/rng:define[@name='domains-atts-value']">
                The domain module should define a domains attribute contribution through a domains-att-value pattern.
            </assert>
            
            <assert test="min(document(@href)/rng:grammar/rng:define[@name='domains-atts-value']/rng:value/contains($domains, .))">
                The domain values defined in an included domain file should be present in the domains attribute default value.
            </assert>            
        </rule>        
    </pattern>
</schema>