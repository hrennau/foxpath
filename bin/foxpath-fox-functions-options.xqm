module namespace f="http://www.foxpath.org/ns/fox-functions-options";
declare function f:buildOptionMaps() {
    map{
        'frequencies': map{
            'txt': (), 'xml': (), 'json': (), 'lines': (),
            'freq': map{'default': 'count', 
                        'check': map{'values': ('count', 'fraction', 'percent')}},
            'order': map{'default': 'a', 
                         'check': map{'values': ('a', 'd', 'n', 'N', 'f', 'F')}},
            'min': map{'check': map{'type': 'integer'}},
            'max': map{'check': map{'type': 'integer'}},
            'width': map{'check': map{'type': 'integer'}}
        },
        'namePath': map{
            'txt': (), 'xml': (), 'json': (),        
            'name': (), 'lname': (), 'jname': (),            
            'fname': (), 'fpath': (), 'fpathrel': (),
            'value': (), 'text': (), 'indexed': (),
            'length': map{'default': 60, 'check': map{'type': 'integer'}},
            'steps': map{'check': map{'type': 'integer'}},
            'atts': map{'check': map{'type': 'text'}}
        },
        'pathContent': map{
            'txt': (), 'xml': (), 'json': (),        
            'with-inner': (),

            'name': (), 'lname': (), 'jname': (),
            'fname': (), 'fpath': (), 'fpathrel': (),            
            'value': (), 'text': (), 'indexed': (),
            'length': map{'default': 60, 'check': map{'type': 'integer'}},
            'atts': map{'check': map{'type': 'text'}},
            
            'freq': map{'default': 'count', 
                        'check': map{'values': ('count', 'fraction', 'percent')}},
            'order': map{'default': 'a', 
                         'check': map{'values': ('a', 'd', 'n', 'N', 'f', 'F')}},
            'min': map{'check': map{'type': 'integer'}},
            'max': map{'check': map{'type': 'integer'}},
            'width': map{'check': map{'type': 'integer'}}
        },
        
        'DUMMY1': map{
            'x1': (),
            'lname': (),
            'jname': (),
            'with-inner': (),
            'text': (),
            'indexed': (),

            'format': map{'default': 'text', 
                          'check': map{'values': ('text', 'xml', 'json')}},
            'width': map{'check': map{'type': 'integer'}},
            'order': map{'default': 'a', 
                          'check': map{'values': ('a', 'd', 'n', 'N', 'f', 'F')}},
            'min': map{'check': map{'type': 'integer'}},
            'max': map{'check': map{'type': 'integer'}},
            'freq': map{'default': 'count', 
                        'check': map{'values': ('count', 'fraction', 'percent')}}
        },
        'DUMMY2': map{
            'x2': (),
            'lname': (),
            'jname': (),
            'with-inner': (),
            'text': (),
            'indexed': (),

            'format': map{'default': 'text', 
                          'check': map{'values': ('text', 'xml', 'json')}},
            'width': map{'check': map{'type': 'integer'}},
            'order': map{'default': 'a', 
                          'check': map{'values': ('a', 'd', 'n', 'N', 'f', 'F')}},
            'min': map{'check': map{'type': 'integer'}},
            'max': map{'check': map{'type': 'integer'}},
            'freq': map{'default': 'count', 
                        'check': map{'values': ('count', 'fraction', 'percent')}}
        },
        'DUMMY3': map{
            'x3': (),
            'lname': (),
            'jname': (),
            'with-inner': (),
            'text': (),
            'indexed': (),

            'format': map{'default': 'text', 
                          'check': map{'values': ('text', 'xml', 'json')}},
            'width': map{'check': map{'type': 'integer'}},
            'order': map{'default': 'a', 
                          'check': map{'values': ('a', 'd', 'n', 'N', 'f', 'F')}},
            'min': map{'check': map{'type': 'integer'}},
            'max': map{'check': map{'type': 'integer'}},
            'freq': map{'default': 'count', 
                        'check': map{'values': ('count', 'fraction', 'percent')}}
        },
        'DUMMY4': map{
            'x4': (),
            'lname': (),
            'jname': (),
            'with-inner': (),
            'text': (),
            'indexed': (),

            'format': map{'default': 'text', 
                          'check': map{'values': ('text', 'xml', 'json')}},
            'width': map{'check': map{'type': 'integer'}},
            'order': map{'default': 'a', 
                          'check': map{'values': ('a', 'd', 'n', 'N', 'f', 'F')}},
            'min': map{'check': map{'type': 'integer'}},
            'max': map{'check': map{'type': 'integer'}},
            'freq': map{'default': 'count', 
                        'check': map{'values': ('count', 'fraction', 'percent')}}
        },
        
        'DUMMY5': map{
            'x5': (),
            'lname': (),
            'jname': (),
            'with-inner': (),
            'text': (),
            'indexed': (),

            'format': map{'default': 'text', 
                          'check': map{'values': ('text', 'xml', 'json')}},
            'width': map{'check': map{'type': 'integer'}},
            'order': map{'default': 'a', 
                          'check': map{'values': ('a', 'd', 'n', 'N', 'f', 'F')}},
            'min': map{'check': map{'type': 'integer'}},
            'max': map{'check': map{'type': 'integer'}},
            'freq': map{'default': 'count', 
                        'check': map{'values': ('count', 'fraction', 'percent')}}
        },
        'DUMMY6': map{
            'x6': (),
            'lname': (),
            'jname': (),
            'with-inner': (),
            'text': (),
            'indexed': (),

            'format': map{'default': 'text', 
                          'check': map{'values': ('text', 'xml', 'json')}},
            'width': map{'check': map{'type': 'integer'}},
            'order': map{'default': 'a', 
                          'check': map{'values': ('a', 'd', 'n', 'N', 'f', 'F')}},
            'min': map{'check': map{'type': 'integer'}},
            'max': map{'check': map{'type': 'integer'}},
            'freq': map{'default': 'count', 
                        'check': map{'values': ('count', 'fraction', 'percent')}}
        },
        'DUMMY7': map{
            'x7': (),
            'lname': (),
            'jname': (),
            'with-inner': (),
            'text': (),
            'indexed': (),

            'format': map{'default': 'text', 
                          'check': map{'values': ('text', 'xml', 'json')}},
            'width': map{'check': map{'type': 'integer'}},
            'order': map{'default': 'a', 
                          'check': map{'values': ('a', 'd', 'n', 'N', 'f', 'F')}},
            'min': map{'check': map{'type': 'integer'}},
            'max': map{'check': map{'type': 'integer'}},
            'freq': map{'default': 'count', 
                        'check': map{'values': ('count', 'fraction', 'percent')}}
        },
        'DUMMY8': map{
            'x8': (),
            'lname': (),
            'jname': (),
            'with-inner': (),
            'text': (),
            'indexed': (),

            'format': map{'default': 'text', 
                          'check': map{'values': ('text', 'xml', 'json')}},
            'width': map{'check': map{'type': 'integer'}},
            'order': map{'default': 'a', 
                          'check': map{'values': ('a', 'd', 'n', 'N', 'f', 'F')}},
            'min': map{'check': map{'type': 'integer'}},
            'max': map{'check': map{'type': 'integer'}},
            'freq': map{'default': 'count', 
                        'check': map{'values': ('count', 'fraction', 'percent')}}
        },
        'DUMMY9': map{
            'x9': (),
            'lname': (),
            'jname': (),
            'with-inner': (),
            'text': (),
            'indexed': (),

            'format': map{'default': 'text', 
                          'check': map{'values': ('text', 'xml', 'json')}},
            'width': map{'check': map{'type': 'integer'}},
            'order': map{'default': 'a', 
                          'check': map{'values': ('a', 'd', 'n', 'N', 'f', 'F')}},
            'min': map{'check': map{'type': 'integer'}},
            'max': map{'check': map{'type': 'integer'}},
            'freq': map{'default': 'count', 
                        'check': map{'values': ('count', 'fraction', 'percent')}}
        },
        'DUMMY10': map{
            'x10': (),
            'lname': (),
            'jname': (),
            'with-inner': (),
            'text': (),
            'indexed': (),

            'format': map{'default': 'text', 
                          'check': map{'values': ('text', 'xml', 'json')}},
            'width': map{'check': map{'type': 'integer'}},
            'order': map{'default': 'a', 
                          'check': map{'values': ('a', 'd', 'n', 'N', 'f', 'F')}},
            'min': map{'check': map{'type': 'integer'}},
            'max': map{'check': map{'type': 'integer'}},
            'freq': map{'default': 'count', 
                        'check': map{'values': ('count', 'fraction', 'percent')}}
        },
        
        'DUMMY11': map{
            'x11': (),
            'lname': (),
            'jname': (),
            'with-inner': (),
            'text': (),
            'indexed': (),

            'format': map{'default': 'text', 
                          'check': map{'values': ('text', 'xml', 'json')}},
            'width': map{'check': map{'type': 'integer'}},
            'order': map{'default': 'a', 
                          'check': map{'values': ('a', 'd', 'n', 'N', 'f', 'F')}},
            'min': map{'check': map{'type': 'integer'}},
            'max': map{'check': map{'type': 'integer'}},
            'freq': map{'default': 'count', 
                        'check': map{'values': ('count', 'fraction', 'percent')}}
        },
        'DUMMY12': map{
            'x12': (),
            'lname': (),
            'jname': (),
            'with-inner': (),
            'text': (),
            'indexed': (),

            'format': map{'default': 'text', 
                          'check': map{'values': ('text', 'xml', 'json')}},
            'width': map{'check': map{'type': 'integer'}},
            'order': map{'default': 'a', 
                          'check': map{'values': ('a', 'd', 'n', 'N', 'f', 'F')}},
            'min': map{'check': map{'type': 'integer'}},
            'max': map{'check': map{'type': 'integer'}},
            'freq': map{'default': 'count', 
                        'check': map{'values': ('count', 'fraction', 'percent')}}
        },
        'DUMMY13': map{
            'x13': (),
            'lname': (),
            'jname': (),
            'with-inner': (),
            'text': (),
            'indexed': (),

            'format': map{'default': 'text', 
                          'check': map{'values': ('text', 'xml', 'json')}},
            'width': map{'check': map{'type': 'integer'}},
            'order': map{'default': 'a', 
                          'check': map{'values': ('a', 'd', 'n', 'N', 'f', 'F')}},
            'min': map{'check': map{'type': 'integer'}},
            'max': map{'check': map{'type': 'integer'}},
            'freq': map{'default': 'count', 
                        'check': map{'values': ('count', 'fraction', 'percent')}}
        },
        'DUMMY14': map{
            'x14': (),
            'lname': (),
            'jname': (),
            'with-inner': (),
            'text': (),
            'indexed': (),

            'format': map{'default': 'text', 
                          'check': map{'values': ('text', 'xml', 'json')}},
            'width': map{'check': map{'type': 'integer'}},
            'order': map{'default': 'a', 
                          'check': map{'values': ('a', 'd', 'n', 'N', 'f', 'F')}},
            'min': map{'check': map{'type': 'integer'}},
            'max': map{'check': map{'type': 'integer'}},
            'freq': map{'default': 'count', 
                        'check': map{'values': ('count', 'fraction', 'percent')}}
        },
        
        'DUMMY15': map{
            'x15': (),
            'lname': (),
            'jname': (),
            'with-inner': (),
            'text': (),
            'indexed': (),

            'format': map{'default': 'text', 
                          'check': map{'values': ('text', 'xml', 'json')}},
            'width': map{'check': map{'type': 'integer'}},
            'order': map{'default': 'a', 
                          'check': map{'values': ('a', 'd', 'n', 'N', 'f', 'F')}},
            'min': map{'check': map{'type': 'integer'}},
            'max': map{'check': map{'type': 'integer'}},
            'freq': map{'default': 'count', 
                        'check': map{'values': ('count', 'fraction', 'percent')}}
        },
        'DUMMY16': map{
            'x16': (),
            'lname': (),
            'jname': (),
            'with-inner': (),
            'text': (),
            'indexed': (),

            'format': map{'default': 'text', 
                          'check': map{'values': ('text', 'xml', 'json')}},
            'width': map{'check': map{'type': 'integer'}},
            'order': map{'default': 'a', 
                          'check': map{'values': ('a', 'd', 'n', 'N', 'f', 'F')}},
            'min': map{'check': map{'type': 'integer'}},
            'max': map{'check': map{'type': 'integer'}},
            'freq': map{'default': 'count', 
                        'check': map{'values': ('count', 'fraction', 'percent')}}
        },
        'DUMMY17': map{
            'x17': (),
            'lname': (),
            'jname': (),
            'with-inner': (),
            'text': (),
            'indexed': (),

            'format': map{'default': 'text', 
                          'check': map{'values': ('text', 'xml', 'json')}},
            'width': map{'check': map{'type': 'integer'}},
            'order': map{'default': 'a', 
                          'check': map{'values': ('a', 'd', 'n', 'N', 'f', 'F')}},
            'min': map{'check': map{'type': 'integer'}},
            'max': map{'check': map{'type': 'integer'}},
            'freq': map{'default': 'count', 
                        'check': map{'values': ('count', 'fraction', 'percent')}}
        },
        'DUMMY18': map{
            'x18': (),
            'lname': (),
            'jname': (),
            'with-inner': (),
            'text': (),
            'indexed': (),

            'format': map{'default': 'text', 
                          'check': map{'values': ('text', 'xml', 'json')}},
            'width': map{'check': map{'type': 'integer'}},
            'order': map{'default': 'a', 
                          'check': map{'values': ('a', 'd', 'n', 'N', 'f', 'F')}},
            'min': map{'check': map{'type': 'integer'}},
            'max': map{'check': map{'type': 'integer'}},
            'freq': map{'default': 'count', 
                        'check': map{'values': ('count', 'fraction', 'percent')}}
        },
        'DUMMY19': map{
            'x19': (),
            'lname': (),
            'jname': (),
            'with-inner': (),
            'text': (),
            'indexed': (),

            'format': map{'default': 'text', 
                          'check': map{'values': ('text', 'xml', 'json')}},
            'width': map{'check': map{'type': 'integer'}},
            'order': map{'default': 'a', 
                          'check': map{'values': ('a', 'd', 'n', 'N', 'f', 'F')}},
            'min': map{'check': map{'type': 'integer'}},
            'max': map{'check': map{'type': 'integer'}},
            'freq': map{'default': 'count', 
                        'check': map{'values': ('count', 'fraction', 'percent')}}
        },
        'DUMMY20': map{
            'x20': (),
            'lname': (),
            'jname': (),
            'with-inner': (),
            'text': (),
            'indexed': (),

            'format': map{'default': 'text', 
                          'check': map{'values': ('text', 'xml', 'json')}},
            'width': map{'check': map{'type': 'integer'}},
            'order': map{'default': 'a', 
                          'check': map{'values': ('a', 'd', 'n', 'N', 'f', 'F')}},
            'min': map{'check': map{'type': 'integer'}},
            'max': map{'check': map{'type': 'integer'}},
            'freq': map{'default': 'count', 
                        'check': map{'values': ('count', 'fraction', 'percent')}}
        }
        
        
        
        
    }
};
