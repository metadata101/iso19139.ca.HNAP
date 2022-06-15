<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                  xmlns:gco="http://www.isotc211.org/2005/gco"
                  xmlns:gmd="http://www.isotc211.org/2005/gmd"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  xmlns:geonet="http://www.fao.org/geonetwork"
                  exclude-result-prefixes="#all">

  <xsl:template match="gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date[gco:Date and string-length(gco:Date) != 10]/gco:Date">

    <xsl:variable name="value" select="." />

    <xsl:copy>
      <xsl:choose>
        <xsl:when test="matches($value, '^\d{4}$')">
          <xsl:value-of select="concat($value, '-01-01')"/>
        </xsl:when>
        <xsl:when test="matches($value, '^\d{4}-(0[1-9]|1[0-2])$')">
          <xsl:value-of select="concat($value, '-01')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$value"/>
        </xsl:otherwise>
      </xsl:choose>

    </xsl:copy>

  </xsl:template>


  <!-- Do a copy of every nodes and attributes -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Remove geonet:* elements. -->
  <xsl:template match="geonet:*" priority="2"/>
</xsl:stylesheet>
