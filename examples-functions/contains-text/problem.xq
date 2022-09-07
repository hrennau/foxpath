declare function local:function($anchor) {
    $anchor
};

let $s := 'a^^b'
return (
    $s,
    $s ! replace(., '\^+', '^')
),
local:function('^')
