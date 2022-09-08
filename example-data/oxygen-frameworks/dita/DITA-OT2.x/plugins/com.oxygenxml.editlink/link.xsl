<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:editlink="http://oxygenxml.com/xslt/editlink/"
    xmlns:local="urn:localfunctions"
    exclude-result-prefixes="editlink xs local"  
    >
    <!-- Computes the Web Author link to be opened for a given topic in the context of a given map. -->
    <xsl:function name="editlink:compute" as="xs:string">
        <!-- The URL of the DITA map, as required by Web Author. -->
        <xsl:param name="remote.ditamap.url" as="xs:string"/>
        <!-- The path to the local copy of the DITA  map. -->
        <xsl:param name="local.ditamap.path" as="xs:string"/>
        <!-- The file:// URL of the local copy of the topic. -->
        <xsl:param name="local.topic.file.url" as="xs:string"/>
        <!-- The URL of the Web Author deployment. -->
        <xsl:param name="web.author.url" as="xs:string"/>
      
        <!-- Use a default value for the Web Author deployment.-->
        <xsl:variable name="web.author.url.nonull">
          <xsl:value-of select="if ($web.author.url != '') then $web.author.url else 'https://www.oxygenxml.com/webapp-demo-aws/'"/>
        </xsl:variable>

        <xsl:variable name="ditamap.url.encoded">
            <xsl:value-of select="encode-for-uri($remote.ditamap.url)"/>
        </xsl:variable>
        
        <!-- Compute the URL params for the edit url -->
        <xsl:variable name="file.rel.path">
            <xsl:value-of select="editlink:makeRelative(editlink:toUrl($local.ditamap.path), $local.topic.file.url)"/>
        </xsl:variable>
        <xsl:variable name="file.url.encoded">
            <xsl:value-of select="encode-for-uri(resolve-uri($file.rel.path, $remote.ditamap.url))"/>
        </xsl:variable>
    
        <xsl:value-of select="concat($web.author.url.nonull, 'app/oxygen.html?url=', $file.url.encoded, '&amp;ditamap=', $ditamap.url.encoded)"/>
    </xsl:function>
    

    <!-- Makes the topic URL relative to the map URL. -->
    <xsl:function name="editlink:makeRelative" as="xs:string">
        <xsl:param name="map" as="xs:string"/>
        <xsl:param name="topic" as="xs:string"/>

        <xsl:variable name="normalizedMap" as="xs:string">
            <xsl:value-of select="tokenize($map, '/')[.!='' and .!='.' and position()!=last()]" separator="/" />
        </xsl:variable>
        <xsl:variable name="mapBase" as="xs:string" select="concat($normalizedMap, '/')"/>
        <xsl:variable name="normalizedTopic" as="xs:string">
            <xsl:value-of select="tokenize($topic, '/')[.!='' and .!='.']" separator="/" />
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$map=''"><xsl:value-of select="''"/></xsl:when>
            <xsl:when test="starts-with($normalizedTopic, $mapBase)">
                <xsl:value-of select="substring-after($normalizedTopic, $mapBase)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="x" select="editlink:makeRelative($normalizedMap, $normalizedTopic)"/>
                <xsl:choose>
                    <xsl:when test="$x=''">
                        <xsl:value-of select="''"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat('../', $x)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- Translates a file path to a file:// URL. -->
    <xsl:function name="editlink:toUrl" as="xs:string">
        <xsl:param name="filepath" as="xs:string"/>
        <xsl:variable name="url" as="xs:string"
            select="if (contains($filepath, '\'))
            then translate($filepath, '\', '/')
            else $filepath
            "
        />
        <xsl:variable name="fileUrl" as="xs:string"
            select="
            if (matches($url, '^[a-zA-Z]:'))
            then concat('file:/', $url)
            else if (starts-with($url, '/')) 
            then concat('file:', $url) 
            else $url
            "
        />
        <xsl:variable name="escapedUrl" 
            select="replace($fileUrl, ' ', '%20')"
        />
        <xsl:sequence select="$escapedUrl"/>
    </xsl:function>
</xsl:stylesheet>
