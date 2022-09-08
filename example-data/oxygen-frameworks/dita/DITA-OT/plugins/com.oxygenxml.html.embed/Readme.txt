Plugin which allows embedding well-formed HTML content in a DITA topic inside a special <foreign outputclass="html-embed"> element.
The plugin works with both DITA-OT 1.8 and 2.x.

Example:

The DITA structure:
   <foreign outputclass="html-embed"><![CDATA[<div><b>bold</b><i>italic</i></div>]]></foreign>

is converted in the HTML output to:

      ...........
      <div><b>bold</b><i>italic</i></div>
      ............