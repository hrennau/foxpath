(: You can activate the content completion by pressing the Ctrl+Space keys. :)
xquery version "1.0";

(: Namespace for the <oXygen/> custom functions and variables :)
declare namespace oxy="http://www.oxygenxml.com/xquery/functions";

(: The URI of the document that is to be queried :)
declare variable $oxy:document-to-query as xs:string := "books.xml";

(: Queries an XML document for authors :)
declare function oxy:list-authors($document as xs:string) {
        
        let $library := doc($document)
        let $seq := $library//author
        let $distinct := distinct-values($seq)
        
        for $a in $distinct
           return
              <author>
                 <name> {$a} </name>
                 {
                     for $book in $library/library/publisher/book
                     where (compare($book/author, $a) eq 0)
                     return $book/title
                 }
              </author> 
};
    
<author_list>
    {oxy:list-authors($oxy:document-to-query)}
</author_list>
