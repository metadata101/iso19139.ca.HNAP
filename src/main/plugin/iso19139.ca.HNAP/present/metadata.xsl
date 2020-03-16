<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl ="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:exslt="http://exslt.org/common"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:ns2="http://www.w3.org/2004/02/skos/core#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                exclude-result-prefixes="gmx xsi gmd gco gml gts srv xlink exslt geonet rdf ns2 rdfs skos svrl">

  <xsl:import href="metadata-brief.xsl"/>
  <xsl:import href="metadata-fop.xsl"/>
  <xsl:import href="metadata-utils.xsl"/>
  <xsl:include href="iso19139.ec.HNAP-readonly.xsl"/>

  <!-- main template - the way into processing iso19139.ca.HNAP -->
  <xsl:template name="metadata-iso19139.ca.HNAP">
    <xsl:param name="schema"/>
    <xsl:param name="edit" select="false()"/>
    <xsl:param name="embedded"/>

    <xsl:apply-templates mode="iso19139" select="." >
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
      <xsl:with-param name="embedded" select="$embedded" />
    </xsl:apply-templates>

  </xsl:template>

  <xsl:template mode="iso19139" match="gmd:MD_Metadata|*[@gco:isoType='gmd:MD_Metadata']" priority="20">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:param name="embedded"/>

    <xsl:variable name="dataset" select="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset' or gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue=''"/>

    <!-- thumbnail -->
    <!--<tr>
            <td valign="middle" colspan="2">
                <xsl:if test="$currTab='metadata' or $currTab='identification' or /root/gui/config/metadata-tab/*[name(.)=$currTab]/@flat">
                    <div style="float:left;width:70%;text-align:center;">
                        <xsl:variable name="md">
                            <xsl:apply-templates mode="brief" select="."/>
                        </xsl:variable>
                        <xsl:variable name="metadata" select="exslt:node-set($md)/*[1]"/>
                        <xsl:call-template name="thumbnail">
                            <xsl:with-param name="metadata" select="$metadata"/>
                        </xsl:call-template>
                    </div>
                </xsl:if>
                <xsl:if test="/root/gui/config/editor-metadata-relation">
                    <div style="float:right;">
                        <xsl:call-template name="relatedResources">
                            <xsl:with-param name="edit" select="$edit"/>
                        </xsl:call-template>
                    </div>
                </xsl:if>
            </td>
        </tr>-->

    <xsl:choose>

      <!-- metadata tab -->
      <xsl:when test="$currTab='metadata'">
        <xsl:call-template name="iso19139Metadata">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:call-template>
      </xsl:when>

      <!-- identification tab -->
      <xsl:when test="$currTab='identification'">
        <xsl:apply-templates mode="elementEP" select="gmd:identificationInfo|geonet:child[string(@name)='identificationInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- maintenance tab -->
      <xsl:when test="$currTab='maintenance'">
        <xsl:apply-templates mode="elementEP" select="gmd:metadataMaintenance|geonet:child[string(@name)='metadataMaintenance']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- constraints tab -->
      <xsl:when test="$currTab='constraints'">
        <xsl:apply-templates mode="elementEP" select="gmd:metadataConstraints|geonet:child[string(@name)='metadataConstraints']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- spatial tab -->
      <xsl:when test="$currTab='spatial'">
        <xsl:apply-templates mode="elementEP" select="gmd:spatialRepresentationInfo|geonet:child[string(@name)='spatialRepresentationInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- refSys tab -->
      <xsl:when test="$currTab='refSys'">
        <xsl:apply-templates mode="elementEP" select="gmd:referenceSystemInfo|geonet:child[string(@name)='referenceSystemInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- distribution tab -->
      <xsl:when test="$currTab='distribution'">
        <xsl:apply-templates mode="elementEP" select="gmd:distributionInfo|geonet:child[string(@name)='distributionInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- embedded distribution tab -->
      <xsl:when test="$currTab='distribution2'">
        <xsl:apply-templates mode="elementEP" select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- dataQuality tab -->
      <xsl:when test="$currTab='dataQuality'">
        <xsl:apply-templates mode="elementEP" select="gmd:dataQualityInfo|geonet:child[string(@name)='dataQualityInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- appSchInfo tab -->
      <xsl:when test="$currTab='appSchInfo'">
        <xsl:apply-templates mode="elementEP" select="gmd:applicationSchemaInfo|geonet:child[string(@name)='applicationSchemaInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- porCatInfo tab -->
      <xsl:when test="$currTab='porCatInfo'">
        <xsl:apply-templates mode="elementEP" select="gmd:portrayalCatalogueInfo|geonet:child[string(@name)='portrayalCatalogueInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- contentInfo tab -->
      <xsl:when test="$currTab='contentInfo'">
        <xsl:apply-templates mode="elementEP" select="gmd:contentInfo|geonet:child[string(@name)='contentInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- extensionInfo tab -->
      <xsl:when test="$currTab='extensionInfo'">
        <xsl:apply-templates mode="elementEP" select="gmd:metadataExtensionInfo|geonet:child[string(@name)='metadataExtensionInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- ISOMinimum tab -->
      <xsl:when test="$currTab='ISOMinimum'">
        <xsl:call-template name="isotabs">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
          <xsl:with-param name="dataset" select="$dataset"/>
          <xsl:with-param name="core" select="false()"/>
        </xsl:call-template>
      </xsl:when>

      <!-- ISOCore tab -->
      <xsl:when test="$currTab='ISOCore'">
        <xsl:call-template name="isotabs">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
          <xsl:with-param name="dataset" select="$dataset"/>
          <xsl:with-param name="core" select="true()"/>
        </xsl:call-template>
      </xsl:when>

      <!-- ISOAll tab -->
      <xsl:when test="$currTab='ISOAll'">
        <xsl:call-template name="iso19139Complete">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:call-template>
      </xsl:when>

      <!-- INSPIRE tab -->
      <xsl:when test="$currTab='inspire'">
        <xsl:call-template name="inspiretabs">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
          <xsl:with-param name="dataset" select="$dataset"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="$edit=false()">
        <!--<xsl:choose>
                    <xsl:when test="/root/request/viewMode = 'full'">
                        <xsl:call-template name="iso19139.ca.HNAPFullView">
                            <xsl:with-param name="schema" select="$schema"/>
                            <xsl:with-param name="edit"   select="$edit"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="iso19139.ca.HNAPCustomView">
                            <xsl:with-param name="schema" select="$schema"/>
                            <xsl:with-param name="edit"   select="$edit"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>-->
        <xsl:call-template name="iso19139.ca.HNAPFullView">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:call-template>
      </xsl:when>

      <!-- default -->
      <xsl:otherwise>
        <xsl:call-template name="napIso19139Simple">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="getTooltipTitle-iso19139.ca.HNAP">
    <xsl:param name="name" />
    <xsl:param name="schema"/>

    <xsl:call-template name="getTooltipTitle-iso19139">
      <xsl:with-param name="name"   select="$name"/>
      <xsl:with-param name="schema" select="$schema"/>
    </xsl:call-template>
  </xsl:template>


  <!-- In order to add profil specific tabs
        add a template in this mode.

        To add some more tabs.
        <xsl:template mode="extraTab" match="/">
        <xsl:param name="tabLink"/>
        <xsl:param name="schema"/>
        <xsl:if test="$schema='iso19139.ca.HNAP'">
        ...
        </xsl:if>
        </xsl:template>
    -->
  <xsl:template mode="extraTab" match="/"/>

  <!-- ============================================================================= -->
  <!-- iso19139 complete tab template	-->
  <!-- ============================================================================= -->
  <xsl:template name="iso19139.ca.HNAPCompleteTab">
    <xsl:param name="tabLink"/>
    <xsl:param name="schema"/>

    <xsl:call-template name="iso19139CompleteTab">
      <xsl:with-param name="tabLink" select="$tabLink"/>
      <xsl:with-param name="schema" select="$schema"/>
    </xsl:call-template>

  </xsl:template>

  <!-- ============================================================================= -->
  <!-- iso19139.ca.HNAP custom elements -->
  <!-- ============================================================================= -->


  <!-- ================================================================= -->
  <!-- codelists -->
  <!-- ================================================================= -->

  <xsl:template mode="iso19139" match="gmd:*[*/@codeList]|srv:*[*/@codeList]" priority="10">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:call-template name="iso19139Codelist">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
    </xsl:call-template>
  </xsl:template>


  <!-- =================================================================== -->
  <!-- === Javascript used by functions in this presentation XSLT          -->
  <!-- =================================================================== -->
  <xsl:template name="iso19139.ca.HNAP-javascript"/>


  <!-- ================================================================== -->
  <!-- Callbacks from metadata-iso19139.xsl to add nap specific content -->
  <!-- ================================================================== -->


  <xsl:template name="napIso19139Simple">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

    <xsl:call-template name="complexElementGuiWrapper">
      <xsl:with-param name="title">
        <xsl:call-template name="getTitle">
          <xsl:with-param name="name"   select="'gmd:MD_Metadata'"/>
          <xsl:with-param name="schema" select="$schema"/>
        </xsl:call-template>
      </xsl:with-param>

      <xsl:with-param name="content">

        <!-- File identifier -->
        <xsl:apply-templates mode="elementEP" select="gmd:fileIdentifier|geonet:child[string(@name)='fileIdentifier']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>

        <!-- Datestamp -->
        <xsl:apply-templates mode="elementEP" select="gmd:dateStamp|geonet:child[string(@name)='dateStamp']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>

        <!-- Language -->
        <!--<xsl:apply-templates mode="elementEP" select="gmd:language|geonet:child[string(@name)='language']">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>-->

        <!-- Other language -->
        <!--<xsl:apply-templates mode="elementEP" select="gmd:locale/gmd:PT_Locale/gmd:languageCode/gmd:LanguageCode|geonet:child[string(@name)='LanguageCode']">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>-->

        <!-- Characterset -->
        <!--<xsl:apply-templates mode="elementEP" select="gmd:characterSet|geonet:child[string(@name)='characterSet']">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>-->

        <!-- Parent identifier -->
        <xsl:apply-templates mode="elementEP" select="gmd:parentIdentifier|geonet:child[string(@name)='parentIdentifier']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>

        <!-- Hierarchy level -->
        <xsl:apply-templates mode="elementEP" select="gmd:hierarchyLevel|geonet:child[string(@name)='hierarchyLevel']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>

        <!-- Dataset URI -->
        <!--<xsl:apply-templates mode="elementEP" select="gmd:dataSetURI|geonet:child[string(@name)='dataSetURI']">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>-->

        <!-- Metadata standard name -->
        <!--<xsl:apply-templates mode="elementEP" select="gmd:metadataStandardName|geonet:child[string(@name)='metadataStandardName']">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>-->


        <!-- Contact -->
        <xsl:apply-templates mode="elementEP" select="gmd:contact|geonet:child[string(@name)='contact']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>

        <!-- IdentificationInfo section -->
        <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification|
                            gmd:identificationInfo/srv:SV_ServiceIdentification|
                            gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']|
                            gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']">
          <xsl:call-template name="complexElementGuiWrapper">
            <xsl:with-param name="title">
              <xsl:call-template name="getTitle">
                <xsl:with-param name="name"   select="name()"/>
                <xsl:with-param name="schema" select="$schema"/>
              </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="content">

              <!-- Title -->
              <xsl:apply-templates mode="elementEP" select="gmd:citation/gmd:CI_Citation/gmd:title|gmd:citation/gmd:CI_Citation/geonet:child[string(@name)='title']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <!-- Date and date type -->
              <xsl:apply-templates mode="elementEP" select="gmd:citation/gmd:CI_Citation/gmd:date|gmd:citation/gmd:CI_Citation/geonet:child[string(@name)='date']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <xsl:variable name="refResourcesDates" select="gmd:citation/gmd:CI_Citation/geonet:element/@ref" />
              <xsl:if test="/root/request/showvalidationerrors = 'true'">
                <tr><td colspan="2">
                  <div id="valmessage_{$refResourcesDates}" class="editor-error">
                    <xsl:if test="count(//svrl:failed-assert[@ref=concat('#_',$refResourcesDates)]) = 0"><xsl:attribute name="style">display:none</xsl:attribute></xsl:if>

                    <xsl:for-each select="//svrl:failed-assert[@ref=concat('#_',$refResourcesDates)]">
                      <xsl:value-of select="."/><br/>
                    </xsl:for-each>
                  </div>
                </td> </tr>
              </xsl:if>

              <!-- Abstract -->
              <xsl:apply-templates mode="elementEP" select="gmd:abstract|geonet:child[string(@name)='abstract']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <!-- Status -->
              <xsl:apply-templates mode="elementEP" select="gmd:status|geonet:child[string(@name)='status']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <!-- Language -->
              <xsl:apply-templates mode="elementEP" select="gmd:language|geonet:child[string(@name)='language']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <!-- Character set -->
              <xsl:apply-templates mode="elementEP" select="gmd:characterSet|geonet:child[string(@name)='characterSet']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <!-- Topic category -->
              <xsl:apply-templates mode="elementEP" select="gmd:topicCategory|geonet:child[string(@name)='topicCategory']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <!-- Supplemental info -->
              <!--<xsl:apply-templates mode="elementEP" select="gmd:supplementalInformation|geonet:child[string(@name)='supplementalInformation']">
                          <xsl:with-param name="schema" select="$schema"/>
                          <xsl:with-param name="edit"   select="$edit"/>
                      </xsl:apply-templates>-->

              <!-- Maintenance and update frequency -->
              <xsl:apply-templates mode="elementEP" select="gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency|geonet:child[string(@name)='maintenanceAndUpdateFrequency']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <!-- Spatial Representation Type -->
              <xsl:apply-templates mode="elementEP" select="gmd:spatialRepresentationType|geonet:child[string(@name)='spatialRepresentationType']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>


              <!-- Citation Contact -->
              <xsl:apply-templates mode="elementEP" select="gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty|gmd:citation/gmd:CI_Citation/geonet:child[string(@name)='citedResponsibleParty']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <!-- Point of contact -->
              <xsl:apply-templates mode="elementEP" select="gmd:pointOfContact|geonet:child[string(@name)='pointOfContact']">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

            </xsl:with-param>

            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
            <xsl:with-param name="realname"   select="name(.)"/>
          </xsl:call-template>

          <!-- Keywords -->
          <xsl:call-template name="complexElementGuiWrapper">
            <xsl:with-param name="title">
              <xsl:call-template name="getTitle">
                <xsl:with-param name="name"   select="'gmd:MD_Keywords'"/>
                <xsl:with-param name="schema" select="$schema"/>
              </xsl:call-template>
            </xsl:with-param>

            <xsl:with-param name="content">


              <tr id="gmd:descriptiveKeywords_new" type="metadata" title="{/root/gui/strings/editor/addfreetextkeywords_desc}">
                <th class="padded-content" width="100%" colspan="2">
                  <xsl:value-of select="/root/gui/strings/editor/addfreetextkeywords" /><a id="add_gmd:descriptiveKeywords_new"
                                                                                           style="cursor:hand;cursor:pointer;"
                                                                                           onclick="if (noDoubleClick()) doNewElementAction('/metadata.elem.add',{geonet:element/@ref},'gmd:descriptiveKeywords','gmd:descriptiveKeywords_new','add',10000);" target="_blank">
                  <img class="icon" src="{/root/gui/url}/images/plus.gif" alt="Add add" title="Add add" />
                </a>
                </th>
              </tr>


              <xsl:apply-templates mode="elementEP" select="gmd:descriptiveKeywords[
				not(normalize-space(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Government of Canada Core Subject Thesaurus') and
          not(normalize-space(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Thésaurus des sujets de base du gouvernement du Canada')]">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

            </xsl:with-param>
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
            <xsl:with-param name="realname"   select="name(.)"/>
          </xsl:call-template>

          <xsl:call-template name="complexElementGuiWrapper">
            <xsl:with-param name="title">
              <xsl:call-template name="getTitle">
                <xsl:with-param name="name"   select="'CoreSubjectThesaurus'"/>
                <xsl:with-param name="schema" select="$schema"/>
              </xsl:call-template>
            </xsl:with-param>

            <xsl:with-param name="content">
              <!-- Government of Canada Core Subject Thesaurus. -->
              <xsl:variable name="countECCoreSubjectThesaurus" select="count(/root/gmd:MD_Metadata//gmd:keyword[
          normalize-space(../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Government of Canada Core Subject Thesaurus' or
          normalize-space(../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Thésaurus des sujets de base du gouvernement du Canada'])"/>
              <xsl:variable name="titleECGeographicScope">
                <xsl:call-template name="getTitle">
                  <xsl:with-param name="name"   select="'gmd:keyword'"/>
                  <xsl:with-param name="schema" select="$schema"/>
                </xsl:call-template>
              </xsl:variable>
              <xsl:variable name="tooltipECGeographicScope">
                <!-- Use dummy element name to identify field in metadata editor. In XML is stored as a keyword -->
                <xsl:call-template name="getTooltipTitle">
                  <xsl:with-param name="name"   select="'CoreSubjectThesaurus'"/>
                  <xsl:with-param name="schema" select="$schema"/>
                </xsl:call-template>
              </xsl:variable>

              <tr id="gmd:descriptiveKeywords_new2" type="metadata" title="{/root/gui/strings/editor/addcoresubjectkeywords_desc}">
                <th class="padded-content" width="100%" colspan="2">
                  <xsl:value-of select="/root/gui/strings/editor/addcoresubjectkeywords" />
                  <xsl:choose>
                    <xsl:when test="$countECCoreSubjectThesaurus &gt; 0">
                      <xsl:variable name="kCST" select="/root/gmd:MD_Metadata//gmd:keyword[
          normalize-space(../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Government of Canada Core Subject Thesaurus' or
          normalize-space(../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Thésaurus des sujets de base du gouvernement du Canada']" />

                      <a id="add-core-subject-keyword"
                         style="cursor:hand;cursor:pointer;"
                         onclick="if (noDoubleClick()) keywordSelectionPanel.showPanelAdd({$kCST[1]/geonet:element/@ref}, {$kCST[1]/geonet:element/@parent}, 1);" target="_blank">
                        <img class="icon" src="{/root/gui/url}/images/plus.gif" alt="Add" title="Add" />
                      </a>
                    </xsl:when>
                    <xsl:otherwise>
                      <a id="add-core-subject-keyword"
                         style="cursor:hand;cursor:pointer;"
                         onclick="if (noDoubleClick()) keywordSelectionPanel.showPanelAdd({geonet:element/@ref}, {geonet:element/@parent}, 2);" target="_blank">
                        <img class="icon" src="{/root/gui/url}/images/plus.gif" alt="Add add" title="Add add" />
                      </a>
                    </xsl:otherwise>
                  </xsl:choose>
                </th>
              </tr>

              <tr id="gmd:descriptiveKeywords_new2" type="metadata">
                <th class="padded-content" width="100%" colspan="2">&#160;</th>
              </tr>

              <!-- Government of Canada Core Subject Thesaurus -->
              <xsl:for-each select="/root/gmd:MD_Metadata//gmd:keyword[
          normalize-space(../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Government of Canada Core Subject Thesaurus' or
          normalize-space(../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Thésaurus des sujets de base du gouvernement du Canada']">
                <xsl:variable name="id">geographic_<xsl:value-of select="geonet:element/@uuid"/></xsl:variable>
                <xsl:variable name="last" select="position() = last()"/>
                <xsl:variable name="first" select="position() = 1"/>

                <xsl:call-template name="simpleElementGui">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit"       select="$edit"/>
                  <xsl:with-param name="id" select="$id"/>

                  <xsl:with-param name="title">
                    <!-- Use dummy element name to identify field in metadata editor. In XML is stored as a keyword -->
                    <xsl:value-of select="$titleECGeographicScope" />

                    <xsl:call-template name="asterisk">
                      <xsl:with-param name="edit" select="$edit"/>
                    </xsl:call-template>

                    <span id="buttons_{$id}">
                      <xsl:variable name="removeLink">
                        <xsl:value-of select="concat('doRemoveElementAction(',$apos,'/metadata.elem.delete',$apos,',',geonet:element/@ref,',',geonet:element/@parent,',',$apos,'',$id,$apos,',',../../geonet:element/@min,',',$apos, 'geographic' ,$apos, ');')"/>
                      </xsl:variable>

                      <xsl:if test="$edit">
                        <xsl:if test="not($first)">&#160;</xsl:if><a id="remove_{$id}" style="cursor:hand;cursor:pointer;" onclick="if (noDoubleClick()) {$removeLink}" target="_blank">
                        <xsl:attribute name="style">
                          cursor:hand;cursor:pointer;
                          <xsl:if test="$first">display:none;</xsl:if>
                        </xsl:attribute>

                        <img src="{/root/gui/url}/images/del.gif" class="icon" alt="{/root/gui/strings/del}" title="{/root/gui/strings/del}"/></a>
                      </xsl:if>

                    </span>

                  </xsl:with-param>
                  <xsl:with-param name="tooltip" select="$tooltipECGeographicScope" />

                  <xsl:with-param name="validationLink">
                    <xsl:variable name="ref" select="concat('#_',gco:CharacterString/geonet:element/@ref)"/>
                    <xsl:call-template name="validationLink">
                      <xsl:with-param name="ref" select="$ref"/>
                      <xsl:with-param name="title" select="$titleECGeographicScope"/>
                    </xsl:call-template>
                  </xsl:with-param>

                  <xsl:with-param name="text">
                    <xsl:variable name="mainLang">
                      <xsl:call-template name="getMainLangFromMetadata">
                        <xsl:with-param name="md" select="/root/*"/>
                      </xsl:call-template>
                    </xsl:variable>

                    <xsl:apply-templates mode="ecCoreSubjectThesaurus" select=".">
                      <xsl:with-param name="schema" select="$schema"/>
                      <xsl:with-param name="edit" select="$edit"/>
                      <!-- Metadata main language -->
                      <xsl:with-param name="langId">
                        <xsl:choose>
                          <xsl:when test="starts-with($mainLang, 'fra')">fra</xsl:when>
                          <xsl:otherwise>eng</xsl:otherwise>
                        </xsl:choose>
                      </xsl:with-param>
                    </xsl:apply-templates>
                  </xsl:with-param>

                </xsl:call-template>

              </xsl:for-each>

              <xsl:for-each select="/root/gmd:MD_Metadata//gmd:descriptiveKeywords[
          normalize-space(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Government of Canada Core Subject Thesaurus' or
          normalize-space(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Thésaurus des sujets de base du gouvernement du Canada']">
                <xsl:variable name="refDescriptiveKeywords" select="geonet:element/@ref" />
                <xsl:if test="/root/request/showvalidationerrors = 'true' and count(//svrl:failed-assert[@ref=concat('#_',$refDescriptiveKeywords)]) > 0">
                  <tr>
                    <td colspan="6">

                      <div id="valmessage_{../geonet:element/@ref}" class="editor-error">

                        <xsl:for-each select="//svrl:failed-assert[@ref=concat('#_',$refDescriptiveKeywords)]">
                          <xsl:value-of select="."/><br/>
                        </xsl:for-each>

                      </div>
                    </td>
                  </tr>
                </xsl:if>
              </xsl:for-each>

            </xsl:with-param>
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
            <xsl:with-param name="realname"   select="name(.)"/>
          </xsl:call-template>

          <!-- Resource constraints -->
          <xsl:apply-templates mode="elementEP" select="gmd:resourceConstraints|geonet:child[string(@name)='resourceConstraints']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
          </xsl:apply-templates>


          <!-- Extent -->
          <xsl:call-template name="complexElementGuiWrapper">
            <xsl:with-param name="title" select="/root/gui/schemas/iso19139/labels/element[@name='gmd:EX_Extent']/label"/>
            <xsl:with-param name="content">
              <xsl:for-each select="*/gmd:EX_Extent">


                <xsl:apply-templates mode="elementEP" select="*">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit"   select="$edit"/>
                </xsl:apply-templates>

              </xsl:for-each>
            </xsl:with-param>
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
            <xsl:with-param name="realname"   select="'gmd:EX_Extent'"/>
          </xsl:call-template>

          <!-- srv:serviceType -->
          <xsl:apply-templates mode="elementEP" select="srv:serviceType|geonet:child[string(@name)='serviceType']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
          </xsl:apply-templates>

          <!-- srv:serviceTypeVersion -->
          <xsl:apply-templates mode="elementEP" select="srv:serviceTypeVersion|geonet:child[string(@name)='serviceTypeVersion']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
          </xsl:apply-templates>

          <!-- srv:accessProperties -->
          <xsl:apply-templates mode="elementEP" select="srv:accessProperties|geonet:child[string(@name)='accessProperties']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
          </xsl:apply-templates>

          <!-- srv:couplingType -->
          <xsl:apply-templates mode="elementEP" select="srv:couplingType|geonet:child[string(@name)='couplingType']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
          </xsl:apply-templates>

          <!-- srv:containsOperations -->
          <xsl:apply-templates mode="elementEP" select="srv:containsOperations|geonet:child[string(@name)='containsOperations']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
          </xsl:apply-templates>

          <!-- srv:operatesOn -->
          <xsl:apply-templates mode="elementEP" select="srv:operatesOn|geonet:child[string(@name)='operatesOn']">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
          </xsl:apply-templates>
        </xsl:for-each>

        <!-- Reference System Information -->
        <xsl:apply-templates mode="elementEP" select="gmd:referenceSystemInfo|geonet:child[string(@name)='referenceSystemInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>

        <!-- Distribution information -->
        <!-- Distribution format -->
        <xsl:apply-templates mode="elementEP" select="gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat|gmd:distributionInfo/*[@gco:isoType='gmd:MD_Distribution']/gmd:distributionFormat">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>

        <xsl:variable name="webMapServicesProtocols" select="/root/gui/webServiceTypes" />

        <xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution|gmd:distributionInfo/*[@gco:isoType='gmd:MD_Distribution']">

          <xsl:call-template name="complexElementGuiWrapper">
            <xsl:with-param name="title">
              <xsl:call-template name="getTitle">
                <xsl:with-param name="name"   select="'gmd:distributionInfo'"/>
                <xsl:with-param name="schema" select="$schema"/>
              </xsl:call-template>
            </xsl:with-param>

            <xsl:with-param name="content">

              <xsl:call-template name="complexElementGuiWrapper">
                <xsl:with-param name="title" select="/root/gui/schemas/iso19139.ca.HNAP/labels/element[@name='gmd:distributorContact']/label"/>
                <xsl:with-param name="content">
                  <xsl:apply-templates mode="elementEP" select="gmd:distributor/gmd:MD_Distributor/gmd:distributorContact ">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit"   select="$edit"/>
                  </xsl:apply-templates>
                </xsl:with-param>
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
                <xsl:with-param name="realname"   select="'gmd:distributorContact'"/>
              </xsl:call-template>

              <xsl:variable name="langId">
                <xsl:call-template name="getLangId">
                  <xsl:with-param name="langGui" select="/root/gui/language" />
                  <xsl:with-param name="md"
                                  select="ancestor-or-self::*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']" />
                </xsl:call-template>
              </xsl:variable>

              <!-- MAP RESOURCES -->
              <tr>
                <td>
                  <h4 title="{/root/gui/schemas/iso19139.ca.HNAP/strings/MapResourcesDesc}">
                    <span class="btn btn-success pull-right btn-xs" onclick="dataDepositMap.showAddMapServiceResource()">
                      <span class="glyphicon glyphicon-plus"></span>&#160;<xsl:value-of select="/root/gui/schemas/iso19139.ca.HNAP/strings/AddMapServiceResource" /></span>
                    <xsl:value-of select="/root/gui/schemas/iso19139.ca.HNAP/strings/MapResources" /></h4>

                  <xsl:variable name="refResources" select="geonet:element/@ref" />

                  <p><xsl:value-of select="/root/gui/schemas/iso19139.ca.HNAP/strings/MapResourcesDesc" /></p>

                  <xsl:if test="/root/request/showvalidationerrors = 'true'">

                    <div id="valmessage_{$refResources}" class="editor-error">
                      <xsl:if test="count(//svrl:failed-assert[@ref=concat('#_',$refResources)]) = 0"><xsl:attribute name="style">display:none</xsl:attribute></xsl:if>

                      <xsl:for-each select="//svrl:failed-assert[@ref=concat('#_',$refResources)]">
                        <xsl:value-of select="."/><br/>
                      </xsl:for-each>
                    </div>
                  </xsl:if>
                </td>
              </tr>
              <tr>
                <td>
                  <table class="table table-striped" id="mapservice-resources-table" style="width:100%">
                    <thead>
                      <tr>
                        <th style="min-width:10px"><xsl:value-of select="/root/gui/schemas/iso19139.ca.HNAP/strings/Dataresources_RCS" /></th>
                        <th style="min-width:100px"><xsl:value-of select="/root/gui/schemas/iso19139.ca.HNAP/strings/Dataresources_Service" /></th>
                        <th style="min-width:100px"><xsl:value-of select="/root/gui/schemas/iso19139.ca.HNAP/strings/Dataresources_Layer" /></th>
                        <th style="min-width:100px"><xsl:value-of select="/root/gui/schemas/iso19139.ca.HNAP/strings/Dataresources_Description" /></th>
                        <th style="min-width:100px"><xsl:value-of select="/root/gui/schemas/iso19139.ca.HNAP/strings/Dataresources_Protocol" /></th>
                        <th style="min-width:100px"><xsl:value-of select="/root/gui/schemas/iso19139.ca.HNAP/strings/Dataresources_Language" /></th>
                        <th style="min-width:100px">&#160;</th>

                      </tr>
                    </thead>
                    <tbody>
                      <xsl:variable name="rcs_protocol_preferred" select="/root/gmd:MD_Metadata/geonet:info/rcs_protocol_preferred" />
                      <xsl:variable name="rcs_protocol_registered" select="/root/gmd:MD_Metadata/geonet:info/rcs_protocol_registered" />
                      <xsl:for-each select="gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[lower-case(normalize-space(gmd:protocol/gco:CharacterString)) = $webMapServicesProtocols/record/name]">
                        <xsl:sort select="concat(gmd:protocol/gco:CharacterString, ../@xlink:role)" />

                        <xsl:variable name="titleId" select="../@xlink:title" />
                        <tr id="resource_{../@xlink:title}">
                          <!-- Register RCS -->
                          <td>
                            <xsl:variable name="l" select="../@xlink:role" />
                            <xsl:variable name="p" select="lower-case(normalize-space(gmd:protocol/gco:CharacterString))" />

                            <xsl:if test="count(//root/gui/webServiceTypes/record[register_rcs = 'y' and name = $p]) = 1">
                              <input type="radio" value="{//root/gui/webServiceTypes/record[register_rcs = 'y' and name = $p]/id}" name="rcs_priority">

                                <xsl:choose>
                                  <xsl:when test="$rcs_protocol_preferred = '-1' and $rcs_protocol_registered = '-1'">
                                    <xsl:if test="//root/gui/webServiceTypes/record[register_rcs = 'y']/name = $p">
                                      <xsl:attribute name="checked">checked</xsl:attribute>
                                    </xsl:if>
                                  </xsl:when>
                                  <xsl:when test="$rcs_protocol_preferred = '-1' and $rcs_protocol_registered != '-1'">
                                    <xsl:if test="//root/gui/webServiceTypes/record[register_rcs = 'y' and name = $p]/id = $rcs_protocol_registered">
                                      <xsl:attribute name="checked">checked</xsl:attribute>
                                    </xsl:if>
                                  </xsl:when>
                                  <xsl:when test="$rcs_protocol_preferred != '-1' and $rcs_protocol_registered = '-1'">
                                    <xsl:if test="//root/gui/webServiceTypes/record[register_rcs = 'y' and name = $p]/id = $rcs_protocol_preferred">
                                      <xsl:attribute name="checked">checked</xsl:attribute>
                                    </xsl:if>
                                  </xsl:when>
                                  <xsl:otherwise>
                                    <xsl:if test="//root/gui/webServiceTypes/record[register_rcs = 'y' and name = $p]/id = $rcs_protocol_registered or
                                                //root/gui/webServiceTypes/record[register_rcs = 'y' and name = $p]/id = $rcs_protocol_preferred">
                                      <xsl:attribute name="checked">checked</xsl:attribute>
                                    </xsl:if>
                                  </xsl:otherwise>
                                </xsl:choose>
                              </input>
                            </xsl:if>

                          </td>
                          <!-- Service -->
                          <td>
                            <xsl:variable name="serviceName">
                              <xsl:value-of select="gmd:linkage/gmd:URL" />
                            </xsl:variable>

                            <a target="_blank" title="{gmd:linkage/gmd:URL}" href="{gmd:linkage/gmd:URL}">
                              <xsl:choose>
                                <xsl:when test="string-length($serviceName) &gt; 20"><xsl:value-of select="substring($serviceName,1, 17)" />...</xsl:when>
                                <xsl:otherwise><xsl:value-of select="$serviceName" /></xsl:otherwise>
                              </xsl:choose>
                            </a>

                          </td>
                          <!-- Name -->
                          <td>
                            <xsl:variable name="resourceName">
                              <xsl:for-each select="gmd:name">
                                <xsl:call-template name="localised">
                                  <xsl:with-param name="langId" select="$langId"/>
                                </xsl:call-template>
                              </xsl:for-each>
                            </xsl:variable>

                            <xsl:value-of select="$resourceName" />
                          </td>
                          <!-- Description -->
                          <td>
                            <xsl:variable name="resourceDesc">
                              <xsl:for-each select="gmd:description">
                                <xsl:call-template name="localised">
                                  <xsl:with-param name="langId" select="$langId"/>
                                </xsl:call-template>
                              </xsl:for-each>
                            </xsl:variable>
                            <xsl:value-of select="$resourceDesc" /></td>
                          <!-- Protocol -->
                          <td>
                            <xsl:value-of select="gmd:protocol" />
                          </td>
                          <td>
                            <xsl:choose>
                              <xsl:when test="../@xlink:role='urn:xml:lang:fra-CAN'">
                                <xsl:value-of select="'French'" />
                              </xsl:when>
                              <xsl:otherwise><xsl:value-of select="'English'" /></xsl:otherwise>
                            </xsl:choose>
                          </td>
                          <td>

                            <span role="button" class="btn btn-warning btn-xs"
                                  onclick="if (noDoubleClick()) dataDepositMap.showEditMapServiceResource('{../@xlink:title}', '')">
                              <span class="glyphicon glyphicon-pencil"></span></span>&#160;
                            <span role="button" class="btn btn-danger btn-xs"
                                  onclick="if (noDoubleClick()) dataDepositMap.removeResource('{../@xlink:title}', '')" >
                              <span class="glyphicon glyphicon-remove"></span></span>

                          </td>

                        </tr>
                        <xsl:variable name="refOnlineRes" select="../geonet:element/@ref" />
                        <xsl:if test="/root/request/showvalidationerrors = 'true' and count(//svrl:failed-assert[@ref=concat('#_',$refOnlineRes)]) > 0">
                          <tr>
                            <td colspan="6">

                              <div id="valmessage_{../geonet:element/@ref}" class="editor-error">

                                <xsl:for-each select="//svrl:failed-assert[@ref=concat('#_',$refOnlineRes)]">
                                  <xsl:value-of select="."/><br/>
                                </xsl:for-each>

                              </div>
                            </td>
                          </tr>
                        </xsl:if>
                      </xsl:for-each>
                    </tbody>
                  </table>

                </td>
              </tr>

              <tr>
                <td>&#160;</td>
              </tr>

              <!-- DATA RESOURCES -->
              <tr>
                <td>

                  <h4 title="{/root/gui/schemas/iso19139.ca.HNAP/strings/DataresourcesDesc}">
                    <span role="button" class="btn btn-success pull-right btn-xs" onclick="dataDeposit.showAddDataResource()">
                      <span class="glyphicon glyphicon-plus"></span>&#160;<xsl:value-of select="/root/gui/schemas/iso19139.ca.HNAP/strings/AddDataResource" /></span>
                    <xsl:value-of select="/root/gui/schemas/iso19139.ca.HNAP/strings/Dataresources" />
                  </h4>
                  <p><xsl:value-of select="/root/gui/schemas/iso19139.ca.HNAP/strings/DataresourcesDesc" /></p>
                </td>
              </tr>
              <tr>
                <td>
                  <table class="table table-striped" id="data-resources-table">
                    <thead>
                      <tr>
                        <th><xsl:value-of select="/root/gui/schemas/iso19139.ca.HNAP/strings/Dataresources_Name" /></th>
                        <th><xsl:value-of select="/root/gui/schemas/iso19139.ca.HNAP/strings/Dataresources_Description" /></th>
                        <th><xsl:value-of select="/root/gui/schemas/iso19139.ca.HNAP/strings/Dataresources_Protocol" /></th>
                        <th>&#160;</th>
                      </tr>
                    </thead>
                    <tbody>
                      <xsl:for-each select="gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource">
                        <xsl:sort select="lower-case(gmd:name)" />

                        <xsl:variable name="protocolValue">
                          <xsl:value-of select="normalize-space(gmd:protocol/gco:CharacterString)" />
                        </xsl:variable>
                        <xsl:if test="not(string($webMapServicesProtocols/record[name = lower-case($protocolValue)]))">

                          <xsl:variable name="urlVal" select="normalize-space(gmd:linkage/gmd:URL)" />
                          <xsl:variable name="fileNameStageArea" select="normalize-space(translate(gmd:name, ' ', '_'))" />

                          <xsl:variable name="titleId" select="../@xlink:title" />

                          <tr id="resource_{../@xlink:title}">
                            <!-- Name -->
                            <td>
                              <xsl:variable name="fnameInUrl" select="substring-before(substring-after(gmd:linkage/gmd:URL, 'fname='), '&amp;')" />

                              <xsl:variable name="resourceName">
                                <xsl:for-each select="gmd:name">
                                  <xsl:call-template name="localised">
                                    <xsl:with-param name="langId" select="$langId"/>
                                  </xsl:call-template>
                                </xsl:for-each>
                              </xsl:variable>

                              <a target="_blank" href="{gmd:linkage/gmd:URL}"><xsl:value-of select="$resourceName" /></a>
                            </td>
                            <!-- Description -->
                            <td> <xsl:variable name="resourceDesc">
                              <xsl:for-each select="gmd:description">
                                <xsl:call-template name="localised">
                                  <xsl:with-param name="langId" select="$langId"/>
                                </xsl:call-template>
                              </xsl:for-each>
                            </xsl:variable>
                              <xsl:value-of select="$resourceDesc" /></td>

                            <!-- Protocol -->
                            <td>
                              <xsl:value-of select="gmd:protocol" />
                            </td>
                            <td>

                              <span role="button" class="btn btn-warning btn-xs"
                                    onclick="if (noDoubleClick()) dataDeposit.showEditDataResourceFgp('{../@xlink:title}', '')">
                                <span class="glyphicon glyphicon-pencil"></span></span>&#160;
                              <span role="button" class="btn btn-danger btn-xs"
                                    onclick="if (noDoubleClick()) dataDeposit.removeResourceFgp('{../@xlink:title}', '')" >
                                <span class="glyphicon glyphicon-remove"></span></span>
                            </td>
                          </tr>
                          <xsl:variable name="refOnlineRes" select="../geonet:element/@ref" />
                          <xsl:if test="/root/request/showvalidationerrors = 'true' and count(//svrl:failed-assert[@ref=concat('#_',$refOnlineRes)]) > 0">
                            <tr>
                              <td colspan="4">

                                <div id="valmessage_{../geonet:element/@ref}" class="editor-error">

                                  <xsl:for-each select="//svrl:failed-assert[@ref=concat('#_',$refOnlineRes)]">
                                    <xsl:value-of select="."/><br/>
                                  </xsl:for-each>

                                </div>
                              </td>
                            </tr>
                          </xsl:if>
                        </xsl:if>
                      </xsl:for-each>
                    </tbody>
                  </table>
                </td>
              </tr>
            </xsl:with-param>

            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
            <xsl:with-param name="realname"   select="name(.)"/>
          </xsl:call-template>
        </xsl:for-each>


      </xsl:with-param>
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
      <xsl:with-param name="realname"   select="name(.)"/>
    </xsl:call-template>
  </xsl:template>


  <!-- Languages templates for NAP -->
  <xsl:template mode="iso19139" match="//gmd:languageCode[gmd:LanguageCode/@codeList]" priority="40">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

    <xsl:apply-templates mode="iso19139" select="gmd:LanguageCode">
      <xsl:with-param name="edit" select="$edit"/>
      <xsl:with-param name="schema" select="$schema"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template mode="iso19139" match="//gmd:languageCode/gmd:LanguageCode" priority="30">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

    <xsl:apply-templates mode="simpleElement" select=".">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>

      <xsl:with-param name="text">
        <xsl:call-template name="iso19139GetIsoLanguageAlternativeEC">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
          <xsl:with-param name="value" select="@codeListValue"/>
          <xsl:with-param name="ref" select="concat('_', geonet:element/@ref, '_codeListValue')"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:apply-templates>

  </xsl:template>

  <!-- Languages templates for NAP -->
  <xsl:template mode="iso19139" match="gmd:MD_Metadata/gmd:language[gco:CharacterString]" priority="40">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

    <xsl:apply-templates mode="simpleElement" select=".">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
      <xsl:with-param name="text">
        <xsl:call-template name="iso19139GetIsoLanguageEC">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
          <xsl:with-param name="value" select="gco:CharacterString"/>
          <xsl:with-param name="ref" select="concat('_', gco:CharacterString/geonet:element/@ref)"/>
          <xsl:with-param name="suggestions" select="'n'"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template mode="iso19139" match="//gmd:language[gco:CharacterString]" priority="30">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

    <xsl:apply-templates mode="simpleElement" select=".">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
      <xsl:with-param name="text">
        <xsl:call-template name="iso19139GetIsoLanguageEC">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
          <xsl:with-param name="value" select="gco:CharacterString"/>
          <xsl:with-param name="ref" select="concat('_', gco:CharacterString/geonet:element/@ref)"/>
          <xsl:with-param name="suggestions" select="'y'"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template name="iso19139GetIsoLanguageEC" mode="iso19139GetIsoLanguage" match="*" priority="30">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:param name="value"/>
    <xsl:param name="ref"/>
    <xsl:param name="suggestions">n</xsl:param>
    <xsl:variable name="lang">
      <xsl:call-template name="getLangForMetadata">
        <xsl:with-param name="uiLang" select="/root/gui/language" />
      </xsl:call-template>
    </xsl:variable>


    <xsl:variable name="tooltip">
      <xsl:call-template name="getTooltipTitle-iso19139.ca.HNAP">
        <xsl:with-param name="name"   select="name(.)"/>
        <xsl:with-param name="schema" select="$schema"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$edit=true()">
        <xsl:variable name="mandatory" select="geonet:element/@min='1'"/>

        <xsl:choose>
          <xsl:when test="$suggestions = 'y'">
            <input type="text" class="form-control" size="40" id="{$ref}" name="{$ref}" title="{$tooltip}" value="{$value}">
              <xsl:if test="$mandatory and $edit">
                <xsl:attribute name="onchange">
                  validateNonEmpty(this);
                </xsl:attribute>
              </xsl:if>

              (<xsl:value-of select="/root/gui/strings/helperList"/>
              <select style="height=300px" id="s{$ref}" onchange="jQuery('#{$ref}').val(this.options[this.selectedIndex].value); if (jQuery('#{$ref}').keyup) jQuery('#{$ref}').keyup(); ">
                <option value=""></option>
                <option value="eng"><xsl:value-of select="/root/gui/isolanguages/record[code='eng']/label/*[name() = /root/gui/language]" /></option>
                <option value="fra"><xsl:value-of select="/root/gui/isolanguages/record[code='fra']/label/*[name() = /root/gui/language]" /></option>
                <option value="spa"><xsl:value-of select="/root/gui/isolanguages/record[code='spa']/label/*[name() = /root/gui/language]" /></option>
                <option value="zxx"><xsl:value-of select="/root/gui/isolanguages/record[code='zxx']/label/*[name() = /root/gui/language]" /></option>
                <option disabled="disabled">_________</option>
                <xsl:for-each select="/root/gui/isolanguages/record">
                  <xsl:sort select="label/eng" />
                  <xsl:if test="code != 'eng' and code != 'fra' and code != 'spa' and code != 'zxx'">
                    <option value="{code}"><xsl:value-of select="label/eng" /> (<xsl:value-of select="code" />)</option>
                  </xsl:if>
                </xsl:for-each>
              </select>
              )
            </input>
          </xsl:when>
          <xsl:otherwise>
            <select class="md" name="{$ref}" size="1" title="{$tooltip}">
              <xsl:if test="$mandatory and $edit">
                <xsl:attribute name="onchange">
                  validateNonEmpty(this);
                </xsl:attribute>
              </xsl:if>

              <option name=""/>

              <option value="eng; CAN">
                <xsl:if test="$value = 'eng; CAN'">
                  <xsl:attribute name="selected"/>
                </xsl:if>
                <xsl:value-of select="/root/gui/schemas/iso19139.ca.HNAP/strings/english" />
              </option>

              <option value="fra; CAN">
                <xsl:if test="$value = 'fra; CAN'">
                  <xsl:attribute name="selected"/>
                </xsl:if>
                <xsl:value-of select="/root/gui/schemas/iso19139.ca.HNAP/strings/french" />
              </option>
            </select>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="starts-with($value, 'eng')">
            <xsl:value-of select="/root/gui/isolanguages/record[code='eng']/label/child::*[name() = /root/gui/language]"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="/root/gui/isolanguages/record[code='fra']/label/child::*[name() = /root/gui/language]"/>
          </xsl:otherwise>
        </xsl:choose>



        <!-- In view mode display other languages from gmd:locale of gmd:MD_Metadata element -->
        <xsl:if test="../gmd:locale or ../../gmd:locale">
          <xsl:text> (</xsl:text><xsl:value-of select="string(/root/gui/schemas/iso19139/labels/element[@name='gmd:locale' and not(@context)]/label)"/>
          <xsl:text>:</xsl:text>
          <xsl:for-each select="../gmd:locale|../../gmd:locale">
            <xsl:variable name="c" select="gmd:PT_Locale/gmd:languageCode/gmd:LanguageCode/@codeListValue"/>
            <xsl:value-of select="/root/gui/isolanguages/record[code=$c]/label/child::*[name() = /root/gui/language]"/>
            <xsl:if test="position()!=last()">, </xsl:if>
          </xsl:for-each><xsl:text>)</xsl:text>
        </xsl:if>

      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="iso19139GetIsoLanguageAlternativeEC" mode="iso19139GetIsoLanguage" match="*" priority="30">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:param name="value"/>
    <xsl:param name="ref"/>
    <xsl:variable name="lang"  select="/root/gui/language"/>

    <xsl:variable name="tooltip">
      <xsl:call-template name="getTooltipTitle-iso19139.ca.HNAP">
        <xsl:with-param name="name"   select="name(.)"/>
        <xsl:with-param name="schema" select="$schema"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$edit=true()">
        <xsl:variable name="mandatory" select="geonet:element/@min='1'"/>

        <select class="md" name="{$ref}" size="1" title="{$tooltip}">
          <xsl:if test="$mandatory and $edit">
            <xsl:attribute name="onchange">
              validateNonEmpty(this);
            </xsl:attribute>
          </xsl:if>

          <option name=""/>

          <option value="eng">
            <xsl:if test="$value = 'eng'">
              <xsl:attribute name="selected"/>
            </xsl:if>
            <xsl:value-of select="/root/gui/schemas/iso19139.ca.HNAP/strings/english" />
          </option>

          <option value="fra">
            <xsl:if test="$value = 'fra'">
              <xsl:attribute name="selected"/>
            </xsl:if>
            <xsl:value-of select="/root/gui/schemas/iso19139.ca.HNAP/strings/french" />
          </option>
        </select>
      </xsl:when>


      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="starts-with($value, 'eng')">
            <xsl:value-of select="/root/gui/isolanguages/record[code='eng']/label/child::*[name() = $lang]"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="/root/gui/isolanguages/record[code='fra']/label/child::*[name() = $lang]"/>
          </xsl:otherwise>
        </xsl:choose>



        <!-- In view mode display other languages from gmd:locale of gmd:MD_Metadata element -->
        <xsl:if test="../gmd:locale or ../../gmd:locale">
          <xsl:text> (</xsl:text><xsl:value-of select="string(/root/gui/schemas/iso19139/labels/element[@name='gmd:locale' and not(@context)]/label)"/>
          <xsl:text>:</xsl:text>
          <xsl:for-each select="../gmd:locale|../../gmd:locale">
            <xsl:variable name="c" select="gmd:PT_Locale/gmd:languageCode/gmd:LanguageCode/@codeListValue"/>
            <xsl:value-of select="/root/gui/isolanguages/record[code=$c]/label/child::*[name() = $lang]"/>
            <xsl:if test="position()!=last()">, </xsl:if>
          </xsl:for-each><xsl:text>)</xsl:text>
        </xsl:if>

      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- EC thesaurusName  special management.
         Comment this template to use default management and add gmd:thesaurusName to template with comment: these elements should be boxed
    -->
  <xsl:template mode="iso19139-disabled" match="gmd:thesaurusName/gmd:CI_Citation/gmd:title" priority="10">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

    <xsl:choose>
      <xsl:when test="$edit=true()">
        <xsl:call-template name="simpleElementGui">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>

          <xsl:with-param name="title">
            <xsl:call-template name="getTitle">
              <xsl:with-param name="name"   select="name(../..)"/>
              <xsl:with-param name="schema" select="$schema"/>
            </xsl:call-template>
          </xsl:with-param>

          <xsl:with-param name="text">

            <xsl:variable name="tooltip">
              <xsl:call-template name="getTooltipTitle-iso19139.ca.HNAP">
                <xsl:with-param name="name"   select="name(../..)"/>
                <xsl:with-param name="schema" select="$schema"/>
              </xsl:call-template>
            </xsl:variable>

            <xsl:variable name="ref" select="concat('_', gco:CharacterString/geonet:element/@ref)"/>
            <!--<xsl:variable name="thesaurusId" select="../@id" />-->
            <xsl:variable name="thesaurusId" select="gco:CharacterString" />

            <xsl:variable name="refValue" select="../../../gmd:keyword/gco:CharacterString/geonet:element/@ref"/>

            <select id="{$ref}" name="{$ref}" size="1" class="md" title="{$tooltip}" onchange="updateThesaurusKeywords('_{$refValue}', this.options[this.selectedIndex].value);">
              <option value=""></option>
              <xsl:for-each select="/root/gui/thesaurus/thesauri/thesaurus">
                <option value="{key}">
                  <xsl:if test="key = $thesaurusId">
                    <xsl:attribute name="selected"/>
                  </xsl:if>

                  <xsl:value-of select="title" />
                </option>
              </xsl:for-each>
            </select>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="element" select=".">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="false()"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>



  <!-- ============================================================================= -->
  <!-- protocol -->
  <!-- ============================================================================= -->

  <xsl:template mode="iso19139" match="gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource|
                                        gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource|
                                        gmd:contact/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource|
                                        gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource" priority="20">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

    <xsl:variable name="langId">
      <xsl:call-template name="getLangId">
        <xsl:with-param name="langGui" select="/root/gui/language" />
        <xsl:with-param name="md"
                        select="ancestor-or-self::*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="linkage" select="gmd:linkage/gmd:URL" />
    <xsl:variable name="name">
      <xsl:for-each select="gmd:name">
        <xsl:call-template name="localised">
          <xsl:with-param name="langId" select="$langId"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="description">
      <xsl:for-each select="gmd:description">
        <xsl:call-template name="localised">
          <xsl:with-param name="langId" select="$langId"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$edit=true()">
        <xsl:apply-templates mode="iso19139" select="gmd:linkage/gmd:URL">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>

        <!--<xsl:apply-templates mode="iso19139EditOnlineRes" select=".">
                    <xsl:with-param name="schema" select="$schema"/>
                </xsl:apply-templates>-->
      </xsl:when>
      <xsl:when test="string($linkage)!=''">
        <xsl:apply-templates mode="simpleElement" select=".">
          <xsl:with-param name="schema"  select="$schema"/>
          <xsl:with-param name="text">
            <a href="{$linkage}" target="_new">
              <xsl:choose>
                <xsl:when test="string($description)!=''">
                  <xsl:value-of select="$description"/>
                </xsl:when>
                <xsl:when test="string($name)!=''">
                  <xsl:value-of select="$name"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$linkage"/>
                </xsl:otherwise>
              </xsl:choose>
            </a>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!--	<xsl:choose>
            <xsl:when test="$edit=true()">
                addsdsds<xsl:call-template name="simpleElementGui">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                    <xsl:with-param name="title">
                        <xsl:call-template name="getTitle">
                            <xsl:with-param name="name"   select="name(.)"/>
                            <xsl:with-param name="schema" select="$schema"/>
                        </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="text">
                        <xsl:variable name="value" select="string(gco:CharacterString)"/>
                        <xsl:variable name="ref" select="gco:CharacterString/geonet:element/@ref"/>
                        <xsl:variable name="fref" select="../gmd:name/gco:CharacterString/geonet:element/@ref|../gmd:name/gmx:MimeFileType/geonet:element/@ref"/>
                        <input type="hidden" id="_{$ref}" name="_{$ref}" value="{$value}"/>
                        <select id="s_{$ref}" name="s_{$ref}" size="1" onchange="checkForFileUpload('{$fref}', '{$ref}');" class="md">
                            <xsl:if test="$value=''">
                                <option value=""/>
                            </xsl:if>
                            <xsl:for-each select="/root/gui/strings/protocolChoice[@value]">
                                <option>
                                    <xsl:if test="string(@value)=$value">
                                        <xsl:attribute name="selected"/>
                                    </xsl:if>
                                    <xsl:attribute name="value"><xsl:value-of select="string(@value)"/></xsl:attribute>
                                    <xsl:value-of select="string(.)"/>
                                </option>
                            </xsl:for-each>
                        </select>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="element" select=".">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit"   select="false()"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->

  <!--<xsl:template mode="iso19139" priority="199" match="*[@gco:nilReason='missing']"/>-->

  <!-- Customization for topic category adding validator -->
  <xsl:template mode="iso19139" match="gmd:topicCategory" priority="30">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

    <xsl:variable name="tooltip">
      <xsl:call-template name="getTooltipTitle-iso19139">
        <xsl:with-param name="name"   select="name(.)"/>
        <xsl:with-param name="schema" select="$schema"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:apply-templates mode="simpleElement" select=".">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
      <xsl:with-param name="text">

        <xsl:variable name="value" select="string(gmd:MD_TopicCategoryCode)"/>
        <xsl:variable name="name" select="name(gmd:MD_TopicCategoryCode)"/>

        <xsl:choose>
          <xsl:when test="$edit=true()">
            <xsl:variable name="refm" select="concat('#_', geonet:element/@ref)" />

            <xsl:variable name="mandatory" select="(gmd:MD_TopicCategoryCode/geonet:element/@min='1' and
					gmd:MD_TopicCategoryCode/geonet:element/@max='1') or (//svrl:failed-assert[@ref=$refm])"/>


            <xsl:variable name="list">
              <items>
                <xsl:for-each select="gmd:MD_TopicCategoryCode/geonet:element/geonet:text">
                  <xsl:variable name="choiceValue" select="string(@value)"/>
                  <xsl:variable name="label" select="/root/gui/schemas/*[name(.)=$schema]/codelists/codelist[@name = $name]/entry[code = $choiceValue]/label"/>

                  <item>
                    <value>
                      <xsl:value-of select="@value"/>
                    </value>
                    <label>
                      <xsl:choose>
                        <xsl:when test="$label"><xsl:value-of select="$label"/></xsl:when>
                        <xsl:otherwise><xsl:value-of select="$choiceValue"/></xsl:otherwise>
                      </xsl:choose>
                    </label>
                  </item>
                </xsl:for-each>
              </items>
            </xsl:variable>

            <!--
             <xsl:for-each select="/root/gui/schemas/*[name(.)=$schema]/codelists/codelist[@name='gmd:MD_TopicCategoryCode']/entry">
                                    <item>
                                        <value>
                                            <xsl:value-of select="code"/>
                                        </value>
                                        <label>
                      <xsl:value-of select="label"/>
                                        </label>
                                    </item>
                                </xsl:for-each>-->

            <select class="md" name="_{gmd:MD_TopicCategoryCode/geonet:element/@ref}" size="1">

              <xsl:if test="$mandatory and $edit">
                <xsl:attribute name="onchange">validateNonEmpty(this);</xsl:attribute>
              </xsl:if>
              <option name=""/>
              <xsl:for-each select="exslt:node-set($list)//item">
                <xsl:sort select="label"/>
                <option>
                  <xsl:if test="value=$value">
                    <xsl:attribute name="selected"/>
                  </xsl:if>
                  <xsl:attribute name="value"><xsl:value-of select="value"/></xsl:attribute>
                  <xsl:value-of select="label"/>
                </option>
              </xsl:for-each>
            </select>
          </xsl:when>

          <xsl:otherwise>
            <xsl:variable name="aVal" select="gmd:MD_TopicCategoryCode"/>

            <xsl:value-of select="/root/gui/schemas/*[name(.)=$schema]/codelists/codelist[@name = $name]/entry[code = $value]/label" />
          </xsl:otherwise>
        </xsl:choose>

      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>


  <xsl:template mode="iso19139" match="gmd:descriptiveKeywords" priority="130">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

    <xsl:choose>
      <!-- Simple view -->
      <xsl:when test="/root/gui/config/metadata-tab/*[name(.)=$currTab]/@flat">

        <xsl:choose>
          <xsl:when test="(
                normalize-space(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Government of Canada Core Subject Thesaurus' or
                normalize-space(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Thésaurus des sujets de base du gouvernement du Canada')">

            <xsl:apply-templates mode="elementEP" select="gmd:MD_Keywords">
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="edit"   select="$edit"/>
            </xsl:apply-templates>

          </xsl:when>

          <xsl:when test="((gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Waf'))">

          </xsl:when>

          <xsl:otherwise>
            <xsl:apply-templates mode="complexElement" select=".">
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="edit"   select="$edit"/>
            </xsl:apply-templates>

            <xsl:if test="/root/request/showvalidationerrors = 'true'">
              <xsl:variable name="refDescriptiveKeywords" select="geonet:element/@ref" />
              <tr><td colspan="2">
                <div id="valmessage_{$refDescriptiveKeywords}" class="editor-error">
                  <xsl:if test="count(//svrl:failed-assert[@ref=concat('#_',$refDescriptiveKeywords)]) = 0"><xsl:attribute name="style">display:none</xsl:attribute></xsl:if>

                  <xsl:for-each select="//svrl:failed-assert[@ref=concat('#_',$refDescriptiveKeywords)]">
                    <xsl:value-of select="."/><br/>
                  </xsl:for-each>
                </div>
              </td> </tr>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>

      </xsl:when>
      <!-- Advanced view -->
      <xsl:otherwise>
        <xsl:apply-templates mode="complexElement" select=".">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>


  <xsl:template mode="iso19139" match="gmd:MD_Keywords" priority="130">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

    <xsl:choose>
      <!-- Simple view -->
      <xsl:when test="/root/gui/config/metadata-tab/*[name(.)=$currTab]/@flat">
        <xsl:for-each select="gmd:keyword">

          <xsl:choose>
            <!--<xsl:when test="((../gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Waf') or
                              (gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'Government of Canada Core Subject Thesaurus' or
                              gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'Thésaurus des sujets de base du gouvernement du Canada'))">

            </xsl:when>-->

            <xsl:when test="((../gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Waf'))">

            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates mode="elementEP" select=".">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>

              <!--<xsl:apply-templates mode="complexElement" select="../gmd:thesaurusName">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit"   select="$edit"/>
              </xsl:apply-templates>-->

            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>

        <xsl:choose>

          <xsl:when test="(
              gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Waf' or
              normalize-space(gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Government of Canada Core Subject Thesaurus' or
              normalize-space(gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Thésaurus des sujets de base du gouvernement du Canada')">

          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="elementEP" select="gmd:type">
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="edit"   select="$edit"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>

      </xsl:when>

      <!-- Advanced view -->
      <xsl:otherwise>
        <xsl:apply-templates mode="elementEP" select="*">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- Box gmd:onLine to allow add/remove -->
  <xsl:template mode="iso19139" match="gmd:onLine/@xlink:title" />
  <xsl:template mode="iso19139" match="gmd:onLine/@xlink:role" />
  <!--<xsl:template mode="iso19139" match="gmd:onLine" priority="130">
            <xsl:param name="schema"/>
            <xsl:param name="edit"/>

             <xsl:apply-templates mode="complexElement" select=".">
                                <xsl:with-param name="schema" select="$schema"/>
                                <xsl:with-param name="edit"   select="$edit"/>
                            </xsl:apply-templates>
    </xsl:template>-->

  <!-- Avoid box for gmd:onLine/gmd:CI_OnlineResource, TODO: Check -->
  <!--<xsl:template mode="iso19139" match="gmd:onLine/gmd:CI_OnlineResource" priority="130">
          <xsl:param name="schema"/>
          <xsl:param name="edit"/>

           <xsl:apply-templates mode="iso19139" select="*">
                              <xsl:with-param name="schema" select="$schema"/>
                              <xsl:with-param name="edit"   select="$edit"/>
                          </xsl:apply-templates>
  </xsl:template>-->



  <xsl:template mode="iso19139" match="@geonet:addedObj" priority="2" />

  <!-- EC: Don't add the online resources to the editor form. Online resources are managed in custom services -->
  <xsl:template mode="iso19139" match="gmd:CI_OnlineResource[name(../..) = 'gmd:MD_DigitalTransferOptions']" priority="20" />


  <xsl:template mode="iso19139" match="gmd:CI_OnlineResource[starts-with(gmd:protocol/gco:CharacterString,'OGC:WMS-') and contains(gmd:protocol/gco:CharacterString,'-get-map') and gmd:name]|gmd:CI_OnlineResource[gmd:protocol/gco:CharacterString = 'OGC:WMS' and string(gmd:name/gco:CharacterString)]" priority="2">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:variable name="metadata_id" select="/root/*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/geonet:info/id" />
    <xsl:variable name="linkage" select="gmd:linkage/gmd:URL" />
    <xsl:variable name="name" select="normalize-space(gmd:name/gco:CharacterString|gmd:name/gmx:MimeFileType)" />
    <xsl:variable name="description" select="normalize-space(gmd:description/gco:CharacterString)" />

    <xsl:choose>
      <xsl:when test="$edit=true()">
        <!--<xsl:apply-templates mode="iso19139EditOnlineRes" select=".">
            <xsl:with-param name="schema" select="$schema"/>
        </xsl:apply-templates>-->
      </xsl:when>
      <!-- Resource name is specified -->
      <xsl:when test="/root/*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/geonet:info[dynamic='true'] and string($linkage)!=''">
        <img class="icon" src="{/root/gui/url}/images/connect.png" title="WMS service" />
        <xsl:choose>
          <xsl:when test="string($description)!=''">
            <xsl:value-of select="$description"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="/root/gui/strings/wmslayers"/>
          </xsl:otherwise>
        </xsl:choose><div style="float:right">
        <button class="btn btn-default">
          <xsl:attribute name="onclick">Ext.Msg.alert('<xsl:value-of select="/root/gui/strings/WMSdetails"/>','url: <xsl:value-of select="$linkage"/><xsl:if test="string($name)!=''">\n <xsl:value-of select="/root/gui/strings/Layer"/>: <xsl:value-of select="$name"/></xsl:if>');</xsl:attribute>
          <xsl:value-of select="/root/gui/strings/details"/>
        </button>
        <button class="btn btn-default"><xsl:attribute name="onclick">
          <xsl:choose><xsl:when test="string($name)!=''">
            location.href="<xsl:value-of select="/root/gui/url"/>/srv/eng/rest.map?newLayer=[['<xsl:value-of select="$name"/>','<xsl:value-of select="$linkage"/>','<xsl:value-of select="$name"/>','<xsl:value-of select="$metadata_id"/>']]"
          </xsl:when>
            <xsl:otherwise>  <!-- todo -->
              Ext.Msg.alert('Not implemented','go to map page and open wms server')
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
          <xsl:value-of select="/root/gui/strings/wmslayers"/>
        </button></div>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="iso19139" match="gmd:CI_OnlineResource[starts-with(gmd:protocol/gco:CharacterString,'WWW:DOWNLOAD-') and contains(gmd:protocol/gco:CharacterString,'http--download') and gmd:name]" priority="2">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:variable name="download_check"><xsl:text>&amp;fname=&amp;access</xsl:text></xsl:variable>
    <xsl:variable name="linkage" select="gmd:linkage/gmd:URL" />
    <xsl:variable name="name" select="normalize-space(gmd:name/gco:CharacterString|gmd:name/gmx:MimeFileType)" />
    <xsl:variable name="description" select="normalize-space(gmd:description/gco:CharacterString)" />

    <xsl:choose>
      <xsl:when test="$edit=true()">
        <!--<xsl:apply-templates mode="iso19139EditOnlineRes" select=".">
            <xsl:with-param name="schema" select="$schema"/>
        </xsl:apply-templates>-->

      </xsl:when>
      <xsl:when test="string(ancestor::*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/geonet:info/download)='true' and string($linkage)!='' and not(contains($linkage,$download_check))">
        <img class="icon" src="{/root/gui/url}/images/database.png" title="Dataset" />

        <xsl:choose>
          <xsl:when test="string($name)!=''">
            <xsl:value-of select="$name"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$description"/>
          </xsl:otherwise>
        </xsl:choose>

        <div style="float:right">
          <button class="btn btn-default" onclick="new Ext.Window({{title:'Download details',html:Ext.get('win{position()}').dom.innerHTML,width:400,height:300}}).show();">
            <xsl:value-of select="/root/gui/strings/details"/>
          </button>
          <a class="btn btn-default" href='{$linkage}' target="_blank">
            <xsl:value-of select="/root/gui/strings/downloadData"/>
          </a>
        </div>

      </xsl:when>
      <xsl:otherwise>

      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Online resource description -->
  <xsl:template mode="iso19139" match="gmd:description[name(..)='gmd:CI_OnlineResource' and name(../..) != 'srv:connectPoint']" priority="10">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
  </xsl:template>

  <xsl:template mode="iso19139_DISABLED" match="gmd:description[name(..)='gmd:CI_OnlineResource']" priority="10">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:choose>
      <xsl:when test="$edit=true()">
        <xsl:variable name="ref" select="gco:CharacterString/geonet:element/@ref"/>
        <xsl:variable name="value" select="gco:CharacterString"/>-

        <xsl:variable name="resourceId" select="../../@xlink:title" />
        <xsl:variable name="refFrench" select="../../../gmd:onLine[@xlink:title = $resourceId and @xlink:role='urn:xml:lang:fra-CAN']/gmd:CI_OnlineResource/gmd:description/gco:CharacterString/geonet:element/@ref"/>
        <xsl:variable name="valueFrench" select="../../../gmd:onLine[@xlink:title = $resourceId and @xlink:role='urn:xml:lang:fra-CAN']/gmd:CI_OnlineResource/gmd:description/gco:CharacterString"/>

        <input type="hidden" id="_{$ref}" name="_{$ref}" value="{$value}" role="rdesc" />
        <input type="hidden" id="_{$refFrench}" name="_{$refFrench}" value="{$valueFrench}" role="rdesc" />

      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="element" select=".">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="false()"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- Online resource protocol -->
  <xsl:template mode="iso19139" match="gmd:protocol[name(..)='gmd:CI_OnlineResource' and name(../..) != 'srv:connectPoint']" priority="10">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
  </xsl:template>

  <xsl:template mode="iso19139_DISABLED" match="gmd:protocol[name(..)='gmd:CI_OnlineResource']" priority="10">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:choose>
      <xsl:when test="$edit=true()">
        <xsl:variable name="value" select="string(gco:CharacterString)"/>

        <xsl:variable name="ref" select="gco:CharacterString/geonet:element/@ref"/>
        <xsl:variable name="fref" select="../gmd:name/gco:CharacterString/geonet:element/@ref|../gmd:name/gmx:MimeFileType/geonet:element/@ref"/>

        <xsl:variable name="resourceId" select="../../@xlink:title" />
        <xsl:variable name="refFrench" select="../../../gmd:onLine[@xlink:title = $resourceId and @xlink:role='urn:xml:lang:fra-CAN']/gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString/geonet:element/@ref"/>

        <xsl:variable name="frefFrench" select="../../../gmd:onLine[@xlink:title = $resourceId and @xlink:role='urn:xml:lang:fra-CAN']/gmd:CI_OnlineResource/gmd:name/gco:CharacterString/geonet:element/@ref|../../../gmd:onLine[@xlink:title = $resourceId and @xlink:role='urn:xml:lang:fra-CAN']/gmd:CI_OnlineResource/gmd:name/gmx:MimeFileType/geonet:element/@ref"/>

        <input type="hidden" id="_{$ref}" name="_{$ref}" value="{$value}" />
        <input type="hidden" id="_{$refFrench}" name="_{$refFrench}" value="{$value}" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="element" select=".">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="false()"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="iso19139_DISABLED" match="gmd:protocol[name(..)='gmd:CI_OnlineResource']" priority="2">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

    <xsl:choose>
      <xsl:when test="$edit=true()">
        <xsl:call-template name="simpleElementGui">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>

          <xsl:with-param name="title">
            <xsl:call-template name="getTitle">
              <xsl:with-param name="name"   select="name(.)"/>
              <xsl:with-param name="schema" select="$schema"/>
            </xsl:call-template>
          </xsl:with-param>

          <xsl:with-param name="tooltip">
            <xsl:call-template name="getTooltipTitle">
              <xsl:with-param name="name"   select="name(.)"/>
              <xsl:with-param name="schema" select="$schema"/>
            </xsl:call-template>
          </xsl:with-param>

          <xsl:with-param name="text">
            <xsl:variable name="value" select="string(gco:CharacterString)"/>

            <xsl:variable name="ref" select="gco:CharacterString/geonet:element/@ref"/>
            <xsl:variable name="fref" select="../gmd:name/gco:CharacterString/geonet:element/@ref|../gmd:name/gmx:MimeFileType/geonet:element/@ref"/>

            <xsl:variable name="resourceId" select="../../@xlink:title" />
            <xsl:variable name="refFrench" select="../../../gmd:onLine[@xlink:title = $resourceId and @xlink:role='urn:xml:lang:fra-CAN']/gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString/geonet:element/@ref"/>

            <xsl:variable name="frefFrench" select="../../../gmd:onLine[@xlink:title = $resourceId and @xlink:role='urn:xml:lang:fra-CAN']/gmd:CI_OnlineResource/gmd:name/gco:CharacterString/geonet:element/@ref|../../../gmd:onLine[@xlink:title = $resourceId and @xlink:role='urn:xml:lang:fra-CAN']/gmd:CI_OnlineResource/gmd:name/gmx:MimeFileType/geonet:element/@ref"/>

            <input type="hidden" id="_{$ref}" name="_{$ref}" value="{$value}"/>

            <xsl:choose>
              <xsl:when test="string(../gmd:protocol/gco:CharacterString)='WWW:DOWNLOAD-1.0-http--download' and string(../gmd:name/gco:CharacterString|../gmd:name/gmx:MimeFileType)!=''">
                <xsl:value-of select="/root/gui/strings/protocolChoice[@value = $value]" />
              </xsl:when>
              <xsl:otherwise>
                <select id="s_{$ref}" name="s_{$ref}" size="1" onchange="checkForFileUploadEC('{$fref}', '{$frefFrench}', '{$ref}', '{$refFrench}');" class="md">
                  <xsl:if test="$value=''">
                    <option value=""/>
                  </xsl:if>
                  <xsl:for-each select="/root/gui/strings/protocolChoice[@value]">
                    <option>
                      <xsl:if test="string(@value)=$value">
                        <xsl:attribute name="selected"/>
                      </xsl:if>
                      <xsl:attribute name="value"><xsl:value-of select="string(@value)"/></xsl:attribute>
                      <xsl:value-of select="string(.)"/>
                    </option>
                  </xsl:for-each>
                </select>
              </xsl:otherwise>
            </xsl:choose>




            <input type="hidden" id="_{$refFrench}" name="_{$refFrench}" value="{$value}"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="element" select=".">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="false()"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- Online resource URL -->
  <xsl:template mode="iso19139" match="gmd:linkage[name(..)='gmd:CI_OnlineResource' and name(../..) != 'srv:connectPoint']" priority="10">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
  </xsl:template>

  <xsl:template mode="iso19139_DISABLED" match="gmd:linkage[name(..)='gmd:CI_OnlineResource']" priority="30">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:choose>
      <xsl:when test="$edit=true()">
        <xsl:variable name="ref" select="gmd:URL/geonet:element/@ref"/>
        <xsl:variable name="value" select="gmd:URL"/>

        <xsl:variable name="resourceId" select="../../@xlink:title" />
        <xsl:variable name="refFrench" select="../../../gmd:onLine[@xlink:title = $resourceId and @xlink:role='urn:xml:lang:fra-CAN']/gmd:CI_OnlineResource/gmd:linkage/gmd:URL/geonet:element/@ref"/>        <xsl:variable name="refFrench" select="../../../gmd:onLine[@xlink:title = $resourceId and @xlink:role='urn:xml:lang:fra-CAN']/gmd:CI_OnlineResource/gmd:linkage/gmd:URL/geonet:element/@ref"/>
        <xsl:variable name="valueFrench" select="../../../gmd:onLine[@xlink:title = $resourceId and @xlink:role='urn:xml:lang:fra-CAN']//gmd:CI_OnlineResource/gmd:linkage/gmd:URL"/>

        <input type="hidden" id="_{$ref}" name="_{$ref}" value="{$value}" />
        <input type="hidden" id="_{$refFrench}" name="_{$refFrench}" value="{$valueFrench}" />

      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="element" select=".">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="false()"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Online resource name -->
  <xsl:template mode="iso19139" match="gmd:name[name(..)='gmd:CI_OnlineResource' and name(../..) != 'srv:connectPoint']" priority="10">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
  </xsl:template>

  <xsl:template mode="iso19139_DISABLED" match="gmd:name[name(..)='gmd:CI_OnlineResource']" priority="10">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:choose>
      <xsl:when test="$edit=true()">
        <xsl:variable name="ref" select="gco:CharacterString/geonet:element/@ref|gmx:MimeFileType/geonet:element/@ref"/>
        <xsl:variable name="value" select="gco:CharacterString|gmx:MimeFileType"/>

        <xsl:variable name="resourceId" select="../../@xlink:title" />
        <xsl:variable name="refFrench" select="../../../gmd:onLine[@xlink:title = $resourceId and @xlink:role='urn:xml:lang:fra-CAN']/gmd:CI_OnlineResource/gmd:name/gco:CharacterString/geonet:element/@ref|../../../gmd:onLine[@xlink:title = $resourceId and @xlink:role='urn:xml:lang:fra-CAN']/gmd:CI_OnlineResource/gmd:name/gmx:MimeFileType/geonet:element/@ref"/>
        <xsl:variable name="valueFrench" select="../../../gmd:onLine[@xlink:title = $resourceId and @xlink:role='urn:xml:lang:fra-CAN']//gmd:CI_OnlineResource/gmd:name/gco:CharacterString|../../../gmd:onLine[@xlink:title = $resourceId and @xlink:role='urn:xml:lang:fra-CAN']/gmd:CI_OnlineResource/gmd:name/gmx:MimeFileType"/>

        <input type="hidden" id="_{$ref}" name="_{$ref}" value="{$value}" />
        <input type="hidden" id="_{$refFrench}" name="_{$refFrench}" value="{$valueFrench}" />

      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="element" select=".">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="false()"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="iso19139EditOnlineRes" match="*">
    <xsl:param name="schema"/>
    <xsl:variable name="id" select="generate-id(.)"/>
    <xsl:variable name="idPanel" select="geonet:element/@uuid"/>
    <tr><td colspan="2"><div id="{$id}"/></td></tr>

    <xsl:apply-templates mode="complexElement" select=".">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="true()"/>


      <xsl:with-param name="content">

        <!--<xsl:value-of select="name()" />-->
        <span id="buttons_{$id}">

          <xsl:variable name="onlineCounter" select="count(../preceding-sibling::gmd:onLine[@xlink:role='urn:xml:lang:eng-CAN'])" />
          <xsl:variable name="removeLink"   select="concat('doRemoveElementAction(',$apos,'/metadata.elem.delete',$apos,',',geonet:element/@ref,',',geonet:element/@parent,',',$apos,'',$idPanel,$apos,',',geonet:element/@min,',',$apos, 'infcategory' ,$apos, ');')"/>

          <xsl:variable name="addLink">
            <xsl:value-of select="concat('addDatasetOnlineResource(',$apos,../geonet:element/@parent,$apos,',',$apos,name(..),$apos,',',$apos,'buttons_',$id,$apos,');')"/>
          </xsl:variable>

          <!-- Add button -->
          &#160;<a id="add_{$id}" style="cursor:hand;cursor:pointer;" onclick="if (noDoubleClick()) {$addLink}" target="_blank">
          <xsl:if test="position() != last()">
            <xsl:attribute name="style">display:none;</xsl:attribute>
          </xsl:if>
          <img src="{/root/gui/url}/images/plus.gif" alt="{/root/gui/strings/add}" class="icon" title="{/root/gui/strings/add}"/></a>
          &#160;<a id="remove_{$id}"  style="cursor:hand;cursor:pointer;" onclick="if (noDoubleClick()) {$removeLink}" target="_blank">
          <xsl:if test="$onlineCounter &lt; 1">
            <xsl:attribute name="style">display:none;</xsl:attribute>
          </xsl:if>

          <img src="{/root/gui/url}/images/del.gif" class="icon" alt="{/root/gui/strings/del}" title="{/root/gui/strings/del}"/>
        </a>

        </span><br/>
        <xsl:apply-templates mode="elementEP" select="gmd:applicationProfile|geonet:child[string(@name)='applicationProfile']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="true()"/>
        </xsl:apply-templates>

        <xsl:choose>
          <xsl:when test="string(gmd:protocol/gco:CharacterString)='WWW:DOWNLOAD-1.0-http--download' and string(gmd:name/gco:CharacterString|gmd:name/gmx:MimeFileType)!=''">
            <xsl:apply-templates mode="iso19139FileRemove" select="gmd:name/gco:CharacterString|gmd:name/gmx:MimeFileType">
              <xsl:with-param name="access" select="'private'"/>
              <xsl:with-param name="id" select="$id"/>
            </xsl:apply-templates>

            <xsl:apply-templates mode="elementEP" select="geonet:child[string(@name)='name']">
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="edit"   select="true()"/>
            </xsl:apply-templates>

            <xsl:apply-templates mode="iso19139" select="gmd:name">
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="edit"   select="true()"/>
            </xsl:apply-templates>

          </xsl:when>
          <xsl:when test="string(gmd:protocol/gco:CharacterString)='DB:POSTGIS'
				    and string(gmd:name/gco:CharacterString|gmd:name/gmx:MimeFileType)!=''">
            <xsl:apply-templates mode="iso19139GeoPublisher" select="gmd:name/gco:CharacterString|gmd:name/gmx:MimeFileType">
              <xsl:with-param name="access" select="'private'"/>
              <xsl:with-param name="id" select="$id"/>
            </xsl:apply-templates>

          </xsl:when>

          <xsl:otherwise>
            <!-- use elementEP for geonet:child only -->
            <xsl:apply-templates mode="elementEP" select="gmd:name|geonet:child[string(@name)='name']">
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="edit"   select="true()"/>
            </xsl:apply-templates>

          </xsl:otherwise>
        </xsl:choose>

        <xsl:apply-templates mode="elementEP" select="gmd:linkage|geonet:child[string(@name)='linkage']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="true()"/>
        </xsl:apply-templates>
        <!-- use elementEP for geonet:child only -->

        <!--<xsl:apply-templates mode="elementEP" select="">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="true()"/>
        </xsl:apply-templates>-->

        <xsl:apply-templates mode="iso19139" select="gmd:protocol|geonet:child[string(@name)='protocol']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="true()"/>
        </xsl:apply-templates>


        <xsl:apply-templates mode="elementEP" select="gmd:description|geonet:child[string(@name)='description']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="true()"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="elementEP" select="gmd:function|geonet:child[string(@name)='function']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="true()"/>
        </xsl:apply-templates>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template mode="iso19139FileRemove" match="*">
    <xsl:param name="access" select="'public'"/>
    <xsl:param name="id"/>

    <xsl:variable name="ref" select="geonet:element/@ref"/>

    <xsl:variable name="code" select="../../../@xlink:title"/>
    <xsl:variable name="ref2" select="../../../../gmd:onLine[@xlink:role='urn:xml:lang:fra-CAN' and @xlink:title=$code]/gmd:CI_OnlineResource/gmd:name/*/geonet:element/@ref"/>

    <xsl:variable name="urlRef" select="../../gmd:linkage/gmd:URL/geonet:element/@ref"/>
    <xsl:variable name="urlRef2" select="../../../../gmd:onLine[@xlink:role='urn:xml:lang:fra-CAN' and @xlink:title=$code]/gmd:CI_OnlineResource/gmd:linkage/gmd:URL/geonet:element/@ref"/>

    <button class="btn btn-default" onclick="javascript:doFileRemoveAction('{/root/gui/locService}/resources.del','{$ref}:;:{$ref2}:;:{$urlRef}:;:{$urlRef2}','{$access}','{$id}')"><xsl:value-of select="/root/gui/strings/remove"/></button>
    <xsl:call-template name="iso19139GeoPublisherButton">
      <xsl:with-param name="access" select="$access"></xsl:with-param>
    </xsl:call-template>

    <!-- <xsl:call-template name="simpleElementGui">
         <xsl:with-param name="title" select="/root/gui/strings/file"/>
         <xsl:with-param name="text">
             <table width="100%"><tr>
                 <xsl:variable name="ref" select="geonet:element/@ref"/>
                 <td width="70%"><xsl:value-of select="string(.)"/></td>
                 <td align="right">
                     <button class="content" onclick="javascript:doFileRemoveAction('{/root/gui/locService}/resources.del','{$ref}','{$access}','{$id}')"><xsl:value-of select="/root/gui/strings/remove"/></button>
                     <xsl:call-template name="iso19139GeoPublisherButton">
                         <xsl:with-param name="access" select="$access"></xsl:with-param>
                     </xsl:call-template>
                 </td>
             </tr></table>
         </xsl:with-param>
         <xsl:with-param name="schema"/>
     </xsl:call-template> -->

  </xsl:template>

  <!-- List of regions to define country.
  gmd:country is not a codelist (only country in PT_Local is).
  A list of existing countries in Regions table is suggested to the editor.
  The input text could also be used to type another value.
  -->
  <xsl:template mode="iso19139" match="gmd:country[gco:CharacterString]" priority="1">
    <xsl:param name="schema" />
    <xsl:param name="edit" />

    <xsl:variable name="l">
      <xsl:call-template name="getLangForMetadata">
        <xsl:with-param name="uiLang" select="/root/gui/language" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="value">
      <xsl:call-template name="localised">
        <xsl:with-param name="langId" select="$l" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="tooltip">
      <xsl:call-template name="getTooltipTitle-iso19139">
        <xsl:with-param name="name"   select="name(.)"/>
        <xsl:with-param name="schema" select="$schema"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:apply-templates mode="simpleElement" select=".">
      <xsl:with-param name="schema" select="$schema" />
      <xsl:with-param name="edit" select="$edit" />
      <xsl:with-param name="tooltip" select="$tooltip"/>

      <xsl:with-param name="text">
        <xsl:variable name="mainLang">
          <xsl:call-template name="getMainLangFromMetadata">
             <xsl:with-param name="md" select="/root/*"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="countryVal">
          <xsl:call-template name="localised">
            <xsl:with-param name="langId" select="$mainLang" />
          </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="otherLang">
          <xsl:choose>
            <xsl:when test="$mainLang = 'eng'">fra</xsl:when>
            <xsl:otherwise>eng</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="countryValOther">
          <xsl:call-template name="localised">
            <xsl:with-param name="langId" select="$otherLang" />
          </xsl:call-template>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="$edit=true()">
            <xsl:variable name="ref" select="gco:CharacterString/geonet:element/@ref"/>

            <xsl:variable name="tmpFreeText">
              <xsl:call-template name="PT_FreeText_Tree" />
            </xsl:variable>

            <xsl:variable name="ptFreeTextTree" select="exslt:node-set($tmpFreeText)" />


            <xsl:variable name="mainLangId">
              <xsl:call-template name="getLangIdFromMetadata">
                <xsl:with-param name="lang" select="$mainLang" />
                <xsl:with-param name="md"
                                select="ancestor-or-self::*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']" />
              </xsl:call-template>
            </xsl:variable>

            <xsl:variable name="relElemId">
              <xsl:if test="gco:CharacterString"><xsl:value-of select="gco:CharacterString/geonet:element/@ref" /> </xsl:if>
            </xsl:variable>

            <xsl:variable name="mainLanguageRef">
              <xsl:choose>
                <xsl:when test="gco:CharacterString/geonet:element/@ref" >
                  <xsl:value-of select="concat('_', gco:CharacterString/geonet:element/@ref)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat('_',
                                      gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=$mainLangId]/geonet:element/@ref)"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>


            <xsl:variable name="other-ref" select="$ptFreeTextTree//gmd:LocalisedCharacterString/geonet:element/@ref"/>
            <input type="hidden" class="form-control" name="_{$ref}" value="{$countryVal}" />
            <input type="hidden" class="form-control" name="_{$other-ref}" id="_{$other-ref}"  value="{$countryValOther}" />

            <button type="button" class="btn btn-default btn-md fa fa-edit " onclick="countrySelectionPanel.showPanelEdit({$ref}, '{$other-ref}', jQuery('#true_{$ref}').val(), jQuery('#true_{$other-ref}').val(), '{$mainLang}')"></button>
            &#160;<span class="small"><xsl:copy-of select="/root/gui/strings/countries_vocabulary" /></span>
            <div role="tabpanel">

              <div class="wb-tabs lang-tabs">
                <div class="tabpanels">
                  <xsl:choose>
                    <xsl:when test="gco:*">
                      <xsl:choose>
                        <xsl:when test="/root/gui/language = 'fre'">
                          <xsl:choose>
                            <xsl:when test="$mainLangId='#fra'">
                              <xsl:for-each select="gco:CharacterString">
                                <xsl:call-template name="tbLangTab">
                                  <xsl:with-param name="id" select="geonet:element/@ref" />
                                  <xsl:with-param name="label" select="/root/gui/strings/french" />
                                  <xsl:with-param name="lang" select="'fre'" />
                                  <xsl:with-param name="rows" select="'1'" />
                                  <xsl:with-param name="schema" select="$schema" />
                                  <xsl:with-param name="edit" select="$edit" />
                                  <xsl:with-param name="readonly" select="'true'" />
                                </xsl:call-template>
                              </xsl:for-each>
                              <xsl:for-each select="$ptFreeTextTree//gmd:LocalisedCharacterString[@locale!=$mainLangId]">
                                <xsl:call-template name="tbLangTab">
                                  <xsl:with-param name="id" select="geonet:element/@ref" />
                                  <xsl:with-param name="label" select="@language" />
                                  <xsl:with-param name="lang" select="replace(@locale, '#', '')" />
                                  <xsl:with-param name="rows" select="'1'" />
                                  <xsl:with-param name="schema" select="$schema" />
                                  <xsl:with-param name="edit" select="$edit" />
                                  <xsl:with-param name="relElemId" select="$relElemId" />
                                  <xsl:with-param name="readonly" select="'true'" />
                                </xsl:call-template>
                              </xsl:for-each>
                            </xsl:when>

                            <xsl:when test="$mainLangId!='#fra'">

                              <xsl:for-each select="$ptFreeTextTree//gmd:LocalisedCharacterString[@locale!=$mainLangId]">
                                <xsl:call-template name="tbLangTab">
                                  <xsl:with-param name="id" select="geonet:element/@ref" />
                                  <xsl:with-param name="label" select="@language" />
                                  <xsl:with-param name="lang" select="replace(@locale, '#', '')" />
                                  <xsl:with-param name="rows" select="'1'" />
                                  <xsl:with-param name="schema" select="$schema" />
                                  <xsl:with-param name="edit" select="$edit" />
                                  <xsl:with-param name="relElemId" select="$relElemId" />
                                  <xsl:with-param name="readonly" select="'true'" />
                                </xsl:call-template>
                              </xsl:for-each>
                              <xsl:for-each select="gco:CharacterString">
                                <xsl:call-template name="tbLangTab">
                                  <xsl:with-param name="id" select="geonet:element/@ref" />
                                  <xsl:with-param name="label" select="/root/gui/strings/english" />
                                  <xsl:with-param name="lang" select="'eng'" />
                                  <xsl:with-param name="rows" select="'1'" />
                                  <xsl:with-param name="schema" select="$schema" />
                                  <xsl:with-param name="edit" select="$edit" />
                                  <xsl:with-param name="readonly" select="'true'" />
                                </xsl:call-template>
                              </xsl:for-each>
                            </xsl:when>
                          </xsl:choose>
                        </xsl:when>
                        <xsl:when test="/root/gui/language = 'eng'">
                          <!--<xsl:value-of select="gco:*/geonet:element"/>-->
                          <xsl:choose>
                            <xsl:when test="$mainLangId='#eng'">

                              <xsl:for-each select="gco:CharacterString">
                                <xsl:call-template name="tbLangTab">
                                  <xsl:with-param name="id" select="geonet:element/@ref" />
                                  <xsl:with-param name="label" select="/root/gui/strings/english" />
                                  <xsl:with-param name="lang" select="eng" />
                                  <xsl:with-param name="rows" select="'1'" />
                                  <xsl:with-param name="schema" select="$schema" />
                                  <xsl:with-param name="edit" select="$edit" />
                                  <xsl:with-param name="readonly" select="'true'" />
                                </xsl:call-template>
                              </xsl:for-each>
                              <xsl:for-each select="$ptFreeTextTree//gmd:LocalisedCharacterString[@locale!=$mainLangId]">
                                <xsl:call-template name="tbLangTab">
                                  <xsl:with-param name="id" select="geonet:element/@ref" />
                                  <xsl:with-param name="label" select="@language" />
                                  <xsl:with-param name="lang" select="replace(@locale, '#', '')" />
                                  <xsl:with-param name="rows" select="'1'" />
                                  <xsl:with-param name="schema" select="$schema" />
                                  <xsl:with-param name="edit" select="$edit" />
                                  <xsl:with-param name="relElemId" select="$relElemId" />
                                  <xsl:with-param name="readonly" select="'true'" />
                                </xsl:call-template>
                              </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="$mainLangId!='#eng'">
                              <xsl:for-each select="$ptFreeTextTree//gmd:LocalisedCharacterString[@locale!=$mainLangId]">
                                <xsl:call-template name="tbLangTab">
                                  <xsl:with-param name="id" select="geonet:element/@ref" />
                                  <xsl:with-param name="label" select="@language" />
                                  <xsl:with-param name="lang" select="replace(@locale, '#', '')" />
                                  <xsl:with-param name="rows" select="'1'" />
                                  <xsl:with-param name="schema" select="$schema" />
                                  <xsl:with-param name="edit" select="$edit" />
                                  <xsl:with-param name="relElemId" select="$relElemId" />
                                  <xsl:with-param name="readonly" select="'true'" />
                                </xsl:call-template>
                              </xsl:for-each>
                              <xsl:for-each select="gco:CharacterString">
                                <xsl:call-template name="tbLangTab">
                                  <xsl:with-param name="id" select="gco:*/geonet:element/@ref" />
                                  <xsl:with-param name="label" select="/root/gui/strings/french" />
                                  <xsl:with-param name="lang" select="'fre'" />
                                  <xsl:with-param name="rows" select="'1'" />
                                  <xsl:with-param name="schema" select="$schema" />
                                  <xsl:with-param name="edit" select="$edit" />
                                  <xsl:with-param name="readonly" select="'true'" />
                                </xsl:call-template>
                              </xsl:for-each>
                            </xsl:when>
                          </xsl:choose>
                        </xsl:when>
                      </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:for-each select="$ptFreeTextTree//gmd:LocalisedCharacterString">
                        <xsl:call-template name="tbLangTab">
                          <xsl:with-param name="id" select="geonet:element/@ref" />
                          <xsl:with-param name="label" select="@language" />
                          <xsl:with-param name="lang" select="replace(@locale, '#', '')" />
                          <xsl:with-param name="rows" select="'1'" />
                          <xsl:with-param name="schema" select="$schema" />
                          <xsl:with-param name="edit" select="$edit" />
                          <xsl:with-param name="relElemId" select="$relElemId" />
                          <xsl:with-param name="readonly" select="'true'" />

                        </xsl:call-template>
                      </xsl:for-each>
                    </xsl:otherwise>
                  </xsl:choose>


                </div>
              </div>

            </div>

          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of
              select="$value" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>


  <xsl:template mode="iso19139" match="gmd:administrativeArea[gco:CharacterString]" priority="20">
    <xsl:param name="schema" />
    <xsl:param name="edit" />

    <xsl:variable name="qname" select="name(.)"/>

    <xsl:variable name="l">
      <xsl:call-template name="getLangForMetadata">
        <xsl:with-param name="uiLang" select="/root/gui/language" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="value">
      <xsl:call-template name="localised">
        <xsl:with-param name="langId" select="$l" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="isXLinked" select="count(ancestor-or-self::node()[@xlink:href]) > 0" />


    <xsl:variable name="tooltip">
      <xsl:call-template name="getTooltipTitle-iso19139">
        <xsl:with-param name="name"   select="name(.)"/>
        <xsl:with-param name="schema" select="$schema"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:apply-templates mode="simpleElement" select=".">
      <xsl:with-param name="schema" select="$schema" />
      <xsl:with-param name="edit" select="$edit" />
      <xsl:with-param name="tooltip" select="$tooltip" />
      <xsl:with-param name="text">
        <xsl:choose>
          <xsl:when test="$edit=true()">

            <xsl:variable name="lang" select="/root/gui/language"/>
            <xsl:variable name="canLabel" select="/root/gui/schemas/iso19139/strings/can" />
            <xsl:variable name="usaLabel" select="/root/gui/schemas/iso19139/strings/usa" />

            <select class="form-control" name="_{gco:CharacterString/geonet:element/@ref}"
                    size="1" title="{$tooltip}">
              <option name="" />
              <optgroup label="{$canLabel}">
                <xsl:for-each select="/root/gui/schemas/iso19139.ca.HNAP/strings/adminAreas/area[@country='CAN']">
                  <xsl:variable name="areaEng" select="@eng" />
                  <xsl:variable name="areaFre" select="@fre" />
                  <option>
                    <xsl:attribute name="value"><xsl:value-of select="@eng"/></xsl:attribute>

                    <xsl:if test="lower-case($value) = lower-case($areaEng) or lower-case($value) = lower-case($areaFre)">
                      <xsl:attribute name="selected"/>
                    </xsl:if>

                    <xsl:choose>
                      <xsl:when test="/root/gui/language = 'fre'"><xsl:value-of select="$areaFre"/></xsl:when>
                      <xsl:otherwise><xsl:value-of select="$areaEng"/></xsl:otherwise>
                    </xsl:choose>

                  </option>
                </xsl:for-each>
              </optgroup>
              <optgroup label="{$usaLabel}">
                <xsl:for-each select="/root/gui/schemas/iso19139.ca.HNAP/strings/adminAreas/area[@country='USA']">
                  <xsl:variable name="areaEng" select="@eng" />
                  <xsl:variable name="areaFre" select="@fre" />
                  <option>
                    <xsl:attribute name="value"><xsl:value-of select="@eng"/></xsl:attribute>

                    <xsl:if test="$value = $areaEng or $value = $areaFre">
                      <xsl:attribute name="selected"/>
                    </xsl:if>

                    <xsl:choose>
                      <xsl:when test="/root/gui/language = 'fre'"><xsl:value-of select="$areaFre"/></xsl:when>
                      <xsl:otherwise><xsl:value-of select="$areaEng"/></xsl:otherwise>
                    </xsl:choose>

                  </option>
                </xsl:for-each>
              </optgroup>
            </select>

          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of
              select="$value" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <!-- get related resources (conversions) identifiers (@xlink:title) for the resource url provided -->
  <xsl:template name="getRelatedResources.nap">
    <xsl:param name="resourceUrl" />

    <!-- Metadata files -->
    <xsl:variable name="resourceFiles" select="/root/*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/geonet:info/files" />

    <!-- Resource id -->
    <!--<xsl:variable name="internalId" select="string($resourceFiles/record[normalize-space(publishedurl)=$resourceUrl]/id)" />-->
    <xsl:variable name="internalId" select="string($resourceFiles/record[normalize-space(filename)=$resourceUrl and relatedtoid = '']/id)" />

    <!-- Metadata online resource -->
    <xsl:variable name="onlineResources" select="/root/*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions" />

    <xsl:if test="string($internalId)">
      <xsl:for-each select="$resourceFiles/record[relatedtoid = $internalId]">
        <xsl:variable name="publishedurlVal" select="publishedurl" />
        <xsl:variable name="fileVal" select="filename" />

        <!-- Check if the online resource contains the published URL -->
        <xsl:variable name="orUrl" select="$onlineResources/*/gmd:onLine[@xlink:role='urn:xml:lang:eng-CAN' and gmd:CI_OnlineResource/gmd:linkage/gmd:URL = $publishedurlVal]/@xlink:title" />

        <!-- Check if the online resource contains the file name (no published resources) -->
        <xsl:variable name="orFile" select="$onlineResources/*/gmd:onLine[@xlink:role='urn:xml:lang:eng-CAN' and contains(gmd:CI_OnlineResource/gmd:linkage/gmd:URL, concat('fname=', $fileVal))]/@xlink:title" />

        <xsl:if test="string($orUrl)"><xsl:value-of select="$orUrl" />:::</xsl:if>
        <xsl:if test="string($orFile)"><xsl:value-of select="$orFile" />:::</xsl:if>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>


  <!-- Override template, parent identifier is hidden field -->
  <!--<xsl:template mode="iso19139" match="gmd:parentIdentifier" priority="20" />-->



  <!-- Don't show in the editor the classification keywords, will be edited in an independent dialog as should be synchronized -->
  <xsl:template mode="iso19139" match="gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Waf']" priority="200" />

  <!-- EC: CharacterSet as readonly input text-->
  <xsl:template mode="iso19139" match="//gmd:MD_Metadata/gmd:characterSet|//*[@gco:isoType='gmd:MD_Metadata']/gmd:characterSet" priority="20">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

    <xsl:variable name="tooltip">
      <xsl:call-template name="getTooltipTitle-iso19139">
        <xsl:with-param name="name"   select="name(.)"/>
        <xsl:with-param name="schema" select="$schema"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:apply-templates mode="simpleElement" select=".">
      <xsl:with-param name="schema"  select="$schema"/>
      <xsl:with-param name="edit"    select="false()"/>
      <xsl:with-param name="tooltip"  select="$tooltip"/>


      <xsl:with-param name="text">
        <xsl:choose>
          <xsl:when test="normalize-space(*/@codeListValue)=''">
            <span class="info">
              - <xsl:value-of select="/root/gui/strings/setOnSave"/> -
            </span>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$edit = true()">
                <xsl:variable name="codelistProfile"  select="/root/gui/schemas/*[name() = $schema]/codelists/codelist[@name = 'gmd:MD_CharacterSetCode']" />

                <xsl:variable name="codelist" select="exslt:node-set($codelistProfile)" />
                <xsl:variable name="value"    select="*/@codeListValue"/>
                <xsl:variable name="charsetVal">
                  <xsl:if test="normalize-space($value)!=''">
                    <xsl:value-of select="$codelist/entry[code = $value]/label"/>
                  </xsl:if>
                </xsl:variable>

                <input type="text" readonly="readonly" value="{$charsetVal}" class="md readonly" size="40" title="{$tooltip}"/><span>&#160;</span>
              </xsl:when>

              <xsl:otherwise>
                <xsl:apply-templates mode="iso19139GetAttributeText" select="*/@codeListValue">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="edit"   select="$edit"/>
                  <xsl:with-param name="tooltip"   select="$tooltip"/>
                </xsl:apply-templates>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>


  <xsl:template mode="ecCoreSubjectThesaurus" match="*">
    <xsl:param name="schema" />
    <xsl:param name="edit" />
    <!-- Metadata main language -->
    <xsl:param name="langId" />

    <xsl:variable name="thesaurusVal">
      <xsl:call-template name="localised">
        <xsl:with-param name="langId" select="$langId" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="uiLanguage">
      <xsl:call-template name="getLangForMetadata">
        <xsl:with-param name="uiLang" select="/root/gui/language" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="thesaurusValUi">
      <xsl:call-template name="localised">
        <xsl:with-param name="langId" select="$uiLanguage" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$edit =  true()">

        <xsl:variable name="ref" select="gco:CharacterString/geonet:element/@ref"/>

        <xsl:variable name="validValue" select="not(string($thesaurusVal)) or (count(/root/gui/rdf:ecCoreSubjectThesaurus/skos:concept/skos:prefLabel[@xml:lang='fr' and normalize-space(.) = normalize-space($thesaurusVal)]) > 0 or
                            count(/root/gui/rdf:ecCoreSubjectThesaurus/skos:concept/skos:prefLabel[not(string(@xml:lang)) and normalize-space(.) = normalize-space($thesaurusVal)]) > 0)" />

        <input type="text" class="form-control" style="display:inline" value="{$thesaurusValUi}" readonly="readonly" id="_{$ref}_show" size="50" />
        <input type="hidden" class="form-control" name="_{$ref}" value="{$thesaurusVal}" />
        &#160;
        <button type="button" class="btn btn-default btn-md fa fa-edit " onclick="keywordSelectionPanel.showPanelEdit({$ref}, jQuery('#_{$ref}_show').val(), '{$langId}')"></button>

        <xsl:if test="not($validValue)">
          &#160;<span class="error-inline"><xsl:value-of select="/root/gui/strings/no-valid-value" /></span>
        </xsl:if>

      </xsl:when>
      <xsl:otherwise>
        <span><xsl:value-of select="$thesaurusVal" /></span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template mode="iso19139" match="gmd:organisationName" priority="100">
    <xsl:param name="schema" />
    <xsl:param name="edit" />

    <xsl:call-template name="simpleElementGui">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"       select="$edit"/>

      <xsl:with-param name="helpLink">
        <xsl:call-template name="getHelpLink">
          <xsl:with-param name="schema" select="$schema" />
          <xsl:with-param name="name" select="name()" />
        </xsl:call-template>
      </xsl:with-param>

      <xsl:with-param name="title">
        <xsl:call-template name="getTitle">
          <xsl:with-param name="name"   select="name(.)"/>
          <xsl:with-param name="schema" select="$schema"/>
        </xsl:call-template>
      </xsl:with-param>

      <xsl:with-param name="validationLink">
        <xsl:variable name="ref" select="geonet:element/@ref"/>
        <xsl:call-template name="validationLink">
          <xsl:with-param name="ref" select="concat('#_', $ref)"/>
        </xsl:call-template>
      </xsl:with-param>

      <xsl:with-param name="text">
        <xsl:variable name="mainLang">
           <xsl:call-template name="getMainLangFromMetadata">
              <xsl:with-param name="md" select="/root/*"/>
           </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="organisationNameVal">
          <xsl:call-template name="localised">
            <xsl:with-param name="langId" select="$mainLang" />
          </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="otherLang">
          <xsl:choose>
            <xsl:when test="$mainLang = 'eng'">fra</xsl:when>
            <xsl:otherwise>eng</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="organisationNameValOther">
          <xsl:call-template name="localised">
            <xsl:with-param name="langId" select="$otherLang" />
          </xsl:call-template>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="$edit =  true()">
            <xsl:variable name="ref" select="gco:CharacterString/geonet:element/@ref"/>

            <xsl:variable name="tmpFreeText">
              <xsl:call-template name="PT_FreeText_Tree" />
            </xsl:variable>

            <xsl:variable name="ptFreeTextTree" select="exslt:node-set($tmpFreeText)" />


            <xsl:variable name="mainLangId">
              <xsl:call-template name="getLangIdFromMetadata">
                <xsl:with-param name="lang" select="$mainLang" />
                <xsl:with-param name="md"
                                select="ancestor-or-self::*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']" />
              </xsl:call-template>
            </xsl:variable>

            <xsl:variable name="relElemId">
              <xsl:if test="gco:CharacterString"><xsl:value-of select="gco:CharacterString/geonet:element/@ref" /> </xsl:if>
            </xsl:variable>

            <xsl:choose>
              <xsl:when test="$ptFreeTextTree//gmd:LocalisedCharacterString">
                <!-- Create combo to select language.
                On change, the input with selected language is displayed. Others hidden. -->

                <xsl:variable name="mainLanguageRef">
                  <xsl:choose>
                    <xsl:when test="gco:CharacterString/geonet:element/@ref" >
                      <xsl:value-of select="concat('_', gco:CharacterString/geonet:element/@ref)"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="concat('_',
                                      gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=$mainLangId]/geonet:element/@ref)"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>


                <xsl:variable name="other-ref" select="$ptFreeTextTree//gmd:LocalisedCharacterString/geonet:element/@ref"/>
                <input type="hidden" class="form-control" name="_{$ref}" value="{$organisationNameVal}" />
                <input type="hidden" class="form-control" name="_{$other-ref}" id="_{$other-ref}"  value="{$organisationNameValOther}" />

                <button type="button" class="btn btn-default btn-md fa fa-edit " onclick="organisationSelectionPanel.showPanelEdit({$ref}, '{$other-ref}', jQuery('#true_{$ref}').val(), jQuery('#true_{$other-ref}').val(), '{$mainLang}')"></button>

                <div role="tabpanel">

                  <div class="wb-tabs lang-tabs">
                    <div class="tabpanels">
                      <xsl:choose>
                        <xsl:when test="gco:*">
                          <xsl:choose>
                            <xsl:when test="/root/gui/language = 'fre'">
                              <xsl:choose>
                                <xsl:when test="$mainLangId='#fra'">
                                  <xsl:for-each select="gco:CharacterString">
                                    <xsl:call-template name="tbLangTab">
                                      <xsl:with-param name="id" select="gco:*/geonet:element/@ref" />
                                      <xsl:with-param name="label" select="/root/gui/strings/french" />
                                      <xsl:with-param name="lang" select="'fre'" />
                                      <xsl:with-param name="rows" select="'1'" />
                                      <xsl:with-param name="schema" select="$schema" />
                                      <xsl:with-param name="edit" select="$edit" />
                                      <xsl:with-param name="readonly" select="'true'" />
                                    </xsl:call-template>
                                  </xsl:for-each>
                                  <xsl:for-each select="$ptFreeTextTree//gmd:LocalisedCharacterString[@locale!=$mainLangId]">
                                    <xsl:call-template name="tbLangTab">
                                      <xsl:with-param name="id" select="geonet:element/@ref" />
                                      <xsl:with-param name="label" select="@language" />
                                      <xsl:with-param name="lang" select="@locale" />
                                      <xsl:with-param name="rows" select="'1'" />
                                      <xsl:with-param name="schema" select="$schema" />
                                      <xsl:with-param name="edit" select="$edit" />
                                      <xsl:with-param name="relElemId" select="$relElemId" />
                                      <xsl:with-param name="readonly" select="'true'" />
                                    </xsl:call-template>
                                  </xsl:for-each>
                                </xsl:when>

                                <xsl:when test="$mainLangId!='#fra'">
                                  <xsl:for-each select="$ptFreeTextTree//gmd:LocalisedCharacterString[@locale!=$mainLangId]">
                                    <xsl:call-template name="tbLangTab">
                                      <xsl:with-param name="id" select="geonet:element/@ref" />
                                      <xsl:with-param name="label" select="@language" />
                                      <xsl:with-param name="lang" select="replace(@locale, '#', '')" />
                                      <xsl:with-param name="rows" select="'1'" />
                                      <xsl:with-param name="schema" select="$schema" />
                                      <xsl:with-param name="edit" select="$edit" />
                                      <xsl:with-param name="relElemId" select="$relElemId" />
                                      <xsl:with-param name="readonly" select="'true'" />
                                    </xsl:call-template>
                                  </xsl:for-each>
                                  <xsl:for-each select="gco:CharacterString">
                                    <xsl:call-template name="tbLangTab">
                                      <xsl:with-param name="id" select="geonet:element/@ref" />
                                      <xsl:with-param name="label" select="/root/gui/strings/english" />
                                      <xsl:with-param name="lang" select="'eng'" />
                                      <xsl:with-param name="rows" select="'1'" />
                                      <xsl:with-param name="schema" select="$schema" />
                                      <xsl:with-param name="edit" select="$edit" />
                                      <xsl:with-param name="readonly" select="'true'" />
                                    </xsl:call-template>
                                  </xsl:for-each>
                                </xsl:when>
                              </xsl:choose>
                            </xsl:when>
                            <xsl:when test="/root/gui/language = 'eng'">
                              <!--<xsl:value-of select="gco:*/geonet:element"/>-->
                              <xsl:choose>
                                <xsl:when test="$mainLangId='#eng'">
                                  <xsl:for-each select="gco:CharacterString">
                                    <xsl:call-template name="tbLangTab">
                                      <xsl:with-param name="id" select="geonet:element/@ref" />
                                      <xsl:with-param name="label" select="/root/gui/strings/english" />
                                      <xsl:with-param name="lang" select="'eng'" />
                                      <xsl:with-param name="rows" select="'1'" />
                                      <xsl:with-param name="schema" select="$schema" />
                                      <xsl:with-param name="edit" select="$edit" />
                                      <xsl:with-param name="readonly" select="'true'" />
                                    </xsl:call-template>
                                  </xsl:for-each>
                                  <xsl:for-each select="$ptFreeTextTree//gmd:LocalisedCharacterString[@locale!=$mainLangId]">
                                    <xsl:call-template name="tbLangTab">
                                      <xsl:with-param name="id" select="geonet:element/@ref" />
                                      <xsl:with-param name="label" select="@language" />
                                      <xsl:with-param name="lang" select="replace(@locale, '#', '')" />
                                      <xsl:with-param name="rows" select="'1'" />
                                      <xsl:with-param name="schema" select="$schema" />
                                      <xsl:with-param name="edit" select="$edit" />
                                      <xsl:with-param name="relElemId" select="$relElemId" />
                                      <xsl:with-param name="readonly" select="'true'" />
                                    </xsl:call-template>
                                  </xsl:for-each>
                                </xsl:when>
                                <xsl:when test="$mainLangId!='#eng'">
                                  <xsl:for-each select="$ptFreeTextTree//gmd:LocalisedCharacterString[@locale!=$mainLangId]">
                                    <xsl:call-template name="tbLangTab">
                                      <xsl:with-param name="id" select="geonet:element/@ref" />
                                      <xsl:with-param name="label" select="@language" />
                                      <xsl:with-param name="lang" select="replace(@locale, '#', '')" />
                                      <xsl:with-param name="rows" select="'1'" />
                                      <xsl:with-param name="schema" select="$schema" />
                                      <xsl:with-param name="edit" select="$edit" />
                                      <xsl:with-param name="relElemId" select="$relElemId" />
                                      <xsl:with-param name="readonly" select="'true'" />
                                    </xsl:call-template>
                                  </xsl:for-each>
                                  <xsl:for-each select="gco:CharacterString">
                                    <xsl:call-template name="tbLangTab">
                                      <xsl:with-param name="id" select="geonet:element/@ref" />
                                      <xsl:with-param name="label" select="/root/gui/strings/french" />
                                      <xsl:with-param name="lang" select="'fre'" />
                                      <xsl:with-param name="rows" select="'1'" />
                                      <xsl:with-param name="schema" select="$schema" />
                                      <xsl:with-param name="edit" select="$edit" />
                                      <xsl:with-param name="readonly" select="'true'" />
                                    </xsl:call-template>
                                  </xsl:for-each>
                                </xsl:when>
                              </xsl:choose>
                            </xsl:when>
                          </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:for-each select="$ptFreeTextTree//gmd:LocalisedCharacterString">
                            <xsl:call-template name="tbLangTab">
                              <xsl:with-param name="id" select="geonet:element/@ref" />
                              <xsl:with-param name="label" select="@language" />
                              <xsl:with-param name="lang" select="replace(@locale, '#', '')" />
                              <xsl:with-param name="rows" select="'1'" />
                              <xsl:with-param name="schema" select="$schema" />
                              <xsl:with-param name="edit" select="$edit" />
                              <xsl:with-param name="relElemId" select="$relElemId" />
                              <xsl:with-param name="readonly" select="'true'" />

                            </xsl:call-template>
                          </xsl:for-each>
                        </xsl:otherwise>
                      </xsl:choose>


                    </div>
                  </div>

                </div>
              </xsl:when>
              <xsl:otherwise>

              </xsl:otherwise>
            </xsl:choose>

          </xsl:when>
          <xsl:otherwise>
            <span><xsl:value-of select="$organisationNameVal" /></span>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>

    </xsl:call-template>

  </xsl:template>

  <!-- ===================================================================== -->
  <!-- gml:TimePeriod (format = %Y-%m-%dThh:mm:ss) -->
  <!-- ===================================================================== -->

  <xsl:template mode="iso19139" match="gml:*[gml:beginPosition|gml:endPosition]|gml:TimeInstant[gml:timePosition]" priority="20">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:for-each select="*">
      <xsl:choose>
        <xsl:when test="$edit=true() and (name(.)='gml:beginPosition' or name(.)='gml:endPosition' or name(.)='gml:timePosition')">
          <xsl:apply-templates mode="simpleElement" select=".">
            <xsl:with-param name="schema"  select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
            <xsl:with-param name="text">
              <xsl:variable name="ref" select="geonet:element/@ref"/>
              <xsl:variable name="format"><xsl:text>%Y-%m-%dT%H:%M:00</xsl:text></xsl:variable>

              <xsl:variable name="tooltip">
                <xsl:call-template name="getTooltipTitle-iso19139">
                  <xsl:with-param name="name"   select="name(.)"/>
                  <xsl:with-param name="schema" select="$schema"/>
                </xsl:call-template>
              </xsl:variable>

              <xsl:variable name="mandatory">
                <xsl:choose>
                  <xsl:when test="name(.) != 'gml:endPosition'">
                    <xsl:value-of select="geonet:element/@min='1'"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="false()"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>

              <xsl:call-template name="calendar-temporal-extent">
                <xsl:with-param name="ref" select="$ref"/>
                <xsl:with-param name="date" select="text()"/>
                <xsl:with-param name="format" select="$format"/>
                <xsl:with-param name="tooltip" select="$tooltip"/>
                <xsl:with-param name="mandatory" select="$mandatory"/>
              </xsl:call-template>

            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:when test="name(.)='gml:timeInterval'">
          <xsl:apply-templates mode="iso19139" select="."/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="simpleElement" select=".">
            <xsl:with-param name="schema"  select="$schema"/>
            <xsl:with-param name="text">
              <xsl:value-of select="text()"/>
            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>


  <!-- Disable ref system panel in EC -->
  <xsl:template mode="addXMLFragment" match="gmd:referenceSystemInfo|
				geonet:child[@name='referenceSystemInfo' and @prefix='gmd']" priority="20">
  </xsl:template>

  <!-- Disable keyword panel in EC -->
  <xsl:template mode="addXMLFragment" match="gmd:descriptiveKeywords|
      geonet:child[@name='descriptiveKeywords' and @prefix='gmd']" priority="20">
  </xsl:template>

  <!-- =====================================================================
  * Anyway some elements should not be multilingual.

  Use this template to define which elements
  are not multilingual.
  If an element is not multilingual and require
  a specific widget (eg. protocol list), create
  a new template for this new element.

  !!! WARNING: this is not defined in ISO19139. !!!
  This list of element mainly focus on identifier (eg. postal code)
  which are usually not multilingual. The list has been defined
  based on ISO profil for Switzerland recommendations. Feel free
  to adapt this list according to your needs.
-->
  <xsl:template mode="iso19139"
                match="
		gmd:code[gco:CharacterString]|
		gmd:individualName[gco:CharacterString]|
		gmd:identifier[gco:CharacterString]|
		gmd:metadataStandardVersion[gco:CharacterString]|
		gmd:hierarchyLevelName[gco:CharacterString]|
		gmd:dataSetURI[gco:CharacterString]|
		gmd:postalCode[gco:CharacterString]|
		gmd:city[gco:CharacterString]|
		gmd:facsimile[gco:CharacterString]|
		gmd:MD_Format/gmd:name[gco:CharacterString]|
		gmd:MD_Format/gmd:version[gco:CharacterString]|
		gmd:MD_ScopeDescription/gmd:dataset[gco:CharacterString]|
		gmd:MD_ScopeDescription/gmd:other[gco:CharacterString]|
		gmd:applicationProfile[gco:CharacterString]|
		gmd:CI_Series/gmd:page[gco:CharacterString]|
		gmd:MD_BrowseGraphic/gmd:fileName[gco:CharacterString]|
		gmd:MD_BrowseGraphic/gmd:fileType[gco:CharacterString]|
		gmd:unitsOfDistribution[gco:CharacterString]|
		gmd:amendmentNumber[gco:CharacterString]|
		gmd:specification[gco:CharacterString]|
		gmd:fileDecompressionTechnique[gco:CharacterString]|
		gmd:turnaround[gco:CharacterString]|
		gmd:fees[gco:CharacterString]|
		gmd:userDeterminedLimitations[gco:CharacterString]|
		gmd:RS_Identifier/gmd:codeSpace[gco:CharacterString]|
		gmd:RS_Identifier/gmd:version[gco:CharacterString]|
		gmd:edition[gco:CharacterString]|
		gmd:ISBN[gco:CharacterString]|
		gmd:ISSN[gco:CharacterString]|
		gmd:errorStatistic[gco:CharacterString]|
		gmd:schemaAscii[gco:CharacterString]|
		gmd:softwareDevelopmentFileFormat[gco:CharacterString]|
		gmd:MD_ExtendedElementInformation/gmd:shortName[gco:CharacterString]|
		gmd:MD_ExtendedElementInformation/gmd:condition[gco:CharacterString]|
		gmd:MD_ExtendedElementInformation/gmd:maximumOccurence[gco:CharacterString]|
		gmd:MD_ExtendedElementInformation/gmd:domainValue[gco:CharacterString]|
		gmd:densityUnits[gco:CharacterString]|
		gmd:MD_RangeDimension/gmd:descriptor[gco:CharacterString]|
		gmd:classificationSystem[gco:CharacterString]|
		gmd:checkPointDescription[gco:CharacterString]|
		gmd:transformationDimensionDescription[gco:CharacterString]|
		gmd:orientationParameterDescription[gco:CharacterString]|
		srv:SV_OperationChainMetadata/srv:name[gco:CharacterString]|
		srv:SV_OperationMetadata/srv:invocationName[gco:CharacterString]|
		srv:serviceTypeVersion[gco:CharacterString]|
		srv:operationName[gco:CharacterString]|
		srv:identifier[gco:CharacterString]|
		gco:aName[gco:CharacterString]|
		srv:optionality[gco:CharacterString]
		"
                priority="120">
    <xsl:param name="schema" />
    <xsl:param name="edit" />

    <xsl:call-template name="iso19139String">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="iso19139" match="gmd:date[gco:DateTime|gco:Date]" priority="20">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

    <xsl:choose>
      <xsl:when test="$edit=true()">
        <xsl:apply-templates mode="simpleElement" select=".">
          <xsl:with-param name="schema"  select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>

          <xsl:with-param name="text">
            <xsl:variable name="ref" select="gco:DateTime/geonet:element/@ref|gco:Date/geonet:element/@ref"/>
            <xsl:variable name="format">
              <xsl:choose>
                <xsl:when test="gco:Date"><xsl:text>%Y-%m-%d</xsl:text></xsl:when>
                <xsl:otherwise><xsl:text>%Y-%m-%dT%H:%M:00</xsl:text></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <xsl:variable name="tooltip">
              <xsl:call-template name="getTooltipTitle-iso19139">
                <xsl:with-param name="name"   select="name(.)"/>
                <xsl:with-param name="schema" select="$schema"/>
              </xsl:call-template>
            </xsl:variable>

            <xsl:variable name="mandatory" select="gco:Date/geonet:element/@min='1' or gco:DateTime/geonet:element/@min='1'"/>

            <xsl:call-template name="calendar-temporal-extent">
              <xsl:with-param name="ref" select="$ref"/>
              <xsl:with-param name="date" select="gco:DateTime/text()|gco:Date/text()"/>
              <xsl:with-param name="format" select="$format"/>
              <xsl:with-param name="tooltip" select="$tooltip"/>
              <xsl:with-param name="mandatory" select="$mandatory"/>
            </xsl:call-template>

          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="dateTypeCode" select="../gmd:dateType/gmd:CI_DateTypeCode/@codeListValue" />

        <xsl:variable name="textValue">
          <xsl:value-of select="gco:DateTime|gco:Date" /> <xsl:text> (</xsl:text><xsl:value-of select="/root/gui/schemas/iso19139.ca.HNAP/codelists/codelist[@name='gmd:CI_DateTypeCode']/entry[code = $dateTypeCode]/label "/><xsl:text>)</xsl:text>
        </xsl:variable>

        <xsl:apply-templates mode="simpleElement" select=".">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
          <xsl:with-param name="text" select="$textValue">
          </xsl:with-param>
        </xsl:apply-templates>

      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="gmd:keyword[
          normalize-space(../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Government of Canada Core Subject Thesaurus' or
          normalize-space(../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Thésaurus des sujets de base du gouvernement du Canada']" mode="iso19139" priority="200">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>


    <xsl:variable name="id">geographic_<xsl:value-of select="geonet:element/@uuid"/></xsl:variable>
    <xsl:variable name="last" select="position() = last()"/>

    <xsl:variable name="titleECGeographicScope">
      <xsl:call-template name="getTitle">
        <xsl:with-param name="name"   select="'gmd:keyword'"/>
        <xsl:with-param name="schema" select="$schema"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="tooltipECGeographicScope">
      <!-- Use dummy element name to identify field in metadata editor. In XML is stored as a keyword -->
      <xsl:call-template name="getTooltipTitle">
        <xsl:with-param name="name"   select="'CoreSubjectThesaurus'"/>
        <xsl:with-param name="schema" select="$schema"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:call-template name="simpleElementGui">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"       select="$edit"/>
      <xsl:with-param name="id" select="$id"/>

      <xsl:with-param name="title">
        <!-- Use dummy element name to identify field in metadata editor. In XML is stored as a keyword -->
        <xsl:value-of select="$titleECGeographicScope" />

        <xsl:call-template name="asterisk">
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:call-template>

        <span id="buttons_{$id}">

          <xsl:variable name="addLink">
            <xsl:value-of select="concat('keywordSelectionPanel.showPanelAdd(',$apos,geonet:element/@ref,$apos,',',$apos,geonet:element/@parent,$apos,',1)')"/>
          </xsl:variable>

          <xsl:variable name="removeLink">
            <xsl:value-of select="concat('doRemoveElementAction(',$apos,'/metadata.elem.delete',$apos,',',geonet:element/@ref,',',geonet:element/@parent,',',$apos,'',$id,$apos,',',../../geonet:element/@min,',',$apos, 'core' ,$apos, ');')"/>
          </xsl:variable>

          <xsl:if test="$edit">
            &#160;<a id="add_{$id}" style="cursor:hand;cursor:pointer;" onclick="if (noDoubleClick()) {$addLink}" target="_blank">
            <xsl:attribute name="style">
              cursor:hand;cursor:pointer;
              <xsl:if test="not($last)">display:none;</xsl:if>
            </xsl:attribute>

            <img src="{/root/gui/url}/images/plus.gif" class="icon" alt="{/root/gui/strings/add}" title="{/root/gui/strings/add}"/></a>

            &#160;<a id="remove_{$id}" style="cursor:hand;cursor:pointer;" onclick="if (noDoubleClick()) {$removeLink}" target="_blank">
            <xsl:attribute name="style">
              cursor:hand;cursor:pointer;
              <!--<xsl:if test="$countECCoreSubjectThesaurus = 1">display:none;</xsl:if>-->
            </xsl:attribute>

            <img src="{/root/gui/url}/images/del.gif" class="icon" alt="{/root/gui/strings/del}" title="{/root/gui/strings/del}"/></a>
          </xsl:if>

        </span>

      </xsl:with-param>
      <xsl:with-param name="tooltip" select="$tooltipECGeographicScope" />

      <xsl:with-param name="validationLink">
        <xsl:variable name="ref" select="concat('#_',gco:CharacterString/geonet:element/@ref)"/>
        <xsl:call-template name="validationLink">
          <xsl:with-param name="ref" select="$ref"/>
          <xsl:with-param name="title" select="$titleECGeographicScope"/>
        </xsl:call-template>
      </xsl:with-param>

      <xsl:with-param name="text">
        <xsl:variable name="mainLang">
           <xsl:call-template name="getMainLangFromMetadata">
              <xsl:with-param name="md" select="/root/*"/>
           </xsl:call-template>
        </xsl:variable>


        <xsl:apply-templates mode="ecCoreSubjectThesaurus" select=".">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
          <!-- Metadata main language -->
          <xsl:with-param name="langId">
            <xsl:choose>
              <xsl:when test="starts-with($mainLang, 'fra')">fra</xsl:when>
              <xsl:otherwise>eng</xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:with-param>

    </xsl:call-template>
  </xsl:template>


  <xsl:template mode="iso19139" match="gmd:metadataStandardName" priority="100">
    <xsl:param name="schema" />
    <xsl:param name="edit" />

    <xsl:call-template name="localizedCharStringField">
      <xsl:with-param name="schema" select="$schema" />
      <xsl:with-param name="edit" select="$edit" />
      <xsl:with-param name="rows" select="'1'" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="iso19139" match="srv:serviceType" priority="100">
    <xsl:param name="schema" />
    <xsl:param name="edit" />

    <xsl:apply-templates mode="simpleElement" select=".">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
      <xsl:with-param name="text">
        <xsl:choose>
          <xsl:when test="$edit=true()">
            <input type="text"  name="_{gco:LocalName/geonet:element/@ref}" id="_{gco:LocalName/geonet:element/@ref}" class="form-control" size="40" value="{gco:LocalName}" />
            <xsl:for-each select="gco:LocalName">
              <xsl:call-template name="helper">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="attribute" select="false()"/>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of
              select="gco:LocalName" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <!-- Boxed srv elements -->
  <xsl:template mode="iso19139" match="srv:connectPoint|srv:parameters|srv:accessProperties">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

    <xsl:apply-templates mode="complexElement" select=".">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template mode="iso19139" match="gmd:transferOptions/gmd:MD_DigitalTransferOptions" priority="100">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

    <xsl:apply-templates mode="elementEP" select="gmd:unitsOfDistribution|geonet:child[string(@name)='unitsOfDistribution']">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit" select="$edit"/>
    </xsl:apply-templates>

    <xsl:apply-templates mode="elementEP" select="gmd:transferSize|geonet:child[string(@name)='transferSize']">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="true()"/>
    </xsl:apply-templates>

    <xsl:if test="count(gmd:onLine) &gt; 0">
      <xsl:variable name="langId">
        <xsl:call-template name="getLangId">
          <xsl:with-param name="langGui" select="/root/gui/language"/>
          <xsl:with-param name="md" select="."/>
        </xsl:call-template>
      </xsl:variable>

      <p><strong><xsl:value-of select="/root/gui/schemas/iso19139.ca.HNAP/strings/resources" /></strong></p>
      <ul>
        <xsl:for-each select="gmd:onLine/gmd:CI_OnlineResource">
          <xsl:variable name="name">
            <xsl:apply-templates mode="localised" select="gmd:name">
              <xsl:with-param name="langId" select="$langId"></xsl:with-param>
            </xsl:apply-templates>
          </xsl:variable>

          <li><a href="{gmd:linkage/gmd:URL}" target="_blank"><xsl:value-of select="$name" /></a></li>
        </xsl:for-each>
      </ul>
    </xsl:if>

    <xsl:apply-templates mode="elementEP" select="gmd:offLine|geonet:child[string(@name)='offLine']">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="true()"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template mode="iso19139" match="gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat/gmd:MD_Format/gmd:name" priority="120">
    <xsl:param name="schema" />
    <xsl:param name="edit" />

    <xsl:variable name="value" select="gco:CharacterString" />

    <xsl:variable name="tooltip">
      <xsl:call-template name="getTooltipTitle-iso19139">
        <xsl:with-param name="name"   select="name(.)"/>
        <xsl:with-param name="schema" select="$schema"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:apply-templates mode="simpleElement" select=".">
      <xsl:with-param name="schema" select="$schema" />
      <xsl:with-param name="edit" select="$edit" />
      <xsl:with-param name="tooltip" select="$tooltip" />
      <xsl:with-param name="text">
        <xsl:choose>
          <xsl:when test="$edit=true()">
            <xsl:variable name="lang">
              <xsl:call-template name="toIso2LangCode">
                <xsl:with-param name="iso3code" select="/root/gui/language"/>
              </xsl:call-template>
            </xsl:variable>

            <xsl:variable name="validValue" select="not(string($value)) or (count(/root/gui/rdf:ecFormats/rdf:Description[
            	(normalize-space(ns2:prefLabel[@xml:lang='fr']) = normalize-space($value)) or
            	(normalize-space(ns2:prefLabel[@xml:lang='en']) = normalize-space($value))]) > 0)" />

            <select class="form-control" name="_{gco:CharacterString/geonet:element/@ref}"
                    size="1" title="{$tooltip}">
              <xsl:if test="not($validValue)">
                <option value="{$value}" selected="selected"><xsl:value-of select="$value" /></option>
                <option disabled="disabled">_________</option>
              </xsl:if>

              <option value=""></option>

              <xsl:for-each select="/root/gui/rdf:ecFormats/rdf:Description/ns2:prefLabel[@xml:lang=$lang]">
                <xsl:sort select="." />
                <xsl:variable name="formatVal" select="." />
                <option>
                  <xsl:attribute name="value"><xsl:value-of select="$formatVal"/></xsl:attribute>

                  <xsl:if test="$value = $formatVal">
                    <xsl:attribute name="selected"/>
                  </xsl:if>

                  <xsl:value-of select="$formatVal"/>
                </option>
              </xsl:for-each>
            </select>
            <xsl:if test="not($validValue)">
              &#160;<span class="error-inline"><xsl:value-of select="/root/gui/strings/no-valid-value" /></span>
            </xsl:if>

          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of
              select="$value" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>
</xsl:stylesheet>
