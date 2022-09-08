org.dita-community.adjust-copy-to
=================================

Post processes the resolved map (output of the mappull preprocess step)
in order to add additional copy-to values in order to ensure unique
result files for all references to a given topic or to impose additional
output filenaming rules, such as using navigation keys for result filenames.

The copy-to adjustment is turned on by default. Turn it off using the args.dc-adjust-copy-to.skip 
Ant parameter.

This process should be run between the mappull and chunk steps of the normal
OT preprocess sequence.   

Depends on the org.dita-community-common.xslt plugin <https://github.com/dita-community/org.dita-community.common.xslt>

## Ant Properties

* args.dc-adjust-copy-to.skip - Set to any value (e.g., "true") to turn off copy-to adjustment.

### Testing Notes

The directory test/Chunkattribute is copied from the OT's testsuite repo (https://github.com/dita-ot/testsuite)
