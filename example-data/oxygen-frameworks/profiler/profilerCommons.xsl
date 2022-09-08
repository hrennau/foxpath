<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:param name="oXygenProfilerImages" select="'oXygenProfilerImages'"/>    
    <xsl:param name="imagesSeparator" select="'&#13;'"/>
    <!-- Images -->
    <xsl:param name="imgMenuTreeMinus" select="'menu_tree_minus_18.gif'"/>
    <xsl:param name="imgMenuCornerMinus" select="'menu_corner_minus_18.gif'"/>
    <xsl:param name="imgMenuTreePlus" select="'menu_tree_plus_18.gif'"/>
    <xsl:param name="imgMenuCornerPlus" select="'menu_corner_plus_18.gif'"/>
    <xsl:param name="imgMenuTree" select="'menu_tree_18.gif'"/>
    <xsl:param name="imgMenuCorner" select="'menu_corner_18.gif'"/>
    <xsl:param name="imgMenuBar" select="'menu_bar_18.gif'"/>
    <xsl:param name="imgPixelTransparent" select="'pixel_transparent_1.gif'"/>    
    <xsl:param name="imgFinalParent" select="'PClock16.gif'"/>
   
    <!-- Handle headers -->
    <xsl:template name="listHeader">
        <xsl:param name="name" select="name()"/>
        <tr>
            <td>
                <b><xsl:value-of select="$name"/></b>
            </td>
            <td><xsl:value-of select="."/></td>
        </tr>        
    </xsl:template>    
    <xsl:template match="timeOfExport" mode="header">
        <xsl:call-template name="listHeader">
            <xsl:with-param name="name" select="'Time of Export'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="engine" mode="header">
        <xsl:call-template name="listHeader">
            <xsl:with-param name="name" select="'Engine'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="style" mode="header">
        <xsl:call-template name="listHeader">
            <xsl:with-param name="name" select="'Stylesheet'"/>
        </xsl:call-template>
    </xsl:template>    
    <xsl:template match="source" mode="header">
        <xsl:call-template name="listHeader">
            <xsl:with-param name="name" select="'Source'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="elapsedTime" mode="header">
        <xsl:call-template name="listHeader">
            <xsl:with-param name="name" select="'Elapsed Time'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="timeResolution" mode="header">
        <xsl:call-template name="listHeader">
            <xsl:with-param name="name" select="'Time Resolution'"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="hotspot" mode="header"/>
    <xsl:template match="inv-tree" mode="header"/>
    
    <!-- Get the plus, minus, simple or corner images, depending on context. -->
    <xsl:template name="getNavigationImage">
        <xsl:value-of select="$oXygenProfilerImages"/>
        <xsl:text>/</xsl:text>
        <xsl:choose>
            <xsl:when test="content/*[not(self::snipped)]">
                <xsl:choose>
                    <xsl:when test="following-sibling::*[name()=name(current())]"><xsl:value-of select="$imgMenuTreeMinus"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$imgMenuCornerMinus"/></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="content/snipped">
                <xsl:choose>
                    <xsl:when test="following-sibling::*[name()=name(current())]"><xsl:value-of select="$imgMenuTreePlus"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$imgMenuCornerPlus"/></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="following-sibling::*[name()=name(current())]"><xsl:value-of select="$imgMenuTree"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$imgMenuCorner"/></xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--  Get the additional menu image, a bar or a transparet image. -->
    <xsl:template name="getAdditionalMenuImage">
        <xsl:value-of select="$oXygenProfilerImages"/>
        <xsl:text>/</xsl:text>
        <xsl:choose>
            <xsl:when test="following-sibling::*[name()=name(current())]">
                <xsl:value-of select="$imgMenuBar"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$imgPixelTransparent"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Get the image for the current parent node -->
    <xsl:template name="getParentImage">
        <xsl:param name="parentImage"/>
        <xsl:value-of select="$oXygenProfilerImages"/>
        <xsl:text>/</xsl:text>
        <xsl:choose>
            <xsl:when test="content"><xsl:value-of select="$parentImage"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$imgFinalParent"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Print location info -->
    <xsl:template name="showLocation">
        <xsl:value-of select="systemid"/>
        <xsl:text>[</xsl:text>
        <xsl:value-of select="line"/>
        <xsl:if test="column!='-1'">
            <xsl:text>:</xsl:text>
            <xsl:value-of select="column"/>
        </xsl:if>
        <xsl:text>]</xsl:text>
    </xsl:template>
    
    
    <!-- Print a list of images -->
    <xsl:template name="printImages">
        <xsl:param name="images" select="''"/>
        <xsl:if test="string-length($images) > 0">
            <xsl:choose>
                <xsl:when test="contains($images, $imagesSeparator)">
                    <img height="18" width="18" border="0" align="left" hspace="0" vspace="0"
                        src="{substring-before($images, $imagesSeparator)}"/>
                    <xsl:call-template name="printImages">
                        <xsl:with-param name="images" select="substring-after($images, $imagesSeparator)"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <img height="18" width="18" border="0" align="left" hspace="0" vspace="0"
                        src="{$images}"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>        
    </xsl:template>
</xsl:stylesheet>
