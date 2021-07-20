<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:exsl="http://exslt.org/common"
                xmlns:geonet="http://www.fao.org/geonetwork" exclude-result-prefixes="#all" version="2.0">

    <!-- ================================================================= -->

    <xsl:template match="gmd:MD_Metadata">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>


    <!-- ================================================================= -->

    <xsl:template match="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[not(@xlink:role) and
        (gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString = 'OGC:WMS' or starts-with(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString, 'ESRI REST:'))]">

        <xsl:variable name="resourceLang">
            <xsl:choose>
                <xsl:when test="ends-with(gmd:CI_OnlineResource/gmd:description/gco:CharacterString, 'fra')"><xsl:value-of select="'urn:xml:lang:fra-CAN'"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="'urn:xml:lang:eng-CAN'"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:copy>
            <xsl:attribute name="xlink:role"><xsl:value-of select="$resourceLang" /></xsl:attribute>
            <xsl:copy-of select="@*" />

            <xsl:apply-templates select="*" />
        </xsl:copy>
    </xsl:template>

    <!-- ================================================================= -->

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- ================================================================= -->

    <!-- Remove geonet:* elements. -->
    <xsl:template match="geonet:*" priority="2"/>
    <xsl:template match="@geonet:*" priority="2"/>
</xsl:stylesheet>
