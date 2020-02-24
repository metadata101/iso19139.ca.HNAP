<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:napec="http://www.ec.gc.ca/data_donnees/standards/schemas/napec"
                xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:xls="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">

  <xsl:param name="schemaDir" />

  <xsl:variable name="labels-file" select="document(concat('file:///', $schemaDir, 'loc/eng/labels.xml'))"/>
  <xsl:variable name="labels-file-fre" select="document(concat('file:///', $schemaDir, 'loc/fre/labels.xml'))"/>

  <xsl:variable name="uuid" select="gmd:MD_Metadata/gmd:fileIdentifier/gco:CharacterString" />

  <xsl:variable name="mainLanguage" select="substring(gmd:MD_Metadata/gmd:language/gco:CharacterString, 1, 3)" />

  <xsl:variable name="localeLang">
    <xsl:choose>
      <xsl:when test="$mainLanguage = 'eng'">#fra</xsl:when>
      <xsl:otherwise>#eng</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template match="/" priority="100">
    <translations>
      <xsl:apply-templates select="*" />
    </translations>
  </xsl:template>


  <xsl:template match="gmd:MD_Metadata" priority="100">
    <xsl:variable name="xpath"><xsl:call-template name="getXPath" /></xsl:variable>

    <xsl:variable name="sectionTitleEnglish">
      <xsl:call-template name="getTitle">
        <xsl:with-param name="name" select="name()"/>
        <xsl:with-param name="fullContext" select="$xpath" />
        <xsl:with-param name="labels-file" select="$labels-file" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="sectionTitleFrench">
      <xsl:call-template name="getTitle">
        <xsl:with-param name="name" select="name()"/>
        <xsl:with-param name="fullContext" select="$xpath" />
        <xsl:with-param name="labels-file" select="$labels-file-fre" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="sectionContactE">
      <xsl:call-template name="getTitle">
        <xsl:with-param name="name" select="'gmd:contact'"/>
        <xsl:with-param name="fullContext" select="$xpath" />
        <xsl:with-param name="labels-file" select="$labels-file" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="sectionContactF">
      <xsl:call-template name="getTitle">
        <xsl:with-param name="name" select="'gmd:contact'"/>
        <xsl:with-param name="fullContext" select="$xpath" />
        <xsl:with-param name="labels-file" select="$labels-file-fre" />
      </xsl:call-template>
    </xsl:variable>

    <!-- contact -->
    <xsl:for-each select="gmd:contact">
      <xsl:variable name="positionContact" select="position()" />

      <xsl:for-each select="gmd:CI_ResponsibleParty/gmd:organisationName">
        <xsl:call-template name="recordEntry">
          <xsl:with-param name="sectionTitleE" select="concat($sectionTitleEnglish, ' - ', $sectionContactE)" />
          <xsl:with-param name="sectionTitleF" select="concat($sectionTitleFrench, ' - ', $sectionContactF)" />
          <xsl:with-param name="position" select="$positionContact" />
        </xsl:call-template>
      </xsl:for-each>

      <xsl:for-each select="gmd:CI_ResponsibleParty/gmd:positionName">
        <xsl:call-template name="recordEntry">
          <xsl:with-param name="sectionTitleE" select="concat($sectionTitleEnglish, ' - ', $sectionContactE)" />
          <xsl:with-param name="sectionTitleF" select="concat($sectionTitleFrench, ' - ', $sectionContactF)" />
          <xsl:with-param name="position" select="$positionContact" />
        </xsl:call-template>
      </xsl:for-each>

      <xsl:for-each select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint">
        <xsl:call-template name="recordEntry">
          <xsl:with-param name="sectionTitleE" select="concat($sectionTitleEnglish, ' - ', $sectionContactE)" />
          <xsl:with-param name="sectionTitleF" select="concat($sectionTitleFrench, ' - ', $sectionContactF)" />
          <xsl:with-param name="position" select="concat($positionContact, '-', position())" />
        </xsl:call-template>
      </xsl:for-each>


      <xsl:for-each select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService">
        <xsl:call-template name="recordEntry">
          <xsl:with-param name="sectionTitleE" select="concat($sectionTitleEnglish, ' - ', $sectionContactE)" />
          <xsl:with-param name="sectionTitleF" select="concat($sectionTitleFrench, ' - ', $sectionContactF)" />
          <xsl:with-param name="position" select="$positionContact" />
        </xsl:call-template>
      </xsl:for-each>

      <xsl:for-each select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:contactInstructions">
        <xsl:call-template name="recordEntry">
          <xsl:with-param name="sectionTitleE" select="concat($sectionTitleEnglish, ' - ', $sectionContactE)" />
          <xsl:with-param name="sectionTitleF" select="concat($sectionTitleFrench, ' - ', $sectionContactF)" />
          <xsl:with-param name="position" select="$positionContact" />
        </xsl:call-template>
      </xsl:for-each>

    </xsl:for-each>

    <xsl:apply-templates select="*[name() != 'gmd:contact']" />

  </xsl:template>


  <!-- Extract multillingual elements:
      - Elements from online resources are ignored.
      - Element gmd:useLimitation is ignored as has default (approved) value.
      - Keywords from controlled vocabularies are ignored.
-->
  <xsl:template match="gmd:identificationInfo/napec:MD_DataIdentification" priority="100">
    <xsl:variable name="xpath"><xsl:call-template name="getXPath" /></xsl:variable>

    <xsl:variable name="sectionTitleEnglish">
      <xsl:call-template name="getTitle">
        <xsl:with-param name="name" select="'napec:MD_DataIdentification'"/>
        <xsl:with-param name="fullContext" select="$xpath" />
        <xsl:with-param name="labels-file" select="$labels-file" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="sectionTitleFrench">
      <xsl:call-template name="getTitle">
        <xsl:with-param name="name" select="'napec:MD_DataIdentification'"/>
        <xsl:with-param name="fullContext" select="$xpath" />
        <xsl:with-param name="labels-file" select="$labels-file-fre" />
      </xsl:call-template>
    </xsl:variable>

    <!-- title -->
    <xsl:for-each select="gmd:citation/gmd:CI_Citation/gmd:title">
      <xsl:call-template name="recordEntry">
        <xsl:with-param name="sectionTitleE" select="$sectionTitleEnglish" />
        <xsl:with-param name="sectionTitleF" select="$sectionTitleFrench" />
      </xsl:call-template>
    </xsl:for-each>

    <!-- abstract -->
    <xsl:for-each select="gmd:abstract">
      <xsl:call-template name="recordEntry">
        <xsl:with-param name="sectionTitleE" select="$sectionTitleEnglish" />
        <xsl:with-param name="sectionTitleF" select="$sectionTitleFrench" />
      </xsl:call-template>
    </xsl:for-each>

    <!-- supplemental information -->
    <xsl:for-each select="gmd:supplementalInformation">
      <xsl:call-template name="recordEntry">
        <xsl:with-param name="sectionTitleE" select="$sectionTitleEnglish" />
        <xsl:with-param name="sectionTitleF" select="$sectionTitleFrench" />
      </xsl:call-template>
    </xsl:for-each>


    <xsl:variable name="sectionCitedResponsiblePartyE">
      <xsl:call-template name="getTitle">
        <xsl:with-param name="name" select="'gmd:citedResponsibleParty'"/>
        <xsl:with-param name="fullContext" select="$xpath" />
        <xsl:with-param name="labels-file" select="$labels-file" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="sectionCitedResponsiblePartyF">
      <xsl:call-template name="getTitle">
        <xsl:with-param name="name" select="'gmd:citedResponsibleParty'"/>
        <xsl:with-param name="fullContext" select="$xpath" />
        <xsl:with-param name="labels-file" select="$labels-file-fre" />
      </xsl:call-template>
    </xsl:variable>

    <!-- cited responsible party -->
    <xsl:for-each select="gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty">
      <xsl:variable name="positionCRP" select="position()" />

      <xsl:for-each select="gmd:CI_ResponsibleParty/gmd:organisationName">
        <xsl:call-template name="recordEntry">
          <xsl:with-param name="sectionTitleE" select="concat($sectionTitleEnglish, ' - ', $sectionCitedResponsiblePartyE)" />
          <xsl:with-param name="sectionTitleF" select="concat($sectionTitleFrench, ' - ', $sectionCitedResponsiblePartyF)" />
          <xsl:with-param name="position" select="$positionCRP" />
        </xsl:call-template>
      </xsl:for-each>

      <xsl:for-each select="gmd:CI_ResponsibleParty/gmd:positionName">
        <xsl:call-template name="recordEntry">
          <xsl:with-param name="sectionTitleE" select="concat($sectionTitleEnglish, ' - ', $sectionCitedResponsiblePartyE)" />
          <xsl:with-param name="sectionTitleF" select="concat($sectionTitleFrench, ' - ', $sectionCitedResponsiblePartyF)" />
          <xsl:with-param name="position" select="$positionCRP" />
        </xsl:call-template>
      </xsl:for-each>

      <xsl:for-each select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint">
        <xsl:call-template name="recordEntry">
          <xsl:with-param name="sectionTitleE" select="concat($sectionTitleEnglish, ' - ', $sectionCitedResponsiblePartyE)" />
          <xsl:with-param name="sectionTitleF" select="concat($sectionTitleFrench, ' - ', $sectionCitedResponsiblePartyF)" />
          <xsl:with-param name="position" select="concat($positionCRP, '-', position())" />
        </xsl:call-template>
      </xsl:for-each>


      <xsl:for-each select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService">
        <xsl:call-template name="recordEntry">
          <xsl:with-param name="sectionTitleE" select="concat($sectionTitleEnglish, ' - ', $sectionCitedResponsiblePartyE)" />
          <xsl:with-param name="sectionTitleF" select="concat($sectionTitleFrench, ' - ', $sectionCitedResponsiblePartyF)" />
          <xsl:with-param name="position" select="$positionCRP" />
        </xsl:call-template>
      </xsl:for-each>

      <xsl:for-each select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:contactInstructions">
        <xsl:call-template name="recordEntry">
          <xsl:with-param name="sectionTitleE" select="concat($sectionTitleEnglish, ' - ', $sectionCitedResponsiblePartyE)" />
          <xsl:with-param name="sectionTitleF" select="concat($sectionTitleFrench, ' - ', $sectionCitedResponsiblePartyF)" />
          <xsl:with-param name="position" select="$positionCRP" />
        </xsl:call-template>
      </xsl:for-each>

    </xsl:for-each>

    <!-- keywords (free-text) -->
    <xsl:for-each select="gmd:descriptiveKeywords">
      <xsl:variable name="decriptiveKeywordsPos" select="position()" />

      <xsl:for-each select="gmd:MD_Keywords/gmd:keyword">
        <xsl:if test="not(../gmd:thesaurusName/gmd:CI_Citation/@id) and not(
            normalize-space(../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'local.theme.EC_Information_Category') and not(
            normalize-space(../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'local.place.EC_Geographic_Scope') and not(
            normalize-space(../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'local.theme.EC_Data_Usage_Scope') and not(
            normalize-space(../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'local.theme.EC_Content_Scope') and not(
            normalize-space(../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'local.theme.EC_Waf') and not(
            normalize-space(../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Government of Canada Core Subject Thesaurus') and not(
            normalize-space(../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Thésaurus des sujets de base du gouvernement du Canada')">
          <xsl:call-template name="recordEntry">
            <xsl:with-param name="sectionTitleE" select="$sectionTitleEnglish" />
            <xsl:with-param name="sectionTitleF" select="$sectionTitleFrench" />
            <xsl:with-param name="position" select="concat($decriptiveKeywordsPos, '-', position())" />
          </xsl:call-template>

        </xsl:if>
      </xsl:for-each>

    </xsl:for-each>

    <!-- other contraints -->
    <xsl:for-each select="gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints">
      <xsl:call-template name="recordEntry">
        <xsl:with-param name="sectionTitleE" select="$sectionTitleEnglish" />
        <xsl:with-param name="sectionTitleF" select="$sectionTitleFrench" />
        <xsl:with-param name="position" select="position()" />
      </xsl:call-template>
    </xsl:for-each>

    <!-- EC project -->
    <xsl:for-each select="napec:EC_CorporateInfo/napec:EC_Project">
      <xsl:call-template name="recordEntry">
        <xsl:with-param name="sectionTitleE" select="$sectionTitleEnglish" />
        <xsl:with-param name="sectionTitleF" select="$sectionTitleFrench" />
        <xsl:with-param name="position" select="position()" />
      </xsl:call-template>
    </xsl:for-each>

  </xsl:template>

  <xsl:template match="gmd:identificationInfo/napec:SV_ServiceIdentification" priority="100">
    <xsl:variable name="xpath"><xsl:call-template name="getXPath" /></xsl:variable>

    <xsl:variable name="sectionTitleEnglish">
      <xsl:call-template name="getTitle">
        <xsl:with-param name="name" select="'napec:SV_ServiceIdentification'"/>
        <xsl:with-param name="fullContext" select="$xpath" />
        <xsl:with-param name="labels-file" select="$labels-file" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="sectionTitleFrench">
      <xsl:call-template name="getTitle">
        <xsl:with-param name="name" select="'napec:SV_ServiceIdentification'"/>
        <xsl:with-param name="fullContext" select="$xpath" />
        <xsl:with-param name="labels-file" select="$labels-file-fre" />
      </xsl:call-template>
    </xsl:variable>

    <!-- title -->
    <xsl:for-each select="gmd:citation/gmd:CI_Citation/gmd:title">
      <xsl:call-template name="recordEntry">
        <xsl:with-param name="sectionTitleE" select="$sectionTitleEnglish" />
        <xsl:with-param name="sectionTitleF" select="$sectionTitleFrench" />
      </xsl:call-template>
    </xsl:for-each>

    <!-- abstract -->
    <xsl:for-each select="gmd:abstract">
      <xsl:call-template name="recordEntry">
        <xsl:with-param name="sectionTitleE" select="$sectionTitleEnglish" />
        <xsl:with-param name="sectionTitleF" select="$sectionTitleFrench" />
      </xsl:call-template>
    </xsl:for-each>


    <xsl:variable name="sectionCitedResponsiblePartyE">
      <xsl:call-template name="getTitle">
        <xsl:with-param name="name" select="'gmd:citedResponsibleParty'"/>
        <xsl:with-param name="fullContext" select="$xpath" />
        <xsl:with-param name="labels-file" select="$labels-file" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="sectionCitedResponsiblePartyF">
      <xsl:call-template name="getTitle">
        <xsl:with-param name="name" select="'gmd:citedResponsibleParty'"/>
        <xsl:with-param name="fullContext" select="$xpath" />
        <xsl:with-param name="labels-file" select="$labels-file-fre" />
      </xsl:call-template>
    </xsl:variable>

    <!-- cited responsible party -->
    <xsl:for-each select="gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty">
      <xsl:variable name="positionCRP" select="position()" />

      <xsl:for-each select="gmd:CI_ResponsibleParty/gmd:organisationName">
        <xsl:call-template name="recordEntry">
          <xsl:with-param name="sectionTitleE" select="concat($sectionTitleEnglish, ' - ', $sectionCitedResponsiblePartyE)" />
          <xsl:with-param name="sectionTitleF" select="concat($sectionTitleFrench, ' - ', $sectionCitedResponsiblePartyF)" />
          <xsl:with-param name="position" select="$positionCRP" />
        </xsl:call-template>
      </xsl:for-each>

      <xsl:for-each select="gmd:CI_ResponsibleParty/gmd:positionName">
        <xsl:call-template name="recordEntry">
          <xsl:with-param name="sectionTitleE" select="concat($sectionTitleEnglish, ' - ', $sectionCitedResponsiblePartyE)" />
          <xsl:with-param name="sectionTitleF" select="concat($sectionTitleFrench, ' - ', $sectionCitedResponsiblePartyF)" />
          <xsl:with-param name="position" select="$positionCRP" />
        </xsl:call-template>
      </xsl:for-each>

      <xsl:for-each select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint">
        <xsl:call-template name="recordEntry">
          <xsl:with-param name="sectionTitleE" select="concat($sectionTitleEnglish, ' - ', $sectionCitedResponsiblePartyE)" />
          <xsl:with-param name="sectionTitleF" select="concat($sectionTitleFrench, ' - ', $sectionCitedResponsiblePartyF)" />
          <xsl:with-param name="position" select="concat($positionCRP, '-', position())" />
        </xsl:call-template>
      </xsl:for-each>


      <xsl:for-each select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService">
        <xsl:call-template name="recordEntry">
          <xsl:with-param name="sectionTitleE" select="concat($sectionTitleEnglish, ' - ', $sectionCitedResponsiblePartyE)" />
          <xsl:with-param name="sectionTitleF" select="concat($sectionTitleFrench, ' - ', $sectionCitedResponsiblePartyF)" />
          <xsl:with-param name="position" select="$positionCRP" />
        </xsl:call-template>
      </xsl:for-each>

      <xsl:for-each select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:contactInstructions">
        <xsl:call-template name="recordEntry">
          <xsl:with-param name="sectionTitleE" select="concat($sectionTitleEnglish, ' - ', $sectionCitedResponsiblePartyE)" />
          <xsl:with-param name="sectionTitleF" select="concat($sectionTitleFrench, ' - ', $sectionCitedResponsiblePartyF)" />
          <xsl:with-param name="position" select="$positionCRP" />
        </xsl:call-template>
      </xsl:for-each>

    </xsl:for-each>

    <!-- keywords (free-text) -->
    <xsl:for-each select="gmd:descriptiveKeywords">
      <xsl:variable name="decriptiveKeywordsPos" select="position()" />

      <xsl:for-each select="gmd:MD_Keywords/gmd:keyword">
        <xsl:if test="not(../gmd:thesaurusName/gmd:CI_Citation/@id) and not(
            normalize-space(../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Government of Canada Core Subject Thesaurus') and not(
            normalize-space(../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'Thésaurus des sujets de base du gouvernement du Canada')">
          <xsl:call-template name="recordEntry">
            <xsl:with-param name="sectionTitleE" select="$sectionTitleEnglish" />
            <xsl:with-param name="sectionTitleF" select="$sectionTitleFrench" />
            <xsl:with-param name="position" select="concat($decriptiveKeywordsPos, '-', position())" />
          </xsl:call-template>

        </xsl:if>
      </xsl:for-each>

    </xsl:for-each>

    <!-- other contraints -->
    <xsl:for-each select="gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints">
      <xsl:call-template name="recordEntry">
        <xsl:with-param name="sectionTitleE" select="$sectionTitleEnglish" />
        <xsl:with-param name="sectionTitleF" select="$sectionTitleFrench" />
        <xsl:with-param name="position" select="position()" />
      </xsl:call-template>
    </xsl:for-each>

    <!-- EC project -->
    <xsl:for-each select="napec:EC_CorporateInfo/napec:EC_Project">
      <xsl:call-template name="recordEntry">
        <xsl:with-param name="sectionTitleE" select="$sectionTitleEnglish" />
        <xsl:with-param name="sectionTitleF" select="$sectionTitleFrench" />
        <xsl:with-param name="position" select="position()" />
      </xsl:call-template>
    </xsl:for-each>

  </xsl:template>

  <xsl:template match="gmd:distributionInfo" priority="100">
    <xsl:variable name="xpath"><xsl:call-template name="getXPath" /></xsl:variable>

    <xsl:variable name="sectionTitleEnglish">
      <xsl:call-template name="getTitle">
        <xsl:with-param name="name" select="'gmd:distributionInfo'"/>
        <xsl:with-param name="fullContext" select="$xpath" />
        <xsl:with-param name="labels-file" select="$labels-file" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="sectionTitleFrench">
      <xsl:call-template name="getTitle">
        <xsl:with-param name="name" select="'gmd:distributionInfo'"/>
        <xsl:with-param name="fullContext" select="$xpath" />
        <xsl:with-param name="labels-file" select="$labels-file-fre" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="sectionDistributorContactE">
      <xsl:call-template name="getTitle">
        <xsl:with-param name="name" select="'gmd:distributorContact'"/>
        <xsl:with-param name="fullContext" select="$xpath" />
        <xsl:with-param name="labels-file" select="$labels-file" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="sectionDistributorContactF">
      <xsl:call-template name="getTitle">
        <xsl:with-param name="name" select="'gmd:distributorContact'"/>
        <xsl:with-param name="fullContext" select="$xpath" />
        <xsl:with-param name="labels-file" select="$labels-file-fre" />
      </xsl:call-template>
    </xsl:variable>


    <xsl:for-each select="gmd:MD_Distribution/gmd:distributor">
      <xsl:variable name="distributorPos" select="position()" />
      <xsl:for-each select="gmd:MD_Distributor/gmd:distributorContact">

        <xsl:for-each select="gmd:CI_ResponsibleParty/gmd:organisationName">
          <xsl:call-template name="recordEntry">
            <xsl:with-param name="sectionTitleE" select="concat($sectionTitleEnglish, ' - ', $sectionDistributorContactE)" />
            <xsl:with-param name="sectionTitleF" select="concat($sectionTitleFrench, ' - ', $sectionDistributorContactF)" />
            <xsl:with-param name="position" select="$distributorPos" />
          </xsl:call-template>
        </xsl:for-each>

        <xsl:for-each select="gmd:CI_ResponsibleParty/gmd:positionName">
          <xsl:call-template name="recordEntry">
            <xsl:with-param name="sectionTitleE" select="concat($sectionTitleEnglish, ' - ', $sectionDistributorContactE)" />
            <xsl:with-param name="sectionTitleF" select="concat($sectionTitleFrench, ' - ', $sectionDistributorContactF)" />
            <xsl:with-param name="position" select="$distributorPos" />
          </xsl:call-template>
        </xsl:for-each>

        <xsl:for-each select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint">
          <xsl:call-template name="recordEntry">
            <xsl:with-param name="sectionTitleE" select="concat($sectionTitleEnglish, ' - ', $sectionDistributorContactE)" />
            <xsl:with-param name="sectionTitleF" select="concat($sectionTitleFrench, ' - ', $sectionDistributorContactF)" />
            <xsl:with-param name="position" select="concat($distributorPos, '-', position())" />
          </xsl:call-template>
        </xsl:for-each>


        <xsl:for-each select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService">
          <xsl:call-template name="recordEntry">
            <xsl:with-param name="sectionTitleE" select="concat($sectionTitleEnglish, ' - ', $sectionDistributorContactE)" />
            <xsl:with-param name="sectionTitleF" select="concat($sectionTitleFrench, ' - ', $sectionDistributorContactF)" />
            <xsl:with-param name="position" select="$distributorPos" />
          </xsl:call-template>
        </xsl:for-each>

        <xsl:for-each select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:contactInstructions">
          <xsl:call-template name="recordEntry">
            <xsl:with-param name="sectionTitleE" select="concat($sectionTitleEnglish, ' - ', $sectionDistributorContactE)" />
            <xsl:with-param name="sectionTitleF" select="concat($sectionTitleFrench, ' - ', $sectionDistributorContactF)" />
            <xsl:with-param name="position" select="$distributorPos" />
          </xsl:call-template>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>


  <!-- Utility templates -->
  <xsl:template name="getXPath">
    <xsl:for-each select="ancestor-or-self::*">
      <xsl:if test="not(position() = 1)">
        <xsl:value-of select="name()" />
      </xsl:if>
      <xsl:if test="not(position() = 1) and not(position() = last())">
        <xsl:text>/</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <!-- Check if is an attribute: http://www.dpawson.co.uk/xsl/sect2/nodetest.html#d7610e91 -->
    <xsl:if test="count(. | ../@*) = count(../@*)">/@<xsl:value-of select="name()" /></xsl:if>
  </xsl:template>

  <xsl:template name="getTitle">
    <xsl:param name="name"/>
    <xsl:param name="fullContext"/>
    <xsl:param name="labels-file" />


    <xsl:variable name="context" select="name(parent::node())"/>
    <xsl:variable name="contextIsoType" select="parent::node()/@gco:isoType"/>

    <xsl:variable name="title">
      <!-- Name with context in current schema -->
      <xsl:variable name="schematitleWithContext"
                    select="string($labels-file/labels/element[@name=$name and (@context=$fullContext or @context=$context or @context=$contextIsoType)]/label)"/>

      <!-- Name in current schema -->
      <xsl:variable name="schematitle" select="string($labels-file/labels/element[@name=$name and not(@context)]/label)"/>

      <xsl:choose>
        <xsl:when test="normalize-space($schematitleWithContext)=''">
          <xsl:value-of select="$schematitle"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$schematitleWithContext"/>
        </xsl:otherwise>

      </xsl:choose>
    </xsl:variable>


    <xsl:choose>
      <xsl:when test="normalize-space($title)!=''">
        <xsl:value-of select="$title"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$name"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Template to create a section with the translation information -->
  <xsl:template name="recordEntry">
    <xsl:param name="sectionTitleE" select="''"/>
    <xsl:param name="sectionTitleF" select="''"/>
    <xsl:param name="position" select="'1'"/>

    <xsl:variable name="xpath"><xsl:call-template name="getXPath" /></xsl:variable>
    <record>
      <label_eng>
        <xsl:choose>
          <xsl:when test="string($sectionTitleE)">
            <xsl:value-of select="$sectionTitleE" /> -
          </xsl:when>
        </xsl:choose>
        <xsl:call-template name="getTitle">
          <xsl:with-param name="name" select="name()"/>
          <xsl:with-param name="fullContext" select="$xpath" />
          <xsl:with-param name="labels-file" select="$labels-file" />
        </xsl:call-template></label_eng>
      <label_fre>
        <xsl:choose>
          <xsl:when test="string($sectionTitleF)">
            <xsl:value-of select="$sectionTitleF" /> -
          </xsl:when>
        </xsl:choose>
        <xsl:call-template name="getTitle">
          <xsl:with-param name="name" select="name()"/>
          <xsl:with-param name="fullContext" select="$xpath" />
          <xsl:with-param name="labels-file" select="$labels-file-fre" />
        </xsl:call-template></label_fre>
      <lang_eng>
        <xsl:choose>
          <xsl:when test="$mainLanguage = 'eng'"><xsl:value-of select="gco:CharacterString" /></xsl:when>
          <xsl:otherwise><xsl:value-of select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString" /></xsl:otherwise>
        </xsl:choose>
      </lang_eng>
      <lang_fre>
        <xsl:choose>
          <xsl:when test="$mainLanguage = 'fra'"><xsl:value-of select="gco:CharacterString" /></xsl:when>
          <xsl:otherwise><xsl:value-of select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString" /></xsl:otherwise>
        </xsl:choose>
      </lang_fre>
      <uuid><xsl:value-of select="$uuid" /></uuid>
      <schema>iso19139.napec</schema>
      <xpath><xls:value-of select="$xpath" /></xpath>
      <position><xsl:value-of select="$position" /></position>
    </record>
  </xsl:template>

</xsl:stylesheet>