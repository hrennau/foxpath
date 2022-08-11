(: You can activate the content completion by pressing the Ctrl+Space keys. :)
xquery version "1.0";

(: Namespace for the <oXygen/> custom functions and variables :)
declare namespace oxy="http://www.oxygenxml.com/xquery/functions";

(: The XML document :)
declare variable $oxy:books as document-node() := doc("books.xml");

(: The average price of the books :)
declare variable $oxy:average-price as xs:double := avg($oxy:books//book/price);

(: Lists the expensive books :)
declare function oxy:list-expensive-books($document as document-node(), $average-price as xs:double) {
  
        for $b in $document//book
           where $b/price > $average-price
           return
              <expensive_book>
                 {$b/title}
                 <current_price>
                     {$b/price/text()}
                 </current_price>
                 <price_difference>
                     {$b/price - $average-price}
                 </price_difference>
              </expensive_book>
};

<result>
  <average_price>{$oxy:average-price}</average_price> 
  {oxy:list-expensive-books($oxy:books, $oxy:average-price)}
</result>
