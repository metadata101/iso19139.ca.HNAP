<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:exsl="http://exslt.org/common"
                xmlns:geonet="http://www.fao.org/geonetwork" exclude-result-prefixes="#all" version="2.0">

    <!--
   Format of the urls parameter:

    <urls>http://url1.com:::http://url2.com</urls>
    -->
    <xsl:param name="urls"></xsl:param>

    <!-- ================================================================= -->

    <xsl:template match="gmd:MD_Metadata">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>


    <!-- ================================================================= -->
    <xsl:template match="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage/gmd:URL">

        <!--<xsl:variable name="urlList" select="tokenize($urls, ':::')" />-->
        <xsl:variable name="urlList">
         <xsl:for-each select="tokenize($urls, ':::')">
             <url><xsl:value-of select="."/></url>
         </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="urlListNodeSet" select="exsl:node-set($urlList)"/>
        <!--<xsl:message>url 1: <xsl:value-of select="$urlListNodeSet/url[1]" /></xsl:message>-->
        <!--<xsl:message>url 2: <xsl:value-of select="$urlListNodeSet/url[2]" /></xsl:message>-->
        
        <xsl:variable name="urlToCheck" select="." />
            
        <!--<xsl:message>url count: <xsl:value-of select="count($urlListNodeSet/url)" /></xsl:message>-->
    <!--<xsl:message>url check: <xsl:value-of select="$urlListNodeSet/url[text() = $urlToCheck]" /></xsl:message>-->

    <xsl:choose>
        <xsl:when test="count($urlListNodeSet/url[text() = $urlToCheck]) > 0">
            <gmd:URL><xsl:value-of select="replace($urlListNodeSet/url[text() = $urlToCheck][1], 'http://', 'https://')" /></gmd:URL>
        </xsl:when>
        <xsl:otherwise>
            <xsl:copy-of select="." />
        </xsl:otherwise>
    </xsl:choose>
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