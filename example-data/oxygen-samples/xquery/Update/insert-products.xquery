(:The Saxon EE processor must be set in the XQuery transformation scenario for this example. :)


(: How to insert a node in an XML document. :)
insert node

<product id="p7">
  <name>papa</name>
  <price>2100</price>
  <stock>4</stock>
  <country>China</country>
</product>

as last into doc("products.xml")/products