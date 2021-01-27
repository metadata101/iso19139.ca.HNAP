<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:geonet="http://www.fao.org/geonetwork"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            queryBinding="xslt2">

  <sch:title xmlns="http://www.w3.org/2001/XMLSchema">HNAP validation rules (non-multilingual)</sch:title>
  <sch:ns prefix="gml" uri="http://www.opengis.net/gml/3.2"/>
  <sch:ns prefix="gml320" uri="http://www.opengis.net/gml"/>
  <sch:ns prefix="gmd" uri="http://www.isotc211.org/2005/gmd"/>
  <sch:ns prefix="srv" uri="http://www.isotc211.org/2005/srv"/>
  <sch:ns prefix="gco" uri="http://www.isotc211.org/2005/gco"/>
  <sch:ns prefix="gmx" uri="http://www.isotc211.org/2005/gmx"/>
  <sch:ns prefix="geonet" uri="http://www.fao.org/geonetwork"/>
  <sch:ns prefix="xsl" uri="http://www.w3.org/1999/XSL/Transform"/>
  <sch:ns prefix="XslUtilHnap" uri="java:ca.gc.schema.iso19139hnap.util.XslUtilHnap"/>
  <sch:ns prefix="tr" uri="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"/>
  <sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>
  <sch:ns prefix="rdf" uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>
  <sch:ns prefix="ns2" uri="http://www.w3.org/2004/02/skos/core#"/>
  <sch:ns prefix="rdfs" uri="http://www.w3.org/2000/01/rdf-schema#"/>

  <sch:let name="schema" value="'iso19139.ca.HNAP'"/>
<sch:let name="mainLanguage" value="if (normalize-space(//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gmd:LanguageCode/@codeListValue) != '')
                                       then lower-case(normalize-space(//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gmd:LanguageCode/@codeListValue))
                                       else if (contains(//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gco:CharacterString,';'))
                                            then lower-case(normalize-space(substring-before(//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gco:CharacterString,';')))
                                            else lower-case(//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gco:CharacterString)"/>
  <sch:let name="mainLanguageId" value="//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:locale/gmd:PT_Locale[gmd:languageCode/*/@codeListValue = $mainLanguage]/@id"/>
  <sch:let name="mainLanguageText" value="if ($mainLanguage = 'fra') then 'French' else 'English'"/>
  <sch:let name="mainLanguage2char" value="if ($mainLanguage = 'fra') then 'fr' else 'en'"/>

  <xsl:function name="geonet:resourceFormatsList" as="xs:string">
    <xsl:param name="thesaurusDir" as="xs:string"/>

    <xsl:variable name="formats-list" select="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Resource_Formats.rdf'), '\\', '/')))"/>

    <xsl:variable name="v">
      <xsl:for-each select="$formats-list//rdf:Description[ns2:prefLabel[@xml:lang='en']]">
        <xsl:sort select="lower-case(@rdf:about)" order="ascending" />
        <xsl:value-of select="replace(@rdf:about, 'http://geonetwork-opensource.org/EC/resourceformat#', '')" />
        <xsl:if test="position() != last()">, </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:value-of select="$v" />
  </xsl:function>

  <xsl:function name="geonet:securityLevelList" as="xs:string">
    <xsl:param name="thesaurusDir" as="xs:string"/>

    <xsl:variable name="security-level-list" select="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Security_Level.rdf'), '\\', '/')))"/>

    <xsl:variable name="v">
      <xsl:for-each select="$security-level-list//rdf:Description[ns2:prefLabel[@xml:lang='en']]">
        <xsl:sort select="lower-case(@rdf:about)" order="ascending" />
        <xsl:value-of select="replace(@rdf:about, 'http://geonetwork-opensource.org/EC/GC_Security_Classification#', '')" />
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
  EC schematron rules for multilingual validation in metadata editor:
  ============================================================= -->

  <!--- Metadata pattern -->
  <sch:pattern>
    <sch:title>$loc/strings/Metadata</sch:title>

    <!-- Metadata Standard Name -->
    <sch:rule context="//gmd:metadataStandardName">

      <sch:let name="correct" value="(($mainLanguage = 'eng' and gco:CharacterString = 'North American Profile of ISO 19115:2003 - Geographic information - Metadata') or
                          ($mainLanguage = 'fra' and gco:CharacterString = 'Profil nord-américain de la norme ISO 19115:2003 - Information géographique - Métadonnées'))
                            " />

      <sch:assert
        test="$correct"
      >$loc/strings/MetadataStandardName</sch:assert>
    </sch:rule>

    <!-- Contact - Organisation Name -->
    <sch:rule context="//gmd:contact/*/gmd:organisationName">

      <sch:let name="mdLang" value="tokenize(/gmd:MD_Metadata/gmd:language/gco:CharacterString, ';')[1]" />

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/ContactOrganisationName</sch:assert>

      <sch:let name="government-titles" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Departments.rdf'), '\\', '/')))"/>
      <sch:let name="government-names" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Org_Names.rdf'), '\\', '/')))"/>

      <sch:let name="organisationName" value="gco:CharacterString" />
      <sch:let name="isGovernmentOfCanada" value="starts-with(lower-case(normalize-space(tokenize($organisationName, ';')[1])), 'government of canada') or starts-with(lower-case(normalize-space(tokenize($organisationName, ';')[1])), 'gouvernement du canada')" />
      <sch:let name="titleName" value="lower-case(normalize-space(tokenize($organisationName, ';')[2]))" />

      <sch:let name="isGovernmentNameAllowed" value="(
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationName)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang=$mainLanguage2char])), ';'))])
        )"/>


      <sch:let name="isErrorContactGovMain" value="not(($missing) or ($isGovernmentNameAllowed and not($isGovernmentOfCanada)) or (not($isGovernmentNameAllowed) and not($isGovernmentOfCanada)) or ($isGovernmentOfCanada and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $titleName]))
                     ))"/>

      <sch:let name="isErrorContactGovMainAllowed" value="not($isErrorContactGovMain) and not(
                ($missing) or
                $isGovernmentNameAllowed
                )"/>

      <sch:assert test="not($isErrorContactGovMain)">$loc/strings/*[name() = concat('ContactGov', $mainLanguageText)]</sch:assert>

      <sch:assert test="not($isErrorContactGovMainAllowed)">$loc/strings/*[name() = concat('ContactGovAllowed', $mainLanguageText)]</sch:assert>
    </sch:rule>


    <!-- Contact - Electronic Mail -->
    <sch:rule context="//gmd:contact/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"

      >$loc/strings/ContactElectronicMail</sch:assert>

    </sch:rule>
  </sch:pattern>


  <!--- Data Identification pattern -->
  <sch:pattern>
    <sch:title>$loc/strings/DataIdentification</sch:title>

    <!-- Use Limitation -->
    <sch:rule context="//gmd:identificationInfo/gmd:MD_DataIdentification
            |//*[@gco:isoType='gmd:MD_DataIdentification']
            |//*[@gco:isoType='srv:SV_ServiceIdentification']">

      <sch:let name="open-licenses" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Open_Licenses.rdf'), '\\', '/')))"/>

      <sch:let name="openLicense" value="count(gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation[
               (normalize-space(gco:CharacterString) = $open-licenses//rdf:Description/ns2:prefLabel[@xml:lang=$mainLanguage2char])])" />


      <sch:assert
        test="$openLicense > 0"
      >$loc/strings/OpenLicense</sch:assert>

    </sch:rule>

    <!-- Title -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:title
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:title
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:title">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/MetadataTitle</sch:assert>
    </sch:rule>

    <!-- Abstract -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:abstract
                     |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:abstract
                     |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:abstract">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                         or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/MetadataAbstract</sch:assert>

    </sch:rule>

    <!-- Cited responsible party  - Organisation Name -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />


      <sch:assert
        test="not($missing)"
      >$loc/strings/CitedResponsiblePartyOrganisationName</sch:assert>

      <sch:let name="government-titles" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Departments.rdf'), '\\', '/')))"/>
      <sch:let name="government-names" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Org_Names.rdf'), '\\', '/')))"/>

      <sch:let name="organisationName" value="gco:CharacterString" />
      <sch:let name="isGovernmentOfCanada" value="starts-with(lower-case(normalize-space(tokenize($organisationName, ';')[1])), 'government of canada') or starts-with(lower-case(normalize-space(tokenize($organisationName, ';')[1])), 'gouvernement du canada')" />
      <sch:let name="titleName" value="lower-case(normalize-space(tokenize($organisationName, ';')[2]))" />

      <sch:let name="isGovernmentNameAllowed" value="(
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationName)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang=$mainLanguage2char])), ';'))])
        )"/>

      <sch:assert test="($missing) or ($isGovernmentNameAllowed and not($isGovernmentOfCanada)) or (not($isGovernmentNameAllowed) and not($isGovernmentOfCanada)) or ($isGovernmentOfCanada and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $titleName]))
              )">$loc/strings/*[name() = concat('CitedResponsibleContactGov', $mainLanguageText)]</sch:assert>

      <sch:assert test="($missing) or
                $isGovernmentNameAllowed
                ">$loc/strings/*[name() = concat('CitedResponsibleContactGovAllowed', $mainLanguageText)]</sch:assert>
    </sch:rule>

    <!-- Cited Responsible Party - Electronic Mail -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress
                      |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress
                      |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />


      <sch:assert
        test="not($missing)"

      >$loc/strings/CitedResponsiblePartyElectronicMail</sch:assert>

    </sch:rule>

    <!-- Keywords -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword">
      <sch:let name="missing" value="not(string(gco:CharacterString))
            or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/Keyword</sch:assert>

    </sch:rule>

    <!-- Thesaurus contact -->
    <sch:rule context="//gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:organisationName">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/OrganisationNameThesaurus</sch:assert>

    </sch:rule>

    <sch:rule context="//gmd:descriptiveKeywords">

      <sch:let name="thesaurusNamePresent" value="count(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation) > 0" />


      <sch:let name="missingTitle" value="not(string(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString))
              or (@gco:nilReason)" />


      <sch:assert
        test="not($thesaurusNamePresent) or ($thesaurusNamePresent and not($missingTitle))"
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

      <sch:assert
        test="not($thesaurusNamePresent) or ($thesaurusNamePresent and not($missingOrganisation))"
      >$loc/strings/ECThesaurusOrg</sch:assert>

      <sch:let name="emailPresent" value="count(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress) > 0" />

      <sch:let name="missingEmail" value="not(string(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString))
              or (@gco:nilReason)" />

      <sch:assert
        test="not($thesaurusNamePresent) or ($thesaurusNamePresent and (not($emailPresent) or ($emailPresent and not($missingEmail))))"
      >$loc/strings/ECThesaurusEmail</sch:assert>
    </sch:rule>

    <!-- Note (Other constraints) -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints">
      <sch:let name="filledFine" value="(
                (string(gco:CharacterString)
                and (../gmd:accessConstraints/gmd:MD_RestrictionCode/@codeListValue = 'RI_609'
                or ../gmd:useConstraints/gmd:MD_RestrictionCode/@codeListValue = 'RI_609')) or

                (not(string(gco:CharacterString))
                and (../gmd:accessConstraints/gmd:MD_RestrictionCode/@codeListValue != 'RI_609'
                and ../gmd:useConstraints/gmd:MD_RestrictionCode/@codeListValue != 'RI_609')
                ))" />
      <sch:assert
        test="$filledFine"
      >$loc/strings/OtherConstraintsNote</sch:assert>
    </sch:rule>

    <sch:rule context="//gmd:MD_SecurityConstraints/gmd:userNote">

      <sch:let name="missingTitle" value="not(string(gco:CharacterString))
              or (@gco:nilReason)" />

      <sch:let name="securityLevel" value="gco:CharacterString" />

      <sch:let name="security-level-list" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Security_Level.rdf'), '\\', '/')))"/>

      <sch:let name="securityLevelList" value="geonet:securityLevelList($thesaurusDir)" />
      <sch:let name="locMsg" value="concat($loc/strings/SecurityLevel, $securityLevelList)" />

      <sch:assert test="$missingTitle or string($security-level-list//rdf:Description[@rdf:about = concat('http://geonetwork-opensource.org/EC/GC_Security_Classification#', $securityLevel)])">$locMsg</sch:assert>

    </sch:rule>

    <!-- Use limitation -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                         or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/UseLimitation</sch:assert>

    </sch:rule>

  </sch:pattern>


  <!-- Distribution - Resources -->
  <sch:pattern>
  <sch:title>$loc/strings/Distribution</sch:title>

    <!-- Distribution - Resources -->
    <sch:rule context="//gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine">

      <sch:let name="missingLanguageForMapService" value="not(string(@xlink:role)) and (lower-case(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString) = 'ogc:wms' or lower-case(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString) = 'esri rest: map service')" />

      <sch:assert
        test="not($missingLanguageForMapService)"
      >$loc/strings/MapServicesLanguage</sch:assert>


      <!-- ResourceDescription -->
      <sch:let name="smallcase" value="'abcdefghijklmnopqrstuvwxyz'" />
      <sch:let name="uppercase" value="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
      <sch:let name="formats-list" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Resource_Formats.rdf'), '\\', '/')))"/>

      <sch:let name="description" value="gmd:CI_OnlineResource/gmd:description/gco:CharacterString" />
      <sch:let name="contentType" value="subsequence(tokenize($description, ';'), 1, 1)" />
      <sch:let name="format" value="subsequence(tokenize($description, ';'), 2, 1)" />
      <sch:let name="language" value="subsequence(tokenize($description, ';'), 3, 1)" />
      <sch:let name="language_present" value="geonet:values-in($language,
              ('eng', 'fra', 'spa', 'zxx'))"/>


      <sch:assert test="($contentType = 'Web Service' or $contentType = 'Service Web' or
              $contentType = 'Dataset' or $contentType = 'Données' or
              $contentType = 'API' or $contentType = 'Application' or
              $contentType='Supporting Document' or $contentType = 'Document de soutien')">$loc/strings/ResourceDescriptionContentType</sch:assert>


      <sch:let name="resourceFormatsList" value="geonet:resourceFormatsList($thesaurusDir)" />
      <sch:let name="locMsg" value="concat($loc/strings/ResourceDescriptionFormat, $resourceFormatsList)" />

      <sch:assert test="string($formats-list//rdf:Description[@rdf:about = concat('http://geonetwork-opensource.org/EC/resourceformat#', $format)])">$locMsg</sch:assert>

      <sch:assert test="normalize-space($language) != ''">$loc/strings/ResourceDescriptionLanguage</sch:assert>

      <sch:assert test="$language_present">$loc/strings/ResourceDescriptionLanguage</sch:assert>

    </sch:rule>




    <!-- Distributor contact - Organisation Name -->
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:organisationName">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/DistributorOrganisationName</sch:assert>


      <sch:let name="government-titles" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Departments.rdf'), '\\', '/')))"/>
      <sch:let name="government-names" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Org_Names.rdf'), '\\', '/')))"/>

      <sch:let name="organisationName" value="gco:CharacterString" />
      <sch:let name="isGovernmentOfCanada" value="starts-with(lower-case(normalize-space(tokenize($organisationName, ';')[1])), 'government of canada') or starts-with(lower-case(normalize-space(tokenize($organisationName, ';')[1])), 'gouvernement du canada')" />
      <sch:let name="titleName" value="lower-case(normalize-space(tokenize($organisationName, ';')[2]))" />

      <sch:let name="isGovernmentNameAllowed" value="(
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationName)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang=$mainLanguage2char])), ';'))])
        )"/>

      <sch:assert test="($missing) or ($isGovernmentNameAllowed and not($isGovernmentOfCanada)) or (not($isGovernmentNameAllowed) and not($isGovernmentOfCanada)) or ($isGovernmentOfCanada and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $titleName]))
              )">$loc/strings/*[name() = concat('DistributorGov', $mainLanguageText)]</sch:assert>

      <sch:assert test="($missing) or
                $isGovernmentNameAllowed
                ">$loc/strings/*[name() = concat('DistributorGovAllowed', $mainLanguageText)]</sch:assert>
    </sch:rule>

    <!-- Distributor contact - Country -->
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact//gmd:country">
      <sch:let name="country-values" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/ISO_Countries.rdf'), '\\', '/')))"/>

      <sch:let name="countryName" value="lower-case(gco:CharacterString)" />

      <sch:assert test="(not($countryName) or
              ($countryName and (string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $countryName]))))">$loc/strings/ECCountry</sch:assert>

    </sch:rule>

    <!-- Distributor - Electronic Mail -->
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                  or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"

      >$loc/strings/DistributorElectronicMail</sch:assert>

    </sch:rule>

  </sch:pattern>
</sch:schema>
