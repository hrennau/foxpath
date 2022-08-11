(:The Saxon EE processor must be set in the XQuery transformation scenario for this example. :)


(: How to replace the value of a node in an XML document. :)
replace value of node doc("products.xml")/products/product[2]/name with "Romeo"
,


(: How to replace a node in an XML document. :)
replace node doc("products.xml")/products/product[3]/name with <NAME>test</NAME>