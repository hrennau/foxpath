module namespace f="http://www.ttools.org/xquery-functions";
import module namespace i="http://www.ttools.org/xquery-functions" 
at "foxpath-processorDependent.xqm";

import module namespace util="http://www.ttools.org/xquery-functions/util" 
at  "foxpath-util.xqm";

declare variable $f:FOXSTEP_SEPERATOR := '/';
declare variable $f:NODESTEP_SEPERATOR := '\';
declare variable $f:FOXSTEP_ESCAPE := '~';
declare variable $f:FOXSTEP_NAME_DELIM := '`';
declare variable $f:URI_TREES_DIRS external := 'basex://uri-trees2';

(: declare variable $f:URI_TREES_DIRS := 'uri-trees'; :)

(:~
 : Parses a foxpath expression, creating an expression tree.
 : For all supported parsing options, the default value is
 : assumed.
 :
 : @param text the expression text
 : @return expression tree representing the expression text
 :)
declare function f:parseFoxpath($text as xs:string?)
        as element()+ {
    f:parseFoxpath($text, ())
};

(:~
 : Parses a foxpath expression, creating an expression tree.
 : This variant of the parsing function switches optimization off.
 :
 : @param text the expression text
 : @return expression tree representing the expression text
 :)
declare function f:parseFoxpath_noOptimization($text as xs:string?)
        as element()+ {        
    f:parseFoxpath($text, map{'SKIP_OPTIMIZATION': true()})
};

(:~
 : Parses a foxpath expression, creating an expression tree.
 : Some parsing details are controlled by options:
 :
 : IS_CONTEXT_URI 
 : = true() => the top-level expression is evaluated in a mode
 :             which assumes the context item to be a URI; this
 :             implies that a name test without axis is interpreted
 :             as a fox name test, not a node name test.
 : FOXSTEP_SEPERATOR 
 : The character used to seperate fox steps; default: /
 :
 : NODESTEP_SEPERATOR 
 : The character used to seperate node steps; default: \
 :
 : @param text the expression text
 : @param options parsing options
 : @return expression tree representing the expression text
 :)
declare function f:parseFoxpath($text as xs:string?, $options as map(*)?)
        as element()+ {    
    let $DEBUG := util:trace($text, 'parse.text.foxpath', 'INTEXT_FOXPATH: ')
    let $context := f:getInitialParsingContext($options)
    let $prologEtc := f:parseProlog($text, $context)
    let $prolog := $prologEtc[. instance of node()]
    let $errors := util:finalizeFoxpathErrors($prolog/descendant-or-self::error)
    return
        if ($errors) then $errors else        
    let $textAfter := f:extractTextAfter($prologEtc)
    
    let $seqExprEtc := util:trace(f:parseSeqExpr($textAfter, $context) , 'tree', 'PARSED: ')   
    let $textAfter := f:extractTextAfter($seqExprEtc)    
    let $seqExpr := $seqExprEtc[. instance of node()]
    let $errors := util:finalizeFoxpathErrors($seqExpr/descendant-or-self::error)        
    return
        if ($errors) then $errors
        else if ($textAfter) then
            util:finalizeFoxpathErrors(
                util:createFoxpathError('SYNTAX_ERROR', 
                    concat('Unexpected text after expression end: ', $textAfter)))                    
        else
            let $nsDecls := $prolog/nsDecls
            let $exprTree := 
                let $finalized := f:finalizeParseTree($seqExpr, $prolog)
                return
                    if (exists($options) and map:get($options, 'SKIP_OPTIMIZATION')) then 
                        $finalized
                    else
                        f:finalizeParseTree_annotateSteps($finalized) !
                        f:finalizeParseTree_extendFoxRoots(.)

            let $errors := util:finalizeFoxpathErrors($exprTree/descendant-or-self::error)            
            return
                if ($errors) then $errors 
                else
                    <foxpathTree>{
                        $prolog,
                        $exprTree
                    }</foxpathTree>
};

(: 
 : ===============================================================================
 :
 :     p r e p a r e    p a r s i n g
 :
 : ===============================================================================
 :)
(:~
 : Constructs the initial context, using option values when supplied, and
 : default values otherwise.
 :
 : @param options parsing options
 : @return the initial parsing context
 :)
declare function f:getInitialParsingContext($options as map(*)?)
        as map(*) {
    let $isContextUri :=
        ($options ! map:get(., 'IS_CONTEXT_URI') eq true(), false())[1]
    let $foxstepSeperator :=
        ($options ! map:get(., 'FOXSTEP_SEPERATOR'), $f:FOXSTEP_SEPERATOR)[1]
    let $nodestepSeperator :=
        ($options ! map:get(., 'NODESTEP_SEPERATOR'), $f:NODESTEP_SEPERATOR)[1]
    let $foxstepEscape :=
        ($options ! map:get(., 'FOXSTEP_ESCAPE'), $f:FOXSTEP_ESCAPE)[1]
    let $foxstepNameDelim :=
        ($options ! map:get(., 'FOXSTEP_NAME_DELIM'), $f:FOXSTEP_NAME_DELIM)[1]
    let $uriTreesDirs :=
        ($options ! map:get(., 'URI_TREES_DIRS'), $f:URI_TREES_DIRS)[1]
        
    let $foxstepSeperatorRegex := replace($foxstepSeperator, '(\\)', '\\$1')
    let $nodestepSeperatorRegex := replace($nodestepSeperator, '(\\)', '\\$1')
    
(:    
    let $uriTrees :=
        if (starts-with($uriTreesDir, 'basex://')) then
            let $db := trace(substring($uriTreesDir, 9) , 'DB: ')
            return db:open($db)
        else
            try {
                file:list($uriTreesDir, false(), 'uri-trees-*') ! concat($uriTreesDir, '/', .) ! doc(.)/*
            } catch * {()}
    let $DUMMY := trace(count($uriTrees), 'COUNT_URI_TREES: ')
:)    
    return
        map{'FOXSTEP_SEPERATOR': $foxstepSeperator,
            'FOXSTEP_SEPERATOR_REGEX': $foxstepSeperatorRegex,
            'NODESTEP_SEPERATOR': $nodestepSeperator,
            'NODESTEP_SEPERATOR_REGEX': $nodestepSeperatorRegex,
            'FOXSTEP_ESCAPE': $foxstepEscape,
            'FOXSTEP_NAME_DELIM': $foxstepNameDelim,
            'IS_CONTEXT_URI': $isContextUri,           
            'URI_TREES_DIRS': $uriTreesDirs
        }
};
            (: 'URI_TREES': $uriTrees}:) 
(: 
 : ===============================================================================
 :
 :     f i n a l i z e    p a r s i n g    r e s u l t
 :
 : ===============================================================================
 :)
declare function f:finalizeParseTree($tree as element(), $prolog as element()?)
        as element() {
    (: add namespaces :)        
    let $nsDecls := $prolog/nsDecls
    let $tree := (: if (not($nsDecls)) then $tree else :) 
        f:finalizeParseTree_namespaces($tree, $prolog)
    return
        $tree
};

declare function f:finalizeParseTree_namespaces($tree as element(), $prolog as element()?)
        as element() {
    f:finalizeParseTree_namespacesRC($tree, $prolog)        
};

declare function f:finalizeParseTree_namespacesRC($n as node(), $prolog as element()?)
        as node()? {
    typeswitch($n)
    case document-node() return
        document {for $c in $n/node() return f:finalizeParseTree_namespacesRC($n, $prolog)}
    case element(step) return
        let $namespace :=
            if ($n/@namespace) then ()
            else if ($n/@prefix) then
                let $prefix := $n/@prefix
                let $uri := $prolog/nsDecls/namespace[@prefix eq $prefix]/@uri
                let $uri :=
                    if ($uri) then $uri
                    else $util:PREDECLARED_NAMESPACES[@prefix eq $prefix]/@uri
                return
                    if (not($uri)) then
                        util:createFoxpathError('SYNTAX_ERROR',
                            concat('Prefix not bound to a namespace URI: ', $prefix))
                    else
                        attribute namespace {$uri}
            else if ($n/@localName ne '*') then
                $prolog/nsDecls/namespace[@prefix eq '']/@uri/attribute namespace {.}
            else ()
        return
            if ($namespace/self::error) then $namespace
            else
                element {node-name($n)} {
                    for $a in $n/@* return 
                        f:finalizeParseTree_namespacesRC($a, $prolog),
                    $namespace,
                    for $c in $n/node() return 
                        f:finalizeParseTree_namespacesRC($c, $prolog)
                }                        
    case element(var) | element(param) return
        let $namespace :=
            if ($n/@namespace) then ()
            else if ($n/@prefix) then
                let $prefix := $n/@prefix
                let $uri := $prolog/nsDecls/namespace[@prefix eq $prefix]/@uri
                return
                    if (not($uri)) then
                        util:createFoxpathError('SYNTAX_ERROR',
                            concat('Prefix not bound to a namespace URI: ', $prefix))
                    else
                        attribute namespace {$uri}
            else ()
        return
            if ($namespace/self::error) then $namespace
            else
                element {node-name($n)} {
                    for $a in $n/@* return 
                        f:finalizeParseTree_namespacesRC($a, $prolog),
                    $namespace,
                    for $c in $n/node() return 
                        f:finalizeParseTree_namespacesRC($c, $prolog)
                }                        
    case element() return
        element {node-name($n)} {
            for $a in $n/@* return f:finalizeParseTree_namespacesRC($a, $prolog),
            for $c in $n/node() return f:finalizeParseTree_namespacesRC($c, $prolog)
        }
    default return
        $n
};

declare function f:finalizeParseTree_annotateSteps($tree as element())
        as element() {
    f:finalizeParseTree_annotateStepsRC($tree)        
};

(:~
 : Annotatation of steps: a foxstep with a predicate 'is-file' or 'is-dir' is annotated
 : with a @nodeKind attribute.
 :)
declare function f:finalizeParseTree_annotateStepsRC($n as node())
        as node()? {
    typeswitch($n)
    case document-node() return
        document {for $c in $n/node() return 
            f:finalizeParseTree_annotateStepsRC($n)}
    case element(foxStep) return
        (: if a predicate prescrites 'is-file' or 'is-dir', 
           @kindFilter is set to 'file' or 'dir' :)
        let $kindFilterAtt :=
            let $fcall := $n/functionCall[@name = ('is-file', 'is-dir')]
            let $arg := $fcall/*            
            return
                if (not($arg) or $arg/self::contextItem) then 
                    attribute kindFilter {$fcall/@name/substring(., 4)}
                else ()
        let $wasChildAtt :=
            if (f:finalizeParseTree_isShortcut_doubleSlashChild($n/preceding-sibling::*[1], $n)) then
                attribute __anno {'was-child'}
            else ()
        let $ignoreAtt :=
            if (f:finalizeParseTree_isShortcut_doubleSlashChild($n, $n/following-sibling::*[1])) then
                attribute __ignore {'true'}
            else ()
        return
            if (not($wasChildAtt)) then
                element {node-name($n)} {
                    for $a in $n/@* return f:finalizeParseTree_annotateStepsRC($a),
                    $ignoreAtt,
                    (: the predicate because of BaseX bug ...:)
                    $kindFilterAtt[string()],
                    for $c in $n/node() return f:finalizeParseTree_annotateStepsRC($c)
                }
            else                
                element {node-name($n)} {
                    attribute axis {'descendant'},
                    $wasChildAtt,                
                    for $a in $n/(@* except @axis) return f:finalizeParseTree_annotateStepsRC($a),
                    (: the predicate because of BaseX bug ...:)
                    $kindFilterAtt[string()],
                    for $c in $n/node() return f:finalizeParseTree_annotateStepsRC($c)
                }
    case element(functionCall) return
        let $ignAtt :=
            if ($n/@name = ('is-file', 'is-dir') and $n/parent::foxStep and (not($n/*) or $n/contextItem)) then
                attribute __ignore {'true'}
            else ()
        return
            element {node-name($n)} {
                for $a in $n/@* return f:finalizeParseTree_annotateStepsRC($a),
                $ignAtt[string()],
                for $c in $n/node() return f:finalizeParseTree_annotateStepsRC($c)
            }
        
    case element() return
        element {node-name($n)} {
            for $a in $n/@* return f:finalizeParseTree_annotateStepsRC($a),
            for $c in $n/node() return f:finalizeParseTree_annotateStepsRC($c)            
        }
    default return $n            
};

(:~
 : Returns true if the two foxsteps stem from //foo and foo has no predicate referring 
 :    to it position.
 :)
declare function f:finalizeParseTree_isShortcut_doubleSlashChild($foxStep1 as element()?, $foxStep2 as element()?)
        as xs:boolean {
    $foxStep1/self::foxStep[@axis eq 'descendant-or-self'][@name eq '*'][not(*)]
       and 
    $foxStep2/self::foxStep/@axis eq 'child'
       and (
    not($foxStep2/*) or 
       count($foxStep2/*) eq 1 and $foxStep2/functionCall[@name = ('is-file', 'is-dir')]
    )
} ;       

(:~
 : Finalizes parse tree - replaces child steps by an extension of the path root.
 :)
declare function f:finalizeParseTree_extendFoxRoots($tree as element())
        as element() {
    (: if (not($tree//foxRoot[starts-with(@path, 'svn-')])) then $tree else :)

    copy $treec := $tree
    modify
        let $roots := $treec//foxRoot
        (: let $roots_svn := $roots[starts-with(@path, 'svn-')] :)       
        for $root in $roots
        let $childSteps :=
            let $after := 
                $root/following-sibling::*[not(self::foxStep) 
                                           or not(@axis eq 'child') 
                                           or matches(@name, '[*?]')
                                           or *][1]
            return
                $root/following-sibling::*[not($after) or . << $after]
        return 
            if (not($childSteps)) then ()
            else
                let $newPath := 
                    string-join((replace($root/@path, '/$', ''), $childSteps/@name), '/')
                return (
                    replace value of node $root/@path with $newPath,
                    delete nodes $childSteps
                )                
    return $treec
};


(: 
 : ===============================================================================
 :
 :     p a r s e    p r o l o g
 :
 : ===============================================================================
 :)
 
(:~
 : Parses the prolog of a foxpath expression.
 :
 : Syntax:
 :     Prolog ::= VarDecl*
 :     VarDecl ::= "declare" "variable" "$" VarName TypeDeclaration? 
 :                           ((":=" VarValue) | ("external" (":=" VarDefaultValue)?))
 :                           ";" 
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseProlog($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.prolog', 'INTEXT_PROLOG: ')
    
    (: parse namespace declarations :)
    let $nsDeclsEtc := f:parseNsDecls($text, $context)
    let $nsDecls := $nsDeclsEtc[. instance of node()]
    (: let $nsDecls := f:completeNsDecls($nsDecls) :)
    let $errors := $nsDecls/self::error
    return
        if ($errors) then $errors else        
    let $textAfterNsDecls := f:extractTextAfter($nsDeclsEtc)
    
    (: parse variable declarations :)
    let $varDeclsEtc := f:parseVarDecls($textAfterNsDecls, $context)
    let $varDecls := $varDeclsEtc[. instance of node()]
    let $errors := $varDecls/self::error
    return
        if ($errors) then $errors else
    let $textAfterVarDecls := f:extractTextAfter($varDeclsEtc)
    
    return (
        if (not($nsDecls) and not($varDecls)) then ()
        else 
            <prolog>{
                if (not($nsDecls)) then () else
                    <nsDecls>{$nsDecls}</nsDecls>,
                if (not($varDecls)) then () else
                    <varDecls>{$varDecls}</varDecls>
            }</prolog>,
        $textAfterVarDecls
    )        
};

(:~
 : Extends the parsed namespace bindings by built-in namespace bindings.
 :)
(:
declare function f:completeNsDecls($nsDecls as element(namespace)*)
        as element(namespace)* {
    $nsDecls,        
    (: add namespace: rdfs :)
    if ($nsDecls/@prefix = 'rdfs') then () else
        <namespace prefix="rdfs" uri="http://www.w3.org/2000/01/rdf-schema#"/>,
    (: add namespace: rdf :)        
    if ($nsDecls/@prefix = 'rdf') then () else
        <namespace prefix="rdf" uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>,
    (: add namespace: owl :)
    if ($nsDecls/@prefix = 'owl') then () else
        <namespace prefix="owl" uri="http://www.w3.org/2002/07/owl#"/>
};
:)

(:~
 : Parses the namespace declarations.
 :)
declare function f:parseNsDecls($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.ns_decls', 'INTEXT_NS_DECLS: ')
    let $nsDeclEtc := f:parseNsDecl($text, $context)
    let $nsDecl := $nsDeclEtc[. instance of node()]
    let $textAfterNsDecl := f:extractTextAfter($nsDeclEtc)
    return (
        $nsDecl,
        if (matches($textAfterNsDecl, 
            '^(declare\s+default\s+element\s+namespace |
               declare\s+namespace\s+)', 'sx')) then
            f:parseNsDecls($textAfterNsDecl, $context)
        else
            $textAfterNsDecl
    )            
};

(:~
 : Parses a single namespace declaration.
 :)
declare function f:parseNsDecl($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.ns_decl', 'INTEXT_NS_DECL: ') return
    
    (: default namespace declaration :)
    if (matches($text, '^declare\s+default\s+element\s+namespace\s+')) then
        let $textNamespaceEtc :=
            replace($text, '^declare\s+default\s+element\s+namespace\s+(.+)', '$1', 'sx')
                [not(. eq $text)]
        return
            let $namespaceEtc := f:parseStringLiteral($textNamespaceEtc, $context)
            let $namespace := $namespaceEtc[. instance of node()]
            let $textAfterNamespace := f:extractTextAfter($namespaceEtc)
            return
                if (not($namespace)) then
                    util:createFoxpathError('SYNTAX_ERROR',
                        concat('Invalid default namespace declaration - ',
                            'URIliteral expected; text: ', $text))
                else if (not(starts-with($textAfterNamespace, ';'))) then                        
                    util:createFoxpathError('SYNTAX_ERROR',
                        concat('Syntax error - default namespace declaration must be followed ',
                            'by semicolon; text: ', $text))
                else
                    let $textAfterNsDecl := f:skipOperator($textAfterNamespace, ';')
                    return (
                        <namespace prefix="" uri="{$namespace}"/>,
                        $textAfterNsDecl                        
                    )
    (: namespace declaration :)                        
    else 
        let $prefixAndNamespaceText :=
            replace($text,
                '^declare\s+namespace\s+(\i[\c-[:]]*)\s*=\s*(.*)', '$1 $2', 'sx')[. ne $text]
        return
            if (not($prefixAndNamespaceText)) then $text
            else
                let $prefix := substring-before($prefixAndNamespaceText, ' ')
                let $textNamespaceEtc := substring-after($prefixAndNamespaceText, ' ')
                let $namespaceEtc := f:parseStringLiteral($textNamespaceEtc, $context)
                let $namespace := $namespaceEtc[. instance of node()]
                let $textAfterNamespace := f:extractTextAfter($namespaceEtc)
                return
                    if (not($namespace)) then
                        util:createFoxpathError('SYNTAX_ERROR',
                            concat('Invalid namespace declaration - pattern ',
                                'prefix = URIliteral expected; text: ', $text))                        
                    else if (not(starts-with($textAfterNamespace, ';'))) then                        
                        util:createFoxpathError('SYNTAX_ERROR',
                            concat('Syntax error - default namespace declaration must be followed ',
                                'by semicolon; text: ', $text))
                    else 
                        let $textAfterNsDecl := f:skipOperator($textAfterNamespace, ';')
                        return (
                            <namespace prefix="{$prefix}" uri="{$namespace}"/>,
                            $textAfterNsDecl
                        )                            
};

(:~
 : Parses the variable declarations.
 :)
declare function f:parseVarDecls($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.var_decls', 'INTEXT_VAR_DECLS: ')
    let $varDeclEtc := f:parseVarDecl($text, $context)
    let $varDecl := $varDeclEtc[. instance of node()]
    let $textAfterVarDecl := f:extractTextAfter($varDeclEtc)
    return (
        $varDecl,
        if (matches($textAfterVarDecl, '^declare\s+variable\s+\$', 's')) then
            f:parseVarDecls($textAfterVarDecl, $context)
        else
            $textAfterVarDecl
    )            
};

(:~
 : Parses a single variable declaration.
 :)
declare function f:parseVarDecl($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.var_decl', 'INTEXT_VAR_DECL: ')
    
    let $eqnameEtcText := 
        replace($text, '^declare\s+variable\s+(\$.+)$', '$1', 's')[. ne $text] 
    return
        if (not($eqnameEtcText)) then $text else
       
    let $eqnameEtc := f:parseVarName($eqnameEtcText, $context)
    let $eqname := $eqnameEtc[. instance of node()]
    let $textAfterEqname := f:extractTextAfter($eqnameEtc)
    
    (: normalization - if no sequence type specified, add 'item()*' :)
    let $useTextAfterEqname :=
        if (matches($textAfterEqname, '^as\s', 's')) then $textAfterEqname
        else concat('as item()* ', $textAfterEqname)
    let $seqTypeEtc := f:parseParamSequenceType($useTextAfterEqname, $context)
    let $seqType := $seqTypeEtc[. instance of node()]
    let $textAfterSeqType := f:extractTextAfter($seqTypeEtc)
    return    
        (: not external :)
        if (starts-with($textAfterSeqType, ':=')) then
            let $textAfterOperator := f:skipOperator($textAfterSeqType, ':=')
            let $valueEtc := f:parseSeqExpr($textAfterOperator, $context)
            let $value := $valueEtc[. instance of node()]
            let $textAfterValue := f:extractTextAfter($valueEtc)
            return
                if (not($value)) then 
                    util:createFoxpathError('SYNTAX_ERROR',
                        concat('Syntax error - variable declaration contains ',
                            'invalid value expression; var name: ', $eqname/@localName))                
                else if (not(starts-with($textAfterValue, ';'))) then
                    util:createFoxpathError('SYNTAX_ERROR',
                        concat('Syntax error - variable declaration must be followed ',
                            'by semicolon; var name: ', $eqname/@localName))
                else
                    let $textAfterVarDecl := f:skipOperator($textAfterValue, ';')
                    return (
                        <varDecl external="false">{
                            $eqname/(@* except @text),
                            $seqType,
                            $value
                        }</varDecl>,
                        $textAfterVarDecl
                    )
                        
        (: external :)                        
        else if (starts-with($textAfterSeqType, 'external')) then
            let $textAfterExternal := f:skipOperator($textAfterSeqType, 'external')
            return
                (: with default value :)            
                if (starts-with($textAfterExternal, ':=')) then
                    let $textAfterOperator := f:skipOperator($textAfterExternal, ':=')
                    let $valueEtc := f:parseSeqExpr($textAfterOperator, $context)
                    let $value := $valueEtc[. instance of node()]
                    let $textAfterValue := f:extractTextAfter($valueEtc)
                    return
                        if (not($value)) then
                            util:createFoxpathError('SYNTAX_ERROR',
                                concat('Syntax error - external variable declaration ',
                                    'contains invalid default value expression; ',
                                    'var name: ', $eqname/@localName))               
                        else if (not(starts-with($textAfterValue, ';'))) then
                            util:createFoxpathError('SYNTAX_ERROR',                        
                                concat('Syntax error - external variable declaration must ',
                                    'be followed by semicolon; var name: ', $eqname/@localName))               
                        else
                            let $textAfterVarDecl := f:skipOperator($textAfterValue, ';')
                            return (
                                <varDecl external="true">{
                                    $eqname/(@* except @text),
                                    $seqType,
                                    $value
                                }</varDecl>,
                                $textAfterVarDecl
                            )
                                
                else if (not(starts-with($textAfterExternal, ';'))) then
                    util:createFoxpathError('SYNTAX_ERROR',                
                        concat('Syntax error - external variable declaration must be followed ',
                            'by semicolon; var name: ', $eqname/@localName))
                (: without default value :)                        
                else
                    let $textAfterVarDecl := f:skipOperator($textAfterExternal, ';')
                    return (
                        <varDecl external="true">{
                            $eqname/(@* except @text),
                            $seqType
                        }</varDecl>,
                        $textAfterVarDecl
                    )
        else
            util:createFoxpathError('SYNTAX_ERROR',                
                concat('Syntax error - in a variable declaration, name and optional ',
                    'sequence type must be followed either by ":=" or by "external"; ',
                    'var name: ', $eqname/@localName))
        
};

(: 
 : ===============================================================================
 :
 :     p a r s e    s e q u e n c e   /  e x p r S i n g l e
 :
 : ===============================================================================
 :)


(:~
 : Parses a sequence expression. A sequence expression consists of
 : one or more single expressions seperated by ",".
 :
 : Syntax:
 :     SeqExpr ::= ExprSingle ("," ExprSingle)* 
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseSeqExpr($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_SEQ: ') return        
    let $seqExprEtc := f:parseSeqExprRC($text, $context)
    let $seqExpr := $seqExprEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($seqExprEtc)        
    return (
        if (count($seqExpr) lt 2) then $seqExpr 
        else <seq>{$seqExpr}</seq>,
        $textAfter
    )        
};

(:~
 : Recursive helper function of `parseSeqExpr`.
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseSeqExprRC($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_SEQ_RC: ') return
    let $termOp := ','
    let $exprSingleEtc := f:parseExprSingle($text, $context)
    let $exprSingle := $exprSingleEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($exprSingleEtc)        
    return (
        $exprSingle,        

        if (starts-with($textAfter, $termOp)) then 
             let $textAfterOperator := f:skipOperator($textAfter, $termOp)
             return 
                f:parseSeqExprRC($textAfterOperator, $context)
        else 
            $textAfter
    )        
};

(:~
 : Parses a single expression. A single expression is one of these: for expression,
 : quantified expression, if expression, or expression.
 :
 : Syntax:
 :     ExprSingle ::= ForExpr
 :                    | LetExpr
 :                    | QuantifiedExpr
 :                    | IfExpr
 :                    | OrExpr 
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseExprSingle($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_EXPR_SINGLE: ') return
    let $forLetExprEtc := f:parseForLetExpr($text, $context)
    return
        if (exists($forLetExprEtc)) then
            let $forLetExpr := $forLetExprEtc [. instance of node()]
            let $textAfter := f:extractTextAfter($forLetExprEtc)
            return ($forLetExpr, $textAfter)
        else 
            let $quantExprEtc := f:parseQuantifiedExpr($text, $context)
            return
                if (exists($quantExprEtc)) then
                    let $quantExpr := $quantExprEtc [. instance of node()]
                    let $textAfter := f:extractTextAfter($quantExprEtc)
                    return ($quantExpr, $textAfter)
                else
                    let $ifExprEtc := f:parseIfExpr($text, $context)
                    return
                        if (exists($ifExprEtc)) then
                            let $ifExpr := $ifExprEtc[. instance of node()]
                            let $textAfter := f:extractTextAfter($ifExprEtc)
                            return ($ifExpr, $textAfter)
                        else
                            f:parseOrExpr($text, $context)
};

(: 
 : ===============================================================================
 :
 :     p a r s e    f o r   /   q u a n t i f i e d   /   i f
 :
 : ===============================================================================
 :)

(:~
 : Parses a simple FLWOR expression consisting of for and/or let clauses and
 : a return clause. Note that whereas XPath allows only a single for or let
 : clause, foxpath allows multiple for and/or let clauses, as XQuery does.
 :
 : @param text the text to be parsed
 : @param context the parsing context
 : @return the parsed FLWOR expression followed by the remaining unparsed text
 :)
declare function f:parseForLetExpr($text as xs:string, $context as map(*))
        as item()* {
    let $DEBUG := util:trace($text, 'parse.for_let_expr', 'INTEXT_FOR_LET_EXPR: ') return
    if (not(matches($text, '^(for|let)\s+\$'))) then () else
    
    let $clauseKind := replace($text, '^(for|let).*', '$1', 's')
    
    let $textVarBindingsEtc := replace($text, concat('^', $clauseKind, '\s+'), '')
    let $varBindingsEtc := f:parseVarBindings($textVarBindingsEtc, $clauseKind, $context)
    let $varBindings := $varBindingsEtc[. instance of node()]
    let $textAfterVarBindings := f:extractTextAfter($varBindingsEtc)
    return
        (: the for|let clauses must be followed by "return";
           if not, we are not dealing with a valid for|let expression 
           => return empty sequence :)
        if (not(starts-with($textAfterVarBindings, 'return'))) then ()
        else
            let $textReturnEtc := f:skipOperator($textAfterVarBindings, 'return')
            let $returnEtc := f:parseExprSingle($textReturnEtc, $context)
            let $return := $returnEtc[. instance of node()]
            let $textAfterReturn := f:extractTextAfter($returnEtc)
            return (
                <flwor>{
                    $varBindings,
                    $return
                }</flwor>
                ,
                $textAfterReturn
            )
};

(:~
 : Parses the variable binding clauses of a for, let or quantified expression.
 :
 : Syntax:
 :     VarBindings ::= SimpleForBinding (, SimpleForBinding)*
 :                     | SimpleLetBinding (, SimpleLetBinding)*
 :     SimpleForBinding ::= "$" VarName "in" ExprSingle
 :     SimpleLetBinding ::= "$" VarName ":=" ExprSingle
 :
 : @param text a text consisting of the variable bindings, followed by further text
 : @param clauseKind either "for" or "let"
 : @return expression tree representing the variable binding clauses,
 :    followed by the remaining unparsed text
 :)
declare function f:parseVarBindings($text as xs:string, $clauseKind as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.var_bindings', 'INTEXT_VAR_BINDINGS: ') return
    let $op := if ($clauseKind eq 'for') then 'in' else ':='
    
    let $varNameEtc := f:parseVarName($text, $context)
    let $varName := $varNameEtc[. instance of node()]
    let $textAfterVarName := f:extractTextAfter($varNameEtc)    
    let $exprEtcText := f:skipOperator($textAfterVarName, $op)
    let $exprEtc := f:parseExprSingle($exprEtcText, $context)    
    let $expr := $exprEtc[. instance of node()]
    let $textAfterExpr := f:extractTextAfter($exprEtc)
    let $clause :=
        element {$clauseKind}{
            <var>{$varName/(@localName, @prefix, @namespace)}</var>,
            $expr
        }
    return (
        $clause,
        if (starts-with($textAfterExpr, ',')) then
            let $textRemainingClauses := f:skipOperator($textAfterExpr, ',')
            return
                f:parseVarBindings($textRemainingClauses, $clauseKind, $context)

        else if (matches($textAfterExpr, '^(for|let)\s+\$')) then    
            let $clauseKind := replace($textAfterExpr, '^(for|let).*', '$1', 's')    
            let $textVarBindingsEtc := replace($textAfterExpr, concat('^', $clauseKind, '\s+'), '')
            return
                f:parseVarBindings($textVarBindingsEtc, $clauseKind, $context)
        else 
            $textAfterExpr
    )
};

(:~
 : Parses a quantified expression. If the text does not start with a 
 : quantified expression, the empty sequence is returned.
 :
 : Syntax:
 :     QuantifiedExpr  ::= ("some"|"every") "$" VarName "in" ExprSingle
 :                         ("," "$" VarName "in" ExprSingle)* "satisfies" ExprSingle
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
 declare function f:parseQuantifiedExpr($text as xs:string, $context as map(*))
        as item()* {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_QUANTIFIED_EXPR: ') return    
    if (not(matches($text, '^(some|every)\s+\$'))) then () else
    
    let $quantKind := replace($text, '^(some|every).*', '$1') 
    let $textVarBindingsEtc := replace($text, '^(some|every)\s+', '')
    let $varBindingsEtc := f:parseVarBindings($textVarBindingsEtc, 'for', $context)
    let $varBindings := $varBindingsEtc[. instance of node()]
    let $textAfterVarBindings := f:extractTextAfter($varBindingsEtc)
    return
        (: the clauses must be followed by "satisfies";
           if not, we are not dealing with a valid quantified expression 
           => return empty sequence :)
        if (not(starts-with($textAfterVarBindings, 'satisfies'))) then ()
        else
            let $textSatisfiesEtc := f:skipOperator($textAfterVarBindings, 'satisfies')
            let $satisfiesEtc := f:parseExprSingle($textSatisfiesEtc, $context)
            let $satisfies := $satisfiesEtc[. instance of node()]
            let $textAfterSatisfies := f:extractTextAfter($satisfiesEtc)
            return (
                <quantified kind="{$quantKind}">{
                    $varBindings,
                    $satisfies
                }</quantified>,
                $textAfterSatisfies
            )
};

(:~
 : Parses an if expression. If the text does not start with an if expression, 
 : the empty sequence is returned.
 :
 : Syntax:
 :     IfExpr  ::= "if" "(" Expr ")" "then" ExprSingle "else" ExprSingle
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseIfExpr($text as xs:string, $context as map(*))
        as item()* {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_IF_EXPR: ') return    
    if (not(matches($text, '^if\s+\('))) then () else
    
    let $textCondExprEtc := replace($text, '^if\s+\((.*)', '$1')
    let $condExprEtc := f:parseSeqExpr($textCondExprEtc, $context)
    let $condExpr := $condExprEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($condExprEtc)
    return
        if (not(matches($textAfter, '^\)\s+then\s'))) then
            ()
        else
            let $textThenExprEtc := replace($textAfter, '^\)\s+then\s+', '')
            let $thenExprEtc := f:parseExprSingle($textThenExprEtc, $context)
            let $thenExpr := $thenExprEtc[. instance of node()]
            let $textAfter := f:extractTextAfter($thenExprEtc)
            return
                if (not(starts-with($textAfter, 'else'))) then ()
                else
                    let $textElseExprEtc := replace($textAfter, '^else\s+', '')
                    let $elseExprEtc := f:parseExprSingle($textElseExprEtc, $context)
                    let $elseExpr := $elseExprEtc[. instance of node()]
                    let $textAfter := f:extractTextAfter($elseExprEtc)
                    let $parsed := <if>{$condExpr, $thenExpr, $elseExpr}</if>
                    return ($parsed, $textAfter)
};

(: 
 : ===============================================================================
 :
 :     p a r s e    o r  /  a n d
 :
 : ===============================================================================
 :)

(:~
 : Parses an or expression. An or expression consists of
 : one or more and expressions seperated by '||'.
 :
 : Syntax:
 :     OrExpr ::= AndExpr ("or" AndExpr )* 
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseOrExpr($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_OR: ') return        
    let $orEtc := f:parseOrExprRC($text, $context)
    let $or := $orEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($orEtc)        
    return (
        if (count($or) lt 2) then $or else
            <or>{$or}</or>,
        $textAfter
    )        
};

(:~
 : Recursive helper function of 'parseOrExpr'.
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseOrExprRC($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_OR_RC: ') return        
    let $andEtc := f:parseAndExpr($text, $context)
    let $and := $andEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($andEtc)        
    return (
        $and,        
        let $textAfterOperator :=
            if (starts-with($textAfter, 'or')) then replace(substring($textAfter, 3), '^\s+', '')
            else ()
        return
            if ($textAfterOperator) then f:parseOrExprRC($textAfterOperator, $context)
            else $textAfter
    )        
};

(:~
 : Parses an and expression. And and expression consists of one
 : or more particles seperated by '&&'. 
 :
 : Syntax:
 :     AndExpr ::= RelationalExpr (('&&'|'and') RelationalExpr)*
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseAndExpr($text as xs:string, $context as map(*))
        as item()+ {
    let $andEtc := f:parseAndExprRC($text, $context)
    let $and := $andEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($andEtc) 
    return (
        if (count($and) lt 2) then $and else
            <and>{$and}</and>,
        $textAfter
    )        
};

(:~
 : Recursive helper function of 'parseAndExpr'.
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseAndExprRC($text as xs:string, $context as map(*))
        as item()+ {
    let $compExprEtc := f:parseComparisonExpr($text, $context)
    let $compExpr := $compExprEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($compExprEtc)    
    return (
        $compExpr,  
        let $textAfterOperator := 
            if (starts-with($textAfter, 'and')) then replace(substring($textAfter, 4), '^\s+', '')
            else ()
        return
            if ($textAfterOperator) then f:parseAndExprRC($textAfterOperator, $context)
            else $textAfter
    )        
};

(: 
 : ===============================================================================
 :
 :     p a r s e    c o m p a r i s o n  /  r a n g e
 :
 : ===============================================================================
 :)

(:~
 : Parses a comparison expression.
 :
 : Syntax:
 :     RangeExpr ( (ValueComp
 :     | GeneralComp
 :     | NodeComp) RangeExpr )?
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :) 
declare function f:parseComparisonExpr($text as xs:string, $context as map(*))
        as item()+ {
    let $nodeComp := "(is|<<|>>)"        
    let $nodeCompMatch := "(is\s|<<|>>)"
    
    (: let $generalComp := "(=|!=|<=|<|>=|>|~~~|~~|~)" :)
    let $generalComp := "(=|!=|<=|<|>=|>)"
    let $generalCompMatch := "(=|!=|<=|<|>=|>)"
    
    let $valueComp := "(eq|ne|lt|le|gt|ge)"
    let $valueCompMatch := "(eq|ne|lt|le|gt|ge)\s"
    
    let $leftExprEtc := f:parseStringConcatExpr($text, $context)
    let $leftExpr := $leftExprEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($leftExprEtc)    
    return 
        if (matches($textAfter, concat('^', $nodeCompMatch))) then            
            let $op := replace($textAfter, concat('^(', $nodeComp, ').*'), '$1', 's')
            let $textAfterOp := f:skipOperator($textAfter, $op)
            let $rightExprEtc := f:parseStringConcatExpr($textAfterOp, $context)
            let $rightExpr := $rightExprEtc[. instance of node()]
            let $textAfter2 := f:extractTextAfter($rightExprEtc)
            return (
                <cmpN op="{$op}">{
                    $leftExpr,
                    $rightExpr
                }</cmpN>,
                $textAfter2
            )
        (: note the whitespace required behind the operator :)
        else if (matches($textAfter, concat('^', $valueCompMatch))) then
            let $op := replace($textAfter, concat('^(', $valueComp, ').*'), '$1', 's')
            let $textAfterOp := f:skipOperator($textAfter, $op)
            let $rightExprEtc := f:parseStringConcatExpr($textAfterOp, $context)
            let $rightExpr := $rightExprEtc[. instance of node()]
            let $textAfter2 := f:extractTextAfter($rightExprEtc)
            return (
                <cmpV op="{$op}">{
                    $leftExpr,
                    $rightExpr
                }</cmpV>,
                $textAfter2
            )
        else if (matches($textAfter, concat('^', $generalCompMatch))) then            
            let $op := replace($textAfter, concat('^(', $generalComp, ').*'), '$1', 's')
            let $textAfterOp := f:skipOperator($textAfter, $op)
            let $rightExprEtc := f:parseStringConcatExpr($textAfterOp, $context)
            let $rightExpr := $rightExprEtc[. instance of node()]
            let $textAfter2 := f:extractTextAfter($rightExprEtc)
            return (
                <cmpG op="{$op}">{
                    $leftExpr,
                    $rightExpr
                }</cmpG>,
                $textAfter2
            )
        else
            ($leftExpr, $textAfter)
};

(:~
 : Parses a string concat expression.
 :
 : Syntax:
 :     RangeExpr ( "||" RangeExpr )*
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :) 
declare function f:parseStringConcatExpr($text as xs:string, $context as map(*))
        as item()+ {
    let $operandsEtc := f:parseStringConcatExprRC($text, $context)
    let $operands := $operandsEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($operandsEtc) 
    return (
        if (count($operands) lt 2) then $operands else
            <functionCall name="concat">{$operands}</functionCall>,
        $textAfter
    )        
};

(:~
 : Recursive helper function of 'parseStringConcatExpr'.
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseStringConcatExprRC($text as xs:string, $context as map(*))
        as item()+ {
    let $op := '||'
    let $rangeExprEtc := f:parseRangeExpr($text, $context)
    let $rangeExpr := $rangeExprEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($rangeExprEtc)    
    return (
        $rangeExpr,  
        if (starts-with($textAfter, $op)) then
            let $textAfterOp := f:skipOperator($textAfter, $op)
            return
                f:parseStringConcatExprRC($textAfterOp, $context)    
        else $textAfter
    )
};

(:~
 : Parses a range expression.
 :
 : Syntax:
 :     AdditiveExpr ( "to" AdditiveExpr )?
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :) 
declare function f:parseRangeExpr($text as xs:string, $context as map(*))
        as item()+ {
    let $rangeOperator := "to"
    
    let $leftExprEtc := f:parseAdditiveExpr($text, $context)
    let $leftExpr := $leftExprEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($leftExprEtc)    
    return 
        if (matches($textAfter, concat('^', $rangeOperator))) then    
            let $textAfterOp := f:skipOperator($textAfter, $rangeOperator)
            let $rightExprEtc := f:parseRangeExpr($textAfterOp, $context)
            let $rightExpr := $rightExprEtc[. instance of node()]
            let $textAfter2 := f:extractTextAfter($rightExprEtc)
            return (
                <range>{
                    $leftExpr,
                    $rightExpr
                }</range>,
                $textAfter2
            )
        else
            ($leftExpr, $textAfter)
};

(: 
 : ===============================================================================
 :
 :     p a r s e    a d d i t i v e  /  m u l t i p l i c a t i v e
 :
 : ===============================================================================
 :)

(:~
 : Parses an additive expression.
 :
 : Syntax:
 :     AdditiveExpr ::= MultiplicativeExpr (('+' | '-') MultiplicativeExpr)*
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :) 
declare function f:parseAdditiveExpr($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_ADDITIVE: ')        
    let $multiplicativeEtc := f:parseMultiplicativeExpr($text, $context)
    let $multiplicative := $multiplicativeEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($multiplicativeEtc)    
    return
        if (not($textAfter)) then $multiplicative
        else f:parseAdditiveExprRC($textAfter, $multiplicative, $context)
};

(:~
 : Recursive helper function of `parseAdditiveExpr`.
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseAdditiveExprRC($text as xs:string, $leftOperand as element(), $context as map(*))
        as item()+ {
    let $operator := replace($text, '^(\+|-).*', '$1', 's')[not(. eq $text)]
    return
        if (not($operator)) then ($leftOperand, $text)
        else
            let $textAfterOperator := replace(substring($text, 1 + string-length($operator)), '^\s+', '')        
            let $multiplicativeEtc := f:parseMultiplicativeExpr($textAfterOperator, $context)
            let $multiplicative := $multiplicativeEtc[. instance of node()]
            let $textAfter := f:extractTextAfter($multiplicativeEtc)            
            let $additiveExpr :=
                <additive op="{$operator}">{    
                    $leftOperand,
                    $multiplicative
                }</additive>
            return
                if ($textAfter) then 
                    f:parseAdditiveExprRC($textAfter, $additiveExpr, $context)
                else 
                    $additiveExpr
};

(:~
 : Parses a multiplicative expression.
 :
 : Syntax:
 :     Multiplicative ::= UnionExpr (("*" | "div" | "idiv" | "mod") UnionExpr)*
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :) 
declare function f:parseMultiplicativeExpr($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_MULTIPLICATIVE: ')        
    let $unionExprEtc := f:parseUnionExpr($text, $context)
    let $unionExpr := $unionExprEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($unionExprEtc)    
    return 
        if (not($textAfter)) then $unionExpr
        else f:parseMultiplicativeExprRC($textAfter, $unionExpr, $context)
};

(:~
 : Recursive helper function of `parseMultiplicativeExpr`.
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseMultiplicativeExprRC($text as xs:string, $leftOperand as element(), $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_MULTIPLICATIVE_RC: ')        
    let $operator := replace($text, '^(\*|div|idiv|mod).*', '$1', 's')[not(. eq $text)]
    return
        if (not($operator)) then ($leftOperand, $text)
        else
            let $textAfterOperator := f:skipOperator($text, $operator)        
            let $unionExprEtc := f:parseUnionExpr($textAfterOperator, $context)
            let $unionExpr := $unionExprEtc[. instance of node()]
            let $textAfter := f:extractTextAfter($unionExprEtc)            
            let $multiplicativeExpr :=
                <multiplicative op="{$operator}">{    
                    $leftOperand,
                    $unionExpr
                }</multiplicative>
            return
                if ($textAfter) then
                    f:parseMultiplicativeExprRC($textAfter, $multiplicativeExpr, $context)
                else
                    $multiplicativeExpr
};

(: 
 : ===============================================================================
 :
 :     p a r s e    u n i o n   /   i n t e r s e c t   /   
 :                  e x c e p t   /   u n a r y
 :
 : ===============================================================================
 :)

(:~
 : Parses a union expression.
 :
 : Syntax:
 :     UnionExpr ::= IntersectExceptExpr ( ( "union" | "|" ) IntersectExceptExpr )* 
 :
 : @param text the expression text, possibly followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseUnionExpr($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.union', 'INTEXT_UNION: ')        
    let $unionOperandsEtc := f:parseUnionExprRC($text, $context)
    let $unionOperands := $unionOperandsEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($unionOperandsEtc)    
    return (
        if (count($unionOperands) lt 2) then $unionOperands else
            <union>{$unionOperands}</union>,
        $textAfter
    )        
};

(:~
 : Recursive helper function of `parseUnionExpr`.
 :
 : @param text the expression text, possibly followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseUnionExprRC($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.union_rc', 'INTEXT_UNION_RC: ')        
    let $intersectExceptExprEtc := f:parseIntersectExceptExpr($text, $context)
    let $intersectExceptExpr := $intersectExceptExprEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($intersectExceptExprEtc)    
    let $followingOperand :=
        if (starts-with($textAfter, 'union')) then 'union'
        else if (matches($textAfter, '^\|[^|]')) then '|'
        else ()  
    return (
        $intersectExceptExpr,        
        if (not($followingOperand)) then $textAfter 
        else
            let $textAfter := f:skipOperator($textAfter, $followingOperand)
            return
                f:parseUnionExprRC($textAfter, $context)
    )        
};

(:~
 : Parses an intersect except expression.
 :
 : Syntax:
 :     IntersectExceptExpr ::= InstanceOfExpr (("intersect" | "except") InstanceOfExpr)*
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :) 
declare function f:parseIntersectExceptExpr($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_INTERSECT_EXCEPT: ')        
    let $instanceOfExprEtc := f:parseInstanceOfExpr($text, $context)
    let $instanceOfExpr := $instanceOfExprEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($instanceOfExprEtc)    
    return
        if (not($textAfter)) then $instanceOfExpr
        else f:parseIntersectExceptExprRC($textAfter, $instanceOfExpr, $context)
};

(:~
 : Recursive helper function of `parseIntersectExceptExpr`.
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseIntersectExceptExprRC($text as xs:string, $leftOperand as element(), $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_INTERSECT_EXCEPT_RC: ')        
    let $operator := replace($text, '^(intersect|except).*', '$1', 's')[not(. eq $text)]
    return
        if (not($operator)) then ($leftOperand, $text)
        else
            let $textAfterOperator := replace(substring($text, 1 + string-length($operator)), '^\s+', '')        
            let $instanceOfExprEtc := f:parseInstanceOfExpr($textAfterOperator, $context)
            let $instanceOfExpr := $instanceOfExprEtc[. instance of node()]
            let $textAfter := f:extractTextAfter($instanceOfExprEtc)            
            let $intersectExceptExpr :=
                <intersectExcept op="{$operator}">{    
                    $leftOperand,
                    $instanceOfExpr
                }</intersectExcept>
            return
                if ($textAfter) then 
                    f:parseIntersectExceptExprRC($textAfter, $intersectExceptExpr, $context)
                else 
                    $intersectExceptExpr
};

(:~
 : Parses an arrow expression.
 :
 : Syntax:
 :     ArrowExpr ::= UnaryExpr ( "=>" ArrowFunctionSpecifier ArgumentList )*
 :     ArrowFunctionSpecifier ::= EQName | VarRef | ParenthesizedExpr
 :
 : @param text the text to be parsed
 : @return a structured representation of the arrow expression,
 :    followed by the remaining unparsed text
 :) 
declare function f:parseArrowExpr($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.arrow', 'INTEXT_ARROW: ')
    let $unaryExprEtc := f:parseUnaryExpr($text, $context)
    let $unaryExpr := $unaryExprEtc[. instance of node()]
    let $textAfterUnary := f:extractTextAfter($unaryExprEtc)   
    return
        if (not(starts-with($textAfterUnary, '=>'))) then
            ($unaryExpr, $textAfterUnary)
        else            
            let $clausesEtc := f:parseArrowExprClauses($textAfterUnary, $context)
            let $clauses := $clausesEtc[. instance of node()]
            let $textAfterClauses := f:extractTextAfter($clausesEtc)
            let $exprTree := f:foldArrowExpr($unaryExpr, $clauses)
            return (
                $exprTree,
                $textAfterClauses
            )
};

(:~
 : Folds an arrow expr into a function call with the first argument being provided
 : by the left-hand side expression. The expression providing the function call is
 : the first child of the clause, and further arguments are the children of the
 : `argumentList` child of the clause.
 : 
 : Example:
 :)
declare function f:foldArrowExpr($lhsExpr as element(), $clauses as element()*)
        as element() {      
    let $head := head($clauses)
    let $tail := tail($clauses)
    let $headFolded :=
        if ($head/@kind eq 'EQName') then
            <functionCall name="{$head/name/@localName}">{
                $head/(@localName, @prefix, @uri),
                $lhsExpr,
                $head/argumentList/*
            }</functionCall>
        else
            <dynFuncCall>{
                $head/*[1],
                $lhsExpr,
                $head/argumentList/*
            }</dynFuncCall>
     return
        if ($tail) then f:foldArrowExpr($headFolded, $tail)
        else $headFolded            
};        

(:~
 : Parses the righthand-side clauses of an arrow expression.
 :
 : Syntax:
 :     ArrowClauses ::= ( "=>" ArrowFunctionSpecifier ArgumentList )*
 :     ArrowFunctionSpecifier ::= EQName | VarRef | ParenthesizedExpr
 :
 : @param text the text to be parsed
 : @return a structured representation of the arrow expression,
 :    followed by the remaining unparsed text
 :) 
declare function f:parseArrowExprClauses($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.arrow_clauses', 'INTEXT_ARROW_CLAUSES: ')
    return if (not(starts-with($text, '=>'))) then $text else
        
    let $textAfterArrow := f:skipOperator($text, '=>')
    let $clauseEtc :=
        let $nameEtc := f:parseEQName($textAfterArrow, $context)
        let $name := $nameEtc[. instance of node()]
        return
            if (not($name)) then () else
                let $textAfterName := f:extractTextAfter($nameEtc)
                return
                    if (not(starts-with($textAfterName, '('))) then () else
                        let $argumentListEtc := f:parseArgumentList($textAfterName, $context)
                        let $argumentList := $argumentListEtc[. instance of node()]
                        let $textAfterArgumentList := f:extractTextAfter($argumentListEtc)
                        return (
                            <arrayClause kind="EQName">{
                                $name,                                
                                <argumentList>{$argumentList}</argumentList>
                            }</arrayClause>,
                            $textAfterArgumentList
                        )
    let $clauseEtc := if ($clauseEtc) then $clauseEtc else  
        let $varRefEtc := f:parseVariableRef($textAfterArrow, $context)        
        let $varRef := $varRefEtc[. instance of node()]
        return
            if (not($varRef)) then () else
                let $textAfterVarRef := f:extractTextAfter($varRefEtc)
                return
                    if (not(starts-with($textAfterVarRef, '('))) then () else
                        let $argumentListEtc := f:parseArgumentList($textAfterVarRef, $context)
                        let $argumentList := $argumentListEtc[. instance of node()]
                        let $textAfterArgumentList := f:extractTextAfter($argumentListEtc)
                        return ( 
                            <arrayClause kind="varRef">{
                                $varRef,                                
                                <argumentList>{$argumentList}</argumentList>
                            }</arrayClause>,
                            $textAfterArgumentList
                            )
    let $clauseEtc := if ($clauseEtc) then $clauseEtc else
        let $parenthEtc := f:parseParenthesizedExpr($textAfterArrow, $context)        
        let $parenth := $parenthEtc[. instance of node()]
        return
            if (not($parenth)) then () else
                let $textAfterParenth := f:extractTextAfter($parenthEtc)
                return
                    if (not(starts-with($textAfterParenth, '('))) then () else
                        let $argumentListEtc := f:parseArgumentList($textAfterParenth, $context)
                        let $argumentList := $argumentListEtc[. instance of node()]
                        let $textAfterArgumentList := f:extractTextAfter($argumentListEtc)
                        return ( 
                            <arrayClause kind="parenthesizedExpr">{
                                $parenth,                                
                                <argumentList>{$argumentList}</argumentList>
                            }</arrayClause>,
                            $textAfterArgumentList
                        )
    let $clause := $clauseEtc[. instance of node()]
    let $textAfterClause := f:extractTextAfter($clauseEtc)    
    return
        if (not($clause)) then $text
        else (
            $clause[. instance of node()],
            if (starts-with($textAfterClause, '=>')) then
                f:parseArrowExprClauses($textAfterClause, $context)
            else
               $textAfterClause
        )                    
};

(:~
 : Parses a unary expression.
 :
 : Syntax:
 :     Unary ::= ("-" | "+")* PathExpr
 :
 : @param text the text to be parsed
 : @return a structured representation of the unary expression,
 :    followed by the remaining unparsed text
 :) 
declare function f:parseUnaryExpr($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.unary', 'INTEXT_UNARY: ')    
    let $signChars := replace($text, '^([\-+\s]+).*', '$1', 's')[. ne $text]
    return
        if (not($signChars)) then f:parseMapExpr($text, $context)
        else      
            let $countMinus := string-length(replace($signChars, '[^\-]', ''))
            let $sign:= 
                if ($countMinus mod 2 eq 1) then '-' else '+'
            let $textMapExprEtc := substring($text, 1 + string-length($signChars))
            let $mapExprEtc := f:parseMapExpr($textMapExprEtc, $context)
            let $mapExpr := $mapExprEtc[. instance of node()]
            let $textAfterMap := f:extractTextAfter($mapExprEtc)
            return (
                <unary op="{$sign}">{$mapExpr}</unary>,
                $textAfterMap
            )
};

(:~
 : Parses a simple map expression. A simple map expression consists of one 
 : or more path expressions seperated by '!'.
 :
 : Syntax:
 :     SimpleMapExpr ::= PathExpr ("!" PathExpr )* 
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseMapExpr($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_MAP: ') return        
    let $operandsEtc := f:parseMapExprRC($text, $context)
    let $operands := $operandsEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($operandsEtc)        
    return (
        if (count($operands) lt 2) then $operands else
            <map>{$operands}</map>,
        $textAfter
    )        
};

(:~
 : Recursive helper function of 'parseMapExpr'.
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseMapExprRC($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_MAP_RC: ') return
    let $operator := "!"
    let $pathExprEtc := f:parsePathExpr($text, $context)
    let $pathExpr := $pathExprEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($pathExprEtc)        
    return (
        $pathExpr,        
        if (matches($textAfter, '^![^=]')) then
            let $textAfterOperator := f:skipOperator($textAfter, $operator)
            
            (: update context - context is URI if the current operand is
               a foxpath expression whose terminal step is a foxStep expression :)
            let $newContext :=
                let $isContextUri := exists($pathExpr/self::foxpath/*[last()]/self::foxStep)
                return
                    if ($isContextUri eq map:get($context, 'IS_CONTEXT_URI')) then $context
                    else
                        map:put($context, 'IS_CONTEXT_URI', $isContextUri)
            return
                f:parseMapExprRC($textAfterOperator, $newContext)
        else
            $textAfter
    )
};

(: 
 : ===============================================================================
 :
 :     p a r s e    p a t h 
 :
 : ===============================================================================
 :)

(:~
 : Parses a path expression. 
 :
 : Syntax:
 :     PathExpr         ::= ( ("/" | DriveLetter ":/") RelativePathExpr?)
 :                          | (("//" | DriveLetter "://") RelativePathExpr)
 :                          | RelativePathExpr
 :     DriveLetter      ::= [a-zA-Z]
 :     RelativePathExpr ::= StepExpr ( ("/" | "//") StepExpr)*
 :     StepExpr         ::= PostfixExpr | AxisStep
 :     PostfixExpr      ::= PrimaryExpr (Predicate | ArgumentList)*
 :     AxisStep         ::= (ReverseStep | ForwardStep) PredicateList
 :     PrimaryExpr      ::= Literal
 :                          | VarRef
 :                          | ParenthesizedExpr
 :                          | ContextItemExpr
 :                          | FunctionCall
 :                          | FunctionItemExpression
 :)     
declare function f:parsePathExpr($text as xs:string, $context as map(*))
        as item()* {
    (: hjr, 20180112 - exclude confusion with FLWOR expression :)
    if (matches($text, '^(let|for)\s+\$')) then $text else
    
    let $DEBUG := util:trace($text, 'parse.path', 'INTEXT_PATH: ')   
    let $FOXSTEP_SEPERATOR_REGEX := map:get($context, 'FOXSTEP_SEPERATOR_REGEX')
    let $NODESTEP_SEPERATOR_REGEX := map:get($context, 'NODESTEP_SEPERATOR_REGEX')    
    let $FOXSTEP_SEPERATOR := map:get($context, 'FOXSTEP_SEPERATOR')
    let $NODESTEP_SEPERATOR := map:get($context, 'NODESTEP_SEPERATOR')
    
    (: parse initial root step (/ or \) 
       ================================ :) 
    let $root :=
        if (starts-with($text, 'http://')) then 
            <foxRoot path="http://"/>        
        else if (starts-with($text, 'https://')) then 
            <foxRoot path="https://"/>        
        else if (matches($text, '^rdf-file://.:/')) then 
            <foxRoot path="{replace($text, '^(rdf-file://.:/).*', '$1')}"/>        
        else if (starts-with($text, 'basex:/')) then
            let $rootUri := replace($text, '^(basex:/+).*', '$1')
            return
                <foxRoot path="basex://"/>        
        else if (matches($text, 'svn-(file|https?):/+')) then
            let $repoPath := replace($text, 'svn-(.*?:/+[^/]*).*', '$1')
            return
                if (not($repoPath)) then error(QName((), 'INVALID_SVN_PATH'), concat('Path does not address SVN repo: ', $text))
                else <foxRoot path="{concat('svn-', $repoPath, '/')}"/>        
        else if (matches($text, concat('^[a-zA-Z]:', $FOXSTEP_SEPERATOR_REGEX))) then 
            let $path := replace(substring($text, 1, 3), '\\', '/')
            return <foxRoot path="{$path}"/>
        else if (starts-with($text, $FOXSTEP_SEPERATOR)) then <foxRoot path="/"/>
        else if (starts-with($text, $NODESTEP_SEPERATOR)) then <root/>
        else ()

    (: parse steps etc
       =============== :) 
    let $stepsEtc :=
    
        (: startHerePrefix = ./ or .\ :)
        let $startHerePrefix :=
            replace($text, 
                concat('^(\.\s*(', $FOXSTEP_SEPERATOR_REGEX, '|', $NODESTEP_SEPERATOR_REGEX, ')).*'), 
                '$1', 'sx')[not(. eq $text)]

        let $textSteps :=
            replace(
                let $rootPath := $root/self::foxRoot/@path
                return
                    if ($rootPath eq 'basex://') then replace($text, '^basex:/+(.*)', '$1')
                    else if ($rootPath) then substring($text, 1 + string-length($rootPath))
                else if ($root/self::root) then substring($text, 2)
                else if ($startHerePrefix) then substring($text, 1 + string-length($startHerePrefix))
                else $text
            , '^\s+', '')[string()]
    
        (: 
           update context component IS_CONTEXT_URI:
             if the initial operator is \: true 
             if the initial operator is /: false
             otherwise: IS_CONTEXT_URI from context of the parent expression
               
           if true: the first step cannot be a node axis step, and the shortcut 
             syntax for foxstep names is accepted;
           if false: the first step may be a node axis step or a fox axis step; 
             if the first step is a fox axis step without explicit fox axis, 
             it must not use abbreviated syntax, as this cannot be disambiguated 
             from a node axis step; consider the path foo - if IS_CONTEXT_URI is 
             false, it would be interpreted as a node axis step, not a fox axis step.
        :)
        let $isContextUri :=
            if ($root/self::foxRoot) then true()
            else if ($root/self::root) then false()
            else if ($startHerePrefix) then 
                $FOXSTEP_SEPERATOR eq substring($startHerePrefix, string-length($startHerePrefix))
            else map:get($context, 'IS_CONTEXT_URI')
                
        (: update context component 'IS_CONTEXT_URI' :)        
        let $newContext :=
            if ($isContextUri eq map:get($context, 'IS_CONTEXT_URI')) then $context
            else map:put($context, 'IS_CONTEXT_URI', $isContextUri)
     
        let $precedingOperator := 
            if ($root/self::foxRoot) then $FOXSTEP_SEPERATOR
            else if ($root/self::root) then $NODESTEP_SEPERATOR
            else ()
            
        return
            f:parseSteps($textSteps, $precedingOperator, $newContext)
    
    let $steps := $stepsEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($stepsEtc)
    
    (: parse tree
       ========== :)    
    let $parsed :=
        if ($root or count($steps) > 1 or 
            $steps[1]/self::foxStep/@axis or 
            $steps[1]/self::step/@axis) 
        then
            let $exprText :=
                let $raw :=
                    if (not($textAfter)) then $text
                    else
                        let $exprTextLen := string-length($text) - string-length($textAfter)
                        return substring($text, 1, $exprTextLen)
                let $raw := replace($raw, '^\s+', '')
                let $raw := replace($raw, '&#xA;', ' ')
                return
                    replace($raw, 
                            concat($NODESTEP_SEPERATOR_REGEX, 'descendant-or-self::node()', 
                                   $NODESTEP_SEPERATOR_REGEX),
                            concat($NODESTEP_SEPERATOR, $NODESTEP_SEPERATOR))                            
                            (: $NODESTEP_SEPERATOR_REGEX) :)
                            (: changed: 20160813, hjr :)
            return
                <foxpath>{
                    attribute context {i:currentDirectory()}[not($root)],
                    attribute text {$exprText},
                    $root,
                    $steps
                }</foxpath>
        else
            $steps
    return (
        $parsed,
        $textAfter
    )
};

(:~
 : Parses the steps of a foxpath.
 :
 : Syntax:
 :     RelativePathExpr ::= StepExpr ( ("/" | "//") StepExpr)*
 :     StepExpr         ::= PostfixExpr | AxisStep
 :     AxisStep         ::= ReverseStep | ForwardStep) PredicateList
 :     PostfixExpr       ::= PrimaryExpr (Predicate | ArgumentList)*
 :     PrimaryExpr      ::= Literal
 :                          | VarRef
 :                          | ParenthesizedExpr
 :                          | ContextItemExpr
 :                          | FunctionCall
 :                          | FunctionItemExpr
 :
 : @param text the text to be parsed
 : @param precedingOp either a foxpath seperator, a node path seperator, or the empty sequence
 : @return a structured representation of the steps,
 :    followed by the remaining unparsed text
 :)
declare function f:parseSteps($text as xs:string?, 
                              $precedingOperator as xs:string?,
                              $context as map(*))
        as item()* {
    if (not($text)) then () else
    
    let $DEBUG := util:trace($text, 'parse.steps', 'INTEXT_STEPS: ')
    let $FOXSTEP_SEPERATOR := map:get($context, 'FOXSTEP_SEPERATOR')
    let $NODESTEP_SEPERATOR := map:get($context, 'NODESTEP_SEPERATOR')
    
    (: let $precedingOperator := () :)
    let $stepEtc := f:parseStep($text, $precedingOperator, $context)
    let $step := $stepEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($stepEtc)   
    let $textAfterChar1 := substring($textAfter, 1, 1)
    return (
        $step,
        if (not($textAfterChar1 = ($FOXSTEP_SEPERATOR, $NODESTEP_SEPERATOR))) then 
            $textAfter
        else 
            let $textAfterOperator := f:skipOperator($textAfter, $textAfterChar1)
            (: update context, dependent on the following path operator (slash or backslash) :)
            let $newContext :=
                let $isContextUri := $textAfterChar1 eq $FOXSTEP_SEPERATOR
                return
                    if (map:get($context, 'IS_CONTEXT_URI') eq $isContextUri) then $context
                    else map:put($context, 'IS_CONTEXT_URI', $isContextUri)
            return
                let $precedingOperator := $textAfterChar1
                return
                    f:parseSteps($textAfterOperator, $precedingOperator, $newContext)
    )
};

(:~
 : Parses a single step of a foxpath. The text consists of a
 : filtered expression or an axis step. An axis step 
 : consists of an optional axis:
 :    "..." , ".." , "/" 
 : optionally (in the first two cases) or mandatorily
 : followed (in the third case) by a name consisting 
 : of all characters preceding the first occurrence of any of these characters: 
 :    [ ] ) | & / \  \s = ! < > ~
 : or all remaining characters if none of these special 
 : characters occurs in the remaining text.
 :
 : Syntax:
 :     Step ::=  '/'+ FiChar+ Predicates?
 :     Predicates ::= (Predicate)+
 :     Predicate ::= '[' OrExpr ']' 
 :     FiChar ::= [^[/]
 : 
 :     StepExpr         ::= PostfixExpr | AxisStep
 :     AxisStep         ::= (ReverseStep | ForwardStep) PredicateList
 :     ReverseStep      ::= ".."
 :                          | ".." FiChar+
 :                          | "..."
 :                          | "..." FiChar+
 :     ForwardStep      ::= FiChar+
 :                          | "/" FiChar+
 :     PostfixExpr      ::= PrimaryExpr (Predicate | ArgumentList)*
 :     PrimaryExpr      ::= Literal
 :                          | VarRef
 :                          | ParenthesizedExpr
 :                          | ContextItemExpr
 :                          | FunctionCall
 :                          | FunctionItemExpr
 :
 : @param text the text to be parsed
 : @param precedingOp either a foxpath seperator, a node path seperator, or the empty sequence 
 : @return a structured representation of the step,
 :    followed by the remaining unparsed text 
 :)
declare function f:parseStep($text as xs:string?, 
                             $precedingOperator as xs:string?,
                             $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.step', 'INTEXT_STEP: ')  
    let $postfixExprEtc := f:parsePostfixExpr($text, $context)
    let $postfixExpr := $postfixExprEtc[. instance of node()]
    let $FOXSTEP_SEPERATOR := map:get($context, 'FOXSTEP_SEPERATOR')
    let $FOXSTEP_SEPERATOR_REGEX := map:get($context, 'FOXSTEP_SEPERATOR_REGEX')
    let $NODESTEP_SEPERATOR := map:get($context, 'NODESTEP_SEPERATOR')
    return
        (: first, try to parse step as postfix expr 
           (primary expr + optional postfix) :)
        if ($postfixExpr) then
            let $textAfter := f:extractTextAfter($postfixExprEtc)
            let $wrapperName :=
                if (not($precedingOperator)) then ()
                else
                    if ($precedingOperator eq $FOXSTEP_SEPERATOR) then 'foxStep'
                    else if ($precedingOperator eq $NODESTEP_SEPERATOR) then 'step'
                    else error()
            let $parsed :=
                if (not($wrapperName)) then $postfixExpr
                else element {$wrapperName} {$postfixExpr}
            return 
                ($parsed, $textAfter)
                (: ($postfixExpr, $textAfter) :)
                
        (: archive entry step :)        
        else if (matches($text, '^#archive#(\s*('||$FOXSTEP_SEPERATOR_REGEX||'.*)?)?$')) then (
            <foxStep><archiveEntry/></foxStep>,
            replace($text, '^#archive#\s*', '')
        )
        else
            (: then, try to parse as fox axis step :)
            let $foxAxisStepEtc := f:parseFoxAxisStep($text, $context)
            let $foxAxisStep := $foxAxisStepEtc[. instance of node()]
            return
                if ($foxAxisStep) then
                    let $textAfter := f:extractTextAfter($foxAxisStepEtc)       
                    return 
                        ($foxAxisStep, $textAfter)
                else
                    (: finally, try to parse as node axis step :)
                    let $nodeAxisStepEtc := f:parseNodeAxisStep($text, $context)
                    let $nodeAxisStep := $nodeAxisStepEtc[. instance of node()]
                    let $textAfter := f:extractTextAfter($nodeAxisStepEtc)
                    return
                        if (not($nodeAxisStep)) then
                            util:createFoxpathError('SYNTAX_ERROR',
                                concat('Expected path step, but did not encounter a valid one; ',
                                'expression text: ', $text))
                        else                                
                            ($nodeAxisStep, $textAfter)
};

(:~
 : Parses a fox axis step, consisting of an explicit or implicit axis
 : and a name test.
 :)
declare function f:parseFoxAxisStep($text as xs:string?, $context as map(*))
        as item()* {
    let $DEBUG := util:trace($text, 'parse.fox_axis_step', 'INTEXT_FOX_AXIS_STEP: ')
    let $isContextUri := $context?IS_CONTEXT_URI    
    let $acceptAbbrevSyntax := $isContextUri
    let $FOXSTEP_SEPERATOR := map:get($context, 'FOXSTEP_SEPERATOR')
    let $FOXSTEP_NAME_DELIM := map:get($context, 'FOXSTEP_NAME_DELIM')
    let $FOXSTEP_ESCAPE := map:get($context, 'FOXSTEP_ESCAPE')
    let $text :=
        if (starts-with($text, $FOXSTEP_SEPERATOR)) then
            concat('descendant-or-self~::*', $FOXSTEP_SEPERATOR, substring($text, 2))
        (: hjr, 20180112: take care of this scenario: let $x := .. return ...
           the best way to do this is replace .. with parent~::*;
           however, if text starts with .. and the context is node,
           then this is a node axis step => return ! :)
        else if (matches($text, '^\.\.\s*[^.]')) then 
            if ($isContextUri) then concat('parent~::*', substring($text, 3))
            else ()
        else $text
    return if (not($text)) then $text else
            
    let $reverseAxis :=
        (: .. or ... :)
        if ($acceptAbbrevSyntax and matches($text, '(^\.\.(\.)?)')) then
             replace($text, '(^\.\.(\.)?).*', '$1', 's')
        else if (starts-with($text, 'parent~::')) then 'parent~::'            
        else if (starts-with($text, 'ancestor~::')) then 'ancestor~::'        
        else if (starts-with($text, 'ancestor-or-self~::')) then 'ancestor-or-self~::'        
        else if (starts-with($text, 'preceding-sibling~::')) then 'preceding-sibling~::'        
        else ()
        (: note that the complete step may consist of only the axis (not possible with forward axes) :)
        
    let $forwardAxis := 
        if ($reverseAxis) then ()
        else if (starts-with($text, $FOXSTEP_SEPERATOR)) then $FOXSTEP_SEPERATOR        
        else if (starts-with($text, 'self~::')) then 'self~::'        
        else if (starts-with($text, 'child~::')) then 'child~::'        
        else if (starts-with($text, 'descendant~::')) then 'descendant~::'        
        else if (starts-with($text, 'descendant-or-self~::')) then 'descendant-or-self~::'       
        else if (starts-with($text, 'following-sibling~::')) then 'following-sibling~::'       
        else ''
            
    let $axis := ($reverseAxis, $forwardAxis)
    let $axisName :=
        if ($axis eq $FOXSTEP_SEPERATOR) then 'descendant'       
        else if ($axis eq 'self~::') then 'self'        
        else if ($axis eq 'child~::') then 'child'        
        else if ($axis eq 'descendant~::') then 'descendant'        
        else if ($axis eq 'descendant-or-self~::') then 'descendant-or-self'
        else if ($axis eq 'following-sibling~::') then 'following-sibling'        
        else if ($axis eq 'parent~::') then 'parent'
        else if ($axis eq 'ancestor~::') then 'ancestor'        
        else if ($axis eq 'ancestor-or-self~::') then 'ancestor-or-self'
        else if ($axis eq 'preceding-sibling~::') then 'preceding-sibling'       
        else if ($axis eq '..') then 'parent'
        else if ($axis eq '...') then 'ancestor'
        else 'child'
        
    (: axis excludes node step => accept abbrev syntax :)    
    let $acceptAbbrevSyntax :=
        if (not($axisName eq 'child')) then true()
        else $acceptAbbrevSyntax
        
    let $afterAxis := f:skipOperator($text, $axis)
    
    (: name test in canonical syntax :)
    let $nameEtc :=
        let $canonicalNameEtc :=
            f:parseItem_canonicalFoxnameTest($afterAxis, $FOXSTEP_NAME_DELIM)            
        return 
            if (exists($canonicalNameEtc)) then $canonicalNameEtc
            else if ($acceptAbbrevSyntax) then 
                f:parseItem_abbreviatedFoxnameTest($afterAxis, $FOXSTEP_ESCAPE, $context)
            else ()

    (: canonical name test expected and not found => return :)
    return if (empty($nameEtc) and not($acceptAbbrevSyntax)) then () else
    
    let $name := $nameEtc[1]                        
    let $afterName := 
        if (not($name)) then $afterAxis
        else $nameEtc[2]
        
    let $regex := 
        if (not($name)) then () 
        else
            replace($name, '[.\\/\[\]^${}()|]', '\\$0')
            ! replace(., '(^|[^~])\*', '$1.*')
            ! replace(., '~\*', '\\*')
            ! replace(., '(^|[^~])\?', '$1.')   (: 20200830, hjr: KNOWN BUG - a???b becomes: a.?.b :)
            ! replace(., '~\?', '\\?')
            ! concat('^', ., '$')
    return
        if (starts-with($afterName, '[')) then
            (: update context - context is URI (as the current step is a fox axis step) :)
            let $newContext :=
                if (map:get($context, 'IS_CONTEXT_URI') eq true()) then $context
                else map:put($context, 'IS_CONTEXT_URI', true())
                
            let $predicatesEtc := f:parsePredicates($afterName, $newContext)
            let $predicates := $predicatesEtc[. instance of node()]
            let $textAfter := f:extractTextAfter($predicatesEtc)            
            return (
                <foxStep axis="{$axisName}" name="{$name}" regex="{$regex}">{
                    $predicates
                }</foxStep>,
                $textAfter
            )
        else (
            <foxStep axis="{$axisName}" name="{$name}" regex="{$regex}"/>,
            $afterName
        )
};

(:~
 : Parsses a node axis step.
 :)
declare function f:parseNodeAxisStep($text as xs:string?, $context as map(*))
        as item()* {
    let $DEBUG := util:trace($text, 'parse.node_axis_step', 'NODE_AXIS_STEP_EXPR: ') return            
    let $DEBUG := map:get($context, 'IS_CONTEXT_URI')
    
    let $NODESTEP_SEPERATOR := map:get($context, 'NODESTEP_SEPERATOR')
    let $text :=
        if (starts-with($text, $NODESTEP_SEPERATOR)) then 
            concat('descendant-or-self::node()', $NODESTEP_SEPERATOR, substring($text, 2))
        else $text
        
    let $explicitAxis :=
        replace($text, 
            concat(
                '^(\.\.|@|',
                '(child|descendant|descendant-or-self|self|attribute|following-sibling|following',
                '|parent|ancestor|ancestor-or-self|preceding-sibling|preceding)::).*'), '$1', 'sx')
            [not(. eq $text) or $text eq '..']

    let $axisName :=
        if (not($explicitAxis)) then 'child'
        else if ($explicitAxis eq '@') then 'attribute'
        else if ($explicitAxis eq '..') then 'parent'
        else replace($explicitAxis, '::$', '')
        
    let $textNodeTest :=
        if (not($explicitAxis)) then $text
        else if ($explicitAxis eq '..') then ()
        else f:skipOperator($text, $explicitAxis)

    let $nodeTestEtc :=
        if ($explicitAxis eq '..') then (
            <kindTest nodeKind="node"/>,
            f:skipOperator($text, $explicitAxis)
        ) else
            let $kindTestEtc := f:parseKindTest($textNodeTest, $context)
            let $kindTest := $kindTestEtc[. instance of node()]
            return
                if ($kindTest) then (
                    $kindTest,
                    f:extractTextAfter($kindTestEtc)
                ) else
                    let $nameTestEtc := f:parseNametest($textNodeTest, $context)
                    let $nameTest := $nameTestEtc[. instance of node()]
                    return
                        if ($nameTest) then (
                            $nameTest,
                            f:extractTextAfter($nameTestEtc)
                        ) else ()
(:                        
                    let $nameTest := 
                        if (not(matches($textNodeTest, '^( \*:\i\c* | \* | \i\c*:\* | \i\c* )', 'sx'))) then ()
                        else
                            replace($textNodeTest, '^( \*:\i\c* | \* | \i\c*:\* | \i\c* ).*', '$1', 'sx')
                    return
                        if (not($nameTest)) then ()
                        else (
                            <nameTest name="{$nameTest}"/>,
                            f:skipOperator($textNodeTest, $nameTest)
                        )
:)
    let $nodeTest := $nodeTestEtc[. instance of node()]
    return if (not($nodeTest)) then () else
    
    let $textAfterNodeTest := f:extractTextAfter($nodeTestEtc)
    let $stepAtts := (
         attribute axis {$axisName},
         $nodeTest/self::kindTest/(@* except @text),
         $nodeTest/self::nameTest/(@* except @text)
    )                
    return
        if (starts-with($textAfterNodeTest, '[')) then
            (: update context - context is URI (as the current step is a node axis step) :)
            let $newContext :=
                if (map:get($context, 'IS_CONTEXT_URI') eq false()) then $context
                else map:put($context, 'IS_CONTEXT_URI', false())
                
            let $predicatesEtc := f:parsePredicates($textAfterNodeTest, $newContext)
            let $predicates := $predicatesEtc[. instance of node()]
            let $textAfter := f:extractTextAfter($predicatesEtc)
            return (
                <step>{$stepAtts, $predicates}</step>,
                $textAfter
            )
        else (
            <step>{$stepAtts}</step>,
            $textAfterNodeTest
        )
};

(: 
 : ===============================================================================
 :
 :     p a r s e    f i l t e r    e x p r e s s i o n 
 :
 : ===============================================================================
 :)

(:~
 : Attempts to parse a postfix expression. If the expression text does not
 : start with a primary expression, the attempt is aborted and the empty sequence
 : is returned.
 :)
declare function f:parsePostfixExpr($text as xs:string, $context as map(*))
        as item()* {
    let $DEBUG := util:trace($text, 'parse.text.postfix', 'INTEXT_POSTFIX_EXPR: ') return
    
    let $primaryExprEtc := f:parsePrimaryExpr($text, $context)
    let $primaryExpr := $primaryExprEtc[. instance of node()]
    return
        (: if no primary expression could be parsed, 
             abort attempt to parse a postfix expression :)
        if (not($primaryExpr)) then ()
        else
            let $textAfter := f:extractTextAfter($primaryExprEtc)
            return
                if (starts-with($textAfter, '[') or starts-with($textAfter, '(')) then
                    (: update context - the context is not a URI, as it has not
                       been produced by a foxStep expression :)
                    let $CHANGE := 1
                    let $newContext :=
                        if (not($CHANGE)) then map:put($context, 'IS_CONTEXT_URI', false())
                        else $context                    
                    let $postfixesEtc := f:parsePostfixes($textAfter, $newContext)
                    let $postfixes := $postfixesEtc[. instance of node()]
                    let $tree := f:buildPostfixesTree($primaryExpr, $postfixes)
                    let $textAfterPostfixes := f:extractTextAfter($postfixesEtc)            
                    return (
                        $tree,
                        $textAfterPostfixes
                ) else (
                    $primaryExpr,
                    $textAfter
                )
};

(:~
 : Creates the parse tree for a parsed primary expression and parsed postfixes.
 :)
declare function f:buildPostfixesTree($primaryExpr as element(), $postfixes as element()+)
        as element() {
    let $postfix1 := $postfixes[1]
    let $tail := tail($postfixes)
    let $innermostExpr :=
        if ($postfix1/self::predicate) then
            <filterExpr>{
                $primaryExpr,
                $postfix1/*
            }</filterExpr>
        else if ($postfix1/self::argumentList) then
            <dynFuncCall>{
                $primaryExpr,
                $postfix1/*
            }</dynFuncCall>
        else
            util:createFoxpathError('SYNTAX_ERROR', 
                concat('Unexpected postfix element: ', local-name($postfix1)))
    return
        if (not($tail)) then $innermostExpr
        else
            f:buildPostfixesTreeRC($innermostExpr, $tail)
};        

declare function f:buildPostfixesTreeRC($postfixExpr as element(), $postfixes as element()+)
        as element() {
    let $postfix1 := $postfixes[1]
    let $tail := tail($postfixes)
    let $outerExpr :=
        if ($postfix1/self::predicate) then
            if ($postfixExpr/self::filterExpr) then
                element {node-name($postfixExpr)} {
                    $postfixExpr/@*,
                    $postfixExpr/node(),
                    $postfix1/*
                }
            else
                <filterExpr>{
                    $postfixExpr,
                    $postfix1/*
                }</filterExpr>
        else if ($postfix1/self::argumentList) then
            <dynFuncCall>{
                $postfixExpr,
                $postfix1/*
            }</dynFuncCall>
        else     
            util:createFoxpathError('SYNTAX_ERROR', concat('Unexpected postfix element: ', local-name($postfix1)))        
    return
        if (not($tail)) then $outerExpr
        else
            f:buildPostfixesTreeRC($outerExpr, $tail)
};

(:~
 : Parses the postfix(es) of a postfix expression. Syntax:
 :     Postfixes ::= (Predicate | ArgumentList)+ 
 :     Predicate ::= '[' SeqExpr ']'
 :     ArgumentList ::= "(" (Argument ("," Argument)*)? ")" 
 :
 : @param text the text to be parsed
 : @return a structured representation of the postfixes, 
 :    followed by the remaining unparsed text
 :)
declare function f:parsePostfixes($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_POSTFIXES: ') return
    
    let $postfixEtc :=
        if (starts-with($text, '[')) then
            let $predicateEtc := f:parsePredicate($text, $context)
            let $predicate := $predicateEtc[. instance of node()]
            let $textAfter := f:extractTextAfter($predicateEtc)
            return (
                <predicate>{$predicate}</predicate>,
                $textAfter
            )    
        else if (starts-with($text, '(')) then
            let $argumentListEtc := f:parseArgumentList($text, $context)
            let $argumentList := $argumentListEtc[. instance of node()]
            let $textAfter := f:extractTextAfter($argumentListEtc)
            return (
                <argumentList>{$argumentList}</argumentList>,
                $textAfter
            )
        else ()
    let $postfix := $postfixEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($postfixEtc)
    return (
        $postfix,
        if (starts-with($textAfter, '[') or starts-with($textAfter, '(')) then 
            f:parsePostfixes($textAfter, $context)
        else 
            $textAfter
    )
};

(:~
 : Attempts to parse a filter expression. If the expression text does not
 : start with a primary expression, the attempt is aborted and the empty sequence
 : is returned.
 :)
declare function f:parseFilterExpr($text as xs:string, $context as map(*))
        as item()* {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_FILTER_EXPR: ') return
    
    let $primaryExprEtc := f:parsePrimaryExpr($text, $context)
    let $primaryExpr := $primaryExprEtc[. instance of node()]
    return
        (: if no primary expression could be parsed, 
             abort attempt to parse a filter expression :)
        if (not($primaryExpr)) then ()
        else
            let $textAfter := f:extractTextAfter($primaryExprEtc)
            return
                if (starts-with($textAfter, '[')) then
                    (: update context - the context is not a URI, as it has not
                       been produced by a foxStep expression :)
                    let $newContext := map:put($context, 'IS_CONTEXT_URI', false())
                    let $predicatesEtc := f:parsePredicates($textAfter, $newContext)
                    let $predicates := $predicatesEtc[. instance of node()]
                    let $textAfterPredicates := f:extractTextAfter($predicatesEtc)            
                    return (
                        <filterExpr>{
                            $primaryExpr,
                            $predicates
                        }</filterExpr>,
                        $textAfterPredicates
                ) else (
                    $primaryExpr,
                    $textAfter
                )
};

(:~
 : Parses the predicate(s) of a filter expression or a foxpath step. Syntax:
 :     Predicates ::= (Predicate)+ 
 :     Predicate ::= '[' SeqExpr ']' 
 :
 : Precondition: the first character of the text is an opening 
 : square bracket of the first predicate.
 :
 : @param text the text to be parsed
 : @return a structured representation of the predicates, 
 :    followed by the remaining unparsed text
 :)
declare function f:parsePredicates($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_PREDICATES: ') return
    
    let $predEtc := f:parsePredicate($text, $context)
    let $pred := $predEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($predEtc)    
    return (
        $pred,
        if (starts-with($textAfter, '[')) then 
            f:parsePredicates($textAfter, $context)
        else 
            $textAfter
    )
};

(:~
 : Parses a predicate. 
 :
 : Syntax:
 :     Predicate ::= "[" ExprSingle ("," ExprSingle)* "]" 
 :
 : Precondition: the first character of the text is the
 : opening square bracket of a predicate.
 :
 : @param text the text to be parsed
 : @return a structured representation of the predicate,
 :    followed by the remaining unparsed text.
 :)
declare function f:parsePredicate($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text.predicate', 'INTEXT_PREDICATE: ')
    let $useText := replace($text, '^\s*\[\s*', '')  
    let $seqExprEtc := f:parseSeqExpr($useText, $context)
    let $seqExpr := $seqExprEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($seqExprEtc)    
    return
        if ($seqExpr/self::error) then $seqExpr    
        else if (not(starts-with($textAfter, ']'))) then
            util:createFoxpathError('SYNTAX_ERROR', 
                concat('Unbalanced square brackets; predicate text: ', $text))
        else
            let $textAfterOp := f:skipOperator($textAfter, ']')
            return
                ($seqExpr, $textAfterOp) 
};

(: 
 : ===============================================================================
 :
 :     p a r s e    p r i m a r y    e x p r e s s i o n
 :
 : ===============================================================================
 :)

declare function f:parsePrimaryExpr($text as xs:string, $context as map(*))
        as item()* {
    let $DEBUG := util:trace($text, 'parse.text.primary', 'INTEXT_PRIMARY_EXPR: ') return

    (: node test => not primary expression :)
    if (matches($text, '^(node|text|comment|processing-instruction|element|attribute|document-node)\s*\(')) then ()
    
    (: axis => not primary expression :)
    else if (matches($text, '^\i+::')) then ()
    
    else if (starts-with($text, '$')) then f:parseVariableRef($text, $context)
    else if (starts-with($text, '(')) then f:parseParenthesizedExpr($text, $context)
    else if (matches($text, '^["&apos;]')) then f:parseStringLiteral($text, $context)
    else if (matches($text, '^(\d|\.\d)')) then f:parseNumericLiteral($text, $context)
    else if (matches($text, '^\.([^./].*)?$', 's')) then f:parseContextItem($text, $context) 
    else if (matches($text, '^function\s*\(', 's')) then f:parseInlineFunctionExpr($text, $context)    
    else if (matches($text, '^\i\c*\s*\(')) then f:parseFunctionCall($text, $context)
    else if (matches($text, '^\i\c*\s*#\s*\d', 's')) then f:parseNamedFunctionItem($text, $context)   
    else ()
};

(:~
 : Parses a variable reference.
 :
 : Syntax: 
 :     '$' \i\c*
 :
 : @param text the text to be parsed
 : @return a structured representation of the variable reference, followed
 :    by the remaining unparsed text
 :)
declare function f:parseVariableRef($text as xs:string, $context as map(*))
        as item()+ {
    let $nameEtc := f:parseVarName($text, $context)
    let $name := $nameEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($nameEtc)
    return
        if (not($name)) then
            util:createFoxpathError('SYNTAX_ERROR', 
                concat('Invalid variable reference: ', $text))
        else (
            <var>{$name/(@localName, @prefix, @namespace)}</var>,
            $textAfter
        )
};

(:~
 : Parses a parenthesized expression.
 :
 : Syntax: 
 :     '(' Expr? ')'
 :
 : @param text the text to be parsed
 : @return a structured representation of the parenthesized expression, followed
 :    by the remaining unparsed text
 :)
declare function f:parseParenthesizedExpr($text as xs:string, $context as map(*))
        as item()+ {
    let $textAfterOpen := replace($text, '^\(\s*', '')
    return
        (: special case: empty sequence () :)
        if (starts-with($textAfterOpen, ')')) then (
            <emptySequence/>,
            f:skipOperator($textAfterOpen, ')')
        ) else
        
    let $seqExprEtc := f:parseSeqExpr($textAfterOpen, $context)
    let $seqExpr := $seqExprEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($seqExprEtc)    
    return
        if (not(starts-with($textAfter, ')'))) then
            util:createFoxpathError('SYNTAX_ERROR', 
                concat('Unbalanced parentheses: (', $text))
        else
            let $textAfterOperator := f:skipOperator($textAfter, ')')
            return
                ($seqExpr, $textAfterOperator)
};

(:~
 : Parses a context item expression.
 :
 : Syntax: 
 :     ContextItem ::= '.'
 :
 : @param text the text to be parsed
 : @return a structured representation of the number, followed
 :    by the remaining unparsed text
 :)
declare function f:parseContextItem($text as xs:string, $context as map(*))
        as item()+ {
    let $textAfter := f:skipOperator($text, '.')
    let $parsed := <contextItem/>
    return 
        ($parsed, $textAfter)
};


(:~
 : Parses a function call.
 :
 : Syntax: 
 :     FunctionCall ::= \i\c* '(' (OrExpr (',' OrExpr)*)? ')'
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the function call, followed
 :    by the remaining unparsed text as a string, if any
 :)
declare function f:parseFunctionCall($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text.function_call', 'INTEXT_FUNCTION_CALL: ')        
    let $name := replace($text, '^(\i\c*)\s*\(.*', '$1', 's')[not(. eq $text)]
    let $argumentsText := f:skipOperator($text, $name)
    let $argumentsEtc := f:parseArgumentList($argumentsText, $context)
    let $arguments := $argumentsEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($argumentsEtc)
    let $parsed := <functionCall name="{$name}">{$arguments}</functionCall>
    return    
        ($parsed, $textAfter)
};

(:~
 : Parses a named function ref.
 :
 : Syntax: 
 :     NamedFunctionRef ::= \i\c* '#' \d
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the named function ref, followed
 :    by the remaining unparsed text as a string, if any
 :)
declare function f:parseNamedFunctionItem($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_NAMED_FUNCTION_REF: ')        
    let $funcRefText := replace($text, '^(\i\c*\s*#\s*\d+).*', '$1', 's')
    let $funcRef := replace($funcRefText, '\s+', '')
    let $parsed := <functionRef name="{$funcRef}"/>
    let $textAfter := substring-after($text, $funcRefText)
    return (
        $parsed,
        $textAfter
    )
};

(:~
 : Parses an inline function expression.
 :
 : Syntax: 
 :     InlineFunctionExpr ::= "function" "(" ParamList? ")" ("as" SequenceType)? FunctionBody
 :     ParamList          ::= Param ("," Param)*
 :     Param              ::= "$" EQName TypeDeclaration?
 :     TypeDeclaration    ::= "as" SequenceType
 :     FunctionBody       ::= EnclosedExpr
 :     EnclosedExpr       ::= "{" Expr "}"
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the named function ref, followed
 :    by the remaining unparsed text as a string, if any
 :)
declare function f:parseInlineFunctionExpr($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text.inline_function_expr', 'INTEXT_INLINE_FUNCTION_EXPR: ')
    let $paramListText := replace($text, '^function\s*(\(.*)', '$1', 's')
    let $paramListEtc := f:parseParamList($paramListText, $context) 
    
    return
        (: parsing failed? => return () :)
        if (empty($paramListEtc)) then () else
        
    let $paramList := $paramListEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($paramListEtc)
    
    let $returnTypeEtc := f:parseReturnType($textAfter, $context)
    let $returnType := $returnTypeEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($returnTypeEtc)  
    
    return
        (: parsing failed? => return $text :)
        if (not(starts-with($textAfter, '{'))) then ()
        
        else
            let $textAfter := f:skipOperator($textAfter, '{')
            let $bodyEtc := f:parseSeqExpr($textAfter, $context)
            let $body := $bodyEtc[. instance of node()]
            let $textAfter := f:extractTextAfter($bodyEtc)
            return
                (: parsing failed? => return $text :)            
                if (not(starts-with($textAfter, '}'))) then $text
                else
                    let $textAfter := f:skipOperator($textAfter, '}')
                    let $tree :=
                        <inlineFunctionExpr>{
                            $paramList,
                            $returnType,
                            <body>{$body}</body>            
                        }</inlineFunctionExpr>
                    return
                        ($tree, $textAfter)
};

(:~
 : Parses the arguments of a function call.
 :
 : Syntax: 
 :     Arguments ::= "(" (ExprSingle ("," ExprSingle)*)? ")"
 :
 : @param text a text representing the arguments, possibly
 :    followed by further text
 : @return a sequence of expression trees representing the arguments,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseArgumentList($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_ARGUMENT_LIST: ') return
    
    (: case 1: empty argument list :)
    if (matches($text, '^\(\s*\)')) then 
        let $textAfter := replace($text, '^\(\s*\)\s*', '')
        return
            $textAfter
    (: case 2: at least one argument :)            
    else
        let $textAfterOpen := f:skipOperator($text, '(')
        let $argumentsEtc := f:parseArgumentListRC($textAfterOpen, $context)
        let $arguments := $argumentsEtc[. instance of node()]
        let $textAfter := f:extractTextAfter($argumentsEtc)        
        return 
            ($arguments, $textAfter)
};

declare function f:parseArgumentListRC($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_ARGUMENT_LIST_RC: ') return
    
    let $exprSingleEtc := 
        if (matches($text, '^\?\s*[,)]')) then (
            <argPlaceholder/>,
            replace($text, '^\?\s*', '')
        ) else
            f:parseExprSingle($text, $context)
    let $exprSingle := $exprSingleEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($exprSingleEtc)        
    return (
        $exprSingle,
        if (starts-with($textAfter, ',')) then
            let $textAfterSep := f:skipOperator($textAfter, ',')
            return 
                f:parseArgumentListRC($textAfterSep, $context)
        else if (starts-with($textAfter, ')')) then
            let $textAfterArguments := f:skipOperator($textAfter, ')')
            return 
                $textAfterArguments
        else
            util:createFoxpathError('SYNTAX_ERROR', 
                concat('Function call with unbalanced parentheses: ', $text))
        )                    
};

(:~
 : Parses the parameter list of an inline function expression.
 :
 : Syntax: 
 :     ParamList       ::= Param ("," Param)*
 :     Param           ::= "$" EQName TypeDeclaration?
 :     TypeDeclaration ::= "as" SequenceType
 :
 : @param text a text representing the arguments, possibly
 :    followed by further text
 : @return a sequence of expression trees representing the arguments,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseParamList($text as xs:string, $context as map(*))
        as item()* {
    let $DEBUG := util:trace($text, 'parse.text.param_list', 'INTEXT_PARAM_LIST: ') return
    
    (: case 0: text does not start with "(" 
       => return empty sequence, indicating that parsing failed :)    
    if (not(starts-with($text, '('))) then () else
    
    (: case 1: empty param list :)
    if (matches($text, '^\(\s*\)')) then 
        let $textAfter := replace($text, '^\(\s*\)\s*', '')
        return
            $textAfter
    (: case 2: at least one param :)            
    else
        let $textAfterOpen := f:skipOperator($text, '(')
        let $paramsEtc := f:parseParamListRC($textAfterOpen, $context)
        let $params := $paramsEtc[. instance of node()]
        let $textAfter := f:extractTextAfter($paramsEtc)  
        let $tree := <params>{$params}</params>
        return 
            ($tree, $textAfter)
};

(:~
 : Parses a single parameter from the parameter list of an inline function expression.
 :
 : Syntax: 
 :     Param           ::= "$" EQName TypeDeclaration?
 :     TypeDeclaration ::= "as" SequenceType
 :
 : @param text a text representing the arguments, possibly
 :    followed by further text
 : @return a sequence of expression trees representing the arguments,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseParamListRC($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text.param_list_rc', 'INTEXT_PARAM_LIST_RC: ') return
    
    let $eqnameEtc := f:parseVarName($text, $context)
    let $eqname := $eqnameEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($eqnameEtc) 

    (: normalization - if no sequence type specified, add 'item()*' :)
    let $useTextAfter :=
        if (matches($textAfter, '^as\s')) then $textAfter
        else concat('as item()* ', $textAfter)
    let $paramSeqTypeEtc := f:parseParamSequenceType($useTextAfter, $context)
    let $paramSeqType := $paramSeqTypeEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($paramSeqTypeEtc)
    
    let $paramTree :=
        <param>{
            $eqname/(@* except @text),
            $paramSeqType
        }</param>
    
    return (
        $paramTree,
        if (starts-with($textAfter, ',')) then
            let $textAfterSep := f:skipOperator($textAfter, ',')
            return 
                f:parseParamListRC($textAfterSep, $context)
        else if (starts-with($textAfter, ')')) then
            let $textAfterParams := f:skipOperator($textAfter, ')')
            return 
                $textAfterParams
        else
            util:createFoxpathError('SYNTAX_ERROR', 
                concat('Param list of function item with unbalanced parentheses: ', $text))
        )                    
};

(:~
 : Parses the return type of an inline function expression.
 :)
declare function f:parseReturnType($text as xs:string, $context as map(*))
        as item()* {
    let $DEBUG := util:trace($text, 'parse.text.return_type', 'INTEXT_RETURN_TYPE: ') return      
    let $useText := if (not(matches($text, '^as\s'))) then concat('as item()* ', $text) else $text
    return
        let $textSequenceType := f:skipOperator($useText, 'as')
        let $sequenceTypeEtc := f:parseSequenceType($textSequenceType, $context)
        let $sequenceType := $sequenceTypeEtc[. instance of node()]
        let $textAfter := f:extractTextAfter($sequenceTypeEtc)
        return (
            <return>{
                $sequenceType
            }</return>,
            $textAfter
        )
};

declare function f:parseParamSequenceType($text as xs:string, $context as map(*))
        as item()+ {
    if (not(matches($text, '^as\s'))) then $text
    else
        let $textSequenceType := f:skipOperator($text, 'as')
        let $sequenceTypeEtc := f:parseSequenceType($textSequenceType, $context)
        let $sequenceType := $sequenceTypeEtc[. instance of node()]
        let $textAfter := f:extractTextAfter($sequenceTypeEtc)
        return (
            $sequenceType,
            $textAfter
        )
};

(: 
 : ===============================================================================
 :
 :     p a r s e    l i t e r a l s
 :
 : ===============================================================================
 :)

(:~
 : Parses a string literal.
 :
 : Syntax: 
 :     '"' ([^"]|'\''"')* '"' 
 :     | '''' ([^']|'\'')* ''''
 :
 : @param text the text to be parsed
 : @return a structured representation of the literal, followed
 :    by the remaining unparsed text
 :)
declare function f:parseStringLiteral($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text.string', 'INTEXT_STRING_LITERAL: ') return 
    let $char1 := substring($text, 1, 1)
    let $text2 := substring($text, 2)    
    let $literalString :=
            replace($text2, concat('(([^', $char1, ']|\\', $char1, ')*)', $char1, '.*'), '$1', 's')
            [not(. eq $text2)]
    return
        if (empty($literalString)) then
            util:createFoxpathError('SYNTAX_ERROR', 
                concat('Unbalanced string delimiter: ', $text))
        else
            let $textAfter := replace(substring($text, 3 + string-length($literalString)), '^\s+', '')
            let $literal := replace($literalString, concat('\\', $char1), $char1)
            return (
                <string>{$literal}</string>,
                $textAfter
            )
};

(:~
 : Parses a numeric literal.
 :
 : Syntax: 
 :     NumericLiteral ::= IntegerLiteral | DecimalLiteral | DoubleLiteral
 :     IntegerLiteral ::= Digits
 :     DecimalLiteral ::= ("." Digits) | (Digits "." [0-9]*)
 :     DoubleLiteral  ::= ( ("."  Digits) | ( Digits ("." [0-9]*)? ) ) [eE] [+-]? Digits
 :     Digits         ::= [0-9]+ 
 :
 : @param text the text to be parsed
 : @return a structured representation of the number, followed
 :    by the remaining unparsed text
 :)
declare function f:parseNumericLiteral($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_NUMERIC_LITERAL: ') return        
    let $number := replace($text, 
        '( (\d+ (\.\d*)? ) | (\.\d+) ) (\s*[eE]\s*[+\-]?\s*\d+)? .*', '$1$5', 'xs')
    let $value := replace(replace($number, '\s+', ''), 'e', 'E')        
    let $type := 
        if (contains($value, 'E')) then 'xs:double'
        else if (contains($value, '.')) then 'xs:decimal' 
        else 'xs:integer'
    let $numValue :=
        if ($type eq 'xs:double') then xs:double($value)
        else if ($type eq 'xs:decimal') then xs:decimal($value)
        else xs:integer($value)
    let $textAfter := replace(substring($text, 1 + string-length($number)), '^\s+', '')
    return (
        <number type="{$type}" value="{$numValue}"/>,
        $textAfter
    )
};

(: 
 : ===============================================================================
 :
 :     p a r s e    e x p r e s s i o n s    o n    s e q u e n c e    t y p e s
 :
 : ===============================================================================
 :)
 
(:~
 : Parses an instance of expression.
 :
 : Syntax:
 :     InstanceOfExpr ::= TreatExpr ( "instance" "of" SequenceType)? 
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseInstanceOfExpr($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_INSTANCE_OF: ')        
    let $treatExprEtc := f:parseTreatExpr($text, $context)
    let $treatExpr := $treatExprEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($treatExprEtc)    
    return 
        if (matches($textAfter, '^instance\s+of')) then
            let $textAfterOperator := replace($textAfter, '^instance\s+of\s+(.*)', '$1')
            let $sequenceTypeEtc := f:parseSequenceType($textAfterOperator, $context)
            let $sequenceType := $sequenceTypeEtc[. instance of node()]
            let $textAfter := f:extractTextAfter($sequenceTypeEtc)
            return (
                <instance>{$treatExpr, $sequenceType}</instance>,
                $textAfter
            )
        else (
            $treatExpr, 
            $textAfter
        )
};

(:~
 : Parses a treat expression.
 :
 : Syntax:
 :     TreatExpr ::= CastableExpr ( "treat" "as" SequenceType)? 
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseTreatExpr($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_TREAT: ')        
    let $castableExprEtc := f:parseCastableExpr($text, $context)
    let $castableExpr := $castableExprEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($castableExprEtc)    
    return 
        if (matches($textAfter, '^treat\s+as\s+')) then
            let $textAfterOperator := replace($textAfter, '^treat\s+as\s+(.*)', '$1')
            let $sequenceTypeEtc := f:parseSequenceType($textAfterOperator, $context)
            let $sequenceType := $sequenceTypeEtc[. instance of node()]
            let $textAfter := f:extractTextAfter($sequenceTypeEtc)
            return (
                <treat>{$castableExpr, $sequenceType}</treat>,
                $textAfter
            )
        else (
            $castableExpr, 
            $textAfter
        )
};

(:~
 : Parses a castable expression.
 :
 : Syntax:
 :     CastableExpr ::= CastExpr ( "castable" "as" SequenceType)? 
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseCastableExpr($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.text', 'INTEXT_CASTABLE: ')        
    let $castExprEtc := f:parseCastExpr($text, $context)
    let $castExpr := $castExprEtc[. instance of node()]
    let $textAfter := f:extractTextAfter($castExprEtc)    
    return 
        if (matches($textAfter, '^castable\s+as\s+')) then
            let $textAfterOperator := replace($textAfter, '^castable\s+as\s+(.*)', '$1')
            let $singleTypeEtc := f:parseSingleType($textAfterOperator, $context)
            let $singleType := $singleTypeEtc[. instance of node()]
            let $textAfter := f:extractTextAfter($singleTypeEtc)
            return (
                <castable>{$castExpr, $singleType}</castable>,
                $textAfter
            )
        else (
            $castExpr, 
            $textAfter
        )
};

(:~
 : Parses a cast expression.
 :
 : Syntax:
 :     CastExpr ::= ArrowExpr ( "cast" "as" SingleType)? 
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseCastExpr($text as xs:string, $context as map(*))
        as item()+ {
    let $DEBUG := util:trace($text, 'parse.cast', 'INTEXT_CAST: ')        
    let $arrowExprEtc := f:parseArrowExpr($text, $context)
    let $arrowExpr := $arrowExprEtc[. instance of node()]
    let $textAfterArrow := f:extractTextAfter($arrowExprEtc)    
    return 
        if (matches($textAfterArrow, '^cast\s+as\s+')) then
            let $textAfterOperator := replace($textAfterArrow, '^cast\s+as\s+(.*)', '$1')
            let $singleTypeEtc := f:parseSingleType($textAfterOperator, $context)
            let $singleType := $singleTypeEtc[. instance of node()]
            let $textAfterSingleType := f:extractTextAfter($singleTypeEtc)
            return (
                <cast>{$arrowExpr, $singleType}</cast>,
                $textAfterSingleType
            )
        else (
            $arrowExpr, 
            $textAfterArrow
        )
};

(: 
 : ===============================================================================
 :
 :     p a r s e    s e q u e n c e    t y p e
 :
 : ===============================================================================
 :)

(:~
 : Parses a sequence type.
 :
 : Syntax:
 :     SequenceType ::= ("empty-sequence" "(" ")")
 :                      | (ItemType OccurrenceIndicator?) 
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseSequenceType($text as xs:string, $context as map(*))
        as item()+ {
    if (matches($text, '^empty-sequence\s*\(\s*\)')) then
        let $sequenceType := <sequenceType empty="true" text="empty-sequence()"/>
        let $textAfter := replace($text, '^empty-sequence\s*\(\s*\)\s*', '')
        return ($sequenceType, $textAfter)
    else
    
    let $itemTypeEtc := f:parseItemType($text, $context)
    return
        if (empty($itemTypeEtc)) then
            util:createFoxpathError('SYNTAX_ERROR', 
                concat('Not a valid sequence type at beginning of string: ', $text))
        else
            let $itemType := $itemTypeEtc[. instance of node()]
            let $itemTypeText :=
                if ($itemType/self::atomicType) then $itemType/@name else $itemType/@text
            let $textAfter := f:extractTextAfter($itemTypeEtc)
            let $occ := 
                if (matches($textAfter, '^[*+?]')) then substring($textAfter, 1, 1)
                else ()
            let $textAfterOcc :=
                if (not($occ)) then $textAfter
                else replace(substring($textAfter, 1 + string-length($occ)), '^\s+', '')
            let $sequenceTypeText := concat($itemTypeText, $occ)
            let $sequenceType :=
                <sequenceType>{
                    if (not($occ)) then () else attribute occ {$occ},
                    
                    if ($itemType/self::atomicType) then attribute atomicType {$itemType/@name}
                    else $itemType/(@* except @text),
                    attribute text {$sequenceTypeText},
                    (: $itemType, :)   
                    ()
                }</sequenceType>
            return 
                ($sequenceType, $textAfterOcc)
};        

(:~
 : Parses a single type.
 :
 : Syntax:
 :     SingleType ::= AtomicType "?"?
 :
 : @param text a text consisting of the single type specification, possibly
 :    followed by further text
 : @return expression tree representing the single type specification,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseSingleType($text as xs:string, $context as map(*))
        as item()+ {
    let $atomicTypeEtc := f:parseAtomicTypeTest($text, $context)
    let $atomicType := $atomicTypeEtc[. instance of node()]
    return
        if (not($atomicType)) then ()
        else
            let $textAfter := f:extractTextAfter($atomicTypeEtc)
            let $typeName := $atomicType/@name
            let $occ :=
                if (starts-with($textAfter, '?')) then '?'
                else ()
            let $textAfterOperator := if (not($occ)) then $textAfter else f:skipOperator($textAfter, '?')
            return (
                <singleType name="{$typeName}">{
                    if (not($occ)) then () else attribute occ {"?"},
                    attribute text {concat($typeName, $occ)}
                }</singleType>,
                $textAfterOperator
            )
};        

(:~
 : Parses an item type.
 :
 : Syntax:
 :     ItemType ::= KindTest | ("item" "(" ")") | AtomicType
 :     KindText ::= DocumentTest
 :                  | ElementTest
 :                  | AttributeTest
 :                  | SchemaElementTest
 :                  | SchemaAttributeTest
 :                  | PITest
 :                  | CommentTest
 :                  | TextTest
 :                  | AnyKindTest
 :      AnyKindTest             ::= "node" "(" ")"
 :      DocumentTest            ::= "document-node" "(" (ElementTest |  SchemaElementTest)? ")"
 :      TextTest                ::= "text" "(" ")"
 :      CommentTest             ::= "comment" "(" ")"
 :      PITest                  ::= "processing-instruction" "(" (NCName | StringLiteral)? ")"
 :      AttributeText           ::= "attribute" "(" (AttribNameOrWildcard ("," TypeName)?)? ")"
 :      AttributeNameOrWildcard ::= AttributeName | "*"
 :      SchemaAttributeTest     ::= "schema-attribute" "(" AttributeDeclaration ")"
 :      AttributeDeclaration    ::= AttributeName
 :      ElementTest             ::= "element" "(" (ElementNameOrWildCard ("," TypeName "?"?)?)? ")"
 :      ElementNameOrWildcard   ::= ElementName | "*"
 :      SchemaElementTest       ::= "schema-element" "(" ElementDeclaration ")"
 :      ElementDeclaration      ::= ElementName
 :      AttributeName           ::= QName
 :      ElementName             ::= QName
 :      TypeName                ::= QName
 :
 : @param text a text consisting of the expression text, possibly
 :    followed by further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseItemType($text as xs:string, $context as map(*))
        as item()+ {
    if (matches($text, '^item\s*\(\s*\)')) then
        let $textAfter := replace($text, '^item\s*\(\s*\)\s*', '')
        let $itemType := <itemType text="item()" kind="item"/>
        return
            ($itemType, $textAfter)
    else
    
    let $kindTestEtc := f:parseKindTest($text, $context)
    return
        if (exists($kindTestEtc)) then
            let $kindTest := $kindTestEtc[. instance of node()]
            let $textAfter := f:extractTextAfter($kindTestEtc)
            return
                ($kindTest, $textAfter)        
        else
            let $atomicTypeEtc := f:parseAtomicTypeTest($text, $context)
            return
                if (empty($atomicTypeEtc)) then
                    util:createFoxpathError('SYNTAX_ERROR', 
                        concat('Not a valid item type at beginning of string: ', $text))
                else
                    let $atomicType := $atomicTypeEtc[. instance of node()]
                    let $textAfter := f:extractTextAfter($atomicTypeEtc)
                    return
                        ($atomicType, $textAfter)
};        

(:~
 : Parses an atomic type test.
 :
 : Syntax:
 :     AtomicType ::= QName
 :
 : @param text a text consisting of the kind test, possibly followed by 
 :    further text
 : @return an element representing the atomic type test,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseAtomicTypeTest($text as xs:string, $context as map(*))
        as item()+ {
    let $qname :=        
        if (matches($text, '^\i\c*?:\i\c*')) then
            replace($text, '^(\i\c*?:\i\c*).*', '$1', 's')
        else if (matches($text, '^\i\c*')) then
            replace($text, '(^\i\c*).*', '$1', 's')
        else ()
    return
        if (not($qname)) then ()
        else
            let $textAfter := replace(substring($text, 1 + string-length($qname)), '^\s+', '')    
            return (
                <atomicType name="{$qname}"/>,
                $textAfter
            )            
};

(:~
 : Parses a kind test.
 :
 : Syntax:
 :     KindText ::= DocumentTest
 :                  | ElementTest
 :                  | AttributeTest
 :                  | SchemaElementTest
 :                  | SchemaAttributeTest
 :                  | PITest
 :                  | CommentTest
 :                  | TextTest
 :                  | AnyKindTest
 :      AnyKindTest             ::= "node" "(" ")"
 :      DocumentTest            ::= "document-node" "(" (ElementTest |  SchemaElementTest)? ")"
 :      TextTest                ::= "text" "(" ")"
 :      CommentTest             ::= "comment" "(" ")"
 :      PITest                  ::= "processing-instruction" "(" (NCName | StringLiteral)? ")"
 :      AttributeTest           ::= "attribute" "(" (AttribNameOrWildcard ("," TypeName)?)? ")"
 :      AttributeNameOrWildcard ::= AttributeName | "*"
 :      SchemaAttributeTest     ::= "schema-attribute" "(" AttributeDeclaration ")"
 :      AttributeDeclaration    ::= AttributeName
 :      ElementTest             ::= "element" "(" (ElementNameOrWildCard ("," TypeName "?"?)?)? ")"
 :      ElementNameOrWildcard   ::= ElementName | "*"
 :      SchemaElementTest       ::= "schema-element" "(" ElementDeclaration ")"
 :      ElementDeclaration      ::= ElementName
 :      AttributeName           ::= QName
 :      ElementName             ::= QName
 :      TypeName                ::= QName
 :
 : @param text a text consisting of the kind test, possibly followed by 
 :    further text
 : @return expression tree representing the expression text,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseKindTest($text as xs:string, $context as map(*))
        as item()* {
    let $parsedEtc :=
        if (matches($text, '^(node|text|comment|processing-instruction)')) then
            f:parseNodeTextCommentPiTest($text, $context)
        else if (matches($text, '^(element|attribute)')) then 
            f:parseElementOrAttributeTest($text, $context)
        else if (matches($text, '^schema-(element|attribute)')) then 
            f:parseSchemaElementOrAttributeTest($text, $context)
        else if (matches($text, '^document-node')) then
            f:parseDocumentNodeTest($text, $context)
        else ()
    return
        $parsedEtc
};

declare function f:parseNodeTextCommentPiTest($text as xs:string, $context as map(*))
        as item()* {
    let $parsedEtc :=
        if (matches($text, '^(node|text|comment|processing-instruction)\s*\(\s*\)')) then
            let $kind := replace($text, '^(node|text|comment|processing-instruction).*', '$1', 'sx')
            let $textAfter := replace($text, concat('^', $kind, '\s*\(\s*\)\s*'), '')
            let $kindTestText := concat($kind, '()')
            let $kindTest := <kindTest nodeKind="{$kind}" text="{$kindTestText}"/>
            return ($kindTest, $textAfter)     
        else if (matches($text, '^processing-instruction \s*\(\s* ([^)\s]+) \s*\)', 'sx')) then
            let $nameRaw := replace($text, '^processing-instruction \s*\(\s* ([^)\s]+) \s*\).*', '$1', 'sx')
            let $name := (
                if (matches($nameRaw, '^["'']')) then
                    let $nameEtc := f:parseStringLiteral($nameRaw, $context)
                    let $nameNode := $nameEtc[. instance of node()]
                    let $textAfterName := f:extractTextAfter($nameEtc)
                    return
                        if ($textAfterName) then () else $nameNode/string()
                else $nameRaw
                )[matches(., '^\i\c*$')]
            return
                if (not($name)) then () else
                    let $textAfter := replace($text, '^processing-instruction \s*\( .*? \)\s* (.*)', '$1', 'sx')
                    let $kindTestText := concat('processing-instruction(', $name, ')')
                    return (
                        <kindTest nodeKind="processing-instruction" nodeName="{$name}" text="{$kindTestText}"/>,
                        $textAfter
                    )
        else ()
    return
        $parsedEtc
};

declare function f:parseDocumentNodeTest($text as xs:string, $context as map(*))
        as item()* {      
    let $parsedEtc :=
        if (matches($text, '^document-node\s*\(\s*\)')) then
            let $textAfter := replace($text, 'document-node\s*\(\s*\)\s*(.*)', '$1', 's')
            let $kindTest := <kindTest nodeKind="document" text="document-node()"/>
            return ($kindTest, $textAfter)     
        else if (matches($text, '^document-node \s*\(\s* [^)\s] .*? \)', 'sx')) then
            let $textElementTestEtc := replace($text, '^document-node\s*\(\s*', '')
            return
                if (starts-with($textElementTestEtc, 'element')) then
                    let $elementTestEtc := f:parseElementOrAttributeTest($textElementTestEtc, $context)
                    let $elementTest := $elementTestEtc[. instance of node()]
                    let $textAfterElementTest := f:extractTextAfter($elementTestEtc)
                    return
                        if (not($elementTest/@nodeKind eq 'element')) then ()
                        else if (not(starts-with($textAfterElementTest, ')'))) then ()                        
                        else
                            let $textAfter := f:skipOperator($textAfterElementTest, ')')
                            let $kindTestText := concat('document-node(', $elementTest/@text, ')')
                            let $kindTest :=
                                <kindTest nodeKind="document">{
                                    $elementTest/@nodeName/attribute elemName {.},
                                    $elementTest/@nodeType/attribute elemType {.},
                                    $elementTest/@nilledAllowed/attribute elemNilledAllowed {.},
                                    attribute text {$kindTestText}
                                }</kindTest>
                            return
                                ($kindTest, $textAfter)
                else if (starts-with($textElementTestEtc, 'schema-element')) then
                    let $schemaElementTestEtc := f:parseSchemaElementOrAttributeTest($textElementTestEtc, $context)
                    let $schemaElementTest := $schemaElementTestEtc[. instance of node()]
                    let $textAfterSchemaElementTest := f:extractTextAfter($schemaElementTestEtc)
                    return
                        if (not($schemaElementTest/@nodeKind eq 'schema-element')) then ()
                        else if (not(starts-with($textAfterSchemaElementTest, ')'))) then ()                        
                        else
                            let $textAfter := f:skipOperator($textAfterSchemaElementTest, ')')
                            let $kindTestText := concat('document-node(', $schemaElementTest/@text, ')')
                            let $kindTest :=
                                <kindTest nodeKind="document">{
                                    $schemaElementTest/@name/attribute schemaElem {.},
                                    attribute text {$kindTestText}
                                }</kindTest>
                            return
                                ($kindTest, $textAfter)
                else ()
            else ()
    return
        $parsedEtc
};

declare function f:parseElementOrAttributeTest($text as xs:string, $context as map(*))
        as item()* {
    let $elemAttItems := 
        replace($text, '^(element|attribute)
                        \s*\(\s*
                        ( (\*|(\i\c*)) (\s*,\s* (\i\c*\??) )? )?
                        \s*\).*', 
                        '$1#$3#$6',   (: kind#nodeName#nodeType :)
                        'x')[. ne $text]
     return
        if (not($elemAttItems)) then () else
        
        let $textAfter := replace($text, '^(element|attribute)\s*\(.*?\)\s*', '')
        let $items := tokenize($elemAttItems, '#')
        let $kind := $items[1]
        let $nodeName := $items[2][string()]
        let $nodeTypeRaw := $items[3][string()]
        let $nilFlag  := ends-with($nodeTypeRaw, '?')
        let $nodeType := replace($nodeTypeRaw, '\?$', '')[string()]
        let $kindTestText := 
            concat($kind, '(', 
                   $nodeName, 
                   if (not($nodeTypeRaw)) then () else concat(',', $nodeTypeRaw), 
                   ')')            
        let $kindTest := 
            <kindTest nodeKind="{$kind}">{
                $nodeName ! attribute nodeName {$nodeName},
                $nodeType ! attribute nodeType {$nodeType},
                if (not($nilFlag)) then () else attribute nilledAllowed {'true'},
                attribute text {$kindTestText}
            }</kindTest>
        return
            ($kindTest, $textAfter)
};        

declare function f:parseSchemaElementOrAttributeTest($text as xs:string, $context as map(*))
        as item()* {
    let $schemaElementOrAttribute :=
        replace($text, '^schema-(element|attribute)\s*\(\s*(\i\c*)\s*\).*', '$1#$2')[. ne $text]
    return
        if (not($schemaElementOrAttribute)) then () else
        
        let $textAfter := replace($text, '^schema-(element|attribute)\s*\(.*?\)\s*', '')         
        let $items := tokenize($schemaElementOrAttribute, '#')
        let $kind := concat('schema-', $items[1])
        let $name := $items[2]
        let $testText := concat($kind, '(', $name, ')')
        let $kindTest :=
            <kindTest nodeKind="{$kind}" name="{$name}" text="{$testText}"/>
        return
            ($kindTest, $textAfter)
};

(: 
 : ===============================================================================
 :
 :     p a r s e    n a m e    o r    n a m e t e s t
 :
 : ===============================================================================
 :)

(:~
 : Parses a variable name. 
 :
 : A variable name is an EQName preceded by a "$" character.
 :
 : See `parseEQName` for details about the structured representation of 
 : an EQName.
 :
 : @param text the text to be parsed
 : @param context the parsing context
 : @return an element representing the variable name,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseVarName($text as xs:string, $context as map(*))
        as item()* {
    let $DEBUG := util:trace($text, 'parse.var_name', 'INTEXT_VAR_NAME: ') return
    
    if (not(starts-with($text, '$'))) then 
        $text 
    else 
        let $nameText := f:skipOperator($text, '$')
        let $nameEtc := f:parseEQName($nameText, $context)
        return
            if ($nameEtc[. instance of node()]) then $nameEtc
            else $text
};

(:~
 : Parses a name test, which is either an EQName or a wildcard.
 :  
 : A wildcard has one of four possible forms:
 :    *, *:foo, bat*:, Q{...}*)
 : An EQName has one of three possible forms: 
 :    foo, foo:bar, Q{zoozoo}foo
 :
 : The structured representation is a "name" element with 
 : attributes providing the name test components:
 : @localName - provides the local name
 : @uri - provides the namespace URI (optional)
 : @prefix - provides the prefix (optional)
 : @text - provides the original name text
 :
 : A wildcard component is represented by the value '*'.
 :
 : @param text the text to be parsed
 : @param context the parsing context
 : @return an element representing the name test,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseNametest($text as xs:string, $context as map(*))
        as item()* {
    let $s := $text || '###'

    (: case *:lname :)
    let $match := replace($s, '(^\*:\i[\c-[:]]*).*', '$1', 's')[not(. eq $s)]
    return
        if ($match) then
            let $lname := substring-after($match, ':')
            let $textAfter := substring($text, 1 + string-length($match))
            return (
                <nameTest namespace="*" localName="{$lname}" text="{$match}"/>,
                $textAfter
            )
        else

    (: case prefix:* :)
    let $match := replace($s, '(^\i[\c-[:]]*:\*).*', '$1', 's')[not(. eq $s)]
    return
        if ($match) then
            let $prefix := substring-before($match, ':')
            let $textAfter := substring($text, 1 + string-length($match))
            return (
                <nameTest prefix="{$prefix}" localName="*" text="{$match}"/>,
                $textAfter
            )
        else

    (: case Q{...}* :)
    let $match := replace($s, '^(Q\{.*?\}\*).*', '$1', 's')[not(. eq $s)]
    return
        if ($match) then
            let $uri := replace($match, '^Q\{(.*?)\}.*', '$1', 's')
            let $textAfter := substring($text, 1 + string-length($match))
            return (
                <nameTest namespace="{$uri}" localName="*" text="{$match}"/>,
                $textAfter
            )
            
    (: case * :)
    else if (matches($s, '^\*')) then (
        <nameTest namespace="*" localName="*" text="*"/>,
        substring($text, 2)
    )
    
    (: case EQName (perhaps) :)                        
    else
        let $nameEtc := f:parseEQName($text, $context)
        let $name := $nameEtc[. instance of node()]
        return
            if (not($name)) then $text
            else (
                <nameTest>{$name/@*}</nameTest>,
                f:extractTextAfter($nameEtc)
            )
};

(:~
 : Parses an EQName. The structured representation is a "name" element with 
 : attributes providing the name components:
 : @localName - provides the local name
 : @namespace - provides the namespace URI (optional)
 : @prefix - provides the prefix (optional)
 : @text - provides the original name text
 : 
 : Note. The resolving of a prefix is postponed to a step finalizing
 :    the parsing; in case of a prefixed name, here only the prefix is
 :    recorded.
 : Note. If the text does not begin with an EQName, the text is returned
 : as-is.
 :
 : @param text a text consisting of the name text, possibly followed by 
 :     further text
 : @param context the parsing context
 : @return an element representing the name,
 :    followed by the remaining unparsed text as a string, if any
 :)
declare function f:parseEQName($text as xs:string, $context as map(*))
        as item()* {
    let $DEBUG := util:trace($text, 'parse.eqname', 'INTEXT_EQNAME: ') return

    let $nameRegex := '^(\i[\c-[:]]*(:\i[\c-[:]]*)?).*'
    let $s := $text || '###'

    (: case: braced URI literal :)
    let $match := replace($s, '^(Q\{.*?\}\i[\c-[:]]*).*', '$1', 's')[not(. eq $s)]
    return
        if ($match) then
            let $parts := replace($match, '.*\{(.*)\}(.*)', '$2#$1', 's')
            let $uri := substring-after($parts, '#')
            let $lname := substring-before($parts, '#')
            return (
                <name namespace="{$uri}" localName="{$lname}" text="{$match}"/>,
                (: substring-after($text, $match) 20160523 :)
                f:skipOperator($text, $match)
            )
        else
        
    let $match := replace($s, $nameRegex, '$1', 's')[not(. eq $s)]
    return 
        if ($match) then 
            (: let $textAfter := substring-after($text, $match) 20160523 :)
            let $textAfter := f:skipOperator($text, $match)
            let $tree :=
            
    (: case: prefixed name :)
                if (contains($match, ':')) then
                    let $prefix := substring-before($match, ':')
                    let $lname := substring-after($match, ':')
                    return
                        <name prefix="{$prefix}" localName="{$lname}" text="{$match}"/>
                        
    (: case: non-prefixed name :)
                else
                    <name localName="{$match}" text="{$match}"/>
                   
            return
                ($tree, $textAfter)
                
    (: case: not an EQName :)                
        else
            $text
};

(:~
 : Parses an EQName. The structured representation is a "name" element with 
 : attributes providing the name components. If the EQName is a braced URI
 : literal, the "name" element has a @localName and a @namespace attribute.
 : Otherwise, the "name" element has a @localName attribute and, optionally,
 : a @prefix attribute.
 :
 : @param text a text consisting of the name text, possibly followed by 
 :     further text
 : @return name element representing the name text, followed by the 
 :     remaining unparsed text as a string, if any 
 :)
(: 
declare function f:parseEQName($text as xs:string, $context as map(*))
        as item()* {
    let $DEBUG := util:trace($text, 'parse.text.eqname', 'INTEXT_EQNAME: ') return        
    let $lnameUri := 
        replace($text, '^\$Q\s*\{\s*(.*)\}\s*(.*)', '$2#$1', 's')[not(. eq $text)]
    return
        if ($lnameUri) then
            <name localName="{substring-before($lnameUri, '#')}" 
                  namespace="{substring-after($lnameUri, '#')}"/>
        else
            let $name := replace($text, '^\$(\i\c*).*', '$1', 's')[not(. eq $text)]
            return
                (: parse error => return () :)
                if (not($name)) then () else
            
                let $prefix := substring-before($name, ':')[string(.)]
                let $lname := replace($name, '^.+:', '')
                return (
                    <name localName="{$lname}">{
                        if (not($prefix)) then () else 
                            attribute prefix {$prefix}
                    }</name>
                    ,
                    f:skipOperator($text, concat('$', $name))
                )
};
:)

(: 
 : ===============================================================================
 :
 :     u t i l i t y    f u n c t i o n s
 :
 : ===============================================================================
 :)

(:~
 : Extracts from the result of parsing an expression the
 : remaining unparsed text.
 :
 : @param exprEtc the parsing result, typically consisting of
 :     zero or more nodes providing a structured representation
 :     of the expression, and an atomic item providing the
 :     remaining unparsed text
 : @return the remaining unparsed text, or the empty sequence
 :     if there is no remaining text 
 :)
declare function f:extractTextAfter($exprEtc as item()*)
        as xs:string? {
    replace($exprEtc[not(. instance of node())], '^\s+', '')[string()]        
};

(:~
 : Extracts from a fragment of expression text starting with an 
 : operator the text following the operator and any whitespace
 : immediately following the operator.
 :
 : @param text expression text
 : @return the text following the operator and any whitespace
 :     immediately following it
 :)
declare function f:skipOperator($text as xs:string, $operator as xs:string?)
        as xs:string {
    replace(substring($text, 1 + string-length($operator)), '^\s+', '')
};

(:~
 : Parses a text which may begin with a canonical fox name test.
 : If this is not the case, the function returns the empty sequence.
 : Otherwise, it returns one or two strings: (1) the name pattern
 : encoded by the name test; (2) if the name test is followed by
 : further text - the text following the canonical name test.
 :
 : @param text the text to be parsd
 : @param FOXSTEP_NAME_DELIM the character used as delimiter of canonical fox name tests
 : @return the name pattern and the string following it, if any;
 :        the empty sequence if the text does not begin with an
 :        abbreviated name test
 :) 
declare function f:parseItem_canonicalFoxnameTest($text as xs:string, 
                                                  $FOXSTEP_NAME_DELIM as xs:string)
        as xs:string* {
        
    (: do not process unless the first character is a delimiter char :)    
    if (not(starts-with($text, $FOXSTEP_NAME_DELIM))) then () else
    
    let $patternText :=
    
        (: complete text is a fox name test :)
        if (matches($text,
            concat('^', $FOXSTEP_NAME_DELIM, 
                   '([^', $FOXSTEP_NAME_DELIM, ']|', $FOXSTEP_NAME_DELIM, $FOXSTEP_NAME_DELIM, ')*', 
                        $FOXSTEP_NAME_DELIM, '$'), 's')) 
        then $text
    
        (: the text starts with a fox name test :)
        else replace($text, 
                concat('^(', $FOXSTEP_NAME_DELIM, 
                        '([^', $FOXSTEP_NAME_DELIM, ']|', $FOXSTEP_NAME_DELIM, $FOXSTEP_NAME_DELIM, 
                        ')*', 
                        $FOXSTEP_NAME_DELIM, ').*'), 
                '$1', 's')
                [not(. eq $text)]
    return
        if (empty($patternText)) then () else (
        
        (: remove delimiters and escaping :)
            replace(
                substring($patternText, 2, string-length($patternText) - 2), 
                concat($FOXSTEP_NAME_DELIM, $FOXSTEP_NAME_DELIM),
                $FOXSTEP_NAME_DELIM
            )
            ! replace(., '[*?]', '~$0')
            ,
            substring($text, string-length($patternText) + 1)
        )
};

(:~
 : Parses a text which may begin with an abbreviated fox name test.
 : If this is not the case, the function returns the empty sequence.
 : Otherwise, it returns one or two strings: (1) the name pattern
 : encoded by the name test; (2) if the name test is followed by
 : further text - the text following the abbreviated name test.
 :
 : @param text the text to be parsd
 : @param FOXSTEP_ESCAPE the character used within abbreviated fox name tests
 :        as escape character
 : @return the name pattern and the string following it, if any;
 :        the empty sequence if the text does not begin with an
 :        abbreviated name test
 :) 
declare function f:parseItem_abbreviatedFoxnameTest($text as xs:string, 
                                                    $FOXSTEP_ESCAPE as xs:string,
                                                    $context as map(*))
        as xs:string* {
    let $NODESTEP_SEPERATOR_REGEX := map:get($context, 'NODESTEP_SEPERATOR_REGEX')    
    let $NODESTEP_SEPERATOR := map:get($context, 'NODESTEP_SEPERATOR')
    let $FOXSTEP_SEPERATOR_REGEX := map:get($context, 'FOXSTEP_SEPERATOR_REGEX')
    let $FOXSTEP_SEPERATOR := map:get($context, 'FOXSTEP_SEPERATOR')
    return
    (: 
       The name test is terminated by any of the following characters (unless escaped): 
       FOXSTEP_ESCAPE []} \/ <> () =!|,;
       Any of these characters occurring within the name pattern must be escaped
       by a preceding escape character.
       
       Additional rule: a leading digit must be escaped.
       
       Escape character: ~
       
       The pattern consists of a sequence of items consisting of 
       (1) one of the characters which are not escaped, 
       (2) or an escape character followed by one of the characters which are escaped       
    :)

    (: if the text does not start with an unescaped or escaped fox name character ... :)
    if (not(matches($text,
            concat(
            '^(',            '[^ ', $FOXSTEP_ESCAPE, $FOXSTEP_SEPERATOR_REGEX, $NODESTEP_SEPERATOR_REGEX, ' ^$<>\[\]{}()=!|,; \d . ] |',
            $FOXSTEP_ESCAPE, '[  ', $FOXSTEP_ESCAPE, $FOXSTEP_SEPERATOR_REGEX, $NODESTEP_SEPERATOR_REGEX, ' ^$<>\[\]{}()=!|,; \d . ] )'
            ), 'sx'))) 
    then ()
    
    (: extract the leading fox name test :)            
    else
        let $namePattern :=
            replace($text,
                concat(
                '^(',
                ' (',               '[^', $FOXSTEP_ESCAPE, $FOXSTEP_SEPERATOR_REGEX, $NODESTEP_SEPERATOR_REGEX, ' ^$<>\[\]{}()=!|,; \d . ] |',
                   $FOXSTEP_ESCAPE, '[ ', $FOXSTEP_ESCAPE, $FOXSTEP_SEPERATOR_REGEX, $NODESTEP_SEPERATOR_REGEX, ' ^$*?<>\[\]{}()=!|,; \d . ] )',
                ' (',               '[^', $FOXSTEP_ESCAPE, $FOXSTEP_SEPERATOR_REGEX, $NODESTEP_SEPERATOR_REGEX, ' ^$<>\[\]{}()=!|,; \s ] |',
                   $FOXSTEP_ESCAPE, '[ ', $FOXSTEP_ESCAPE, $FOXSTEP_SEPERATOR_REGEX, $NODESTEP_SEPERATOR_REGEX, ' ^$*?<>\[\]{}()=!|,; \s ] )*', 
                ' ).*'), '$1', 'sx')
        return (
            (: name, after removing escapes :)
            replace($namePattern, '~([*?])', '\\$1')             (: replace ~* with \*, ~? with \? :)
            ! replace(., concat($FOXSTEP_ESCAPE, '(.)'), '$1')   (: remove ~ :)
            ! replace(., '\\([*?])', '~$1')                      (: replace \* with ~*, \? with ~? :)   
            ,
            substring($text, string-length($namePattern) + 1) ! replace(., '^\s+', '')
        )
};        
