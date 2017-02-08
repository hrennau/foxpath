module namespace f="http://www.ttools.org/xquery-functions";
import module namespace i="http://www.ttools.org/xquery-functions" at
    "foxpath-functions.xqm",
    "foxpath-parser.xqm",
    "foxpath-processorDependent.xqm",
    "foxpath-uri-operations.xqm",
    "foxpath-util.xqm";

(:~
 : Resolves a foxpath expression. The result is an XDM value.
 :
 : @param foxpath the expression text
 : @return the expression value, which is an XDM value
 :)
declare function f:resolveFoxpath($foxpath as xs:string?) as item()* {
    f:resolveFoxpath($foxpath, (), ())
};

(:~
 : Resolves a foxpath expression in an URI context. The result is an XDM value.
 :
 : @param foxpath the expression text
 : @return the expression value, which is an XDM value
 :)
declare function f:resolveFoxpathInURIContext($foxpath as xs:string?) as item()* {
    f:resolveFoxpath($foxpath, map:entry('IS_CONTEXT_URI', true()), ())
};


(:~
 : Resolves a foxpath expression. The result is an XDM value.
 :
 : @param foxpath the expression text
 : @param options evaluation options
 : @return the expression value, which is an XDM value
 :)
declare function f:resolveFoxpath($foxpath as xs:string?, 
                                  $options as map(*)?,
                                  $externalVariableBindings as map(xs:QName, item()*)?) 
        as item()* {
    f:resolveFoxpath($foxpath, false(), (), (), $options, $externalVariableBindings)
};

(:~
 : Resolves a foxpath expression to a value.
 :
 : @param foxpath the text of a foxpath expression
 : @param ebvMode if true, the expression is resolved to its effective 
 :    boolean value, rather than its value
 : @param context if specified, a file system folder used for resolving 
 :    relative path expressions; defaults to the current working directory
 : @param defaultFileName if set, foxpath resolution is extended by the replacement
 :     of any folder URIs in the preliminary result by the URIs of files and 
 :     folders contained by the respective folder and matching the parameter
 :     value interpreted as a glob pattern
 : @return the expression value
 :)
declare function f:resolveFoxpath($foxpath as xs:string?, 
                                  $ebvMode as xs:boolean?,
                                  $context as xs:string?,
                                  $defaultFileName as xs:string?,
                                  $options as map(*)?,
                                  $externalVariableBindings as map(xs:QName, item()*)?)
        as item()* {
    if (not($foxpath)) then () else
    
    let $value := f:resolveFoxpath($foxpath, $ebvMode, $context, $options, 
                    $externalVariableBindings)
    return 
        if (not($defaultFileName) or $value instance of element(errors)) 
        then $value 
        else  
            (: paths pointing at folders are resolved to the set of 
               paths pointing to the child files matching the default 
               file name pattern :)
            sort(distinct-values(
                for $path in $value return
                    if (not(i:fox-is-dir($path, $options))) then $path
                    else
                        f:childUriCollection($path, $defaultFileName, (), $options)
                        ! concat($path, '/', .)
            ))                        
};

(:~
 : Resolves a foxpath expression to a value.
 :
 : @param foxpath the text of a foxpath expression
 : @param ebvMode if true, the expression is resolved to its effective 
 :    boolean value, rather than its value
 : @param context if specified, a file system folder used for resolving 
 :    relative path expressions; defaults to the current working directory
 : @return the expression value
 :)
declare function f:resolveFoxpath($foxpath as xs:string, 
                                  $ebvMode as xs:boolean?, 
                                  $context as xs:string?,
                                  $options as map(*)?,
                                  $externalVariableBindings as map(xs:QName, item()*)?)
        as item()* {
    let $DEBUG := f:trace($foxpath, 'parse.resolve_foxpath', 'INTEXT_RESOLVE_FOXPATH: ')
    let $tree := f:trace(i:parseFoxpath($foxpath, $options), 'parse', 'FOXPATH_ELEM: ')
    let $errors := $tree/self::errors 
    return 
        if ($errors) then $errors
        else
            let $useOptions := f:finalizeOptions($options)
            let $expr := $tree/*[not(self::prolog)]
            let $vars := f:initVars($tree/prolog, $externalVariableBindings, $context, $useOptions)
            return
                f:resolveFoxpathRC($expr, $ebvMode, $context, (), (), $vars, $useOptions)
};

(: 
 : ===============================================================================
 :
 :     p r e p a r e    r e s o l v i n g
 :
 : ===============================================================================
 :)
(:~
 : Finalizes the options map, using input option values when supplied, and
 : default values otherwise. Adds to the map also URI trees, if provided.
 :
 : @param options parsing options
 : @return the initial parsing context
 :)
declare function f:finalizeOptions($options as map(*)?)
        as map(*) {
    let $utreeDirs := $options ! map:get(., 'UTREE_DIRS') ! tokenize(normalize-space(.), ' ')        
    let $ugraphEndpoints := $options ! map:get(., 'UGRAPH_ENDPOINTS') ! tokenize(normalize-space(.), ' ')    
    
    let $utreeDirs :=
        for $utreeDir in $utreeDirs
        return
            if (starts-with($utreeDir, 'basex://')) then $utreeDir
            else if (starts-with($utreeDir, '/')) then $utreeDir
            else
                let $baseURI := replace(static-base-uri(), '[^/]+$', '')
                return
                    concat($baseURI, $utreeDir)
    let $uriTrees :=
        for $utreeDir in $utreeDirs
        return
            if (starts-with($utreeDir, 'basex://')) then
                let $db := substring($utreeDir, 9)
                let $docs := try {db:open($db)/*} catch * {()}
                return $docs
            else
                try {
                    file:list($utreeDir, false(), 'utree-*') 
                    ! concat($utreeDir, '/', .) ! doc(.)/*
                } catch * {()}
(:            
    let $uriPrefixMap :=
        map:merge(
            for $doc in $uriTrees
            return map:entry($doc/@uriPrefix, $doc/tree/@baseURI)
        )
:)        
    let $uriPrefixes := $uriTrees/@uriPrefix
    
    (: let $ugraphUriPrefixes := 'https://github.com/marklogic/' :)
    let $ugraphUriPrefixes := 
        if (empty($ugraphEndpoints)) then () else
            f:get-ugraph-uri-prefixes($ugraphEndpoints[1], $options)
    
    (: let $DUMMY := trace(count($uriTrees), 'COUNT_URI_TREES #2: ') :)        
    let $map :=
        map{       
            'URI_TREES_DIRS': $utreeDirs,
            'URI_TREES': $uriTrees,
            'URI_TREES_BASE_URIS': $uriTrees/tree/@baseURI,
            'URI_TREES_PREFIXES': $uriPrefixes,
            'UGRAPH_ENDPOINTS': $ugraphEndpoints,
            'UGRAPH_URI_PREFIXES': $ugraphUriPrefixes
        }
(:  'URI_TREES_PREFIX_TO_BASE_URIS': $uriPrefixMap :)
    (: let $DUMMY := trace(count(map:get($map, 'URI_TREES')), 'COUNT_URI_TREES_IN_MAP: ') :)
    return    
        $map
};

(:~
 : Initializes the map of variable bindings with the result of evaluating
 : the variable declarations.
 :)
declare function f:initVars($prolog as element(prolog)?, 
                            $externalVariableBindings as map(xs:QName, item()*)?,
                            $context as xs:string?,
                            $options as map(*)?)
        as map(xs:QName, item()*)? {
    if (empty($prolog)) then () else
    
    let $varDecls := $prolog/varDecls/varDecl
    return if (not($varDecls)) then () else
    
    let $vars := map{}    
    let $vars := f:bindVars($vars, $varDecls, $externalVariableBindings, $context, $options)
    return
        $vars
};

(:~
 : Enters the values of variable declarations into the map of variable bindings.
 :
 : @param vars the map of variable bindings
 : @param varDecls variable declarations
 : @param externalVariableBindings a map associating the names of external
 :    variables with values supplied from without
 :)
declare function f:bindVars($vars as map(xs:QName, item()*),
                            $varDecls as element(varDecl)*,
                            $externalVariableBindings as map(xs:QName, item()*)?,
                            $context as xs:string?,
                            $options as map(*)?)
        as map(xs:QName, item()*) {
    let $varDecl := head($varDecls)
    let $tail := tail($varDecls)
    
    let $localName := $varDecl/@localName
    let $namespace := $varDecl/@namespace
    let $qname := QName($namespace, $localName)
    let $varName := $qname (: $localName :)
    let $isExternal := $varDecl/@external
    
    let $mapEntry :=
        if ($isExternal eq 'true') then
            let $externalVariableBindingNames := 
                if (empty($externalVariableBindings)) then () else
                    map:keys($externalVariableBindings)
            return
                if ($qname = $externalVariableBindingNames) then
                    let $valueRaw := $externalVariableBindings($qname)                            
                    let $value := 
                        let $seqType := $varDecl/sequenceType
                        return f:applyFunctionConversionRules($valueRaw, $seqType)
                    return map:entry($varName, $value)
                else 
                    let $valueExpr := $varDecl/*[not(self::sequenceType)]
                    return
                        if (not($valueExpr)) then
                            error(QName((), 'MISSING_EXTERNAL_VARIABLE_VALUE'), 
                                concat('No value supplied for external variables: ', 
                                $varName))
                        else
                            let $valueRaw := f:resolveFoxpathRC($valueExpr, false(), $context, (), (), $vars, $options)                            
                            let $value := 
                                let $seqType := $varDecl/sequenceType
                                return f:applyFunctionConversionRules($valueRaw, $seqType)
                            return
                                map:entry($varName, $value)
        else
            let $valueExpr := $varDecl/*[not(self::sequenceType)]
            let $valueRaw := f:resolveFoxpathRC($valueExpr, false(), $context, (), (), $vars, $options)            
            let $value := 
                let $seqType := $varDecl/sequenceType
                return f:applyFunctionConversionRules($valueRaw, $seqType)
            return
                map:entry($varName, $value)
    
    let $newVars := map:merge(($vars, $mapEntry))
    return 
        if ($tail) then 
            f:bindVars($newVars, $tail, $externalVariableBindings, $context, $options)
        else
            $newVars
};        

(:~
 : Resolves a foxpath, provided as an expression tree.
 :
 : @param n a node of the expression tree
 : @param ebvMode if true, the node must be resolved to its effective boolean value
 : @return the value of the expression tree node
 :)
declare function f:resolveFoxpathRC($n as node(),
                                    $ebvMode as xs:boolean?,
                                    $context as item()?,
                                    $position as xs:integer?,
                                    $last as xs:integer?,
                                    $vars as map(xs:QName, item()*)?,
                                    $options as map(*)?)
        as item()* {
    typeswitch($n)
  
    case element(additive) return
        let $lhs := f:resolveFoxpathRC($n/*[1], false(), $context, $position, $last, $vars, $options)
        let $rhs := f:resolveFoxpathRC($n/*[2], false(), $context, $position, $last, $vars, $options)
        let $op := $n/@op
        let $value := 
            if ($op eq '+') then $lhs + $rhs
            else if ($op eq '-') then $lhs - $rhs
            else error(QName((), 'UNEXPECTED_OPERATOR'), 
                concat('Unexpected operator in additive expression: ', $op))
        return
            if ($ebvMode) then boolean($value)
            else $value
            
    case element(and) return
        let $args := $n/*/(
                     f:resolveFoxpathRC(., true(), $context, $position, $last, $vars, $options), 
                     false()
                     )[1]
        return
            every $arg in $args satisfies $arg
 
    case element(archiveEntry) return
        $context ! concat(., '/', $f:ARCHIVE_TOKEN)
        
    case element(cast) return
        f:resolveCastExpr($n, $ebvMode, $context, $position, $last, $vars, $options)
        
    case element(castable) return
        f:resolveCastableExpr($n, $ebvMode, $context, $position, $last, $vars, $options)
        
    case element(contextItem) return
        $context
        
    case element(cmpN) return
        let $lhs := f:resolveFoxpathRC($n/*[1], false(), $context, $position, $last, $vars, $options)
        let $rhs := f:resolveFoxpathRC($n/*[2], false(), $context, $position, $last, $vars, $options)
        let $op := $n/@op
        let $value := 
            if ($op eq 'is') then $lhs is $rhs
            else if ($op eq '&lt;&lt;') then $lhs << $rhs
            else if ($op eq '>>') then $lhs >> $rhs            
            else error(QName((), 'UNEXPECTED_OPERATOR'), 
                concat('Unexpected operator in node comparison expression: ', $op))
        return
            $value
            
    case element(cmpG) return
        let $lhs := f:resolveFoxpathRC($n/*[1], false(), $context, $position, $last, $vars, $options)
        let $rhs := f:resolveFoxpathRC($n/*[2], false(), $context, $position, $last, $vars, $options)
        let $lhs := if ($lhs instance of xs:string) then xs:untypedAtomic($lhs) else $lhs
        let $rhs := if ($rhs instance of xs:string) then xs:untypedAtomic($rhs) else $rhs        
        let $op := $n/@op
        let $value := 
            if ($op eq '=') then $lhs = $rhs
            else if ($op eq '!=') then $lhs != $rhs
            else if ($op eq '<') then $lhs < $rhs            
            else if ($op eq '<=') then $lhs <= $rhs
            else if ($op eq '>') then $lhs > $rhs
            else if ($op eq '>=') then $lhs >= $rhs            
            else if ($op eq '~') then matches(string($lhs), string($rhs))            
            else error(QName((), 'UNEXPECTED_OPERATOR'), 
                concat('Unexpected operator in general comparison: ', $op))
        return
            $value
            
    case element(cmpV) return
        let $lhs := f:resolveFoxpathRC($n/*[1], false(), $context, $position, $last, $vars, $options)
        let $rhs := f:resolveFoxpathRC($n/*[2], false(), $context, $position, $last, $vars, $options)
        let $lhs := if ($lhs instance of xs:string) then xs:untypedAtomic($lhs) else $lhs
        let $rhs := if ($rhs instance of xs:string) then xs:untypedAtomic($rhs) else $rhs        
        let $op := $n/@op
        let $value := 
            if ($op eq 'eq') then $lhs eq $rhs
            else if ($op eq 'ne') then $lhs ne $rhs
            else if ($op eq 'lt') then $lhs lt $rhs            
            else if ($op eq 'le') then $lhs le $rhs
            else if ($op eq 'gt') then $lhs gt $rhs
            else if ($op eq 'ge') then $lhs ge $rhs           
            else error(QName((), 'UNEXPECTED_OPERATOR'), 
                concat('Unexpected operator in value comparison: ', $op))
        return
            $value
            
    case element(dynFuncCall) return
        let $value := f:resolveDynFunctionCall($n, $context, $position, $last, $vars, $options)       
        return
            if ($ebvMode) then f:getEbv($value) else $value

    case element(emptySequence) return ()       

     case element(filterExpr) return
        let $unfiltered := f:resolveFoxpathRC($n/*[1], false(), $context, $position, $last, $vars, $options)
        let $predicates := tail($n/*)
        let $value := f:testPredicates($unfiltered, $predicates, $vars, $options)
        return
            if ($ebvMode) then f:getEbv($value) else $value
            
    case element(flwor) return
        f:resolveFlworExpr($n, $ebvMode, $context, $position, $last, $vars, $options)

    case element(foxpath) return
        f:resolveFoxpathExpr($n, $ebvMode, $context, $position, $last, $vars, $options)
        
     case element(functionRef) return
        let $funcItem := f:resolveNamedFunctionRef($n, $context, $position, $last, $vars, $options)
        return
            $funcItem

     case element(inlineFunctionExpr) return
        let $funcItem := f:resolveInlineFunctionExpression($n, $context, $position, $last, $vars, $options)
        return
            $funcItem

    case element(functionCall) return
        let $value := f:resolveFunctionCall($n, $context, $position, $last, $vars, $options)
        return
            if ($ebvMode) then f:getEbv($value) else $value

    case element(if) return
        let $value := f:resolveIfExpr($n, $ebvMode, $context, $position, $last, $vars, $options)
        return
            if ($ebvMode) then f:getEbv($value) else $value
        
    case element(instance) return
        f:resolveInstanceOfExpr($n, $ebvMode, $context, $position, $last, $vars, $options)
            
    case element(intersectExcept) return
        f:resolveIntersectExceptExpr($n, $ebvMode, $context, $position, $last, $vars, $options)
            
    case element(map) return
        f:resolveMapExpr($n, $ebvMode, $context, $position, $last, $vars, $options)
            
    case element(multiplicative) return
        let $lhs := f:resolveFoxpathRC($n/*[1], false(), $context, $position, $last, $vars, $options)
        let $rhs := f:resolveFoxpathRC($n/*[2], false(), $context, $position, $last, $vars, $options)
        let $op := $n/@op
        let $value := 
            if ($op eq '*') then $lhs * $rhs
            else if ($op eq 'div') then $lhs div $rhs
            else if ($op eq 'idiv') then $lhs idiv $rhs            
            else if ($op eq 'mod') then $lhs mod $rhs            
            else error(QName((), 'UNEXPECTED_OPERATOR'), 
                concat('Unexpected operator in multiplicative expression: ', $op))
        return
            if ($ebvMode) then boolean($value)
            else $value
            
    case element(number) return
        let $untyped := string($n/@value)
        let $type := $n/@type
        let $value :=
            if ($type eq 'xs:integer') then xs:integer($untyped)
            else if ($type eq 'xs:decimal') then xs:decimal($untyped)
            else if ($type eq 'xs:double') then xs:double($untyped)            
            else error(QName((), 'UNEXPECTED_NUMBER_TYPE'), concat('Unexpected number type: ', $type))
        return
            if ($ebvMode) then $value != 0
            else $value

    case element(or) return
        let $args := $n/*/(
                     f:resolveFoxpathRC(., true(), $context, $position, $last, $vars, $options), 
                     false()
                     )[1]
        return
            some $arg in $args satisfies $arg 

     case element(postfixExpr) return
        let $unfiltered := f:resolveFoxpathRC($n/*[1], false(), $context, $position, $last, $vars, $options)
        let $predicates := tail($n/*)
        let $value := f:testPredicates($unfiltered, $predicates, $vars, $options)
        return
            if ($ebvMode) then f:getEbv($value) else $value
            
    case element(quantified) return
        f:resolveQuantifiedExpr($n, $context, $position, $last, $vars, $options)

    case element(range) return
        let $lhs := f:resolveFoxpathRC($n/*[1], false(), $context, $position, $last, $vars, $options)
        let $rhs := f:resolveFoxpathRC($n/*[2], false(), $context, $position, $last, $vars, $options)
        let $value := $lhs to $rhs
        return if ($ebvMode) then f:getEbv($value) else $value
            
    case element(seq) return
        let $args := $n/*/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
        return if ($ebvMode) then f:getEbv($args) else $args

    case element(string) return
        let $value := string($n)
        return if ($ebvMode) then f:getEbv($value) else $value
            
    case element(treat) return
        f:resolveTreatExpr($n, $ebvMode, $context, $position, $last, $vars, $options)
        
    case element(unary) return
        let $operand := f:resolveFoxpathRC($n/*[1], false(), $context, $position, $last, $vars, $options)
        let $op := $n/@op
        let $value := 
            if ($op eq '-') then - $operand else + $operand
        return
            if ($ebvMode) then f:getEbv($value) else $value
            
    case element(union) return
        f:resolveUnionExpr($n, $ebvMode, $context, $position, $last, $vars, $options)
            
    case element(var) return   
        let $value := f:getVarValue($n, $vars, $options)
        return
            if ($ebvMode) then f:getEbv($value) else $value
    default return
        error(QName((), 'NOT_YET_IMPLEMENTED'),
            concat('Unexpected foxpath node, name=', local-name($n)))
};

(: 
 : ===============================================================================
 :
 :     r e s o l v e    f o x p a t h    e x p r e s s i o n
 :
 : ===============================================================================
 :)

(:~
 : Resolves a foxpath expression.
 :
 : @param foxpath the expression as an expression tree
 : qparam ebvMode if true, the effective boolean value is returned, rather than the expression value
 : @param context the context item
 : @return the value or effective boolean value of the expression
 :)
declare function f:resolveFoxpathExpr($foxpath as element(foxpath), 
                                      $ebvMode as xs:boolean?,
                                      $context as item()?,
                                      $position as xs:integer?,
                                      $last as xs:integer?,
                                      $vars as map(xs:QName, item()*)?,
                                      $options as map(*)?)                                      
        as item()* {
    let $initialRoot := $foxpath/*[1][self::foxRoot or self::root]   
    
    (: the context wherein to evaluate the first step :)
    let $initialContext :=
        (: leading step to the root resource :)
        if ($initialRoot/self::foxRoot) then 
            $initialRoot/@path/string()
        (: leading step to the root node :)
        else if ($initialRoot/self::root) then 
            if ($context instance of node()) then root($context)
            else if (exists($context)) then 
                i:fox-doc($context, $options)
            else 
                f:createFoxpathError('SYNTAX_ERROR', 
                    concat('Absolute node path encountered, but no context provided; ',
                        'expr=', $foxpath/@text))
        (: no initial step to the root resource or root node;
           the context item defaults to the current directory! :) 
        else 
            ($context, $foxpath/@context/string())[1]
    return
        if (empty($initialContext)) then () else
        
    let $steps := $foxpath/(* except $initialRoot)[not(@__ignore eq 'true')]
    let $value :=
        if (not($steps)) then 
            $initialContext [f:fox-file-exists($initialContext, $options)]
            (: 20161202, hjr - removed .../string() :)
            (: $initialContext/string() [f:fox-file-exists($initialContext, $options)] :)
        else
            let $items := f:resolveFoxpathExprRC($steps, $initialContext, $vars, $options)
            (: 20161001, hjr: removed the sorting; 
                         sorting is handled within fox axis step resolver 
            return
                if ($foxpath/*[last()]/self::foxStep) then
                    for $item in $items order by lower-case(string($item)) return $item
                else $items
            :)
            return $items
    return
        if (not($ebvMode)) then $value
        else f:getEbv($value)
};

(:~
 : Recursive helper function of `resolveFoxpathExpr`.
 :)
declare function f:resolveFoxpathExprRC($steps as element()+, 
                                        $context as item()*,
                                        $vars as map(xs:QName, item()*)?,
                                        $options as map(*)?)                                        
        as item()* {
    let $step1 := $steps[1]
    let $tail := tail($steps)
    let $items :=
        if ($step1/self::foxStep/@axis) then 
            f:resolveFoxAxisStep($step1, $context, $vars, $options)
        else if ($step1/self::step/@axis) then 
            f:resolveNodeAxisStep($step1, $context, $vars, $options)
        else
            (: bugfix 20160724 - expr either child or self of step1 :)
            let $expr :=
                if ($step1/(self::foxStep, self::step)) then $step1/*
                else $step1
            
            let $useContext :=
                if ($step1/self::step) then
                    for $item in $context 
                    return 
                        if ($item instance of node()) then $item 
                        else i:fox-doc($item, $options) 
                else $context
                
            let $last := count($useContext)
            let $value :=
                for $c at $pos in $useContext 
                (: let $EXPR := trace($expr, 'EXPR: ') :)
                return f:resolveFoxpathRC($expr, false(), $c, $pos, $last, $vars, $options)
            let $value :=
                if ($step1/self::step and (every $item in $value satisfies ($item instance of node()))) then $value/.
                else $value
            return
                $value
    return (
        if (not($tail)) then $items
        else f:resolveFoxpathExprRC($tail, $items, $vars, $options)
    )
};

(:~
 : Resolve a fox step expression to a value.
 :)
declare function f:resolveFoxAxisStep($axisStep as element()+, 
                                      $context as xs:string*,
                                      $vars as map(xs:QName, item()*)?,
                                      $options as map(*)?)
        as xs:string* {
    let $axis := $axisStep/@axis/string()
    let $name := $axisStep/@name/string()
    let $regex := $axisStep/@regex/string()
    let $predicates := $axisStep/*[not(@__ignore eq 'true')]    
    let $files :=
        (: forward axis :)
        if ($axis = ('child', 'descendant', 'descendant-or-self')) then
            let $deep := $axis = ('descendant', 'descendant-or-self')
            let $listFunction := 
                if ($deep) then f:descendantUriCollection#4 
                           else f:childUriCollection#4
            return
                for $ctxt in $context (: [not(i:fox-is-file(., $options))] :)
                let $useCtxt := if (matches($ctxt, '^.:$')) then concat($ctxt, '/') else $ctxt 
                (:     file:list('c:') delivers the current working directory files, not the root directory files :)
            
                let $prefix := replace($useCtxt, '/$', '')
                let $descendants :=
                    $listFunction($ctxt, $name, $axisStep, $options)
                    ! replace(., '/$', '')
                    [not($regex) or matches(replace(., '.*/', ''), $regex, 'i')]            
                    ! concat($prefix, '/', .)
                    (: [not($tail) or file:is-dir(.)] :)  (: not any more true: following steps may be reverse steps :)
(:                   
                let $DUMMY := trace((), concat('AFTER_LIST_DESCENDANTS ',
                                        $axis, '~::', $name, ' (', count($descendants), '): '))
:)                                        
                let $descendants := distinct-values($descendants)
                let $ctxtFiles :=
                    if (not($axis eq 'descendant-or-self')) then $descendants
                    else (
                        $ctxt[not($regex) or matches(replace(., '.*/', ''), $regex, 'i')],
                        $descendants
                    )
                return
                    (: let $DUMMY := trace(sort($ctxtFiles), 'CTXT_FILES: ') return :)
                    if (not($predicates)) then $ctxtFiles
                    else f:testPredicates(sort($ctxtFiles, (), lower-case#1), $predicates, $vars, $options)
                    
        else if ($axis = 'self') then
                for $ctxt in $context
                let $ctxt := if (matches($ctxt, '^.:$')) then concat($ctxt, '/') else $ctxt 
                (:     file:list('c:') delivers the current working directory files, not the root directory files :)
            
                let $ctxtFiles := $ctxt
                    [not($regex) or matches(replace(., '.*/', ''), $regex, 'i')]            
                return
                    if (not($predicates)) then $ctxtFiles
                    else f:testPredicates(sort($ctxtFiles, lower-case#1), $predicates, $vars, $options)
        else if ($axis = 'following-sibling') then
                for $ctxt in $context
                let $parent := (replace($ctxt, '/[^/]*$', '')[string()], '/')[1]
                let $followingSiblings := 
                    f:childUriCollection($parent, '*', $axisStep, $options)
                    [lower-case(replace(., '.*/', '')) gt lower-case(replace($ctxt, '.*/', ''))]                    
                    [not($regex) or matches(replace(., '.*/', ''), $regex, 'i')]            
                    ! concat($parent, '/', .)                
                return
                    if (not($predicates)) then $followingSiblings
                    else f:testPredicates(sort($followingSiblings, lower-case#1), $predicates, $vars, $options)
        
        (: reverse axis :)        
        else    
            if ($axis eq 'parent') then
                for $ctxt in $context
                let $parent := (replace($ctxt, '/[^/]*$', '')[string()], '/')[1]
                (: correction - if parent is driveLetter: - append slash :)
                let $parent :=
                    if (matches($parent, '^.:$')) then concat($parent, '/') else $parent
                let $parent :=
                    $parent
                    [not($regex) or matches(replace(., '.*/', ''), $regex)]
                return
                    if (not($predicates)) then $parent
                    else f:testPredicates($ctxt, $predicates, $vars, $options)
            else if ($axis = ('ancestor', 'ancestor-or-self')) then
                for $ctxt in $context
                let $items := tokenize($ctxt, '/')
                let $root := concat(head($items), '/')            
                let $steps := tail($items)[position() lt last()]
                let $ancestorsIndices :=
                    for $pos in 1 to count($steps)
                    where not($regex) or matches($steps[$pos], $regex, 'i')
                    return $pos
                let $ancestors := (
                    $root[not($regex) or $regex eq '^.*$'], 
                    (: the root folder is only considered if there is no non-wildcard name test :)
                    for $ai in $ancestorsIndices
                    return
                        concat($root, string-join(for $index in 1 to $ai return $steps[$index], '/'))
                )
                let $ctxtFiles :=
                    if (not($axis eq 'ancestor-or-self')) then $ancestors
                    else (
                        $ctxt[not($regex) or matches(replace(., '.*/', ''), $regex, 'i')],
                        $ancestors
                    )
                return                    
                    if (not($predicates)) then $ctxtFiles
                    else
                        f:testPredicates(reverse(sort($ctxtFiles, (), lower-case#1)), $predicates, $vars, $options)
        else if ($axis = 'preceding-sibling') then
                for $ctxt in $context
                let $parent := (replace($ctxt, '/[^/]*$', '')[string()], '/')[1]
                let $precedingSiblings := 
                    f:childUriCollection($parent, '*', $axisStep, $options)
                    [lower-case(replace(., '.*/', '')) lt lower-case(replace($ctxt, '.*/', ''))]                    
                    [not($regex) or matches(replace(., '.*/', ''), $regex, 'i')]            
                    ! concat($parent, '/', .)                
                return
                    if (not($predicates)) then $precedingSiblings
                    else f:testPredicates(reverse(sort($precedingSiblings, lower-case#1)), $predicates, $vars, $options)
                        
        else
            f:createFoxpathError('NOT_YET_IMPLEMENTED', 
                concat('Axis not yet implemented: ', $axis))
                
    let $files := distinct-values(for $f in $files order by lower-case($f) return $f)  
    return (
        $files
    )
};

(:~
 : Resolve a node step expression to a value.
 :)
declare function f:resolveNodeAxisStep($axisStep as element()+, 
                                       $context as item()*,
                                       $vars as map(xs:QName, item()*)?,
                                       $options as map(*)?)
        as item()* {
    (: *** ATTENTION - DEVIATION FROM THE XQUERY SPEC *********************
       Note that the XQuery spec prescribes a fatal error when a node
       axis step appears in a dynamic context including atomic values.

       In contrast to this rule, the foxpath specification prescribes an 
       implicit transformation of any atomic context items into document 
       nodes, achieved by applying to each atomic context item the fn:doc 
       function. This deviation enables the seamless integration of fox 
       axis steps and node axis steps, example: \a\b\c.xml/x/y/z
       ********************************************************************
    :)
    
    (: edit context, transforming atomic values into document nodes :)
    (: let $DUMMY := trace($context, 'CONTEXT: ') :)
    let $context :=
        for $c in $context return
            if ($c instance of node()) then $c
            else i:fox-doc($c, $options)              
    let $axis := $axisStep/@axis
    let $localName := $axisStep/@localName
    let $uri := $axisStep/@namespace    
    let $nodeKind := $axisStep/@nodeKind
    let $nodeName := $axisStep/@nodeName
    let $predicates := $axisStep/*
    
    let $nodeTest :=
        if ($localName) then
            if ($localName eq '*') then 
                if ($uri ne '*') then
                    function($node as node()) as xs:boolean? 
                        {namespace-uri($node) eq $uri}                
                else
                    function($node as node()) as xs:boolean? {true()}
            else if ($uri ne '*') then
                function($node as node()) as xs:boolean? 
                    {local-name($node) eq $localName and namespace-uri($node) eq $uri}
            else
                function($node as node()) as xs:boolean?            
                    {local-name($node) eq $localName}
        else if ($nodeKind) then
            if ($nodeKind eq 'node') then
                function($node as node()) as xs:boolean? {true()}
            else if ($nodeKind eq 'text') then
                function($node as node()) as xs:boolean? {exists($node/self::text())}
            else if ($nodeKind eq 'comment') then
                function($node as node()) as xs:boolean? {exists($node/self::comment())}
            else if ($nodeKind eq 'processing-instruction') then
                function($node as node()) as xs:boolean? {exists($node/self::processing-instruction())}
            else if ($nodeKind eq 'document') then
                function($node as node()) as xs:boolean? {exists($node/self::document-node())}
            else if ($nodeKind eq 'element') then
                if (not($nodeName) or $nodeName eq '*') then
                    function($node as node()) as xs:boolean? {exists($node/self::element())}
                else    
                    function($node as node()) as xs:boolean? {$node/self::element()/(name(.) eq $nodeName)}
                    (: *TODO* compare node-name(), rather than name(), 
                        which presupposes in-scope namespace bindings :)
            else if ($nodeKind eq 'attribute') then
                if (not($nodeName) or $nodeName eq '*') then
                    function($node as node()) as xs:boolean? {exists($node/self::attribute())}
                else    
                    function($node as node()) as xs:boolean? {$node/self::attribute()/(name(.) eq $nodeName)}
                    (: *TODO* compare node-name(), rather than name(), 
                        which presupposes in-scope namespace bindings :)
            else ()
        else
            f:createFoxpathError('NOT_YET_IMPLEMENTED', 
                concat('Not yet implemented: path step with node kind test: ', $nodeKind))
   
    let $resultItemsUnfiltered :=
        if ($axis eq 'child') then
            if ($localName or $nodeKind eq 'element') then
                for $c in $context return $c/*[$nodeTest(.)]
            else                
                for $c in $context return $c/node()[$nodeTest(.)]
        else if ($axis eq 'attribute') then
            for $c in $context return $c/@*[$nodeTest(.)]
        else if ($axis eq 'descendant') then
            if ($localName or $nodeKind eq 'element') then        
                for $c in $context return $c/descendant::*[$nodeTest(.)]
            else
                for $c in $context return $c/descendant::node()[$nodeTest(.)]
        else if ($axis eq 'descendant-or-self') then
            if ($localName or $nodeKind eq 'element') then        
                for $c in $context return $c/descendant-or-self::*[$nodeTest(.)]
            else                
                for $c in $context return $c/descendant-or-self::node()[$nodeTest(.)]
        else if ($axis eq 'descendant-or-self') then
            if ($localName or $nodeKind eq 'element') then            
                for $c in $context return $c/descendant-or-self::*[$nodeTest(.)]
            else
                for $c in $context return $c/descendant-or-self::node()[$nodeTest(.)]
        else if ($axis eq 'following-sibling') then
            if ($localName or $nodeKind eq 'element') then
                for $c in $context return $c/following-sibling::*[$nodeTest(.)]
            else
                for $c in $context return $c/following-sibling::node()[$nodeTest(.)]
        else if ($axis eq 'following') then
            if ($localName or $nodeKind eq 'element') then        
                for $c in $context return $c/following::*[$nodeTest(.)]
            else                
                for $c in $context return $c/following::node()[$nodeTest(.)]
        else if ($axis eq 'self') then
            if ($localName or $nodeKind eq 'element') then        
                for $c in $context return $c/self::*[$nodeTest(.)]
            else
                for $c in $context return $c/self::node()[$nodeTest(.)]
        else if ($axis eq 'parent') then
            if ($localName or $nodeKind eq 'element') then        
                for $c in $context return $c/parent::*[$nodeTest(.)]
            else
                for $c in $context return $c/parent::node()[$nodeTest(.)]
        else if ($axis eq 'ancestor') then
            if ($localName or $nodeKind eq 'element') then
                for $c in $context return $c/ancestor::*[$nodeTest(.)]
            else
                for $c in $context return $c/ancestor::node()[$nodeTest(.)]
        else if ($axis eq 'ancestor-or-self') then
            if ($localName or $nodeKind eq 'element') then        
                for $c in $context return $c/ancestor-or-self::*[$nodeTest(.)]
            else
                for $c in $context return $c/ancestor-or-self::node()[$nodeTest(.)]
        else if ($axis eq 'preceding-sibling') then
            if ($localName or $nodeKind eq 'element') then
                for $c in $context return $c/preceding-sibling::*[$nodeTest(.)]
            else                
                for $c in $context return $c/preceding-sibling::node()[$nodeTest(.)]
        else if ($axis eq 'preceding') then
            if ($localName or $nodeKind eq 'element') then        
                for $c in $context return $c/preceding::*[$nodeTest(.)]
            else
                for $c in $context return $c/preceding::node()[$nodeTest(.)]
        else
            f:createFoxpathError('PROGRAM_ERROR', concat('Unexpected axis: ', $axis))
    let $resultItemsUnfiltered := $resultItemsUnfiltered/.        
    let $resultItems :=
        if (not($predicates)) then $resultItemsUnfiltered
        else
            let $reverseAxis := $axis = ('parent', 'ancestor', 'ancestor-or-self', 'preceding-sibling', 'preceding')
            let $predicatesInput :=
                if ($reverseAxis) then reverse($resultItemsUnfiltered)
                else  $resultItemsUnfiltered
            return
                f:testPredicates($predicatesInput, $predicates, $vars, $options)

    return
        $resultItems
};

(:~
 : Filters a squence of items by a list of predicates.
 :
 : @param items the items to be filtered
 : @param predicates the predicates
 : @return the items retained after filtering
 :)
declare function f:testPredicates($items as item()*, 
                                  $predicates as element()*,
                                  $vars as map(xs:QName, item()*)?,
                                  $options as map(*)?)                                  
        as item()* {
    if (empty($items)) then () 
    else if (empty($predicates)) then $items
    else
    
    let $predicate := head($predicates)
    let $tail := tail($predicates)
    let $last := count($items)
    let $itemsFiltered :=
        let $last := count($items)
        for $item at $pos in $items        
        let $predicateValue := f:resolveFoxpathRC($predicate, false(), $item, $pos, $last, $vars, $options) 
        return
            if ($predicateValue instance of xs:decimal) then $item[$predicateValue eq $pos]
            else if (count($predicateValue) gt 1) then $item   (: special rule, taking files lists into account :)
            else $item[$predicateValue]
    return
        if (empty($itemsFiltered)) then ()
        else if ($tail) then f:testPredicates($itemsFiltered, $tail, $vars, $options)
        else $itemsFiltered
};        

(: 
 : ===============================================================================
 :
 :     r e s o l v e    i f   /   f l w o r   /   q u a n t i f i e d    /    m a p
 :
 : ===============================================================================
 :)

(:~
 : Resolves an if expression.
 :
 : @param if the expression tree of an if expression.
 : @param ebvMode if true, the node must be resolved to its effective boolean value
 : @return the value of the if expression
 :)
declare function f:resolveIfExpr($if as element(if),
                                 $ebvMode as xs:boolean?,
                                 $context as item()?,
                                 $position as xs:integer?,
                                 $last as xs:integer?,
                                 $vars as map(xs:QName, item()*)?,
                                 $options as map(*)?)
        as item()* {
    let $condValue := f:resolveFoxpathRC($if/*[1], true(), $context, $position, $last, $vars, $options) 
    return
        if ($condValue) then
            f:resolveFoxpathRC($if/*[2], $ebvMode, $context, $position, $last, $vars, $options)
        else
            f:resolveFoxpathRC($if/*[3], $ebvMode, $context, $position, $last, $vars, $options)
};

(:~
 : Resolves a FLWOR expression.
 :
 : @param flwor the expression tree of FLWOR expression.
 : @param ebvMode if true, the node must be resolved to its effective boolean value
 : @return the value of the expression tree node
 :)
declare function f:resolveFlworExpr($flwor as element(flwor),
                                    $ebvMode as xs:boolean?,
                                    $context as item()?,
                                    $position as xs:integer?,
                                    $last as xs:integer?,
                                    $vars as map(xs:QName, item()*)?,
                                    $options as map(*)?)                                    
        as item()* {
    let $firstClause := $flwor/*[1]       
    let $vars :=
        if (exists($vars)) then $vars
        else map {}
    return
        typeswitch($firstClause)
        case element(for) return 
            f:resolveFlworExpr_for($firstClause, $ebvMode, $context, $position, $last, $vars, $options)
        case element(let) return 
            f:resolveFlworExpr_let($firstClause, $ebvMode, $context, $position, $last, $vars, $options)
        default return
            f:createFoxpathError('NOT_YET_IMPLEMENTED', 
                concat('Flwor clause not yet implemented: ', local-name($firstClause)))
};

(:~
 : Handles a for clause of a FLWOR expression.
 :
 : @param for expression tree of the for clause
 : @param ebvMode if true, the node must be resolved to its effective boolean value
 : @return the value produced by the for clause and all succeeding clauses
 :)
declare function f:resolveFlworExpr_for($for as element(for),
                                        $ebvMode as xs:boolean?,
                                        $context as item()?,
                                        $position as xs:integer?,
                                        $last as xs:integer?,
                                        $vars as map(xs:QName, item()*)?,
                                        $options as map(*)?)                                        
        as item()* {
    let $nextClause := $for/following-sibling::*[1]        
    let $varName := $for/var[1]/@localName   
    let $varNamespace := $for/var[1]/@namespace
    let $varQname := QName($varNamespace, $varName)
    let $varValue := f:resolveFoxpathRC($for/*[2], false(), $context, $position, $last, $vars, $options)                     
    let $exprValue :=
        for $item in $varValue
        let $vars := map:put($vars, $varQname, $item)
        return
            if ($nextClause is $for/following-sibling::*[last()]) then
                f:resolveFoxpathRC($nextClause, $ebvMode, $context, $position, $last, $vars, $options)
            else            
                typeswitch($nextClause)
                case element(for) return 
                    f:resolveFlworExpr_for($nextClause, $ebvMode, $context, $position, $last, $vars, $options)
                case element(let) return 
                    f:resolveFlworExpr_let($nextClause, $ebvMode, $context, $position, $last, $vars, $options)
                default return
                    f:createFoxpathError('NOT_YET_IMPLEMENTED', 
                        concat('Flwor clause not yet implemented: ', local-name($nextClause)))
    return
        if (not($ebvMode)) then $exprValue
        else f:getEbv($exprValue)                   
};

(:~
 : Handles a let clause of a FLWOR expression.
 :
 : @param for expression tree of the let clause
 : @param ebvMode if true, the node must be resolved to its effective boolean value
 : @return the value produced by the let clause and all succeeding clauses
 :)
declare function f:resolveFlworExpr_let($let as element(let),
                                        $ebvMode as xs:boolean?,
                                        $context as item()?,
                                        $position as xs:integer?,
                                        $last as xs:integer?,
                                        $vars as map(xs:QName, item()*),
                                        $options as map(*)?)
        as item()* {
    let $nextClause := $let/following-sibling::*[1]        
    let $varName := $let/var[1]/@localName
    let $varNamespace := $let/var[1]/@namespace 
    let $varQname := QName($varNamespace, $varName)
    let $varValue := f:resolveFoxpathRC($let/*[2], false(), $context, $position, $last, $vars, $options)
    let $vars := map:put($vars, $varQname, $varValue)
    let $exprValue :=
        if ($nextClause is $let/following-sibling::*[last()]) then       
            f:resolveFoxpathRC($nextClause, $ebvMode, $context, $position, $last, $vars, $options)
        else            
            typeswitch($nextClause)
            case element(for) return 
                f:resolveFlworExpr_for($nextClause, $ebvMode, $context, $position, $last, $vars, $options)
            case element(let) return 
                f:resolveFlworExpr_let($nextClause, $ebvMode, $context, $position, $last, $vars, $options)
            default return
                f:createFoxpathError('NOT_YET_IMPLEMENTED', 
                    concat('Flwor clause not yet implemented: ', local-name($nextClause)))
    return
        if (not($ebvMode)) then $exprValue
        else f:getEbv($exprValue)
};

(:~
 : Resolves a quantified expression.
 :
 : @param flwor the expression tree of FLWOR expression.
 : @param ebvMode if true, the node must be resolved to its effective boolean value
 : @return the value of the expression tree node
 :)
declare function f:resolveQuantifiedExpr($quant as element(quantified),
                                         $context as item()?,
                                         $position as xs:integer?,
                                         $last as xs:integer?,
                                         $vars as map(xs:QName, item()*)?,
                                         $options as map(*)?)                                         
        as xs:boolean {
    let $kind := $quant/@kind        
    let $firstClause := $quant/*[1]       
    let $vars :=
        if (exists($vars)) then $vars
        else map {}
    return
        typeswitch($firstClause)
        case element(for) return 
            if ($kind eq 'every') then
                every $result in
                    f:resolveQuantifiedExpr_for($firstClause, $context, $position, $last, $vars, $options)
                satisfies $result eq true()
            else      
                some $result in
                    f:resolveQuantifiedExpr_for($firstClause, $context, $position, $last, $vars, $options)
                satisfies $result eq true()
        default return
            f:createFoxpathError('NOT_YET_IMPLEMENTED', 
                concat('Quantified clause not yet implemented: ', local-name($firstClause)))
};

(:~
 : Handles a var in clause of a quantified expression.
 :
 : @param for expression tree of the var in clause
 : @param ebvMode if true, the node must be resolved to its effective boolean value
 : @return the value produced by the var in clause and all succeeding clauses
 :)
declare function f:resolveQuantifiedExpr_for($for as element(for),
                                             $context as item()?,
                                             $position as xs:integer?,
                                             $last as xs:integer?,
                                             $vars as map(xs:QName, item()*)?,
                                             $options as map(*)?)                                             
        as xs:boolean* {
    let $nextClause := $for/following-sibling::*[1]        
    let $varName := $for/var[1]/@localName        
    let $varNamespace := $for/var[1]/@namespace    
    let $varQname := QName($varNamespace, $varName)    
    let $value := f:resolveFoxpathRC($for/*[2], false(), $context, $position, $last, $vars, $options)
                  (: note that ebvMode = false() :)
    for $item in $value
    let $vars := map:put($vars, $varQname, $item)
    return
        if ($nextClause is $for/following-sibling::*[last()]) then
            f:resolveFoxpathRC($nextClause, true(), $context, $position, $last, $vars, $options)
            (: note that ebvMode = true() :)
        else            
            typeswitch($nextClause)
            case element(for) return 
                f:resolveQuantifiedExpr_for($nextClause, $context, $position, $last, $vars, $options)
            default return
                f:createFoxpathError('NOT_YET_IMPLEMENTED', 
                    concat('Quantified clause not yet implemented: ', local-name($nextClause)))
};

(:~
 : Resolves a map expression.
 :
 : @param for expression tree of the map expression
 : @param ebvMode if true, the node must be resolved to its effective boolean value
 : @return the value produced by the for clause and all succeeding clauses
 :)
declare function f:resolveMapExpr($map as element(map),
                                  $ebvMode as xs:boolean?,
                                  $context as item()?,
                                  $position as xs:integer?,
                                  $last as xs:integer?,
                                  $vars as map(xs:QName, item()*)?,
                                  $options as map(*)?)                                  
        as item()* {
    let $operands := $map/*
    let $value := f:resolveMapExprRC($operands, $context, $position, $last, $vars, $options)
    return
        if ($ebvMode) then f:getEbv($value) else $value
};

(:~
 : Recursive helper function of `resolveMapExpr`
 :
 : @param for expression tree of the map expression
 : @param ebvMode if true, the node must be resolved to its effective boolean value
 : @return the value produced by the for clause and all succeeding clauses
 :)
declare function f:resolveMapExprRC($mapOperands as element()+,
                                    $context as item()?,
                                    $position as xs:integer?,
                                    $last as xs:integer?,
                                    $vars as map(xs:QName, item()*)?,
                                    $options as map(*)?)                                    
        as item()* {
    let $op1 := $mapOperands[1]
    let $tail := tail($mapOperands)
    let $value := f:resolveFoxpathRC($op1, false(), $context, $position, $last, $vars, $options)
    return
        if (empty($tail)) then $value
        else
            let $newLast := count($tail)
            for $item at $newPosition in $value
            return
                f:resolveMapExprRC($tail, $item, $newPosition, $newLast, $vars, $options)
};

(: 
 : ===============================================================================
 :
 :     r e s o l v e    u n i o n   /   i n t e r s e c t   /   e x c e p t
 :
 : ===============================================================================
 :)

(:~
 : Resolves a union expression, provided as an expression tree.
 :
 : The expression value is determined as follows:
 : (1) If all argument items are node: the union of all items
 : (2) If all argument items are atoms: the sorted sequence of distinct item string values
 : (3) If argument items are both, node and atom items: the sorted sequence of distinct item string values
 :
 : If $ebvMode is 'true', the effective boolean value of the expression value
 : is returned, rather than the expression value itself. 
 :
 : @param union element representing the expression tree
 : @param ebvMode if true, the expression must be resolved to its effective boolean value
 : @return the value of the expression tree node
 :)
declare function f:resolveUnionExpr($union as element(union),
                                    $ebvMode as xs:boolean?,
                                    $context as item()?,
                                    $position as xs:integer?,
                                    $last as xs:integer?,
                                    $vars as map(xs:QName, item()*)?,
                                    $options as map(*)?)                                    
        as item()* {
    let $args := $union/*/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
    let $itemKinds :=
        if (every $arg in $args satisfies $arg instance of node()) then 'nodes'
        else if (every $arg in $args satisfies not($arg instance of node())) then 'atoms'
        else 'mixed'
    let $value := 
        if ($itemKinds eq 'atoms') then
            for $item in distinct-values($args) order by string($item) return $item 
        else if ($itemKinds eq 'nodes') then
            ($args | ())
        else
            let $items := $args ! string(.)
            return
                for $item in distinct-values($items) order by string($item) return $item
    return
        if ($ebvMode) then exists($value)
        else $value
};

(:~
 : Resolves an intersect except expression, provided as an expression tree.
 :
 : @param intersectExcept element representing the expression tree
 : @param ebvMode if true, the expression must be resolved to its effective boolean value
 : @return the value of the expression tree node
 :)
declare function f:resolveIntersectExceptExpr($intersectExcept as element(intersectExcept),
                                              $ebvMode as xs:boolean?,
                                              $context as item()?,
                                              $position as xs:integer?,
                                              $last as xs:integer?,
                                              $vars as map(xs:QName, item()*)?,
                                              $options as map(*)?)                                              
        as item()* {
    let $op := $intersectExcept/@op
    let $args1 := $intersectExcept/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
    let $args2 := $intersectExcept/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
    let $args := ($args1, $args2)    
    let $itemKinds :=
        if (every $arg in $args satisfies $arg instance of node()) then 'nodes'
        else if (every $arg in $args satisfies not($arg instance of node())) then 'atoms'
        else 'mixed'
    let $value := 
        if ($itemKinds eq 'nodes') then
            if ($op eq 'except') then $args1 except $args2
            else $args1 intersect $args2
        else
            let $args1 := if ($itemKinds eq 'atoms') then $args1 else $args1 | string(.)
            let $args2 := if ($itemKinds eq 'atoms') then $args2 else $args2 | string(.)            
            let $values :=
                if ($op eq 'except') then $args1[not(. = $args2)]
                else $args1[. = $args2]
            return
                for $item in distinct-values($values) order by string($item) return $item
    return
        if ($ebvMode) then f:getEbv($value) else $value
};

(: 
 : =================================================================================
 :
 :     r e s o l v e    e x p r e s s i o n s    o n    s e q u e n c e    t y p e s
 :
 : =================================================================================
 :)
 
(:~
 : Resolves an instance of expression.
 :
 : @param instance the expression tree of an instance of expression.
 : @param ebvMode if true, the node must be resolved to its effective boolean value
 : @return the value of the if expression
 :)
declare function f:resolveInstanceOfExpr($instance as element(instance),
                                         $ebvMode as xs:boolean?,
                                         $context as item()?,
                                         $position as xs:integer?,
                                         $last as xs:integer?,
                                         $vars as map(xs:QName, item()*)?,
                                         $options as map(*)?)                                         
        as item()* {
    let $arg := $instance/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
    let $sequenceType := $instance/sequenceType/@text    
    let $expr := concat('declare variable $arg external; $arg instance of ', $sequenceType)
    let $value := i:xquery($expr, map{'arg':$arg})    
    return
        $value
};

(:~
 : Resolves a treat expression.
 :
 : @param instance the expression tree of a treat expression
 : @param ebvMode if true, the node must be resolved to its effective boolean value
 : @return the value of the if expression
 :)
declare function f:resolveTreatExpr($treat as element(treat),
                                    $ebvMode as xs:boolean?,
                                    $context as item()?,
                                    $position as xs:integer?,
                                    $last as xs:integer?,
                                    $vars as map(xs:QName, item()*)?,
                                    $options as map(*)?)                                    
        as item()* {
    let $arg := $treat/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
    let $sequenceType := $treat/sequenceType/@text    
    let $expr := concat('declare variable $arg external; $arg treat as ', $sequenceType)
    let $value := i:xquery($expr, map{'arg':$arg})    
    return
        if ($ebvMode) then f:getEbv($value) else $value
};

(:~
 : Resolves a castable expression.
 :
 : @param instance the expression tree of a castable expression.
 : @param ebvMode if true, the node must be resolved to its effective boolean value
 : @return the value of the if expression
 :)
declare function f:resolveCastableExpr($castable as element(castable),
                                       $ebvMode as xs:boolean?,
                                       $context as item()?,
                                       $position as xs:integer?,
                                       $last as xs:integer?,
                                       $vars as map(xs:QName, item()*)?,
                                       $options as map(*)?)                                       
        as item()* {
    let $arg := $castable/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
    let $singleType := $castable/singleType/@text    
    let $expr := concat('declare variable $arg external; $arg castable as ', $singleType)
    let $value := i:xquery($expr, map{'arg':$arg})    
    return
        $value
};

(:~
 : Resolves a cast expression.
 :
 : @param instance the expression tree of a cast expression
 : @param ebvMode if true, the node must be resolved to its effective boolean value
 : @return the value of the if expression
 :)
declare function f:resolveCastExpr($cast as element(cast),
                                   $ebvMode as xs:boolean?,
                                   $context as item()?,
                                   $position as xs:integer?,
                                   $last as xs:integer?,
                                   $vars as map(xs:QName, item()*)?,
                                   $options as map(*)?)
        as item()* {
    let $arg := $cast/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
    let $singleType := $cast/singleType/@text    
    let $expr := concat('declare variable $arg external; $arg cast as ', $singleType)
    let $value := i:xquery($expr, map{'arg':$arg})    
    return
        if ($ebvMode) then f:getEbv($value) else $value
};

(: 
 : ===============================================================================
 :
 :     r e s o l v e    f u n c t i o n    i t e m
 :
 : ===============================================================================
 :)

declare function f:resolveNamedFunctionRef($funcRef as element(), 
                                           $context as item()?, 
                                           $position as xs:integer?, 
                                           $last as xs:integer?,
                                           $vars as map(xs:QName, item()*)?,
                                           $options as map(*)?)
        as item()* {
    let $funcName := $funcRef/@name
    let $funcItem := $i:STD-FUNC-ITEMS($funcName)
    let $funcItem := i:resolveFuncItemText($funcName)
    return
        if (empty($funcItem)) then 
            f:createFoxpathError('NOT_YET_IMPLEMENTED', 
                concat('Named function reference, name: ', $funcName))
        else $funcItem
};    

(:
 : Resolves a parsed inline function expression to a function item.
 :)
declare function f:resolveInlineFunctionExpression(
                                           $inlineFuncExpr as element(),
                                           $context as item()?, 
                                           $position as xs:integer?, 
                                           $last as xs:integer?,
                                           $vars as map(xs:QName, item()*)?,
                                           $options as map(*)?)
        as item()* {
    if (1 eq 1) then
        f:resolveInlineFunctionExpression_new($inlineFuncExpr, $context, $position, $last, $vars, $options)
    else
    
    let $inlineFuncBody := $inlineFuncExpr/body/*
    let $funcItem :=
       function(
         $mode as xs:string,
         $context as item()?, 
         $position as xs:integer?, 
         $last as xs:integer?, 
         $vars as map(xs:QName, item()*)?) {
      if ($mode eq "tree") then $inlineFuncExpr else         
      $inlineFuncBody/f:resolveFoxpathRC#7(., false(), $context, $position, $last, $vars, $options)
    }
    
    return $funcItem
};    

(:
 : Resolves a parsed inline function expression to a function item.
 :)
declare function f:resolveInlineFunctionExpression_new(
                                           $inlineFuncExpr as element(),
                                           $context as item()?, 
                                           $position as xs:integer?, 
                                           $last as xs:integer?,
                                           $vars as map(xs:QName, item()*)?,
                                           $options as map(*)?)
        as item()* {
    let $inlineFuncBody := $inlineFuncExpr/body/*
    let $nsDecls := $inlineFuncExpr/root()//prolog/nsDecls/*
    let $funcItemText_params :=
        string-join(
            for $param in $inlineFuncExpr/params/param
            let $name := $param/@localName
            let $prefix := $param/@prefix
            let $lexName := string-join($param/(@prefix, @localName), ':')
            let $seqType := $param/sequenceType/concat(' as ', @text)
            return concat('$', $lexName, $seqType)
            , ', ')
    let $funcItemText_result := $inlineFuncExpr/return/sequenceType/concat(' as ', @text)
    
    (: shift parameters into vars map and launch the resolver :)
    (: TODO - if a variable of the signature has a prefix, the EQName must spell out
              the URI
    :)
    let $funcItemText_launch :=
        string-join((
            'let $vars := map:merge((',
            '$varsIn,',
            string-join(
                for $param in $inlineFuncExpr/params/param 
                let $lexName := string-join($param/(@prefix, @localName), ':')
                let $uriString := 
                    if ($param/@namespace) then $param/@namespace/concat('''', ., '''')
                    else '()'
                return 
                    $param
                    /concat('map:entry(QName(', $uriString, ', ''', @localName, '''), $', $lexName, ')')
                , ',&#xA;'),
            '))',
            'let $body := ',
            $inlineFuncExpr/body/*/serialize(.) ,
            'return $resolver($body, false(), (), 1, 1, $vars, $options)'
        ), '&#xA;')
    let $baseURI := static-base-uri()
    let $funcItemText :=
        string-join((
            (: namespace declarations :)
            for $nsDecl in $nsDecls
            return
                if (string($nsDecl/@prefix)) then
                    concat('declare namespace ', $nsDecl/@prefix, '="', $nsDecl/@uri, '";')
                else
                    concat('declare default element namespace "', $nsDecl/@uri, '";'),
                    
            (: variable declarations :)
            'declare variable $varsIn as map(xs:QName, item()*)? external;',        
            'declare variable $options as map(*)? external;',            
            'declare variable $resolver as function(*) external;',
            
            (: function item :)            
            concat('function(', $funcItemText_params, ')', $funcItemText_result), 
            ' {', $funcItemText_launch, '}')
            
        , '&#xA;')
    let $funcItem := xquery:eval($funcItemText, map{'resolver': f:resolveFoxpathRC#7, 'varsIn':$vars, 'options':$options})
    return
        $funcItem
};    

declare function f:resolveInlineFunctionExpression_new_20160903(
                                           $inlineFuncExpr as element(),
                                           $context as item()?, 
                                           $position as xs:integer?, 
                                           $last as xs:integer?,
                                           $vars as map(xs:QName, item()*)?,
                                           $options as map(*)?)
        as item()* {
    let $inlineFuncBody := $inlineFuncExpr/body/*
    let $funcItemText_params := trace(
        string-join(
            for $param in $inlineFuncExpr/params/param
            let $name := $param/@localName
            let $lexName := string-join($param/(@namespace, @localName), ':')
            let $seqType := $param/sequenceType/concat(' as ', @text)
            return concat('$', $lexName, $seqType)
            , ', ') , 'PARAMS: ')
    let $funcItemText_result := $inlineFuncExpr/return/sequenceType/concat(' as ', @text)
    
    (: shift parameters into vars map and launch the resolver :)
    let $funcItemText_launch :=
        string-join((
            'let $vars := map:merge((',
            '$vars,',
            string-join(
                for $param in $inlineFuncExpr/params/param 
                let $lexName := string-join($param/(@namespace, @localName), ':')
                return 
                    $param
                    /concat('map:entry(QName((), ''', @localName, '''), $', $lexName, ')')
                , ',&#xA;'),
            '))',
            'let $body := ',
            $inlineFuncExpr/body/*/serialize(.),
            'return $resolver($body, false(), (), 1, 1, $vars)'
        ), '&#xA;')
    let $baseURI := static-base-uri()
    let $funcItemText := trace(
        string-join((
            'declare variable $resolver as function(*) external;',
            'declare variable $vars as map(*)? external;',            
            concat('function(', $funcItemText_params, ')', $funcItemText_result), 
            ' {', $funcItemText_launch, '}')
        , '&#xA;') , 'FUNCT_ITEM_TEXT: ')

    let $funcItem := xquery:eval($funcItemText, map{})
    (: let $funcItem := xquery:eval($funcItemText, map{'resolver': f:resolveFoxpathRC#6, 'vars':$vars}) :)
    return
        $funcItem
};    

(: 
 : ===============================================================================
 :
 :     r e s o l v e    d y n a m i c    f u n c t i o n    c a l l
 :
 : ===============================================================================
 :)

(:~
 : Resolves a dynamic function call. The function item is determined
 : and the call arguments are inspected. If they do not contain an
 : argument placeholder, they are resolved to values and the dynamic
 : call is executed, otherwise the partial function application is
 : evaluated.
 :)
declare function f:resolveDynFunctionCall($callExpr as element(), 
                                          $context as item()?, 
                                          $position as xs:integer?, 
                                          $last as xs:integer?,
                                          $vars as map(xs:QName, item()*)?,
                                          $options as map(*)?)
        as item()* {
    let $funcExpr := $callExpr/*[1]
    let $argExprs := $callExpr/*[position() gt 1]    
    let $funcItem := $funcExpr/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
    
    (: @TODO@ assignment `isInlineFunction`:
              Find a better way to recognize the use of an inline function expression :)
    (:              
    let $isInlineFunction := 
        $funcItem instance of 
            function(xs:string, item()?, xs:integer, xs:integer, map(*)?, element(nevernever)) as item()*
    :)        
    return
        (:
        if ($isInlineFunction) then
            f:resolveInlineFunctionCall($funcItem, $argExprs, $context, $position, $last, $vars)
        :)
        
        if ($argExprs/self::argPlaceholder) then
            f:resolvePartialFunctionCall($funcItem, $argExprs, $context, $position, $last, $vars, $options)            
        else if (count($argExprs) eq 0) then 
            $funcItem()
        else if (count($argExprs) eq 1) then
            let $arg1 := $argExprs[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                $funcItem($arg1)
        else if (count($argExprs) eq 2) then
            let $arg1 := $argExprs[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $argExprs[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                $funcItem($arg1, $arg2)
        else if (count($argExprs) eq 3) then
            let $arg1 := $argExprs[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $argExprs[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg3 := $argExprs[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            return
                $funcItem($arg1, $arg2, $arg3)
        else
            f:createFoxpathError('NOT_YET_IMPLEMENTED', 
                concat('Dynamic function call with >3 arguments; # arguments: ', count($argExprs)))
};    

(:
(:~
 : Resolves the dynamic call of an inline function expression.
 :)
declare function f:resolveInlineFunctionCall($funcItem as function(*),
                                             $argExprs as element()*,
                                             $context as item()?, 
                                             $position as xs:integer?, 
                                             $last as xs:integer?,
                                             $vars as map(*)?)                                       
        as item()* {
    let $exprTree := $funcItem('tree', $context, $position, $last, $vars)
    let $params := $exprTree/params/param        
    return
        if ($argExprs/self::argPlaceholder) then
            f:resolveInlinePartialFunctionCall($funcItem, $argExprs, $context, $position, $last, $vars)
        else

            let $useVars := map:merge((
                $vars,        
                for $param at $pos in $params
                let $argExpr := $argExprs[$pos]
                let $argValue := $argExpr/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
                let $argName := $param/@localName
                return map:entry($argName, $argValue)    
            ))
            return
                $funcItem('value', $context, $position, $last, $useVars)
};    
:)

(: 
 : ===============================================================================
 :
 :     r e s o l v e    p a r t i a l    f u n c t i o n    c a l l
 :
 : ===============================================================================
 :)

(:~
 : Resolves the dynamic call of an inline function expression.
 :)
declare function f:resolveInlinePartialFunctionCall($funcItem as function(*),
                                                    $argExprs as element()*,
                                                    $context as item()?, 
                                                    $position as xs:integer?, 
                                                    $last as xs:integer?,
                                                    $vars as map(xs:QName, item()*)?,
                                                    $options as map(*)?)
        as item()* {
        
    let $exprTree := $funcItem('tree', $context, $position, $last, $vars, $options)
    let $params := $exprTree/params/param  
    let $return := $exprTree/return
    let $funcBody := $exprTree/body/*
    
    (: construct the context for the dynamic function call;
       contains the variables required for foxpath resolution,
       as well as all arguments which are not placeholders :)
    let $dynCallContext := map:merge((
        $vars, 
        map:entry('resolve', f:resolveFoxpathRC#7),        
        map:entry('inlineFuncBody', $funcBody),        
        map:entry('context', $context),
        map:entry('position', $position),
        map:entry('last', $last),
        map:entry('vars', $vars),
        map:entry('options', $options),
        
        for $argExpr at $pos in $argExprs
        let $argName := $params[$pos]/@localName
        where not($argExpr/self::argPlaceholder)
        return
            let $argValue := $argExpr/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return map:entry($argName, $argValue)
    ))

    (: construct the external variables of the dynamic function call: 
          declare variable $foo external;
          declare variable $bar external;          
     :)
    let $variableDeclarations := string-join((
        for $argExpr at $pos in $argExprs
        let $paramName := $params[$pos]/@localName
        where not($argExpr/self::argPlaceholder)
        return
            concat('declare variable $', $paramName, ' external;')
        ), '&#xA;')            

    (: construct parameter declarations of the inline function item:
          $foo as xs:string
          $bar as xs:integer?
     :)
    let $paramDeclarations := 
        let $raw :=
            string-join((
                for $param in $params
                let $paramName := $param/@localName
                let $sequenceType := $param/sequenceType/@text/concat(' as ', .)
                return
                    concat('$', $paramName, $sequenceType)        
            ), ',&#xA;           ')
        return
            concat($raw, ')')
            
    (: construct the return declaration:
          as xs:integer*
    :)            
    let $returnDeclaration := $return/sequenceType/@text/concat(' as ', .)
 
    (: construct the code transferring argument values into the $vars map
           let $useVars := map:put($useVars, "foo", $foo)
           let $useVars := map:put($useVars, "bar", $bar)
    :)
    let $paramTransfer := string-join((
        for $argExpr at $pos in $argExprs
        let $paramName := $params[$pos]/@localName
        (: where not($argExpr/self::argPlaceholder) :)
        return
            concat('let $useVars := map:put($useVars, "', $paramName, '", $', $paramName, ')')        
        ), '&#xA;    ')            

    (: construct the argument list used within the dynamic function call,
       contains arguments and placeholders:
           $x, ?, $z
     :)
    let $args := string-join((
        for $argExpr at $pos in $argExprs
        let $argName := $params[$pos]/@localName
        return
            if ($argExpr/self::argPlaceholder) then '?'
            else concat('$', $argName)
        ), ', ')            


    (: construct the text of an expression which ...
       (a) defines a "synthetic" inline function which ...
           (a1) receives the followgin parameters:
              (a11) a function item providing the evaluation of an expression tree ($resolve)
              (a12) the expression tree of the original inline function body ($inlineFuncBody)
              (a13) the "generic" parameters required for the evaluation of an expression tree
                    ($context, $position, $last, $vars)              
              (a14) the parameters defined by the original inline function
           (a2) updates the $vars map with all (non-placeholder) parameters
           (a3) invokes evaluation of the expression tree of the original inline function body
       (b) calls the synthetic inline function, passing to it the appropriate mixture of 
           arguments and placeholders
    :)
    let $dynCallText := 
``[declare variable $resolve external;
declare variable $inlineFuncBody external;
declare variable $context external;
declare variable $position external;
declare variable $last external;
declare variable $vars external;
declare variable $options external;
`{$variableDeclarations}`

let $funcItem :=
  function($resolve as function(*),
           $inlineFuncBody as element(),
           $context as item()?,
           $position as xs:integer?,
           $last as xs:integer?,
           $vars as map(xs:QName, item()*)?,
           $options as map(*)?,
           `{$paramDeclarations}`
 `{$returnDeclaration}`              
  {
    let $useVars := if (exists($vars)) then $vars else map{}
    `{$paramTransfer}`
    return
      $resolve($inlineFuncBody, false(), $context, $position, $last, $useVars, $options)
}
return
  $funcItem($resolve, $inlineFuncBody, $context, $position, $last, $vars, $options, `{$args}`)
]`` ! replace(., '&#xD;', '')    
    return
        xquery:eval($dynCallText, $dynCallContext)
};    

(:~ 
 : Resolve a partial function call to its value which is
 : a function item.
 :)
declare function f:resolveStaticPartialFunctionCall($call as element(), 
                                                    $context as item()?, 
                                                    $position as xs:integer?, 
                                                    $last as xs:integer?,
                                                    $vars as map(xs:QName, item()*)?,
                                                    $options as map(*)?)
        as item()* {      
    let $funcName := $call/@name
    let $args := $call/*
    return
        f:resolvePartialFunctionCall($funcName, $args, $context, $position, $last, $vars, $options)
};

(:~ 
 : Resolve a partial function call to its value which is
 : a function item.
 :)
declare function f:resolvePartialFunctionCall($funcNameOrItem as item(),
                                              $args as element()*,
                                              $context as item()?, 
                                              $position as xs:integer?, 
                                              $last as xs:integer?,
                                              $vars as map(xs:QName, item()*)?,
                                              $options as map(*)?)
        as item()* {   
    (: *TODO* Currently, the expression text used to resolve the partial
     : function call uses hard-coded variable names for the arguments
     : and the function item ($arg1, ..., $argn, $___function); 
     : however, these names may be used by the current variable context and 
     : must not be overwritten; therefore, the names used for the expression 
     : variables must be dynamically determined so that name clashed are 
     : relyably avoided.)
     :)
     
    let $funcItem :=
        if ($funcNameOrItem instance of function(*)) then $funcNameOrItem
        else ()
    let $funcRef := 
        if (exists($funcItem)) then '$___function' else $funcNameOrItem    
    let $countArgs := count($args)    
    
    (: create the context map, containing the bindings of all 
     : non-placeholder arguments. :)
    let $context := map:merge(
        for $arg at $pos in $args
        where not($arg/self::argPlaceholder)
        return
            let $name := 'arg' || $pos
            let $value := $arg/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return map:entry($name, $value)
    )
    (: create the required variable declarations :)
    let $declareVariables :=
        string-join((
            map:keys($context) ! concat('declare variable $', ., ' external;'),
            if (empty($funcItem)) then () else 'declare variable $___function external;'
            ), '&#xA;'
        )
        
    (: compose the expression text :)
    let $exprText :=
        concat(
            $declareVariables, '&#xA;',
            $funcRef, '(',
            string-join(
                for $argNr in 1 to $countArgs
                let $argName := 'arg' || $argNr
                return
                    if (map:contains($context, $argName)) then '$' || $argName
                    else '?'
                , ', '),
            ')')
            
    (: insert the context entries (non-placeholder arguments) into the 
    :  variable map, possibly overwriting entries :) 
    let $vars := if (exists($vars)) then $vars else map{}
    let $f := function($accum, $key) {map:put($accum, $key, $context($key))}    
    let $useContext :=
        let $updatedVars := fold-left(map:keys($context), $vars, $f)
        return
            if (empty($funcItem)) then $updatedVars
            else map:put($updatedVars, '___function', $funcItem)    
    return
        (: evaluate the synthesized query which yields the function item :)
        f:xquery($exprText, $useContext)

};

(: 
 : ===============================================================================
 :
 :     r e s o l v e    s t a t i c    f u n c t i o n    c a l l
 :
 : ===============================================================================
 :)

declare function f:resolveFunctionCall($call as element(), 
                                       $context as item()?, 
                                       $position as xs:integer?, 
                                       $last as xs:integer?,
                                       $vars as map(xs:QName, item()*)?,
                                       $options as map(*)?)                                       
        as item()* {
    if ($call/argPlaceholder) then 
        f:resolveStaticPartialFunctionCall($call, $context, $position, $last, $vars, $options)
        
    (: special case - as function `resolveFoxpath` must not be called from
       an imported module, it is called from here
    :)
    else if ($call/@name = ('resolve-foxpath', 'fox')) then
        let $expression := 
        let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
        return
            ($explicit, $context)[1]
        return
(:
declare function f:resolveFoxpath($foxpath as xs:string, 
                                  $ebvMode as xs:boolean?, 
                                  $context as xs:string?,
                                  $options as map(*)?,
                                  $externalVariableBindings as map(xs:QName, item()*)?)
:)
            i:resolveFoxpath($expression, false(), $context, $options, ())
        
    else
        i:resolveStaticFunctionCall($call, $context, $position, $last, $vars, $options)
};      

(: 
 : ===============================================================================
 :
 :     r e s o l v e    v a r i a b l e    r e f e r e n c e s
 :
 : ===============================================================================
 :)
 
 (:~
 : Resolves a variable reference.
 :
 : @param varSpec structured representation of the variable reference
 : @vars a map providing the the names and values of the currently bound variables
 :)
declare function f:getVarValue($varSpec as element(var), 
                               $vars as map(xs:QName, item()*)?, 
                               $options as map(*)?)
        as item()* {       
    let $varName := $varSpec/@localName
    let $varNamespace := $varSpec/@namespace    
    let $varQname := QName($varNamespace, $varName)
    return
        if (empty($vars) or not(map:contains($vars, $varQname))) then
            (: several artificial variable names, defined for test purposes :)
            if (matches($varName, '^value_[\d.]+$')) then
                number(substring($varName, 7))
            else if (matches($varName, '^string_.*$')) then
                substring($varName, 8)
            else if (matches($varName, '^string_$')) then
                ''
            else if (matches($varName, '^empty')) then
                ()
            else        
                error(QName((), 'UNEXPECTED_VARIABLE_NAME'), 
                    concat('Unexpected variable name: ', $varQname))        
        else        
            let $valueFromMap := $vars($varQname)
            return
                $valueFromMap
};

(: 
 : ===============================================================================
 :
 :     u t i l i t y    f u n c t i o n s
 :
 : ===============================================================================
 :)
 
(:~
 : Determines the effective boolean value of a value.
 :
 : @param value the value for which the effective boolean value is determined
 : @return the effective boolean value
 :)
declare function f:getEbv($value as item()*)
        as xs:boolean {
    boolean($value[1])        
};

declare function f:pattern2Regex($pattern as xs:string)
        as xs:string {
    concat('^', 
           replace(replace($pattern, '\.', '\\.'), '\*', '.*'), 
           '$')        
};
