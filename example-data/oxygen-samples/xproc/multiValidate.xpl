<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" name="multivalidate" version="1.0">
    <!-- Bind on input the personal.xml file to be validated with XML Schema, and then with Relax NG -->
    <p:input port="source">
        <p:document href="../personal.xml"/>
    </p:input>
    <!-- Declare the output port. -->
    <p:output port="result"/>
    <!-- Validate with XML Schema. -->
    <p:validate-with-xml-schema>
        <p:input port="schema">
            <p:document href="../personal.xsd"/>
        </p:input>
    </p:validate-with-xml-schema>
    <!-- Validate with Relax NG. The input document is the output of the previous
        'validate-with-xml-schema' step. -->
    <p:validate-with-relax-ng>
        <p:input port="schema">
            <p:document href="../relaxng/personal.rng"/>
        </p:input>
    </p:validate-with-relax-ng>
</p:declare-step>
