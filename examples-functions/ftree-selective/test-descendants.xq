declare variable $mode external;
declare variable $dir external := ();
switch($mode)
case 'f' return file:read-text('COPYRIGHT-NOTICE.txt')
case 'u' return unparsed-text('COPYRIGHT-NOTICE.txt')
case 'c' return file:children($dir)
case 'cr' return file:children($dir) ! file:resolve-path(., file:current-dir())
case 'cn' return file:children($dir) ! file:path-to-native(.)
case 'cu' return file:children($dir) ! file:path-to-native(.) ! file:path-to-uri(.)
default return error()