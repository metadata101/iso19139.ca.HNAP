<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:geonet="http://www.fao.org/geonetwork"
    exclude-result-prefixes="#all"
    version="2.0">

    <xsl:template match="gmd:graphicOverview">
        <xsl:variable name="desc" select="gmd:MD_BrowseGraphic/gmd:fileDescription/gco:CharacterString"/>

        <xsl:copy>
            <xsl:choose>
                <xsl:when test="$desc = 'thumbnail' or $desc = 'large_thumbnail'">
                    <xsl:attribute name="xlink:role">urn:xml:lang:eng-CAN</xsl:attribute>
                </xsl:when>
                <xsl:when test="$desc = 'thumbnail_fre' or $desc = 'large_thumbnail_fre'">
                    <xsl:attribute name="xlink:role">urn:xml:lang:fra-CAN</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:copy-of select="@xlink:role" />
                </xsl:otherwise>
            </xsl:choose>

            <xsl:copy-of select="gmd:MD_BrowseGraphic" />
        </xsl:copy>
    </xsl:template>

    <!-- Do a copy of every nodes and attributes -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Always remove geonet:* elements. -->
    <xsl:template match="geonet:*" priority="2"/>

</xsl:stylesheet>
