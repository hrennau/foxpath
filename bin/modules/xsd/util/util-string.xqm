(:~
util-string.xqm - utility functions handling strings

Version 20131031 # initial version
:)

(: ============================================================================== :)

module namespace ustr="http://www.parsqube.de/xquery/util/string";

(: 
   === mergeCamelCase()================================================= 
 :)
(:~
 : Merges strings to a single string in camel case syntax. The first
 : character of every string except for the first one is changed into
 : uppercase. Exemple: ('abc', 'xyz') -> 'abcXyz'.
 :
 : @param parts a sequence of strings
 : @return the merged string with camel case syntax
 :)
declare function ustr:mergeCamelCase($parts as xs:string*) {
    if (count($parts) le 1) then $parts else string-join((
        $parts[1],
        tail($parts) ! (upper-case(substring(., 1, 1))||substring(., 2)))
        , '')
};

(: 
   === trim()===================================================== 
 :)
(:~
 : Removes leading and trailing whitespace.
 :
 : @param s a string
 : @return the edited string
 :)
declare function ustr:trim($s as xs:string) {
    replace($s, '^\s+|\s+$', '')
};

(: 
   === repeatString()============================================= 
 :)
(:~
 : Concatenates repetitions of a string.
 :
 : @param s a string
 : @param count the number of repetitions
 : @return the concatenated repetitions
 :)
declare function ustr:repeatString($s as xs:string, $count as xs:integer)
        as xs:string {
    (for $i in 1 to $count return $s) => string-join('')        
};

(: 
   === truncate()============================================= 
 :)
(:~
 : Truncates a string to a given maximum length. Does not change
 : the string if the length is le the maximum length. Otherwise
 : returns a string composed of a substring of the string,
 : followed by ' ...'. 
 :
 : @param s a string
 : @param length the maximumlength
 : @return the truncated string
 :)
declare function ustr:truncate($s as xs:string, $length as xs:integer)
        as xs:string {
    let $actLength := string-length($s)
    return
        if ($actLength le $length) then $s        
        else substring($s, 1, $actLength - 4)||' ...' 
};
