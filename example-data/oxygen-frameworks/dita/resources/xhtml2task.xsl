<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:e="http://www.oxygenxml.com/xsl/conversion-elements"
        xmlns:f="http://www.oxygenxml.com/xsl/functions"
        exclude-result-prefixes="xsl e f"
        version="2.0">
 
    <xsl:template
      match="e:table[
                not(empty((index-of($context.path.names.sequence, 'steps'),
                      index-of($context.path.names.sequence, 'steps-unordered'))))
                and empty(index-of($context.path.names.sequence, 'info'))]"
      priority="2">
        <choicetable frame="all">
            <xsl:apply-templates mode="task"/>
        </choicetable>
    </xsl:template>
  
  
    <xsl:template match="e:thead" mode="task">
        <xsl:if test="count(.//e:td) >= 2">
            <chhead>
                <xsl:apply-templates mode="task"/>
            </chhead>
        </xsl:if>
    </xsl:template>
    
    
    <xsl:template match="e:tr" mode="task">
        <xsl:choose>
            <xsl:when test="parent::e:thead">
                <xsl:apply-templates mode="task"/>
            </xsl:when>
            <xsl:otherwise>
                <chrow>
                    <xsl:apply-templates mode="task"/>
                </chrow>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template match="e:th[ancestor::e:thead][position() &lt; last()] 
                                | e:td[ancestor::e:thead][position() &lt; last()]" 
            mode="task">
        <choptionhd>
            <xsl:apply-templates/>
        </choptionhd>
    </xsl:template>
    
    <xsl:template match="e:th[ancestor::e:thead][position() = last()] 
                                | e:td[ancestor::e:thead][position() = last()]" 
            mode="task">
        <chdeschd>
            <xsl:apply-templates/>
        </chdeschd>
    </xsl:template>
    
    <xsl:template match="e:td[ancestor::e:table]
                                        [not(ancestor::e:thead)][position() &lt; last()]" 
            mode="task">
        <choption>
            <xsl:apply-templates/>
        </choption>
    </xsl:template>
    
    <xsl:template match="e:td[ancestor::e:table]
                                        [not(ancestor::e:thead)][position() = last()]" 
            mode="task">
        <chdesc>
            <xsl:apply-templates/>
        </chdesc>
    </xsl:template>
    
    
    <!-- List elements -->
    <xsl:template 
        match="e:ul[not(ancestor::e:li)]
                          [$context.path.names.sequence[1] = 'task'
                          or ($context.path.names.sequence[1] = 'dita'
                                  and $context.path.names.sequence[2] = 'task')]
                          [$context.path.names.sequence[last()] = 'taskbody']"
            priority="3">
        <steps-unordered>
            <xsl:apply-templates mode="task"/>
        </steps-unordered>
    </xsl:template>
    
    
    <xsl:template 
        match="e:ul[not(ancestor::e:li)]
                          [$context.path.names.sequence[1] = 'task'
                          or ($context.path.names.sequence[1] = 'dita'
                                  and $context.path.names.sequence[2] = 'task')]
                          [$context.path.names.sequence[last()] = 'step']
                  | e:ul[count(ancestor::e:li) = 1]
                          [$context.path.names.sequence[1] = 'task'
                          or ($context.path.names.sequence[1] = 'dita'
                                  and $context.path.names.sequence[2] = 'task')]
                          [$context.path.names.sequence[last()] = 'taskbody']"
            priority="2">
        <substeps>
            <xsl:apply-templates mode="task"/>
        </substeps>
    </xsl:template>
    
    
    <xsl:template 
        match="e:ul[not(ancestor::e:li)]
                          [$context.path.names.sequence[1] = 'task'
                          or ($context.path.names.sequence[1] = 'dita'
                                  and $context.path.names.sequence[2] = 'task')]
                          [$context.path.names.sequence[last()] = 'substep'] 
                  | e:ul[count(ancestor::e:li) = 1]
                          [$context.path.names.sequence[1] = 'task'
                          or ($context.path.names.sequence[1] = 'dita'
                                  and $context.path.names.sequence[2] = 'task')]
                          [$context.path.names.sequence[last()] = 'step']
                  | e:ul[count(ancestor::e:li) = 2]
                          [$context.path.names.sequence[1] = 'task'
                          or ($context.path.names.sequence[1] = 'dita'
                                  and $context.path.names.sequence[2] = 'task')]
                          [$context.path.names.sequence[last()] = 'taskbody']"
            priority="1">
        <info>
            <ul>
                <xsl:apply-templates/>
            </ul>
        </info>
    </xsl:template>
    
    
    <xsl:template 
        match="e:ol[not(ancestor::e:li)]
                          [$context.path.names.sequence[1] = 'task'
                          or ($context.path.names.sequence[1] = 'dita'
                                  and $context.path.names.sequence[2] = 'task')]
                          [$context.path.names.sequence[last()] = 'taskbody']"
            priority="3">
        <steps>
            <xsl:apply-templates mode="task"/>
        </steps>
    </xsl:template>
    
    
    <xsl:template 
        match="e:ol[not(ancestor::e:li)]
                          [$context.path.names.sequence[1] = 'task'
                          or ($context.path.names.sequence[1] = 'dita'
                                  and $context.path.names.sequence[2] = 'task')]
                          [$context.path.names.sequence[last()] = 'step']
                  | e:ol[count(ancestor::e:li) = 1]
                          [$context.path.names.sequence[1] = 'task'
                          or ($context.path.names.sequence[1] = 'dita'
                                  and $context.path.names.sequence[2] = 'task')]
                          [$context.path.names.sequence[last()] = 'taskbody']"
            priority="2">
        <substeps>
            <xsl:apply-templates mode="task"/>
        </substeps>
    </xsl:template>
    
    
    <xsl:template 
        match="e:ol[not(ancestor::e:li)]
                          [$context.path.names.sequence[1] = 'task'
                          or ($context.path.names.sequence[1] = 'dita'
                                  and $context.path.names.sequence[2] = 'task')]
                          [$context.path.names.sequence[last()] = 'substep'] 
                  | e:ol[count(ancestor::e:li) = 1]
                          [$context.path.names.sequence[1] = 'task'
                          or ($context.path.names.sequence[1] = 'dita'
                                  and $context.path.names.sequence[2] = 'task')]
                          [$context.path.names.sequence[last()] = 'step']
                  | e:ol[count(ancestor::e:li) = 2]
                          [$context.path.names.sequence[1] = 'task'
                          or ($context.path.names.sequence[1] = 'dita'
                                  and $context.path.names.sequence[2] = 'task')]
                          [$context.path.names.sequence[last()] = 'taskbody']"
            priority="1">
        <info>
            <ol>
                <xsl:apply-templates/>
            </ol>
        </info>
    </xsl:template>
    
    <xsl:template match="e:li[not(ancestor::e:li)]
                                        [$context.path.names.sequence[last()] = 'step']
                                | e:li[count(ancestor::e:li) = 1]
                                        [$context.path.names.sequence[last()] = 'taskbody']"
            priority="1"
            mode="task">
        <substep>
            <cmd>
                <xsl:apply-templates select="node() except (e:ul | e:ol)"/>
            </cmd>
            <xsl:apply-templates select="e:ul | e:ol"/>
        </substep>
    </xsl:template>
    
    <xsl:template match="e:li[not(ancestor::e:li)]" mode="task">
        <step>
            <cmd>
                <xsl:apply-templates select="node() except (e:ul | e:ol)"/>
            </cmd>
            <xsl:apply-templates select="e:ul | e:ol"/>
        </step>
    </xsl:template>
    
</xsl:stylesheet>