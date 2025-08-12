(: Function options models :)
module namespace f="http://www.foxpath.org/ns/fox-functions-options";
declare function f:buildOptionMaps() {
  map{
    'basedir-name': map{
      'options': map{},
      'optionValues': map{}
    },
    'basedir-path': map{
      'options': map{},
      'optionValues': map{}
    },
    'basedir-relpath': map{
      'options': map{},
      'optionValues': map{}
    },
    'basedir-reluri': map{
      'options': map{},
      'optionValues': map{}
    },
    'basedir-uri': map{
      'options': map{},
      'optionValues': map{}
    },
    'base-name': map{
      'options': map{},
      'optionValues': map{}
    },
    'base-path': map{
      'options': map{},
      'optionValues': map{}
    },
    'base-relpath': map{
      'options': map{},
      'optionValues': map{}
    },
    'base-reluri': map{
      'options': map{},
      'optionValues': map{}
    },
    'base-uri': map{
      'options': map{},
      'optionValues': map{}
    },
    'filter-items': map{
      'options': map{},
      'optionValues': map{}
    },
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
    'matches-pattern': map{
      'options': map{},
      'optionValues': map{}
    },
    'name-path': map{
      'options': map{
        'atts': map{
          'type': 'string'
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
        'name': 'namekind',
        'lname': 'namekind',
        'jname': 'namekind',
        'value': 'post',
        'base-name': 'pre',
        'base-path': 'pre',
        'base-relpath': 'pre'
      }
    },
    'path-content': map{
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
    },
    'truncate': map{
      'options': map{
        'strict': (),
        'info': map{
          'type': 'string',
          'default': 'dots',
          'values': ('empty', 'dots', 'count')
        }
      },
      'optionValues': map{
        'empty': 'info',
        'dots': 'info',
        'count': 'info'
      }
    }
  }
};