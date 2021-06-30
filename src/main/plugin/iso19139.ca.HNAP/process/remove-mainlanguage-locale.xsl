<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright (C) 2001-2016 Food and Agriculture Organization of the
  ~ United Nations (FAO-UN), United Nations World Food Programme (WFP)
  ~ and United Nations Environment Programme (UNEP)
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or (at
  ~ your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful, but
  ~ WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  ~ General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
  ~
  ~ Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
  ~ Rome - Italy. email: geonetwork@osgeo.org
  -->

<!--
Processing to insert or update an online resource element.
Insert is made in first transferOptions found.
-->
<xsl:stylesheet xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gml320="http://www.opengis.net/gml"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:geonet="http://www.fao.org/geonetwork"
                exclude-result-prefixes="#all"
                version="2.0">


  <!-- The default language is also added as gmd:locale
for multilingual metadata records. -->
  <xsl:variable name="mainLanguage">
    <xsl:call-template name="langId_from_gmdlanguage19139">
      <xsl:with-param name="gmdlanguage" select="gmd:MD_Metadata/gmd:language"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:template name="langId_from_gmdlanguage19139">
    <xsl:param name="gmdlanguage" required="yes"/>
    <xsl:variable name="tmp">
      <xsl:choose>
        <xsl:when test="normalize-space($gmdlanguage/gmd:LanguageCode/@codeListValue) != ''">
          <xsl:value-of select="$gmdlanguage/gmd:LanguageCode/@codeListValue"/>
        </xsl:when>
        <xsl:when test="contains($gmdlanguage/gco:CharacterString,';')">
          <xsl:value-of  select="normalize-space(substring-before($gmdlanguage/gco:CharacterString,';'))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$gmdlanguage/gco:CharacterString"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="normalize-space(string($tmp))"></xsl:value-of>
  </xsl:template>

  <xsl:template match="gmd:locale[*/gmd:languageCode/*/@codeListValue = $mainLanguage]"/>

  <!-- Remove geonet:* elements. -->
  <xsl:template match="geonet:*" priority="2"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
