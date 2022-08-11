<?xml version="1.0" encoding="UTF-8"?>
<!--   Sample from Zvon Schematron tutorial (www.zvon.org)  
    Description:    If the element has one attribute then it must have the second one as well. -->
<schema xmlns="http://www.ascc.net/xml/schematron">
     <pattern name="Attributes present">
          <rule context="BBB">
               <assert test="not(@aaa) or (@aaa and @bbb)">The element must not have an isolated aaa
                    attribute</assert>
               <assert test="not(@bbb) or (@aaa and @bbb)">The element must not have an isolated bbb
                    attribute</assert>
          </rule>
     </pattern>
</schema>
