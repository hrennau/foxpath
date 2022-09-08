<?xml version="1.0" encoding="UTF-8"?>
<!-- ============================================================= -->
<!--                    HEADER                                     -->
<!-- ============================================================= -->
<!--  MODULE:    DITA Map Group Domain                             -->
<!--  VERSION:   1.2                                               -->
<!--  DATE:      November 2009                                     -->
<!--                                                               -->
<!-- ============================================================= -->

<!-- ============================================================= -->
<!--                    PUBLIC DOCUMENT TYPE DEFINITION            -->
<!--                    TYPICAL INVOCATION                         -->
<!--                                                               -->
<!--  Refer to this file by the following public identifier or an 
      appropriate system identifier 
PUBLIC "-//OASIS//ELEMENTS DITA Map Group Domain//EN"
      Delivered as file "mapGroup.mod"                             -->

<!-- ============================================================= -->
<!-- SYSTEM:     Darwin Information Typing Architecture (DITA)     -->
<!--                                                               -->
<!-- PURPOSE:    Define elements and specialization attributes     -->
<!--             for Map Group Domain                              -->
<!--                                                               -->
<!-- ORIGINAL CREATION DATE:                                       -->
<!--             March 2001                                        -->
<!--                                                               -->
<!--             (C) Copyright OASIS Open 2005, 2009.              -->
<!--             (C) Copyright IBM Corporation 2001, 2004.         -->
<!--             All Rights Reserved.                              -->
<!--                                                               -->
<!--  UPDATES:                                                     -->
<!--    2005.11.15 RDA: Corrected the "Delivered as" system ID     -->
<!--    2006.06.07 RDA: Make universal attributes universal        -->
<!--                      (DITA 1.1 proposal #12)                  -->
<!--    2007.12.01 EK:  Reformatted DTD modules for DITA 1.2       -->
<!--    2008.02.01 RDA: Added keydef element, keys attributes      -->
<!--    2008.02.12 RDA: Navtitle no longer required on topichead   -->
<!--    2008.02.13 RDA: Create .content and .attributes entities   -->
<!--    2010.09.20 RDA: Add copy-to to topichead                   -->
<!-- ============================================================= -->


<!-- ============================================================= -->
<!--                    ELEMENT NAME ENTITIES                      -->
<!-- ============================================================= -->

<!ENTITY % anchorref    "anchorref"                                  >
<!ENTITY % keydef       "keydef"                                     >
<!ENTITY % mapref       "mapref"                                     >
<!ENTITY % topicgroup   "topicgroup"                                 >
<!ENTITY % topichead    "topichead"                                  >
<!ENTITY % topicset     "topicset"                                   >
<!ENTITY % topicsetref  "topicsetref"                                >


<!-- ============================================================= -->
<!--                    ELEMENT DECLARATIONS                       -->
<!-- ============================================================= -->


<!--                    LONG NAME: Topic Head                      -->
<!ENTITY % topichead.content
                       "((%topicmeta;)?, 
                         (%anchor; | 
                          %data.elements.incl; | 
                          %navref; | 
                          %topicref;)* )"
>
<!ENTITY % topichead.attributes
             "navtitle 
                        CDATA 
                                  #IMPLIED
              outputclass 
                        CDATA 
                                  #IMPLIED
              keys 
                        CDATA 
                                  #IMPLIED
              copy-to 
                        CDATA 
                                  #IMPLIED
              %topicref-atts;
              %univ-atts;"
>
<!--doc:The <topichead> element provides a title-only entry in a navigation map, as an alternative to the fully-linked title provided by the <topicref> element.
Category: Mapgroup elements-->
<!ELEMENT topichead    %topichead.content;>
<!ATTLIST topichead    %topichead.attributes;>



<!--                    LONG NAME: Topic Group                     -->
<!ENTITY % topicgroup.content
                       "((%topicmeta;)?, 
                         (%anchor; | 
                          %data.elements.incl; | 
                          %navref; | 
                          %topicref;)* )"
>
<!ENTITY % topicgroup.attributes
             "outputclass 
                        CDATA 
                                  #IMPLIED
              %topicref-atts;
              %univ-atts;"
>
<!--doc:The <topicgroup> element is for creating groups of <topicref> elements without affecting the hierarchy, as opposed to nested <topicref> elements within a <topicref>, which does imply a structural hierarchy. It is typically used outside a hierarchy to identify groups for linking without affecting the resulting toc/navigation output.
Category: Mapgroup elements-->
<!ELEMENT topicgroup    %topicgroup.content;>
<!ATTLIST topicgroup    %topicgroup.attributes;>


<!--                    LONG NAME: Anchor Reference                -->
<!ENTITY % anchorref.content
                       "((%topicmeta;)?, 
                         (%data.elements.incl; |
                          %topicref;)* )"
>
<!ENTITY % anchorref.attributes
             "navtitle 
                        CDATA 
                                  #IMPLIED
              href 
                        CDATA 
                                  #IMPLIED
              keyref 
                        CDATA 
                                  #IMPLIED
              keys 
                        CDATA 
                                  #IMPLIED
              query 
                        CDATA 
                                  #IMPLIED
              copy-to 
                        CDATA 
                                  #IMPLIED
              outputclass 
                        CDATA 
                                  #IMPLIED
              collection-type 
                        (choice | 
                         family | 
                         sequence | 
                         unordered |
                         -dita-use-conref-target) 
                                  #IMPLIED
              processing-role
                        (normal |
                         resource-only |
                         -dita-use-conref-target)
                                  #IMPLIED
              type 
                        CDATA 
                                  'anchor'
              scope 
                        (external | 
                         local | 
                         peer | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              locktitle 
                        (no | 
                         yes | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              format 
                        CDATA 
                                  'ditamap'
              linking 
                        (none | 
                         normal | 
                         sourceonly | 
                         targetonly |
                         -dita-use-conref-target) 
                                  #IMPLIED
              toc 
                        (no | 
                         yes | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              print 
                        (no | 
                         printonly | 
                         yes | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              search 
                        (no | 
                         yes | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              chunk 
                        CDATA 
                                  'to-navigation'
              %univ-atts;"
>
<!--doc:The contents of an <anchorref> element are rendered both in the original authored location and at the location of the referenced <anchor> element. The referenced <anchor> element can be defined in the current map or another map.-->
<!ELEMENT anchorref    %anchorref.content;>
<!ATTLIST anchorref    %anchorref.attributes;>


<!--                    LONG NAME: Map Reference                   -->
<!ENTITY % mapref.content
                       "((%topicmeta;)?, 
                         (%data.elements.incl;)* )"
>
<!ENTITY % mapref.attributes
             "navtitle 
                        CDATA 
                                  #IMPLIED
              href 
                        CDATA 
                                  #IMPLIED
              keyref 
                        CDATA 
                                  #IMPLIED
              keys 
                        CDATA 
                                  #IMPLIED
              query 
                        CDATA 
                                  #IMPLIED
              copy-to 
                        CDATA 
                                  #IMPLIED
              outputclass 
                        CDATA 
                                  #IMPLIED
              format 
                        CDATA 
                                  'ditamap'
              %topicref-atts-without-format;
              %univ-atts;"
>
<!--doc:The <mapref> element is a convenience element that has the same meaning as a <topicref> element that explicitly sets the format attribute to "ditamap". The hierarchy of the referenced map is merged into the container map at the position of the reference, and the relationship tables of the child map are added to the parent map.-->
<!ELEMENT mapref    %mapref.content;>
<!ATTLIST mapref    %mapref.attributes;>


<!--                    LONG NAME: Topicset                        -->
<!ENTITY % topicset.content
                       "((%topicmeta;)?, 
                         (%anchor; | 
                          %data.elements.incl; |
                          %navref; | 
                          %topicref;)* )"
>
<!ENTITY % topicset.attributes
             "navtitle 
                        CDATA 
                                  #IMPLIED
              href 
                        CDATA 
                                  #IMPLIED
              keyref 
                        CDATA 
                                  #IMPLIED
              keys 
                        CDATA 
                                  #IMPLIED
              query 
                        CDATA 
                                  #IMPLIED
              copy-to 
                        CDATA 
                                  #IMPLIED
              outputclass 
                        CDATA 
                                  #IMPLIED
              collection-type 
                        (choice | 
                         family | 
                         sequence | 
                         unordered |
                         -dita-use-conref-target) 
                                  #IMPLIED
              processing-role
                        (normal |
                         resource-only |
                         -dita-use-conref-target)
                                  #IMPLIED
              type 
                        CDATA 
                                  #IMPLIED
              scope 
                        (external | 
                         local | 
                         peer | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              locktitle 
                        (no | 
                         yes | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              format 
                        CDATA 
                                  #IMPLIED
              linking 
                        (none | 
                         normal | 
                         sourceonly | 
                         targetonly |
                         -dita-use-conref-target) 
                                  #IMPLIED
              toc 
                        (no | 
                         yes | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              print 
                        (no | 
                         printonly | 
                         yes | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              search 
                        (no | 
                         yes | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              chunk 
                        CDATA 
                                  'to-navigation'
              id 
                        NMTOKEN 
                                  #REQUIRED
              %conref-atts;
              %select-atts;
              %localization-atts;"
>
<!--doc:The <topicset> element defines a complete unit of content that can be reused in other DITA maps or other <topicset> elements. The <topicset> element can be especially useful for task composition in which larger tasks that are composed indefinitely of smaller tasks. The id attribute on a <topicset> is required, which ensures that the complete unit is available for reuse in other contexts.-->
<!ELEMENT topicset    %topicset.content;>
<!ATTLIST topicset    %topicset.attributes;>


<!--                    LONG NAME: Topicset Reference              -->
<!ENTITY % topicsetref.content
                       "((%topicmeta;)?, 
                         (%data.elements.incl; |
                          %topicref;)* )"
>
<!ENTITY % topicsetref.attributes
             "navtitle 
                        CDATA 
                                  #IMPLIED
              href 
                        CDATA 
                                  #IMPLIED
              keyref 
                        CDATA 
                                  #IMPLIED
              keys 
                        CDATA 
                                  #IMPLIED
              query 
                        CDATA 
                                  #IMPLIED
              copy-to 
                        CDATA 
                                  #IMPLIED
              outputclass 
                        CDATA 
                                  #IMPLIED
              collection-type 
                        (choice | 
                         family | 
                         sequence | 
                         unordered |
                         -dita-use-conref-target) 
                                  #IMPLIED
              processing-role
                        (normal |
                         resource-only |
                         -dita-use-conref-target)
                                  #IMPLIED
              type 
                        CDATA 
                                  'topicset'
              scope 
                        (external | 
                         local | 
                         peer | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              locktitle 
                        (no | 
                         yes | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              format 
                        CDATA 
                                  'ditamap'
              linking 
                        (none | 
                         normal | 
                         sourceonly | 
                         targetonly |
                         -dita-use-conref-target) 
                                  #IMPLIED
              toc 
                        (no | 
                         yes | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              print 
                        (no | 
                         printonly | 
                         yes | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              search 
                        (no | 
                         yes | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              chunk 
                        CDATA 
                                  #IMPLIED
              %univ-atts;"
>
<!--doc:The <topicsetref> element references a <topicset> element. The referenced <topicset> element can be defined in the current map or in another map.-->
<!ELEMENT topicsetref    %topicsetref.content;>
<!ATTLIST topicsetref    %topicsetref.attributes;>


<!--                    LONG NAME: Key Definition                  -->
<!ENTITY % keydef.content
                       "((%topicmeta;)?, 
                         (%anchor; | 
                          %data.elements.incl; |
                          %navref; | 
                          %topicref;)* )"
>
<!ENTITY % keydef.attributes
             "navtitle 
                        CDATA 
                                  #IMPLIED
              href 
                        CDATA 
                                  #IMPLIED
              keyref 
                        CDATA 
                                  #IMPLIED
              keys 
                        CDATA 
                                  #REQUIRED
              query 
                        CDATA 
                                  #IMPLIED
              copy-to 
                        CDATA 
                                  #IMPLIED
              outputclass 
                        CDATA 
                                  #IMPLIED
              collection-type 
                        (choice | 
                         family | 
                         sequence | 
                         unordered |
                         -dita-use-conref-target) 
                                  #IMPLIED
              processing-role
                        (normal |
                         resource-only |
                         -dita-use-conref-target)
                                  'resource-only'
              type 
                        CDATA 
                                  #IMPLIED
              scope 
                        (external | 
                         local | 
                         peer | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              locktitle 
                        (no | 
                         yes | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              format 
                        CDATA 
                                  #IMPLIED
              linking 
                        (none | 
                         normal | 
                         sourceonly | 
                         targetonly |
                         -dita-use-conref-target) 
                                  #IMPLIED
              toc 
                        (no | 
                         yes | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              print 
                        (no | 
                         printonly | 
                         yes | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              search 
                        (no | 
                         yes | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              chunk 
                        CDATA 
                                  #IMPLIED
              %univ-atts;"
>
<!--doc:The <keydef> element is a convenience element that is used to define keys without any of the other effects that occur when using a <topicref> element: no content is included in output, no title is included in the table of contents, and no linking or other relationships are defined. The <keydef> element is not the only way to define keys; its purpose is to simplify the process by defaulting several attributes to achieve the described behaviors.-->
<!ELEMENT keydef    %keydef.content;>
<!ATTLIST keydef    %keydef.attributes;>


<!-- ============================================================= -->
<!--                    SPECIALIZATION ATTRIBUTE DECLARATIONS      -->
<!-- ============================================================= -->

<!ATTLIST anchorref     %global-atts;  class CDATA "+ map/topicref mapgroup-d/anchorref ">
<!ATTLIST keydef        %global-atts;  class CDATA "+ map/topicref mapgroup-d/keydef ">
<!ATTLIST mapref        %global-atts;  class CDATA "+ map/topicref mapgroup-d/mapref ">
<!ATTLIST topicgroup    %global-atts;  class CDATA "+ map/topicref mapgroup-d/topicgroup ">
<!ATTLIST topichead     %global-atts;  class CDATA "+ map/topicref mapgroup-d/topichead ">
<!ATTLIST topicset      %global-atts;  class CDATA "+ map/topicref mapgroup-d/topicset ">
<!ATTLIST topicsetref   %global-atts;  class CDATA "+ map/topicref mapgroup-d/topicsetref ">


<!-- ================== DITA Map Group Domain  =================== -->