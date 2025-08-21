(:~
util-filePath.xqm - utility functions for evaluating file paths

Version 20131108 # added resolveFpath()
:)

(: ============================================================================== :)

module namespace ufpath="http://www.parsqube.de/xquery/util/file-path";
import module namespace unamef="http://www.parsqube.de/xquery/util/name-filter"
    at "util-nameFilter.xqm";
import module namespace uregex="http://www.parsqube.de/xquery/util/regex"
    at "util-regex.xqm";
    
(: 
   === addPath =================================================== 
 :)
(:~
 : Adds a path to another path, returning the result path. If the second path
 : is absolute, the second path is returned, otherwise the second path 
 : resolved in the context of the first path's destination.
 :
 : The result path is returned as normalized path.
 :
 : @param path1 a path
 : @param path2 a second path
 :)
declare function ufpath:addPath($path1 as xs:string,
                                $path2 as xs:string?)
        as xs:string {
    let $path1N := $path1 ! ufpath:normalizePath(.)
    return if (not($path2)) then $path1N else
    
    let $path2N := $path2 ! ufpath:normalizePath(.)
    return
        if (ufpath:isNormalizedPathAbsolute($path2N)) then $path2N
        else ufpath:addPathREC($path1N, $path2N)
};

(:~
 : Recursive helper function of `addPath()`.
 :)
declare function ufpath:addPathREC($path1 as xs:string,
                                   $path2 as xs:string?)
        as xs:string {
    if (not($path2)) then $path1        
    else
        let $split := ufpath:splitPath($path2)
        let $step1 := $split[1]
        let $tail := $split[2]
        return
            let $pathNext :=
                if ($step1 eq '..') then $path1 ! ufpath:getParentFolder(.)
                else string-join(($path1, $step1), '/'[$path1 ! not(ends-with(., '/'))])
            return ufpath:addPathREC($pathNext, $tail)
};

(: 
   === getCurrentFolder()========================================= 
 :)
declare function ufpath:getCurrentFolder() as xs:string {
    file:current-dir() ! ufpath:normalizePath(.)
};

(: 
   === getFileBaseName()========================================== 
 :)
declare function ufpath:getFileBaseName($path as xs:string)
        as xs:string {
    let $pathN := ufpath:normalizePath($path)
    let $fname := $pathN ! file:name(.)
    return 
        if (not(contains($fname, '.'))) then $fname else
            $fname ! replace(., '\.[^.]+', '')[not(. eq $fname)]
};

(: 
   === removeFileNameExtension()================================== 
 :)
(:~
 : Edits a file name or file path, removiong the file name extension.
 :
 : @param path a file path or file name
 :)
declare function ufpath:removeFileNameExtension($path as xs:string)
        as xs:string {
    let $ext := $path ! ufpath:getFileNameExtension(.)
    return substring($path, 1, string-length($path) - string-length($ext))
};

(: 
   === getFileNameExtension()===================================== 
 :)
(:~
 : Returns the file name extension, or the empty string if the
 : file name does not contain a dot.
 :
 : @param path a file path or file name
 : @return the file name extension
 :)
declare function ufpath:getFileNameExtension($path as xs:string)
        as xs:string? {
    let $fname := $path ! file:name(.)        
    return $fname ! replace(., '.*?(\.[^.]+$)', '$1')[. ne $fname]
};

(:~
 : Returns an edited timestamp suitable as a name component
 : for backup.
 :
 : @return edited timestamp
 :)
declare function ufpath:getBackupTimestamp()
        as xs:string {
    prof:current-ms() ! convert:integer-to-dateTime(.) !        
    xs:string(.) ! replace(., '-|:|\.', '') ! replace(., 'T', '-') 
    ! (substring(., 1, 13)||'-'||substring(., 14, 3))
};        

(: 
   === insertBeforeFileNameExtension()============================ 
 :)
(:~
 : Inserts a label before the file name extension. If the file
 : name does not contain a dot, the label is appended to the
 : file name.
 :
 : @param path a file path or file name
 : @param label a label to be inserted
 : @return the file path or file name, with the label inserted before the
 :   file name extension
 :) 
declare function ufpath:insertBeforeFileNameExtension($path as xs:string, $label as xs:string)
        as xs:string {
    let $ext := $path ! ufpath:getFileNameExtension(.)
    return
        if (not($ext)) then $path||$label
        else
            $path ! ufpath:removeFileNameExtension(.) ! (.||$label||$ext)
};

(: 
   === getParentFolder()========================================= 
 :)
declare function ufpath:getParentFolder($path as xs:string)
        as xs:string {
    let $pathN := ufpath:normalizePath($path)
    return $pathN ! replace(., '/+[^/]*$', '')
};

(: 
   === getParentFolderName()===================================== 
 :)
declare function ufpath:getParentFolderName($path as xs:string)
        as xs:string {
    let $pathN := ufpath:normalizePath($path)
    return $pathN ! replace(., '.*/([^/]+)/[^/]+$', '$1')
};

(: 
   === hasFileNameSuffix()======================================== 
 :)
declare function ufpath:hasFileNameSuffix($filePath as xs:string, 
                                        $suffix as xs:string)
        as xs:boolean {
    let $suffixR := replace($suffix, '\.', '\\.') ! (.||'$')
    return $filePath ! file:name(.) ! matches(., $suffixR, 'i')
};

(: 
   === normalizePath() =========================================== 
 :)
(:~
 : Normalizes path:
 : - replaces \ with /
 : - removes trailing /
 : - removes "file://", if present
 : The result is either a relative path, or a path starting
 : with "/" (Unix), or a path starting with d:/ (Window,
 : where "d" represents the drive letter).
 :
 : @param path a file system path, or a file URI
 : @return the normalized path
 :) 
declare function ufpath:normalizePath($path as xs:string)
        as xs:string {
    $path
    ! replace(., '\\', '/')
    ! replace(., '/$', '')
    ! replace(., 
      '^file:/*? ((/([a-zA-Z]:/.*))$  |  (/([^/].*)?$))', '$3$4', 'x')
};

(: 
   === isPathAbsolute() ========================================== 
 :)
(:~
 : Returns true or false, dependent if a given path is absolute.
 :
 : @param path a path
 : @return true, if the path is absolute, false otherwise
 :)
declare function ufpath:isPathAbsolute($path as xs:string)
        as xs:boolean {
    $path ! ufpath:normalizePath(.) 
          ! ufpath:isNormalizedPathAbsolute(.)        
};

(:~
 : Returns true or false, dependent if a given normalized path is absolute.
 :
 : @param path a path
 : @return true, if the path is absolute, false otherwise
 :)
declare function ufpath:isNormalizedPathAbsolute($path as xs:string)
        as xs:boolean {
    $path ! matches(., '^(/|[a-z]:/)', 'i')        
};

(: 
   === resolvePath() ============================================= 
 :)
declare function ufpath:resolvePath($path as xs:string)
        as xs:string {
    ufpath:resolvePath($path, ())        
};

(: 
   === relativePath() ============================================ 
 :)
(:~
 : Returns the relative path leading from the resource at location
 : $contextPath to the resource at location $path.
 :
 : Examples:
 : Path        Context Path         Result
 : /a/b/c/d    /a/b/c/d             .
 : /a/b/c/d    /a/b/c               d
 : /a/b/c/d    /a/b                 c/d
 : /a/b/c/d    /a                   b/c/d
 : /a/b/c/d    /a/b/x/c             ../../c/d 
 : C:/a/b/c/d  C:/a/b/x/c           ../../c/d 
 :)
declare function ufpath:relativePath($path as xs:string, 
                                     $contextPath as xs:string)
        as xs:string {
    let $pathN := ufpath:normalizePath($path)
    let $pathNLC := $pathN ! lower-case(.)
    let $contextPathN := ufpath:normalizePath($contextPath) ! lower-case(.)
    let $relPath := string-join(ufpath:relativePathREC($pathNLC, $contextPathN), '/')
    let $relPathC :=
        if ($pathNLC eq $pathN) then $relPath
        else if (not(contains($relPath, '..'))) then 
            $pathN ! substring(., 1 + string-length(.) - string-length($relPath))
        else 
            let $lenPart2 := replace($relPath, '^.*\.\.', '') ! string-length(.)
            let $lenPart1 := string-length($relPath) - $lenPart2
            return
                substring($relPath, 1, $lenPart1)||
                $pathN ! substring(., 1 + string-length(.) - $lenPart2)
    return ($relPathC[string()], '.')[1]
};

declare function ufpath:relativePathREC($path as xs:string, 
                                        $contextPath as xs:string)
        as xs:string* {
    if ($path eq $contextPath) then ()
    else if (starts-with($path, $contextPath||'/')) then 
        substring-after($path, $contextPath||'/')
    else if (not(contains($contextPath, '/'))) then $path
    else ('..', $contextPath 
        ! ufpath:getParentFolder(.) 
        ! ufpath:relativePathREC($path, .))        
};

(: 
   === replaceFileNameExtension()================================= 
 :)
(:~
 : Replaces the file name extension with a string.
 :
 : @param path a file path or file name
 : @param newExt the string replacing the file name extension
 : @return the file path or name with the file name extension replaced
 :)
declare function ufpath:replaceFileNameExtension($path as xs:string, $newExt as xs:string)
        as xs:string {
    let $ext := $path ! ufpath:getFileNameExtension(.)
    return
        if (not($ext)) then $path||$newExt
        else
            $path ! ufpath:removeFileNameExtension(.) ! (.||$newExt)
};

(:~
 : Resolves a path against a context resource.
 :)
declare function ufpath:resolvePath($path as xs:string, $base as xs:string?)
        as xs:string {
    (
    if ($base) then file:resolve-path($path, $base) 
     else file:resolve-path($path)
    ) ! ufpath:normalizePath(.)
};

(: 
   === resolvePathStrict() ======================================= 
 :)
(:~
 : Resolves a path against a context resource. The resolving is independent
 : on whether the context resource is a file or a folder. Compared to
 : conventional resolving, it is treated as if ending on "/", independent
 : of whether is does or does not end on "/".
 :)
declare function ufpath:resolvePathStrict($path as xs:string, $base as xs:string?)
        as xs:string {
    (
    if ($base) then 
        $base ! ufpath:normalizePath(.) ! (.||'/') ! file:resolve-path($path, .) 
     else file:resolve-path($path)
     ) ! ufpath:normalizePath(.)
};

(: 
   === splitPath ================================================= 
 :)
(:~
 : Splits a path into a first step and the remaining path. If
 : the path is absolute, the first step is a root step (/ or
 : D:/).
 :
 : @param path a path string
 : @return two strings - the first step and the remaining path
 :)
declare function ufpath:splitPath($path as xs:string)
        as xs:string+ {
    $path ! ufpath:normalizePath(.) ! ufpath:splitNormalizedPath(.)
};        

(:~
 : Splits a path into a first step and the remaining path. If
 : the path is absolute, the first step is a root step (/ or
 : D:/).
 :
 : @param path a path string
 : @return two strings - the first step and the remaining path
 :)
declare function ufpath:splitNormalizedPath($path as xs:string)
        as xs:string+ {
    if (ufpath:isPathAbsolute($path)) then
        let $step1 := $path ! replace(., '^( / | [a-z]:/ ).*', '$1', 'ix')
        let $tail := substring($path, string-length($step1) + 1)
        return ($step1, $tail)
    else
        let $step1 := $path ! replace(., '^([^/]+)/?.*', '$1')
        let $tail := substring($path, string-length($step1) + 1) 
                     ! replace(., '^\s*/\s*', '')
        return ($step1, $tail)
};    

(: 
   === resolveFpath ============================================== 
 :)

(:~
 : Resolves an Fpath expression. It is an absolute or relative
 : path consisting of steps which are Glob expressions selecting
 : names, seperated by / or //.
 :
 : Examples:
 : - /a/b/c 
 : - /a/b*/c?
 : - /a/b//*.xml
 : - b*/*.json
 : - b*//*.csv
 :)
declare function ufpath:resolveFpath($fpath as xs:string)
        as item()* {ufpath:resolveFpath($fpath, (), ())};

(:~
 : Resolves an Fpath expression.
 :)
declare function ufpath:resolveFpath($fpath as xs:string, 
                                     $context as xs:string?)
        as item()* {ufpath:resolveFpath($fpath, $context, ())};

(:~
 : Resolves an Fpath expression.
 :)
declare function ufpath:resolveFpath($fpath as xs:string, 
                                     $context as xs:string?,
                                     $options as map(xs:string, item()*)?)
        as item()* {
    let $fpathC := ufpath:compileFpath($fpath, $context, $options)
    let $result := ufpath:resolveFpathC($fpathC)
    return if ($options?parse) then $fpathC else $result
};

declare %private function ufpath:compileFpath(
                                 $fpath as xs:string,
                                 $explicitContext as xs:string?,
                                 $options as map(xs:string, item()*)?)
        as element(fpath) {
    let $root := 
        if (not(matches($fpath, '^([a-zA-Z]:)?/'))) then ()
        else replace($fpath, '^(([a-zA-Z]:)?/).*', '$1')          
    let $context := 
        if ($root) then $root 
        else if ($explicitContext) then ufpath:resolvePath($explicitContext) 
        else ufpath:getCurrentFolder()
    let $fpathE := 
        if (not($root)) then $fpath
        else substring($fpath, string-length($root) + 1)                    
    let $as := analyze-string($fpathE, '/+')
    let $steps :=
        for $name in $as/fn:non-match
        let $op := $name/preceding-sibling::fn:match[1]
        let $axis := 
            switch($op)
            case '/' return 'child'
            case '//' return 'descendant'
            default return 'child'
        let $regex := 
            if ($name eq '.') then '' 
            else if (matches($name, '^\(.*\)$')) then
                let $expr := $name ! replace(., '^\((.*)\)$', '$1')
                let $filterObject := unamef:parseNameFilter($expr)
                return $filterObject
            else uregex:globToRegex($name, ())
        return <step axis="{$axis}">{
                   if ($regex instance of xs:anyAtomicType) then attribute name {$regex}
                   else <filter>{$regex}</filter>
               }</step>
    return
        <fpath>{
            <context path="{$context}"/>,
            <steps>{$steps}</steps>
        }</fpath>
};

(:~
 : Resolves a compiled fpath expression.
 :)
declare %private function ufpath:resolveFpathC($fpath as element(fpath))
        as xs:string* {
    let $context := $fpath/context/@path
    return ufpath:resolveFpathCREC($fpath/steps/step, $context)
};

(:~
 : Recursive helper function of function `resolvePath`.
 :)
declare %private function ufpath:resolveFpathCREC($steps as element(step)*, 
                                                  $context as xs:string*)
        as xs:string* {
    let $head := head($steps)
    let $tail := tail($steps)
    let $axis := $head/@axis
    let $name := $head/@name/string()
    let $filter := $head/filter/*
    let $_DEBUG := trace($filter, '_FILTER: ')
    let $fnNav :=
        switch($axis)
        case 'child' return file:children#1
        case 'descendant' return file:descendants#1
        default return error((), 'Unknown axis: '||$axis)
    let $context2 :=
        if (not($name)) then $context
        else if ($axis = ('child', 'descendant')) then 
            $context[file:is-dir(.)] 
        else $context
    let $newContext := if (not($name) and not($filter)) then $context2 
                       else $context2 ! $fnNav(.)[file:name(.) ! ( 
                            if ($name) then matches(., $name, 'i')
                            else unamef:matchesNameFilterObject(trace(., '_MATCH_TARGET: '), $filter))]
    return
        if ($tail) then ufpath:resolveFpathCREC($tail, $newContext)
        else $newContext ! ufpath:normalizePath(.)
};



