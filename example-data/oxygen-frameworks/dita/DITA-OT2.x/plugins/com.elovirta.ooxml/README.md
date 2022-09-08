DITA to Word plug-in
====================

A DITA-OT plug-in to generate [Office Open XML (OOXML)](https://en.wikipedia.org/wiki/Office_Open_XML) output from DITA source.

Installation
------------

Standard DITA-OT plug-in installation, see [DITA-OT documentation](http://www.dita-ot.org/2.4/dev_ref/plugins-installing.html). Only latests stable version of DITA-OT is supported.

```shell
$ dita -install https://github.com/jelovirt/com.elovirta.ooxml/archive/master.zip
```

Running
-------

Use the `docx` transtype to create DOCX output.

```shell
$ dita -i guide.ditamap -f docx
```

See [documentation](https://github.com/jelovirt/com.elovirta.ooxml/wiki) for more information.

Donating
--------

Support this project and others by [@jelovirt](https://github.com/jelovirt) via [Paypal](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=jarno%40elovirta%2ecom&lc=FI&item_name=Support%20Open%20Source%20work&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_LG%2egif%3aNonHosted).

License
-------

The DITA to Word plug-in is released under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)
