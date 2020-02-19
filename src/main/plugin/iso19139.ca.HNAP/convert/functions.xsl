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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco" version="2.0">
  <xsl:import href="../../iso19139/convert/functions.xsl"/>

  <xsl:variable name="defaultLang">eng</xsl:variable>


  <!-- ================================================================== -->
  <!-- iso3code from the supplied gmdlanguage
       It will prefer LanguageCode if it exists over CharacterString -->
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

  <xsl:template name="langIdWithCountry19139">
    <xsl:variable name="tmp">
      <xsl:choose>
        <xsl:when test="/*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gmd:LanguageCode/@codeListValue|
        	              /*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gco:CharacterString
                                ">
          <xsl:call-template name="langId_from_gmdlanguage19139">
             <xsl:with-param name="gmdlanguage" select="/*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language"/>
           </xsl:call-template>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="$defaultLang"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="tmp2">
      <xsl:value-of select="normalize-space(string(replace($tmp, '; CAN', '')))"></xsl:value-of>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$tmp2 != 'eng' and $tmp2 != 'fra'"><xsl:value-of select="$defaultLang"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$tmp2"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
