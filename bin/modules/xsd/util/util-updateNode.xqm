(:~
util-updNode.xqm - utility functions for updating nodes

Version 20131102 # initial version
:)

(: ============================================================================== :)

module namespace uupd="http://www.parsqube.de/xquery/util/update-node";
import module namespace uns="http://www.parsqube.de/xquery/util/namespace"
    at "util-namespace.xqm";

(: 
=================================================================

   p u b l i c    f u n c t i o s
   
=================================================================
:)

(:~
 : Adds attributes to an element.
 :
 : @param elem an element node
 : @param atts attribute nodes
 : @return the updated element node
 :)
declare function uupd:addAtts($elem as element(),
                              $atts as attribute()*) {
    if (empty($atts)) then $elem else
        $elem/element {node-name(.)} {
            uns:getNamespaceNodes(.),
            $elem/@*,
            $atts,
            node()
        }
};

(:~
 : Removes "pretty print text nodes". These are whitespace-only nodes with
 : element siblings.
 :)
declare function uupd:prettyNode($n as node())
        as node()? {
    typeswitch($n)
    case document-node() return
        document {$n/node() ! uupd:prettyNode(.)}
    case element() return
        $n/element {node-name(.)} {
            uns:getNamespaceNodes(.),
            $n/@* ! uupd:prettyNode(.),
            $n/node() ! uupd:prettyNode(.)
        }
    case text() return
        if (not(matches($n, '\S')) and $n/../*) then () else $n
    default return $n
};

(: 
=================================================================

   p r i v a t e    f u n c t i o s
   
=================================================================
:)

