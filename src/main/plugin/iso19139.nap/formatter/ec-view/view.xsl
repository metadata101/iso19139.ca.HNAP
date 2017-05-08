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
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
                xmlns:gn-fn-render="http://geonetwork-opensource.org/xsl/functions/render"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:saxon="http://saxon.sf.net/"
                version="2.0"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all">
  <!--
    This formatter render an iso19139.nap record for EC.
  -->

  <xsl:import href="../../present/metadata-utils.xsl" />
  <xsl:import href="ec-nap-metadata-utils.xsl" />

  <!-- Load the editor configuration to be able
     to render the different views -->


  <!-- TODO: schema is not part of the XML -->
  <xsl:variable name="schema"
                select="/root/info/record/datainfo/schemaid"/>

  <xsl:variable name="metadataId"
                select="/root/info/record/id"/>

  <xsl:variable name="language"
                select="/root/lang/text()"/>

  <xsl:variable name="langForMetadata">
    <xsl:call-template name="getLangForMetadata">
      <xsl:with-param name="uiLang" select="$language" />
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="nodeUrl"
                select="/root/gui/nodeUrl"/>

  <xsl:template match="/">
    <xsl:apply-templates select="/root/gmd:MD_Metadata|*[@gco:isoType='gmd:MD_Metadata']"/>
  </xsl:template>


  <xsl:template match="gmd:MD_Metadata|*[@gco:isoType='gmd:MD_Metadata']">
    <xsl:variable name="schema" select="/root/info/record/datainfo/schemaid"/>
    <xsl:variable name="edit" select="boolean('false')"/>


    <div>
      <div class="col-md-8 ec-md-detail" itemscope="" itemtype="http://schema.org/Dataset">
        <xsl:call-template name="common-detailview-fields">
          <xsl:with-param name="schema" select="$schema" />
          <xsl:with-param name="edit" select="$edit" />
          <xsl:with-param name="langForMetadata" select="$langForMetadata" />
        </xsl:call-template>

        <div style="clear:both" />
        <h3><xsl:value-of select="/root/schemas/*[name()=$schema]/strings/Additionalinformation"/></h3>

        <xsl:call-template name="showPanel">

          <xsl:with-param name="title"   select="/root/schemas/*[name()=$schema]/labels/element[@name='gmd:identificationInfo']/label"/>
          <xsl:with-param name="content">
            <table class="sidebar2" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
              <tbody>
                <xsl:apply-templates mode="render-field" select="gmd:identificationInfo/*/gmd:citation/*/*[name() != 'gmd:title' and name() != 'gmd:citedResponsibleParty']" />

                <xsl:apply-templates mode="render-field"  select="gmd:identificationInfo/*/*[name() != 'gmd:citation' and
                  name() != 'gmd:abstract' and name() != 'gmd:pointOfContact' and name() != 'gmd:descriptiveKeywords' and
                  name() != 'gmd:extent' and name() != 'gmd:graphicOverview' and name() != 'gmd:topicCategory']" />
              </tbody>
            </table>
          </xsl:with-param>
        </xsl:call-template>

        <xsl:if test="gmd:contentInfo/*">
          <xsl:call-template name="showPanel">
            <xsl:with-param name="title"   select="/root/schemas/*[name()=$schema]/labels/element[@name='gmd:contentInfo']/label"/>
            <xsl:with-param name="content">
              <table class="sidebar2" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
                <tbody>
                  <xsl:apply-templates mode="render-field" select="gmd:contentInfo/*" />
                </tbody>
              </table>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>

        <xsl:if test="gmd:distributionInfo/*/*[name() = 'gmd:distributionFormat']">
          <xsl:call-template name="showPanel">
            <xsl:with-param name="title"   select="/root/schemas/*[name()=$schema]/labels/element[@name='gmd:distributionInfo']/label"/>
            <xsl:with-param name="content">
              <table class="sidebar2" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
                <tbody>
                  <xsl:apply-templates mode="render-field" select="gmd:distributionInfo/*/*[name() = 'gmd:distributionFormat']" />
                </tbody>
              </table>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>

        <xsl:if test="gmd:dataQualityInfo/*">
          <xsl:call-template name="showPanel">
            <xsl:with-param name="title"   select="/root/schemas/*[name()=$schema]/labels/element[@name='gmd:dataQualityInfo']/label"/>
            <xsl:with-param name="content">
              <table class="sidebar2" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
                <tbody>
                  <xsl:apply-templates mode="render-field" select="gmd:dataQualityInfo/*" />
                </tbody>
              </table>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>

        <xsl:if test="gmd:portrayalCatalogueInfo/*">
          <xsl:call-template name="showPanel">
            <xsl:with-param name="title"   select="/root/schemas/*[name()=$schema]/labels/element[@name='gmd:portrayalCatalogueInfo']/label"/>
            <xsl:with-param name="content">
              <table class="sidebar2" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
                <tbody>
                  <xsl:apply-templates mode="render-field" select="gmd:portrayalCatalogueInfo/*" />
                </tbody>
              </table>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>

        <xsl:if test="gmd:metadataConstraints/*">
          <xsl:call-template name="showPanel">
            <xsl:with-param name="title"   select="/root/schemas/*[name()=$schema]/labels/element[@name='gmd:metadataConstraints']/label"/>
            <xsl:with-param name="content">
              <table class="sidebar2" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
                <tbody>
                  <xsl:apply-templates mode="render-field" select="gmd:metadataConstraints/*" />
                </tbody>
              </table>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>

        <xsl:if test="gmd:applicationSchemaInfo/*">
          <xsl:call-template name="showPanel">
            <xsl:with-param name="title"   select="/root/schemas/*[name()=$schema]/labels/element[@name='gmd:applicationSchemaInfo']/label"/>
            <xsl:with-param name="content">
              <table class="sidebar2" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
                <tbody>
                  <xsl:apply-templates mode="render-field" select="gmd:applicationSchemaInfo/*" />
                </tbody>
              </table>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>

        <xsl:if test="gmd:metadataMaintenance/*">
          <xsl:call-template name="showPanel">
            <xsl:with-param name="title"   select="/root/schemas/*[name()=$schema]/labels/element[@name='gmd:metadataMaintenance']/label"/>
            <xsl:with-param name="content">
              <table class="sidebar2" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
                <tbody>
                  <xsl:apply-templates mode="render-field" select="gmd:metadataMaintenance/*" />
                </tbody>
              </table>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>

        <xsl:call-template name="showPanel">
          <xsl:with-param name="title"   select="/root/schemas/*[name()=$schema]/strings/Metadatarecord"/>
          <xsl:with-param name="content">

            <table>
              <tbody>
                <xsl:apply-templates mode="render-field" select="gmd:fileIdentifier" />

                <!-- dataseturi -->
                <xsl:apply-templates mode="render-field" select="gmd:dataSetURI" />


                <!-- Hierarchy level -->
                <xsl:apply-templates mode="render-field" select="gmd:hierarchyLevel" />

                <xsl:apply-templates  mode="render-field" select="gmd:hierarchyLevelName" />

                <!-- Datestamp -->
                <xsl:apply-templates mode="render-field" select="gmd:dateStamp" />

                <xsl:apply-templates mode="render-field" select="gmd:language" />

                <xsl:apply-templates mode="render-field" select="gmd:characterSet" />

                <!-- metadataStandardName -->
                <xsl:apply-templates mode="render-field" select="gmd:metadataStandardName" />

                <xsl:apply-templates mode="render-field" select="gmd:metadataStandardVersion" />

                <xsl:apply-templates mode="render-field" select="gmd:dataSetURI" />

                <!-- ReferenceSystemInfo -->
                <xsl:apply-templates mode="render-field" select="gmd:referenceSystemInfo" />

                <!-- spatialRepresentationInfo -->
                <xsl:apply-templates mode="render-field" select="gmd:spatialRepresentationInfo" />

                <xsl:apply-templates mode="render-field" select="gmd:series" />

                <xsl:apply-templates mode="render-field" select="gmd:describes" />

                <xsl:apply-templates mode="render-field" select="gmd:propertyType" />

                <xsl:apply-templates mode="render-field" select="gmd:featureType" />

                <xsl:apply-templates mode="render-field" select="gmd:featureAttribute" />

              </tbody>
            </table>
          </xsl:with-param>
        </xsl:call-template>

        <xsl:if test="gmd:metadataExtensionInfo/*">
          <xsl:call-template name="showPanel">
            <xsl:with-param name="title"   select="/root/gui/schemas/iso19139.nap/labels/element[@name='gmd:metadataExtensionInfo']/label"/>
            <xsl:with-param name="content">
              <table class="sidebar2" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
                <tbody>
                  <xsl:apply-templates mode="render-field" select="gmd:metadataExtensionInfo/*" />
                </tbody>
              </table>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </div>

      <xsl:call-template name="sidebar-panel" />

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
          <xsl:for-each select="/root/gmd:MD_Metadata//gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod">
            <br/><br/><span class="bold"><xsl:value-of select="$schemaStrings/Timeperiod"/></span><br/>
            <xsl:value-of select="$schemaStrings/from"/>: <span itemprop="temporal"><xsl:value-of select="gml:beginPosition"/></span> <br/>
            <xsl:value-of select="$schemaStrings/to"/>:  <span itemprop="temporal"><xsl:value-of select="gml:endPosition"/></span>
          </xsl:for-each>
        </xsl:if>
      </div>
    </xsl:for-each>

    <script type="text/javascript">$( ".wb-geomap" ).trigger( "wb-init.wb-geomap" );</script>


    <div style="clear:left">&#160;</div>

    <xsl:variable name="lang">
      <xsl:choose>
        <xsl:when test="/root/lang='fra'">
          <xsl:text>fre</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>eng</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="isoLang">
      <xsl:choose>
        <xsl:when test="$lang='fra'">
          <xsl:text>urn:xml:lang:fra-CAN</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>urn:xml:lang:eng-CAN</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="langId">
      <xsl:call-template name="getLangId">
        <xsl:with-param name="langGui" select="$lang" />
        <xsl:with-param name="md"
                        select="ancestor-or-self::*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']" />
      </xsl:call-template>
    </xsl:variable>

    <!-- Resources -->
    <!-- TODO retrieve the webServiceTypes -->
    <xsl:variable name="webMapServicesProtocols" select="/root/gui/webServiceTypes" />
    <xsl:variable name="mapResourcesCount" select="count( /root/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role=$isoLang]/gmd:CI_OnlineResource[lower-case(normalize-space(gmd:protocol/gco:CharacterString))=$webMapServicesProtocols/record/name])"/>
    <xsl:variable name="resourcesCount" select="count( /root/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine)"/>
    <xsl:variable name="mapResourcesTotalCount" select="count( /root/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[lower-case(normalize-space(gmd:protocol/gco:CharacterString))=$webMapServicesProtocols/record/name])"/>

    <xsl:if test="$mapResourcesCount > 0">
      <!-- MAP RESOURCES -->
      <h3><xsl:value-of select="$schemaStrings/MapResources"/></h3>

      <xsl:call-template name="map-resources">
        <xsl:with-param name="langId" select="$langId" />
        <xsl:with-param name="webMapServicesProtocols" select="$webMapServicesProtocols" />
        <xsl:with-param name="isoLang" select="$isoLang" />
      </xsl:call-template>

    </xsl:if>

    <!-- Data resources -->
    <xsl:if test="($resourcesCount - $mapResourcesTotalCount) > 0">
      <h3><xsl:value-of select="$schemaStrings/Dataresources"/></h3>
      <!-- TODO return geonet:info/files inside the metadata element -->
      <xsl:variable name="resourceFiles" select="/root/*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/geonet:info/files" />

      <!-- first create a hidden window, below in this file are some hyperlink-create templates, some of them,
          like the download link, use the content in this div for a details-window -->
      <xsl:call-template name="data-resources">
        <xsl:with-param name="langId" select="$langId" />
        <xsl:with-param name="webMapServicesProtocols" select="$webMapServicesProtocols" />
      </xsl:call-template>
    </xsl:if>

    <!-- this template is in /envcan/metadata.xsl, and includes a title, if any relations -->
    <xsl:call-template name="parentCollection">
      <!-- TODO retrieve the parent metadata -->
      <xsl:with-param name="resources" select="/root/gui/relation/parent/response/*[geonet:info]"/>
      <xsl:with-param name="theme" select="geonet:info/Theme"/>
      <xsl:with-param name="subtheme" select="geonet:info/Subtheme"/>
      <xsl:with-param name="schema" select="geonet:info/schema"/>
    </xsl:call-template>

    <xsl:call-template name="relatedDatasets">
    <!-- TODO retrieve the children metadata -->
      <xsl:with-param name="resources" select="/root/gui/relation/children/response/*[geonet:info]|/root/gui/relation/services/response/*[geonet:info]|/root/gui/relation/related/response/*[geonet:info]"/>
    </xsl:call-template>


  </xsl:template>


  <xsl:template name="map-resources">
    <xsl:param name="langId" />
    <!-- TODO receive the right webMapServicesProtocols -->
    <xsl:param name="webMapServicesProtocols" />
    <xsl:param name="isoLang" />

    <div><h3>Map resources section (DELETE ME)</h3></div>
    <xsl:message>=== map-resources ===</xsl:message>

    <!-- TODO retrieve the isolanguages from the service -->
    <!--<xsl:variable name="isoLanguages" select="/root/gui/isolanguages" />-->

    <!--<xsl:variable name="lang">-->
      <!--<xsl:choose>-->
        <!--<xsl:when test="/root/lang='fra'">-->
          <!--<xsl:text>fre</xsl:text>-->
        <!--</xsl:when>-->
        <!--<xsl:otherwise>-->
          <!--<xsl:text>eng</xsl:text>-->
        <!--</xsl:otherwise>-->
      <!--</xsl:choose>-->
    <!--</xsl:variable>-->

    <!--<xsl:variable name="map_url">-->
      <!--<xsl:choose>-->
        <!--<xsl:when test="$lang = 'fre'"><xsl:value-of select="/root/gui/env/publication/mapviewer/viewonmap_fre" /></xsl:when>-->
        <!--<xsl:otherwise><xsl:value-of select="/root/gui/env/publication/mapviewer/viewonmap_eng" /></xsl:otherwise>-->
      <!--</xsl:choose>-->
    <!--</xsl:variable>-->

    <!--&lt;!&ndash; MAP RESOURCES &ndash;&gt;-->
    <!--<xsl:variable name="esriRestValue">esri rest: map service</xsl:variable>-->
    <!--<xsl:variable name="hasRESTService" select="count(/root/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[lower-case(normalize-space(gmd:protocol/gco:CharacterString))=$esriRestValue]) &gt; 0"/>-->

    <!--<xsl:for-each-group select="/root/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[lower-case(normalize-space(gmd:protocol/gco:CharacterString))=$webMapServicesProtocols/record/name]"-->
                        <!--group-by="tokenize(gmd:description/gco:CharacterString, ';')[1]">-->

      <!--<xsl:variable name="descriptionValue">-->
        <!--<xsl:for-each select="gmd:description">-->
          <!--<xsl:call-template name="localised">-->
            <!--<xsl:with-param name="langId" select="$langId"/>-->
          <!--</xsl:call-template>-->
        <!--</xsl:for-each>-->
      <!--</xsl:variable>-->

      <!--<h4><xsl:value-of select="tokenize($descriptionValue, ';')[1]"/></h4>-->

      <!--<table class="wb-tables table table-striped table-hover" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">-->
        <!--<xsl:attribute name="data-wb-tables">'{ "ordering" : false }</xsl:attribute>-->

        <!--<thead style="display: none">-->
          <!--<th style="width: 65%"><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Dataresources_Name" /></th>-->
          <!--<th style="width: 35%"><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Dataresources_Link" /></th>-->
        <!--</thead>-->
        <!--&lt;!&ndash;<xsl:for-each select="/root/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource|/root/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[not(string(@xlink:role))]/gmd:CI_OnlineResource">&ndash;&gt;-->
        <!--<xsl:for-each select="current-group()">-->
          <!--<xsl:sort select="gmd:protocol/gco:CharacterString" order="descending" />-->
          <!--<xsl:variable name="urlValue" select="normalize-space(gmd:linkage/gmd:URL)" />-->

          <!--<xsl:variable name="nameValue">-->
            <!--<xsl:for-each select="gmd:name">-->
              <!--<xsl:call-template name="localised">-->
                <!--<xsl:with-param name="langId" select="$langId"/>-->
              <!--</xsl:call-template>-->
            <!--</xsl:for-each>-->
          <!--</xsl:variable>-->

          <!--<xsl:variable name="descriptionValue">-->
            <!--<xsl:for-each select="gmd:description">-->
              <!--<xsl:call-template name="localised">-->
                <!--<xsl:with-param name="langId" select="$langId"/>-->
              <!--</xsl:call-template>-->
            <!--</xsl:for-each>-->
          <!--</xsl:variable>-->

          <!--<xsl:variable name="p" select="lower-case(normalize-space(gmd:protocol/gco:CharacterString))" />-->

          <!--<tr>-->
            <!--<td style="width: 65%"><span class="ec-word-wrap"><xsl:value-of select="$nameValue" />-->
              <!--(<xsl:choose>-->
                <!--<xsl:when test="../@xlink:role = 'urn:xml:lang:fra-CAN'"><xsl:value-of select="/root/gui/strings/french" /></xsl:when>-->
                <!--<xsl:otherwise><xsl:value-of select="/root/gui/strings/english" /></xsl:otherwise>-->
              <!--</xsl:choose>)</span></td>-->
            <!--<td style="width: 35%">-->
              <!--&lt;!&ndash; Access data button &ndash;&gt;-->
              <!--<div style="min-height:35px; margin-left: 5px" class="pull-right">-->
                <!--<a class="btn btn-default btn-sm" href="{$urlValue}">-->
                  <!--<xsl:value-of select="tokenize($descriptionValue, ';')[2]" />-->
                <!--</a>-->
              <!--</div>-->

              <!--&lt;!&ndash; Add view map buttons next to the RCS registered services, condition /root/gmd:MD_Metadata/geonet:info/rcs_priority_registered = '-1' maintained for legacy records &ndash;&gt;-->
              <!--<xsl:if test="/root/gui/env/publication/mapviewer/mapviewerenabled = 'true' and (/root/gmd:MD_Metadata/geonet:info/disabledMapServices = 'false' or not(/root/gmd:MD_Metadata/geonet:info/disabledMapServices)) and-->
                      <!--(((/root/gmd:MD_Metadata/geonet:info/rcs_protocol_registered != '-1') and ($webMapServicesProtocols/record[name = $p]/id = /root/gmd:MD_Metadata/geonet:info/rcs_protocol_registered)) or-->
                       <!--((/root/gmd:MD_Metadata/geonet:info/rcs_protocol_registered = '-1') and ((lower-case(gmd:protocol/gco:CharacterString) = $esriRestValue) or (not($hasRESTService) and lower-case(gmd:protocol/gco:CharacterString) = 'ogc:wms'))))">-->
                <!--<xsl:variable name="sq">'</xsl:variable>-->
                <!--<xsl:variable name="tsq">\\'</xsl:variable>-->
                <!--<xsl:variable name="titleMap"><xsl:apply-templates select="/root/*/geonet:info/uuid" mode="getMetadataTitle" /></xsl:variable>-->
                <!--<xsl:variable name="titleMapEscaped" select="replace($titleMap, $sq, $tsq)" />-->

                <!--<xsl:variable name="maxPreviewLayers" select="/root/gui/env/publication/mapviewer/maxlayersmappreview" />-->
                <!--<xsl:variable name="mapPreviewLayersMsg" select="replace(/root/gui/strings/maxpreviewlayers, '%1', $maxPreviewLayers)" />-->
                <!--<xsl:variable name="mapPreviewLayersTitle" select="/root/gui/strings/map-preview/dialogtitle" />-->
                <!--<xsl:variable name="mapPreviewLayersLayerAdd" select="/root/gui/strings/map-preview/dialoglayeradded" />-->
                <!--<xsl:variable name="mapPreviewLayersLayerExists" select="/root/gui/strings/map-preview/dialoglayerexists" />-->


                <!--<xsl:variable name="vm-smallkey">-->
                  <!--<xsl:choose>-->
                    <!--<xsl:when test="/root/*/geonet:info/workspace = 'true' or /root/*/geonet:info/status = '1'">draft-<xsl:value-of select="normalize-space(/root/*/geonet:info/smallkey)" /></xsl:when>-->
                    <!--<xsl:otherwise><xsl:value-of select="normalize-space(/root/*/geonet:info/smallkey)" /></xsl:otherwise>-->
                  <!--</xsl:choose>-->
                <!--</xsl:variable>-->

                <!--&lt;!&ndash; Add to map preview &ndash;&gt;-->

                <!--<div style="min-height:35px" class="pull-right">-->
                  <!--<a class="btn btn-default btn-sm" href="#">-->
                    <!--<xsl:attribute name="onclick">mappreview.addLayer('<xsl:value-of select="$urlValue" />','<xsl:value-of select="$titleMapEscaped" />','<xsl:value-of select="replace($nameValue, $sq, $tsq)" />',-->
                      <!--'<xsl:value-of select="replace($descriptionValue, $sq, $tsq)" />','<xsl:value-of select="normalize-space(gmd:protocol)" />',-->
                      <!--'<xsl:value-of select="normalize-space($vm-smallkey)" />', '<xsl:value-of select="$maxPreviewLayers" />',-->
                      <!--'<xsl:value-of select="$mapPreviewLayersMsg" />',-->
                      <!--'<xsl:value-of select="$mapPreviewLayersTitle" />', '<xsl:value-of select="$mapPreviewLayersLayerAdd" />',-->
                      <!--'<xsl:value-of select="$mapPreviewLayersLayerExists" />'); return false;</xsl:attribute>-->
                    <!--<xsl:value-of select="/root/gui/strings/map_page/add2mapPreview"/>-->
                  <!--</a>-->
                <!--</div>-->

              <!--</xsl:if>-->

              <!--<div style="clear:both;" />-->
            <!--</td>-->
          <!--</tr>-->

        <!--</xsl:for-each>-->


      <!--</table>-->
    <!--</xsl:for-each-group>-->

  </xsl:template>

  <xsl:template name="data-resources">
    <xsl:param name="langId" />
    <xsl:param name="webMapServicesProtocols" />

    <!-- TODO retrieve the isolanguages from the service -->
    <xsl:variable name="isoLanguages" select="/root/gui/isolanguages" />


    <xsl:for-each-group select="/root/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[not(lower-case(normalize-space(gmd:protocol/gco:CharacterString))=$webMapServicesProtocols/record/name)]"
                        group-by="tokenize(gmd:description/gco:CharacterString, ';')[1]">

      <xsl:variable name="descriptionValue">
        <xsl:for-each select="gmd:description">
          <xsl:call-template name="localised">
            <xsl:with-param name="langId" select="$langId"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:variable>

      <h4><xsl:value-of select="tokenize($descriptionValue, ';')[1]"/></h4>

      <table class="wb-tables table table-striped table-hover" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
        <xsl:attribute name="data-wb-tables">'{ "ordering" : false }</xsl:attribute>

        <thead style="display: none">
          <th style="width: 75%"><xsl:value-of select="/root/schemas/iso19139.nap/strings/Dataresources_Name" /></th>
          <th style="width: 25%"><xsl:value-of select="/root/schemas/iso19139.nap/strings/Dataresources_Link" /></th>
        </thead>

        <xsl:for-each select="current-group()">
          <xsl:variable name="urlValue" select="normalize-space(gmd:linkage/gmd:URL)" />

          <xsl:variable name="nameValue">
            <xsl:for-each select="gmd:name">
              <xsl:call-template name="localised">
                <xsl:with-param name="langId" select="$langId"/>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:variable>

          <xsl:variable name="descriptionValue">
            <xsl:for-each select="gmd:description">
              <xsl:call-template name="localised">
                <xsl:with-param name="langId" select="$langId"/>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:variable>

          <tr>
            <td style="width: 75%"><span class="ec-word-wrap"><xsl:value-of select="$nameValue" /></span></td>
            <td style="width: 25%">

              <a class="btn btn-default btn-sm pull-right" target="_blank" href="{$urlValue}">
                <xsl:attribute name="onclick">logExternalDownload('<xsl:value-of select="/root/gmd:MD_Metadata//gmd:fileIdentifier/gco:CharacterString" />','<xsl:value-of select="$urlValue" />');</xsl:attribute>

                <xsl:value-of select="tokenize($descriptionValue, ';')[2]" />
              </a>
            </td>
          </tr>
        </xsl:for-each>
      </table>
    </xsl:for-each-group>
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


  <xsl:template name="sidebar-panel">

    <!-- side bar-->
    <div class="col-md-4 row-end ec-md-detail mrgn-tp-sm">
      <!-- as defined in md-show -->
      <xsl:call-template name="md-sidebar-title">
        <xsl:with-param name="metadata" select="/root/gmd:MD_Metadata"/>
        <xsl:with-param name="info" select="/root/info/record"/>
      </xsl:call-template>

      <xsl:if test="/root/gmd:MD_Metadata//gmd:graphicOverview/gmd:MD_BrowseGraphic/gmd:fileName/gco:CharacterString!=''">

        <xsl:variable name="langId" select="$language" />

        <xsl:variable name="thumbnailName">
          <xsl:choose>
            <xsl:when test="$langId != 'eng'"><xsl:value-of select="concat('thumbnail_', $langId)" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="'thumbnail'" /></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="largeThumbnailName">
          <xsl:choose>
            <xsl:when test="$langId != 'eng'"><xsl:value-of select="concat('large_thumbnail_', $langId)" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="'large_thumbnail'" /></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="thumbnailNameOtherLang">
          <xsl:choose>
            <xsl:when test="$langId != 'fre'"><xsl:value-of select="'thumbnail_fre'" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="'thumbnail'" /></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="largeThumbnailNameOtherLang">
          <xsl:choose>
            <xsl:when test="$langId != 'fre'"><xsl:value-of select="'large_thumbnail_fre'" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="'large_thumbnail'" /></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="fileName">
          <xsl:choose>

            <!-- large thumbnail -->
            <xsl:when test="/root/gmd:MD_Metadata//gmd:graphicOverview/gmd:MD_BrowseGraphic/gmd:fileDescription/gco:CharacterString = $largeThumbnailName and
                            //gmd:graphicOverview/gmd:MD_BrowseGraphic[gmd:fileDescription/gco:CharacterString=$largeThumbnailName]/gmd:fileName/gco:CharacterString!=''">
              <xsl:value-of select="/root/gmd:MD_Metadata//gmd:graphicOverview/gmd:MD_BrowseGraphic[gmd:fileDescription/gco:CharacterString = $largeThumbnailName]/gmd:fileName/gco:CharacterString"/>
            </xsl:when>
            <!-- small thumbnail -->
            <xsl:when test="/root/gmd:MD_Metadata//gmd:graphicOverview/gmd:MD_BrowseGraphic/gmd:fileDescription/gco:CharacterString = $thumbnailName and
                            //gmd:graphicOverview/gmd:MD_BrowseGraphic[gmd:fileDescription/gco:CharacterString=$thumbnailName]/gmd:fileName/gco:CharacterString!=''">
              <xsl:value-of select="/root/gmd:MD_Metadata//gmd:graphicOverview/gmd:MD_BrowseGraphic[gmd:fileDescription/gco:CharacterString = $thumbnailName]/gmd:fileName/gco:CharacterString"/>
            </xsl:when>
            <!-- large thumbnail other language -->
            <xsl:when test="/root/gmd:MD_Metadata//gmd:graphicOverview/gmd:MD_BrowseGraphic/gmd:fileDescription/gco:CharacterString = $largeThumbnailNameOtherLang and
                              //gmd:graphicOverview/gmd:MD_BrowseGraphic[gmd:fileDescription/gco:CharacterString=$largeThumbnailNameOtherLang]/gmd:fileName/gco:CharacterString!=''">
              <xsl:value-of select="/root/gmd:MD_Metadata//gmd:graphicOverview/gmd:MD_BrowseGraphic[gmd:fileDescription/gco:CharacterString = $largeThumbnailNameOtherLang]/gmd:fileName/gco:CharacterString"/>
            </xsl:when>
            <!-- small thumbnail other language -->
            <xsl:when test="/root/gmd:MD_Metadata//gmd:graphicOverview/gmd:MD_BrowseGraphic/gmd:fileDescription/gco:CharacterString = $thumbnailNameOtherLang and
                              //gmd:graphicOverview/gmd:MD_BrowseGraphic[gmd:fileDescription/gco:CharacterString=$thumbnailNameOtherLang]/gmd:fileName/gco:CharacterString!=''">
              <xsl:value-of select="/root/gmd:MD_Metadata//gmd:graphicOverview/gmd:MD_BrowseGraphic[gmd:fileDescription/gco:CharacterString = $thumbnailNameOtherLang]/gmd:fileName/gco:CharacterString"/>
            </xsl:when>
            <!-- any thumbnail -->
            <xsl:otherwise>
              <xsl:value-of
                select="/root/gmd:MD_Metadata//gmd:graphicOverview/gmd:MD_BrowseGraphic[
                                  not(gmd:fileDescription/gco:CharacterString = 'thumbnail') and
                                   not(gmd:fileDescription/gco:CharacterString = 'thumbnail_fre') and
                                    not(gmd:fileDescription/gco:CharacterString = 'large_thumbnail') and
                                     not(gmd:fileDescription/gco:CharacterString = 'large_thumbnail_fre')][1]/gmd:fileName/gco:CharacterString"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:if test="/root/gmd:MD_Metadata//gmd:graphicOverview/gmd:MD_BrowseGraphic/gmd:fileName/gco:CharacterString=$fileName">
          <xsl:call-template name="showPanel">

            <xsl:with-param name="title"   select="/root/schemas/*[name()=$schema]/strings/Thumbnail"/>

            <xsl:with-param name="content">
              <xsl:choose>
                <xsl:when test="starts-with($fileName, 'http')">
                  <img class="ec-thumbnail" src="{$fileName}" itemprop="image" alt="{/root/gui/schemas/iso19139.nap/strings/Thumbnail}" title="{/root/gui/schemas/iso19139.nap/strings/Thumbnail}" />
                </xsl:when>
                <xsl:otherwise>
                  <img class="ec-thumbnail" src="{concat(/root/gui/url,'/srv/eng/resources.get?uuid=', /root/gmd:MD_Metadata//gmd:fileIdentifier/gco:CharacterString, '&amp;fname=', $fileName, '&amp;access=public')}" itemprop="image" alt="{/root/gui/schemas/iso19139.nap/strings/Thumbnail}" title="{/root/gui/schemas/iso19139.nap/strings/Thumbnail}" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>

      <xsl:for-each select="/root/gmd:MD_Metadata//gmd:identificationInfo/*/gmd:pointOfContact/gmd:CI_ResponsibleParty">

        <xsl:call-template name="showPanel">
          <xsl:with-param name="title"   select="/root/schemas/*[name()=$schema]/strings/Contact"/>
          <xsl:with-param name="content">
            <table class="sidebar" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
              <tbody>
                <xsl:apply-templates mode="render-field" select="." />
              </tbody>
            </table></xsl:with-param>
        </xsl:call-template>

      </xsl:for-each>


      <xsl:for-each select="/root/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty">
        <xsl:call-template name="showPanel">

          <xsl:with-param name="title"   select="/root/schemas/*[name()=$schema]/strings/MetadataContact"/>
          <xsl:with-param name="content">
            <table class="sidebar" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
              <tbody>
                <xsl:apply-templates mode="render-field" select="." />
              </tbody>
            </table>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>

      <xsl:for-each select="/root/gmd:MD_Metadata//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty">
        <xsl:call-template name="showPanel">

          <xsl:with-param name="title"   select="/root/schemas/*[name()=$schema]/strings/DataContact"/>
          <xsl:with-param name="content">
            <table class="sidebar" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
              <tbody>
                <xsl:apply-templates mode="render-field" select=".">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit" select="false"/>
                </xsl:apply-templates>
              </tbody>
            </table>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>

      <xsl:for-each select="/root/gmd:MD_Metadata//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty">
        <xsl:call-template name="showPanel">

          <xsl:with-param name="title"   select="/root/schemas/*[name()=$schema]/strings/DistributorContact"/>
          <xsl:with-param name="content">
            <table class="sidebar" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
              <tbody>
                <xsl:apply-templates mode="render-field" select="." />
              </tbody>
            </table>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>

     </div>
  </xsl:template>

  <xsl:template name="md-sidebar-title">
    <xsl:param name="metadata"/>
    <xsl:param name="info"/>
    <!-- export icons -->
    <div style="float:right" class="mrgn-bttm-sm">
      <xsl:call-template name="showMetadataExportIcons">
        <xsl:with-param name="info" select="$info" />
      </xsl:call-template>
    </div>
    <div style="clear:both"/>


    <xsl:call-template name="showPanel">
      <xsl:with-param name="title">
        <xsl:value-of select="/root/schemas/*[name()=$schema]/strings/Status"/>:

        <xsl:choose>

          <!-- no published copy available, always draft (or retired/rejected) -->
          <xsl:when test="not ($info/publishedCopy='true')">
            <xsl:value-of select="/root/gui/strings/*[name()=$info/statusName]"/>
          </xsl:when>

          <!-- when viewing draft of a published copy -->
          <xsl:when test="$info/workspace='true'">
            <xsl:value-of select="/root/gui/strings/*[name()=$info/statusName]"/> &#160;
            (<a href="{/root/gui/url}/metadata/{/root/gui/language}/{$info/uuid}" style="color:white" title="{/root/gui/strings/view_published}">
            <xsl:value-of select="/root/gui/strings/view"/>&#160;<xsl:value-of select="/root/gui/strings/published"/></a>)
          </xsl:when>

          <!-- if viewing puslished copy, status is draft, if a draft is available, but should show status published here, with option to visit draft, if you have right to view draft (=edit?) -->
          <xsl:when test="($info/status!='2') and ($info/edit='true')">
            <xsl:value-of select="/root/gui/strings/published"/> &#160;
            (<a href="{/root/gui/url}/metadata/{/root/gui/language}/{$info/uuid}?fromWorkspace=true" style="color:white" title="{/root/gui/strings/view_draft}">
            <xsl:value-of select="/root/gui/strings/view"/>&#160;<xsl:value-of select="/root/gui/strings/draft"/></a>)
          </xsl:when>

          <!-- else this is a published record without draft (status approved, display as 'published') -->
          <xsl:otherwise>
            <xsl:value-of select="/root/gui/strings/published"/>
          </xsl:otherwise>

        </xsl:choose>
      </xsl:with-param>

      <xsl:with-param name="content">
        <table style="border:none">
          <tbody>
            <tr valign="top">
              <td><xsl:value-of select="/root/schemas/*[name()=$schema]/strings/Publishedto"/>:</td>
              <td><xsl:value-of select="$info/publishedto"/></td>
            </tr>
            <tr valign="top">
              <td><!-- Owner -->
                <xsl:value-of select="/root/schemas/*[name()=$schema]/strings/owner"/>:
              </td>
              <td>
                <xsl:value-of select="$info/ownername"/>
              </td>
            </tr>
            <xsl:if test="$info/isLocked = 'y' and $info/workspace= 'true'">
              <tr valign="top">
                <td>
                  <xsl:value-of select="/root/schemas/*[name()=$schema]/strings/lastChangedBy"/>:
                </td>
                <td>
                  <xsl:value-of select="$info/lockername"/>
                </td>
              </tr>
            </xsl:if>

            <tr valign="top">
              <td>
                <xsl:value-of select="/root/schemas/*[name()=$schema]/strings/changeDate"/>:
              </td>
              <td>
                <xsl:value-of select="$info/datainfo/changedate"/>
              </td>
            </tr>


            <tr valign="top">
              <td><!-- Data Openness Rating -->
                <xsl:value-of select="/root/schemas/*[name()=$schema]/strings/rating"/>:
              </td>
              <td class="stars">
                <xsl:variable name="dataOpennessRating" select="'2'" />
                <xsl:choose>
                  <xsl:when test="not($info/dataOpennessRating) or $info/dataOpennessRating = 0">
                    <xsl:call-template name="ratingStars">
                      <xsl:with-param name="fill" select="false()" />
                      <xsl:with-param name="count" select="5" />
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:call-template name="ratingStars">
                      <xsl:with-param name="fill" select="true()" />
                      <xsl:with-param name="count" select="$info/dataOpennessRating" />
                    </xsl:call-template>
                    <xsl:call-template name="ratingStars">
                      <xsl:with-param name="fill" select="false()" />
                      <xsl:with-param name="count" select="5 - $info/dataOpennessRating" />
                    </xsl:call-template>
                  </xsl:otherwise>
                </xsl:choose>

              </td>
            </tr>

            <!--<tr>
              <td>
                <div  role="menubar">
                  <xsl:call-template name="buttons">
                    <xsl:with-param name="metadata" select="$metadata"/>
                  </xsl:call-template>
                </div>
              </td>
            </tr>-->
          </tbody>
        </table>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>
