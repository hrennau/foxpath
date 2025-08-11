(: Function options models :)
module namespace f="http://www.foxpath.org/ns/fox-functions-options";
declare function f:buildOptionMaps() {
  map{
    'frequencies': map{
      'options': map{
        'format': map{
          'type': 'string',
          'default': 'txt',
          'values': ('txt', 'xml', 'json', 'lines')
        },
        'freq': map{
          'type': 'string',
          'default': 'count',
          'values': ('count', 'fraction', 'percent')
        },
        'order': map{
          'type': 'string',
          'default': 'a',
          'values': ('a', 'd', 'an', 'dn', 'af', 'df')
        },
        'min': map{
          'type': 'integer'
        },
        'max': map{
          'type': 'integer'
        },
        'width': map{
          'type': 'integer'
        }
      },
      'optionValues': map{
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
        'dn': 'order',
        'af': 'order',
        'df': 'order'
      }
    },
    'namePath': map{
      'options': map{
        'atts': map{
          'type': 'string'
        },
        'format': map{
          'type': 'string',
          'default': 'txt',
          'values': ('txt', 'xml', 'json')
        },
        'indexed': (),
        'length': map{
          'type': 'integer',
          'default': 60
        },
        'namekind': map{
          'type': 'string',
          'default': 'lname',
          'values': ('name', 'lname', 'jname')
        },
        'post': map{
          'type': 'string',
          'values': ('value')
        },
        'pre': map{
          'type': 'string',
          'values': ('base-name', 'base-path', 'base-relpath')
        },
        'steps': map{
          'type': 'integer'
        },
        'text': (),
        'withcontext': ()
      },
      'optionValues': map{
        'txt': 'format',
        'xml': 'format',
        'json': 'format',
        'name': 'namekind',
        'lname': 'namekind',
        'jname': 'namekind',
        'value': 'post',
        'base-name': 'pre',
        'base-path': 'pre',
        'base-relpath': 'pre'
      }
    },
    'pathContent': map{
      'options': map{
        'atts': map{
          'type': 'string'
        },
        'format': map{
          'values': ('txt', 'xml', 'json')
        },
        'freq': map{
          'type': 'string',
          'default': 'count',
          'values': ('count', 'fraction', 'percent')
        },
        'length': map{
          'type': 'integer',
          'default': 60
        },
        'min': map{
          'type': 'integer'
        },
        'max': map{
          'type': 'integer'
        },
        'namekind': map{
          'type': 'string',
          'default': 'lname',
          'values': ('name', 'lname', 'jname')
        },
        'order': map{
          'type': 'string',
          'default': 'a',
          'values': ('a', 'd', 'an', 'dn', 'af', 'df')
        },
        'post': map{
          'type': 'string',
          'values': ('value')
        },
        'pre': map{
          'type': 'string',
          'values': ('base-name', 'base-path', 'base-relpath')
        },
        'width': map{
          'type': 'integer'
        },
        'withinner': ()
      },
      'optionValues': map{
        'txt': 'format',
        'xml': 'format',
        'json': 'format',
        'count': 'freq',
        'fraction': 'freq',
        'percent': 'freq',
        'name': 'namekind',
        'lname': 'namekind',
        'jname': 'namekind',
        'a': 'order',
        'd': 'order',
        'an': 'order',
        'dn': 'order',
        'af': 'order',
        'df': 'order',
        'value': 'post',
        'base-name': 'pre',
        'base-path': 'pre',
        'base-relpath': 'pre'
      }
    }
  }
};