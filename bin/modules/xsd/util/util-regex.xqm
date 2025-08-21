(:~
util-regex.xqm - utility functions handling regular expressions

Version 20131301 # initial version
:)
module namespace rgx="http://www.parsqube.de/xquery/util/regex";

(: 
   === globToRegex()============================================== 
 :)
 (:~
 : Maps a glob pattern to a regular expression.
 :
 : @param glob a glob pattern
 : @param noAnchors if true, the constructed regex does not have anchors 
 :   marking the begin and end of the string 
 : @return a regular expression
 :)
declare function rgx:globToRegex($glob as xs:string, 
                                 $noAnchors as xs:boolean?)
        as xs:string {
    $glob        
    ! replace(., '\\s', ' ')
    ! replace(., '[.+|\\(){}\[\]\^$]', '\\$0')        
    ! replace(., '\*', '.*')
    ! replace(., '\?', '.')
    ! (if ($noAnchors) then . else ('^'||.||'$'))
};

(: 
   === multiMatches() ============================================ 
 :)
(:~
 : Checks if a string matches at least one of a set of regular expressions.
 :
 : @param s a string
 : @param regexes a set of regular expressions
 : @param flags a string containing regex flags (i, x, s)
 : @return true or false
 :)
declare function rgx:multiMatches($s as xs:string, 
                                  $regexes as xs:string*, 
                                  $flags as xs:string?)
        as xs:boolean {
    some $regex in $regexes satisfies matches($s, $regex, $flags)            
};        


 