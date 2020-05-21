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
  Create a simple XML tree for relation description.
  <relations>
    <relation type="related|services|children">
      + super-brief representation.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:util="java:org.fao.geonet.util.XslUtil"
                xmlns:gn-fn-rel="http://geonetwork-opensource.org/xsl/functions/relations"
                version="2.0"
                exclude-result-prefixes="#all">

  <xsl:import href="../iso19139/extract-relations.xsl"/>


  <!-- Convert an element gco:CharacterString
  to the GN localized string structure -->
  <xsl:template mode="get-iso19139-localized-string" match="*">

    <xsl:variable name="mainLanguage">
      <xsl:call-template name="langId_from_gmdlanguage19139">
        <xsl:with-param name="gmdlanguage" select="ancestor::metadata/*[@gco:isoType='gmd:MD_Metadata' or name()='gmd:MD_Metadata']/gmd:language"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:for-each select="gco:CharacterString|gmx:Anchor|
                          gmd:PT_FreeText/*/gmd:LocalisedCharacterString">

      <!-- Return the related UI language, not the metadata language. French value is different in HNAP -->
      <xsl:variable name="langVal">
        <xsl:choose>
          <xsl:when test="substring-after(@locale, '#') = 'fra'">fre</xsl:when>
          <xsl:when test="substring-after(@locale, '#') "><xsl:value-of select="substring-after(@locale, '#')"/></xsl:when>
          <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <value lang="{if (@locale)
                  then $langVal
                  else if ($mainLanguage) then $mainLanguage else $lang}">
        <xsl:copy-of select="@xlink:href"/>
        <xsl:value-of select="."/>
      </value>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
