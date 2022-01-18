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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
                version="2.0"
                exclude-result-prefixes="#all">


  <xsl:import href="../../iso19139/layout/utility-fn.xsl"/>

  <xsl:function name="gn-fn-iso19139:getLangIdHNAP" as="xs:string">
    <xsl:param name="md"/>
    <xsl:param name="lang"/>

    <!-- convert ISO 639-2B to_ISO 639-2T - i.e. FRE to FRA -->
    <xsl:variable name="lang_ISO639_2T">
      <xsl:choose>
        <xsl:when test="$lang ='fre'">
          <xsl:value-of select="'fra'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$lang"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when
        test="$md/gmd:locale/gmd:PT_Locale[gmd:languageCode/gmd:LanguageCode/@codeListValue = $lang_ISO639_2T]/@id">
        <xsl:value-of
          select="concat('#', $md/gmd:locale/gmd:PT_Locale[gmd:languageCode/gmd:LanguageCode/@codeListValue = $lang_ISO639_2T]/@id)"
        />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('#', upper-case($lang_ISO639_2T))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
</xsl:stylesheet>
