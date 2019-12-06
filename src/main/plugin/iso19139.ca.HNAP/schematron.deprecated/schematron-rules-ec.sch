<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:geonet="http://www.fao.org/geonetwork"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            queryBinding="xslt2">

  <sch:title xmlns="http://www.w3.org/2001/XMLSchema">HNAP validation rules for FGP publication</sch:title>
  <sch:ns prefix="gml" uri="http://www.opengis.net/gml/3.2"/>
  <sch:ns prefix="gml320" uri="http://www.opengis.net/gml"/>
  <sch:ns prefix="gmd" uri="http://www.isotc211.org/2005/gmd"/>
  <sch:ns prefix="srv" uri="http://www.isotc211.org/2005/srv"/>
  <sch:ns prefix="gco" uri="http://www.isotc211.org/2005/gco"/>
  <sch:ns prefix="geonet" uri="http://www.fao.org/geonetwork"/>
  <sch:ns prefix="xsl" uri="http://www.w3.org/1999/XSL/Transform"/>
  <sch:ns prefix="languageTranslated" uri="java:ca.gc.schema.iso19139hnap.util.XslUtilHnap"/>
  <sch:ns prefix="tr" uri="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"/>
  <sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>
  <sch:ns prefix="rdf" uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>
  <sch:ns prefix="ns2" uri="http://www.w3.org/2004/02/skos/core#"/>
  <sch:ns prefix="rdfs" uri="http://www.w3.org/2000/01/rdf-schema#"/>
  <sch:ns prefix="napec" uri="http://www.ec.gc.ca/data_donnees/standards/schemas/napec"/>

  <sch:let name="schema" value="'iso19139.ca.HNAP'"/>
  <sch:let name="mainLanguage" value="if (normalize-space(//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gmd:LanguageCode/@codeListValue) != '')
                                       then normalize-space(//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gmd:LanguageCode/@codeListValue)
                                       else if (contains(//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gco:CharacterString,';'))
                                            then normalize-space(substring-before(//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gco:CharacterString,';'))
                                            else //*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gco:CharacterString"/>
  <sch:let name="mainLanguageId" value="//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:locale/gmd:PT_Locale[gmd:languageCode/*/@codeListValue = $mainLanguage]/@id"/>
  <sch:let name="altLanguageId" value="//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:locale/gmd:PT_Locale[gmd:languageCode/*/@codeListValue != $mainLanguage and (gmd:languageCode/*/@codeListValue = 'eng' or gmd:languageCode/*/@codeListValue = 'fra')]/@id"/>
  <sch:let name="mainLanguage2char" value="if (lower-case($mainLanguageId) = 'fra') then 'fr' else 'en'"/>
  <sch:let name="altLanguage2char" value="if (lower-case($altLanguageId) = 'fra') then 'fr' else 'en'"/>
  <sch:let name="mainLanguageText" value="if (lower-case($mainLanguageId) = 'fra') then 'French' else 'English'"/>
  <sch:let name="altLanguageText" value="if (lower-case($altLanguageId) = 'fra') then 'French' else 'English'"/>

  <xsl:function name="geonet:resourceFormatsList" as="xs:string">
    <xsl:param name="thesaurusDir" as="xs:string"/>

    <xsl:variable name="formats-list" select="document(concat('file:///', replace(concat($thesaurusDir, '/local/thesauri/theme/EC_Resource_Formats.rdf'), '\\', '/')))"/>

    <xsl:variable name="v">
      <xsl:for-each select="$formats-list//rdf:Description[ns2:prefLabel[@xml:lang='en']]">
        <xsl:sort select="lower-case(@rdf:about)" order="ascending" />
        <xsl:value-of select="replace(@rdf:about, 'http://geonetwork-opensource.org/EC/resourceformat#', '')" />
        <xsl:if test="position() != last()">, </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:value-of select="$v" />
  </xsl:function>

  <!-- Checks if the values in arg (can be a comma separate list of items) are all in the searchStrings list -->
  <xsl:function name="geonet:values-in" as="xs:boolean">
    <xsl:param name="arg" as="xs:string?"/>
    <xsl:param name="searchStrings" as="xs:string*"/>

    <xsl:variable name="list" select="tokenize($arg, ',')" />
    <xsl:sequence
            select="
            every $listValue in $list
            satisfies exists($searchStrings[. = $listValue])
            "
    />
  </xsl:function>

  <!-- =============================================================
  EC schematron rules:
  ============================================================= -->

  <!--- Metadata pattern -->
  <sch:pattern>
    <sch:title>$loc/strings/Metadata</sch:title>

    <!-- HierarchyLevel -->
    <sch:rule context="//gmd:hierarchyLevel">

      <sch:let name="missing" value="not(string(gmd:MD_ScopeCode/@codeListValue))
                 or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/HierarchyLevel</sch:assert>

      <sch:let name="hierarchyLevelCodelistLabel"
                     value="tr:codelist-value-label(
                            tr:create($schema),
                            gmd:MD_ScopeCode/local-name(),
                            gmd:MD_ScopeCode/@codeListValue)"/>

      <sch:let name="isValid" value="($hierarchyLevelCodelistLabel != '') and ($hierarchyLevelCodelistLabel != gmd:MD_ScopeCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidHierarchyLevel</sch:assert>

    </sch:rule>


    <!-- Metadata Standard Name -->
    <sch:rule context="//gmd:metadataStandardName">

      <sch:let name="correct" value="(gco:CharacterString = 'North American Profile of ISO 19115:2003 - Geographic information - Metadata' or
                      gco:CharacterString = 'Profil nord-américain de la norme ISO 19115:2003 - Information géographique - Métadonnées') and

                      (gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)] = 'North American Profile of ISO 19115:2003 - Geographic information - Metadata' or
                       gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)] = 'Profil nord-américain de la norme ISO 19115:2003 - Information géographique - Métadonnées')
                        " />

      <sch:assert
        test="$correct"
      >$loc/strings/EC19</sch:assert>
    </sch:rule>


    <!-- Mandatory, if spatialRepresentionType in Data Identification is "vector," "grid" or "tin”. -->
    <sch:rule context="/gmd:MD_Metadata">
      <sch:let name="missing" value="not(gmd:referenceSystemInfo)
                  " />

      <sch:let name="sRequireRefSystemInfo" value="count(//gmd:identificationInfo/*/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode[@codeListValue= 'RI_635']) +
                                                       count(//gmd:identificationInfo/*/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode[@codeListValue= 'RI_636']) +
                                                       count(//gmd:identificationInfo/*/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode[@codeListValue= 'RI_638'])" />

      <sch:assert
        test="(($sRequireRefSystemInfo > 0) and not($missing)) or
              $sRequireRefSystemInfo = 0"
      >$loc/strings/ReferenceSystemInfo</sch:assert>
    </sch:rule>

    <sch:rule context="//gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code">
      <sch:let name="missing" value="not(string(gco:CharacterString))
                  " />

      <sch:assert
        test="not($missing)"
      >$loc/strings/ReferenceSystemInfoCode</sch:assert>
    </sch:rule>


  </sch:pattern>

  <!--- Data Identification pattern -->
  <sch:pattern>
    <sch:title>$loc/strings/DataIdentification</sch:title>


    <!-- Title -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title
                     |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:title
                     |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:title">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                         or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="not($missing) or not($missingOtherLang)"
      >$loc/strings/ECTitle</sch:assert>

    </sch:rule>


    <!-- Creation/revision dates -->
     <sch:rule context="//gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation
                       |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation
                       |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation">

      <sch:let name="missingPublication" value="count(gmd:date[gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'RI_367']) = 0" />

      <sch:assert
        test="not($missingPublication)"
      >$loc/strings/EC14</sch:assert>

      <sch:let name="missingCreation" value="count(gmd:date[gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'RI_366']) = 0" />

      <sch:assert
        test="not($missingCreation)"
      >$loc/strings/EC15</sch:assert>

    </sch:rule>

    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date
          |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date
          |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date">

      <sch:let name="missing" value="not(string(*/text()))
                    " />

      <sch:assert
        test="not($missing)"
      >$loc/strings/MissingDate</sch:assert>
    </sch:rule>

    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:dateType
          |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:dateType
          |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:dateType">

      <sch:let name="dateTypeCodelistLabel"
                     value="tr:codelist-value-label(
                            tr:create($schema),
                            gmd:CI_DateTypeCode/local-name(),
                            gmd:CI_DateTypeCode/@codeListValue)"/>

      <sch:let name="missing" value="not(string(gmd:CI_DateTypeCode/@codeListValue))
               or (@gco:nilReason)" />

      <sch:let name="isValid" value="($dateTypeCodelistLabel != '') and ($dateTypeCodelistLabel != gmd:CI_DateTypeCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidDateTypeCode</sch:assert>

    </sch:rule>


    <!-- Abstract -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:abstract
                   |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:abstract
                   |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:abstract">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                       or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="not($missing) or not($missingOtherLang)"
      >$loc/strings/EC32</sch:assert>

    </sch:rule>



    <!-- Status -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:status
                     |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:status
                     |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:status">

      <sch:let name="missing" value="not(string(gmd:MD_ProgressCode/@codeListValue))
                 or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/Status</sch:assert>


      <sch:let name="statusCodelistLabel"
                     value="tr:codelist-value-label(
                            tr:create($schema),
                            gmd:MD_ProgressCode/local-name(),
                            gmd:MD_ProgressCode/@codeListValue)"/>

      <sch:let name="isValid" value="($statusCodelistLabel != '') and ($statusCodelistLabel != gmd:MD_ProgressCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidStatusCode</sch:assert>
    </sch:rule>


    <!-- Language -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:language
                     |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:language
                     |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:language">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                         or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="not($missing) or not($missingOtherLang)"
      >$loc/strings/ECDatasetLanguage</sch:assert>

    </sch:rule>


    <!-- Cited Responsible Party - Individual Name -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:individualName
              |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:individualName
              |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:individualName">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/CitedResponsiblePartyIndividualName</sch:assert>

    </sch:rule>


    <!-- Cited Responsible Party - Organisation Name -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName
                       |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName
                       |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName">

      <sch:let name="missing" value="not(string(normalize-space(gco:CharacterString)))
                    or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)])))" />

      <sch:assert
        test="not($missing) or not($missingOtherLang)"
      >$loc/strings/CitedResponsiblePartyOrganisation</sch:assert>

      <sch:let name="government-titles" value="document(concat('file:///', replace(concat($thesaurusDir, '/local/thesauri/theme/EC_Government_Titles.rdf'), '\\', '/')))"/>

      <sch:let name="organisationName" value="gco:CharacterString" />
      <sch:let name="isGovernmentOfCanada" value="starts-with(lower-case($organisationName), 'government of canada') or starts-with(lower-case($organisationName), 'gouvernement du canada')" />
      <sch:let name="titleName" value="lower-case(normalize-space(tokenize($organisationName, ';')[2]))" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />
      <sch:assert test="($missing and $missingOtherLang) or
                  ($isGovernmentOfCanada and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $titleName]) or
                  string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang=$altLanguage2char])) = $titleName]))
                  )">$loc/strings/*[name() = concat('EC37Gov', $mainLanguageText)]</sch:assert>


      <sch:let name="organisationNameOtherLang" value="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]" />
      <sch:let name="isGovernmentOfCanadaOtherLang" value="starts-with(lower-case($organisationNameOtherLang), 'government of canada') or starts-with(lower-case($organisationNameOtherLang), 'gouvernement du canada')" />
      <sch:let name="titleNameOtherLang" value="lower-case(normalize-space(tokenize($organisationNameOtherLang, ';')[2]))" />

      <sch:assert test="($missing and $missingOtherLang) or
                  ($isGovernmentOfCanadaOtherLang and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $titleNameOtherLang]) or
                  string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang=$altLanguage2char])) = $titleNameOtherLang]))
                  )">$loc/strings/*[name() = concat('EC37Gov', $altLanguageText)]</sch:assert>
    </sch:rule>


    <!-- Cited Responsible Party - Position Name -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:positionName
                |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:positionName
                |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:positionName">

      <sch:let name="missing" value="not(string(normalize-space(gco:CharacterString)))
                    or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)])))" />

      <sch:assert
        test="(not($missing) or not($missingOtherLang))"
      >$loc/strings/CitedResponsiblePartyPositionName</sch:assert>

    </sch:rule>


    <!-- Cited Responsible Party - Country -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty//gmd:country
                                                 |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty//gmd:country
                                                 |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty//gmd:country">
	  <sch:let name="country-values" value="document(concat('file:///', replace(concat($thesaurusDir, '/local/thesauri/theme/EC_ISO_Countries.rdf'), '\\', '/')))"/>

      <sch:let name="countryName" value="lower-case(gco:CharacterString)" />
      <sch:let name="countryNameOtherLang" value="lower-case(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)])" />

      <sch:assert test="(not($countryName) or
           ($countryName and (string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $countryName]) or
           string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang=$altLanguage2char])) = $countryName]))))

           and

           (not($countryNameOtherLang) or
                       ($countryNameOtherLang and (string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $countryNameOtherLang]) or
                       string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang=$altLanguage2char])) = $countryNameOtherLang]))
                       ))">$loc/strings/ECCountry</sch:assert>
    </sch:rule>


    <!-- Cited Responsible Party - Delivery point: optional in internal validation -->


    <!-- Cited Responsible Party - Hours of service: optional in internal validation -->


    <!-- Cited Responsible Party - Electronic mail address -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">

      <sch:let name="missing" value="not(string(normalize-space(gco:CharacterString)))
                    or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)])))" />

      <sch:assert
        test="not($missing) or not($missingOtherLang)"

      >$loc/strings/CitedResponsiblePartyEmail</sch:assert>

    </sch:rule>


    <!-- Cited Responsible Party - Role -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:role
              |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:role
              |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:role">

      <sch:let name="missing" value="not(string(gmd:CI_RoleCode/@codeListValue))
                  or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/CitedResponsiblePartyRole</sch:assert>

      <sch:let name="roleCodelistLabel"
                     value="tr:codelist-value-label(
                            tr:create($schema),
                            gmd:CI_RoleCode/local-name(),
                            gmd:CI_RoleCode/@codeListValue)"/>

      <sch:let name="isValid" value="($roleCodelistLabel != '') and ($roleCodelistLabel != gmd:CI_RoleCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidCitedResponsibleRole</sch:assert>
    </sch:rule>


    <!-- Topic Category -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:topicCategory
                   |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:topicCategory
                   |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:topicCategory">

      <sch:let name="missing" value="not(string(gmd:MD_TopicCategoryCode))
                      " />

      <sch:assert
        test="not($missing)"
      >$loc/strings/EC10</sch:assert>
    </sch:rule>


    <!-- Maintenance and frequency -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency
                   |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency
                   |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency">

      <sch:let name="missing" value="not(string(gmd:MD_MaintenanceFrequencyCode/@codeListValue))
               or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/MaintenanceFrequency</sch:assert>

      <sch:let name="maintenanceFrequencyCodelistLabel"
                     value="tr:codelist-value-label(
                            tr:create($schema),
                            gmd:MD_MaintenanceFrequencyCode/local-name(),
                            gmd:MD_MaintenanceFrequencyCode/@codeListValue)"/>

      <sch:let name="isValid" value="($maintenanceFrequencyCodelistLabel != '') and ($maintenanceFrequencyCodelistLabel != gmd:MD_MaintenanceFrequencyCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidMaintenanceFrequency</sch:assert>
    </sch:rule>


    <!-- Spatial Representation -->
    <sch:rule context="//gmd:identificationInfo/gmd:MD_DataIdentification
                |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:MD_DataIdentification
                |//*[@gco:isoType='srv:SV_ServiceIdentification']/srv:SV_ServiceIdentification">

      <sch:let name="missing" value="not(gmd:spatialRepresentationType)
                              " />

      <sch:assert
        test="not($missing)"
      >$loc/strings/SpatialRepresentation</sch:assert>

      <!-- Core Subject Thesaurus -->
      <sch:let name="coreSubjectThesaurusExists"
               value="count(gmd:descriptiveKeywords[*/gmd:thesaurusName/*/gmd:title/*/text() = 'Government of Canada Core Subject Thesaurus' or
              */gmd:thesaurusName/*/gmd:title/*/text() = 'Government of Canada Core Subject Thesaurus']) > 0" />

      <sch:assert test="$coreSubjectThesaurusExists">$loc/strings/CoreSubjectThesaurusMissing</sch:assert>
    </sch:rule>

    <sch:rule context="//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:spatialRepresentationType
                         |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:spatialRepresentationType
                         |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:spatialRepresentationType">

      <sch:let name="spatialRepresentationTypeCodelistLabel"
                     value="tr:codelist-value-label(
                            tr:create($schema),
                            gmd:MD_SpatialRepresentationTypeCode/local-name(),
                            gmd:MD_SpatialRepresentationTypeCode/@codeListValue)"/>

      <sch:let name="missing" value="not(string(gmd:MD_SpatialRepresentationTypeCode/@codeListValue))
        or (@gco:nilReason)" />

      <sch:let name="isValid" value="($spatialRepresentationTypeCodelistLabel != '') and ($spatialRepresentationTypeCodelistLabel != gmd:MD_SpatialRepresentationTypeCode/@codeListValue)"/>

      <sch:assert
        test="$isValid"
      >$loc/strings/InvalidSpatialRepresentationType</sch:assert>
    </sch:rule>


    <!-- Keywords -->

    <sch:rule context="//gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[not(gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'theme.EC_Data_Usage_Scope.rdf' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'theme.EC_Information_Category.rdf' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'theme.EC_Content_Scope.rdf' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'theme.EC_Waf.rdf' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'place.EC_Geographic_Scope.rdf')]/gmd:keyword
                           |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:descriptiveKeywords/gmd:MD_Keywords[not(gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'theme.EC_Data_Usage_Scope.rdf' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'theme.EC_Information_Category.rdf' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'theme.EC_Content_Scope.rdf' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'theme.EC_Waf.rdf' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'place.EC_Geographic_Scope.rdf')]/gmd:keyword
                           |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:descriptiveKeywords/gmd:MD_Keywords[not(gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'theme.EC_Data_Usage_Scope.rdf' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'theme.EC_Information_Category.rdf' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'theme.EC_Content_Scope.rdf' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'theme.EC_Waf.rdf' or
                                                                                              gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'place.EC_Geographic_Scope.rdf')]/gmd:keyword">

      <sch:let name="missing" value="not(string(gco:CharacterString))
            or (../@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="not($missing) or not($missingOtherLang)"
      >$loc/strings/EC35</sch:assert>

    </sch:rule>


    <!-- Thesaurus info -->
    <sch:rule context="//gmd:descriptiveKeywords">

      <sch:let name="thesaurusNamePresent" value="count(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation) > 0" />


      <sch:let name="missingTitle" value="not(string(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString))
                      or (@gco:nilReason)" />

      <sch:let name="missingTitleOtherLang" value="not(string(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="not($thesaurusNamePresent) or ($thesaurusNamePresent and not($missingTitle) and not($missingTitleOtherLang))"
      >$loc/strings/ECThesaurusTitle</sch:assert>


      <sch:let name="missingPublication" value="count(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:date[gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'RI_367']) = 0" />

      <sch:assert
        test="not($thesaurusNamePresent) or ($thesaurusNamePresent and not($missingPublication))"
      >$loc/strings/ECThesaurusPubDate</sch:assert>

      <sch:let name="missingCreation" value="count(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:date[gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'RI_366']) = 0" />

      <sch:assert
        test="not($thesaurusNamePresent) or ($thesaurusNamePresent and not($missingCreation))"
      >$loc/strings/ECThesaurusCreDate</sch:assert>


      <sch:let name="missingRole" value="not(string(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue))" />

      <sch:assert
        test="not($thesaurusNamePresent) or ($thesaurusNamePresent and not($missingRole))"
      >$loc/strings/ECThesaurusRole</sch:assert>

      <sch:let name="missingOrganisation" value="not(string(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString))
                      or (@gco:nilReason)" />

      <sch:let name="missingOrganisationOtherLang" value="not(string(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:organisationName/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="not($thesaurusNamePresent) or ($thesaurusNamePresent and not($missingOrganisation) and not($missingOrganisationOtherLang))"
      >$loc/strings/ECThesaurusOrg</sch:assert>

      <sch:let name="emailPresent" value="count(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress) > 0" />

      <sch:let name="missingEmail" value="not(string(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString))
                      or (@gco:nilReason)" />

      <sch:let name="missingEmailOtherLang" value="not(string(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="not($thesaurusNamePresent) or ($thesaurusNamePresent and (not($emailPresent) or ($emailPresent and not($missingEmail) and not($missingEmailOtherLang))))"
      >$loc/strings/ECThesaurusEmail</sch:assert>
    </sch:rule>


    <!-- Other constraints -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints">

      <sch:let name="filledFine" value="(
                (string(gco:CharacterString) or string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))
                    and (../gmd:accessConstraints/gmd:MD_RestrictionCode/@codeListValue = 'RI_609'
                    or ../gmd:useConstraints/gmd:MD_RestrictionCode/@codeListValue = 'RI_609')) or

                    (not(string(gco:CharacterString)) and not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))
                    and (../gmd:accessConstraints/gmd:MD_RestrictionCode/@codeListValue != 'RI_609'
                    and ../gmd:useConstraints/gmd:MD_RestrictionCode/@codeListValue != 'RI_609')
                    )" />
      <sch:assert
        test="$filledFine"
      >$loc/strings/EC8</sch:assert>

    </sch:rule>

    <!-- Use limitation -->
     <sch:rule context="//gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation">

      <sch:let name="missing" value="not(string(gco:CharacterString) or string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/EC11</sch:assert>

      <sch:let name="openLicense" value="count(../../../gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation[
                ($mainLanguage = 'eng' and
                normalize-space(gco:CharacterString) = 'Open Government Licence - Canada (http://open.canada.ca/en/open-government-licence-canada)' and
                normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]) = 'Licence du gouvernement ouvert - Canada (http://ouvert.canada.ca/fr/licence-du-gouvernement-ouvert-canada)') or
                (mainLanguage = 'fra' and
                normalize-space(gco:CharacterString) = 'Licence du gouvernement ouvert - Canada (http://ouvert.canada.ca/fr/licence-du-gouvernement-ouvert-canada)' and
                normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)])  = 'Open Government Licence - Canada (http://open.canada.ca/en/open-government-licence-canada)')])"/>

      <sch:assert
       test="$openLicense > 0"
      >$loc/strings/OpenLicense</sch:assert>

     </sch:rule>


    <!-- Access constraints -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:accessConstraints">

      <sch:let name="missing" value="not(string(gmd:MD_RestrictionCode/@codeListValue))
               or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/EC12</sch:assert>

      <sch:let name="accessConstraintsCodelistLabel"
                     value="tr:codelist-value-label(
                            tr:create($schema),
                            gmd:MD_RestrictionCode/local-name(),
                            gmd:MD_RestrictionCode/@codeListValue)"/>

      <sch:let name="isValid" value="($accessConstraintsCodelistLabel != '') and ($accessConstraintsCodelistLabel != gmd:MD_RestrictionCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidAccessConstraints</sch:assert>

      </sch:rule>


    <!-- Use constraints -->
      <sch:rule context="//gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useConstraints">

        <sch:let name="missing" value="not(string(gmd:MD_RestrictionCode/@codeListValue))
                 or (@gco:nilReason)" />

        <sch:assert
          test="not($missing)"
        >$loc/strings/EC13</sch:assert>

        <sch:let name="useConstraintsCodelistLabel"
                     value="tr:codelist-value-label(
                            tr:create($schema),
                            gmd:MD_RestrictionCode/local-name(),
                            gmd:MD_RestrictionCode/@codeListValue)"/>

        <sch:let name="isValid" value="($useConstraintsCodelistLabel != '') and ($useConstraintsCodelistLabel != gmd:MD_RestrictionCode/@codeListValue)"/>

        <sch:assert
          test="$isValid or $missing"
        >$loc/strings/InvalidUseConstraints</sch:assert>

      </sch:rule>


    <!-- Open License -->
    <!-- Use Limitation: missing element -->
    <sch:rule context="//gmd:identificationInfo/gmd:MD_DataIdentification[not(gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation)]
          |//*[@gco:isoType='gmd:MD_DataIdentification' and not(gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation)]
          |//*[@gco:isoType='srv:SV_ServiceIdentification' and not(gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation)]">

      <sch:let name="openLicense" value="count(gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation[
                ($mainLanguage = 'eng' and
                normalize-space(gco:CharacterString) = 'Open Government Licence - Canada (http://open.canada.ca/en/open-government-licence-canada)' and
                normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]) = 'Licence du gouvernement ouvert - Canada (http://ouvert.canada.ca/fr/licence-du-gouvernement-ouvert-canada)') or
                (mainLanguage = 'fra' and
                normalize-space(gco:CharacterString) = 'Licence du gouvernement ouvert - Canada (http://ouvert.canada.ca/fr/licence-du-gouvernement-ouvert-canada)' and
                normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)])  = 'Open Government Licence - Canada (http://open.canada.ca/en/open-government-licence-canada)')])"/>

      <sch:assert
        test="$openLicense > 0"
      >$loc/strings/OpenLicense</sch:assert>

    </sch:rule>



  </sch:pattern>


  <!-- Corporate Information pattern -->
  <sch:pattern>
    <sch:title>$loc/strings/CorporateInfo</sch:title>

    <!-- Branch -->
    <sch:rule context="//*[@gco:isoType='gmd:MD_DataIdentification']/napec:EC_CorporateInfo/napec:EC_Branch
                   |//*[@gco:isoType='srv:SV_ServiceIdentification']/napec:EC_CorporateInfo/napec:EC_Branch">


      <sch:let name="missing" value="not(string(napec:EC_Branch_TypeCode/@codeListValue))" />


      <sch:assert
        test="not($missing)"
      >$loc/strings/Branch</sch:assert>
    </sch:rule>


    <!-- Directorate -->
    <sch:rule context="//*[@gco:isoType='gmd:MD_DataIdentification']/napec:EC_CorporateInfo/napec:EC_Directorate
                   |//*[@gco:isoType='srv:SV_ServiceIdentification']/napec:EC_CorporateInfo/napec:EC_Directorate">

      <sch:let name="missing" value="not(string(napec:EC_Directorate_TypeCode/@codeListValue))" />


      <sch:assert
        test="not($missing)"
      >$loc/strings/Directorate</sch:assert>
    </sch:rule>
  </sch:pattern>


  <!-- Information Classification pattern -->
  <sch:pattern>
    <sch:title>$loc/strings/InformationClassification</sch:title>

    <!-- Information category -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[
          gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Information_Category' or
          normalize-space(gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'theme.EC_Information_Category.rdf']/gmd:keyword">

      <sch:let name="missing" value="not(string(normalize-space(gco:CharacterString)))" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/EC7</sch:assert>

    </sch:rule>

    <sch:rule context="//gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[
          gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Information_Category' or
          normalize-space(gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'theme.EC_Information_Category.rdf']">

      <sch:let name="missing" value="not(string(normalize-space(gmd:keyword/gco:CharacterString)))" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/EC7</sch:assert>

    </sch:rule>

    <!-- Geographic scope -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[
          gmd:thesaurusName/gmd:CI_Citation/@id = 'local.place.EC_Geographic_Scope' or
          normalize-space(gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'place.EC_Geographic_Scope.rdf']/gmd:keyword">

      <sch:let name="missing" value="not(string(normalize-space(gco:CharacterString)))" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/EC6</sch:assert>
    </sch:rule>

    <sch:rule context="//gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[
          gmd:thesaurusName/gmd:CI_Citation/@id = 'local.place.EC_Geographic_Scope' or
          normalize-space(gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString) = 'place.EC_Geographic_Scope.rdf']">

      <sch:let name="missing" value="not(string(normalize-space(gmd:keyword/gco:CharacterString)))" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/EC6</sch:assert>
    </sch:rule>

    <!-- Security Classification -->
    <sch:rule context="//*[@gco:isoType='gmd:MD_DataIdentification']/napec:EC_CorporateInfo/napec:GC_Security_Classification
                 |//*[@gco:isoType='srv:SV_ServiceIdentification']/napec:EC_CorporateInfo/napec:GC_Security_Classification">

      <sch:let name="missing" value="not(string(napec:GC_Security_Classification_TypeCode/@codeListValue))" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/SecurityClassification</sch:assert>
    </sch:rule>
  </sch:pattern>


  <!-- Distribution - Resources -->
  <sch:pattern>
    <sch:title>$loc/strings/Distribution</sch:title>

    <!-- Transfer options -->
    <sch:rule context="//gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage/gmd:URL">

      <sch:let name="missing" value="not(string(.)) and not(string(../../../../gmd:onLine[@xlink:role!=../../../@xlink:role and @xlink:title=../../../@xlink:title]/gmd:CI_OnlineResource/gmd:linkage/gmd:URL))
                                               and (string(../../gmd:protocol/gco:CharacterString) or
                                                    string(../../gmd:name/gco:CharacterString) or
                                                    string(../../../../gmd:onLine[@xlink:role!=../../../@xlink:role and @xlink:title=../../../@xlink:title]/gmd:CI_OnlineResource/gmd:name/gco:CharacterString) or
                                                    string(../../../../gmd:onLine[@xlink:role!=../../../@xlink:role and @xlink:title=../../../@xlink:title]/gmd:CI_OnlineResource/gmd:description/gco:CharacterString) or
                                                    string(../../gmd:description/gco:CharacterString))"
      />

      <sch:assert
        test="not($missing)"
      >$loc/strings/EC9</sch:assert>

    </sch:rule>


    <!-- Distributor contact - Individual name -->
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:individualName">

      <sch:let name="missing" value="not(string(gco:CharacterString))
					or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/DistributorIndividualName</sch:assert>
    </sch:rule>


    <!-- Distributor contact - Organisation name -->
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:organisationName">

      <sch:let name="missing" value="not(string(normalize-space(gco:CharacterString)))
                    or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)])))" />

      <sch:assert
        test="not($missing) or not($missingOtherLang)"
      >$loc/strings/DistributorOrganisation</sch:assert>


      <sch:let name="government-titles" value="document(concat('file:///', replace(concat($thesaurusDir, '/local/thesauri/theme/EC_Government_Titles.rdf'), '\\', '/')))"/>

      <sch:let name="organisationName" value="gco:CharacterString" />
      <sch:let name="isGovernmentOfCanada" value="starts-with(lower-case($organisationName), 'government of canada') or starts-with(lower-case($organisationName), 'gouvernement du canada')" />
      <sch:let name="titleName" value="lower-case(normalize-space(tokenize($organisationName, ';')[2]))" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert test="($missing and $missingOtherLang) or
                    ($isGovernmentOfCanada and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $titleName]) or
                    string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang=$altLanguage2char])) = $titleName]))
                    )">$loc/strings/*[name() = concat('EC26Gov', $mainLanguageText)]</sch:assert>


      <sch:let name="organisationNameOtherLang" value="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]" />
      <sch:let name="isGovernmentOfCanadaOtherLang" value="starts-with(lower-case($organisationNameOtherLang), 'government of canada') or starts-with(lower-case($organisationNameOtherLang), 'gouvernement du canada')" />
      <sch:let name="titleNameOtherLang" value="lower-case(normalize-space(tokenize($organisationNameOtherLang, ';')[2]))" />

      <sch:assert test="($missing and $missingOtherLang) or
                    ($isGovernmentOfCanadaOtherLang and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $titleNameOtherLang]) or
                    string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang=$altLanguage2char])) = $titleNameOtherLang]))
                    )">$loc/strings/*[name() = concat('EC26Gov', $altLanguageText)]</sch:assert>
    </sch:rule>


    <!-- Distributor contact - Position Name -->
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact//gmd:positionName">

      <sch:let name="missing" value="not(string(normalize-space(gco:CharacterString)))
                    or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)])))" />

      <sch:assert
        test="(not($missing) or not($missingOtherLang))"
      >$loc/strings/DistributorPositionName</sch:assert>

    </sch:rule>


    <!-- Distributor contact - Country -->
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact//gmd:country">
      <sch:let name="country-values" value="document(concat('file:///', replace(concat($thesaurusDir, '/local/thesauri/theme/EC_ISO_Countries.rdf'), '\\', '/')))"/>

      <sch:let name="countryName" value="lower-case(gco:CharacterString)" />
      <sch:let name="countryNameOtherLang" value="lower-case(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)])" />

      <sch:assert test="(not($countryName) or
           ($countryName and (string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $countryName]) or
           string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang=$altLanguage2char])) = $countryName]))))

           and

           (not($countryNameOtherLang) or
                       ($countryNameOtherLang and (string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $countryNameOtherLang]) or
                       string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang=$altLanguage2char])) = $countryNameOtherLang]))
                       ))">$loc/strings/ECCountry</sch:assert>


    </sch:rule>

    <!-- Distributor - Delivery point: optional in internal validation -->


    <!-- Distributor - Hours of service: optional in internal validation -->


    <!-- Distributor - Electronic mail address -->
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">

      <sch:let name="missing" value="not(string(normalize-space(gco:CharacterString)))
                  or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)])))" />

      <sch:assert
        test="not($missing) or not($missingOtherLang)"

      >$loc/strings/DistributorEmail</sch:assert>

    </sch:rule>


    <!-- Distributor - Role -->
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:role">

      <sch:let name="missing" value="not(string(gmd:CI_RoleCode/@codeListValue))
                  or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/DistributorRole</sch:assert>

      <sch:let name="roleCodelistLabel"
                     value="tr:codelist-value-label(
                            tr:create($schema),
                            gmd:CI_RoleCode/local-name(),
                            gmd:CI_RoleCode/@codeListValue)"/>

      <sch:let name="isValid" value="($roleCodelistLabel != '') and ($roleCodelistLabel != gmd:CI_RoleCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidDistributorRole</sch:assert>

    </sch:rule>


    <!-- Distribution Format -->
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributionFormat/*/gmd:name">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                      or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/EC21</sch:assert>

      <sch:let name="distribution-formats" value="document(concat('file:///', replace(concat($thesaurusDir, '/local/thesauri/theme/EC_Resource_Formats.rdf'), '\\', '/')))"/>

      <sch:let name="distributionFormat" value="gco:CharacterString" />

      <sch:assert test="($missing) or (string($distribution-formats//rdf:Description[normalize-space(ns2:prefLabel[@xml:lang=$mainLanguage2char]) = $distributionFormat]))">$loc/strings/DistributionFormatInvalid</sch:assert>
    </sch:rule>


    <!-- Distribution Format version -->
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributionFormat/*/gmd:version">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                      or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/EC22</sch:assert>

    </sch:rule>


    <!-- Resources -->
    <sch:rule context="//gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine">

      <sch:let name="missingLanguageForMapService" value="not(string(@xlink:role)) and (lower-case(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString) = 'ogc:wms' or lower-case(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString) = 'esri rest: map service')" />

      <sch:assert
        test="not($missingLanguageForMapService)"
      >$loc/strings/EC23</sch:assert>

    </sch:rule>

    <!-- Online resource: MapResourcesREST, MapResourcesWMS-->
    <sch:rule context="//gmd:distributionInfo/gmd:MD_Distribution">
      <sch:let name="smallcase" value="'abcdefghijklmnopqrstuvwxyz'" />
      <sch:let name="uppercase" value="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

      <sch:let name="mapRESTCount" value="count(gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role='urn:xml:lang:eng-CAN' and translate(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString, $uppercase, $smallcase) = 'esri rest: map service']) +
                count(gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role='urn:xml:lang:fra-CAN' and translate(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString, $uppercase, $smallcase) = 'esri rest: map service'])" />

      <sch:assert test="$mapRESTCount &lt;= 2">$loc/strings/MapResourcesRESTNumber</sch:assert>
      <sch:assert test="$mapRESTCount = 0 or $mapRESTCount = 2 or $mapRESTCount &gt; 2">$loc/strings/MapResourcesREST</sch:assert>

      <sch:let name="mapWMSCount" value="count(gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role='urn:xml:lang:eng-CAN' and translate(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString, $uppercase, $smallcase) = 'ogc:wms']) +
                count(gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role='urn:xml:lang:fra-CAN' and translate(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString, $uppercase, $smallcase) = 'ogc:wms'])" />

      <sch:assert test="$mapWMSCount &lt;= 2">$loc/strings/MapResourcesWMSNumber</sch:assert>
      <sch:assert test="$mapWMSCount = 0 or $mapWMSCount = 2 or $mapWMSCount &gt; 2">$loc/strings/MapResourcesWMS</sch:assert>
    </sch:rule>

    <sch:rule context="//gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine">
      <sch:let name="smallcase" value="'abcdefghijklmnopqrstuvwxyz'" />
      <sch:let name="uppercase" value="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
	  <sch:let name="formats-list" value="document(concat('file:///', replace(concat($thesaurusDir, '/local/thesauri/theme/EC_Resource_Formats.rdf'), '\\', '/')))"/>

      <sch:let name="description" value="gmd:CI_OnlineResource/gmd:description/gco:CharacterString" />
      <sch:let name="contentType" value="subsequence(tokenize($description, ';'), 1, 1)" />
      <sch:let name="format" value="subsequence(tokenize($description, ';'), 2, 1)" />
      <sch:let name="language" value="subsequence(tokenize($description, ';'), 3, 1)" />
      <sch:let name="language_list" value="tokenize('eng fra spa zxx', '\s+')"/>
      <sch:let name="language_present" value="geonet:values-in($language,
              ('eng', 'fra', 'spa', 'zxx'))"/>

      <sch:let name="descriptionTranslated" value="gmd:CI_OnlineResource/gmd:description/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]" />
      <sch:let name="contentTypeTranslated" value="subsequence(tokenize($descriptionTranslated, ';'), 1, 1)" />
      <sch:let name="languageTranslated" value="subsequence(tokenize($descriptionTranslated, ';'), 3, 1)" />

      <sch:let name="languageTranslated_present" value="geonet:values-in($languageTranslated,
              ('eng', 'fra', 'spa', 'zxx'))"/>

      <sch:assert test="($contentType = 'Web Service' or $contentType = 'Service Web' or
                $contentType = 'Dataset' or $contentType = 'Données' or
                $contentType = 'API' or $contentType = 'Application' or
                $contentType='Supporting Document' or $contentType = 'Document de soutien') and
                ($contentTypeTranslated = 'Web Service' or $contentTypeTranslated = 'Service Web' or
                $contentTypeTranslated = 'Dataset' or $contentTypeTranslated = 'Données' or
                $contentTypeTranslated = 'API' or $contentTypeTranslated = 'Application' or
                $contentTypeTranslated='Supporting Document' or $contentTypeTranslated = 'Document de soutien')">$loc/strings/ResourceDescriptionContentType</sch:assert>


      <sch:let name="formatTranslated" value="subsequence(tokenize($descriptionTranslated, ';'), 2, 1)" />
      <sch:let name="formatTranslated" value="subsequence(tokenize($descriptionTranslated, ';'), 2, 1)" />
      <sch:let name="formatTranslated" value="subsequence(tokenize($descriptionTranslated, ';'), 2, 1)" />
      <sch:let name="resourceFormatsList" value="geonet:resourceFormatsList($thesaurusDir)" />
      <sch:let name="locMsg" value="concat($loc/strings/ResourceDescriptionFormat, $resourceFormatsList)" />

      <sch:assert test="string($formats-list//rdf:Description[@rdf:about = concat('http://geonetwork-opensource.org/EC/resourceformat#', $format)]) and
                               string($formats-list//rdf:Description[@rdf:about = concat('http://geonetwork-opensource.org/EC/resourceformat#',$formatTranslated)])">$locMsg</sch:assert>


      <sch:assert test="normalize-space($language) != '' and normalize-space($languageTranslated) != ''">$loc/strings/ResourceDescriptionLanguage</sch:assert>

      <sch:assert test="$language_present and $languageTranslated_present">$loc/strings/ResourceDescriptionLanguage</sch:assert>
    </sch:rule>
  </sch:pattern>
</sch:schema>
