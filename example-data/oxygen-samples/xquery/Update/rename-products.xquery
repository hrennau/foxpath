 (:The Saxon EE processor must be set in the XQuery transformation scenario for this example. :)


(: How to rename one node in an XML document. :)
(:
rename node doc("products.xml")/products/product[1] as "PRODUCT"
,
:)


(: How to rename many nodes in an XML document. :)
for $x in doc("products.xml")//(*|@*)
return
rename node $x
as upper-case(name($x))
