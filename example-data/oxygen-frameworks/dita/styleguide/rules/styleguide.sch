<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <ns uri="http://oxygenxml.com/dita/blockElements" prefix="e"/>
  <pattern id="check.note">
    <rule context="note" role="warning">
      <let name="paragraphs" value="count(*[substring-before(substring-after(@class, ' '), ' ')='topic/p'])"/>
      <let name="blockElements" value="count(*[substring-before(substring-after(@class, ' '), ' ')=document('blockElements.xml')//e:class])"/>
      <report test="$paragraphs=1 and $blockElements=1"
        > Please remove the "<value-of select="name(*[1])"/>" element and place its text directly in
        the note. If there is just one block of text in the note, then the note should be left as
        string-only. This stores the minimum of mark-up, and simplifies the processed output. If
        there are multiple blocks in the note, then paragraphs, lists (or other block elements)
        should be used. </report>
      <report test="$blockElements > 0 and count(text()[normalize-space(.)!=''])>0" role="error"
        > You should wrap the text that you entered directly inside the note element in a "p"
        element or other block element, or move it inside one of the existing block elements.
        Alternatively remove all the block elements and leave the note to contain only text.
        String-only text should not be used in the same note alongside block elements. </report>
      <report test="matches(., 'Note:')"
        > Please remove the "Note:" text that starts your note! The mark-up of that element in DITA
        must always follow the pattern: &lt;note>Before having...&lt;/note> and never:
        &lt;note>Note: Before having...&lt;/note>. Embedding the label for an element in its text
        will limit the ways in which the element can be presented. </report>
    </rule>
  </pattern>

</schema>
