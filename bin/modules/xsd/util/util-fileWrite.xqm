(:~
util-fileWrite.xqm - utility functions for copying and writing files

Version 20131030 # initial version
:)

(: ============================================================================== :)

module namespace ufwrite="http://www.parsqube.de/xquery/util/file-write";
import module namespace ufpath="http://www.parsqube.de/xquery/util/file-path"
  at "util-filePath.xqm";

(: 
   === copyFile ================================================== 
 :)
(:~
 : Copies a file. Rules:
 : (1) If the target path does not yet exist, it is interpreted as file path, 
 :     and the containing folder will be created, if not already existing.
 : (2) If the target path exists and is a folder, the file will be copied into 
 :     the folder, possibly overwriting an existing file. 
 : (3) If the target path exists and is a file, it will be overwritten.
 :)
declare function ufwrite:copyFile($sourcePath as xs:string,
                                  $targetPath as xs:string)
        as empty-sequence() {
    let $sourcePathR := $sourcePath ! ufpath:resolvePath(.)        
    let $targetPathR := $targetPath ! ufpath:resolvePath(.)
    return
        if (file:exists($targetPathR)) then file:copy($sourcePathR, $targetPathR)
        else
        
    let $targetFolder := ufpath:getParentFolder($targetPathR)
    let $_CREATE_DIR :=
        if (not(file:exists($targetPathR))) then file:create-dir($targetFolder)
        else ()
    return file:copy($sourcePathR, $targetPathR)        
};

(:~
 : Writes a document to the file system. If the folder does not
 : yet exist, it is now created. By default, the document is
 : serialized in indented style.
 :
 : @param path file path (absolute or relative or current work dir)
 : @param doc the root node of the document to write
 : @param indent if yes/no, serialize with/without indentation;
 :   default: true
 : @return empty sequence
 :)
declare function ufwrite:writeDoc($path as xs:string, 
                                  $doc as node(),
                                  $indent as xs:boolean?)
        as empty-sequence() {
    let $indentE := ($indent, true())[1]        
    let $pathR := $path ! ufpath:resolvePath(.)
    let $folder := $path ! ufpath:getParentFolder(.)
    let $_CREATE := if (file:exists($folder)) then () else file:create-dir($folder)
    return file:write($pathR, $doc, map{'indent': $indentE})
};        
