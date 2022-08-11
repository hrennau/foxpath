(: You can activate the content completion by pressing the Ctrl+Space keys. :)
xquery version "1.0";

(: Namespace for the <oXygen/> custom functions and variables :)
declare namespace oxy="http://www.oxygenxml.com/xquery/functions";

(: The URI of the document that is to be queried :)
declare variable $oxy:document-to-query as xs:string := "books.xml";

(: The XML document :)
declare variable $oxy:books as document-node() := doc($oxy:document-to-query);

(: Lists the SF books :)
declare function oxy:list-sf-books($document as document-node()) {
        for $book in $document//book
        where (contains($book/author/text(),"Herbert") or contains($book/author/text(),"Asimov"))
            return $book
};

<SFBooks>
    {oxy:list-sf-books($oxy:books)}
</SFBooks>