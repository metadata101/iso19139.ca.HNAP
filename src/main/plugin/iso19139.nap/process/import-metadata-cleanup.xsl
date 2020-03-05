<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:exsl="http://exslt.org/common"
                xmlns:geonet="http://www.fao.org/geonetwork" exclude-result-prefixes="#all" version="2.0">


  <!-- ================================================================= -->

  <xsl:template match="gmd:MD_Metadata">
    <xsl:copy>
      <!-- Make sure the namespace in in the root to remove it later from gco:CharacterString elements -->
      <!-- Some metadata imported had the definition inline, what makes the metadata too long -->
      <xsl:namespace name="gco" select="'http://www.isotc211.org/2005/gco'"/>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Remove empty xlink:role, online xsd for HNAP has change xlink version to older one, to confirm as causes issues with this element -->
  <!-- Local version of xlink xsd didn't have this issue -->
  <xsl:template match="@xlink:role" priority="10">
    <xsl:if test="string-length(.)!=0">
      <xsl:copy />
    </xsl:if>
  </xsl:template>

  <!-- Remove inline namespace declaration found in some metadata -->
  <xsl:template match="gco:CharacterString">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
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
