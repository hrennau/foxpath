org.dita-community.preprocess-extensions
========================================

Provides extensions or customizations to the base Open Toolkit
preprocessing pipeline. 

Depends on the org.dita-community.adjust-copy-to plugin <https://github.com/dita-community/org.dita-community.adjust-copy-to>

Provides the following alternative Ant targets to replace the built-in "preprocess"
target:

### "dc-preprocess"

Extends the base preprocessing by doing a second pass over the resolved map to
adjust the copy-to values on topicrefs. The copy-to adjustment
ensures that each reference to a given topic after the first is assigned a unique 
copy-to value. This has the effect of ensuring, in HTML outputs, that all HTML files are
unique for each use of a topic (important for EPUB and for HTML Web sites that use
prev/next navigation and should reflect exactly one location in the ToC hierarchy for
a given use of a topic).

### "dc-process-map-first"

Rearchitects the Open Toolkit preprocessing pipeline
to do all map processing first, then do processing
of topics to resolve conrefs, apply filtering,
and create temporary topic files reflecting any
copy-to and chunking defined in the map.


