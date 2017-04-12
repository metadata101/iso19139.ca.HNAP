<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:math="http://exslt.org/math"
                xmlns:exslt="http://exslt.org/common"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:ns2="http://www.w3.org/2004/02/skos/core#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                xmlns:xls="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="gmx xsi gmd gco gml gts srv xlink exslt geonet rdf ns2 rdfs skos svrl math">

  <!-- Template for view mode. XML structure with editing information is quite different than "raw" metadata for view -->
  <xsl:template name="iso19139.napCustomView">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

    <xsl:variable name="langForMetadata">
      <xsl:call-template name="getLangForMetadata">
        <xsl:with-param name="uiLang" select="/root/gui/language" />
      </xsl:call-template>
    </xsl:variable>


    <div class="col-md-8 ec-md-detail" itemscope="" itemtype="http://schema.org/Dataset">


      <xsl:call-template name="common-detailview-fields">
        <xsl:with-param name="schema" select="$schema" />
        <xsl:with-param name="edit" select="$edit" />
        <xsl:with-param name="langForMetadata" select="$langForMetadata" />
      </xsl:call-template>


      <h3><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Additionalinformation"/></h3>


      <xsl:call-template name="showPanel">
        <xsl:with-param name="title"   select="/root/gui/schemas/iso19139.nap/strings/Metadatarecord"/>
        <xsl:with-param name="content">

          <table>
            <tbody>
              <xsl:apply-templates mode="elementEP" select="gmd:fileIdentifier|geonet:child[string(@name)='fileIdentifier']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>


              <!-- dataseturi -->
              <xsl:apply-templates mode="elementEP" select="gmd:dataSetURI">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <!-- Hierarchy level -->
              <xsl:apply-templates mode="elementEP" select="gmd:hierarchyLevel|geonet:child[string(@name)='hierarchyLevel']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <!-- Datestamp -->
              <xsl:apply-templates mode="elementEP" select="gmd:dateStamp|geonet:child[string(@name)='dateStamp']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <!-- ReferenceSystemInfo -->
              <xsl:for-each select="gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier">
                <xsl:apply-templates mode="elementEP" select="gmd:codeSpace">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit"   select="$edit"/>
                </xsl:apply-templates>
                <xsl:apply-templates mode="elementEP" select="gmd:code">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit"   select="$edit"/>
                </xsl:apply-templates>
                <xsl:apply-templates mode="elementEP" select="gmd:version">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit"   select="$edit"/>
                </xsl:apply-templates>
              </xsl:for-each>
            </tbody>
          </table>
        </xsl:with-param>
      </xsl:call-template>

      <xsl:call-template name="showPanel">
        <xsl:with-param name="title"   select="/root/gui/schemas/iso19139.nap/strings/Datasetidentification"/>
        <xsl:with-param name="content">
          <table>
            <tbody>
              <xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <xsl:apply-templates mode="elementEP" select="gmd:language|geonet:child[string(@name)='language']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <xsl:apply-templates mode="elementEP" select="gmd:characterSet|geonet:child[string(@name)='characterSet']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/*/gmd:status">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <!-- Maintenance and update frequency -->
              <xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/*/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency|geonet:child[string(@name)='maintenanceAndUpdateFrequency']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>


              <!-- Spatial representation type -->
              <xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/*/gmd:spatialRepresentationType|geonet:child[string(@name)='spatialRepresentationType']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <!-- Legal constraints -->
              <xsl:if test="gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints"><tr><td colspan="2"><hr/></td></tr></xsl:if>
              <xsl:for-each select="gmd:identificationInfo/*/gmd:resourceConstraints">
                <xsl:apply-templates mode="elementEP" select="gmd:MD_LegalConstraints">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit"   select="$edit"/>
                </xsl:apply-templates>
                <tr><td colspan="2"><hr/></td></tr>
              </xsl:for-each>
              <!--<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints">
                            <xsl:with-param name="schema" select="$schema"/>
                            <xsl:with-param name="edit"   select="$edit"/>
                        </xsl:apply-templates>-->

              <xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/*/gmd:supplementalInformation|geonet:child[string(@name)='supplementalInformation']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <!-- Service type - specific info -->
              <xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/*/srv:serviceType">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/*/srv:serviceTypeVersion">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/*/srv:couplingType">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <xsl:for-each select="gmd:identificationInfo/*/srv:containsOperations">
                <xsl:apply-templates mode="elementEP" select=".">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit"   select="$edit"/>
                </xsl:apply-templates>
              </xsl:for-each>
            </tbody>
          </table>
        </xsl:with-param>

      </xsl:call-template>

    </div>

    <xsl:call-template name="sidebar-panel">
      <xsl:with-param name="schema" select="$schema" />
      <xsl:with-param name="edit" select="$edit" />
      <xsl:with-param name="langForMetadata" select="$langForMetadata" />

    </xsl:call-template>

  </xsl:template>


  <xsl:template name="iso19139.napFullView">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

    <xsl:variable name="langForMetadata">
      <xsl:call-template name="getLangForMetadata">
        <xsl:with-param name="uiLang" select="/root/gui/language" />
      </xsl:call-template>
    </xsl:variable>

    <div class="col-md-8 ec-md-detail" itemscope="" itemtype="http://schema.org/Dataset">

      <xsl:call-template name="common-detailview-fields">
        <xsl:with-param name="schema" select="$schema" />
        <xsl:with-param name="edit" select="$edit" />
        <xsl:with-param name="langForMetadata" select="$langForMetadata" />
      </xsl:call-template>

      <h3><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Additionalinformation"/></h3>

      <xsl:call-template name="showPanel">

        <xsl:with-param name="title"   select="/root/gui/schemas/iso19139.nap/labels/element[@name='gmd:identificationInfo']/label"/>
        <xsl:with-param name="content">
          <table class="sidebar2" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
            <tbody>
              <xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/*/gmd:citation/*/*[name() != 'gmd:title' and name() != 'gmd:citedResponsibleParty']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit" select="false"/>
              </xsl:apply-templates>
              <xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/*/*[name() != 'gmd:citation' and
                name() != 'gmd:abstract' and name() != 'gmd:pointOfContact' and name() != 'gmd:descriptiveKeywords' and
                name() != 'gmd:extent' and name() != 'gmd:graphicOverview' and name() != 'gmd:topicCategory']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit" select="false"/>
              </xsl:apply-templates>
            </tbody>
          </table>
        </xsl:with-param>
      </xsl:call-template>

      <xsl:if test="gmd:contentInfo/*">
        <xsl:call-template name="showPanel">
          <xsl:with-param name="title"   select="/root/gui/schemas/iso19139.nap/labels/element[@name='gmd:contentInfo']/label"/>
          <xsl:with-param name="content">
            <table class="sidebar2" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
              <tbody>
                <xsl:apply-templates mode="elementEP" select="gmd:contentInfo/*">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit"   select="$edit"/>
                </xsl:apply-templates>
              </tbody>
            </table>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>

      <xsl:if test="gmd:distributionInfo/*/*[name() = 'gmd:distributionFormat']">
        <xsl:call-template name="showPanel">
          <xsl:with-param name="title"   select="/root/gui/schemas/iso19139.nap/labels/element[@name='gmd:distributionInfo']/label"/>
          <xsl:with-param name="content">
            <table class="sidebar2" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
              <tbody>
                <xsl:apply-templates mode="elementEP" select="gmd:distributionInfo/*/*[name() = 'gmd:distributionFormat']">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit"   select="$edit"/>
                </xsl:apply-templates>
              </tbody>
            </table>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>

      <xsl:if test="gmd:dataQualityInfo/*">
        <xsl:call-template name="showPanel">
          <xsl:with-param name="title"   select="/root/gui/schemas/iso19139.nap/labels/element[@name='gmd:dataQualityInfo']/label"/>
          <xsl:with-param name="content">
            <table class="sidebar2" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
              <tbody>
                <xsl:apply-templates mode="elementEP" select="gmd:dataQualityInfo/*">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit"   select="$edit"/>
                </xsl:apply-templates>
              </tbody>
            </table>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>

      <xsl:if test="gmd:portrayalCatalogueInfo/*">
        <xsl:call-template name="showPanel">
          <xsl:with-param name="title"   select="/root/gui/schemas/iso19139.nap/labels/element[@name='gmd:portrayalCatalogueInfo']/label"/>
          <xsl:with-param name="content">
            <table class="sidebar2" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
              <tbody>
                <xsl:apply-templates mode="elementEP" select="gmd:portrayalCatalogueInfo/*">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit"   select="$edit"/>
                </xsl:apply-templates>
              </tbody>
            </table>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>

      <xsl:if test="gmd:metadataConstraints/*">
        <xsl:call-template name="showPanel">
          <xsl:with-param name="title"   select="/root/gui/schemas/iso19139.nap/labels/element[@name='gmd:metadataConstraints']/label"/>
          <xsl:with-param name="content">
            <table class="sidebar2" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
              <tbody>
                <xsl:apply-templates mode="elementEP" select="gmd:metadataConstraints/*">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit"   select="$edit"/>
                </xsl:apply-templates>
              </tbody>
            </table>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>

      <xsl:if test="gmd:applicationSchemaInfo/*">
        <xsl:call-template name="showPanel">
          <xsl:with-param name="title"   select="/root/gui/schemas/iso19139.nap/labels/element[@name='gmd:applicationSchemaInfo']/label"/>
          <xsl:with-param name="content">
            <table class="sidebar2" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
              <tbody>
                <xsl:apply-templates mode="elementEP" select="gmd:applicationSchemaInfo/*">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit"   select="$edit"/>
                </xsl:apply-templates>
              </tbody>
            </table>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>

      <xsl:if test="gmd:metadataMaintenance/*">
        <xsl:call-template name="showPanel">
          <xsl:with-param name="title"   select="/root/gui/schemas/iso19139.nap/labels/element[@name='gmd:metadataMaintenance']/label"/>
          <xsl:with-param name="content">
            <table class="sidebar2" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
              <tbody>
                <xsl:apply-templates mode="elementEP" select="gmd:metadataMaintenance/*">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit"   select="$edit"/>
                </xsl:apply-templates>
              </tbody>
            </table>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>



      <xsl:call-template name="showPanel">
        <xsl:with-param name="title"   select="/root/gui/schemas/iso19139.nap/strings/Metadatarecord"/>
        <xsl:with-param name="content">

          <table>
            <tbody>
              <xsl:apply-templates mode="elementEP" select="gmd:fileIdentifier|geonet:child[string(@name)='fileIdentifier']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>


              <!-- dataseturi -->
              <xsl:apply-templates mode="elementEP" select="gmd:dataSetURI">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <!-- Hierarchy level -->
              <xsl:apply-templates mode="elementEP" select="gmd:hierarchyLevel|geonet:child[string(@name)='hierarchyLevel']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <xsl:apply-templates mode="elementEP" select="gmd:hierarchyLevelName|geonet:child[string(@name)='hierarchyLevelName']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <!-- Datestamp -->
              <xsl:apply-templates mode="elementEP" select="gmd:dateStamp|geonet:child[string(@name)='dateStamp']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <xsl:apply-templates mode="elementEP" select="gmd:language|geonet:child[string(@name)='language']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <xsl:apply-templates mode="elementEP" select="gmd:characterSet|geonet:child[string(@name)='characterSet']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>


              <!-- metadataStandardName -->
              <xsl:apply-templates mode="elementEP" select="gmd:metadataStandardName|geonet:child[string(@name)='metadataStandardName']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <xsl:apply-templates mode="elementEP" select="gmd:metadataStandardVersion|geonet:child[string(@name)='metadataStandardVersion']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>


              <xsl:apply-templates mode="elementEP" select="gmd:dataSetURI|geonet:child[string(@name)='dataSetURI']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <xsl:apply-templates mode="elementEP" select="gmd:locale|geonet:child[string(@name)='locale']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <!-- ReferenceSystemInfo -->
              <xsl:apply-templates mode="elementEP" select="gmd:referenceSystemInfo">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <!-- spatialRepresentationInfo -->
              <xsl:apply-templates mode="elementEP" select="gmd:spatialRepresentationInfo">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <xsl:apply-templates mode="elementEP" select="gmd:series|geonet:child[string(@name)='series']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <xsl:apply-templates mode="elementEP" select="gmd:describes|geonet:child[string(@name)='describes']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <xsl:apply-templates mode="elementEP" select="gmd:propertyType|geonet:child[string(@name)='propertyType']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <xsl:apply-templates mode="elementEP" select="gmd:featureType|geonet:child[string(@name)='featureType']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <xsl:apply-templates mode="elementEP" select="gmd:featureAttribute|geonet:child[string(@name)='featureAttribute']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

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
                <xsl:apply-templates mode="elementEP" select="gmd:metadataExtensionInfo/*">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit"   select="$edit"/>
                </xsl:apply-templates>
              </tbody>
            </table>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>

    </div>


    <xsl:call-template name="sidebar-panel">
      <xsl:with-param name="schema" select="$schema" />
      <xsl:with-param name="edit" select="$edit" />
      <xsl:with-param name="langForMetadata" select="$langForMetadata" />

    </xsl:call-template>
  </xsl:template>

  <xsl:template name="sidebar-panel">
    <xsl:param name="schema" />
    <xsl:param name="edit" />
    <xsl:param name="langForMetadata" />

    <!-- side bar-->
    <div class="col-md-4 row-end ec-md-detail mrgn-tp-sm">

      <!-- as defined in md-show -->
      <xsl:call-template name="md-sidebar-title">
        <xsl:with-param name="metadata" select="/root/gmd:MD_Metadata"/>
      </xsl:call-template>

      <xsl:if test="/root/gmd:MD_Metadata//gmd:graphicOverview/gmd:MD_BrowseGraphic/gmd:fileName/gco:CharacterString!=''">

        <xsl:variable name="langId" select="/root/gui/language" />

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

            <xsl:with-param name="title"   select="/root/gui/schemas/iso19139.nap/strings/Thumbnail"/>

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

      <xsl:call-template name="showPanel">
        <xsl:with-param name="title"   select="/root/gui/schemas/iso19139.nap/strings/Dataclassification"/>
        <xsl:with-param name="content">
          <table style="border:none; table-layout:fixed; width:99% !important; word-wrap: break-word;">

            <!-- keywords -->
            <xsl:variable name="kCodelist" select="/root/gui/schemas/iso19139.nap/codelists/codelist[@name='gmd:MD_KeywordTypeCode']" />

            <xsl:for-each-group select="/root/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:descriptiveKeywords[
                not(normalize-space(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Government of Canada Core Subject Thesaurus') and
                not(normalize-space(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Thésaurus des sujets de base du gouvernement du Canada')]" group-by="gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue">

              <tr>
                <th class="md" colspan="2"><span class="content">

                  <xsl:for-each select="gmd:MD_Keywords/gmd:type">
                    <xsl:variable name="kCode" select="gmd:MD_KeywordTypeCode/@codeListValue" />
                    <xsl:value-of select="$kCodelist/entry[code=$kCode]/label" />
                  </xsl:for-each>
                </span>
                </th>
              </tr>
              <tr>
                <td colspan="2">
                  <xsl:variable name="keywordsList">
                    <xsl:for-each select="current-group()">

                      <xsl:for-each select="gmd:MD_Keywords/gmd:keyword">
                        <xsl:variable name="keywordVal">
                          <xsl:call-template name="translatedString">
                            <xsl:with-param name="schema" select="$schema"/>
                            <xsl:with-param name="langId">
                              <xsl:call-template name="getLangId">
                                <xsl:with-param name="langGui" select="$langForMetadata"/>
                                <xsl:with-param name="md" select="ancestor-or-self::*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']" />
                              </xsl:call-template>
                            </xsl:with-param>
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
                </td>
              </tr>

            </xsl:for-each-group>


            <xsl:for-each-group select="/root/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:descriptiveKeywords[
                (normalize-space(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Government of Canada Core Subject Thesaurus') or
                (normalize-space(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Thésaurus des sujets de base du gouvernement du Canada')]" group-by="gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue">

              <tr>
                <th class="md" colspan="2"><span class="content">

                  <xsl:call-template name="getTitle">
                    <xsl:with-param name="name"   select="'CoreSubjectThesaurus'"/>
                    <xsl:with-param name="schema" select="$schema"/>
                  </xsl:call-template>
                </span>
                </th>
              </tr>
              <tr>
                <td colspan="2">
                  <xsl:variable name="keywordsList">
                    <xsl:for-each select="current-group()">

                      <xsl:for-each select="gmd:MD_Keywords/gmd:keyword">
                        <xsl:variable name="keywordVal">
                          <xsl:call-template name="translatedString">
                            <xsl:with-param name="schema" select="$schema"/>
                            <xsl:with-param name="langId">
                              <xsl:call-template name="getLangId">
                                <xsl:with-param name="langGui" select="$langForMetadata"/>
                                <xsl:with-param name="md" select="ancestor-or-self::*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']" />
                              </xsl:call-template>
                            </xsl:with-param>
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
                </td>
              </tr>

            </xsl:for-each-group>

            <tr>
              <th class="md" colspan="2"><span class="content">

                <xsl:call-template name="getTitle">
                  <xsl:with-param name="name"   select="'gmd:topicCategory'"/>
                  <xsl:with-param name="schema" select="$schema"/>
                </xsl:call-template>
              </span>
              </th>
            </tr>
            <tr>
              <td colspan="2">
                <xsl:variable name="topicCatList">
                  <xsl:for-each select="/root/gmd:MD_Metadata//gmd:topicCategory">
                    <xsl:variable name="val" select="gmd:MD_TopicCategoryCode" />
                    <xsl:variable name="label" select="/root/gui/schemas/*[name(.)=$schema]/codelists/codelist[@name = 'gmd:MD_TopicCategoryCode']/entry[code = $val]/label"/>
                    <xsl:value-of select="normalize-space($label)" /><xsl:if test="string(normalize-space($label))"><xsl:text>, </xsl:text></xsl:if>
                  </xsl:for-each>
                </xsl:variable>

                <xsl:variable name="topicCatListNorm" select="normalize-space($topicCatList)" />
                <xsl:if test="string($topicCatListNorm)">
                  <xsl:value-of select="substring($topicCatListNorm, 1, string-length($topicCatListNorm) - 1)" />
                </xsl:if>
              </td>
            </tr>


            <!--                        <tr><td colspan="2"><br/><br/></td></tr> -->
          </table>
        </xsl:with-param>
      </xsl:call-template>

      <xsl:for-each select="/root/gmd:MD_Metadata//gmd:identificationInfo/*/gmd:pointOfContact/gmd:CI_ResponsibleParty">

        <xsl:call-template name="showPanel">
          <xsl:with-param name="title"   select="/root/gui/strings/Contact"/>
          <xsl:with-param name="content">
            <table class="sidebar" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
              <tbody>
                <xsl:apply-templates mode="elementEP" select=".">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit" select="false"/>
                </xsl:apply-templates>
              </tbody>
            </table></xsl:with-param>
        </xsl:call-template>

      </xsl:for-each>


      <xsl:for-each select="/root/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty">
        <xsl:call-template name="showPanel">

          <xsl:with-param name="title"   select="/root/gui/strings/MetadataContact"/>
          <xsl:with-param name="content">
            <table class="sidebar" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
              <tbody>
                <xsl:apply-templates mode="elementEP" select=".">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit" select="false"/>
                </xsl:apply-templates>
              </tbody>
            </table>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>


      <xsl:for-each select="/root/gmd:MD_Metadata//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty">
        <xsl:call-template name="showPanel">

          <xsl:with-param name="title"   select="/root/gui/strings/DataContact"/>
          <xsl:with-param name="content">
            <table class="sidebar" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
              <tbody>
                <xsl:apply-templates mode="elementEP" select=".">
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

          <xsl:with-param name="title"   select="/root/gui/strings/DistributorContact"/>
          <xsl:with-param name="content">
            <table class="sidebar" style="table-layout:fixed; width:99% !important; word-wrap: break-word;">
              <tbody>
                <xsl:apply-templates mode="elementEP" select=".">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit" select="false"/>
                </xsl:apply-templates>
              </tbody>
            </table>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template name="common-detailview-fields">
    <xsl:param name="schema" />
    <xsl:param name="edit" />
    <xsl:param name="langForMetadata" />

    <!-- md title -->

    <h1 id="wb-cont" style="border-bottom:none" itemprop="name">
      <!-- as defined in md-show -->
      <img src="{/root/gui/url}/images/dataset.png" class="ds-icon-lg" alt="{/root/gui/strings/dataset}: {/root/gmd:MD_Metadata//gmd:title/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[string(@locale)='/root/gui/language']}" />
      <xsl:for-each select="/root/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title">
        <xsl:call-template name="localised">
          <xsl:with-param name="langId" select="$langForMetadata" />
        </xsl:call-template>
      </xsl:for-each>
    </h1>

    <!-- abstract -->
    <h3><xsl:value-of select="/root/gui/strings/description"/></h3>
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
        <div style="float:left;margin-right:10px;" role="map" aria-label="{/root/gui/stings/page_advanced/where_explained}">
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
          <span class="bold"><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/GeographicExtent"/></span><br/>
          <span itemprop="spatial">
            <xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/sw"/>: <xsl:value-of select="concat(format-number(gmd:westBoundLongitude/gco:Decimal,'#.##'), ' ', format-number(gmd:southBoundLatitude/gco:Decimal,'#.##'))"/> <br/>
            <xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/ne"/>: <xsl:value-of select="concat(format-number(gmd:eastBoundLongitude/gco:Decimal,'#.##'), ' ', format-number(gmd:northBoundLatitude/gco:Decimal,'#.##'))"/>
          </span>
        </xsl:if>

        <!-- GeographicScope -->
        <xsl:if test="/root/gmd:MD_Metadata//gmd:keyword[../gmd:thesaurusName/gmd:CI_Citation/@id = 'local.place.EC_Geographic_Scope']">
          <br/><br/><span class="bold"><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/GeographicScope"/></span><br/>

          <xsl:for-each select="/root/gmd:MD_Metadata//gmd:keyword[../gmd:thesaurusName/gmd:CI_Citation/@id = 'local.place.EC_Geographic_Scope']">
            <xsl:if test="position()!=1">,&#160;</xsl:if>
            <xsl:apply-templates mode="ecGeographicScope" select=".">
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="edit" select="$edit"/>
            </xsl:apply-templates>
          </xsl:for-each>
        </xsl:if>
        <!-- Time period -->
        <xsl:if test="/root/gmd:MD_Metadata//gmd:temporalElement">
          <xsl:for-each select="/root/gmd:MD_Metadata//gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod">

            <br/><br/><span class="bold"><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Timeperiod"/></span><br/>
            <xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/from"/>: <span itemprop="temporal"><xsl:value-of select="gml:beginPosition"/></span> <br/>
            <xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/to"/>:  <span itemprop="temporal"><xsl:value-of select="gml:endPosition"/></span>
          </xsl:for-each>
        </xsl:if>
      </div>
    </xsl:for-each>




    <div style="clear:left"></div>


    <xsl:variable name="isoLang">
      <xsl:choose>
        <xsl:when test="/root/gui/language='eng'">
          <xsl:text>urn:xml:lang:eng-CAN</xsl:text>
        </xsl:when>
        <xsl:when test="/root/gui/language='fre'">
          <xsl:text>urn:xml:lang:fra-CAN</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>


    <xsl:variable name="langId">
      <xsl:call-template name="getLangId">
        <xsl:with-param name="langGui" select="/root/gui/language" />
        <xsl:with-param name="md"
                        select="ancestor-or-self::*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']" />
      </xsl:call-template>
    </xsl:variable>

    <!-- Resources -->
    <xsl:variable name="webMapServicesProtocols" select="/root/gui/webServiceTypes" />
    <xsl:variable name="mapResourcesCount" select="count( /root/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role=$isoLang]/gmd:CI_OnlineResource[lower-case(normalize-space(gmd:protocol/gco:CharacterString))=$webMapServicesProtocols/record/name])"/>
    <xsl:variable name="resourcesCount" select="count( /root/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine)"/>
    <xsl:variable name="mapResourcesTotalCount" select="count( /root/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[lower-case(normalize-space(gmd:protocol/gco:CharacterString))=$webMapServicesProtocols/record/name])"/>

    <xsl:if test="$mapResourcesCount > 0">
      <!-- MAP RESOURCES -->
      <h3><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/MapResources"/></h3>

      <xsl:call-template name="map-resources">
        <xsl:with-param name="langId" select="$langId" />
        <xsl:with-param name="webMapServicesProtocols" select="$webMapServicesProtocols" />
        <xsl:with-param name="isoLang" select="$isoLang" />
      </xsl:call-template>

    </xsl:if>


    <!-- Data resources -->
    <xsl:if test="($resourcesCount - $mapResourcesTotalCount) > 0">
      <h3><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Dataresources"/></h3>
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
      <xsl:with-param name="resources" select="/root/gui/relation/parent/response/*[geonet:info]"/>
      <xsl:with-param name="theme" select="geonet:info/Theme"/>
      <xsl:with-param name="subtheme" select="geonet:info/Subtheme"/>
      <xsl:with-param name="schema" select="geonet:info/schema"/>
    </xsl:call-template>

    <xsl:call-template name="relatedDatasets">
      <xsl:with-param name="resources" select="/root/gui/relation/children/response/*[geonet:info]|/root/gui/relation/services/response/*[geonet:info]|/root/gui/relation/related/response/*[geonet:info]"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="map-resources">
    <xsl:param name="langId" />
    <xsl:param name="webMapServicesProtocols" />
    <xsl:param name="isoLang" />

    <xsl:variable name="isoLanguages" select="/root/gui/isolanguages" />

    <xsl:variable name="map_url">
      <xsl:choose>
        <xsl:when test="/root/gui/language = 'fre'"><xsl:value-of select="/root/gui/env/publication/mapviewer/viewonmap_fre" /></xsl:when>
        <xsl:otherwise><xsl:value-of select="/root/gui/env/publication/mapviewer/viewonmap_eng" /></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- MAP RESOURCES -->
    <xsl:variable name="esriRestValue">esri rest: map service</xsl:variable>
    <xsl:variable name="hasRESTService" select="count(/root/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[lower-case(normalize-space(gmd:protocol/gco:CharacterString))=$esriRestValue]) &gt; 0"/>

    <xsl:for-each-group select="/root/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[lower-case(normalize-space(gmd:protocol/gco:CharacterString))=$webMapServicesProtocols/record/name]"
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
          <th style="width: 65%"><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Dataresources_Name" /></th>
          <th style="width: 35%"><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Dataresources_Link" /></th>
        </thead>
        <!--<xsl:for-each select="/root/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource|/root/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[not(string(@xlink:role))]/gmd:CI_OnlineResource">-->
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

          <tr>
            <td style="width: 65%"><span class="ec-word-wrap"><xsl:value-of select="$nameValue" />
              (<xsl:choose>
                <xsl:when test="../@xlink:role = 'urn:xml:lang:fra-CAN'"><xsl:value-of select="/root/gui/strings/french" /></xsl:when>
                <xsl:otherwise><xsl:value-of select="/root/gui/strings/english" /></xsl:otherwise>
              </xsl:choose>)</span></td>
            <td style="width: 35%">
              <!-- Access data button -->
              <div style="min-height:35px; margin-left: 5px" class="pull-right">
                <a class="btn btn-default btn-sm" href="{$urlValue}">
                  <xsl:value-of select="tokenize($descriptionValue, ';')[2]" />
                </a>
              </div>

              <!-- Add view map buttons next to the RCS registered services, condition /root/gmd:MD_Metadata/geonet:info/rcs_priority_registered = '-1' maintained for legacy records -->
              <xsl:if test="(/root/gmd:MD_Metadata/geonet:info/disabledMapServices = 'false' or not(/root/gmd:MD_Metadata/geonet:info/disabledMapServices)) and
                      (((/root/gmd:MD_Metadata/geonet:info/rcs_protocol_registered != '-1') and ($webMapServicesProtocols/record[name = $p]/id = /root/gmd:MD_Metadata/geonet:info/rcs_protocol_registered)) or
                       ((/root/gmd:MD_Metadata/geonet:info/rcs_protocol_registered = '-1') and ((lower-case(gmd:protocol/gco:CharacterString) = $esriRestValue) or (not($hasRESTService) and lower-case(gmd:protocol/gco:CharacterString) = 'ogc:wms'))))">
                <xsl:variable name="sq">'</xsl:variable>
                <xsl:variable name="tsq">\\'</xsl:variable>
                <xsl:variable name="titleMap"><xsl:apply-templates select="/root/*/geonet:info/uuid" mode="getMetadataTitle" /></xsl:variable>
                <xsl:variable name="titleMapEscaped" select="replace($titleMap, $sq, $tsq)" />

                <xsl:variable name="maxPreviewLayers" select="/root/gui/env/publication/mapviewer/maxlayersmappreview" />
                <xsl:variable name="mapPreviewLayersMsg" select="replace(/root/gui/strings/maxpreviewlayers, '%1', $maxPreviewLayers)" />
                <xsl:variable name="mapPreviewLayersTitle" select="/root/gui/strings/map-preview/dialogtitle" />
                <xsl:variable name="mapPreviewLayersLayerAdd" select="/root/gui/strings/map-preview/dialoglayeradded" />
                <xsl:variable name="mapPreviewLayersLayerExists" select="/root/gui/strings/map-preview/dialoglayerexists" />


                <xsl:variable name="vm-smallkey">
                  <xsl:choose>
                    <xsl:when test="/root/*/geonet:info/workspace = 'true' or /root/*/geonet:info/status = '1'">draft-<xsl:value-of select="normalize-space(/root/*/geonet:info/smallkey)" /></xsl:when>
                    <xsl:otherwise><xsl:value-of select="normalize-space(/root/*/geonet:info/smallkey)" /></xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>

                <!-- Add to map preview -->

                <div style="min-height:35px" class="pull-right">
                  <a class="btn btn-default btn-sm" href="#">
                    <xsl:attribute name="onclick">mappreview.addLayer('<xsl:value-of select="$urlValue" />','<xsl:value-of select="$titleMapEscaped" />','<xsl:value-of select="replace($nameValue, $sq, $tsq)" />',
                      '<xsl:value-of select="replace($descriptionValue, $sq, $tsq)" />','<xsl:value-of select="normalize-space(gmd:protocol)" />',
                      '<xsl:value-of select="normalize-space($vm-smallkey)" />', '<xsl:value-of select="$maxPreviewLayers" />',
                      '<xsl:value-of select="$mapPreviewLayersMsg" />',
                      '<xsl:value-of select="$mapPreviewLayersTitle" />', '<xsl:value-of select="$mapPreviewLayersLayerAdd" />',
                      '<xsl:value-of select="$mapPreviewLayersLayerExists" />'); return false;</xsl:attribute>
                    <xsl:value-of select="/root/gui/strings/map_page/add2mapPreview"/>
                  </a>
                </div>

              </xsl:if>

              <div style="clear:both;" />
            </td>
          </tr>

        </xsl:for-each>


      </table>
    </xsl:for-each-group>

  </xsl:template>


  <xsl:template name="data-resources">
    <xsl:param name="langId" />
    <xsl:param name="webMapServicesProtocols" />

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
          <th style="width: 75%"><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Dataresources_Name" /></th>
          <th style="width: 25%"><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Dataresources_Link" /></th>
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
</xsl:stylesheet>
