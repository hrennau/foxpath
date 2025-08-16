(: Function options models :)
module namespace op="http://www.foxpath.org/ns/fox-functions-options";

(: declare variable $f:OPTION_MODELS := prof:time(opt:buildOptionMaps()); :)
declare variable $op:OPTION_MODELS := op:buildOptionMaps();
declare variable $op:PARAM_MODELS := op:buildParamMaps();
        
declare function op:buildOptionMaps() {
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
    },
    'table': map{
      'options': map{
        'format': map{
          'type': 'string',
          'default': 'txt',
          'values': ('txt', 'xml')
        },
        'hanging': map{
          'type': 'integer'
        },
        'initial-prefix': map{
          'type': 'string'
        },
        'nil': map{
          'type': 'string'
        },
        'order': map{
          'type': 'string',
          'pattern': '^\d+(a|d|c|an|dn|ac|dc)?(\.\d+(a|d|c|an|dn|ac|dc)?)*$',
          'patternExplanation': 'The value must consists of one or more dot-separated items, each one consisting of a column number, optionally followed by a|d|n|c|an|dn|ac|dc, meaning ascending, descending, ascending numeric, descending numeric, ascending case-insensitive, descending case-insensitive. Examples: 3, 3.1, 3c.1c, 3dn.1c, 3dn.1c.4'
        },
        'split': map{
          'type': 'string'
        },
        'width': map{
          'type': 'integer'
        }
      },
      'optionValues': map{
        'txt': 'format',
        'xml': 'format'
      }
    }
  }
};
declare function op:buildParamMaps() {
  map{
    'colspec': map{
      'options': map{
        'hanging': map{
          'type': 'integer'
        },
        'items': (),
        'leftalign': (),
        'initial-prefix': map{
          'type': 'string'
        },
        'nil': map{
          'type': 'string'
        },
        'split': map{
          'type': 'string'
        },
        'width': map{
          'type': 'integer'
        }
      },
      'optionValues': map{}
    }
  }
};