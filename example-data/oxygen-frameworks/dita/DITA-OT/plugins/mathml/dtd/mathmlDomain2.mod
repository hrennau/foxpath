<?xml version="1.0" encoding="UTF-8"?>

<!--
    <public publicId="-//FIRELAB//ELEMENTS DITA 1.1 MathML Domain 3//EN"  uri="mathmlDomain2.mod"/>
    <system systemId="http://www.smoke-fire.us/svn/firelab/common/trunk/xml/firelab-doctypes/mathmlDomain2.mod" uri="mathmlDomain2.mod"/>
-->

<!-- included MathML document type -->
<!ENTITY % MATHML.prefixed "INCLUDE">
<!ENTITY % MATHML.prefix "mml">
<!ENTITY % MathMLstrict "INCLUDE">
<!ENTITY % mathml 
PUBLIC "-//W3C//DTD MathML 2.0//EN"
      "http://www.w3.org/Math/DTD/mathml2/mathml2.dtd" >
%mathml;

<!--
  Entity declarations for elements defined here.
-->
<!ENTITY % math      "math">
<!ENTITY % mathph    "mathph">
<!ENTITY % equation  "equation">
<!ENTITY % eqsymbols "eqsymbols">
<!ENTITY % eqsymbol  "eqsymbol">
<!ENTITY % symname   "symname">
<!ENTITY % symdesc   "symdesc">
<!ENTITY % symdescph "symdescph">
<!ENTITY % eqdefsph  "eqdefsph">
<!ENTITY % eqdefstbl "eqdefstbl">

<!-- 
    Common attributes for elements containing or referring to math expressions.
-->
<!ENTITY % math-atts
    'href       CDATA                                         #IMPLIED
     format     (mathml | openmath | 
                  opendocument | -dita-use-conref-target)     #IMPLIED
     type       (content | presentation | symbol |
                  -dita-use-conref-target )                   #REQUIRED' >
                  
<!-- 
    Content model for inline and tabular display elements.
-->
<!ENTITY % eqdisp.cnt  "((%eqsymbols;) | ((%xref;)+,(%eqsymbols;)*) ) " >

<!ELEMENT mathph (%math.qname;)* >
<!ATTLIST mathph
  %math-atts;
  %univ-atts;
  outputclass CDATA #IMPLIED
  xmlns:mml CDATA #FIXED "http://www.w3.org/1998/Math/MathML">

<!ELEMENT math (%math.qname;)* >
<!ATTLIST math
  %math-atts;
  %univ-atts;
  outputclass CDATA #IMPLIED
  xmlns:mml CDATA #FIXED "http://www.w3.org/1998/Math/MathML"> 

<!ELEMENT equation ((%title;)?, (%desc;)?, (%math;), (%eqsymbols;)?) >
<!ATTLIST equation
  %univ-atts;
  %display-atts;
  outputclass CDATA #IMPLIED
>

<!ELEMENT eqsymbols ( (%eqsymbol;)+ )>
<!ATTLIST eqsymbols
  %univ-atts;
  outputclass CDATA #IMPLIED
>

<!ELEMENT eqsymbol ( (%symname;),  (((%symdescph;), (%symdesc;)?) | ((%symdesc;), (%symdescph;)?))) >
<!ATTLIST eqsymbol
  %univ-atts;
  outputclass CDATA #IMPLIED
>

<!--
   You can either specify the <ci>, <mi>, or <csymbol> which you are defining, or you 
   may simply type text.  If you need fancy formatting like subscripts, etc. just use 
   the presentation MathML syntax using the <mathph> element.
-->
<!ELEMENT symname (%term.cnt;)*  >
<!ATTLIST symname
  %univ-atts;
  outputclass CDATA #IMPLIED
>

<!ELEMENT symdesc ( %defn.cnt; )* >
<!ATTLIST symdesc
  %univ-atts;
  outputclass CDATA #IMPLIED
>

<!ELEMENT symdescph ( %defn.cnt; )* >
<!ATTLIST symdescph
  %univ-atts;
  outputclass CDATA #IMPLIED
>

<!ELEMENT eqdefsph ( %eqdisp.cnt; )* >
<!ATTLIST eqdefsph
  %univ-atts;
  outputclass CDATA #IMPLIED
>

<!ELEMENT eqdefstbl ( %eqdisp.cnt; )* >
<!ATTLIST eqdefstbl
  %univ-atts;
  outputclass CDATA #IMPLIED
>

<!ATTLIST mathph %global-atts; class CDATA "+ topic/foreign math-d/mathph ">
<!ATTLIST math %global-atts; class CDATA "+ topic/foreign math-d/math " >
<!ATTLIST equation %global-atts; class CDATA "+ topic/fig math-d/equation " >
<!ATTLIST eqsymbols %global-atts; class CDATA "+ topic/dl math-d/eqsymbols ">
<!ATTLIST eqsymbol %global-atts; class CDATA "+ topic/dlentry math-d/eqsymbol ">
<!ATTLIST symname %global-atts; class CDATA "+ topic/dt math-d/symname ">
<!ATTLIST symdesc %global-atts; class CDATA "+ topic/dd math-d/symdesc ">
<!ATTLIST symdescph %global-atts; class CDATA "+ topic/dd math-d/symdescph ">
<!ATTLIST eqdefsph %global-atts; class CDATA "+ topic/unknown math-d/eqdefsph ">
<!ATTLIST eqdefstbl %global-atts; class CDATA "+ topic/unknown math-d/eqdefstbl ">

