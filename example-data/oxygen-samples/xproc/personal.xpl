<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
    xmlns:t="http://www.oxygenxml.com/ns/samples/personal"
    version="1.0">
    <!-- Declare the input and bind it on the document to be split. -->
    <p:input port="source">
        <p:document href="../personal.xml"/>
    </p:input>
    <p:output port="result"></p:output>
    <!-- Select the 'person' elements... -->
    <p:filter select="//t:person"/>
    <!-- ... and store them in separate files. -->
    <p:for-each>
        <p:store>
            <p:with-option name="href" select="concat('persons/', /t:person/@id, '.xml')"/>
        </p:store>
    </p:for-each>
    <!--<p:escape-markup>
        <p:input port="source"><p:inline><x><y></y></x></p:inline></p:input>
        <p:log port="result" href="./a.txt"></p:log>
    </p:escape-markup>-->
    <p:unescape-markup>
        <p:input port="source"><p:inline><x>&lt;y/&gt;</x></p:inline></p:input>
        <p:log port="result" href="./a.txt"></p:log>
    </p:unescape-markup>
</p:declare-step>
