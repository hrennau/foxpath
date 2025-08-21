module namespace f="http://www.data2type.de/ns/octopus/css-serializer";

declare variable $f:INDENT := '    ';

(:~
 : Serializes a CSS document.
 :)
declare function f:serializeCss($tree as node(),
                                $options as map(xs:string, item()*)?)
        as item()? {
    let $rootElem := $tree/descendant-or-self::*[1]
    let $options := ($options, map{})[1]
    let $options := map:put($options, 'comment-inline', false())    
    let $serParts := f:serializeCssREC($rootElem, 0, $options)
    let $ser := $serParts => string-join('')
    let $ser := $ser ! replace(., '^\s*&#xA;+', '')
    return $ser
};

(:~
 : Recursive helper function of `Serializes a CSS document.
 :)
declare function f:serializeCssREC($node as element(),
                                   $level as xs:integer,
                                   $options as map(xs:string, item()*))
        as item()* {
    typeswitch($node)
    case document-node() return
        $node/* ! f:serializeCssREC(., 0, $options)
        
    case element(css) return 
        $node/* ! f:serializeCssREC(., 0, $options)
        
    case element(rules) return (
        ' {'[$node/parent::rule],
        $node/* ! f:serializeCssREC(., $level + 1, $options),
        '&#xA;}'[$node/parent::rule]        
    )

    case element(import) return (
        '&#xA;@import '||$node/string()||';&#xA;'        
    )

    case element(comment) return
        let $text := '/*'||$node||'*/'
        return
            if ($options?comment-inline) then $text
            else 
                let $prefix := $node/preceding-sibling::*[1][self::properties]/' ' 
                return '&#xA;'||$prefix||f:indent($level)||$text
        
    case element(rule) return (
        '&#xA;'||'&#xA;'[$node/preceding-sibling::rule],
        $node/* ! f:serializeCssREC(., $level, $options),
        if (exists($node/(properties, rules))) then () else ' {}'
    )
    
    case element(selectors) return (
        f:indent($level),
        let $text := ($node/* ! f:serializeCssREC(., $level, $options))
                     => string-join('')
        let $text := replace($text, '\s+$', '')                     
        return $text        
    )

    case element(properties) return (
        ' {',
        $node/* ! f:serializeCssREC(., $level + 1, $options),
        '&#xA;'||f:indent($level)||'}'
    )
    
    case element(property) return 
        let $options := map:put($options, 'comment-inline', true())
        return (
            '&#xA;'||f:indent($level),
            $node/* ! f:serializeCssREC(., $level, $options),
            ';',
            () (: '&#xA;'[not($node/following-sibling::comment)] :)
        )

    case element(name) return (
        $node/* ! f:serializeCssREC(., $level, $options),
        ': '
    )

    case element(value) return (
        $node/* ! f:serializeCssREC(., $level, $options)
    )
    
    case element(t) return string($node)
   
    default return $node
};

declare function f:indent($level as xs:integer)
        as xs:string {
    f:repeatString($f:INDENT, $level - 1)        
};        

declare function f:repeatString($s as xs:string, $count as xs:integer)
        as xs:string {
    (for $i in 1 to $count return $s) => string-join('')        
};


