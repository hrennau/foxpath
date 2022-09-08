# DITA Metrics Report

Obtain different metrics from a DITA map.

The project can be used as a DITA OT plugin. Just copy the entire "dita-metrics-report" folder to the DITA OT "plugins" folder and run the integrator.

Or you can apply the XSLT processing directly.
Applying the XSLT stylesheets requires an XSLT 2.0 processor (Saxon 9) and the publishing is done in two stages:

  - The **report.xsl** XSLT stylesheet is applied on the main DITA Map. This produces a special XML document containing all the report data.
  - On the XML document produced in the first stage  you should apply the **report2XHTML.xsl** XSLT stylesheet which produces the HTML output.
  
A short description of each reported metric can be found below:

  - Total number of maps and topics which are part of the project.
  - Total number of elements used in topics and maps along with a table presenting all element names and their usage counter.
  - The used elements used from each DITA domain.
  - Total number of attributes used in topics and maps along with a table presenting all attribute names and their usage counter.
  - Statistics about the conditional attributes used in the project.
  - Information about content reuse.
  - Tables containing list of largest and smallest topics and the number of words each one used.
  - Table containing a listing of all links to resources outside of the project.

## License

This project is licensed under MPL 2.0, see the [LICENSE](LICENSE) file for details.

