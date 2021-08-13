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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gn="http://www.fao.org/geonetwork"
                xmlns:xslutil="java:org.fao.geonet.util.XslUtil"
                xmlns:XslUtilHnap="java:ca.gc.schema.iso19139hnap.util.XslUtilHnap"
                version="2.0"
                exclude-result-prefixes="#all">


  <xsl:import href="../../iso19139/layout/utility-tpl-multilingual.xsl"/>


  <!-- Get the main metadata languages -->
  <xsl:template name="get-iso19139.ca.HNAP-language">
    <xsl:variable name="isTemplate" select="$metadata/gn:info[position() = last()]/isTemplate"/>
    <xsl:choose>
      <xsl:when test="$isTemplate = 's' or $isTemplate = 't'">
        <xsl:value-of select="xslutil:getLanguage()" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$metadata/gmd:language/gmd:LanguageCode/@codeListValue">
            <xsl:value-of select="$metadata/gmd:language/gmd:LanguageCode/@codeListValue"/>
          </xsl:when>
          <xsl:when test="contains($metadata/gmd:language/gco:CharacterString,';')">
            <xsl:variable name="metadataMainLanguage" select="normalize-space(substring-before($metadata/gmd:language/gco:CharacterString,';'))"/>
            <xsl:choose>
              <xsl:when test=" $metadataMainLanguage = 'fra'">
                <xsl:value-of>fre</xsl:value-of>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of  select="$metadataMainLanguage"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$metadata/gmd:language/gco:CharacterString"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- Get the list of other languages in JSON -->
  <xsl:template name="get-iso19139.ca.HNAP-other-languages-as-json">
    <!-- This is a copy of "get-iso19139-other-languages-as-json" in iso19139 with Language mapping for hnap : eng; CAN -> eng, fra; CAN -> fre, fra -> fre -->
    <xsl:variable name="isTemplate" select="$metadata/gn:info[position() = last()]/isTemplate"/>
    <xsl:variable name="langs">
      <xsl:choose>
        <xsl:when test="$isTemplate = 's' or $isTemplate = 't'">

          <xsl:for-each select="distinct-values($metadata//gmd:LocalisedCharacterString/@locale)">
            <xsl:variable name="locale" select="string(.)"/>
            <xsl:variable name="langId" select="xslutil:threeCharLangCode(substring($locale,2,2))"/>
            <lang>
              <xsl:value-of select="concat('&quot;', $langId, '&quot;:&quot;', ., '&quot;')"/>
            </lang>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="mainLanguage">
            <xsl:call-template name="get-iso19139-language"/>
          </xsl:variable>
          <xsl:if test="$mainLanguage">
            <xsl:variable name="mainLanguageId"
                          select="$metadata/gmd:locale/gmd:PT_Locale[
                                gmd:languageCode/gmd:LanguageCode/@codeListValue = $mainLanguage]/@id"/>
            <xsl:variable name="mainLanguageCode"
                          select="$metadata/gmd:locale/gmd:PT_Locale[
                                gmd:languageCode/gmd:LanguageCode/@codeListValue = $mainLanguage]/gmd:languageCode/gmd:LanguageCode/@codeListValue"/>

            <xsl:variable name="lang_ISO639_2B">
              <xsl:choose>
                <xsl:when test="$mainLanguage = 'fra'">fre</xsl:when>
                <xsl:otherwise><xsl:value-of select="$mainLanguage"/></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:variable name="mainLanguageCode_ISO639_2B">
              <xsl:choose>
                <xsl:when test="$mainLanguageCode[1] = 'fra'">fre</xsl:when>
                <xsl:otherwise><xsl:value-of select="$mainLanguageId[1]"/></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>


            <lang><xsl:value-of select="concat('&quot;', $lang_ISO639_2B, '&quot;:&quot;#', $mainLanguageCode_ISO639_2B, '&quot;')"/></lang>
          </xsl:if>

          <xsl:for-each
            select="$metadata/gmd:locale/gmd:PT_Locale[gmd:languageCode/gmd:LanguageCode/@codeListValue != $mainLanguage]">
            <xsl:variable name="lang_ISO639_2B">
              <xsl:choose>
                <xsl:when test="gmd:languageCode/gmd:LanguageCode/@codeListValue = 'fra'">fre</xsl:when>
                <xsl:otherwise><xsl:value-of select="gmd:languageCode/gmd:LanguageCode/@codeListValue"/></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <xsl:variable name="lang_code_ISO639_2B">
              <xsl:choose>
                <xsl:when test="gmd:languageCode/gmd:LanguageCode/@codeListValue = 'fra'">fre</xsl:when>
                <xsl:otherwise><xsl:value-of select="gmd:languageCode/gmd:LanguageCode/@codeListValue"/></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <lang><xsl:value-of select="concat('&quot;', $lang_ISO639_2B, '&quot;:&quot;#', $lang_code_ISO639_2B, '&quot;')"/></lang>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:text>{</xsl:text><xsl:value-of select="string-join($langs/lang, ',')"/><xsl:text>}</xsl:text>
  </xsl:template>

  <!-- Get the list of other languages -->
  <xsl:template name="get-iso19139.ca.HNAP-other-languages">
    <xsl:variable name="isTemplate" select="$metadata/gn:info[position() = last()]/isTemplate"/>
    <xsl:choose>
      <xsl:when test="$isTemplate = 's' or $isTemplate = 't'">

        <xsl:for-each select="distinct-values($metadata//gmd:LocalisedCharacterString/@locale)">
          <xsl:variable name="locale" select="string(.)"/>
          <xsl:variable name="langId" select="xslutil:threeCharLangCode(substring($locale,2,2))"/>
          <lang id="{substring($locale,2,2)}" code="{$langId}"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="mainLanguage">
          <xsl:call-template name="get-iso19139-language"/>
        </xsl:variable>
        <xsl:for-each select="$metadata/gmd:locale/gmd:PT_Locale">
          <xsl:variable name="langCode"
                        select="gmd:languageCode/gmd:LanguageCode/@codeListValue"/>
          <xsl:variable name="langCode_ISO639_2B">
            <xsl:choose>
              <xsl:when test="$langCode='fra'">
                <xsl:value-of select="'fre'"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$langCode"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <lang id="{$langCode_ISO639_2B}" code="{$langCode_ISO639_2B}">
            <xsl:if test="$langCode = $mainLanguage">
              <xsl:attribute name="default" select="''"/>
            </xsl:if>
          </lang>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
