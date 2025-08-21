module namespace ftree="http://www.parsqube.de/xquery/util/ftree";
import module namespace ufp="http://www.parsqube.de/xquery/util/file-path"
    at "util-filePath.xqm";

(:~
 : Creates a file system tree document. Return an <ftree> or
 : an <ftrees> document.
 :
 : File properties are described by (a) an optional file name
 : pattern, (b) a property name, (c) a property retrieval
 : expression.
 :)
declare function ftree:ftree($paths as xs:string*,
                             $rootPath as xs:string?) as element(*)? {
    let $rootPathR := ufp:resolvePath($rootPath)
    let $notContainedPaths :=
        $paths[not(matches(., '^'||$rootPath||'(/.*)?$'))]
    return
        if (exists($notContainedPaths)) then 
            error(QName((), 'INVALID_ARG'), 'Paths not under root path: '||
                string-join($notContainedPaths, ', '))
        else
    let $children := 
        let $relPaths := 
            $paths[file:is-file(.)] 
            ! ufp:relativePath(., $rootPathR) => sort()
        return ftree:ftreeREC($relPaths, $rootPathR)
    return
        <fo path="{$rootPathR}">{$children}</fo>
};

declare function ftree:ftreeREC($paths as xs:string*,
                                $context as xs:string) 
        as element()* {
    let $files := 
        $paths[not(contains(., '/'))][file:is-file($context||'/'||.)]
    let $folders := $paths[not(. = $files)]
    let $fileElems := $files ! <fi name="{.}"/>
    let $folderTrees :=
        for $folder in $folders
        group by $name := replace($folder, '/.*', '')
        let $newContext := $context||'/'||$name
        let $newPaths := $folder[contains(., '/')] ! replace(., '^.*?/', '')
        let $childFolderTrees := $newPaths => ftree:ftreeREC($newContext)
        return
            <fo name="{$name}">{$childFolderTrees}</fo>
    return ($folderTrees, $fileElems)
};
