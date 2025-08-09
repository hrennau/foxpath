(: Function options models :)
module namespace f="http://www.foxpath.org/ns/fox-functions-options";
declare function f:buildOptionMaps() {
    map{
        'frequencies': map{
            'options': map{
                'format': map{'default': 'txt',
                              'check': map{'values': ('txt', 'xml', 'json', 'lines')}},
                'freq': map{'default': 'count', 
                            'check': map{'values': ('count', 'fraction', 'percent')}},
                'order': map{'default': 'a', 
                             'check': map{'values': ('a', 'd', 'an', 'dn', 'af', 'df')}},
                'min': map{'check': map{'type': 'integer'}},
                'max': map{'check': map{'type': 'integer'}},
                'width': map{'check': map{'type': 'integer'}}
            },
            'values': map{
                'txt': 'format',
                'xml': 'format',
                'json': 'format',
                'lines': 'format',
                'count': 'freq',
                'fraction': 'freq',
                'percent': 'freq',
                'a': 'order',
                'd': 'order',
                'an': 'order',
                'ad': 'order', 
                'af': 'order',
                'df': 'order'
            }
        },
        'namePath': map{
            'options': map{
                'atts': map{'check': map{'type': 'text'}},            
                'format': map{'default': 'txt',
                              'check': map{'values': ('txt', 'xml', 'json')}},
                'indexed': (),
                'length': map{'default': 60, 'check': map{'type': 'integer'}},                
                'namekind': map{'default': 'lname',
                                'check': map{'values': ('name', 'lname', 'jname')}},
                'pre': map{'check': map{'values': ('base-name', 'base-path', 'base-relpath')}}, 
                'post': map{'check': 
                        map{'values': ('value')}},
                'steps': map{'check': map{'type': 'integer'}},                        
                'text': (),    
                'withcontext': ()
            },
            'values': map{
                'txt': 'format',
                'xml': 'format',
                'json': 'format',
                'name': 'namekind',
                'lname': 'namekind',
                'jname': 'namekind',
                'base-name': 'pre',
                'base-path': 'pre',
                'base-relpath': 'pre',
                'value': 'post'
            }
        },
        'pathContent': map{
            'options': map{
                'withinner': (),            
                'format': map{'default': 'txt',
                              'check': map{'values': ('txt', 'xml', 'json')}},
                'namekind': map{'default': 'lname',
                                'check': map{'values': ('name', 'lname', 'jname')}},
                'freq': map{'default': 'count', 
                            'check': map{'values': ('count', 'fraction', 'percent')}},
                'order': map{'default': 'a', 
                             'check': map{'values': ('a', 'd', 'an', 'dn', 'af', 'df')}},
                'pre': map{'check': map{'values': ('base-name', 'base-path', 'base-relpath')}},                                
                'post': map{'check': 
                        map{'values': ('value')}},                
                'min': map{'check': map{'type': 'integer'}},
                'max': map{'check': map{'type': 'integer'}},
                'width': map{'check': map{'type': 'integer'}},                                
                'length': map{'default': 60, 'check': map{'type': 'integer'}},
                'atts': map{'check': map{'type': 'text'}}
            },
            'values': map{
                'txt': 'format',
                'xml': 'format',
                'json': 'format',
                'name': 'namekind',
                'lname': 'namekind',
                'jname': 'namekind',
                'count': 'freq',
                'fraction': 'freq',
                'percent': 'freq',
                'a': 'order',
                'd': 'order',
                'an': 'order',
                'ad': 'order', 
                'af': 'order',
                'df': 'order',
                'base-name': 'pre',
                'base-path': 'pre',
                'base-relpath': 'pre',
                'value': 'post'
            }        
        }        
    }
};
