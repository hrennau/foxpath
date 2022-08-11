(: You can activate the content completion by pressing the Ctrl+Space keys. :)
xquery version "1.0";

(: Namespace for the <oXygen/> custom functions and variables :)
declare namespace oxy="http://www.oxygenxml.com/xquery/functions";

(: The products XML document :)
declare variable $oxy:products as document-node() := doc("products.xml");

(: The sales XML document :)
declare variable $oxy:sales as document-node() := doc("sales.xml");

(: Generates a sales report :)
declare function oxy:generate-sales-report($products-doc as document-node(), $sales-doc as document-node()) {
       for $product in $products-doc/products/product,
           $sale in $sales-doc/sales/sale        
       where $product/productId = $sale/@productId
       return 
            <product id="{$product/productId}">
                {$product/productName, $product/productSpec, $sale/mrq, $sale/ytd, $sale/margin}
            </product>              
};
<sales>
  {oxy:generate-sales-report($oxy:products, $oxy:sales)}
</sales>
