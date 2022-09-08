<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
     
     <!-- This file is generated from param.xweb -->
     
     <!-- ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or http://cdn.docbook.org/release/xsl/current/ for
     copyright and other information.

     ******************************************************************** -->
     
     
     <doc:refentry xmlns:doc="http://nwalsh.com/xsl/documentation/1.0" id="wordml.template">
          <refmeta>
               <refentrytitle>wordml.template</refentrytitle>
               <refmiscinfo class="other" otherclass="datatype">uri</refmiscinfo>
          </refmeta>
          <refnamediv>
               <refname>wordml.template</refname>
               <refpurpose>Specify the template WordML document</refpurpose>
          </refnamediv>
          
          
          
          <refsection><info><title>Description</title></info>
               
               <para>The <parameter>wordml.template</parameter> parameter specifies a WordML document to use as a template for the generated document.  The template document is used to define the (extensive) headers for the generated document, in particular the paragraph and character styles that are used to format the various elements.  Any content in the template document is ignored.</para>
               
               <para>A template document is used in order to allow maintenance of the paragraph and character styles to be done using Word itself, rather than these XSL stylesheets.</para>
               
          </refsection>
     </doc:refentry>
     <xsl:param name="wordml.template"/>
     
     <doc:refentry xmlns:doc="http://nwalsh.com/xsl/documentation/1.0" id="pages.template">
          <refmeta>
               <refentrytitle>pages.template</refentrytitle>
               <refmiscinfo class="other" otherclass="datatype">uri</refmiscinfo>
          </refmeta>
          <refnamediv>
               <refname>pages.template</refname>
               <refpurpose>Specify the template Pages document</refpurpose>
          </refnamediv>
          
          
          
          <refsection><info><title>Description</title></info>
               
               <para>The <parameter>pages.template</parameter> parameter specifies a Pages (the Apple word processing application) document to use as a template for the generated document.  The template document is used to define the (extensive) headers for the generated document, in particular the paragraph and character styles that are used to format the various elements.  Any content in the template document is ignored.</para>
               
               <para>A template document is used in order to allow maintenance of the paragraph and character styles to be done using Pages itself, rather than these XSL stylesheets.</para>
               
          </refsection>
     </doc:refentry>
     <xsl:param name="pages.template"/>
</xsl:stylesheet>
