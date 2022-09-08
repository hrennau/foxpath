(: 
    XQuery document used to implement 'Change topic ID to file name' operation from XML Refactoring tool. 
:)
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method   "xml";
declare option output:indent   "no";
declare variable $filename := replace(tokenize(document-uri(/), '/')[last()], '\.(dita|ditamap|xml)$', '')[1];
(: Set ID attribute on root :)
(
let $root := /*[not(@id=$filename)]
for $elem in $root
    let $attrNode := $elem/@id
     return if (exists($attrNode))
                then replace value of node $attrNode with $filename
                else ()
                ),
(
(: Set ID attribute on references to topic elements. :)
let $elements := //*[@href or @conref][not(@format) or @format='dita']
for $elem in $elements
  let $possibleAttrs := $elem/@href | $elem/@conref
   for $attr in $possibleAttrs
     (:<xref href="../topics/flowers/iris.dita#irisgigi/p_vbr_bkc_5w"/>:)
    return if (exists($attr) and contains($attr, '#'))     
                then (
                    let $before := substring-before($attr, '#')
                    let $filename := substring-before(tokenize(if($before='') then (document-uri()) else ($before), '/')[last()], '.')
                    let $after := substring-after($attr, '#')
                    let $topicID := tokenize($after, '/')[1]
                    let $replaced := replace($after, $topicID, $filename)
                    return
                         if($topicID != $filename and $filename != '') then
                           replace value of node $attr with concat($before, '#', $replaced)
                         else ()  
                    )
                else ()
                )
    
