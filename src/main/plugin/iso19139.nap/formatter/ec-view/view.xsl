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
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
                xmlns:gn-fn-render="http://geonetwork-opensource.org/xsl/functions/render"
                xmlns:saxon="http://saxon.sf.net/"
                version="2.0"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all">
  <!--
    This formatter render an iso19139.nap record for EC.
  -->

  <xsl:import href="../../present/metadata-utils.xsl" />
  <xsl:import href="ec-nap-metadata-utils.xsl" />


  <xsl:template match="/">
    <xsl:apply-templates select="/root/gmd:MD_Metadata|*[@gco:isoType='gmd:MD_Metadata']"/>
  </xsl:template>


  <xsl:template match="gmd:MD_Metadata|*[@gco:isoType='gmd:MD_Metadata']">
    <xsl:variable name="schema" select="/root/info/record/datainfo/schemaid"/>
    <xsl:variable name="edit" select="boolean('false')"/>

    <xsl:variable name="langForMetadata">
      <xsl:call-template name="getLangForMetadata">
        <xsl:with-param name="uiLang" select="/root/lang" />
      </xsl:call-template>
    </xsl:variable>
    <div class="col-md-8 ec-md-detail" itemscope="" itemtype="http://schema.org/Dataset">
      <xsl:call-template name="common-detailview-fields">
        <xsl:with-param name="schema" select="$schema" />
        <xsl:with-param name="edit" select="$edit" />
        <xsl:with-param name="langForMetadata" select="$langForMetadata" />
      </xsl:call-template>
    </div>
  </xsl:template>

  <xsl:template name="common-detailview-fields">
    <xsl:param name="schema" />
    <xsl:param name="edit" />
    <xsl:param name="langForMetadata" />

    <xsl:variable name="schemaStrings" select="/root/schemas/*[name()=$schema]/strings" />

    <!-- md title -->
    <h1 id="wb-cont" style="border-bottom:none" itemprop="name">
      <!-- as defined in md-show -->
      <img src="{/root/gui/url}/images/dataset.png" class="ds-icon-lg" alt="{$schemaStrings/dataset}: {/root/gmd:MD_Metadata//gmd:title/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[string(@locale)='/root/gui/lang']}" />
      <xsl:for-each select="/root/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title">
        <xsl:call-template name="localised">
          <xsl:with-param name="langId" select="$langForMetadata" />
        </xsl:call-template>
      </xsl:for-each>
    </h1>

    <!-- abstract -->
    <h3><xsl:value-of select="$schemaStrings/description"/></h3>
    <pre class="ec-abstract" itemprop="description">
      <xsl:for-each select="/root/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:abstract">
        <xsl:call-template name="localised">
          <xsl:with-param name="langId" select="$langForMetadata" />
        </xsl:call-template>
      </xsl:for-each>
    </pre>
    <br/><br/>

    <xsl:for-each select="/root/gmd:MD_Metadata//gmd:extent//gmd:EX_GeographicBoundingBox|/root/gmd:MD_Metadata//srv:extent//gmd:EX_GeographicBoundingBox">
      <xsl:variable name="minx" select="gmd:westBoundLongitude/gco:Decimal"/>
      <xsl:variable name="miny" select="gmd:southBoundLatitude/gco:Decimal"/>
      <xsl:variable name="maxx" select="gmd:eastBoundLongitude/gco:Decimal"/>
      <xsl:variable name="maxy" select="gmd:northBoundLatitude/gco:Decimal"/>
      <xsl:variable name="hasGeometry" select="($minx!='' and $miny!='' and $maxx!='' and $maxy!='' and (number($maxx)+number($minx)+number($maxy)+number($miny))!=0)"/>
      <xsl:variable name="geom" select="concat('POLYGON((', $minx, ' ', $miny,',',$maxx,' ',$miny,',',$maxx,' ',$maxy,',',$minx,' ',$maxy,',',$minx,' ',$miny, '))')"/>

      <xsl:if test="$hasGeometry">
        <div style="float:left;margin-right:10px;" role="map" aria-label="{$schemaStrings/where_explained}">
          <xsl:call-template name="showMap">
            <xsl:with-param name="edit" select="false" />
            <xsl:with-param name="mode" select="'bbox'" />
            <xsl:with-param name="coords" select="concat($minx,',',$miny,',',$maxx,',',$maxy)"/>
            <xsl:with-param name="targetPolygon" select="$geom"/>
            <xsl:with-param name="watchedBbox" select="'x1,y1,x2,y2'"/>
            <xsl:with-param name="eltRef" select="'EX_GeographicBoundingBox'"/>
            <xsl:with-param name="width" select="400"/>
            <xsl:with-param name="height" select="250"/>
            <xsl:with-param name="schema" select="$schema" />
          </xsl:call-template>
        </div>
      </xsl:if>



      <div style="float:left;text-align:left;width:200px">

        <xsl:if test="$hasGeometry">
          <span class="bold"><xsl:value-of select="$schemaStrings/GeographicExtent"/></span><br/>
          <span itemprop="spatial">
            <xsl:value-of select="$schemaStrings/sw"/>: <xsl:value-of select="concat(format-number(gmd:westBoundLongitude/gco:Decimal,'#.##'), ' ', format-number(gmd:southBoundLatitude/gco:Decimal,'#.##'))"/> <br/>
            <xsl:value-of select="$schemaStrings/ne"/>: <xsl:value-of select="concat(format-number(gmd:eastBoundLongitude/gco:Decimal,'#.##'), ' ', format-number(gmd:northBoundLatitude/gco:Decimal,'#.##'))"/>
          </span>
        </xsl:if>

        <!-- GeographicScope -->
        <xsl:if test="/root/gmd:MD_Metadata//gmd:keyword[../gmd:thesaurusName/gmd:CI_Citation/@id = 'local.place.EC_Geographic_Scope']">
          <br/><br/><span class="bold"><xsl:value-of select="$schemaStrings/GeographicScope"/></span><br/>
          <xsl:for-each select="/root/gmd:MD_Metadata//gmd:keyword[../gmd:thesaurusName/gmd:CI_Citation/@id = 'local.place.EC_Geographic_Scope']">
            <xsl:if test="position()!=1">,&#160;</xsl:if>
            <xsl:apply-templates mode="ecGeographicScope" select=".">
              <xsl:with-param name="schema" select="$schema"/>
            </xsl:apply-templates>
          </xsl:for-each>
        </xsl:if>
        <!-- Time period -->
        <xsl:if test="/root/gmd:MD_Metadata//gmd:temporalElement">
          <xsl:message>=== time period ===
          <xsl:copy-of select="/root/gmd:MD_Metadata//gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod"/>
          </xsl:message>
          <xsl:for-each select="/root/gmd:MD_Metadata//gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod">

            <br/><br/><span class="bold"><xsl:value-of select="$schemaStrings/Timeperiod"/></span><br/>
            <xsl:value-of select="$schemaStrings/from"/>: <span itemprop="temporal"><xsl:value-of select="gml:beginPosition"/></span> <br/>
            <xsl:value-of select="$schemaStrings/to"/>:  <span itemprop="temporal"><xsl:value-of select="gml:endPosition"/></span>
          </xsl:for-each>
        </xsl:if>
      </div>
    </xsl:for-each>



  </xsl:template>



  <xsl:template mode="ecGeographicScope" match="*">
    <xsl:param name="schema" />
    <xsl:param name="langId" />

    <xsl:variable name="thesaurusVal">
      <xsl:call-template name="localised">
        <xsl:with-param name="langId" select="$langId" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="lang">
      <xsl:call-template name="toIso2LangCode">
        <xsl:with-param name="iso3code" select="/root/lang"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="schemaStrings" select="/root/schemas/*[name()=$schema]/strings" />

    <span><xsl:value-of select="$thesaurusVal" /></span>
  </xsl:template>



</xsl:stylesheet>
