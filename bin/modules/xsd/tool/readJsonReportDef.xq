declare variable $rdef external;
declare variable $rtype external;

let $doc := 
    try {doc($rdef)} catch * {'Cannot read report def document: '||$rdef}
return if (not($doc)) then () else

let $report := $doc//$doc//report[@name eq $rtype]
let $cases := $report//case
return if (not($cases)) then () else

for $case in $cases return map:merge(
for $att in $case/ancestor-or-self::*[. >> $report]/@*
group by $attName := $att/name()
let $att2 := $att[last()]
return
    $att2/map:entry(local-name(.), string())
)
    
