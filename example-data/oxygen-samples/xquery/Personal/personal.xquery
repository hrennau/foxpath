(: You can activate the content completion by pressing the Ctrl+Space keys. :)
xquery version "1.0";

(: Namespace for the <oXygen/> custom functions and variables :)
declare namespace oxy="http://www.oxygenxml.com/xquery/functions";

(: The URI of the document that is to be queried :)
declare variable $oxy:document-uri as xs:string := "personal.xml";

(: The XML document :)
declare variable $oxy:document as document-node() := doc($oxy:document-uri);

(: The manager ID :)
declare variable $oxy:manager as xs:string := "Big.Boss";

(: Lists the manager's subordinates:)
declare function oxy:list-subordinates($document as document-node(), $manager as xs:string) {
        for $person in $document/personnel/person
        let $link := $person/link
        where (exists($link/@manager) and (compare($link/@manager, $manager) eq 0)) 
        return
            <person id="{$person/@id}">
                <name>{$person/name/given/text(), " ", $person/name/family/text()}</name>
            </person>
};

<BigBoss_subordinates>
    {oxy:list-subordinates($oxy:document, $oxy:manager)}
</BigBoss_subordinates>
