org.dita4publishers.html2
======================

Extension to the base HTML transform type. Does numbering across the publication, back-of-the-box index, dynamic ToC

NOTE: Currently only works with the 1.8.5 Open Toolkit due to dependencies
on the org.dita-community.adjust-copy-to plugin, which only works with 1.8.5.
Work is under way to remove this limitation so the transform will work with
OT 1.7.5, 1.8.5, and 2.1+.

== Updates

18 June 2015: Take @copy-to into account for result files.  