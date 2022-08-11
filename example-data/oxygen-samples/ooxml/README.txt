This folder contains examples of reading from and writing to an Excel sheet and an OOXML file using XSLT. 
The examples XSLT stylesheets do the following:

importToExcel.xsl: Updates the Excel sheet Website_stats.xlsx with the website statistic data from Website_stats_data.xml.

extractFromExcel.xsl: Computes a report with the website statistic data extracted from
Website_stats.xlsx. Hint: to find the URL that must be put in the XML URL field of the
transformation scenario you should open the file xl/worksheets/sheet1.xml from Website_stats.xlsx,
right click on the title bar of the editor and select Copy Location.

extractFromWord.xsl: Generates an SQL statement for updating a database with the data extracted from
the Conversion of units.docx document. Hint: to find the URL that must be put in the XML URL field of the
transformation scenario you should open the file word/document.xml from Conversion of units.docx,
right click on the title bar of the editor and select Copy Location.
