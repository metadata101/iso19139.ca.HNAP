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
                xmlns:ns2="http://www.w3.org/2004/02/skos/core#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
                xmlns:gn-fn-render="http://geonetwork-opensource.org/xsl/functions/render"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:exslt="http://exslt.org/common"
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

  <xsl:variable name="thesauriDir" select="/root/thesaurusDir" />
  <xsl:variable name="resourceFormatsTh" select="document(concat('file:///', replace(concat($thesauriDir, '/local/thesauri/theme/EC_Resource_Formats.rdf'), '\\', '/')))" />


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

        <script>
          jQuery( ".wb-tables" ).trigger( "wb-init.wb-tables" );
        </script>

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

  <!-- template to display the province data license disclaimer -->
  <xsl:template name="provinceDataLicenseDisclaimer">

    <xsl:variable name="licensesEnglish">
      <licenses>
        <license gov="Government of British Columbia">Open Government Licence - British Columbia (https://www2.gov.bc.ca/gov/content/data/open-data/open-government-licence-bc)</license>
        <license gov="Government of Alberta">Open Government Licence - Alberta (https://open.alberta.ca/licence)</license>
        <license gov="Government of Newfoundland and Labrador">Open Government Licence – Newfoundland and Labrador (https://opendata.gov.nl.ca/public/opendata/page/?page-id=licence)</license>
        <license gov="Government of Nova Scotia">Open Government Licence – Nova Scotia (https://novascotia.ca/opendata/licence.asp)</license>
        <license gov="Government of Ontario">Open Government Licence – Ontario (https://www.ontario.ca/page/open-government-licence-ontario)</license>
        <license gov="Government of Prince Edward Island">Open Government Licence – Prince Edward Island (https://www.princeedwardisland.ca/en/information/finance/open-government-licence-prince-edward-island)</license>
        <license gov="Government of New Brunswick">Open Government Licence - New Brunswick (http://www.snb.ca/e/2000/data-E.html)</license>
        <license gov="Government of Yukon">Open Government Licence - Yukon (https://open.yukon.ca/open-government-licence-yukon)</license>
        <license gov="Quebec Government and Municipalities">Creative Commons 4.0 Attribution (CC-BY) licence – Quebec (https://www.donneesquebec.ca/fr/licence/)</license>
      </licenses>
    </xsl:variable>

    <xsl:variable name="licensesFrench">
      <licenses>
        <license gov="Gouvernement de la Colombie-Britannique">Licence du gouvernement ouvert - Colombie-Britannique (https://www2.gov.bc.ca/gov/content/data/open-data/open-government-licence-bc)</license>
        <license gov="Gouvernement de l'Alberta">Licence du gouvernement ouvert - Alberta (https://open.alberta.ca/licence)</license>
        <license gov="Gouvernement de Terre-Neuve-et-Labrador">Licence du gouvernement ouvert – Terre-Neuve-et-Labrador (https://opendata.gov.nl.ca/public/opendata/page/?page-id=licence)</license>
        <license gov="Gouvernement de la  Nouvelle-Écosse">Licence du gouvernement ouvert – Nouvelle-Écosse (https://novascotia.ca/opendata/licence.asp)</license>
        <license gov="Gouvernement de l'Ontario">Licence du gouvernement ouvert – Ontario (https://www.ontario.ca/fr/page/licence-du-gouvernement-ouvert-ontario)</license>
        <license gov="Gouvernement de l'Île-du-Prince-Édouard">Licence du gouvernement ouvert – Île-du-Prince-Édouard (https://www.princeedwardisland.ca/fr/information/finances/licence-du-gouvernement-ouvert-ile-du-prince-edouard)</license>
        <license gov="Gouvernement du Nouveau-Brunswick">Licence du gouvernement ouvert - Nouveau-Brunswick (http://www.snb.ca/f/2000/data-F.html)</license>
        <license gov="Gouvernement du Yukon">Licence du gouvernement ouvert - Yukon (https://open.yukon.ca/fr/gouvernement-ouvert-licence-du-yukon)</license>
        <license gov="Gouvernement et municipalités du Québec">Licence Creative Commons 4.0 Attribution (CC-BY) – Québec (https://www.donneesquebec.ca/fr/licence/)</license>

      </licenses>
    </xsl:variable>

    <xsl:variable name="hasProvinceLicense" select="if ($langForMetadata = 'fra') then
                  (count(/root/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation[gco:CharacterString = $licensesFrench/licenses/license or gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[1] = $licensesFrench/licenses/license]) > 0)
                  else
                  (count(/root/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation[gco:CharacterString = $licensesEnglish/licenses/license or gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[1] = $licensesEnglish/licenses/license]) > 0)" />


    <xsl:if test="$hasProvinceLicense = true()">
      <xsl:variable name="licenseValue1" select="if ($langForMetadata = 'fra') then
                  /root/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation[gco:CharacterString = $licensesFrench/licenses/license or gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[1] = $licensesFrench/licenses/license]/gco:CharacterString
                  else
                  /root/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation[gco:CharacterString = $licensesEnglish/licenses/license or gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[1] = $licensesEnglish/licenses/license]/gco:CharacterString" />

      <xsl:variable name="licenseValue2" select="if ($langForMetadata = 'fra') then
                  /root/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation[gco:CharacterString = $licensesFrench/licenses/license or gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[1] = $licensesFrench/licenses/license]/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[1]
                  else
                  /root/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation[gco:CharacterString = $licensesEnglish/licenses/license or gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[1] = $licensesEnglish/licenses/license]/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[1]" />

      <xsl:variable name="licenseGovernment" select="if ($langForMetadata = 'fra') then
                 $licensesFrench/licenses/license[. = $licenseValue1 or . = $licenseValue2]/@gov
                  else
                   $licensesEnglish/licenses/license[. = $licenseValue1 or . = $licenseValue2]/@gov" />

      <xsl:variable name="schemaStrings" select="/root/schemas/*[name()=$schema]/strings" />

      <section class="mrgn-tp-md">
        <details class="alert alert-info" id="alert-info" open="open">
          <summary class="h3">
            <h3> <xsl:value-of select="$schemaStrings/disclaimer_header"/>&#160;<xsl:value-of select="$licenseGovernment" /></h3>
          </summary>

          <xsl:copy-of select="$schemaStrings/disclaimer/*"/>
        </details>
      </section>
    </xsl:if>
  </xsl:template>

  <xsl:template name="common-detailview-fields">
    <xsl:param name="schema" />
    <xsl:param name="edit" />
    <xsl:param name="langForMetadata" />

    <xsl:variable name="schemaStrings" select="/root/schemas/*[name()=$schema]/strings" />

    <!-- md title -->
    <h1 id="wb-cont" style="border-bottom:none" itemprop="name">
      <!-- as defined in md-show -->
      <xsl:for-each select="/root/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title">
        <xsl:call-template name="localised">
          <xsl:with-param name="langId" select="$langForMetadata" />
        </xsl:call-template>
      </xsl:for-each>
    </h1>

    <xsl:apply-templates select="." mode="showAddMapCart" />

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

    <xsl:call-template name="provinceDataLicenseDisclaimer" />

    <div class="row mrgn-tp-md">
      <!-- Spatial extent -->
      <div class="col-md-6">
        <xsl:for-each select="/root/gmd:MD_Metadata//gmd:extent//gmd:EX_GeographicBoundingBox|/root/gmd:MD_Metadata//srv:extent//gmd:EX_GeographicBoundingBox">
          <xsl:variable name="minx" select="gmd:westBoundLongitude/gco:Decimal"/>
          <xsl:variable name="miny" select="gmd:southBoundLatitude/gco:Decimal"/>
          <xsl:variable name="maxx" select="gmd:eastBoundLongitude/gco:Decimal"/>
          <xsl:variable name="maxy" select="gmd:northBoundLatitude/gco:Decimal"/>
          <xsl:variable name="hasGeometry" select="($minx!='' and $miny!='' and $maxx!='' and $maxy!='' and (number($maxx)+number($minx)+number($maxy)+number($miny))!=0)"/>
          <xsl:variable name="geom" select="concat('POLYGON((', $minx, ' ', $miny,',',$maxx,' ',$miny,',',$maxx,' ',$maxy,',',$minx,' ',$maxy,',',$minx,' ',$miny, '))')"/>

          <xsl:if test="$hasGeometry">
            <span class="bold"><xsl:value-of select="$schemaStrings/GeographicExtent"/></span><br/>
            <span itemprop="spatial">
              <xsl:value-of select="$schemaStrings/sw"/>: <xsl:value-of select="concat(format-number(gmd:westBoundLongitude/gco:Decimal,'#.##'), ' ', format-number(gmd:southBoundLatitude/gco:Decimal,'#.##'))"/> <br/>
              <xsl:value-of select="$schemaStrings/ne"/>: <xsl:value-of select="concat(format-number(gmd:eastBoundLongitude/gco:Decimal,'#.##'), ' ', format-number(gmd:northBoundLatitude/gco:Decimal,'#.##'))"/>
            </span>
          </xsl:if>
        </xsl:for-each>
      </div>

      <!-- Time period -->
      <xsl:if test="/root/gmd:MD_Metadata//gmd:temporalElement">
        <div class="col-md-6">
          <xsl:for-each select="/root/gmd:MD_Metadata//gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod">
            <xsl:if test="position() > 1"><br/><br/></xsl:if>
            <span class="bold"><xsl:value-of select="$schemaStrings/Timeperiod"/></span><br/>
            <xsl:value-of select="$schemaStrings/from"/>: <span itemprop="temporal"><xsl:value-of select="gml:beginPosition"/></span> <br/>
            <xsl:value-of select="$schemaStrings/to"/>:  <span itemprop="temporal"><xsl:value-of select="gml:endPosition"/></span>
          </xsl:for-each>
        </div>
      </xsl:if>
    </div>

    <!--<script type="text/javascript">$( ".wb-geomap" ).trigger( "wb-init.wb-geomap" );</script>-->


    <div style="clear:left">&#160;</div>

    <xsl:variable name="lang">
      <xsl:choose>
        <xsl:when test="/root/lang='fra'">
          <xsl:text>fre</xsl:text>
        </xsl:when>
        <xsl:when test="/root/lang='fre'">
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
    <xsl:variable name="resourcesCount" select="count( /root/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine)"/>

    <xsl:if test="$resourcesCount > 0">
      <h3><xsl:value-of select="$schemaStrings/Dataresources"/></h3>

      <xsl:call-template name="md-resources">
        <xsl:with-param name="langId" select="$langId" />
        <xsl:with-param name="webMapServicesProtocols" select="$webMapServicesProtocols" />
        <xsl:with-param name="isoLang" select="$isoLang" />
      </xsl:call-template>
    </xsl:if>

    <!-- this template is in /envcan/metadata.xsl, and includes a title, if any relations -->
    <xsl:call-template name="parentCollection">
      <!-- TODO retrieve the parent metadata -->
      <xsl:with-param name="resources" select="/root/gui/related/parent/item"/>
      <xsl:with-param name="theme" select="/root/info/record/classificationinfo/theme"/>
      <xsl:with-param name="subtheme" select="/root/info/record/classificationinfo/subtheme"/>
      <xsl:with-param name="schema" select="/root/info/record/datainfo/schemaid"/>
    </xsl:call-template>

    <xsl:call-template name="relatedDatasets">
    <!-- TODO retrieve the children metadata -->
      <xsl:with-param name="resources" select="/root/gui/related/children/item"/>
    </xsl:call-template>

  </xsl:template>


  <!--
      Template: sidebar-panel

      Description: Displays the side bar panel.
  -->
  <xsl:template name="sidebar-panel">

    <!-- side bar-->
    <div class="col-md-4 row-end ec-md-detail mrgn-tp-sm">
      <!-- as defined in md-show -->

        <xsl:call-template name="md-sidebar-title">
          <xsl:with-param name="metadata" select="/root/gmd:MD_Metadata"/>
          <xsl:with-param name="info" select="/root/info/record"/>
        </xsl:call-template>

      <!-- Thumbnail/map -->
      <div class="wb-tabs ignore-session">
        <div class="tabpanels">
          <details id="details-thumbnail-{/root/info/record/id}">
            <summary><xsl:value-of select="/root/schemas/*[name()=$schema]/strings/display-thumbnails-header" /></summary>
            <xsl:call-template name="thumbnail">
              <xsl:with-param name="metadata" select="/root/gmd:MD_Metadata"/>
              <xsl:with-param name="id" select="/root/info/record/id"/>
              <xsl:with-param name="size" select="''" />
            </xsl:call-template>
          </details>
          <details id="details-overview-{/root/info/record/id}">
            <summary><xsl:value-of select="/root/schemas/*[name()=$schema]/strings/display-overviews-header" /></summary>

            <xsl:variable name="metadataTitle">
              <xsl:for-each select="/root/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title">
                <xsl:call-template name="localised">
                  <xsl:with-param name="langId" select="$langForMetadata" />
                </xsl:call-template>
              </xsl:for-each>
            </xsl:variable>

            <xsl:for-each select="/root/gmd:MD_Metadata//gmd:extent//gmd:EX_GeographicBoundingBox[1]|/root/gmd:MD_Metadata//srv:extent//gmd:EX_GeographicBoundingBox[1]">
              <xsl:variable name="minx" select="gmd:westBoundLongitude/gco:Decimal"/>
              <xsl:variable name="miny" select="gmd:southBoundLatitude/gco:Decimal"/>
              <xsl:variable name="maxx" select="gmd:eastBoundLongitude/gco:Decimal"/>
              <xsl:variable name="maxy" select="gmd:northBoundLatitude/gco:Decimal"/>
              <xsl:variable name="hasGeometry" select="($minx!='' and $miny!='' and $maxx!='' and $maxy!='' and (number($maxx)+number($minx)+number($maxy)+number($miny))!=0)"/>
              <xsl:variable name="geom" select="concat('POLYGON((', $minx, ' ', $miny,',',$maxx,' ',$miny,',',$maxx,' ',$maxy,',',$minx,' ',$maxy,',',$minx,' ',$miny, '))')"/>

              <img src="{/root/gui/url}/srv/eng/region.getmap.png?mapsrs=EPSG:3978&amp;geom={$geom}&amp;geomsrs=EPSG:4326&amp;background=geogratis-fgp&amp;width=380&amp;square=true&amp;densifybbox=true"
                   alt="{$metadataTitle}" title="{$metadataTitle}" class="full-width" />
            </xsl:for-each>
          </details>

        </div>

      </div>

      <script>
        jQuery( ".wb-tabs" ).trigger( "wb-init.wb-tabs" );
      </script>

      <xsl:call-template name="showPanel">
        <xsl:with-param name="title"   select="/root/schemas/*[name()=$schema]/strings/Dataclassification"/>
        <xsl:with-param name="content">
          <table class="sidebar" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
            <tbody>
              <!-- keywords (no Core Subject thesaurus) -->
              <xsl:variable name="kCodelist" select="/root/schemas/*[name()=$schema]/codelists/codelist[@name='gmd:MD_KeywordTypeCode']" />

              <xsl:for-each-group select="/root/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:descriptiveKeywords[
                not(normalize-space(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Government of Canada Core Subject Thesaurus') and
                not(normalize-space(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Thésaurus des sujets de base du gouvernement du Canada')]" group-by="gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue">

                <dl>
                  <dt>
                    <xsl:value-of select="$kCodelist/entry[code=current-grouping-key()]/label" />
                  </dt>
                  <dd>
                    <xsl:variable name="keywordsList">
                      <xsl:for-each select="current-group()">

                        <xsl:for-each select="gmd:MD_Keywords/gmd:keyword">
                          <xsl:variable name="keywordVal">
                            <xsl:call-template name="localised">
                              <xsl:with-param name="langId" select="$langForMetadata" />
                            </xsl:call-template>
                          </xsl:variable>

                          <xsl:value-of select="normalize-space($keywordVal)" /><xsl:if test="string(normalize-space($keywordVal))"><xsl:text>, </xsl:text></xsl:if>
                        </xsl:for-each>

                      </xsl:for-each>
                    </xsl:variable>

                    <xsl:variable name="keywordsListNorm" select="normalize-space($keywordsList)" />
                    <xsl:if test="string($keywordsListNorm)">
                      <xsl:value-of select="substring($keywordsListNorm, 1, string-length($keywordsListNorm) - 1)" />
                    </xsl:if>
                  </dd>
                </dl>

              </xsl:for-each-group>

              <xsl:apply-templates mode="render-field" select="/root/gmd:MD_Metadata//gmd:identificationInfo/*/gmd:descriptiveKeywords[contains(*/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString, 'Government of Canada Core Subject Thesaurus') or
                contains(*/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString, 'Thésaurus des sujets de base du gouvernement du Canada')]" />


              <xsl:apply-templates mode="render-field" select="/root/gmd:MD_Metadata//gmd:identificationInfo/*/gmd:topicCategory" />

              </tbody>
          </table></xsl:with-param>
      </xsl:call-template>


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

    <xsl:if test="/root/gui/session/userId != ''">
      <xsl:call-template name="showPanel">
        <xsl:with-param name="title">
          <xsl:value-of select="/root/schemas/*[name()=$schema]/strings/Status"/>:

          <xsl:choose>
            <xsl:when test="$info/status='4'">
              <xsl:value-of select="/root/schemas/*[name()=$schema]/strings/*[name()=$info/statusName]"/>

              <xsl:if test="$info/publishedCopy='true' and $info/workspace='false'">
                (<a href="{/root/gui/url}/metadata/{/root/lang}/{$info/uuid}" style="color:white" title="{/root/schemas/*[name()=$schema]/strings/view_draft}">
                <xsl:value-of select="/root/schemas/*[name()=$schema]/strings/view"/>&#160;<xsl:value-of select="/root/schemas/*[name()=$schema]/strings/draft"/></a>)
              </xsl:if>

              <xsl:if test="$info/publishedCopy='true' and $info/workspace='true'">
                (<a href="{/root/gui/url}/metadata/{/root/lang}/{$info/uuid}?draft=n" style="color:white" title="{/root/schemas/*[name()=$schema]/strings/view_published}">
                <xsl:value-of select="/root/schemas/*[name()=$schema]/strings/view"/>&#160;<xsl:value-of select="/root/schemas/*[name()=$schema]/strings/published"/></a>)
              </xsl:if>
            </xsl:when>


            <!-- no published copy available, always draft (or retired/rejected) -->
            <xsl:when test="not ($info/publishedCopy='true')">
              <xsl:value-of select="/root/schemas/*[name()=$schema]/strings/*[name()=$info/statusName]"/>
            </xsl:when>

            <!-- when viewing draft of a published copy -->
            <xsl:when test="$info/workspace='true'">
              <xsl:choose>
                <xsl:when test="$info/publishedCopy='true'">
                  <xsl:value-of select="/root/schemas/*[name()=$schema]/strings/approved_local"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="/root/schemas/*[name()=$schema]/strings/*[name()=$info/statusName]"/>
                </xsl:otherwise>
              </xsl:choose>
              (<a href="{/root/gui/url}/metadata/{/root/lang}/{$info/uuid}?view=published" style="color:white" title="{/root/schemas/*[name()=$schema]/strings/view_published}">
              <xsl:value-of select="/root/schemas/*[name()=$schema]/strings/view"/>&#160;<xsl:value-of select="/root/schemas/*[name()=$schema]/strings/published"/></a>)
            </xsl:when>

            <!-- if viewing puslished copy, status is draft, if a draft is available, but should show status published here, with option to visit draft, if you have right to view draft (=edit?) -->
            <!--<xsl:when test="($info/status!='2') and ($info/edit='true')">
              CCCC:<xsl:value-of select="/root/schemas/*[name()=$schema]/strings/published"/> &#160;
              (<a href="{/root/gui/url}/metadata/{/root/lang}/{$info/uuid}?fromWorkspace=true" style="color:white" title="{/root/gui/strings/view_draft}">
              <xsl:value-of select="/root/gui/strings/view"/>&#160;<xsl:value-of select="/root/gui/strings/draft"/></a>)
            </xsl:when>-->

            <!-- View published copy and allowed to see the draft -->
            <xsl:when test="($info/status='2') and ($info/edit='true') and ($info/workspace='false')  and ($info/hasDraft='true')">
              <xsl:value-of select="/root/schemas/*[name()=$schema]/strings/published"/> &#160;
              (<a href="{/root/gui/url}/metadata/{/root/lang}/{$info/uuid}" style="color:white" title="{/root/schemas/*[name()=$schema]/strings/view_draft}">
              <xsl:value-of select="/root/schemas/*[name()=$schema]/strings/view"/>&#160;<xsl:value-of select="/root/schemas/*[name()=$schema]/strings/draft"/></a>)
            </xsl:when>

            <!-- else this is a published record without draft (status approved, display as 'published') -->
            <xsl:otherwise>
              <xsl:value-of select="/root/schemas/*[name()=$schema]/strings/published"/>
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

              <!-- Data Openness Rating -->

              <!--<tr valign="top">
                <td>
                  <xsl:value-of select="/root/schemas/*[name()=$schema]/strings/rating"/>:
                </td>
                <td class="stars">
                  <xsl:variable name="dataOpennessRating" select="'2'" />
                  <xsl:choose>
                    <xsl:when test="not($info/datainfo/dataopennessrating ) or $info/datainfo/dataopennessrating = 0">
                      <xsl:call-template name="ratingStars">
                        <xsl:with-param name="fill" select="false()" />
                        <xsl:with-param name="count" select="5" />
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:call-template name="ratingStars">
                        <xsl:with-param name="fill" select="true()" />
                        <xsl:with-param name="count" select="$info/datainfo/dataopennessrating " />
                      </xsl:call-template>
                      <xsl:call-template name="ratingStars">
                        <xsl:with-param name="fill" select="false()" />
                        <xsl:with-param name="count" select="5 - $info/datainfo/dataopennessrating " />
                      </xsl:call-template>
                    </xsl:otherwise>
                  </xsl:choose>

                </td>
              </tr>-->

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
    </xsl:if>
  </xsl:template>


  <!--
      Template: md-resources

      Description: Display metadata resources.
  -->
  <xsl:template name="md-resources">
    <xsl:param name="langId" />
    <xsl:param name="webMapServicesProtocols" />
    <xsl:param name="isoLang" />

    <xsl:variable name="schemaStrings" select="/root/schemas/*[name()=$schema]/strings" />

    <xsl:variable name="isoLanguages" select="/root/gui/isolanguages" />

    <xsl:variable name="formatLang">
      <xsl:choose>
        <xsl:when test="/root/gui/language = 'fre'">fr</xsl:when>
        <xsl:otherwise>en</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <table class="wb-tables table table-striped table-hover table-bordered" role="grid">
      <xsl:attribute name="data-wb-tables">{"bPaginate": false, "searching":false, "info":false}</xsl:attribute>
      <thead>
        <th style="width: 45%"><xsl:value-of select="$schemaStrings/Dataresources_Name" /></th>
        <th style="width: 20%"><xsl:value-of select="$schemaStrings/Dataresources_Type" /></th>
        <th style="width: 10%"><xsl:value-of select="$schemaStrings/Dataresources_Lang" /></th>
        <th style="width: 20%; text-align:right"><xsl:value-of select="$schemaStrings/Dataresources_Format" /></th>
      </thead>

      <!-- Map resources managed by RCS-->
      <xsl:for-each-group select="/root/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[lower-case(normalize-space(gmd:protocol/gco:CharacterString))=$webMapServicesProtocols/record/name]"
                          group-by="tokenize(gmd:description/gco:CharacterString, ';')[1]">


        <xsl:for-each select="current-group()">
          <xsl:sort select="gmd:protocol/gco:CharacterString" order="descending" />
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

          <xsl:variable name="p" select="lower-case(normalize-space(gmd:protocol/gco:CharacterString))" />

          <xsl:variable name="formatKey" select="concat('http://geonetwork-opensource.org/EC/resourceformat#', tokenize($descriptionValue, ';')[2])" />
          <xsl:variable name="formatValue" select="$resourceFormatsTh/rdf:RDF/rdf:Description[@rdf:about=$formatKey]/ns2:prefLabel[@xml:lang=$formatLang]" />

          <tr>
            <td><xsl:value-of select="$nameValue" /></td>
            <td><xsl:value-of select="tokenize($descriptionValue, ';')[1]"/></td>
            <td>
              <xsl:variable name="langResource" select="tokenize($descriptionValue, ';')[3]" />
              <xsl:for-each select="tokenize($langResource, ',')">
                <xsl:variable name="v" select="." />
                <xsl:value-of select="$isoLanguages/record[code=$v]/label/*[name()=/root/lang]" /><xsl:if test="position() != last()">,</xsl:if>
              </xsl:for-each>
            </td>
            <td>
              <div style="min-height:35px; margin-left: 5px" class="pull-right">
                <a class="btn btn-default btn-sm" href="{$urlValue}"
                   title="{concat(/root/gui/strings/View, ' ', $formatValue, ' ', lower-case(/root/gui/schemas/iso19139.nap/strings/Dataresources_Format), ':&#160;', $nameValue )}">
                  <xsl:choose>
                    <xsl:when test="string($formatValue)"><xsl:value-of select="$formatValue" /></xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="tokenize($descriptionValue, ';')[2]" />
                    </xsl:otherwise>
                  </xsl:choose>
                </a>
              </div>
            </td>
          </tr>

        </xsl:for-each>

      </xsl:for-each-group>


      <!-- Other resources -->
      <xsl:for-each-group select="/root/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[not(lower-case(normalize-space(gmd:protocol/gco:CharacterString))=$webMapServicesProtocols/record/name)]"
                          group-by="tokenize(gmd:description/gco:CharacterString, ';')[1]">


        <xsl:for-each select="current-group()">
          <xsl:sort select="gmd:protocol/gco:CharacterString" order="descending" />
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

          <xsl:variable name="p" select="lower-case(normalize-space(gmd:protocol/gco:CharacterString))" />

          <xsl:variable name="formatKey" select="concat('http://geonetwork-opensource.org/EC/resourceformat#', tokenize($descriptionValue, ';')[2])" />
          <xsl:variable name="formatValue" select="$resourceFormatsTh/rdf:RDF/rdf:Description[@rdf:about=$formatKey]/ns2:prefLabel[@xml:lang=$formatLang]" />

          <tr>
            <td><xsl:value-of select="$nameValue" /></td>
            <td><xsl:value-of select="tokenize($descriptionValue, ';')[1]"/></td>
            <td>
              <xsl:variable name="langResource" select="tokenize($descriptionValue, ';')[3]" />
              <xsl:for-each select="tokenize($langResource, ',')">
                <xsl:variable name="v" select="." />
                <xsl:value-of select="$isoLanguages/record[code=$v]/label/*[name()=/root/lang]" /><xsl:if test="position() != last()">,</xsl:if>
              </xsl:for-each>

            </td>
            <td>

              <div style="min-height:35px; margin-left: 5px" class="pull-right">
                <a class="btn btn-default btn-sm pull-right" target="_blank" href="{$urlValue}"
                   title="{concat(/root/gui/strings/View, ' ', $formatValue, ' ', lower-case(/root/gui/schemas/iso19139.nap/strings/Dataresources_Format), ':&#160;', $nameValue )}">
                  <xsl:attribute name="onclick">logExternalDownload('<xsl:value-of select="/root/gmd:MD_Metadata//gmd:fileIdentifier/gco:CharacterString" />','<xsl:value-of select="$urlValue" />');</xsl:attribute>

                  <xsl:choose>
                    <xsl:when test="string($formatValue)"><xsl:value-of select="$formatValue" /></xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="tokenize($descriptionValue, ';')[2]" />
                    </xsl:otherwise>
                  </xsl:choose>
                </a>
              </div>
            </td>
          </tr>

        </xsl:for-each>

      </xsl:for-each-group>
    </table>
  </xsl:template>

</xsl:stylesheet>
