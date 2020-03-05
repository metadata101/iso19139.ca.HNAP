<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:napec="http://www.ec.gc.ca/data_donnees/standards/schemas/napec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="gmd xsl gco srv geonet napec xsi xs">

  <!-- TODO: check replace function, probably requires to be replaced by java method, seem not working in phrases -->

  <xsl:param name="replacements" />

  <xsl:variable name="mainLanguage" select="substring(gmd:MD_Metadata/gmd:language/gco:CharacterString, 1, 3)" />

  <xsl:variable name="localeLang">
    <xsl:choose>
      <xsl:when test="$mainLanguage = 'eng'">#fra</xsl:when>
      <xsl:otherwise>#eng</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- by default is case sensitive, sending i value in the param makes replacements case insensitive -->
  <xsl:variable name="case_insensitive" select="$replacements/replacements/caseInsensitive" />

  <!-- Do a copy of every nodes and attributes -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Remove geonet:* elements. -->
  <!--<xsl:template match="geonet:*" priority="2"/>-->

  <!--                    -->
  <!-- Field replacements -->
  <!--                    -->

  <!-- IDENTIFICATION updates: gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification -->
  <!-- Title: id.dataid.title -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation/gmd:title|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:title|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:title">
    <xsl:call-template name="replaceFieldMultilingual">
      <xsl:with-param name="fieldId">id.dataid.title</xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation">
    <xsl:copy>
      <xsl:copy-of select="@*" />

      <xsl:apply-templates select="gmd:title" />
      <xsl:apply-templates select="gmd:alternateTitle" />
      <!--<xsl:apply-templates select="gmd:date" />-->

      <xsl:variable name="fieldIdDate" select="'id.dataid.date'" />
      <xsl:choose>
        <!-- If date added, but also an empty gmd:date, don't copy the empty in the result -->
        <xsl:when test="$replacements/replacements/replacement[field = $fieldIdDate and searchValue = ':;:']">
          <xsl:apply-templates select="gmd:date[string(gmd:CI_Date/gmd:date/gco:Date)]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="gmd:date" />
        </xsl:otherwise>
      </xsl:choose>

      <xsl:for-each select="$replacements/replacements/replacement[field = $fieldIdDate]">
        <xsl:if test="searchValue = ':;:'">
          <xsl:variable name="replaceType" select="tokenize(replaceValue,':;:')[2]" />
          <xsl:variable name="replaceDate" select="tokenize(replaceValue,':;:')[1]" />

          <gmd:date>
            <gmd:CI_Date>
              <xsl:attribute name="geonet:change" select="$fieldIdDate" />
              <xsl:attribute name="geonet:original" select="''" />
              <xsl:attribute name="geonet:new" select="concat($replaceDate, '/', $replaceType)" />

              <gmd:date>
                <gco:Date><xsl:value-of select="$replaceDate" /></gco:Date>
              </gmd:date>
              <gmd:dateType>
                <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="{$replaceType}"/>
              </gmd:dateType>
            </gmd:CI_Date>
          </gmd:date>
        </xsl:if>
      </xsl:for-each>

      <xsl:apply-templates select="gmd:accessConstraints" />

      <xsl:apply-templates select="gmd:edition" />
      <xsl:apply-templates select="gmd:editionDate" />
      <xsl:apply-templates select="gmd:identifier" />
      <xsl:apply-templates select="gmd:citedResponsibleParty" />
      <xsl:apply-templates select="gmd:presentationForm" />
      <xsl:apply-templates select="gmd:series" />
      <xsl:apply-templates select="gmd:otherCitationDetails" />
      <xsl:apply-templates select="gmd:collectiveTitle" />
      <xsl:apply-templates select="gmd:ISBN" />
      <xsl:apply-templates select="gmd:ISSN" />

    </xsl:copy>

  </xsl:template>


  <!-- date/date type -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date">
    <xsl:message>gmd:CI_Date</xsl:message>
    <xsl:variable name="fieldId" select="'id.dataid.date'" />

    <xsl:choose>
      <xsl:when test="$replacements/replacements/replacement[field = $fieldId and searchValue != ':;:']">

        <xsl:call-template name="replace-loop-date">
          <xsl:with-param name="actualValDate" select="gmd:date/gco:Date" />
          <xsl:with-param name="actualValDateType" select="gmd:dateType/gmd:CI_DateTypeCode/@codeListValue" />
          <xsl:with-param name="fieldId" select="$fieldId" />
          <xsl:with-param name="i" select="1" />
          <xsl:with-param name="n" select="count($replacements/replacements/replacement[field = $fieldId])" />
        </xsl:call-template>
      </xsl:when>

      <xsl:otherwise>
        <xsl:copy>
          <xsl:copy-of select="@*" />
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:template>

  <!-- Abstract: id.dataid.abstract -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:abstract|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:abstract|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:abstract">
    <xsl:call-template name="replaceFieldMultilingual">
      <xsl:with-param name="fieldId">id.dataid.abstract</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Status: id.dataid.status --> <!-- TODO: Check geonet:change -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:status|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:status|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:status|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:status">
    <xsl:variable name="fieldId" select="'id.dataid.status'" />
    <xsl:variable name="newValue">
      <xsl:call-template name="replace-loop-multiple">
        <xsl:with-param name="actualVal" select="gmd:MD_ProgressCode/@codeListValue" />
        <xsl:with-param name="fieldId" select="$fieldId" />
        <xsl:with-param name="i" select="1" />
        <xsl:with-param name="n" select="count($replacements/replacements/replacement[field = $fieldId])" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:copy>
      <xsl:copy-of select="@*" />
      <gmd:MD_ProgressCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_ProgressCode" codeListValue="{$newValue}">
        <xsl:if test="gmd:MD_ProgressCode/@codeListValue != $newValue">
          <xsl:attribute name="geonet:change" select="'id.dataid.status'" />
          <xsl:attribute name="geonet:original" select="gmd:MD_ProgressCode/@codeListValue" />
          <xsl:attribute name="geonet:new" select="$newValue" />
        </xsl:if>

      </gmd:MD_ProgressCode>
    </xsl:copy>
  </xsl:template>

  <!-- Topic category: id.dataid.topiccategory -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:topicCategory|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:topicCategory">
    <xsl:variable name="fieldId" select="'id.dataid.topiccategory'" />
    <xsl:variable name="newValue">
      <xsl:call-template name="replace-loop-multiple">
        <xsl:with-param name="actualVal" select="gmd:MD_TopicCategoryCode" />
        <xsl:with-param name="fieldId" select="$fieldId" />
        <xsl:with-param name="i" select="1" />
        <xsl:with-param name="n" select="count($replacements/replacements/replacement[field = $fieldId])" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:copy>
      <xsl:choose>
        <xsl:when test="not(string($newValue))"><xsl:copy-of select="@*" /></xsl:when>
        <xsl:otherwise><xsl:copy-of select="@*[not(name()='gco:nilReason')]" /></xsl:otherwise>
      </xsl:choose>

      <gmd:MD_TopicCategoryCode>
        <xsl:if test="gmd:MD_TopicCategoryCode != $newValue">
          <xsl:attribute name="geonet:change" select="'id.dataid.topiccategory'" />
          <xsl:attribute name="geonet:original" select="gmd:MD_TopicCategoryCode" />
          <xsl:attribute name="geonet:new" select="$newValue" />
        </xsl:if>

        <xsl:value-of select="$newValue" />
      </gmd:MD_TopicCategoryCode>
    </xsl:copy>
  </xsl:template>

  <!-- Supplemental information: id.dataid.supplementalinfo -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:supplementalInformation|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:supplementalInformation">
    <xsl:call-template name="replaceFieldMultilingual">
      <xsl:with-param name="fieldId">id.dataid.supplementalinfo</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Maintenance/update frequency: id.dataid.maintenanceupdatefreq -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency">
    <xsl:variable name="fieldId" select="'id.dataid.maintenanceupdatefreq'" />
    <xsl:variable name="newValue">
      <xsl:call-template name="replace-loop">
        <xsl:with-param name="actualVal" select="gmd:MD_MaintenanceFrequencyCode/@codeListValue" />
        <xsl:with-param name="fieldId" select="$fieldId" />
        <xsl:with-param name="i" select="1" />
        <xsl:with-param name="n" select="count($replacements/replacements/replacement[field = $fieldId])" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:copy>
      <xsl:copy-of select="@*" />
      <gmd:MD_MaintenanceFrequencyCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_MaintenanceFrequencyCode" codeListValue="{$newValue}">
        <xsl:if test="gmd:MD_MaintenanceFrequencyCode/@codeListValue != $newValue">
          <xsl:attribute name="geonet:change" select="'id.dataid.maintenanceupdatefreq'" />
          <xsl:attribute name="geonet:original" select="gmd:MD_MaintenanceFrequencyCode/@codeListValue" />
          <xsl:attribute name="geonet:new" select="$newValue" />
        </xsl:if>
      </gmd:MD_MaintenanceFrequencyCode>
    </xsl:copy>
  </xsl:template>


  <!-- POINT OF CONTACT updates: gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty -->
  <!-- individualName -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:individualName|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:individualName|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:individualName|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:individualName">
    <xsl:call-template name="replaceField">
      <xsl:with-param name="fieldId">id.poc.individualname</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- organisationName -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:organisationName|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:organisationName|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:organisationName|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:organisationName">
    <xsl:call-template name="replaceFieldMultilingual">
      <xsl:with-param name="fieldId">id.poc.orgname</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- positionName -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:positionName|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:positionName|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:positionName|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:positionName">
    <xsl:call-template name="replaceFieldMultilingual">
      <xsl:with-param name="fieldId">id.poc.positionname</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- voice -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice">
    <xsl:call-template name="replaceField">
      <xsl:with-param name="fieldId">id.poc.phonenumber</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- facsimile -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:facsimile|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:facsimile|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:facsimile|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:facsimile">
    <xsl:call-template name="replaceField">
      <xsl:with-param name="fieldId">id.poc.faxnumber</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- deliveryPoint -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint">
    <xsl:call-template name="replaceField">
      <xsl:with-param name="fieldId">id.poc.deliverypoint</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- city -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city">
    <xsl:call-template name="replaceField">
      <xsl:with-param name="fieldId">id.poc.city</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- administrativeArea/province -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea">
    <xsl:call-template name="replaceField">
      <xsl:with-param name="fieldId">id.poc.province</xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <!-- postalCode -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode">
    <xsl:call-template name="replaceField">
      <xsl:with-param name="fieldId">id.poc.postalcode</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- country --> <!-- TODO: Fail replacement -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country">
    <xsl:call-template name="replaceField">
      <xsl:with-param name="fieldId">id.poc.country</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- email -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">
    <xsl:call-template name="replaceField">
      <xsl:with-param name="fieldId">id.poc.email</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- hoursOfService -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService">
    <xsl:call-template name="replaceFieldMultilingual">
      <xsl:with-param name="fieldId">id.poc.hoursofservice</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- onlineResource url --> <!-- TODO: Manage <gmd:linkage gco:nilReason="missing"> -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL">
    <xsl:call-template name="replaceField">
      <xsl:with-param name="fieldId">id.poc.onlineres</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- role -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role">
    <xsl:variable name="fieldId" select="'id.poc.roles'" />
    <xsl:variable name="newValue">
      <xsl:call-template name="replace-loop">
        <xsl:with-param name="actualVal" select="gmd:CI_RoleCode/@codeListValue" />
        <xsl:with-param name="fieldId" select="$fieldId" />
        <xsl:with-param name="i" select="1" />
        <xsl:with-param name="n" select="count($replacements/replacements/replacement[field = $fieldId])" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:copy>
      <xsl:copy-of select="@*" />
      <gmd:CI_RoleCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_RoleCode" codeListValue="{$newValue}">
        <xsl:if test="gmd:CI_RoleCode/@codeListValue != $newValue">
          <xsl:attribute name="geonet:change" select="'id.poc.roles'" />
          <xsl:attribute name="geonet:original" select="gmd:CI_RoleCode/@codeListValue" />
          <xsl:attribute name="geonet:new" select="$newValue" />
        </xsl:if>
      </gmd:CI_RoleCode>
    </xsl:copy>
  </xsl:template>

  <!-- CORPORATE METADATA updates: gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/napec:EC_CorporateInfo -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification' or @gco:isoType='srv:SV_ServiceIdentification']/napec:EC_CorporateInfo">

    <xsl:copy>
      <xsl:copy-of select="@*" />

      <xsl:variable name="fieldIdB" select="'id.corporate.branch'" />
      <xsl:choose>
        <!-- If napec:EC_Branch added, but also an empty napec:EC_Branch, don't copy the empty in the result -->
        <xsl:when test="$replacements/replacements/replacement[field = $fieldIdB and not(string(searchValue))]">
          <xsl:apply-templates select="napec:EC_Branch[string(napec:EC_Branch_TypeCode/@codeListValue)]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="napec:EC_Branch" />
        </xsl:otherwise>
      </xsl:choose>

      <xsl:for-each select="$replacements/replacements/replacement[field = $fieldIdB]">
        <xsl:if test="not(string(searchValue))">
          <napec:EC_Branch>
            <napec:EC_Branch_TypeCode codeListValue="{replaceValue}" codeList="http://www.ec.gc.ca/data_donnees/standards/schemas/napec#EC_Branch">
              <xsl:attribute name="geonet:change" select="$fieldIdB" />
              <xsl:attribute name="geonet:original" select="''" />
              <xsl:attribute name="geonet:new" select="replaceValue" />
            </napec:EC_Branch_TypeCode>
          </napec:EC_Branch>
        </xsl:if>
      </xsl:for-each>

      <!--<xsl:apply-templates select="napec:EC_Branch" />-->

      <xsl:variable name="fieldIdD" select="'id.corporate.directorate'" />
      <xsl:choose>
        <!-- If napec:EC_Branch added, but also an empty napec:EC_Branch, don't copy the empty in the result -->
        <xsl:when test="$replacements/replacements/replacement[field = $fieldIdD and not(string(searchValue))]">
          <xsl:apply-templates select="napec:EC_Directorate[string(napec:EC_Directorate_TypeCode/@codeListValue)]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="napec:EC_Directorate" />
        </xsl:otherwise>
      </xsl:choose>

      <xsl:for-each select="$replacements/replacements/replacement[field = $fieldIdD]">
        <xsl:if test="not(string(searchValue))">
          <napec:EC_Directorate>
            <napec:EC_Directorate_TypeCode codeListValue="{replaceValue}" codeList="http://www.ec.gc.ca/data_donnees/standards/schemas/napec#EC_Directorate">
              <xsl:attribute name="geonet:change" select="$fieldIdD" />
              <xsl:attribute name="geonet:original" select="''" />
              <xsl:attribute name="geonet:new" select="replaceValue" />
            </napec:EC_Directorate_TypeCode>
          </napec:EC_Directorate>
        </xsl:if>
      </xsl:for-each>

      <!--<xsl:apply-templates select="napec:EC_Directorate" />-->


      <xsl:apply-templates select="napec:EC_Project" />


      <!--<xsl:variable name="fieldIdS" select="'id.corporate.securitylevel'" />
      <xsl:for-each select="$replacements/replacements/replacement[field = $fieldIdS]">
        <xsl:if test="not(string(searchValue))">
          <napec:GC_Security_Classification>
            <napec:GC_Security_Classification_TypeCode codeListValue="{replaceValue}" codeList="http://www.ec.gc.ca/data_donnees/standards/schemas/napec#GC_Security_Classification">
              <xsl:attribute name="geonet:change" select="$fieldIdS" />
              <xsl:attribute name="geonet:original" select="''" />
              <xsl:attribute name="geonet:new" select="replaceValue" />
            </napec:GC_Security_Classification_TypeCode>
          </napec:GC_Security_Classification>
        </xsl:if>
      </xsl:for-each>-->

      <xsl:apply-templates select="napec:GC_Security_Classification" />


      <xsl:variable name="fieldIdP" select="'id.corporate.program'" />

      <xsl:choose>
        <!-- If napec:EC_Branch added, but also an empty napec:EC_Branch, don't copy the empty in the result -->
        <xsl:when test="$replacements/replacements/replacement[field = $fieldIdP and not(string(searchValue))]">
          <xsl:apply-templates select="napec:EC_Program[string(napec:EC_Program_TypeCode/@codeListValue)]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="napec:EC_Program" />
        </xsl:otherwise>
      </xsl:choose>

      <xsl:for-each select="$replacements/replacements/replacement[field = $fieldIdP]">
        <xsl:if test="not(string(searchValue))">
          <napec:EC_Program>
            <napec:EC_Program_TypeCode codeListValue="{replaceValue}" codeList="http://www.ec.gc.ca/data_donnees/standards/schemas/napec#EC_Program">
              <xsl:attribute name="geonet:change" select="$fieldIdP" />
              <xsl:attribute name="geonet:original" select="''" />
              <xsl:attribute name="geonet:new" select="replaceValue" />
            </napec:EC_Program_TypeCode>
          </napec:EC_Program>
        </xsl:if>
      </xsl:for-each>

      <!--<xsl:apply-templates select="napec:EC_Program" />-->
    </xsl:copy>
  </xsl:template>

  <!-- branch -->
  <xsl:template match="napec:EC_Branch">
    <xsl:variable name="fieldId" select="'id.corporate.branch'" />
    <xsl:variable name="newValue">
      <xsl:call-template name="replace-loop-multiple">
        <xsl:with-param name="actualVal" select="napec:EC_Branch_TypeCode/@codeListValue" />
        <xsl:with-param name="fieldId" select="$fieldId" />
        <xsl:with-param name="i" select="1" />
        <xsl:with-param name="n" select="count($replacements/replacements/replacement[field = $fieldId])" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:copy>
      <xsl:copy-of select="@*" />
      <napec:EC_Branch_TypeCode codeListValue="{$newValue}" codeList="http://www.ec.gc.ca/data_donnees/standards/schemas/napec#EC_Branch">
        <xsl:if test="napec:EC_Branch_TypeCode/@codeListValue != $newValue">
          <xsl:attribute name="geonet:change" select="'id.corporate.branch'" />
          <xsl:attribute name="geonet:original" select="napec:EC_Branch_TypeCode/@codeListValue" />
          <xsl:attribute name="geonet:new" select="$newValue" />
        </xsl:if>
      </napec:EC_Branch_TypeCode>
    </xsl:copy>
  </xsl:template>

  <!-- directorate -->
  <xsl:template match="napec:EC_Directorate">
    <xsl:variable name="fieldId" select="'id.corporate.directorate'" />
    <xsl:variable name="newValue">
      <xsl:call-template name="replace-loop-multiple">
        <xsl:with-param name="actualVal" select="napec:EC_Directorate_TypeCode/@codeListValue" />
        <xsl:with-param name="fieldId" select="$fieldId" />
        <xsl:with-param name="i" select="1" />
        <xsl:with-param name="n" select="count($replacements/replacements/replacement[field = $fieldId])" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:copy>
      <xsl:copy-of select="@*" />
      <napec:EC_Directorate_TypeCode codeListValue="{$newValue}" codeList="http://www.ec.gc.ca/data_donnees/standards/schemas/napec#EC_Directorate" >
        <xsl:if test="napec:EC_Directorate_TypeCode/@codeListValue != $newValue">
          <xsl:attribute name="geonet:change" select="'id.corporate.directorate'" />
          <xsl:attribute name="geonet:original" select="napec:EC_Directorate_TypeCode/@codeListValue" />
          <xsl:attribute name="geonet:new" select="$newValue" />
        </xsl:if>
      </napec:EC_Directorate_TypeCode>
    </xsl:copy>
  </xsl:template>

  <!-- project -->
  <xsl:template match="napec:EC_Project">
    <xsl:call-template name="replaceFieldMultilingual">
      <xsl:with-param name="fieldId">id.corporate.project</xsl:with-param>
      <xsl:with-param name="multiple" select="true()" />
    </xsl:call-template>
  </xsl:template>

  <!-- Information Category -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword[../gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Information_Category' or ../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Information_Category']|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword[../gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Information_Category' or ../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Information_Category']|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword[../gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Information_Category' or ../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Information_Category']|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword[../gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Information_Category' or ../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Information_Category']">
    <xsl:message>Information Category</xsl:message>

    <!-- gmd:keyword -->
    <xsl:call-template name="replaceFieldMultilingual">
      <xsl:with-param name="fieldId" select="'id.corporate.infocategory'" />
      <xsl:with-param name="multiple" select="true()" />
    </xsl:call-template>
  </xsl:template>

  <!-- Geography -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword[../gmd:thesaurusName/gmd:CI_Citation/@id = 'local.place.EC_Geographic_Scope' or ../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.place.EC_Geographic_Scope']|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword[../gmd:thesaurusName/gmd:CI_Citation/@id = 'local.place.EC_Geographic_Scope' or ../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.place.EC_Geographic_Scope']|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword[../gmd:thesaurusName/gmd:CI_Citation/@id = 'local.place.EC_Geographic_Scope' or ../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.place.EC_Geographic_Scope']|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword[../gmd:thesaurusName/gmd:CI_Citation/@id = 'local.place.EC_Geographic_Scope' or ../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.place.EC_Geographic_Scope']">
    <xsl:message>Geography</xsl:message>

    <!-- gmd:keyword -->
    <xsl:call-template name="replaceFieldMultilingual">
      <xsl:with-param name="fieldId">id.corporate.geography</xsl:with-param>
      <xsl:with-param name="multiple" select="true()" />
    </xsl:call-template>
  </xsl:template>


  <!-- Function -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword[../gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Data_Usage_Scope' or ../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Data_Usage_Scope']|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword[../gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Data_Usage_Scope' or ../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Data_Usage_Scope']|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword[../gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Data_Usage_Scope' or ../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Data_Usage_Scope']|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword[../gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Data_Usage_Scope' or ../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Data_Usage_Scope']">
    <xsl:message>Function</xsl:message>

    <!-- gmd:keyword -->
    <xsl:call-template name="replaceFieldMultilingual">
      <xsl:with-param name="fieldId">id.corporate.function</xsl:with-param>
      <xsl:with-param name="multiple" select="true()" />
    </xsl:call-template>
  </xsl:template>

  <!-- Content -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword[../gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Content_Scope' or ../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Content_Scope']|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword[../gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Content_Scope' or ../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Content_Scope']|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword[../gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Content_Scope' or ../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Content_Scope']|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword[../gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Content_Scope' or ../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Content_Scope']">
    <xsl:message>Content</xsl:message>

    <!-- gmd:keyword -->
    <xsl:call-template name="replaceFieldMultilingual">
      <xsl:with-param name="fieldId">id.corporate.content</xsl:with-param>
      <xsl:with-param name="multiple" select="true()" />
    </xsl:call-template>
  </xsl:template>

  <!-- program -->
  <xsl:template match="napec:EC_Program">
    <xsl:variable name="fieldId" select="'id.corporate.program'" />
    <xsl:variable name="newValue">
      <xsl:call-template name="replace-loop-multiple">
        <xsl:with-param name="actualVal" select="napec:EC_Program_TypeCode/@codeListValue" />
        <xsl:with-param name="fieldId" select="$fieldId" />
        <xsl:with-param name="i" select="1" />
        <xsl:with-param name="n" select="count($replacements/replacements/replacement[field = $fieldId])" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:copy>
      <xsl:copy-of select="@*" />
      <napec:EC_Program_TypeCode codeListValue="{$newValue}" codeList="http://www.ec.gc.ca/data_donnees/standards/schemas/napec#EC_Program">
        <xsl:if test="napec:EC_Program_TypeCode/@codeListValue != $newValue">
          <xsl:attribute name="geonet:change" select="'id.corporate.program'" />
          <xsl:attribute name="geonet:original" select="napec:EC_Program_TypeCode/@codeListValue" />
          <xsl:attribute name="geonet:new" select="$newValue" />
        </xsl:if>
      </napec:EC_Program_TypeCode>
    </xsl:copy>
  </xsl:template>

  <!-- security -->
  <xsl:template match="napec:GC_Security_Classification">
    <xsl:variable name="fieldId" select="'id.corporate.securitylevel'" />
    <xsl:variable name="newValue">
      <xsl:call-template name="replace-loop-multiple-security">
        <xsl:with-param name="actualVal" select="napec:GC_Security_Classification_TypeCode/@codeListValue" />
        <xsl:with-param name="fieldId" select="$fieldId" />
        <xsl:with-param name="i" select="1" />
        <xsl:with-param name="n" select="count($replacements/replacements/replacement[field = $fieldId])" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:copy>
      <xsl:copy-of select="@*" />
      <napec:GC_Security_Classification_TypeCode codeListValue="{$newValue}" codeList="http://www.ec.gc.ca/data_donnees/standards/schemas/napec#GC_Security_Classification">
        <xsl:if test="napec:GC_Security_Classification_TypeCode/@codeListValue != $newValue">
          <xsl:attribute name="geonet:change" select="'id.corporate.securitylevel'" />
          <xsl:attribute name="geonet:original" select="napec:GC_Security_Classification_TypeCode/@codeListValue" />
          <xsl:attribute name="geonet:new" select="$newValue" />
        </xsl:if>
      </napec:GC_Security_Classification_TypeCode>
    </xsl:copy>
  </xsl:template>

  <!-- CONSTRAINTS -->
  <xsl:template match="gmd:MD_LegalConstraints">
    <xsl:copy>
      <xsl:copy-of select="@*" />

      <xsl:apply-templates select="gmd:useLimitation" />

      <xsl:variable name="fieldIdAc" select="'id.constraints.accessconstraints'" />
      <xsl:choose>
        <!-- If status added, but also an empty gmd:status, don't copy the empty in the result -->
        <xsl:when test="$replacements/replacements/replacement[field = $fieldIdAc and not(string(searchValue))]">
          <xsl:apply-templates select="gmd:accessConstraints[string(gmd:MD_RestrictionCode/@codeListValue)]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="gmd:accessConstraints" />
        </xsl:otherwise>
      </xsl:choose>

      <xsl:for-each select="$replacements/replacements/replacement[field = $fieldIdAc]">
        <xsl:if test="not(string(searchValue))">
          <gmd:accessConstraints>
            <gmd:MD_RestrictionCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_RestrictionCode" codeListValue="{replaceValue}" codeSpace="ISOTC211/19115">
              <xsl:attribute name="geonet:change" select="$fieldIdAc" />
              <xsl:attribute name="geonet:original" select="''" />
              <xsl:attribute name="geonet:new" select="replaceValue" />
            </gmd:MD_RestrictionCode>
          </gmd:accessConstraints>
        </xsl:if>
      </xsl:for-each>

      <!--<xsl:apply-templates select="gmd:accessConstraints" />-->

      <xsl:variable name="fieldIdUc" select="'id.constraints.useconstraints'" />
      <xsl:choose>
        <!-- If status added, but also an empty gmd:status, don't copy the empty in the result -->
        <xsl:when test="$replacements/replacements/replacement[field = $fieldIdUc and not(string(searchValue))]">
          <xsl:apply-templates select="gmd:useConstraints[string(gmd:MD_RestrictionCode/@codeListValue)]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="gmd:useConstraints" />
        </xsl:otherwise>
      </xsl:choose>

      <xsl:for-each select="$replacements/replacements/replacement[field = $fieldIdUc]">
        <xsl:if test="not(string(searchValue))">
          <gmd:useConstraints>
            <gmd:MD_RestrictionCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_RestrictionCode" codeListValue="{replaceValue}" codeSpace="ISOTC211/19115">
              <xsl:attribute name="geonet:change" select="$fieldIdUc" />
              <xsl:attribute name="geonet:original" select="''" />
              <xsl:attribute name="geonet:new" select="replaceValue" />
            </gmd:MD_RestrictionCode>
          </gmd:useConstraints>
        </xsl:if>
      </xsl:for-each>

      <!--<xsl:apply-templates select="gmd:useConstraints" />-->

      <xsl:apply-templates select="gmd:otherConstraints" />
    </xsl:copy>
  </xsl:template>

  <!-- legal access -->
  <!--<xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:accessConstraints|gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:accessConstraints">-->
  <xsl:template match="gmd:accessConstraints">
    <xsl:variable name="fieldId" select="'id.constraints.accessconstraints'" />
    <xsl:variable name="newValue">
      <xsl:call-template name="replace-loop-multiple">
        <xsl:with-param name="actualVal" select="gmd:MD_RestrictionCode/@codeListValue" />
        <xsl:with-param name="fieldId" select="$fieldId" />
        <xsl:with-param name="i" select="1" />
        <xsl:with-param name="n" select="count($replacements/replacements/replacement[field = $fieldId])" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:copy>
      <xsl:copy-of select="@*" />
      <gmd:MD_RestrictionCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_RestrictionCode" codeListValue="{$newValue}" codeSpace="ISOTC211/19115">
        <xsl:if test="gmd:MD_RestrictionCode/@codeListValue != $newValue">
          <xsl:attribute name="geonet:change" select="'id.constraints.accessconstraints'" />
          <xsl:attribute name="geonet:original" select="gmd:MD_RestrictionCode/@codeListValue" />
          <xsl:attribute name="geonet:new" select="$newValue" />
        </xsl:if>
      </gmd:MD_RestrictionCode>
    </xsl:copy>
  </xsl:template>

  <!-- use -->
  <!--<xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useConstraints|gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useConstraints">-->
  <xsl:template match="gmd:useConstraints">
    <xsl:variable name="fieldId" select="'id.constraints.useconstraints'" />
    <xsl:variable name="newValue">
      <xsl:call-template name="replace-loop-multiple">
        <xsl:with-param name="actualVal" select="gmd:MD_RestrictionCode/@codeListValue" />
        <xsl:with-param name="fieldId" select="$fieldId" />
        <xsl:with-param name="i" select="1" />
        <xsl:with-param name="n" select="count($replacements/replacements/replacement[field = $fieldId])" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:copy>
      <xsl:copy-of select="@*" />
      <gmd:MD_RestrictionCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_RestrictionCode" codeListValue="{$newValue}" codeSpace="ISOTC211/19115">
        <xsl:if test="gmd:MD_RestrictionCode/@codeListValue != $newValue">
          <xsl:attribute name="geonet:change" select="'id.constraints.useconstraints'" />
          <xsl:attribute name="geonet:original" select="gmd:MD_RestrictionCode/@codeListValue" />
          <xsl:attribute name="geonet:new" select="$newValue" />
        </xsl:if>
      </gmd:MD_RestrictionCode>
    </xsl:copy>
  </xsl:template>

  <!-- note -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints">
    <xsl:call-template name="replaceFieldMultilingual">
      <xsl:with-param name="fieldId">id.constraints.note</xsl:with-param>
    </xsl:call-template>
  </xsl:template>



  <!-- MD_DataIdentification: Add keywords, etc. (if search values empty) -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/napec:MD_DataIdentification">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates select="gmd:citation" />
      <xsl:apply-templates select="gmd:abstract" />
      <xsl:apply-templates select="gmd:purpose" />
      <xsl:apply-templates select="gmd:credit" />

      <!--<xsl:apply-templates select="gmd:status" />-->
      <xsl:variable name="fieldIdSt" select="'id.dataid.status'" />
      <xsl:choose>
        <!-- If status added, but also an empty gmd:status, don't copy the empty in the result -->
        <xsl:when test="$replacements/replacements/replacement[field = $fieldIdSt and not(string(searchValue))]">
          <xsl:apply-templates select="gmd:status[string(gmd:MD_ProgressCode/@codeListValue)]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="gmd:status" />
        </xsl:otherwise>
      </xsl:choose>

      <!-- Add new status -->

      <xsl:for-each select="$replacements/replacements/replacement[field = $fieldIdSt]">
        <xsl:if test="not(string(searchValue))">
          <gmd:status>
            <gmd:MD_ProgressCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_ProgressCode" codeListValue="{replaceValue}">
              <xsl:attribute name="geonet:change" select="'id.dataid.status'" />
              <xsl:attribute name="geonet:original" select="''" />
              <xsl:attribute name="geonet:new" select="replaceValue" />
            </gmd:MD_ProgressCode>
          </gmd:status>
        </xsl:if>
      </xsl:for-each>


      <xsl:apply-templates select="gmd:pointOfContact" />
      <xsl:apply-templates select="gmd:resourceMaintenance" />
      <xsl:apply-templates select="gmd:graphicOverview" />
      <xsl:apply-templates select="gmd:resourceFormat" />

      <!-- add the new keywords -->
      <xsl:variable name="fieldId" select="'id.keywords.keyword'" />

      <xsl:choose>
        <!-- If status added, but also an empty gmd:status, don't copy the empty in the result -->
        <xsl:when test="$replacements/replacements/replacement[field = $fieldId and searchValue = ':;::;:']">
          <xsl:apply-templates select="gmd:descriptiveKeywords[string(gmd:MD_Keywords/gmd:keyword/gco:CharacterString) and not(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Data_Usage_Scope' or
                                                                   gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Information_Category' or
                                                                   gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Content_Scope' or
                                                                   gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Waf' or
                                                                   gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.place.EC_Geographic_Scope')]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="gmd:descriptiveKeywords[not(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Data_Usage_Scope' or
                                                                   gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Information_Category' or
                                                                   gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Content_Scope' or
                                                                   gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Waf' or
                                                                   gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.place.EC_Geographic_Scope')]" />
        </xsl:otherwise>
      </xsl:choose>


      <xsl:for-each select="$replacements/replacements/replacement[field = $fieldId]">
        <xsl:variable name="searchValueE" select="tokenize(searchValue,':;:')[1]" />
        <xsl:variable name="searchValueF" select="tokenize(searchValue,':;:')[2]" />
        <xsl:variable name="searchType" select="tokenize(searchValue,':;:')[3]" />

        <xsl:if test="not(string($searchValueE)) and not(string($searchValueF)) and not(string($searchType))">
          <xsl:variable name="replaceValueE" select="tokenize(replaceValue,':;:')[1]" />
          <xsl:variable name="replaceValueF" select="tokenize(replaceValue,':;:')[2]" />
          <xsl:variable name="replaceType" select="tokenize(replaceValue,':;:')[3]" />

          <xsl:variable name="mainValue">
            <xsl:choose>
              <xsl:when test="$mainLanguage = 'eng'"><xsl:value-of select="$replaceValueE" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="$replaceValueF" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="altValue">
            <xsl:choose>
              <xsl:when test="$mainLanguage = 'eng'"><xsl:value-of select="$replaceValueF" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="$replaceValueE" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <gmd:descriptiveKeywords>
            <gmd:MD_Keywords>
              <gmd:keyword xsi:type="gmd:PT_FreeText_PropertyType">
                <gco:CharacterString>
                  <xsl:attribute name="geonet:change" select="$fieldId" />
                  <xsl:attribute name="geonet:original" select="''" />
                  <xsl:attribute name="geonet:new" select="$mainValue" />

                  <xsl:value-of select="$mainValue" />
                </gco:CharacterString>
                <gmd:PT_FreeText>
                  <gmd:textGroup>
                    <gmd:LocalisedCharacterString locale="{$localeLang}">
                      <xsl:attribute name="geonet:change" select="$fieldId" />
                      <xsl:attribute name="geonet:original" select="''" />
                      <xsl:attribute name="geonet:new" select="$altValue" />

                      <xsl:value-of select="$altValue" /></gmd:LocalisedCharacterString>
                  </gmd:textGroup>
                </gmd:PT_FreeText>
              </gmd:keyword>
              <gmd:type>
                <gmd:MD_KeywordTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="{$replaceType}">
                  <xsl:attribute name="geonet:change" select="$fieldId" />
                  <xsl:attribute name="geonet:original" select="''" />
                  <xsl:attribute name="geonet:new" select="$replaceType" />
                </gmd:MD_KeywordTypeCode>
              </gmd:type>
              <gmd:thesaurusName>
                <gmd:CI_Citation>
                  <gmd:title gco:nilReason="missing">
                    <gco:CharacterString/>
                  </gmd:title>
                  <gmd:date>
                    <gmd:CI_Date>
                      <gmd:date>
                        <gco:Date/>
                      </gmd:date>
                      <gmd:dateType>
                        <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication"/>
                      </gmd:dateType>
                    </gmd:CI_Date>
                  </gmd:date>
                  <gmd:citedResponsibleParty/>
                </gmd:CI_Citation>
              </gmd:thesaurusName>
            </gmd:MD_Keywords>
          </gmd:descriptiveKeywords>
        </xsl:if>
      </xsl:for-each>

      <!-- process the existing keywords (not related to EC vocabularies) -->
      <!--<xsl:apply-templates select="gmd:descriptiveKeywords[not(string(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/@id))]" />-->

      <!-- Info category -->
      <xsl:variable name="fieldIdIC" select="'id.corporate.infocategory'" />

      <xsl:choose>
        <!-- If status added, but also an empty gmd:status, don't copy the empty in the result -->
        <xsl:when test="$replacements/replacements/replacement[field = $fieldIdIC and not(string(searchValue))]">
          <xsl:apply-templates select="gmd:descriptiveKeywords[string(gmd:MD_Keywords/gmd:keyword/gco:CharacterString) and (gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Information_Category' or gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Information_Category')]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Information_Category' or gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Information_Category']" />
        </xsl:otherwise>
      </xsl:choose>

      <xsl:for-each select="$replacements/replacements/replacement[field = $fieldIdIC]">
        <xsl:if test="not(string(searchValue))">
          <xsl:variable name="replaceValueE" select="tokenize(replaceValue,':;:')[1]" />
          <xsl:variable name="replaceValueF" select="tokenize(replaceValue,':;:')[2]" />

          <xsl:variable name="mainValue">
            <xsl:choose>
              <xsl:when test="$mainLanguage = 'eng'"><xsl:value-of select="$replaceValueE" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="$replaceValueF" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="altValue">
            <xsl:choose>
              <xsl:when test="$mainLanguage = 'eng'"><xsl:value-of select="$replaceValueF" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="$replaceValueE" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <gmd:descriptiveKeywords>
            <gmd:MD_Keywords>
              <gmd:keyword>
                <xsl:attribute name="geonet:change" select="$fieldIdIC" />
                <xsl:attribute name="geonet:original" select="''" />
                <xsl:attribute name="geonet:new" select="$mainValue" />

                <gco:CharacterString><xsl:value-of select="$mainValue" /></gco:CharacterString>
                <gmd:PT_FreeText>
                  <gmd:textGroup>
                    <gmd:LocalisedCharacterString locale="{$localeLang}">
                      <xsl:attribute name="geonet:change" select="$fieldIdIC" />
                      <xsl:attribute name="geonet:original" select="''" />
                      <xsl:attribute name="geonet:new" select="$altValue" />

                      <xsl:value-of select="$altValue" /></gmd:LocalisedCharacterString>
                  </gmd:textGroup>
                </gmd:PT_FreeText>
              </gmd:keyword>
              <gmd:type>
                <gmd:MD_KeywordTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="theme"/>
              </gmd:type>
              <gmd:thesaurusName>
                <gmd:CI_Citation>
                  <gmd:title>
                    <gco:CharacterString>local.theme.EC_Information_Category</gco:CharacterString>
                  </gmd:title>
                  <gmd:date>
                    <gmd:CI_Date>
                      <gmd:date>
                        <gco:Date>2012-05-25</gco:Date>
                      </gmd:date>
                      <gmd:dateType>
                        <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication"/>
                      </gmd:dateType>
                    </gmd:CI_Date>
                  </gmd:date>
                  <gmd:citedResponsibleParty/>
                </gmd:CI_Citation>
              </gmd:thesaurusName>
            </gmd:MD_Keywords>
          </gmd:descriptiveKeywords>
        </xsl:if>
      </xsl:for-each>


      <!-- Geography -->
      <xsl:variable name="fieldIdGeo" select="'id.corporate.geography'" />

      <xsl:choose>
        <xsl:when test="$replacements/replacements/replacement[field = $fieldIdGeo and not(string(searchValue))]">
          <xsl:apply-templates select="gmd:descriptiveKeywords[string(gmd:MD_Keywords/gmd:keyword/gco:CharacterString) and (gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/@id = 'local.place.EC_Geographic_Scope' or gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.place.EC_Geographic_Scope')]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/@id = 'local.place.EC_Geographic_Scope' or gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.place.EC_Geographic_Scope']" />
        </xsl:otherwise>
      </xsl:choose>

      <xsl:for-each select="$replacements/replacements/replacement[field = $fieldIdGeo]">
        <xsl:if test="not(string(searchValue))">
          <xsl:variable name="replaceValueE" select="tokenize(replaceValue,':;:')[1]" />
          <xsl:variable name="replaceValueF" select="tokenize(replaceValue,':;:')[2]" />

          <xsl:variable name="mainValue">
            <xsl:choose>
              <xsl:when test="$mainLanguage = 'eng'"><xsl:value-of select="$replaceValueE" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="$replaceValueF" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="altValue">
            <xsl:choose>
              <xsl:when test="$mainLanguage = 'eng'"><xsl:value-of select="$replaceValueF" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="$replaceValueE" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <gmd:descriptiveKeywords>
            <gmd:MD_Keywords>
              <gmd:keyword>
                <xsl:attribute name="geonet:change" select="$fieldIdGeo" />
                <xsl:attribute name="geonet:original" select="''" />
                <xsl:attribute name="geonet:new" select="$mainValue" />

                <gco:CharacterString><xsl:value-of select="$mainValue" /></gco:CharacterString>
                <gmd:PT_FreeText>
                  <gmd:textGroup>
                    <gmd:LocalisedCharacterString locale="{$localeLang}">
                      <xsl:attribute name="geonet:change" select="$fieldIdGeo" />
                      <xsl:attribute name="geonet:original" select="''" />
                      <xsl:attribute name="geonet:new" select="$altValue" />

                      <xsl:value-of select="$altValue" /></gmd:LocalisedCharacterString>
                  </gmd:textGroup>
                </gmd:PT_FreeText>
              </gmd:keyword>
              <gmd:type>
                <gmd:MD_KeywordTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="theme"/>
              </gmd:type>
              <gmd:thesaurusName>
                <gmd:CI_Citation>
                  <gmd:title>
                    <gco:CharacterString>local.place.EC_Geographic_Scope</gco:CharacterString>
                  </gmd:title>
                  <gmd:date>
                    <gmd:CI_Date>
                      <gmd:date>
                        <gco:Date>2012-05-25</gco:Date>
                      </gmd:date>
                      <gmd:dateType>
                        <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication"/>
                      </gmd:dateType>
                    </gmd:CI_Date>
                  </gmd:date>
                  <gmd:citedResponsibleParty/>
                </gmd:CI_Citation>
              </gmd:thesaurusName>
            </gmd:MD_Keywords>
          </gmd:descriptiveKeywords>
        </xsl:if>
      </xsl:for-each>


      <!-- Function -->
      <xsl:variable name="fieldIdFun" select="'id.corporate.function'" />

      <xsl:choose>
        <!-- If status added, but also an empty gmd:status, don't copy the empty in the result -->
        <xsl:when test="$replacements/replacements/replacement[field = $fieldIdFun and not(string(searchValue))]">
          <xsl:apply-templates select="gmd:descriptiveKeywords[string(gmd:MD_Keywords/gmd:keyword/gco:CharacterString) and (gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Data_Usage_Scope' or gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Data_Usage_Scope')]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Data_Usage_Scope' or gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Data_Usage_Scope']" />

        </xsl:otherwise>
      </xsl:choose>

      <xsl:for-each select="$replacements/replacements/replacement[field = $fieldIdFun]">
        <xsl:if test="not(string(searchValue))">
          <xsl:variable name="replaceValueE" select="tokenize(replaceValue,':;:')[1]" />
          <xsl:variable name="replaceValueF" select="tokenize(replaceValue,':;:')[2]" />

          <xsl:variable name="mainValue">
            <xsl:choose>
              <xsl:when test="$mainLanguage = 'eng'"><xsl:value-of select="$replaceValueE" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="$replaceValueF" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="altValue">
            <xsl:choose>
              <xsl:when test="$mainLanguage = 'eng'"><xsl:value-of select="$replaceValueF" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="$replaceValueE" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <gmd:descriptiveKeywords>
            <gmd:MD_Keywords>
              <gmd:keyword>
                <xsl:attribute name="geonet:change" select="$fieldIdFun" />
                <xsl:attribute name="geonet:original" select="''" />
                <xsl:attribute name="geonet:new" select="$mainValue" />

                <gco:CharacterString><xsl:value-of select="$mainValue" /></gco:CharacterString>
                <gmd:PT_FreeText>
                  <gmd:textGroup>
                    <gmd:LocalisedCharacterString locale="{$localeLang}">
                      <xsl:attribute name="geonet:change" select="$fieldIdFun" />
                      <xsl:attribute name="geonet:original" select="''" />
                      <xsl:attribute name="geonet:new" select="$altValue" />

                      <xsl:value-of select="$altValue" /></gmd:LocalisedCharacterString>
                  </gmd:textGroup>
                </gmd:PT_FreeText>
              </gmd:keyword>
              <gmd:type>
                <gmd:MD_KeywordTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="theme"/>
              </gmd:type>
              <gmd:thesaurusName>
                <gmd:CI_Citation id="local.theme.EC_Data_Usage_Scope">
                  <gmd:title>
                    <gco:CharacterString>local.theme.EC_Data_Usage_Scope</gco:CharacterString>
                  </gmd:title>
                  <gmd:date>
                    <gmd:CI_Date>
                      <gmd:date>
                        <gco:Date>2012-05-25</gco:Date>
                      </gmd:date>
                      <gmd:dateType>
                        <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication"/>
                      </gmd:dateType>
                    </gmd:CI_Date>
                  </gmd:date>
                  <gmd:citedResponsibleParty/>
                </gmd:CI_Citation>
              </gmd:thesaurusName>
            </gmd:MD_Keywords>
          </gmd:descriptiveKeywords>
        </xsl:if>
      </xsl:for-each>


      <!-- Content -->
      <xsl:variable name="fieldIdCon" select="'id.corporate.content'" />

      <xsl:choose>
        <!-- If status added, but also an empty gmd:status, don't copy the empty in the result -->
        <xsl:when test="$replacements/replacements/replacement[field = $fieldIdCon and not(string(searchValue))]">
          <xsl:apply-templates select="gmd:descriptiveKeywords[string(gmd:MD_Keywords/gmd:keyword/gco:CharacterString) and (gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Content_Scope' or gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Content_Scope')]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Content_Scope' or gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Content_Scope']" />
        </xsl:otherwise>
      </xsl:choose>

      <xsl:for-each select="$replacements/replacements/replacement[field = $fieldIdCon]">
        <xsl:if test="not(string(searchValue))">
          <xsl:variable name="replaceValueE" select="tokenize(replaceValue,':;:')[1]" />
          <xsl:variable name="replaceValueF" select="tokenize(replaceValue,':;:')[2]" />

          <xsl:variable name="mainValue">
            <xsl:choose>
              <xsl:when test="$mainLanguage = 'eng'"><xsl:value-of select="$replaceValueE" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="$replaceValueF" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="altValue">
            <xsl:choose>
              <xsl:when test="$mainLanguage = 'eng'"><xsl:value-of select="$replaceValueF" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="$replaceValueE" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <gmd:descriptiveKeywords>
            <gmd:MD_Keywords>
              <gmd:keyword>
                <xsl:attribute name="geonet:change" select="$fieldIdCon" />
                <xsl:attribute name="geonet:original" select="''" />
                <xsl:attribute name="geonet:new" select="$mainValue" />

                <gco:CharacterString><xsl:value-of select="$mainValue" /></gco:CharacterString>
                <gmd:PT_FreeText>
                  <gmd:textGroup>
                    <gmd:LocalisedCharacterString locale="{$localeLang}">
                      <xsl:attribute name="geonet:change" select="$fieldIdCon" />
                      <xsl:attribute name="geonet:original" select="''" />
                      <xsl:attribute name="geonet:new" select="$altValue" />

                      <xsl:value-of select="$altValue" /></gmd:LocalisedCharacterString>
                  </gmd:textGroup>
                </gmd:PT_FreeText>
              </gmd:keyword>
              <gmd:type>
                <gmd:MD_KeywordTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="theme"/>
              </gmd:type>
              <gmd:thesaurusName>
                <gmd:CI_Citation>
                  <gmd:title>
                    <gco:CharacterString>local.theme.EC_Content_Scope</gco:CharacterString>
                  </gmd:title>
                  <gmd:date>
                    <gmd:CI_Date>
                      <gmd:date>
                        <gco:Date>2012-05-25</gco:Date>
                      </gmd:date>
                      <gmd:dateType>
                        <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication"/>
                      </gmd:dateType>
                    </gmd:CI_Date>
                  </gmd:date>
                  <gmd:citedResponsibleParty/>
                </gmd:CI_Citation>
              </gmd:thesaurusName>
            </gmd:MD_Keywords>
          </gmd:descriptiveKeywords>
        </xsl:if>
      </xsl:for-each>


      <!-- process the existing keywords (related to EC vocabularies) -->
      <!--<xsl:apply-templates select="gmd:descriptiveKeywords[string(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/@id)]" />-->



      <xsl:apply-templates select="gmd:resourceSpecificUsage" />
      <xsl:apply-templates select="gmd:resourceConstraints" />
      <xsl:apply-templates select="gmd:aggregationInfo" />
      <xsl:apply-templates select="gmd:spatialRepresentationType" />
      <xsl:apply-templates select="gmd:spatialResolution" />
      <xsl:apply-templates select="gmd:language" />
      <xsl:apply-templates select="gmd:characterSet" />


      <!--<xsl:apply-templates select="gmd:topicCategory" />-->
      <xsl:variable name="fieldIdTc" select="'id.dataid.topiccategory'" />
      <xsl:choose>
        <!-- If status added, but also an empty gmd:status, don't copy the empty in the result -->
        <xsl:when test="$replacements/replacements/replacement[field = $fieldIdTc and not(string(searchValue))]">
          <xsl:apply-templates select="gmd:topicCategory[string(gmd:MD_TopicCategoryCode)]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="gmd:topicCategory" />
        </xsl:otherwise>
      </xsl:choose>

      <!-- Add new topic category -->

      <xsl:for-each select="$replacements/replacements/replacement[field = $fieldIdTc]">
        <xsl:if test="not(string(searchValue))">
          <gmd:topicCategory>
            <gmd:MD_TopicCategoryCode>
              <xsl:attribute name="geonet:change" select="'id.dataid.topiccategory'" />
              <xsl:attribute name="geonet:original" select="''" />
              <xsl:attribute name="geonet:new" select="replaceValue" />
              <xsl:value-of select="replaceValue" />
            </gmd:MD_TopicCategoryCode>
          </gmd:topicCategory>
        </xsl:if>
      </xsl:for-each>

      <xsl:apply-templates select="gmd:environmentDescription" />
      <xsl:apply-templates select="gmd:extent" />
      <xsl:apply-templates select="gmd:supplementalInformation" />
      <xsl:apply-templates select="napec:EC_CorporateInfo" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/napec:SV_ServiceIdentification">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates select="gmd:citation" />
      <xsl:apply-templates select="gmd:abstract" />
      <xsl:apply-templates select="gmd:purpose" />
      <xsl:apply-templates select="gmd:credit" />

      <!--<xsl:apply-templates select="gmd:status" />-->
      <xsl:variable name="fieldIdSt" select="'id.dataid.status'" />
      <xsl:choose>
        <!-- If status added, but also an empty gmd:status, don't copy the empty in the result -->
        <xsl:when test="$replacements/replacements/replacement[field = $fieldIdSt and not(string(searchValue))]">
          <xsl:apply-templates select="gmd:status[string(gmd:MD_ProgressCode/@codeListValue)]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="gmd:status" />
        </xsl:otherwise>
      </xsl:choose>

      <!-- Add new status -->

      <xsl:for-each select="$replacements/replacements/replacement[field = $fieldIdSt]">
        <xsl:if test="not(string(searchValue))">
          <gmd:status>
            <gmd:MD_ProgressCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_ProgressCode" codeListValue="{replaceValue}">
              <xsl:attribute name="geonet:change" select="'id.dataid.status'" />
              <xsl:attribute name="geonet:original" select="''" />
              <xsl:attribute name="geonet:new" select="replaceValue" />
            </gmd:MD_ProgressCode>
          </gmd:status>
        </xsl:if>
      </xsl:for-each>


      <xsl:apply-templates select="gmd:pointOfContact" />
      <xsl:apply-templates select="gmd:resourceMaintenance" />
      <xsl:apply-templates select="gmd:graphicOverview" />
      <xsl:apply-templates select="gmd:resourceFormat" />

      <!-- add the new keywords -->
      <xsl:variable name="fieldId" select="'id.keywords.keyword'" />

      <xsl:choose>
        <!-- If status added, but also an empty gmd:status, don't copy the empty in the result -->
        <xsl:when test="$replacements/replacements/replacement[field = $fieldId and searchValue = ':;::;:']">
          <xsl:apply-templates select="gmd:descriptiveKeywords[string(gmd:MD_Keywords/gmd:keyword/gco:CharacterString) and not(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Data_Usage_Scope' or
                                                                   gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Information_Category' or
                                                                   gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Content_Scope' or
                                                                   gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Waf' or
                                                                   gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.place.EC_Geographic_Scope')]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="gmd:descriptiveKeywords[not(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Data_Usage_Scope' or
                                                                   gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Information_Category' or
                                                                   gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Content_Scope' or
                                                                   gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Waf' or
                                                                   gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.place.EC_Geographic_Scope')]" />
        </xsl:otherwise>
      </xsl:choose>


      <xsl:for-each select="$replacements/replacements/replacement[field = $fieldId]">
        <xsl:variable name="searchValueE" select="tokenize(searchValue,':;:')[1]" />
        <xsl:variable name="searchValueF" select="tokenize(searchValue,':;:')[2]" />
        <xsl:variable name="searchType" select="tokenize(searchValue,':;:')[3]" />

        <xsl:if test="not(string($searchValueE)) and not(string($searchValueF)) and not(string($searchType))">
          <xsl:variable name="replaceValueE" select="tokenize(replaceValue,':;:')[1]" />
          <xsl:variable name="replaceValueF" select="tokenize(replaceValue,':;:')[2]" />
          <xsl:variable name="replaceType" select="tokenize(replaceValue,':;:')[3]" />

          <xsl:variable name="mainValue">
            <xsl:choose>
              <xsl:when test="$mainLanguage = 'eng'"><xsl:value-of select="$replaceValueE" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="$replaceValueF" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="altValue">
            <xsl:choose>
              <xsl:when test="$mainLanguage = 'eng'"><xsl:value-of select="$replaceValueF" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="$replaceValueE" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <gmd:descriptiveKeywords>
            <gmd:MD_Keywords>
              <gmd:keyword xsi:type="gmd:PT_FreeText_PropertyType">
                <gco:CharacterString>
                  <xsl:attribute name="geonet:change" select="$fieldId" />
                  <xsl:attribute name="geonet:original" select="''" />
                  <xsl:attribute name="geonet:new" select="$mainValue" />

                  <xsl:value-of select="$mainValue" />
                </gco:CharacterString>
                <gmd:PT_FreeText>
                  <gmd:textGroup>
                    <gmd:LocalisedCharacterString locale="{$localeLang}">
                      <xsl:attribute name="geonet:change" select="$fieldId" />
                      <xsl:attribute name="geonet:original" select="''" />
                      <xsl:attribute name="geonet:new" select="$altValue" />

                      <xsl:value-of select="$altValue" /></gmd:LocalisedCharacterString>
                  </gmd:textGroup>
                </gmd:PT_FreeText>
              </gmd:keyword>
              <gmd:type>
                <gmd:MD_KeywordTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="{$replaceType}">
                  <xsl:attribute name="geonet:change" select="$fieldId" />
                  <xsl:attribute name="geonet:original" select="''" />
                  <xsl:attribute name="geonet:new" select="$replaceType" />
                </gmd:MD_KeywordTypeCode>
              </gmd:type>
              <gmd:thesaurusName>
                <gmd:CI_Citation>
                  <gmd:title gco:nilReason="missing">
                    <gco:CharacterString/>
                  </gmd:title>
                  <gmd:date>
                    <gmd:CI_Date>
                      <gmd:date>
                        <gco:Date/>
                      </gmd:date>
                      <gmd:dateType>
                        <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication"/>
                      </gmd:dateType>
                    </gmd:CI_Date>
                  </gmd:date>
                  <gmd:citedResponsibleParty/>
                </gmd:CI_Citation>
              </gmd:thesaurusName>
            </gmd:MD_Keywords>
          </gmd:descriptiveKeywords>
        </xsl:if>
      </xsl:for-each>

      <!-- process the existing keywords (not related to EC vocabularies) -->
      <!--<xsl:apply-templates select="gmd:descriptiveKeywords[not(string(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/@id))]" />-->

      <!-- Info category -->
      <xsl:variable name="fieldIdIC" select="'id.corporate.infocategory'" />

      <xsl:choose>
        <!-- If status added, but also an empty gmd:status, don't copy the empty in the result -->
        <xsl:when test="$replacements/replacements/replacement[field = $fieldIdIC and not(string(searchValue))]">
          <xsl:apply-templates select="gmd:descriptiveKeywords[string(gmd:MD_Keywords/gmd:keyword/gco:CharacterString) and (gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Information_Category' or gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Information_Category')]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Information_Category' or gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Information_Category']" />
        </xsl:otherwise>
      </xsl:choose>

      <xsl:for-each select="$replacements/replacements/replacement[field = $fieldIdIC]">
        <xsl:if test="not(string(searchValue))">
          <xsl:variable name="replaceValueE" select="tokenize(replaceValue,':;:')[1]" />
          <xsl:variable name="replaceValueF" select="tokenize(replaceValue,':;:')[2]" />

          <xsl:variable name="mainValue">
            <xsl:choose>
              <xsl:when test="$mainLanguage = 'eng'"><xsl:value-of select="$replaceValueE" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="$replaceValueF" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="altValue">
            <xsl:choose>
              <xsl:when test="$mainLanguage = 'eng'"><xsl:value-of select="$replaceValueF" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="$replaceValueE" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <gmd:descriptiveKeywords>
            <gmd:MD_Keywords>
              <gmd:keyword>
                <xsl:attribute name="geonet:change" select="$fieldIdIC" />
                <xsl:attribute name="geonet:original" select="''" />
                <xsl:attribute name="geonet:new" select="$mainValue" />

                <gco:CharacterString><xsl:value-of select="$mainValue" /></gco:CharacterString>
                <gmd:PT_FreeText>
                  <gmd:textGroup>
                    <gmd:LocalisedCharacterString locale="{$localeLang}">
                      <xsl:attribute name="geonet:change" select="$fieldIdIC" />
                      <xsl:attribute name="geonet:original" select="''" />
                      <xsl:attribute name="geonet:new" select="$altValue" />

                      <xsl:value-of select="$altValue" /></gmd:LocalisedCharacterString>
                  </gmd:textGroup>
                </gmd:PT_FreeText>
              </gmd:keyword>
              <gmd:type>
                <gmd:MD_KeywordTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="theme"/>
              </gmd:type>
              <gmd:thesaurusName>
                <gmd:CI_Citation>
                  <gmd:title>
                    <gco:CharacterString>local.theme.EC_Information_Category</gco:CharacterString>
                  </gmd:title>
                  <gmd:date>
                    <gmd:CI_Date>
                      <gmd:date>
                        <gco:Date>2012-05-25</gco:Date>
                      </gmd:date>
                      <gmd:dateType>
                        <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication"/>
                      </gmd:dateType>
                    </gmd:CI_Date>
                  </gmd:date>
                  <gmd:citedResponsibleParty/>
                </gmd:CI_Citation>
              </gmd:thesaurusName>
            </gmd:MD_Keywords>
          </gmd:descriptiveKeywords>
        </xsl:if>
      </xsl:for-each>


      <!-- Geography -->
      <xsl:variable name="fieldIdGeo" select="'id.corporate.geography'" />

      <xsl:choose>
        <xsl:when test="$replacements/replacements/replacement[field = $fieldIdGeo and not(string(searchValue))]">
          <xsl:apply-templates select="gmd:descriptiveKeywords[string(gmd:MD_Keywords/gmd:keyword/gco:CharacterString) and (gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/@id = 'local.place.EC_Geographic_Scope' or gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.place.EC_Geographic_Scope')]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/@id = 'local.place.EC_Geographic_Scope' or gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.place.EC_Geographic_Scope']" />
        </xsl:otherwise>
      </xsl:choose>

      <xsl:for-each select="$replacements/replacements/replacement[field = $fieldIdGeo]">
        <xsl:if test="not(string(searchValue))">
          <xsl:variable name="replaceValueE" select="tokenize(replaceValue,':;:')[1]" />
          <xsl:variable name="replaceValueF" select="tokenize(replaceValue,':;:')[2]" />

          <xsl:variable name="mainValue">
            <xsl:choose>
              <xsl:when test="$mainLanguage = 'eng'"><xsl:value-of select="$replaceValueE" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="$replaceValueF" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="altValue">
            <xsl:choose>
              <xsl:when test="$mainLanguage = 'eng'"><xsl:value-of select="$replaceValueF" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="$replaceValueE" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <gmd:descriptiveKeywords>
            <gmd:MD_Keywords>
              <gmd:keyword>
                <xsl:attribute name="geonet:change" select="$fieldIdGeo" />
                <xsl:attribute name="geonet:original" select="''" />
                <xsl:attribute name="geonet:new" select="$mainValue" />

                <gco:CharacterString><xsl:value-of select="$mainValue" /></gco:CharacterString>
                <gmd:PT_FreeText>
                  <gmd:textGroup>
                    <gmd:LocalisedCharacterString locale="{$localeLang}">
                      <xsl:attribute name="geonet:change" select="$fieldIdGeo" />
                      <xsl:attribute name="geonet:original" select="''" />
                      <xsl:attribute name="geonet:new" select="$altValue" />

                      <xsl:value-of select="$altValue" /></gmd:LocalisedCharacterString>
                  </gmd:textGroup>
                </gmd:PT_FreeText>
              </gmd:keyword>
              <gmd:type>
                <gmd:MD_KeywordTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="theme"/>
              </gmd:type>
              <gmd:thesaurusName>
                <gmd:CI_Citation>
                  <gmd:title>
                    <gco:CharacterString>local.place.EC_Geographic_Scope</gco:CharacterString>
                  </gmd:title>
                  <gmd:date>
                    <gmd:CI_Date>
                      <gmd:date>
                        <gco:Date>2012-05-25</gco:Date>
                      </gmd:date>
                      <gmd:dateType>
                        <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication"/>
                      </gmd:dateType>
                    </gmd:CI_Date>
                  </gmd:date>
                  <gmd:citedResponsibleParty/>
                </gmd:CI_Citation>
              </gmd:thesaurusName>
            </gmd:MD_Keywords>
          </gmd:descriptiveKeywords>
        </xsl:if>
      </xsl:for-each>


      <!-- Function -->
      <xsl:variable name="fieldIdFun" select="'id.corporate.function'" />

      <xsl:choose>
        <!-- If status added, but also an empty gmd:status, don't copy the empty in the result -->
        <xsl:when test="$replacements/replacements/replacement[field = $fieldIdFun and not(string(searchValue))]">
          <xsl:apply-templates select="gmd:descriptiveKeywords[string(gmd:MD_Keywords/gmd:keyword/gco:CharacterString) and (gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Data_Usage_Scope' or gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Data_Usage_Scope')]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Data_Usage_Scope' or gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Data_Usage_Scope']" />

        </xsl:otherwise>
      </xsl:choose>

      <xsl:for-each select="$replacements/replacements/replacement[field = $fieldIdFun]">
        <xsl:if test="not(string(searchValue))">
          <xsl:variable name="replaceValueE" select="tokenize(replaceValue,':;:')[1]" />
          <xsl:variable name="replaceValueF" select="tokenize(replaceValue,':;:')[2]" />

          <xsl:variable name="mainValue">
            <xsl:choose>
              <xsl:when test="$mainLanguage = 'eng'"><xsl:value-of select="$replaceValueE" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="$replaceValueF" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="altValue">
            <xsl:choose>
              <xsl:when test="$mainLanguage = 'eng'"><xsl:value-of select="$replaceValueF" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="$replaceValueE" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <gmd:descriptiveKeywords>
            <gmd:MD_Keywords>
              <gmd:keyword>
                <xsl:attribute name="geonet:change" select="$fieldIdFun" />
                <xsl:attribute name="geonet:original" select="''" />
                <xsl:attribute name="geonet:new" select="$mainValue" />

                <gco:CharacterString><xsl:value-of select="$mainValue" /></gco:CharacterString>
                <gmd:PT_FreeText>
                  <gmd:textGroup>
                    <gmd:LocalisedCharacterString locale="{$localeLang}">
                      <xsl:attribute name="geonet:change" select="$fieldIdFun" />
                      <xsl:attribute name="geonet:original" select="''" />
                      <xsl:attribute name="geonet:new" select="$altValue" />

                      <xsl:value-of select="$altValue" /></gmd:LocalisedCharacterString>
                  </gmd:textGroup>
                </gmd:PT_FreeText>
              </gmd:keyword>
              <gmd:type>
                <gmd:MD_KeywordTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="theme"/>
              </gmd:type>
              <gmd:thesaurusName>
                <gmd:CI_Citation id="local.theme.EC_Data_Usage_Scope">
                  <gmd:title>
                    <gco:CharacterString>local.theme.EC_Data_Usage_Scope</gco:CharacterString>
                  </gmd:title>
                  <gmd:date>
                    <gmd:CI_Date>
                      <gmd:date>
                        <gco:Date>2012-05-25</gco:Date>
                      </gmd:date>
                      <gmd:dateType>
                        <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication"/>
                      </gmd:dateType>
                    </gmd:CI_Date>
                  </gmd:date>
                  <gmd:citedResponsibleParty/>
                </gmd:CI_Citation>
              </gmd:thesaurusName>
            </gmd:MD_Keywords>
          </gmd:descriptiveKeywords>
        </xsl:if>
      </xsl:for-each>


      <!-- Content -->
      <xsl:variable name="fieldIdCon" select="'id.corporate.content'" />

      <xsl:choose>
        <!-- If status added, but also an empty gmd:status, don't copy the empty in the result -->
        <xsl:when test="$replacements/replacements/replacement[field = $fieldIdCon and not(string(searchValue))]">
          <xsl:apply-templates select="gmd:descriptiveKeywords[string(gmd:MD_Keywords/gmd:keyword/gco:CharacterString) and (gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Content_Scope' or gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Content_Scope')]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Content_Scope' or gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Content_Scope']" />
        </xsl:otherwise>
      </xsl:choose>

      <xsl:for-each select="$replacements/replacements/replacement[field = $fieldIdCon]">
        <xsl:if test="not(string(searchValue))">
          <xsl:variable name="replaceValueE" select="tokenize(replaceValue,':;:')[1]" />
          <xsl:variable name="replaceValueF" select="tokenize(replaceValue,':;:')[2]" />

          <xsl:variable name="mainValue">
            <xsl:choose>
              <xsl:when test="$mainLanguage = 'eng'"><xsl:value-of select="$replaceValueE" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="$replaceValueF" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="altValue">
            <xsl:choose>
              <xsl:when test="$mainLanguage = 'eng'"><xsl:value-of select="$replaceValueF" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="$replaceValueE" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <gmd:descriptiveKeywords>
            <gmd:MD_Keywords>
              <gmd:keyword>
                <xsl:attribute name="geonet:change" select="$fieldIdCon" />
                <xsl:attribute name="geonet:original" select="''" />
                <xsl:attribute name="geonet:new" select="$mainValue" />

                <gco:CharacterString><xsl:value-of select="$mainValue" /></gco:CharacterString>
                <gmd:PT_FreeText>
                  <gmd:textGroup>
                    <gmd:LocalisedCharacterString locale="{$localeLang}">
                      <xsl:attribute name="geonet:change" select="$fieldIdCon" />
                      <xsl:attribute name="geonet:original" select="''" />
                      <xsl:attribute name="geonet:new" select="$altValue" />

                      <xsl:value-of select="$altValue" /></gmd:LocalisedCharacterString>
                  </gmd:textGroup>
                </gmd:PT_FreeText>
              </gmd:keyword>
              <gmd:type>
                <gmd:MD_KeywordTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="theme"/>
              </gmd:type>
              <gmd:thesaurusName>
                <gmd:CI_Citation>
                  <gmd:title>
                    <gco:CharacterString>local.theme.EC_Content_Scope</gco:CharacterString>
                  </gmd:title>
                  <gmd:date>
                    <gmd:CI_Date>
                      <gmd:date>
                        <gco:Date>2012-05-25</gco:Date>
                      </gmd:date>
                      <gmd:dateType>
                        <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication"/>
                      </gmd:dateType>
                    </gmd:CI_Date>
                  </gmd:date>
                  <gmd:citedResponsibleParty/>
                </gmd:CI_Citation>
              </gmd:thesaurusName>
            </gmd:MD_Keywords>
          </gmd:descriptiveKeywords>
        </xsl:if>
      </xsl:for-each>


      <!-- process the existing keywords (related to EC vocabularies) -->
      <!--<xsl:apply-templates select="gmd:descriptiveKeywords[string(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/@id)]" />-->

      <xsl:apply-templates select="gmd:resourceSpecificUsage" />
      <xsl:apply-templates select="gmd:resourceConstraints" />
      <xsl:apply-templates select="gmd:aggregationInfo" />

      <xsl:apply-templates select="srv:*" />

      <xsl:apply-templates select="napec:EC_CorporateInfo" />
    </xsl:copy>
  </xsl:template>

  <!-- KEYWORDS -->
  <xsl:template name="keywordPositionList">
    <xsl:param name="fieldId" />
    <xsl:param name="currentType" />
    <xsl:param name="i" />
    <xsl:param name="n" />

    <xsl:choose>
      <xsl:when test="$i &lt; $n+1">
        <xsl:variable name="searchValueE" select="tokenize($replacements/replacements/replacement[field = $fieldId][$i]/searchValue,':;:')[1]" />
        <xsl:variable name="searchValueF" select="tokenize($replacements/replacements/replacement[field = $fieldId][$i]/searchValue,':;:')[2]" />
        <xsl:variable name="searchType" select="tokenize($replacements/replacements/replacement[field = $fieldId][$i]/searchValue,':;:')[3]" />

        <xsl:choose>
          <!-- no search values, ignore the replacement: managed in previous template -->
          <xsl:when test="not(string($searchValueE)) and not(string($searchValueF)) and not(string($searchType))"></xsl:when>
          <xsl:otherwise>
            <xsl:if test="$currentType = $searchType or not(string($searchType))"><xsl:value-of select="$i" />:;:</xsl:if>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="keywordPositionList">
          <xsl:with-param name="fieldId" select="$fieldId"/>
          <xsl:with-param name="currentType" select="$currentType" />
          <xsl:with-param name="i" select="$i + 1"/>
          <xsl:with-param name="n" select="$n"/>
        </xsl:call-template>
      </xsl:when>

      <!-- End loop -->
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- keyword/keyword type -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords[not(gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Data_Usage_Scope' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Information_Category' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Waf' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Content_Scope' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.place.EC_Geographic_Scope')]
                       |gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:descriptiveKeywords/gmd:MD_Keywords[not(gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Data_Usage_Scope' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Information_Category' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Waf' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Content_Scope' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.place.EC_Geographic_Scope')]
                       |gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords[not(gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Data_Usage_Scope' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Information_Category' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Waf' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Content_Scope' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.place.EC_Geographic_Scope')]
                       |gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:descriptiveKeywords/gmd:MD_Keywords[not(gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Data_Usage_Scope' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Information_Category' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Waf' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.theme.EC_Content_Scope' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.place.EC_Geographic_Scope')]">
    <xsl:message>gmd:MD_Keywords</xsl:message>
    <xsl:variable name="fieldId" select="'id.keywords.keyword'" />
    <!--<xsl:variable name="searchType" select="tokenize($replacements/replacements/replacement[field = $fieldId]/searchValue,':;:')[3]" />
    <xsl:variable name="replaceType" select="tokenize($replacements/replacements/replacement[field = $fieldId]/replaceValue,':;:')[3]" />-->



    <xsl:variable name="positionsToCheck">
      <xsl:call-template name="keywordPositionList">
        <xsl:with-param name="fieldId" select="$fieldId"/>
        <xsl:with-param name="currentType" select="gmd:type/gmd:MD_KeywordTypeCode/@codeListValue" />
        <xsl:with-param name="i" select="1"/>
        <xsl:with-param name="n" select="count($replacements/replacements/replacement[field = $fieldId])"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="positionsToCheckList" select="tokenize(normalize-space($positionsToCheck), ':;:')" />

    <xsl:message>positionsToCheckList: <xsl:value-of select="$positionsToCheckList" /></xsl:message>
    <xsl:choose>
      <!-- If the keyword type is the same, process the replacement -->
      <xsl:when test="count($positionsToCheckList) > 1">

        <!--<xsl:when test="gmd:type/gmd:MD_KeywordTypeCode/@codeListValue = $searchType">-->
        <xsl:copy>
          <xsl:call-template name="replaceFieldMultilingualKeywords">
            <xsl:with-param name="fieldId">id.keywords.keyword</xsl:with-param>
            <xsl:with-param name="positions" select="normalize-space($positionsToCheck)" />
          </xsl:call-template>

          <!-- gmd:keyword -->
          <!--<xsl:for-each select="gmd:keyword">
              <xsl:call-template name="replaceFieldMultilingualKeywords">
                  <xsl:with-param name="fieldId">id.keywords.keyword</xsl:with-param>
                  <xsl:with-param name="positions" select="normalize-space($positionsToCheck)" />
              </xsl:call-template>
          </xsl:for-each>-->

          <!-- gmd:type -->
          <!--<xsl:variable name="newKeywordType">
              <xsl:call-template name="setValue">
                  <xsl:with-param name="actualVal" select="gmd:type/gmd:MD_KeywordTypeCode/@codeListValue" />
                  <xsl:with-param name="searchVal" select="$searchType" />
                  <xsl:with-param name="replaceVal" select="$replaceType" />
              </xsl:call-template>
          </xsl:variable>
          <gmd:type>
              <gmd:MD_KeywordTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="{$newKeywordType}"/>
          </gmd:type>-->
          <!--<xsl:apply-templates select="gmd:type" />-->

          <!-- gmd:thesaurusName -->
          <xsl:apply-templates select="gmd:thesaurusName" />
        </xsl:copy>
      </xsl:when>

      <xsl:otherwise>
        <xsl:copy>
          <xsl:copy-of select="@*" />
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:otherwise>

    </xsl:choose>

  </xsl:template>



  <!-- Extent -->
  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox|
                       gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/srv:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox">
    <xsl:variable name="fieldId">id.extent.coordinates</xsl:variable>

    <xsl:copy>
      <xsl:choose>
        <xsl:when test="$replacements/replacements/replacement[field = $fieldId]">
          <xsl:variable name="searchVal" select="$replacements/replacements/replacement[field = $fieldId]/searchValue" />
          <xsl:message>searchVal: <xsl:value-of select="$searchVal" /></xsl:message>
          <xsl:variable name="sW" select="tokenize($searchVal, ',')[1]"/>
          <xsl:variable name="sS" select="tokenize($searchVal, ',')[2]"/>
          <xsl:variable name="sN" select="tokenize($searchVal, ',')[3]"/>
          <xsl:variable name="sE" select="tokenize($searchVal, ',')[4]"/>

          <xsl:variable name="replaceVal" select="$replacements/replacements/replacement[field = $fieldId]/replaceValue" />
          <xsl:message>replaceVal: <xsl:value-of select="$replaceVal" /></xsl:message>
          <xsl:variable name="rW" select="tokenize($replaceVal, ',')[1]"/>
          <xsl:variable name="rS" select="tokenize($replaceVal, ',')[2]"/>
          <xsl:variable name="rN" select="tokenize($replaceVal, ',')[3]"/>
          <xsl:variable name="rE" select="tokenize($replaceVal, ',')[4]"/>

          <xsl:choose>
            <!-- No search value: replace OR Search extent is equal to current extent: replace -->
            <xsl:when test="(not(string($sW)) and not(string($sE)) and not(string($sS)) and not(string($sN))) or
              (gmd:westBoundLongitude/gco:Decimal = $sW and
                gmd:eastBoundLongitude/gco:Decimal = $sE and
                gmd:southBoundLatitude/gco:Decimal = $sS and gmd:northBoundLatitude/gco:Decimal = $sN)">
              <gmd:westBoundLongitude>
                <xsl:attribute name="geonet:change" select="$fieldId" />
                <xsl:attribute name="geonet:original" select="$searchVal" />
                <xsl:attribute name="geonet:new" select="$replaceVal" />
                <gco:Decimal>
                  <xsl:call-template name="setValue">
                    <xsl:with-param name="actualVal" select="gmd:westBoundLongitude/gco:Decimal" />
                    <xsl:with-param name="searchVal" select="$sW" />
                    <xsl:with-param name="replaceVal" select="$rW" />
                  </xsl:call-template>
                </gco:Decimal>
              </gmd:westBoundLongitude>
              <gmd:eastBoundLongitude>
                <gco:Decimal>
                  <xsl:call-template name="setValue">
                    <xsl:with-param name="actualVal" select="gmd:eastBoundLongitude/gco:Decimal" />
                    <xsl:with-param name="searchVal" select="$sE" />
                    <xsl:with-param name="replaceVal" select="$rE" />
                  </xsl:call-template>
                </gco:Decimal>
              </gmd:eastBoundLongitude>
              <gmd:southBoundLatitude>
                <gco:Decimal>
                  <xsl:call-template name="setValue">
                    <xsl:with-param name="actualVal" select="gmd:southBoundLatitude/gco:Decimal" />
                    <xsl:with-param name="searchVal" select="$sS" />
                    <xsl:with-param name="replaceVal" select="$rS" />
                  </xsl:call-template>
                </gco:Decimal>
              </gmd:southBoundLatitude>
              <gmd:northBoundLatitude>
                <gco:Decimal>
                  <xsl:call-template name="setValue">
                    <xsl:with-param name="actualVal" select="gmd:northBoundLatitude/gco:Decimal" />
                    <xsl:with-param name="searchVal" select="$sN" />
                    <xsl:with-param name="replaceVal" select="$rN" />
                  </xsl:call-template>
                </gco:Decimal>
              </gmd:northBoundLatitude>
            </xsl:when>

            <!-- No match: keep current extent -->
            <xsl:otherwise>
              <xsl:copy-of select="@*" />
              <xsl:apply-templates select="@*|node()"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>

        <xsl:otherwise>
          <xsl:copy-of select="@*" />
          <xsl:apply-templates select="@*|node()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <!-- Temporal extent -->
  <xsl:template name="temporalExtentPos">
    <xsl:param name="fieldId" />
    <xsl:param name="currentVal" />
    <xsl:param name="i" />
    <xsl:param name="n" />

    <xsl:choose>
      <xsl:when test="$i &lt; $n + 1">
        <xsl:choose>
          <xsl:when test="$currentVal = $replacements/replacements/replacement[field = $fieldId][$i]/searchValue or
            not(string($replacements/replacements/replacement[field = $fieldId][$i]/searchValue))"><xsl:value-of select="$i" /></xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="temporalExtentPos">
              <xsl:with-param name="fieldId" select="$fieldId" />
              <xsl:with-param name="currentVal" select="$currentVal" />
              <xsl:with-param name="i" select="$i + 1" />
              <xsl:with-param name="n" select="$n" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition">
    <xsl:message>gml:beginPosition</xsl:message>

    <xsl:call-template name="temporalExtentField">
      <xsl:with-param name="fieldId" select="'id.extent.begindate'" />

    </xsl:call-template>
  </xsl:template>

  <xsl:template match="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:endPosition|
                       gmd:MD_Metadata/gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:endPosition">
    <xsl:message>gml:endPosition</xsl:message>

    <xsl:call-template name="temporalExtentField">
      <xsl:with-param name="fieldId" select="'id.extent.enddate'" />

    </xsl:call-template>
  </xsl:template>

  <xsl:template name="temporalExtentField">
    <xsl:param name="fieldId" />

    <xsl:choose>
      <xsl:when test="$replacements/replacements/replacement[field = $fieldId]">

        <xsl:variable name="pos">
          <xsl:call-template name="temporalExtentPos">
            <xsl:with-param name="fieldId" select="$fieldId" />
            <xsl:with-param name="currentVal" select="."/>
            <xsl:with-param name="i" select="1"/>
            <xsl:with-param name="n" select="count($replacements/replacements/replacement[field = $fieldId])"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="string($pos)">
            <xsl:variable name="posN" select="number($pos)" />
            <xsl:variable name="searchVal" select="$replacements/replacements/replacement[field = $fieldId][$posN]/searchValue" />
            <xsl:message>searchVal: <xsl:value-of select="$searchVal" /></xsl:message>

            <xsl:variable name="replaceVal" select="$replacements/replacements/replacement[field = $fieldId][$posN]/replaceValue" />
            <xsl:message>replaceVal: <xsl:value-of select="$replaceVal" /></xsl:message>

            <xsl:variable name="value">
              <xsl:call-template name="setValue">
                <xsl:with-param name="actualVal" select="." />
                <xsl:with-param name="searchVal" select="$searchVal" />
                <xsl:with-param name="replaceVal" select="$replaceVal" />
              </xsl:call-template>
            </xsl:variable>

            <xsl:copy>
              <xsl:choose>
                <xsl:when test="not(string($value))"><xsl:copy-of select="@*" /></xsl:when>
                <xsl:otherwise><xsl:copy-of select="@*[not(name()='gco:nilReason')]" /></xsl:otherwise>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="$replacements/replacements/replacement[field = $fieldId]">

                  <xsl:copy>
                    <xsl:if test=".!= $value">
                      <xsl:attribute name="geonet:change" select="$fieldId" />
                      <xsl:attribute name="geonet:original" select="." />
                      <xsl:attribute name="geonet:new" select="$value" />
                    </xsl:if>
                    <xsl:value-of select="$value" />
                  </xsl:copy>
                </xsl:when>

                <xsl:otherwise>
                  <xsl:apply-templates select="@*|node()"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:copy>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy>
              <xsl:copy-of select="@*" />
              <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
          </xsl:otherwise>
        </xsl:choose>

      </xsl:when>

      <!-- no replacement -->
      <xsl:otherwise>
        <xsl:copy>
          <xsl:copy-of select="@*" />
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:template>

  <xsl:template name="replaceFieldMultilingualKeywords">
    <xsl:param name="fieldId" />
    <xsl:param name="positions" />


    <xsl:choose>
      <!-- replacement match -->
      <xsl:when test="$replacements/replacements/replacement[field = $fieldId]"> <!-- and string($replacements/replacements/replacement[field = $fieldId]/searchValue) -->

        <xsl:variable name="updatedValues">
          <xsl:call-template name="replace-loop-multilingual-keywords">
            <xsl:with-param name="fieldId" select="$fieldId" />
            <xsl:with-param name="mainValue" select="gmd:keyword/gco:CharacterString" />
            <xsl:with-param name="otherValue" select="gmd:keyword/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale = $localeLang]" />
            <xsl:with-param name="typeValue" select="gmd:type/gmd:MD_KeywordTypeCode/@codeListValue" />
            <xsl:with-param name="positions" select="$positions" />
          </xsl:call-template>
        </xsl:variable>


        <xsl:message>updatedValues: <xsl:value-of select="$updatedValues" /></xsl:message>
        <xsl:variable name="mainValue" select="tokenize($updatedValues,':;:')[1]" />
        <xsl:variable name="otherValue" select="tokenize($updatedValues,':;:')[2]" />
        <xsl:variable name="typeValue" select="tokenize($updatedValues,':;:')[3]" />

        <xsl:message>updatedValues gco:CharacterString: <xsl:value-of select="gmd:keyword/gco:CharacterString" /></xsl:message>

        <gmd:keyword>
          <!-- Copy element attributes -->
          <xsl:choose>
            <xsl:when test="not(string($mainValue)) and not(string($otherValue))"><xsl:copy-of select="gmd:keyword/@*" /></xsl:when>
            <xsl:otherwise><xsl:copy-of select="gmd:keyword/@*[not(name()='gco:nilReason')]" /></xsl:otherwise>
          </xsl:choose>
          <xsl:if test="string($otherValue) and not(gmd:keyword/@*[name() = 'xsi:type'])">
            <xsl:attribute name="xsi:type">gmd:PT_FreeText_PropertyType</xsl:attribute>
          </xsl:if>

          <!-- Main language value -->
          <gco:CharacterString>
            <xsl:copy-of select="gmd:keyword/gco:CharacterString/@*" />
            <xsl:if test="gmd:keyword/gco:CharacterString != $mainValue">
              <xsl:attribute name="geonet:change" select="$fieldId" />
              <xsl:attribute name="geonet:original" select="gmd:keyword/gco:CharacterString" />
              <xsl:attribute name="geonet:new" select="$mainValue" />
            </xsl:if>

            <xsl:value-of select="$mainValue" />
          </gco:CharacterString>

          <!-- Translations -->
          <xsl:choose>
            <xsl:when test="string($otherValue)">
              <xsl:choose>
                <xsl:when test="gmd:keyword/gmd:PT_FreeText">
                  <xsl:for-each select="gmd:keyword/gmd:PT_FreeText">
                    <xsl:copy>
                      <xsl:copy-of select="@*" />
                      <xsl:for-each select="gmd:textGroup">
                        <xsl:copy>
                          <xsl:copy-of select="@*" />
                          <xsl:for-each select="gmd:LocalisedCharacterString">
                            <xsl:choose>
                              <xsl:when test="@locale = $localeLang">
                                <gmd:LocalisedCharacterString locale="{@locale}">
                                  <xsl:if test=". != $otherValue">
                                    <xsl:attribute name="geonet:change" select="$fieldId" />
                                    <xsl:attribute name="geonet:original" select="." />
                                    <xsl:attribute name="geonet:new" select="$otherValue" />
                                  </xsl:if>
                                  <xsl:value-of select="$otherValue" />
                                </gmd:LocalisedCharacterString>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:apply-templates select="." />
                              </xsl:otherwise>
                            </xsl:choose>

                          </xsl:for-each>
                        </xsl:copy>
                      </xsl:for-each>
                    </xsl:copy>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <gmd:PT_FreeText>
                    <gmd:textGroup>
                      <gmd:LocalisedCharacterString locale="{$localeLang}">
                        <xsl:attribute name="geonet:change" select="$fieldId" />
                        <xsl:attribute name="geonet:original" select="''" />
                        <xsl:attribute name="geonet:new" select="$otherValue" />
                        <xsl:value-of select="$otherValue" />
                      </gmd:LocalisedCharacterString>
                    </gmd:textGroup>
                  </gmd:PT_FreeText>

                </xsl:otherwise>
              </xsl:choose>



            </xsl:when>

            <!-- If no value for replacement, copy actual structure -->
            <xsl:otherwise>
              <xsl:apply-templates select="gmd:keyword/gmd:PT_FreeText" />
            </xsl:otherwise>
          </xsl:choose>

        </gmd:keyword>

        <gmd:type>
          <gmd:MD_KeywordTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="{$typeValue}"/>
        </gmd:type>
      </xsl:when>

      <!-- no replacement match -->
      <xsl:otherwise>
        <xsl:copy-of select="@*" />
        <xsl:apply-templates select="@*|node()"/>
      </xsl:otherwise>
    </xsl:choose>




  </xsl:template>


  <!-- Multilingual field replacement template -->
  <xsl:template name="replaceFieldMultilingual">
    <xsl:param name="fieldId" />
    <xsl:param name="multiple" select="false()"/>

    <xsl:copy>
      <xsl:choose>
        <xsl:when test="$replacements/replacements/replacement[field = $fieldId]"> <!-- and string($replacements/replacements/replacement[field = $fieldId]/searchValue) -->
          <xsl:variable name="updatedValues">
            <xsl:choose>
              <xsl:when test="$multiple = true()">
                <xsl:call-template name="replace-loop-multilingual-multiple">
                  <xsl:with-param name="fieldId" select="$fieldId" />
                  <xsl:with-param name="mainValue" select="gco:CharacterString" />
                  <xsl:with-param name="otherValue" select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale = $localeLang]" />
                  <xsl:with-param name="i" select="1" />
                  <xsl:with-param name="n" select="count($replacements/replacements/replacement[field = $fieldId])" />
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="replace-loop-multilingual">
                  <xsl:with-param name="fieldId" select="$fieldId" />
                  <xsl:with-param name="mainValue" select="gco:CharacterString" />
                  <xsl:with-param name="otherValue" select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale = $localeLang]" />
                  <xsl:with-param name="i" select="1" />
                  <xsl:with-param name="n" select="count($replacements/replacements/replacement[field = $fieldId])" />
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="mainValue" select="tokenize($updatedValues,':;:')[1]" />
          <xsl:variable name="otherValue" select="tokenize($updatedValues,':;:')[2]" />

          <!-- Copy element attributes -->
          <xsl:choose>
            <xsl:when test="not(string($mainValue)) and not(string($otherValue))"><xsl:copy-of select="@*" /></xsl:when>
            <xsl:otherwise><xsl:copy-of select="@*[not(name()='gco:nilReason')]" /></xsl:otherwise>
          </xsl:choose>
          <xsl:if test="string($otherValue) and not(@*[name() = 'xsi:type'])">
            <xsl:attribute name="xsi:type">gmd:PT_FreeText_PropertyType</xsl:attribute>
          </xsl:if>

          <!-- Main language value -->
          <gco:CharacterString>
            <xsl:copy-of select="gco:CharacterString/@*" />
            <xsl:if test="gco:CharacterString != $mainValue">
              <xsl:attribute name="geonet:change" select="$fieldId" />
              <xsl:attribute name="geonet:original" select="gco:CharacterString" />
              <xsl:attribute name="geonet:new" select="$mainValue" />
            </xsl:if>

            <xsl:value-of select="$mainValue" />
          </gco:CharacterString>

          <!-- Translations -->
          <xsl:choose>
            <xsl:when test="string($otherValue)">
              <xsl:choose>
                <xsl:when test="gmd:PT_FreeText">
                  <xsl:for-each select="gmd:PT_FreeText">
                    <xsl:copy>
                      <xsl:copy-of select="@*" />
                      <xsl:for-each select="gmd:textGroup">
                        <xsl:copy>
                          <xsl:copy-of select="@*" />
                          <xsl:for-each select="gmd:LocalisedCharacterString">
                            <xsl:choose>
                              <xsl:when test="@locale = $localeLang">
                                <gmd:LocalisedCharacterString locale="{@locale}">
                                  <xsl:if test=". != $otherValue">
                                    <xsl:attribute name="geonet:change" select="$fieldId" />
                                    <xsl:attribute name="geonet:original" select="." />
                                    <xsl:attribute name="geonet:new" select="$otherValue" />
                                  </xsl:if>
                                  <xsl:value-of select="$otherValue" />
                                </gmd:LocalisedCharacterString>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:apply-templates select="." />
                              </xsl:otherwise>
                            </xsl:choose>

                          </xsl:for-each>
                        </xsl:copy>
                      </xsl:for-each>
                    </xsl:copy>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <gmd:PT_FreeText>
                    <gmd:textGroup>
                      <gmd:LocalisedCharacterString locale="{$localeLang}">
                        <xsl:attribute name="geonet:change" select="$fieldId" />
                        <xsl:attribute name="geonet:original" select="''" />
                        <xsl:attribute name="geonet:new" select="$otherValue" />
                        <xsl:value-of select="$otherValue" />
                      </gmd:LocalisedCharacterString>
                    </gmd:textGroup>
                  </gmd:PT_FreeText>

                </xsl:otherwise>
              </xsl:choose>

            </xsl:when>

            <!-- If no value for replacement, copy actual structure -->
            <xsl:otherwise>
              <xsl:apply-templates select="gmd:PT_FreeText" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>

        <xsl:otherwise>
          <xsl:copy-of select="@*" />
          <xsl:apply-templates select="@*|node()"/>
        </xsl:otherwise>
      </xsl:choose>

    </xsl:copy>
  </xsl:template>


  <!-- No multilingual field replacement template -->
  <xsl:template name="replaceField">
    <xsl:param name="fieldId" />

    <xsl:variable name="searchVal" select="$replacements/replacements/replacement[field = $fieldId]/searchValue" />
    <!--<xsl:message>searchVal: <xsl:value-of select="$searchVal" /></xsl:message>-->

    <xsl:variable name="replaceVal" select="$replacements/replacements/replacement[field = $fieldId]/replaceValue" />
    <!--<xsl:message>replaceVal: <xsl:value-of select="$replaceVal" /></xsl:message>-->

    <xsl:variable name="value">
      <xsl:call-template name="setValue">
        <xsl:with-param name="actualVal" select="gco:CharacterString|gmd:URL" />
        <xsl:with-param name="searchVal" select="$searchVal" />
        <xsl:with-param name="replaceVal" select="$replaceVal" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:copy>
      <xsl:choose>
        <xsl:when test="not(string($value))"><xsl:copy-of select="@*" /></xsl:when>
        <xsl:otherwise><xsl:copy-of select="@*[not(name()='gco:nilReason')]" /></xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$replacements/replacements/replacement[field = $fieldId]">

          <xsl:choose>
            <xsl:when test="name() != 'gmd:URL'">
              <gco:CharacterString>
                <xsl:if test="gco:CharacterString != $value">
                  <xsl:attribute name="geonet:change" select="$fieldId" />
                  <xsl:attribute name="geonet:original" select="gco:CharacterString" />
                  <xsl:attribute name="geonet:new" select="$value" />
                </xsl:if>
                <xsl:value-of select="$value" />
              </gco:CharacterString>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test=". != $value">
                <xsl:attribute name="geonet:change" select="$fieldId" />
                <xsl:attribute name="geonet:original" select="." />
                <xsl:attribute name="geonet:new" select="$value" />
              </xsl:if>
              <xsl:value-of select="$value" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>

        <xsl:otherwise>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>

  </xsl:template>

  <xsl:template name="replaceDateField">
    <xsl:param name="fieldId" />

    <xsl:variable name="searchVal" select="tokenize($replacements/replacements/replacement[field = $fieldId]/searchValue,':;:')[1]" />
    <!--<xsl:message>searchDateVal: <xsl:value-of select="$searchVal" /></xsl:message>-->

    <xsl:variable name="replaceVal" select="tokenize($replacements/replacements/replacement[field = $fieldId]/replaceValue,':;:')[1]" />
    <!--<xsl:message>replaceDateVal: <xsl:value-of select="$replaceVal" /></xsl:message>-->

    <xsl:variable name="value">
      <xsl:call-template name="setValue">
        <xsl:with-param name="actualVal" select="gco:Date|gco:DateTime" />
        <xsl:with-param name="searchVal" select="$searchVal" />
        <xsl:with-param name="replaceVal" select="$replaceVal" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:copy>
      <xsl:choose>
        <xsl:when test="not(string($value))"><xsl:copy-of select="@*" /></xsl:when>
        <xsl:otherwise><xsl:copy-of select="@*[not(name()='gco:nilReason')]" /></xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$replacements/replacements/replacement[field = $fieldId]">
          <xsl:choose>
            <xsl:when test="string(gco:Date)">
              <gco:Date>
                <xsl:if test="gco:Date != $value">
                  <xsl:attribute name="geonet:change" select="$fieldId" />
                  <xsl:attribute name="geonet:original" select="gco:Date" />
                  <xsl:attribute name="geonet:new" select="$value" />
                </xsl:if>
                <xsl:value-of select="$value" />
              </gco:Date>
            </xsl:when>

            <xsl:when test="string(gco:DateTime)">
              <gco:DateTime>
                <xsl:if test="gco:DateTime != $value">
                  <xsl:attribute name="geonet:change" select="$fieldId" />
                  <xsl:attribute name="geonet:original" select="gco:DateTime" />
                  <xsl:attribute name="geonet:new" select="$value" />
                </xsl:if>
                <xsl:value-of select="$value" />
              </gco:DateTime>
            </xsl:when>

            <xsl:otherwise></xsl:otherwise>
          </xsl:choose>

        </xsl:when>

        <xsl:otherwise>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>

  </xsl:template>


  <xsl:template name="replaceDateField2">
    <xsl:param name="fieldId" />
    <xsl:param name="searchVal" />
    <xsl:param name="replaceVal" />

    <xsl:variable name="value">
      <xsl:call-template name="setValue">
        <xsl:with-param name="actualVal" select="gco:Date|gco:DateTime" />
        <xsl:with-param name="searchVal" select="$searchVal" />
        <xsl:with-param name="replaceVal" select="$replaceVal" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:copy>
      <xsl:choose>
        <xsl:when test="not(string($value))"><xsl:copy-of select="@*" /></xsl:when>
        <xsl:otherwise><xsl:copy-of select="@*[not(name()='gco:nilReason')]" /></xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$replacements/replacements/replacement[field = $fieldId]">
          <xsl:choose>
            <xsl:when test="string(gco:Date)">
              <gco:Date>
                <xsl:if test="gco:Date != $value">
                  <xsl:attribute name="geonet:change" select="$fieldId" />
                  <xsl:attribute name="geonet:original" select="gco:Date" />
                  <xsl:attribute name="geonet:new" select="$value" />
                </xsl:if>
                <xsl:value-of select="$value" />
              </gco:Date>
            </xsl:when>

            <xsl:when test="string(gco:DateTime)">
              <gco:DateTime>
                <xsl:if test="gco:DateTime != $value">
                  <xsl:attribute name="geonet:change" select="$fieldId" />
                  <xsl:attribute name="geonet:original" select="gco:DateTime" />
                  <xsl:attribute name="geonet:new" select="$value" />
                </xsl:if>
                <xsl:value-of select="$value" />
              </gco:DateTime>
            </xsl:when>

            <xsl:otherwise></xsl:otherwise>
          </xsl:choose>

        </xsl:when>

        <xsl:otherwise>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>

  </xsl:template>

  <xsl:template name="setValue">
    <xsl:param name="actualVal" />
    <xsl:param name="searchVal" />
    <xsl:param name="replaceVal" />

    <!--<xsl:message>setValue (actualVal): <xsl:value-of select="$actualVal" /></xsl:message>
    <xsl:message>setValue (searchVal): <xsl:value-of select="$searchVal" /></xsl:message>
    <xsl:message>setValue (replaceVal): <xsl:value-of select="$replaceVal" /></xsl:message>-->

    <xsl:choose>
      <!-- Replacement is empty: Keep actual value -->
      <xsl:when test="not(string($replaceVal))">
        <xsl:value-of select="$actualVal" />
      </xsl:when>
      <!-- No search value, but replacement value: Set the value to the replacement -->
      <xsl:when test="not(string($searchVal)) and string($replaceVal)">
        <xsl:value-of select="$replaceVal" />
      </xsl:when>
      <!-- Case insensitive replacement -->
      <xsl:when test="string($case_insensitive)">
        <xsl:value-of select="replace($actualVal, $searchVal, $replaceVal, $case_insensitive)" />
      </xsl:when>
      <!-- Case sensitive replacement -->
      <xsl:otherwise>
        <xsl:value-of select="replace($actualVal,  $searchVal, $replaceVal)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="replace-loop-date">
    <xsl:param name="fieldId" />
    <xsl:param name="actualValDate" />
    <xsl:param name="actualValDateType" />
    <xsl:param name="i" />
    <xsl:param name="n" />

    <xsl:choose>
      <xsl:when test="$i &lt; $n+1">
        <xsl:variable name="searchType" select="tokenize($replacements/replacements/replacement[field = $fieldId][$i]/searchValue,':;:')[2]" />
        <xsl:variable name="replaceType" select="tokenize($replacements/replacements/replacement[field = $fieldId][$i]/replaceValue,':;:')[2]" />
        <xsl:variable name="searchDate" select="tokenize($replacements/replacements/replacement[field = $fieldId][$i]/searchValue,':;:')[1]" />
        <xsl:variable name="replaceDate" select="tokenize($replacements/replacements/replacement[field = $fieldId][$i]/replaceValue,':;:')[1]" />


        <xsl:choose>
          <!-- no search value, ignore it. managed in other template to add new date -->
          <xsl:when test="$replacements/replacements/replacement[field = $fieldId][$i]/searchValue = ':;:'">
            <xsl:call-template name="replace-loop-date">
              <xsl:with-param name="fieldId" select="$fieldId"/>
              <xsl:with-param name="actualValDate" select="$actualValDate"/>
              <xsl:with-param name="actualValDateType" select="$actualValDateType"/>
              <xsl:with-param name="i" select="$i + 1"/>
              <xsl:with-param name="n" select="$n"/>
            </xsl:call-template>
          </xsl:when>

          <!-- Exact match of date/datetyp with search strings -->
          <xsl:when test="gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = $searchType and gmd:date/gco:Date = $searchDate">
            <xsl:variable name="newDateType">
              <xsl:call-template name="setValue">
                <xsl:with-param name="actualVal" select="gmd:dateType/gmd:CI_DateTypeCode/@codeListValue" />
                <xsl:with-param name="searchVal" select="$searchType" />
                <xsl:with-param name="replaceVal" select="$replaceType" />
              </xsl:call-template>
            </xsl:variable>

            <xsl:variable name="newDate">
              <xsl:call-template name="setValue">
                <xsl:with-param name="actualVal" select="gmd:date/gco:Date|gmd:date/gco:DateTime" />
                <xsl:with-param name="searchVal" select="$searchDate" />
                <xsl:with-param name="replaceVal" select="$replaceDate" />
              </xsl:call-template>
            </xsl:variable>

            <xsl:copy>
              <xsl:if test="gmd:dateType/gmd:CI_DateTypeCode/@codeListValue != $newDateType or gmd:date/gco:Date != $newDate">
                <xsl:attribute name="geonet:change" select="$fieldId" />
                <xsl:attribute name="geonet:original" select="concat(gmd:date/gco:Date, '/', gmd:dateType/gmd:CI_DateTypeCode/@codeListValue)" />
                <xsl:attribute name="geonet:new" select="concat($newDate, '/', $newDateType)" />
              </xsl:if>

              <!-- gmd:date -->
              <xsl:for-each select="gmd:date">
                <xsl:call-template name="replaceDateField2">
                  <xsl:with-param name="fieldId">id.dataid.date</xsl:with-param>
                  <xsl:with-param name="searchVal" select="$searchDate" />
                  <xsl:with-param name="replaceVal" select="$replaceDate" />
                </xsl:call-template>
              </xsl:for-each>

              <!-- gmd:dateType -->
              <gmd:dateType>
                <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="{$newDateType}"/>
              </gmd:dateType>
            </xsl:copy>
          </xsl:when>

          <!-- No search type specified -->
          <xsl:when test="not(string($searchType))">
            <xsl:variable name="newDateType">
              <xsl:call-template name="setValue">
                <xsl:with-param name="actualVal" select="gmd:dateType/gmd:CI_DateTypeCode/@codeListValue" />
                <xsl:with-param name="searchVal" select="$searchType" />
                <xsl:with-param name="replaceVal" select="$replaceType" />
              </xsl:call-template>
            </xsl:variable>

            <xsl:variable name="newDate">
              <xsl:call-template name="setValue">
                <xsl:with-param name="actualVal" select="gmd:date/gco:Date|gmd:date/gco:DateTime" />
                <xsl:with-param name="searchVal" select="$searchDate" />
                <xsl:with-param name="replaceVal" select="$replaceDate" />
              </xsl:call-template>
            </xsl:variable>

            <xsl:copy>
              <xsl:attribute name="geonet:change" select="$fieldId" />
              <xsl:attribute name="geonet:original" select="concat(gmd:date/gco:Date, '/', gmd:dateType/gmd:CI_DateTypeCode/@codeListValue)" />
              <xsl:attribute name="geonet:new" select="concat($newDate, '/', $newDateType)" />

              <!-- gmd:date -->
              <xsl:for-each select="gmd:date">
                <xsl:call-template name="replaceDateField2">
                  <xsl:with-param name="fieldId">id.dataid.date</xsl:with-param>
                  <xsl:with-param name="searchVal" select="$searchDate" />
                  <xsl:with-param name="replaceVal" select="$replaceDate" />
                </xsl:call-template>
              </xsl:for-each>

              <!-- gmd:dateType -->
              <gmd:dateType>
                <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="{$newDateType}"/>
              </gmd:dateType>
            </xsl:copy>
          </xsl:when>

          <!-- Check next replacement -->
          <xsl:otherwise>
            <!--<xsl:copy>
              <xsl:copy-of select="@*" />
              <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>-->
            <xsl:call-template name="replace-loop-date">
              <xsl:with-param name="fieldId" select="$fieldId"/>
              <xsl:with-param name="actualValDate" select="$actualValDate"/>
              <xsl:with-param name="actualValDateType" select="$actualValDateType"/>
              <xsl:with-param name="i" select="$i + 1"/>
              <xsl:with-param name="n" select="$n"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>



      </xsl:when>

      <xsl:otherwise>
        <!--<xsl:value-of select="$actualValDate"/>:;:<xsl:value-of select="$actualValDateType"/>-->
        <xsl:copy>
          <xsl:copy-of select="@*" />
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="replace-loop">
    <xsl:param name="fieldId" />
    <xsl:param name="actualVal" />
    <xsl:param name="i" />
    <xsl:param name="n" />

    <xsl:choose>
      <xsl:when test="$i &lt; $n+1">

        <xsl:variable name="searchVal" select="$replacements/replacements/replacement[field = $fieldId][$i]/searchValue" />
        <!--<xsl:message>searchVal: <xsl:value-of select="$searchVal" /></xsl:message>-->

        <xsl:variable name="replaceVal" select="$replacements/replacements/replacement[field = $fieldId][$i]/replaceValue" />
        <!--<xsl:message>replaceVal: <xsl:value-of select="$replaceVal" /></xsl:message>-->

        <xsl:variable name="newActualVal">
          <xsl:call-template name="setValue">
            <xsl:with-param name="actualVal" select="$actualVal" />
            <xsl:with-param name="searchVal" select="$searchVal" />
            <xsl:with-param name="replaceVal" select="$replaceVal" />
          </xsl:call-template>
        </xsl:variable>

        <xsl:call-template name="replace-loop">
          <xsl:with-param name="fieldId" select="$fieldId"/>
          <xsl:with-param name="actualVal" select="$newActualVal"/>
          <xsl:with-param name="i" select="$i + 1"/>
          <xsl:with-param name="n" select="$n"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:otherwise>
        <xsl:value-of select="$actualVal"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="replace-loop-multiple">
    <xsl:param name="fieldId" />
    <xsl:param name="actualVal" />
    <xsl:param name="i" />
    <xsl:param name="n" />

    <xsl:choose>
      <xsl:when test="$i &lt; $n+1">

        <xsl:variable name="searchVal" select="$replacements/replacements/replacement[field = $fieldId][$i]/searchValue" />
        <!--<xsl:message>searchVal: <xsl:value-of select="$searchVal" /></xsl:message>-->

        <!--<xsl:message>replaceVal: <xsl:value-of select="$replaceVal" /></xsl:message>-->

        <xsl:choose>
          <!-- ignore add new value replacements -->
          <xsl:when test="not(string($searchVal))">
            <xsl:call-template name="replace-loop-multiple">
              <xsl:with-param name="fieldId" select="$fieldId"/>
              <xsl:with-param name="actualVal" select="$actualVal"/>
              <xsl:with-param name="i" select="$i + 1"/>
              <xsl:with-param name="n" select="$n"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="replaceVal" select="$replacements/replacements/replacement[field = $fieldId][$i]/replaceValue" />

            <xsl:variable name="newActualVal">
              <xsl:call-template name="setValue">
                <xsl:with-param name="actualVal" select="$actualVal" />
                <xsl:with-param name="searchVal" select="$searchVal" />
                <xsl:with-param name="replaceVal" select="$replaceVal" />
              </xsl:call-template>
            </xsl:variable>

            <xsl:call-template name="replace-loop-multiple">
              <xsl:with-param name="fieldId" select="$fieldId"/>
              <xsl:with-param name="actualVal" select="$newActualVal"/>
              <xsl:with-param name="i" select="$i + 1"/>
              <xsl:with-param name="n" select="$n"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>

      </xsl:when>

      <xsl:otherwise>
        <xsl:value-of select="$actualVal"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="replace-loop-multiple-security">
    <xsl:param name="fieldId" />
    <xsl:param name="actualVal" />
    <xsl:param name="i" />
    <xsl:param name="n" />

    <xsl:choose>
      <xsl:when test="$i &lt; $n+1">

        <xsl:variable name="searchVal" select="$replacements/replacements/replacement[field = $fieldId][$i]/searchValue" />
        <xsl:variable name="replaceVal" select="$replacements/replacements/replacement[field = $fieldId][$i]/replaceValue" />

        <xsl:variable name="newActualVal">
          <xsl:call-template name="setValue">
            <xsl:with-param name="actualVal" select="$actualVal" />
            <xsl:with-param name="searchVal" select="$searchVal" />
            <xsl:with-param name="replaceVal" select="$replaceVal" />
          </xsl:call-template>
        </xsl:variable>

        <xsl:call-template name="replace-loop-multiple-security">
          <xsl:with-param name="fieldId" select="$fieldId"/>
          <xsl:with-param name="actualVal" select="$newActualVal"/>
          <xsl:with-param name="i" select="$i + 1"/>
          <xsl:with-param name="n" select="$n"/>
        </xsl:call-template>

      </xsl:when>

      <xsl:otherwise>
        <xsl:value-of select="$actualVal"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="replace-loop-multilingual-keywords">
    <xsl:param name="fieldId" />
    <xsl:param name="mainValue" />
    <xsl:param name="otherValue" />
    <xsl:param name="typeValue" />
    <xsl:param name="positions" />

    <xsl:choose>
      <xsl:when test="string($positions)">
        <xsl:variable name="i" select="number(tokenize($positions, ':;:')[1])" />
        <xsl:variable name="otherPos" select="replace($positions, concat($i, ':;:'), '')" />

        <xsl:variable name="englishSearchVal" select="tokenize($replacements/replacements/replacement[field = $fieldId][$i]/searchValue,':;:')[1]" />
        <xsl:message>englishSearchVal: <xsl:value-of select="$englishSearchVal" /></xsl:message>
        <xsl:variable name="frenchSearchVal" select="tokenize($replacements/replacements/replacement[field = $fieldId][$i]/searchValue,':;:')[2]" />
        <xsl:message>frenchSearchVal: <xsl:value-of select="$frenchSearchVal" /></xsl:message>
        <xsl:variable name="typeSearchVal" select="tokenize($replacements/replacements/replacement[field = $fieldId][$i]/searchValue,':;:')[3]" />

        <xsl:variable name="englishReplaceVal" select="tokenize($replacements/replacements/replacement[field = $fieldId][$i]/replaceValue,':;:')[1]" />
        <xsl:message>englishReplaceVal: <xsl:value-of select="$englishReplaceVal" /></xsl:message>
        <xsl:variable name="frenchReplaceVal" select="tokenize($replacements/replacements/replacement[field = $fieldId][$i]/replaceValue,':;:')[2]" />
        <xsl:message>frenchReplaceVal: <xsl:value-of select="$frenchReplaceVal" /></xsl:message>
        <xsl:variable name="typeReplaceVal" select="tokenize($replacements/replacements/replacement[field = $fieldId][$i]/replaceValue,':;:')[3]" />

        <xsl:message>Language: <xsl:value-of select="$mainLanguage" /></xsl:message>
        <xsl:message>Locale lang: <xsl:value-of select="$localeLang" /></xsl:message>


        <xsl:variable name="mainSearchVal">
          <xsl:choose>
            <xsl:when test="$mainLanguage = 'fra'"><xsl:value-of select="$frenchSearchVal" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="$englishSearchVal" /></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:message>mainSearchVal: <xsl:value-of select="$mainSearchVal" /></xsl:message>

        <xsl:variable name="mainReplaceVal">
          <xsl:choose>
            <xsl:when test="$mainLanguage = 'fra'"><xsl:value-of select="$frenchReplaceVal" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="$englishReplaceVal" /></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:message>mainReplaceVal: <xsl:value-of select="$mainReplaceVal" /></xsl:message>

        <xsl:variable name="otherSearchVal">
          <xsl:choose>
            <xsl:when test="$mainLanguage = 'fra'"><xsl:value-of select="$englishSearchVal" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="$frenchSearchVal" /></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:message>otherSearchVal: <xsl:value-of select="$otherSearchVal" /></xsl:message>

        <xsl:variable name="otherReplaceVal">
          <xsl:choose>
            <xsl:when test="$mainLanguage = 'fra'"><xsl:value-of select="$englishReplaceVal" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="$frenchReplaceVal" /></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:message>otherReplaceVal: <xsl:value-of select="$otherReplaceVal" /></xsl:message>

        <xsl:variable name="mainValueUpdated">
          <xsl:call-template name="setValue">
            <xsl:with-param name="actualVal" select="$mainValue" />
            <xsl:with-param name="searchVal" select="$mainSearchVal" />
            <xsl:with-param name="replaceVal" select="$mainReplaceVal" />
          </xsl:call-template>
        </xsl:variable>
        <xsl:message>mainValueUpdated: <xsl:value-of select="$mainValueUpdated" /></xsl:message>
        <xsl:message>mainActualValue: <xsl:value-of select="gco:CharacterString" /></xsl:message>
        <xsl:message>mainValue: <xsl:value-of select="$mainValue" /></xsl:message>

        <xsl:variable name="otherValueUpdated">
          <xsl:call-template name="setValue">
            <xsl:with-param name="actualVal" select="$otherValue" />
            <xsl:with-param name="searchVal" select="$otherSearchVal" />
            <xsl:with-param name="replaceVal" select="$otherReplaceVal" />
          </xsl:call-template>
        </xsl:variable>
        <xsl:message>otherValueUpdated: <xsl:value-of select="$otherValueUpdated" /></xsl:message>
        <xsl:message>otherActualValue: <xsl:value-of select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale = $localeLang]" /></xsl:message>
        <xsl:message>otherValue: <xsl:value-of select="$otherValue" /></xsl:message>

        <xsl:variable name="typeValueUpdated">
          <xsl:call-template name="setValue">
            <xsl:with-param name="actualVal" select="$typeValue" />
            <xsl:with-param name="searchVal" select="$typeSearchVal" />
            <xsl:with-param name="replaceVal" select="$typeReplaceVal" />
          </xsl:call-template>
        </xsl:variable>
        <xsl:message>typeValueUpdated: <xsl:value-of select="$typeValueUpdated" /></xsl:message>

        <xsl:message>otherPos: <xsl:value-of select="$otherPos" /></xsl:message>

        <xsl:call-template name="replace-loop-multilingual-keywords">
          <xsl:with-param name="fieldId" select="$fieldId"/>
          <xsl:with-param name="mainValue" select="$mainValueUpdated"/>
          <xsl:with-param name="otherValue" select="$otherValueUpdated"/>
          <xsl:with-param name="typeValue" select="$typeValueUpdated"/>
          <xsl:with-param name="positions" select="$otherPos"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:otherwise>
        <xsl:value-of select="$mainValue"/>:;:<xsl:value-of select="$otherValue" />:;:<xsl:value-of select="$typeValue" />
        <xsl:message>replace-loop: <xsl:value-of select="$mainValue"/>:;:<xsl:value-of select="$otherValue" /></xsl:message>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template name="replace-loop-multilingual">
    <xsl:param name="fieldId" />
    <xsl:param name="mainValue" />
    <xsl:param name="otherValue" />
    <xsl:param name="i" />
    <xsl:param name="n" />

    <xsl:choose>
      <xsl:when test="$i &lt; $n+1">

        <xsl:variable name="englishSearchVal" select="tokenize($replacements/replacements/replacement[field = $fieldId][$i]/searchValue,':;:')[1]" />
        <!--<xsl:message>englishSearchVal: <xsl:value-of select="$englishSearchVal" /></xsl:message>-->
        <xsl:variable name="frenchSearchVal" select="tokenize($replacements/replacements/replacement[field = $fieldId][$i]/searchValue,':;:')[2]" />
        <!--<xsl:message>frenchSearchVal: <xsl:value-of select="$frenchSearchVal" /></xsl:message>-->

        <xsl:variable name="englishReplaceVal" select="tokenize($replacements/replacements/replacement[field = $fieldId][$i]/replaceValue,':;:')[1]" />
        <!--<xsl:message>englishReplaceVal: <xsl:value-of select="$englishReplaceVal" /></xsl:message>-->
        <xsl:variable name="frenchReplaceVal" select="tokenize($replacements/replacements/replacement[field = $fieldId][$i]/replaceValue,':;:')[2]" />
        <!--<xsl:message>frenchReplaceVal: <xsl:value-of select="$frenchReplaceVal" /></xsl:message>-->

        <!--<xsl:message>Language: <xsl:value-of select="$mainLanguage" /></xsl:message>
        <xsl:message>Locale lang: <xsl:value-of select="$localeLang" /></xsl:message>-->

        <xsl:variable name="mainSearchVal">
          <xsl:choose>
            <xsl:when test="$mainLanguage = 'fra'"><xsl:value-of select="$frenchSearchVal" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="$englishSearchVal" /></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!--<xsl:message>mainSearchVal: <xsl:value-of select="$mainSearchVal" /></xsl:message>-->

        <xsl:variable name="mainReplaceVal">
          <xsl:choose>
            <xsl:when test="$mainLanguage = 'fra'"><xsl:value-of select="$frenchReplaceVal" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="$englishReplaceVal" /></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!--<xsl:message>mainReplaceVal: <xsl:value-of select="$mainReplaceVal" /></xsl:message>-->

        <xsl:variable name="otherSearchVal">
          <xsl:choose>
            <xsl:when test="$mainLanguage = 'fra'"><xsl:value-of select="$englishSearchVal" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="$frenchSearchVal" /></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!--<xsl:message>otherSearchVal: <xsl:value-of select="$otherSearchVal" /></xsl:message>-->

        <xsl:variable name="otherReplaceVal">
          <xsl:choose>
            <xsl:when test="$mainLanguage = 'fra'"><xsl:value-of select="$englishReplaceVal" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="$frenchReplaceVal" /></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!--<xsl:message>otherReplaceVal: <xsl:value-of select="$otherReplaceVal" /></xsl:message>-->

        <xsl:variable name="mainValueUpdated">
          <xsl:call-template name="setValue">
            <xsl:with-param name="actualVal" select="$mainValue" />
            <xsl:with-param name="searchVal" select="$mainSearchVal" />
            <xsl:with-param name="replaceVal" select="$mainReplaceVal" />
          </xsl:call-template>
        </xsl:variable>
        <!--<xsl:message>mainActualValue: <xsl:value-of select="gco:CharacterString" /></xsl:message>
        <xsl:message>mainValue: <xsl:value-of select="$mainValue" /></xsl:message>-->

        <xsl:variable name="otherValueUpdated">
          <xsl:call-template name="setValue">
            <xsl:with-param name="actualVal" select="$otherValue" />
            <xsl:with-param name="searchVal" select="$otherSearchVal" />
            <xsl:with-param name="replaceVal" select="$otherReplaceVal" />
          </xsl:call-template>
        </xsl:variable>
        <!--<xsl:message>otherActualValue: <xsl:value-of select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale = $localeLang]" /></xsl:message>
        <xsl:message>otherValue: <xsl:value-of select="$otherValue" /></xsl:message>-->

        <xsl:call-template name="replace-loop-multilingual">
          <xsl:with-param name="fieldId" select="$fieldId"/>
          <xsl:with-param name="mainValue" select="$mainValueUpdated"/>
          <xsl:with-param name="otherValue" select="$otherValueUpdated"/>
          <xsl:with-param name="i" select="$i + 1"/>
          <xsl:with-param name="n" select="$n"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:otherwise>
        <xsl:value-of select="$mainValue"/>:;:<xsl:value-of select="$otherValue" />
        <!--<xsl:message>replace-loop: <xsl:value-of select="$mainValue"/>:;:<xsl:value-of select="$otherValue" /></xsl:message>-->
      </xsl:otherwise>
    </xsl:choose>


  </xsl:template>

  <xsl:template name="replace-loop-multilingual-multiple">
    <xsl:param name="fieldId" />
    <xsl:param name="mainValue" />
    <xsl:param name="otherValue" />
    <xsl:param name="i" />
    <xsl:param name="n" />

    <xsl:choose>
      <xsl:when test="$i &lt; $n+1">



        <xsl:choose>
          <!-- no search value, ignore it. managed in other templates -->
          <xsl:when test="$replacements/replacements/replacement[field = $fieldId][$i]/searchValue = ':;:' or not(string($replacements/replacements/replacement[field = $fieldId][$i]/searchValue))">
            <xsl:call-template name="replace-loop-multilingual-multiple">
              <xsl:with-param name="fieldId" select="$fieldId"/>
              <xsl:with-param name="mainValue" select="$mainValue"/>
              <xsl:with-param name="otherValue" select="$otherValue"/>
              <xsl:with-param name="i" select="$i + 1"/>
              <xsl:with-param name="n" select="$n"/>
            </xsl:call-template>
          </xsl:when>

          <xsl:otherwise>
            <xsl:variable name="englishSearchVal" select="tokenize($replacements/replacements/replacement[field = $fieldId][$i]/searchValue,':;:')[1]" />
            <!--<xsl:message>englishSearchVal: <xsl:value-of select="$englishSearchVal" /></xsl:message>-->
            <xsl:variable name="frenchSearchVal" select="tokenize($replacements/replacements/replacement[field = $fieldId][$i]/searchValue,':;:')[2]" />
            <!--<xsl:message>frenchSearchVal: <xsl:value-of select="$frenchSearchVal" /></xsl:message>-->

            <xsl:variable name="englishReplaceVal" select="tokenize($replacements/replacements/replacement[field = $fieldId][$i]/replaceValue,':;:')[1]" />
            <!--<xsl:message>englishReplaceVal: <xsl:value-of select="$englishReplaceVal" /></xsl:message>-->
            <xsl:variable name="frenchReplaceVal" select="tokenize($replacements/replacements/replacement[field = $fieldId][$i]/replaceValue,':;:')[2]" />
            <!--<xsl:message>frenchReplaceVal: <xsl:value-of select="$frenchReplaceVal" /></xsl:message>-->

            <!--<xsl:message>Language: <xsl:value-of select="$mainLanguage" /></xsl:message>
            <xsl:message>Locale lang: <xsl:value-of select="$localeLang" /></xsl:message>-->

            <xsl:variable name="mainSearchVal">
              <xsl:choose>
                <xsl:when test="$mainLanguage = 'fra'"><xsl:value-of select="$frenchSearchVal" /></xsl:when>
                <xsl:otherwise><xsl:value-of select="$englishSearchVal" /></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <!--<xsl:message>mainSearchVal: <xsl:value-of select="$mainSearchVal" /></xsl:message>-->

            <xsl:variable name="mainReplaceVal">
              <xsl:choose>
                <xsl:when test="$mainLanguage = 'fra'"><xsl:value-of select="$frenchReplaceVal" /></xsl:when>
                <xsl:otherwise><xsl:value-of select="$englishReplaceVal" /></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <!--<xsl:message>mainReplaceVal: <xsl:value-of select="$mainReplaceVal" /></xsl:message>-->

            <xsl:variable name="otherSearchVal">
              <xsl:choose>
                <xsl:when test="$mainLanguage = 'fra'"><xsl:value-of select="$englishSearchVal" /></xsl:when>
                <xsl:otherwise><xsl:value-of select="$frenchSearchVal" /></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <!--<xsl:message>otherSearchVal: <xsl:value-of select="$otherSearchVal" /></xsl:message>-->

            <xsl:variable name="otherReplaceVal">
              <xsl:choose>
                <xsl:when test="$mainLanguage = 'fra'"><xsl:value-of select="$englishReplaceVal" /></xsl:when>
                <xsl:otherwise><xsl:value-of select="$frenchReplaceVal" /></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <!--<xsl:message>otherReplaceVal: <xsl:value-of select="$otherReplaceVal" /></xsl:message>-->

            <xsl:variable name="mainValueUpdated">
              <xsl:call-template name="setValue">
                <xsl:with-param name="actualVal" select="$mainValue" />
                <xsl:with-param name="searchVal" select="$mainSearchVal" />
                <xsl:with-param name="replaceVal" select="$mainReplaceVal" />
              </xsl:call-template>
            </xsl:variable>
            <!--<xsl:message>mainActualValue: <xsl:value-of select="gco:CharacterString" /></xsl:message>
            <xsl:message>mainValue: <xsl:value-of select="$mainValue" /></xsl:message>-->

            <xsl:variable name="otherValueUpdated">
              <xsl:call-template name="setValue">
                <xsl:with-param name="actualVal" select="$otherValue" />
                <xsl:with-param name="searchVal" select="$otherSearchVal" />
                <xsl:with-param name="replaceVal" select="$otherReplaceVal" />
              </xsl:call-template>
            </xsl:variable>
            <!--<xsl:message>otherActualValue: <xsl:value-of select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale = $localeLang]" /></xsl:message>
            <xsl:message>otherValue: <xsl:value-of select="$otherValue" /></xsl:message>-->

            <xsl:call-template name="replace-loop-multilingual-multiple">
              <xsl:with-param name="fieldId" select="$fieldId"/>
              <xsl:with-param name="mainValue" select="$mainValueUpdated"/>
              <xsl:with-param name="otherValue" select="$otherValueUpdated"/>
              <xsl:with-param name="i" select="$i + 1"/>
              <xsl:with-param name="n" select="$n"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>


      </xsl:when>

      <xsl:otherwise>
        <xsl:value-of select="$mainValue"/>:;:<xsl:value-of select="$otherValue" />
        <!--<xsl:message>replace-loop: <xsl:value-of select="$mainValue"/>:;:<xsl:value-of select="$otherValue" /></xsl:message>-->
      </xsl:otherwise>
    </xsl:choose>


  </xsl:template>
</xsl:stylesheet>

