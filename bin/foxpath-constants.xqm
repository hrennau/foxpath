(: module foxpath-constants.xqm - constants :)
module namespace const="http://www.foxpath.org/ns/constants";

import module namespace opt="http://www.foxpath.org/ns/fox-functions-options" 
at "foxpath-fox-functions-options.gen.xqm";

declare variable $const:NS_FOX := 'http://www.foxpath.org/ns';

(: declare variable $f:OPTION_MODELS := prof:time(opt:buildOptionMaps()); :)
declare variable $const:OPTION_MODELS := opt:buildOptionMaps();
declare variable $const:PARAM_MODELS := opt:buildParamMaps();


