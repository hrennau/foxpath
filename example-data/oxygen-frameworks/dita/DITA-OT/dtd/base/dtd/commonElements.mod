<?xml version="1.0" encoding="UTF-8"?>
<!-- ============================================================= -->
<!--                    HEADER                                     -->
<!-- ============================================================= -->
<!--  MODULE:    DITA Common Elements                              -->
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
PUBLIC "-//OASIS//ELEMENTS DITA Common Elements//EN"
      Delivered as file "commonElements.mod"                       -->

<!-- ============================================================= -->
<!-- SYSTEM:     Darwin Information Typing Architecture (DITA)     -->
<!--                                                               -->
<!-- PURPOSE:    Declaring the elements and specialization         -->
<!--             attributes for content elements used in both      -->
<!--             topics and maps.                                  -->
<!--                                                               -->
<!-- ORIGINAL CREATION DATE:                                       -->
<!--             June 2006                                         -->
<!--                                                               -->
<!--             (C) Copyright OASIS Open 2005, 2009.              -->
<!--             (C) Copyright IBM Corporation 2001, 2004.         -->
<!--             All Rights Reserved.                              -->
<!--                                                               -->
<!--  UPDATES:                                                     -->
<!--    2006.06.06 RDA: Add data element                           -->
<!--    2006.06.07 RDA: Add @scale to image                        -->
<!--    2006.06.07 RDA: Add index-base element                     -->
<!--    2006.06.07 RDA: Make universal attributes universal        -->
<!--                      (DITA 1.1 proposal #12)                  -->
<!--    2006.06.07 RDA: Add unknown element                        -->
<!--    2006.06.14 RDA: Add dir attribute to localization-atts     -->
<!--    2006.11.30 RDA: Add -dita-use-conref-target to enumerated  -->
<!--                      attributes                               -->
<!--    2007.12.01 EK:  Reformatted DTD modules for DITA 1.2       -->
<!--    2008.01.28 RDA: Add draft-comment to shortdesc             -->
<!--    2008.01.28 RDA: Remove enumeration for @disposition on     -->
<!--                    draft-comment                              -->
<!--    2008.01.29 RDA: Extend content of figgroup                 -->
<!--    2008.01.30 RDA: Add %conref-atts; and @conaction           -->
<!--    2008.02.01 RDA: Added keyref to data, data-about           -->
<!--                    Added conkeyref attr to conref attr entity -->
<!--    2008.02.12 RDA: Added text element, added to keyword, tm,  -->
<!--                    term, ph. Added ph to alt.                 -->
<!--    2008.02.12 RDA: Added longdescref; add to image, object    -->
<!--    2008.02.12 RDA: Modify imbeds to use specific 1.2 version  -->
<!--    2008.02.12 RDA: Move navtitle decl. here from topic.mod    -->
<!--    2008.02.13 RDA: Create .content and .attributes entities   -->
<!--    2008.11.10 RDA: Make href optional on image                -->
<!-- ============================================================= -->


<!-- ============================================================= -->
<!--                    ELEMENT NAME ENTITIES                      -->
<!-- ============================================================= -->

<!ENTITY % commonDefns 
  PUBLIC "-//OASIS//ENTITIES DITA 1.2 Common Elements//EN" 
         "commonElements.ent" 
>%commonDefns;

<!-- ============================================================= -->
<!--                    COMMON ELEMENT SETS                        -->
<!-- ============================================================= -->


<!--                   Phrase/inline elements of various classes   -->
<!ENTITY % basic.ph 
  "%boolean; | 
   %cite; | 
   %keyword; | 
   %ph; | 
   %q; |
   %term; | 
   %tm; | 
   %xref; | 
   %state;
  "
>

<!--                   Elements common to most body-like contexts  -->
<!ENTITY % basic.block 
  "%dl; | 
   %fig; | 
   %image; | 
   %lines; | 
   %lq; | 
   %note; | 
   %object; | 
   %ol;| 
   %p; | 
   %pre; | 
   %simpletable; | 
   %sl; | 
   %table; | 
   %ul;
  "
>

<!-- class groupings to preserve in a schema -->

<!ENTITY % basic.phandblock 
  "%basic.block; | 
   %basic.ph;
  " 
>


<!-- Exclusions: models modified by removing excluded content      -->
<!ENTITY % basic.ph.noxref
  "%boolean; | 
   %keyword; | 
   %ph; | 
   %q; |
   %term; | 
   %tm; | 
   %state;
  "
>
<!ENTITY % basic.ph.notm
  "%boolean; | 
   %cite; | 
   %keyword; | 
   %ph; | 
   %q; |
   %term; | 
   %xref; | 
   %state;
  "
>


<!ENTITY % basic.block.notbl
  "%dl; | 
   %fig; | 
   %image; | 
   %lines; | 
   %lq; | 
   %note; | 
   %object; | 
   %ol;| 
   %p; | 
   %pre; | 
   %sl; | 
   %ul;
  "
>
<!ENTITY % basic.block.nonote
  "%dl; | 
   %fig; | 
   %image; | 
   %lines; | 
   %lq; | 
   %object; | 
   %ol;| 
   %p; | 
   %pre; | 
   %simpletable; | 
   %sl; | 
   %table; | 
   %ul;
  "
>
<!ENTITY % basic.block.nopara
  "%dl; | 
   %fig; | 
   %image; | 
   %lines; | 
   %lq; | 
   %note; | 
   %object; | 
   %ol;| 
   %pre; | 
   %simpletable; | 
   %sl; | 
   %table; | 
   %ul;
  "
>
<!ENTITY % basic.block.nolq
  "%dl; | 
   %fig; | 
   %image; | 
   %lines; | 
   %note; | 
   %object; | 
   %ol;| 
   %p; | 
   %pre; | 
   %simpletable; | 
   %sl; | 
   %table; | 
   %ul;
  "
>
<!ENTITY % basic.block.notbnofg
  "%dl; | 
   %image; | 
   %lines; | 
   %lq; | 
   %note; | 
   %object; | 
   %ol;| 
   %p; | 
   %pre; | 
   %sl; | 
   %ul;
  "
>
<!ENTITY % basic.block.notbfgobj
  "%dl; | 
   %image; | 
   %lines; | 
   %lq; | 
   %note; | 
   %ol;| 
   %p; | 
   %pre; | 
   %sl; | 
   %ul;
  "
>


<!-- Inclusions: defined sets that can be added into appropriate models -->
<!ENTITY % txt.incl 
  "%draft-comment; |
   %fn; |
   %indextermref; |
   %indexterm; |
   %required-cleanup;
  ">

<!-- Metadata elements intended for specialization -->
<!ENTITY % data.elements.incl 
  "%data; |
   %data-about;
  "
>
<!ENTITY % foreign.unknown.incl 
  "%foreign; | 
   %unknown;
  " 
>

<!-- Predefined content model groups, based on the previous, element-only categories: -->
<!-- txt.incl is appropriate for any mixed content definitions (those that have PCDATA) -->
<!-- the context for blocks is implicitly an InfoMaster "containing_division" -->
<!ENTITY % listitem.cnt 
  "#PCDATA | 
   %basic.block; |
   %basic.ph; | 
   %data.elements.incl; | 
   %foreign.unknown.incl; | 
   %itemgroup; | 
   %txt.incl;
  "
>
<!ENTITY % itemgroup.cnt 
  "#PCDATA | 
   %basic.block; | 
   %basic.ph; | 
   %data.elements.incl; | 
   %foreign.unknown.incl; | 
   %txt.incl;
  "
>
<!ENTITY % title.cnt 
  "#PCDATA | 
   %basic.ph.noxref; | 
   %data.elements.incl; | 
   %foreign.unknown.incl; | 
   %image;
  "
>
<!ENTITY % xreftext.cnt 
  "#PCDATA | 
   %basic.ph.noxref; | 
   %data.elements.incl; | 
   %foreign.unknown.incl; | 
   %image;
  "
>
<!ENTITY % xrefph.cnt 
  "#PCDATA | 
   %basic.ph.noxref; | 
   %data.elements.incl; | 
   %foreign.unknown.incl;
  "
>
<!ENTITY % shortquote.cnt 
  "#PCDATA | 
   %basic.ph; | 
   %data.elements.incl; | 
   %foreign.unknown.incl;
  "
>
<!ENTITY % para.cnt 
  "#PCDATA | 
   %basic.block.nopara; | 
   %basic.ph; | 
   %data.elements.incl; | 
   %foreign.unknown.incl; | 
   %txt.incl;
  "
>
<!ENTITY % note.cnt 
  "#PCDATA | 
   %basic.block.nonote; | 
   %basic.ph; | 
   %data.elements.incl; | 
   %foreign.unknown.incl; | 
   %txt.incl;
  "
>
<!ENTITY % longquote.cnt 
  "#PCDATA | 
   %basic.block.nolq; | 
   %basic.ph; | 
   %data.elements.incl; | 
   %foreign.unknown.incl; |
   %longquoteref; | 
   %txt.incl; 
  ">
<!ENTITY % tblcell.cnt 
  "#PCDATA | 
   %basic.block.notbl; | 
   %basic.ph; | 
   %data.elements.incl; | 
   %foreign.unknown.incl; | 
   %txt.incl;
  "
>
<!ENTITY % desc.cnt 
  "#PCDATA | 
   %basic.block.notbfgobj; | 
   %basic.ph; | 
   %data.elements.incl; | 
   %foreign.unknown.incl;
  "
>
<!ENTITY % ph.cnt 
  "#PCDATA | 
   %basic.ph; | 
   %data.elements.incl; | 
   %foreign.unknown.incl; | 
   %image; | 
   %txt.incl;
  "
>
<!ENTITY % fn.cnt 
  "#PCDATA | 
   %basic.block.notbl; | 
   %basic.ph; | 
   %data.elements.incl; | 
   %foreign.unknown.incl;
  "
>
<!ENTITY % term.cnt 
  "#PCDATA | 
   %basic.ph; | 
   %data.elements.incl; | 
   %foreign.unknown.incl; | 
   %image;
  "
>
<!ENTITY % defn.cnt 
  "#PCDATA | 
   %basic.block; |
   %basic.ph; | 
   %data.elements.incl; | 
   %foreign.unknown.incl; | 
   %itemgroup; | 
   %txt.incl;
  "
>
<!ENTITY % pre.cnt 
  "#PCDATA | 
   %basic.ph; | 
   %data.elements.incl; | 
   %foreign.unknown.incl; | 
   %txt.incl;
  "
>
<!ENTITY % fig.cnt 
  "%basic.block.notbnofg; | 
   %data.elements.incl; | 
   %fn;| 
   %foreign.unknown.incl; | 
   %simpletable; | 
   %xref;
  "
>
<!ENTITY % figgroup.cnt 
  "%basic.block.notbnofg; | 
   %basic.ph; |
   %data.elements.incl; | 
   %fn; |
   %foreign.unknown.incl; 
  "
>
<!ENTITY % words.cnt 
  "#PCDATA | 
   %data.elements.incl; | 
   %foreign.unknown.incl; | 
   %keyword; | 
   %term;
  "
>
<!ENTITY % data.cnt 
  "%words.cnt; |
   %image; |
   %object; |
   %ph; |
   %title;
  "
>

<!-- ============================================================= -->
<!--                    COMMON ATTLIST SETS                        -->
<!-- ============================================================= -->

<!-- Copied into metaDecl.mod -->
<!--<!ENTITY % date-format 'CDATA'                                       >-->

<!ENTITY % display-atts 
             'scale 
                        (50 |
                         60 |
                         70 |
                         80 |
                         90 |
                         100 |
                         110 |
                         120 |
                         140 |
                         160 |
                         180 |
                         200 |
                        -dita-use-conref-target) 
                                  #IMPLIED
              frame 
                        (all |
                         bottom |
                         none | 
                         sides | 
                         top | 
                         topbot | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              expanse 
                        (column | 
                         page |
                         spread | 
                         textline | 
                         -dita-use-conref-target) 
                                  #IMPLIED' 
>

<!-- Provide a default of no attribute extensions -->
<!ENTITY % props-attribute-extensions 
  ""
>
<!ENTITY % base-attribute-extensions 
  ""
>

<!ENTITY % filter-atts
             'props 
                         CDATA 
                                   #IMPLIED
              platform 
                         CDATA 
                                   #IMPLIED
              product 
                         CDATA 
                                   #IMPLIED
              audience 
                         CDATA 
                                   #IMPLIED
              otherprops 
                         CDATA 
                                   #IMPLIED
              %props-attribute-extensions; 
  ' 
>

<!ENTITY % select-atts 
             '%filter-atts;
              base 
                         CDATA 
                                  #IMPLIED
              %base-attribute-extensions;
              importance 
                        (default | 
                         deprecated | 
                         high | 
                         low | 
                         normal | 
                         obsolete | 
                         optional | 
                         recommended | 
                         required | 
                         urgent | 
                         -dita-use-conref-target ) 
                                  #IMPLIED
              rev 
                        CDATA 
                                  #IMPLIED
              status 
                        (changed | 
                         deleted | 
                         new | 
                         unchanged | 
                         -dita-use-conref-target) 
                                  #IMPLIED' 
>

<!ENTITY % conref-atts 
             'conref 
                        CDATA 
                                  #IMPLIED
              conrefend
                        CDATA
                                  #IMPLIED
              conaction
                        (mark |
                         pushafter |
                         pushbefore |
                         pushreplace |
                         -dita-use-conref-target)
                                  #IMPLIED
              conkeyref
                        CDATA
                                  #IMPLIED' 
>

<!ENTITY % id-atts 
             'id 
                        NMTOKEN 
                                  #IMPLIED
              %conref-atts;' 
>

<!-- Attributes related to localization that are used everywhere   -->
<!ENTITY % localization-atts 
             'translate 
                        (no | 
                         yes | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              xml:lang 
                        CDATA 
                                  #IMPLIED
              dir 
                        (lro | 
                         ltr | 
                         rlo | 
                         rtl | 
                         -dita-use-conref-target) 
                                  #IMPLIED' 
>
<!-- The following entity should be used when defaulting a new
     element to translate="no", so that other (or new) localization
     attributes will always be included.   -->
<!ENTITY % localization-atts-translate-no 
             'translate 
                        (no | 
                         yes | 
                         -dita-use-conref-target) 
                                  "no"
              xml:lang 
                        CDATA 
                                  #IMPLIED
              dir 
                        (lro | 
                         ltr | 
                         rlo | 
                         rtl | 
                         -dita-use-conref-target) 
                                  #IMPLIED' 
>
 
<!ENTITY % univ-atts 
             '%id-atts;
              %select-atts;
              %localization-atts;' 
>
<!ENTITY % univ-atts-translate-no 
             '%id-atts;
              %select-atts;
              %localization-atts-translate-no;' 
>

<!ENTITY % global-atts 
             'xtrc 
                        CDATA 
                                  #IMPLIED
              xtrf 
                        CDATA 
                                  #IMPLIED'
>
 
<!-- ============================================================= -->
<!--                    ELEMENT DECLARATIONS                       -->
<!-- ============================================================= -->

<!--                    LONG NAME: Data About                      -->
<!ENTITY % data-about.content
                       "((%data;), 
                         (%data;|
                          %data-about;)*)
">
<!ENTITY % data-about.attributes
             "%univ-atts;
              href 
                        CDATA 
                                  #IMPLIED
              keyref 
                        CDATA 
                                  #IMPLIED
              format 
                        CDATA 
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
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <data-about> element identifies the subject of a property when the subject isn't associated with the context in which the property is specified. The property itself is expressed by the <data> element. The <data-about> element handles exception cases where a property must be expressed somewhere other than inside the actual subject of the property. The <data-about> element is particularly useful as a basis for specialization in combination with the <data> element.
Category: Miscellaneous elements-->
<!ELEMENT data-about    %data-about.content;>
<!ATTLIST data-about    %data-about.attributes;>


<!ENTITY % data-element-atts
             '%univ-atts;
              name 
                        CDATA 
                                  #IMPLIED
              datatype 
                        CDATA 
                                  #IMPLIED
              value 
                        CDATA 
                                  #IMPLIED
              href 
                        CDATA 
                                  #IMPLIED
              keyref 
                        CDATA 
                                  #IMPLIED
              format 
                        CDATA 
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
              outputclass
                        CDATA 
                                  #IMPLIED' 
>
 
<!--                    LONG NAME: Data element                    -->
<!ENTITY % data.content
                       "(%data.cnt;)*
">
<!ENTITY % data.attributes
             "%data-element-atts;"
>
<!--doc:The <data> element represents a property within a DITA topic or map. While the <data> element can be used directly to capture properties, it is particularly useful as a basis for specialization. Default processing treats the property values as an unknown kind of metadata, but custom processing can match the name attribute or specialized element to format properties as sidebars or other adornments or to harvest properties for automated processing.
Category: Miscellaneous elements-->
<!ELEMENT data    %data.content;>
<!ATTLIST data    %data.attributes;>


<!--                    LONG NAME: Unknown element                 -->
<!ENTITY % unknown.content
                       "ANY"
>
<!ENTITY % unknown.attributes
             "%univ-atts;
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <unknown> element is an open extension that allows information architects to incorporate xml fragments that do not necessarily fit into an existing DITA use case. The base processing for <unknown> is to suppress unless otherwise instructed.
Category: Specialization elements-->
<!ELEMENT unknown    %unknown.content;>
<!ATTLIST unknown    %unknown.attributes;>

 
<!--                    LONG NAME: Foreign content element         -->
<!ENTITY % foreign.content
                       "ANY
">
<!ENTITY % foreign.attributes
             "%univ-atts;
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <foreign> element is an open extension that allows information architects to incorporate existing standard vocabularies for non-textual content. like MathML and SVG, as inline objects. If <foreign> contains more than one alternative content element, they will all be processed. Specialization of <foreign> should be implemented as a domain, but for those looking for more control over the content can implement foreign vocabulary as an element specialization.
Category: Specialization elements-->
<!ELEMENT foreign    %foreign.content;>
<!ATTLIST foreign    %foreign.attributes;>


<!--                    LONG NAME: Title                           -->
<!--                    This is referenced inside CALS table       -->
<!ENTITY % title.content
                       "(%title.cnt;)*"
>
<!ENTITY % title.attributes
             "%id-atts;
              %localization-atts;
              base 
                        CDATA 
                                  #IMPLIED
              %base-attribute-extensions;
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <title> element contains a heading or label for the main parts of a topic, including the topic as a whole, its sections and examples, and its labelled content, such as figures and tables. Beginning with DITA 1.1, the element may also be used to provide a title for a map.
Category: Topic elements-->
<!ELEMENT title    %title.content;>
<!ATTLIST title    %title.attributes;>


<!--                    LONG NAME: Navigation Title                -->
<!ENTITY % navtitle.content
                       "(%words.cnt; |
                         %ph;)*"
>
<!ENTITY % navtitle.attributes
             "%univ-atts;"
>
<!--doc:The navigation title (<navtitle>) element is one of a set of alternate titles that can be included inside the <titlealts> element. This navigation title may differ from the first level heading that shows in the main browser window. Use <navtitle> when the actual title of the topic isn't appropriate for use in navigation panes or online contents (for example, because the actual title is too long).
Category: Topic elements-->
<!ELEMENT navtitle    %navtitle.content;>
<!ATTLIST navtitle    %navtitle.attributes;>


<!--                    LONG NAME: Short Description               -->
<!ENTITY % shortdesc.content
                       "(%title.cnt; |
                         %draft-comment;)*"
>
<!ENTITY % shortdesc.attributes
             "%univ-atts;
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The short description (<shortdesc>) element occurs between the topic title and the topic body, as the initial paragraph-like content of a topic, or it can be embedded in an abstract element. The short description, which represents the purpose or theme of the topic, is also intended to be used as a link preview and for searching. When used within a DITA map, the short description of the <topicref> can be used to override the short description in the topic.
Category: Topic elements-->
<!ELEMENT shortdesc    %shortdesc.content;>
<!ATTLIST shortdesc    %shortdesc.attributes;>


<!--                    LONG NAME: Description                     -->
<!--                    Desc is used in context with figure and 
                        table titles and also for content models 
                        within linkgroup and object (for 
                        accessibility)                             -->
<!ENTITY % desc.content
                       "(%desc.cnt;)*"
>
<!ENTITY % desc.attributes
             "%univ-atts;
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <desc> element contains the description of the current element. A description should provide more information than the title. This is its behavior in fig/table/linklist, for example. In xref/link, it provides a description of the target; processors that support it may choose to display this as hover help. In object, it contains alternate content for use when in contexts that cannot display the object.
Category: Body elements-->
<!ELEMENT desc    %desc.content;>
<!ATTLIST desc    %desc.attributes;>



<!-- ============================================================= -->
<!--                    BASIC DOCUMENT ELEMENT DECLARATIONS        -->
<!--                    (rich text)                                -->
<!-- ============================================================= -->

<!--                    LONG NAME: Paragraph                       -->
<!ENTITY % p.content
                       "(%para.cnt;)*"
>
<!ENTITY % p.attributes
             "%univ-atts;
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:A paragraph element (<p>) is a block of text containing a single main idea.
Category: Body elements-->
<!ELEMENT p    %p.content;>
<!ATTLIST p    %p.attributes;>



<!--                    LONG NAME: Note                            -->
<!ENTITY % note.content
                       "(%note.cnt;)*"
>
<!ENTITY % note.attributes
             "type 
                        (attention|
                         caution | 
                         danger | 
                         fastpath | 
                         important | 
                         note |
                         notice |
                         other | 
                         remember | 
                         restriction |
                         tip |
                         warning |
                         -dita-use-conref-target) 
                                  #IMPLIED 
              spectitle 
                        CDATA 
                                  #IMPLIED
              othertype 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:A <note> element contains information, differentiated from the main text, which expands on or calls attention to a particular point.
Category: Body elements-->
<!ELEMENT note    %note.content;>
<!ATTLIST note    %note.attributes;>


<!--                    LONG NAME: Long quote reference            -->
<!ENTITY % longquoteref.content
                       "EMPTY"
>
<!ENTITY % longquoteref.attributes
             "href 
                        CDATA 
                                  #IMPLIED
              keyref 
                        CDATA 
                                  #IMPLIED
              type 
                        CDATA 
                                  #IMPLIED
              format 
                        CDATA 
                                  #IMPLIED
              scope 
                        (external | 
                         local | 
                         peer | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <longquoteref> element provides a reference to the source of a long quote. The long quote (<lq>) element itself allows an href attribute to specify the source of a quote, but it does not allow other standard linking attributes such as keyref, scope, and format. The <longquoteref> element should be used for references that make use of these attributes.-->
<!ELEMENT longquoteref    %longquoteref.content;>
<!ATTLIST longquoteref    %longquoteref.attributes;>

<!--                    LONG NAME: Long Quote (Excerpt)            -->
<!ENTITY % lq.content
                       "(%longquote.cnt;)*"
>
<!ENTITY % lq.attributes
             "href 
                        CDATA 
                                  #IMPLIED
              keyref 
                        CDATA 
                                  #IMPLIED
              format 
                        CDATA 
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
              reftitle 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The long quote (<lq>) element indicates content quoted from another source. Use the quote element <q> for short, inline quotations, and long quote <lq> for quotations that are too long for inline use, following normal guidelines for quoting other sources. You can store a URL to the source of the quotation in the href attribute; the href value may point to a DITA topic.
Category: Body elements-->
<!ELEMENT lq    %lq.content;>
<!ATTLIST lq    %lq.attributes;>



<!--                    LONG NAME: Quoted text                     -->
<!ENTITY % q.content
                       "(%shortquote.cnt;)*"
>
<!ENTITY % q.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:A quotation element (<q>) indicates content quoted from another source. This element is used for short quotes which are displayed inline. Use the long quote element (<lq>) for quotations that should be set off from the surrounding text.
Category: Body elements-->
<!ELEMENT q    %q.content;>
<!ATTLIST q    %q.attributes;>



<!--                    LONG NAME: Simple List                     -->
<!ENTITY % sl.content
                       "(%sli;)+"
>
<!ENTITY % sl.attributes
             "compact 
                        (no | 
                         yes | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              spectitle 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The simple list (<sl>) element contains a simple list of items of short, phrase-like content, such as in documenting the materials in a kit or package.
Category: Body elements-->
<!ELEMENT sl    %sl.content;>
<!ATTLIST sl    %sl.attributes;>



<!--                    LONG NAME: Simple List Item                -->
<!ENTITY % sli.content
                       "(%ph.cnt;)*"
>
<!ENTITY % sli.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:A simple list item (<sli>) is a single item in a simple list <sl>. Simple list items have phrase or text content, adequate for describing package contents, for example. When a DITA topic is formatted for output, the items of a simple list are placed each on its own line, with no other prefix such as a number (as in an ordered list) or bullet (as in an unordered list).
Category: Body elements-->
<!ELEMENT sli    %sli.content;>
<!ATTLIST sli    %sli.attributes;>



<!--                    LONG NAME: Unordered List                  -->
<!ENTITY % ul.content
                       "(%li;)+"
>
<!ENTITY % ul.attributes
             "compact 
                        (no | 
                         yes | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              spectitle 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:In an unordered list (<ul>), the order of the list items is not significant. List items are typically styled on output with a "bullet" character, depending on nesting level.
Category: Body elements-->
<!ELEMENT ul    %ul.content;>
<!ATTLIST ul    %ul.attributes;>



<!--                    LONG NAME: Ordered List                    -->
<!ENTITY % ol.content
                       "(%li;)+"
>
<!ENTITY % ol.attributes
             "compact 
                        (no | 
                         yes | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              spectitle 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:An ordered list (<ol>) is a list of items sorted by sequence or order of importance.
Category: List elements-->
<!ELEMENT ol    %ol.content;>
<!ATTLIST ol    %ol.attributes;>



<!--                    LONG NAME: List Item                       -->
<!ENTITY % li.content
                       "(%listitem.cnt;)*"
>
<!ENTITY % li.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:A list (<li>) item is a single item in an ordered <ol> or unordered <ul> list. When a DITA topic is formatted for output, numbers and alpha characters are usually output with list items in ordered lists, while bullets and dashes are usually output with list items in unordered lists.
Category: Body elements-->
<!ELEMENT li    %li.content;>
<!ATTLIST li    %li.attributes;>



<!--                    LONG NAME: Item Group                      -->
<!ENTITY % itemgroup.content
                       "(%itemgroup.cnt;)*"
>
<!ENTITY % itemgroup.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <itemgroup> element is reserved for use in specializations of DITA. As a container element, it can be used to sub-divide or organize elements that occur inside a list item, definition, or parameter definition.
Category: Specialization elements-->
<!ELEMENT itemgroup    %itemgroup.content;>
<!ATTLIST itemgroup    %itemgroup.attributes;>



<!--                    LONG NAME: Definition List                 -->
<!ENTITY % dl.content
                       "((%dlhead;)?, 
                         (%dlentry;)+)"
>
<!ENTITY % dl.attributes
             "compact 
                        (no | 
                         yes | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              spectitle 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:A definition list (<dl>) is a list of terms and corresponding definitions. The term (<dt>) is usually flush left. The description or definition (<dd>) is usually either indented and on the next line, or on the same line to the right of the term.
Category: Body elements-->
<!ELEMENT dl    %dl.content;>
<!ATTLIST dl    %dl.attributes;>



<!--                    LONG NAME: Definition List Head            -->
<!ENTITY % dlhead.content
                       "((%dthd;)?, 
                         (%ddhd;)? )"
>
<!ENTITY % dlhead.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <dlhead> element contains optional headings for the term and description columns in a definition list. The definition list heading contains a heading <dthd> for the column of terms and an optional heading <ddhd>for the column of descriptions.
Category: Body elements-->
<!ELEMENT dlhead    %dlhead.content;>
<!ATTLIST dlhead    %dlhead.attributes;>



<!--                    LONG NAME: Term Header                     -->
<!ENTITY % dthd.content
                       "(%title.cnt;)*"
>
<!ENTITY % dthd.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The definition term heading (<dthd>) element is contained in a definition list head (<dlhead>) and provides an optional heading for the column of terms in a description list.
Category: Body elements-->
<!ELEMENT dthd    %dthd.content;>
<!ATTLIST dthd    %dthd.attributes;>



<!--                    LONG NAME: Definition Header               -->
<!ENTITY % ddhd.content
                       "(%title.cnt;)*"
>
<!ENTITY % ddhd.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The definition descriptions heading (<ddhd>) element contains an optional heading or title for a column of descriptions or definitions in a definition list
Category: Body elements-->
<!ELEMENT ddhd    %ddhd.content;>
<!ATTLIST ddhd    %ddhd.attributes;>



<!--                    LONG NAME: Definition List Entry           -->
<!ENTITY % dlentry.content
                       "((%dt;)+, 
                         (%dd;)+ )"
>
<!ENTITY % dlentry.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:In a definition list, each list item is defined by the definition list entry (<dlentry>) element. The definition list entry element includes a term <dt> and one or more definitions or descriptions <dd> of that term.
Category: Body elements-->
<!ELEMENT dlentry    %dlentry.content;>
<!ATTLIST dlentry    %dlentry.attributes;>




<!--                    LONG NAME: Definition Term                 --> 
<!ENTITY % dt.content
                       "(%term.cnt;)*"
>
<!ENTITY % dt.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The definition term <dt> element contains a term in a definition list entry.
Category: Body elements-->
<!ELEMENT dt    %dt.content;>
<!ATTLIST dt    %dt.attributes;>



<!--                    LONG NAME: Definition Description          -->
<!ENTITY % dd.content
                       "(%defn.cnt;)*"
>
<!ENTITY % dd.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The definition description (<dd>) element contains the description of a term in a definition list entry.
Category: Body elements-->
<!ELEMENT dd    %dd.content;>
<!ATTLIST dd    %dd.attributes;>


<!--                    LONG NAME: Figure                          -->
<!ENTITY % fig.content
                       "((%title;)?, 
                         (%desc;)?, 
                         (%figgroup; | 
                          %fig.cnt;)* )"
>
<!ENTITY % fig.attributes
             "%display-atts;
              spectitle 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The figure (<fig>) element is a display context (sometimes called an exhibit) with an optional title for a wide variety of content. Most commonly, the figure element contains an image element (a graphic or artwork), but it can contain several kinds of text objects as well. A title is placed inside the figure element to provide a caption to describe the content.
Category: Body elements-->
<!ELEMENT fig    %fig.content;>
<!ATTLIST fig    %fig.attributes;>



<!--                    LONG NAME: Figure Group                    -->
<!ENTITY % figgroup.content
                       "((%title;)?, 
                         (%figgroup; | 
                          (%figgroup.cnt;))* )"
>
<!ENTITY % figgroup.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <figgroup> element is used only for specialization at this time. Figure groups can be used to contain multiple cross-references, footnotes or keywords, but not multipart images. Multipart images in DITA should be represented by a suitable media type displayed by the <object> element.
Category: Body elements-->
<!ELEMENT figgroup    %figgroup.content;>
<!ATTLIST figgroup    %figgroup.attributes;>


<!--                    LONG NAME: Preformatted Text               -->
<!ENTITY % pre.content
                       "(%pre.cnt;)*"
>
<!ENTITY % pre.attributes
             "%display-atts;
              spectitle 
                        CDATA 
                                  #IMPLIED
              xml:space 
                        (preserve) 
                                  #FIXED 'preserve'
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The preformatted element (<pre>) preserves line breaks and spaces entered manually by the author in the content of the element, and also presents the content in a monospaced type font (depending on your output formatting processor). Do not use <pre> when a more semantically specific element is appropriate, such as <codeblock>.
Category: Body elements-->
<!ELEMENT pre    %pre.content;>
<!ATTLIST pre    %pre.attributes;>


<!--                    LONG NAME: Line Respecting Text            -->
<!ENTITY % lines.content
                       "(%pre.cnt;)*"
>
<!ENTITY % lines.attributes
             "%display-atts;
              spectitle 
                        CDATA 
                                  #IMPLIED
              xml:space 
                        (preserve) 
                                  #FIXED 'preserve'
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <lines> element may be used to represent dialogs, lists, text fragments, and so forth. The <lines> element is similar to <pre> in that hard line breaks are preserved, but the font style is not set to monospace, and extra spaces inside the lines are not preserved.
Category: Body elements-->
<!ELEMENT lines    %lines.content;>
<!ATTLIST lines    %lines.attributes;>


<!-- ============================================================= -->
<!--                   BASE FORM PHRASE TYPES                      -->
<!-- ============================================================= -->

<!--                    LONG NAME: Text                            -->
<!ENTITY % text.content
                       "(#PCDATA | 
                         %text;)*"
>
<!ENTITY % text.attributes
             "%univ-atts;
">
<!--doc:The text element associates no semantics with its content. It exists to serve as a container for text where a container is needed (e.g., for conref, or for restricted content models in specializations). Unlike ph, text cannot contain images. Unlike keyword, text does not imply keyword-like semantics. The text element contains only text data, or nested text elements. All universal attributes are available on text.-->
<!ELEMENT text    %text.content;>
<!ATTLIST text    %text.attributes;>


<!--                    LONG NAME: Keyword                         -->
<!ENTITY % keyword.content
                       "(#PCDATA |
                         %text; |
                         %tm;)*"
>
<!ENTITY % keyword.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <keyword> element identifies a keyword or token, such as a single value from an enumerated list, the name of a command or parameter, product name, or a lookup key for a message.
Category: Body elements-->
<!ELEMENT keyword    %keyword.content;>
<!ATTLIST keyword    %keyword.attributes;>



<!--                    LONG NAME: Term                            -->
<!ENTITY % term.content
                       "(#PCDATA |
                         %text; |
                         %tm;)*"
>
<!ENTITY % term.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <term> element identifies words that may have or require extended definitions or explanations. In future development of DITA, for example, terms might provide associative linking to matching glossary entries.
Category: Specialization elements-->
<!ELEMENT term    %term.content;>
<!ATTLIST term    %term.attributes;>



<!--                    LONG NAME: Phrase                          -->
<!ENTITY % ph.content
                       "(%ph.cnt; |
                         %text;)*"
>
<!ENTITY % ph.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The phrase (<ph>) element is used to organize content for reuse or conditional processing (for example, when part of a paragraph applies to a particular audience). It can be used by specializations of DITA to create semantic markup for content at the phrase level, which then allows (but does not require) specific processing or formatting.
Category: Body elements-->
<!ELEMENT ph    %ph.content;>
<!ATTLIST ph    %ph.attributes;>



<!--                    LONG NAME: Trade Mark                      -->
<!ENTITY % tm.content
                       "(#PCDATA |
                         %text; |
                         %tm;)*"
>
<!ENTITY % tm.attributes
             "trademark 
                        CDATA 
                                  #IMPLIED
              tmowner 
                        CDATA 
                                  #IMPLIED
              tmtype 
                        (reg | 
                         service | 
                         tm | 
                         -dita-use-conref-target) 
                                  #REQUIRED
              tmclass 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
">
<!--doc:The trademark (<tm>) element in DITA is used to markup and identify a term or phrase that is trademarked. Trademarks include registered trademarks, service marks, slogans and logos.
Category: Miscellaneous elements-->
<!ELEMENT tm    %tm.content;>
<!ATTLIST tm    %tm.attributes;>



<!--                    LONG NAME: Boolean  (deprecated)           -->
<!ENTITY % boolean.content
                       "EMPTY"
>
<!ENTITY % boolean.attributes
             "state 
                        (no | 
                         yes | 
                         -dita-use-conref-target) 
                                  #REQUIRED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <boolean> element is used to express one of two opposite values, such as yes or no, on or off, true or false, high or low, and so forth. The element itself is empty; the value of the element is stored in its state attribute, and the semantic associated with the value is typically in a specialized name derived from this element.
Category: Specialization elements-->
<!ELEMENT boolean    %boolean.content;>
<!ATTLIST boolean    %boolean.attributes;>



<!--                    LONG NAME: State                           -->
<!--                    A state can have a name and a string value, 
                        even if empty or indeterminate             -->
<!ENTITY % state.content
                       "EMPTY"
>
<!ENTITY % state.attributes
             "name 
                        CDATA 
                                  #REQUIRED
              value 
                        CDATA 
                                  #REQUIRED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <state> element specifies a name/value pair whenever it is necessary to represent a named state that has a variable value. The element is primarily intended for use in specializations to represent specific states (like logic circuit states, chemical reaction states, airplane instrumentation states, and so forth).
Category: Specialization elements-->
<!ELEMENT state    %state.content;>
<!ATTLIST state    %state.attributes;>


<!--                    LONG NAME: Image Data                      -->
<!ENTITY % image.content
                       "((%alt;)?,
                         (%longdescref;)?)
">
<!ENTITY % image.attributes
             "href 
                        CDATA 
                                  #IMPLIED

              scope 
                        (external | 
                         local | 
                         peer | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              keyref 
                        CDATA 
                                  #IMPLIED
              alt 
                        CDATA 
                                  #IMPLIED
              longdescref 
                        CDATA 
                                  #IMPLIED
              height 
                        NMTOKEN 
                                  #IMPLIED
              width 
                        NMTOKEN 
                                  #IMPLIED
              align 
                        CDATA 
                                  #IMPLIED
              scale 
                        NMTOKEN 
                                  #IMPLIED
              scalefit
                        (yes |
                         no |
                         -dita-use-conref-target)
                                  #IMPLIED
              placement 
                        (break | 
                         inline | 
                         -dita-use-conref-target) 
                                  'inline'
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:Include artwork or images in a DITA topic by using the <image> element. The <image> element has optional attributes that indicate whether the placement of the included graphic or artwork should be inline (like a button or icon) or on a separate line for a larger image. There are also optional attributes that indicate the size to which the included graphic or artwork should be scaled. An href attribute is required on the image element, as this attribute creates a pointer to the image, and allows the output formatting processor to bring the image into the text flow. To make the intent of the image more accessible for users using screen readers or text-only readers, always include a description of the image's content in the alt element.
Category: Body elements-->
<!ELEMENT image    %image.content;>
<!ATTLIST image    %image.attributes;>



<!--                    LONG NAME: Alternate text                  -->
<!ENTITY % alt.content
                       "(%words.cnt; |
                         %ph;)*
">
<!ENTITY % alt.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The alt element provides alternate text for an image. It is equivalent to the alt attribute on the image element; the attribute is deprecated, so the alt element should be used instead. As an element, alt provides direct text entry within an XML editor and is more easily accessed than an attribute for translation.
Category: Body elements-->
<!ELEMENT alt    %alt.content;>
<!ATTLIST alt    %alt.attributes;>


<!--                    LONG NAME: Long description reference      -->
<!ENTITY % longdescref.content
                       "EMPTY"
>
<!ENTITY % longdescref.attributes
             "href 
                        CDATA 
                                  #IMPLIED
              keyref 
                        CDATA 
                                  #IMPLIED
              type 
                        CDATA 
                                  #IMPLIED
              format 
                        CDATA 
                                  #IMPLIED
              scope 
                        (external | 
                         local | 
                         peer | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:A reference to a textual description of the graphic or object. This element is a replacement for the longdescref attribute on image and object elements.-->
<!ELEMENT longdescref    %longdescref.content;>
<!ATTLIST longdescref    %longdescref.attributes;>


<!--                    LONG NAME: Object (Streaming/Executable 
                                   Data)                           -->
<!-- The longdescre attribute is an error which appeared in the
     original DTD implementation of OASIS DITA. It is an error that
     is not part of the standard. It was left here to provide time
     to change documents, but it will be removed at a later date.
     The longdescref (with ending F) should be used instead.       -->
<!ENTITY % object.content
                       "((%desc;)?,
                         (%longdescref;)?,
                         (%param;)*, 
                         (%foreign.unknown.incl;)*)"
>
<!ENTITY % object.attributes
             "declare 
                        (declare) 
                                  #IMPLIED
              classid 
                        CDATA 
                                  #IMPLIED
              codebase 
                        CDATA 
                                  #IMPLIED
              data 
                        CDATA 
                                  #IMPLIED
              type 
                        CDATA 
                                  #IMPLIED
              codetype 
                        CDATA 
                                  #IMPLIED
              archive 
                        CDATA 
                                  #IMPLIED
              standby 
                        CDATA 
                                  #IMPLIED
              height 
                        NMTOKEN 
                                  #IMPLIED
              width 
                        NMTOKEN 
                                  #IMPLIED
              usemap 
                        CDATA 
                                  #IMPLIED
              name 
                        CDATA 
                                  #IMPLIED
              tabindex 
                        NMTOKEN 
                                  #IMPLIED
              longdescref
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED 
              longdescre CDATA    #IMPLIED"
>
<!--doc:DITA's <object> element corresponds to the HTML <object> element.
Category: Body elements-->
<!ELEMENT object    %object.content;>
<!ATTLIST object    %object.attributes;>



<!--                    LONG NAME: Parameter                       -->
<!ENTITY % param.content
                       "EMPTY
">
<!ENTITY % param.attributes
             "%univ-atts;
              name 
                        CDATA 
                                  #REQUIRED
              value 
                        CDATA 
                                  #IMPLIED
              valuetype 
                        (data | 
                         object | 
                         ref | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              type 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The parameter (<param>) element specifies a set of values that may be required by an <object> at runtime. Any number of <param> elements may appear in the content of an object in any order, but must be placed at the start of the content of the enclosing object. This element is comparable to the XHMTL <param> element.
Category: Body elements-->
<!ELEMENT param    %param.content;>
<!ATTLIST param    %param.attributes;>
 


<!--                    LONG NAME: Simple Table                    -->
<!ENTITY % simpletable.content
                       "((%sthead;)?, 
                         (%strow;)+)"
>
<!ENTITY % simpletable.attributes
             "relcolwidth 
                        CDATA 
                                  #IMPLIED
              keycol 
                        NMTOKEN 
                                  #IMPLIED
              refcols 
                        NMTOKENS 
                                  #IMPLIED
              %display-atts;
              spectitle 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <simpletable> element is used for tables that are regular in structure and do not need a caption. Choose the simple table element when you want to show information in regular rows and columns. For example, multi-column tabular data such as phone directory listings or parts lists are good candidates for simpletable. Another good use of simpletable is for information that seems to beg for a "three-part definition list"—just use the keycol attribute to indicate which column represents the "key" or term-like column of your structure.
Category: Table elements-->
<!ELEMENT simpletable    %simpletable.content;>
<!ATTLIST simpletable    %simpletable.attributes;>



<!--                    LONG NAME: Simple Table Head               -->
<!ENTITY % sthead.content
                       "(%stentry;)+"
>
<!ENTITY % sthead.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The simpletable header (<sthead>) element contains the table's header row. The header row is optional in a simple table.
Category: Table elements-->
<!ELEMENT sthead    %sthead.content;>
<!ATTLIST sthead    %sthead.attributes;>



<!--                    LONG NAME: Simple Table Row                -->
<!ENTITY % strow.content
                       "(%stentry;)*"
>
<!ENTITY % strow.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <simpletable> row (<strow>) element specifies a row in a simple table.
Category: Table elements-->
<!ELEMENT strow    %strow.content;>
<!ATTLIST strow    %strow.attributes;>



<!--                    LONG NAME: Simple Table Cell (entry)       -->
<!ENTITY % stentry.content
                       "(%tblcell.cnt;)*"
>
<!ENTITY % stentry.attributes
             "specentry 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The simpletable entry (<stentry>) element represents a single table cell, like <entry> in <table>. You can place any number of stentry cells in either an <sthead> element (for headings) or <strow> element (for rows of data).
Category: Table elements-->
<!ELEMENT stentry    %stentry.content;>
<!ATTLIST stentry    %stentry.attributes;>


<!--                    LONG NAME: Review Comments Block           -->
<!ENTITY % draft-comment.content
                       "(#PCDATA | 
                         %basic.phandblock; | 
                         %data.elements.incl; | 
                         %foreign.unknown.incl;)*"
>
<!-- 20080128: Removed enumeration for @disposition for DITA 1.2. Previous values:
               accepted, completed, deferred, duplicate, issue, open, 
               rejected, reopened, unassigned, -dita-use-conref-target           -->
<!ENTITY % draft-comment.attributes
             "author 
                        CDATA 
                                  #IMPLIED
              time 
                        CDATA 
                                  #IMPLIED
              disposition 
                        CDATA 
                                  #IMPLIED
              %univ-atts-translate-no;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <draft-comment> element allows simple review and discussion of topic contents within the marked-up content. Use the <draft-comment> element to ask a question or make a comment that you would like others to review. To indicate the source of the draft comment or the status of the comment, use the author, time or disposition attributes.
Category: Miscellaneous elements-->
<!ELEMENT draft-comment    %draft-comment.content;>
<!ATTLIST draft-comment    %draft-comment.attributes;>

<!--                    LONG NAME: Required Cleanup Block          -->
<!ENTITY % required-cleanup.content
                       "ANY"
>
<!ENTITY % required-cleanup.attributes
             "remap 
                        CDATA 
                                  #IMPLIED
              %univ-atts-translate-no;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:A <required-cleanup> element is used as a placeholder for migrated elements that cannot be appropriately tagged without manual intervention. As the element name implies, the intent for authors is to clean up the contained material and eventually get rid of the <required-cleanup> element. Authors should not insert this element into documents.
Category: Specialization elements-->
<!ELEMENT required-cleanup    %required-cleanup.content;>
<!ATTLIST required-cleanup    %required-cleanup.attributes;>



<!--                    LONG NAME: Footnote                        -->
<!ENTITY % fn.content
                       "(%fn.cnt;)*"
>
<!ENTITY % fn.attributes
             "callout 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:Use footnote (<fn>) to annotate text with notes that are not appropriate for inclusion in line or to indicate the source for facts or other material used in the text.
Category: Miscellaneous elements-->
<!ELEMENT fn    %fn.content;>
<!ATTLIST fn    %fn.attributes;>


<!--                    LONG NAME: Index Term                      -->
<!ENTITY % indexterm.content
                       "(%words.cnt;|
                         %indexterm;|
                         %index-base;)*"
>
<!ENTITY % indexterm.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              start 
                        CDATA 
                                  #IMPLIED
              end 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
">
<!--doc:An <indexterm> element allows the author to indicate that a certain word or phrase should produce an index entry in the generated index.
Category: Miscellaneous elements-->
<!ELEMENT indexterm    %indexterm.content;>
<!ATTLIST indexterm    %indexterm.attributes;>


<!--                    LONG NAME: Index Base                      -->
<!ENTITY % index-base.content
                       "(%words.cnt; |
                         %indexterm;)*"
>
<!ENTITY % index-base.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts;"
>
<!--doc:The <index-base> element allows indexing extensions to be added by specializing off this element. It does not in itself have any meaning and should be ignored in processing.
Category: Miscellaneous elements-->
<!ELEMENT index-base    %index-base.content;>
<!ATTLIST index-base    %index-base.attributes;>


<!--                    LONG NAME: Index term reference            -->
<!ENTITY % indextermref.content
                       "EMPTY
">
<!ENTITY % indextermref.attributes
             "keyref 
                        CDATA 
                                  #REQUIRED
              %univ-atts;
">
<!--doc:This element is not completely defined, and is reserved for future use.
Category: Miscellaneous elements-->
<!ELEMENT indextermref    %indextermref.content;>
<!ATTLIST indextermref    %indextermref.attributes;>


<!--                    LONG NAME: Citation (bibliographic source) -->
<!ENTITY % cite.content
                       "(%xrefph.cnt;)*"
>
<!ENTITY % cite.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <cite> element is used when you need a bibliographic citation that refers to a book or article. It specifically identifies the title of the resource.
Category: Body elements-->
<!ELEMENT cite    %cite.content;>
<!ATTLIST cite    %cite.attributes;>


<!--                    LONG NAME: Cross Reference/Link            -->
<!ENTITY % xref.content
                       "(%xreftext.cnt; | 
                         %desc;)*"
>
<!ENTITY % xref.attributes
             "href 
                        CDATA 
                                  #IMPLIED
              keyref 
                        CDATA 
                                  #IMPLIED
              type 
                        CDATA 
                                  #IMPLIED
              format 
                        CDATA 
                                  #IMPLIED
              scope 
                        (external | 
                         local | 
                         peer | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:Use the cross-reference (<xref>) element to link to a different location within the current topic, or a different topic within the same help system, or to external sources, such as Web pages, or to a location in another topic. The href attribute on the <xref> element provides the location of the target.
Category: Body elements-->
<!ELEMENT xref    %xref.content;>
<!ATTLIST xref    %xref.attributes;>



<!ENTITY % tableXML 
  PUBLIC  "-//OASIS//ELEMENTS DITA Exchange Table Model//EN" 
          "tblDecl.mod" 
>%tableXML;

<!-- ============================================================= -->
<!--                    SPECIALIZATION ATTRIBUTE DECLARATIONS      -->
<!-- ============================================================= -->
 
<!ATTLIST alt       %global-atts;  class CDATA "- topic/alt "        >
<!ATTLIST boolean   %global-atts;  class CDATA "- topic/boolean "    >
<!ATTLIST cite      %global-atts;  class CDATA "- topic/cite "       >
<!ATTLIST dd        %global-atts;  class CDATA "- topic/dd "         >
<!ATTLIST data      %global-atts;  class CDATA "- topic/data "       >
<!ATTLIST data-about
                    %global-atts;  class CDATA "- topic/data-about ">
<!ATTLIST ddhd      %global-atts;  class CDATA "- topic/ddhd "       >
<!ATTLIST desc      %global-atts;  class CDATA "- topic/desc "       >
<!ATTLIST dl        %global-atts;  class CDATA "- topic/dl "         >
<!ATTLIST dlentry   %global-atts;  class CDATA "- topic/dlentry "    >
<!ATTLIST dlhead    %global-atts;  class CDATA "- topic/dlhead "     >
<!ATTLIST draft-comment 
                    %global-atts;  class CDATA "- topic/draft-comment ">
<!ATTLIST dt        %global-atts;  class CDATA "- topic/dt "         >
<!ATTLIST dthd      %global-atts;  class CDATA "- topic/dthd "       >
<!ATTLIST fig       %global-atts;  class CDATA "- topic/fig "        >
<!ATTLIST figgroup  %global-atts;  class CDATA "- topic/figgroup "   >
<!ATTLIST fn        %global-atts;  class CDATA "- topic/fn "         >
<!ATTLIST foreign   %global-atts;  class CDATA "- topic/foreign "    >
<!ATTLIST image     %global-atts;  class CDATA "- topic/image "      >
<!ATTLIST indexterm %global-atts;  class CDATA "- topic/indexterm "  >
<!ATTLIST index-base %global-atts;  class CDATA "- topic/index-base ">
<!ATTLIST indextermref 
                    %global-atts;  class CDATA "- topic/indextermref ">
<!ATTLIST itemgroup %global-atts;  class CDATA "- topic/itemgroup "  >
<!ATTLIST keyword   %global-atts;  class CDATA "- topic/keyword "    >
<!ATTLIST li        %global-atts;  class CDATA "- topic/li "         >
<!ATTLIST lines     %global-atts;  class CDATA "- topic/lines "      >
<!ATTLIST longdescref
                    %global-atts;  class CDATA "- topic/longdescref ">
<!ATTLIST longquoteref
                    %global-atts;  class CDATA "- topic/longquoteref ">
<!ATTLIST lq        %global-atts;  class CDATA "- topic/lq "         >
<!ATTLIST navtitle  %global-atts;  class CDATA "- topic/navtitle "   >
<!ATTLIST note      %global-atts;  class CDATA "- topic/note "       >
<!ATTLIST object    %global-atts;  class CDATA "- topic/object "     >
<!ATTLIST ol        %global-atts;  class CDATA "- topic/ol "         >
<!ATTLIST p         %global-atts;  class CDATA "- topic/p "          >
<!ATTLIST param     %global-atts;  class CDATA "- topic/param "      >
<!ATTLIST ph        %global-atts;  class CDATA "- topic/ph "         >
<!ATTLIST pre       %global-atts;  class CDATA "- topic/pre "        >
<!ATTLIST q         %global-atts;  class CDATA "- topic/q "          >
<!ATTLIST required-cleanup 
                    %global-atts;  class CDATA "- topic/required-cleanup ">
<!ATTLIST simpletable 
                    %global-atts;  class CDATA "- topic/simpletable ">
<!ATTLIST sl        %global-atts;  class CDATA "- topic/sl "         >
<!ATTLIST sli       %global-atts;  class CDATA "- topic/sli "        >
<!ATTLIST state     %global-atts;  class CDATA "- topic/state "      >
<!ATTLIST stentry   %global-atts;  class CDATA "- topic/stentry "    >
<!ATTLIST sthead    %global-atts;  class CDATA "- topic/sthead "     >
<!ATTLIST strow     %global-atts;  class CDATA "- topic/strow "      >
<!ATTLIST term      %global-atts;  class CDATA "- topic/term "       >
<!ATTLIST text      %global-atts;  class CDATA "- topic/text "       >
<!ATTLIST title     %global-atts;  class CDATA "- topic/title "      >
<!ATTLIST tm        %global-atts;  class CDATA "- topic/tm "         >
<!ATTLIST ul        %global-atts;  class CDATA "- topic/ul "         >
<!ATTLIST unknown   %global-atts;  class CDATA "- topic/unknown "    >
<!ATTLIST xref      %global-atts;  class CDATA "- topic/xref "       >


<!-- ================== End Common Elements Module  ============== -->