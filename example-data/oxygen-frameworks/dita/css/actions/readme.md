# Generating inline actions

A CSS file can provide inline actions that the user can select directly on the document view. Sometimes, for a novice user, it is useful to see the main structure of the document. We can provide that by showing actions in places where specific elements can be inserted.

Because it will be difficult to write the CSS file manually, we can specify those inline actions declaratively in a descriptor file and generate the corresponding CSS automatically using an XSLT script.

In this folder there are two descriptor files, for DITA topics and for DITA Maps, `actionsDescriptor.xml` and `actionsDescriptorMap.xml`, respectively. These can be transformed using the `generateActions.xsl` script into the corresponding CSS files, `actions.css` and `actionsMap.css`, respectively.

The CSS files are used by the DITA and DITAMap frameworks, as alternate CSS styles which can be activated by the user in order to show inline actions, thus making the structure easily available.

In oXygen, you can define a transformation scenario to spply the XSLT script on a descriptor file to obtain the CSS.
