<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform" queryBinding="xslt2">

  <sch:title xmlns="http://www.w3.org/2001/XMLSchema">HNAP validation rules for publication</sch:title>
  <sch:ns prefix="gml" uri="http://www.opengis.net/gml/3.2"/>
  <sch:ns prefix="gmd" uri="http://www.isotc211.org/2005/gmd"/>
  <sch:ns prefix="srv" uri="http://www.isotc211.org/2005/srv"/>
  <sch:ns prefix="gco" uri="http://www.isotc211.org/2005/gco"/>
  <sch:ns prefix="gmx" uri="http://www.isotc211.org/2005/gmx"/>
  <sch:ns prefix="geonet" uri="http://www.fao.org/geonetwork"/>
  <sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>
  <sch:ns prefix="rdf" uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>
  <sch:ns prefix="ns2" uri="http://www.w3.org/2004/02/skos/core#"/>
  <sch:ns prefix="rdfs" uri="http://www.w3.org/2000/01/rdf-schema#"/>

  <!-- =============================================================
  EC schematron rules for multilingual validation in metadata editor:
  ============================================================= -->

  <!-- HierarchyLevel -->
  <sch:pattern>
    <sch:title>$loc/strings/HierarchyLevel</sch:title>
    <sch:rule context="//gmd:hierarchyLevel">

      <sch:let name="missing" value="not(string(gmd:MD_ScopeCode/@codeListValue))
                 or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/HierarchyLevel</sch:assert>

    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>$loc/strings/InvalidHierarchyLevel</sch:title>
    <sch:rule context="//gmd:hierarchyLevel">

      <sch:let name="hierarchyLevelCodelist" value="document(concat('file:///', $schemaDir, '/loc/', $lang, '/codelists.xml'))"/>

      <sch:let name="missing" value="not(string(gmd:MD_ScopeCode/@codeListValue))
                 or (@gco:nilReason)" />

      <sch:let name="value" value="gmd:MD_ScopeCode/@codeListValue" />
      <sch:let name="isValid" value="count($hierarchyLevelCodelist/codelists/codelist[@name='gmd:MD_ScopeCode']/entry[code=$value]) = 1" />

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidHierarchyLevel</sch:assert>

    </sch:rule>
  </sch:pattern>

  <!-- Metadata Standard Name -->
  <sch:pattern>
    <sch:title>$loc/strings/EC19</sch:title>

    <sch:rule context="//gmd:metadataStandardName">

      <sch:let name="correct" value="(gco:CharacterString = 'North American Profile of ISO 19115:2003 - Geographic information - Metadata' or
                      gco:CharacterString = 'Profil nord-américain de la norme ISO 19115:2003 - Information géographique - Métadonnées') and

                      (gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString = 'North American Profile of ISO 19115:2003 - Geographic information - Metadata' or
                       gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString = 'Profil nord-américain de la norme ISO 19115:2003 - Information géographique - Métadonnées')
                        " />

      <sch:assert
              test="$correct"
      >$loc/strings/EC19</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Title -->
  <sch:pattern>
    <sch:title>$loc/strings/EC33</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:title
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:title
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:title">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert
        test="not($missing) and not($missingOtherLang)"
        >$loc/strings/EC33</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Abstract -->
  <sch:pattern>
    <sch:title>$loc/strings/EC32</sch:title>
    <sch:rule context="//gmd:identificationInfo/*/gmd:abstract
                     |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:abstract
                     |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:abstract">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                         or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert
        test="not($missing) and not($missingOtherLang)"
        >$loc/strings/EC32</sch:assert>

    </sch:rule>
  </sch:pattern>

  <!-- Status -->
  <sch:pattern>
    <sch:title>$loc/strings/Status</sch:title>
    <sch:rule context="//gmd:identificationInfo/*/gmd:status
                     |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:status
                     |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:status">


      <sch:let name="missing" value="not(string(gmd:MD_ProgressCode/@codeListValue))" />


      <sch:assert
        test="not($missing)"
      >$loc/strings/Status</sch:assert>

    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>$loc/strings/InvalidStatusCode</sch:title>
    <sch:rule context="//gmd:identificationInfo/*/gmd:status
                     |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:status
                     |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:status">

      <sch:let name="statusCodelist" value="document(concat('file:///', $schemaDir, '/loc/', $lang, '/codelists.xml'))"/>

      <sch:let name="missing" value="not(string(gmd:MD_ProgressCode/@codeListValue))
                 or (@gco:nilReason)" />

      <sch:let name="value" value="gmd:MD_ProgressCode/@codeListValue" />
      <sch:let name="isValid" value="count($statusCodelist/codelists/codelist[@name='gmd:MD_ProgressCode']/entry[code=$value]) = 1" />

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidStatusCode</sch:assert>

    </sch:rule>
  </sch:pattern>

  <!-- Contact - Organisation Name -->
  <sch:pattern>
    <sch:title>$loc/strings/ContactOrganisationName</sch:title>

    <sch:rule context="//gmd:contact/*/gmd:organisationName">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />


      <sch:assert
        test="not($missing) and not($missingOtherLang)"
        >$loc/strings/ContactOrganisationName</sch:assert>

    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>$loc/strings/EC38GovEnglish</sch:title>

    <sch:rule context="//gmd:contact/*/gmd:organisationName">
      <sch:let name="government-titles" value="document(concat('file:///', $thesaurusDir, '/local/thesauri/theme/EC_Government_Titles.rdf'))"/>

      <sch:let name="organisationName" value="gco:CharacterString" />
      <sch:let name="isGovernmentOfCanada" value="starts-with(lower-case($organisationName), 'government of canada') or starts-with(lower-case($organisationName), 'gouvernement du canada')" />
      <sch:let name="titleName" value="lower-case(normalize-space(tokenize($organisationName, ';')[2]))" />

      <sch:let name="missing" value="not(string(gco:CharacterString))
                  or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert test="($missing and $missingOtherLang) or ($isGovernmentOfCanada and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='en'])) = $titleName]) or
              string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='fr'])) = $titleName]))
              )">$loc/strings/EC38GovEnglish</sch:assert>

    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>$loc/strings/EC38GovFrench</sch:title>

    <sch:rule context="//gmd:contact/*/gmd:organisationName">
      <sch:let name="government-titles" value="document(concat('file:///', $thesaurusDir, '/local/thesauri/theme/EC_Government_Titles.rdf'))"/>

      <sch:let name="organisationNameOtherLang" value="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString" />
      <sch:let name="isGovernmentOfCanadaOtherLang" value="starts-with(lower-case($organisationNameOtherLang), 'government of canada') or starts-with(lower-case($organisationNameOtherLang), 'gouvernement du canada')" />
      <sch:let name="titleNameOtherLang" value="lower-case(normalize-space(tokenize($organisationNameOtherLang, ';')[2]))" />

      <sch:let name="missing" value="not(string(gco:CharacterString))
                  or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert test="($missing and $missingOtherLang) or ($isGovernmentOfCanadaOtherLang and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='en'])) = $titleNameOtherLang]) or
              string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='fr'])) = $titleNameOtherLang]))
              )">$loc/strings/EC38GovFrench</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Contact - Position name -->
  <sch:pattern>
    <sch:title>$loc/strings/ContactPositionName</sch:title>

    <sch:rule context="//gmd:contact/*/gmd:positionName">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
        >$loc/strings/ContactPositionName</sch:assert>

    </sch:rule>
  </sch:pattern>

  <!-- Contact - Country -->
  <sch:pattern>
    <sch:title>$loc/strings/ECCountry</sch:title>

    <sch:rule context="//gmd:contact//gmd:country">
      <sch:let name="country-values" value="document(concat('file:///', $thesaurusDir, '/local/thesauri/theme/EC_ISO_Countries.rdf'))"/>

      <sch:let name="countryName" value="lower-case(gco:CharacterString)" />
      <sch:let name="countryNameOtherLang" value="lower-case(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString)" />

      <sch:assert test="(not($countryName) or
           ($countryName and (string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang='en'])) = $countryName]) or
           string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang='fr'])) = $countryName]))))

           and

           (not($countryNameOtherLang) or
                       ($countryNameOtherLang and (string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang='en'])) = $countryNameOtherLang]) or
                       string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang='fr'])) = $countryNameOtherLang]))
                       ))">$loc/strings/ECCountry</sch:assert>


    </sch:rule>
  </sch:pattern>

  <!-- Contact - Delivery point -->
  <sch:pattern>
    <sch:title>$loc/strings/ContactDeliveryPoint</sch:title>

    <sch:rule context="//gmd:contact/*/gmd:contactInfo//gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                " />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/ContactDeliveryPoint</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Contact - Phone -->
  <sch:pattern>
    <sch:title>$loc/strings/ContactPhone</sch:title>
    <sch:rule context="//gmd:contact/*/gmd:contactInfo/*/gmd:phone/gmd:CI_Telephone/gmd:voice">

      <sch:let name="missing" value="not(string(gco:CharacterString))
              " />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/ContactPhone</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Contact - Electronic Mail -->
  <sch:pattern>
    <sch:title>$loc/strings/ContactElectronicMail</sch:title>

    <sch:rule context="//gmd:contact/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert
        test="not($missing) and not($missingOtherLang)"

        >$loc/strings/ContactElectronicMail</sch:assert>

    </sch:rule>
  </sch:pattern>

  <!-- Contact - Hours of service -->
  <sch:pattern>
    <sch:title>$loc/strings/ContactHoursOfService</sch:title>

    <sch:rule context="//gmd:contact/*/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                " />
      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/ContactHoursOfService</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Contact - Role -->
  <sch:pattern>
    <sch:title>$loc/strings/MissingContactRole</sch:title>
    <sch:rule context="//gmd:contact/*/gmd:role">

      <sch:let name="roleCodelist" value="document(concat('file:///', $schemaDir, '/loc/', $lang, '/codelists.xml'))"/>

      <sch:let name="missing" value="not(string(gmd:CI_RoleCode/@codeListValue))
                 or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
        >$loc/strings/MissingContactRole</sch:assert>

    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>$loc/strings/InvalidContactRole</sch:title>
    <sch:rule context="//gmd:contact/*/gmd:role">

      <sch:let name="roleCodelist" value="document(concat('file:///', $schemaDir, '/loc/', $lang, '/codelists.xml'))"/>

      <sch:let name="missing" value="not(string(gmd:CI_RoleCode/@codeListValue))
        or (@gco:nilReason)" />

      <sch:let name="value" value="gmd:CI_RoleCode/@codeListValue" />
      <sch:let name="isValid" value="count($roleCodelist/codelists/codelist[@name='gmd:CI_RoleCode']/entry[code=$value]) = 1" />

      <sch:assert
        test="$isValid or $missing"
        >$loc/strings/InvalidContactRole</sch:assert>

    </sch:rule>
  </sch:pattern>

  <!-- Cited responsible party  - Organisation Name -->
  <sch:pattern>
    <sch:title>$loc/strings/CitedResponsiblePartyOrganisationName</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />


      <sch:assert
        test="not($missing) and not($missingOtherLang)"
        >$loc/strings/CitedResponsiblePartyOrganisationName</sch:assert>

    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>$loc/strings/EC37GovEnglish</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName
          |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName
          |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName">
      <sch:let name="government-titles" value="document(concat('file:///', $thesaurusDir, '/local/thesauri/theme/EC_Government_Titles.rdf'))"/>

      <sch:let name="organisationName" value="gco:CharacterString" />
      <sch:let name="isGovernmentOfCanada" value="starts-with(lower-case($organisationName), 'government of canada') or starts-with(lower-case($organisationName), 'gouvernement du canada')" />
      <sch:let name="titleName" value="lower-case(normalize-space(tokenize($organisationName, ';')[2]))" />

      <sch:let name="missing" value="not(string(gco:CharacterString))
                    or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert test="($missing and $missingOtherLang) or ($isGovernmentOfCanada and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='en'])) = $titleName]) or
              string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='fr'])) = $titleName]))
              )">$loc/strings/EC37GovEnglish</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>$loc/strings/EC37GovFrench</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName
          |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName
          |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName">
      <sch:let name="government-titles" value="document(concat('file:///', $thesaurusDir, '/local/thesauri/theme/EC_Government_Titles.rdf'))"/>

      <sch:let name="organisationNameOtherLang" value="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString" />
      <sch:let name="isGovernmentOfCanadaOtherLang" value="starts-with(lower-case($organisationNameOtherLang), 'government of canada') or starts-with(lower-case($organisationNameOtherLang), 'gouvernement du canada')" />
      <sch:let name="titleNameOtherLang" value="lower-case(normalize-space(tokenize($organisationNameOtherLang, ';')[2]))" />

      <sch:let name="missing" value="not(string(gco:CharacterString))
                  or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert test="($missing and $missingOtherLang) or ($isGovernmentOfCanadaOtherLang and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='en'])) = $titleNameOtherLang]) or
              string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='fr'])) = $titleNameOtherLang]))
              )">$loc/strings/EC37GovFrench</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Cited responsible party  - Country  -->
  <sch:pattern>
      <sch:title>$loc/strings/ECCountry</sch:title>

      <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty//gmd:country
             |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty//gmd:country
             |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty//gmd:country">
        <sch:let name="country-values" value="document(concat('file:///', $thesaurusDir, '/local/thesauri/theme/EC_ISO_Countries.rdf'))"/>

        <sch:let name="countryName" value="lower-case(gco:CharacterString)" />
         <sch:let name="countryNameOtherLang" value="lower-case(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString)" />

          <sch:assert test="(not($countryName) or
                ($countryName and (string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang='en'])) = $countryName]) or
                string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang='fr'])) = $countryName]))))

                and

                (not($countryNameOtherLang) or
                            ($countryNameOtherLang and (string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang='en'])) = $countryNameOtherLang]) or
                            string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang='fr'])) = $countryNameOtherLang]))
                            ))">$loc/strings/ECCountry</sch:assert>
      </sch:rule>
    </sch:pattern>

  <!-- Cited Responsible Party - Position name -->
  <sch:pattern>
    <sch:title>$loc/strings/CitedResponsiblePartyPositionName</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:positionName
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:positionName
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:positionName">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
        >$loc/strings/CitedResponsiblePartyPositionName</sch:assert>

    </sch:rule>
  </sch:pattern>

  <!-- Cited Responsible Party - Phone -->
  <sch:pattern>
    <sch:title>$loc/strings/CitedResponsiblePartyPhone</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:phone/gmd:CI_Telephone/gmd:voice
              |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:phone/gmd:CI_Telephone/gmd:voice
              |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:phone/gmd:CI_Telephone/gmd:voice">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                " />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/CitedResponsiblePartyPhone</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Cited Responsible Party - Delivery point -->
  <sch:pattern>
    <sch:title>$loc/strings/CitedResponsiblePartyDeliveryPoint</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:CI_Contact//gmd:address/gmd:CI_Address/gmd:deliveryPoint
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:CI_Contact//gmd:address/gmd:CI_Address/gmd:deliveryPoint">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                " />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/CitedResponsiblePartyDeliveryPoint</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Cited Responsible Party - Electronic Mail -->
  <sch:pattern>
    <sch:title>$loc/strings/CitedResponsiblePartyElectronicMail</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress
                      |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress
                      |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">

    <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert
        test="not($missing) and not($missingOtherLang)"

        >$loc/strings/CitedResponsiblePartyElectronicMail</sch:assert>

    </sch:rule>
  </sch:pattern>

  <!-- Cited Responsible Party - Hours of service -->
  <sch:pattern>
    <sch:title>$loc/strings/CitedResponsiblePartyHoursOfService</sch:title>

    <sch:rule context="//gmd:identificationInfo/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:CI_Contact/gmd:hoursOfService
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:CI_Contact/gmd:hoursOfService">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                " />
      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/CitedResponsiblePartyHoursOfService</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Cited Responsible Party -  Role -->
  <sch:pattern>
    <sch:title>$loc/strings/MissingCitedResponsibleRole</sch:title>
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:role
      |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:role
      |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:role">

      <sch:let name="roleCodelist" value="document(concat('file:///', $schemaDir, '/loc/', $lang, '/codelists.xml'))"/>

      <sch:let name="missing" value="not(string(gmd:CI_RoleCode/@codeListValue))
        or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
        >$loc/strings/MissingCitedResponsibleRole</sch:assert>

    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>$loc/strings/InvalidCitedResponsibleRole</sch:title>
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:role
              |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:role
              |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:role">

      <sch:let name="roleCodelist" value="document(concat('file:///', $schemaDir, '/loc/', $lang, '/codelists.xml'))"/>

      <sch:let name="missing" value="not(string(gmd:CI_RoleCode/@codeListValue))
                 or (@gco:nilReason)" />

      <sch:let name="value" value="gmd:CI_RoleCode/@codeListValue" />
      <sch:let name="isValid" value="count($roleCodelist/codelists/codelist[@name='gmd:CI_RoleCode']/entry[code=$value]) = 1" />

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidCitedResponsibleRole</sch:assert>

    </sch:rule>
  </sch:pattern>

  <!-- Topic Category -->
  <sch:pattern>
    <sch:title>$loc/strings/EC10</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:topicCategory
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:topicCategory
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:topicCategory">

      <sch:let name="missing" value="not(string(gmd:MD_TopicCategoryCode))
                " />

      <sch:assert
        test="not($missing)"
        >$loc/strings/EC10</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Spatial Representation Type -->
  <sch:pattern>
    <sch:title>$loc/strings/SpatialRepresentation</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:spatialRepresentationType
                   |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:spatialRepresentationType
                   |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:spatialRepresentationType">

      <sch:let name="missing" value="not(string(gmd:MD_SpatialRepresentationTypeCode/@codeListValue))
                      " />

      <sch:assert
        test="not($missing)"
      >$loc/strings/SpatialRepresentation</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>$loc/strings/InvalidSpatialRepresentationType</sch:title>

    <sch:rule context="//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:spatialRepresentationType
                         |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:spatialRepresentationType
                         |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:spatialRepresentationType">

      <sch:let name="spatialRepresentationTypeCodelist" value="document(concat('file:///', $schemaDir, '/loc/', $lang, '/codelists.xml'))"/>

      <sch:let name="missing" value="not(string(gmd:MD_SpatialRepresentationTypeCode/@codeListValue))
                 or (@gco:nilReason)" />

      <sch:let name="value" value="gmd:MD_SpatialRepresentationTypeCode/@codeListValue" />
      <sch:let name="isValid" value="count($spatialRepresentationTypeCodelist/codelists/codelist[@name='gmd:MD_SpatialRepresentationTypeCode']/entry[code=$value]) = 1" />

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidSpatialRepresentationType</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Creation/revision dates -->
  <sch:pattern>
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
  </sch:pattern>

  <sch:pattern>
    <sch:title>$loc/strings/MissingDate</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date">

      <sch:let name="missing" value="not(string(*/text()))
                      " />

      <sch:assert
        test="not($missing)"
      >$loc/strings/MissingDate</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>$loc/strings/InvalidDateTypeCode</sch:title>
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:dateType
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:dateType
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:dateType">

      <sch:let name="dateTypeCodelist" value="document(concat('file:///', $schemaDir, '/loc/', $lang, '/codelists.xml'))"/>

      <sch:let name="missing" value="not(string(gmd:CI_DateTypeCode/@codeListValue))
                 or (@gco:nilReason)" />

      <sch:let name="value" value="gmd:CI_DateTypeCode/@codeListValue" />
      <sch:let name="isValid" value="count($dateTypeCodelist/codelists/codelist[@name='gmd:CI_DateTypeCode']/entry[code=$value]) = 1" />

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidDateTypeCode</sch:assert>

    </sch:rule>
  </sch:pattern>

  <!-- Keywords -->
  <sch:pattern>
    <sch:title>$loc/strings/EC36</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[not(string(gmd:thesaurusName/gmd:CI_Citation/@id))]/gmd:keyword">
      <sch:let name="missing" value="not(string(gco:CharacterString))
            or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert
        test="not($missing) and not($missingOtherLang)"
        >$loc/strings/EC36</sch:assert>

    </sch:rule>
  </sch:pattern>

  <!-- Constraints -->
  <sch:pattern>
    <sch:title>$loc/strings/EC8</sch:title>


    <sch:rule context="//gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints">

      <sch:let name="filledFine" value="(
                (string(gco:CharacterString) or string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))
                and (../gmd:accessConstraints/gmd:MD_RestrictionCode/@codeListValue = 'RI_609'
                or ../gmd:useConstraints/gmd:MD_RestrictionCode/@codeListValue = 'RI_609')) or

                (not(string(gco:CharacterString)) and not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))
                and (../gmd:accessConstraints/gmd:MD_RestrictionCode/@codeListValue != 'RI_609'
                and ../gmd:useConstraints/gmd:MD_RestrictionCode/@codeListValue != 'RI_609')
                )" />
      <sch:assert
        test="$filledFine"
        >$loc/strings/EC8</sch:assert>

    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>$loc/strings/EC11</sch:title>


    <sch:rule context="//gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation">

      <sch:let name="missing" value="not(string(gco:CharacterString) or string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert
        test="not($missing)"
        >$loc/strings/EC11</sch:assert>

    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>$loc/strings/EC12</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:accessConstraints">

      <sch:let name="missing" value="not(string(gmd:MD_RestrictionCode/@codeListValue))" />

      <sch:assert
        test="not($missing)"
        >$loc/strings/EC12</sch:assert>

    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>$loc/strings/EC13</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useConstraints">

      <sch:let name="missing" value="not(string(gmd:MD_RestrictionCode/@codeListValue))" />

      <sch:assert
        test="not($missing)"
        >$loc/strings/EC12</sch:assert>

    </sch:rule>
  </sch:pattern>

  <!-- Begin position -->
  <sch:pattern>
    <sch:title>$loc/strings/BeginDate</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/gml:beginPosition
      |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/gml:beginPosition
      |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/gml:beginPosition
      |//gmd:identificationInfo/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/*/gml:beginPosition
      |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/*/gml:beginPosition
      |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/*/gml:beginPosition">

      <sch:let name="missing" value="not(string(.))
                 " />

      <sch:assert test="not($missing)">$loc/strings/BeginDate</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>$loc/strings/BeginPositionFormat</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/gml:beginPosition
      |//*[@gco:isoType='gmd:MD_DataIdentification']/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/gml:beginPosition
      |//*[@gco:isoType='srv:SV_ServiceIdentification']/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/gml:beginPosition">

      <sch:let name="beginPosition" value="." />

      <sch:assert test="geonet:verifyDateFormat($beginPosition) &gt; 0">$loc/strings/BeginPositionFormat</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Xpaths include gml:TimePeriodTypeCHOICE_ELEMENT, added in editor -->
  <sch:pattern>
    <sch:title>$loc/strings/BeginPositionFormat</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/*/gml:beginPosition
      |//*[@gco:isoType='gmd:MD_DataIdentification']/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/*/gml:beginPosition
      |//*[@gco:isoType='srv:SV_ServiceIdentification']/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/*/gml:beginPosition">

      <sch:let name="beginPosition" value="." />

      <sch:assert test="geonet:verifyDateFormat($beginPosition) &gt; 0">$loc/strings/BeginPositionFormat</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- End position -->
  <sch:pattern>
    <sch:title>$loc/strings/EndPosition</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/gml:endPosition
      |//*[@gco:isoType='gmd:MD_DataIdentification']/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/gml:endPosition
      |//*[@gco:isoType='srv:SV_ServiceIdentification']/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/gml:endPosition">

      <sch:let name="endPosition" value="." />
      <sch:let name="beginPosition" value="../gml:beginPosition" />

      <sch:assert test="geonet:compareDates($endPosition, $beginPosition) &gt;= 0">$loc/strings/EndPosition</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Xpaths include gml:TimePeriodTypeCHOICE_ELEMENT, added in editor -->
  <sch:pattern>
    <sch:title>$loc/strings/EndPosition</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/*/gml:endPosition
      |//*[@gco:isoType='gmd:MD_DataIdentification']/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/*/gml:endPosition
      |//*[@gco:isoType='srv:SV_ServiceIdentification']/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/*/gml:endPosition">

      <sch:let name="endPosition" value="." />
      <sch:let name="beginPosition" value="../../*/gml:beginPosition" />

      <sch:assert test="geonet:compareDates($endPosition, $beginPosition) &gt;= 0">$loc/strings/EndPosition</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>$loc/strings/EndPositionFormat</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/gml:endPosition
      |//*[@gco:isoType='gmd:MD_DataIdentification']/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/gml:endPosition
      |//*[@gco:isoType='srv:SV_ServiceIdentification']/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/gml:endPosition">

      <sch:let name="endPosition" value="." />

      <sch:assert test="geonet:verifyDateFormat($endPosition) &gt; 0">$loc/strings/EndPositionFormat</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Xpaths include gml:TimePeriodTypeCHOICE_ELEMENT, added in editor -->
  <sch:pattern>
    <sch:title>$loc/strings/EndPositionFormat</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/*/gml:endPosition
      |//*[@gco:isoType='gmd:MD_DataIdentification']/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/*/gml:endPosition
      |//*[@gco:isoType='srv:SV_ServiceIdentification']/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/*/gml:endPosition">

      <sch:let name="endPosition" value="." />

      <sch:assert test="geonet:verifyDateFormat($endPosition) &gt; 0">$loc/strings/EndPositionFormat</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Distribution - Resources -->
  <sch:pattern>
    <sch:title>$loc/strings/EC9</sch:title>

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
  </sch:pattern>

  <!-- Distribution - Format -->
  <sch:pattern>
    <sch:title>$loc/strings/EC21</sch:title>

    <sch:rule context="//gmd:distributionInfo/*/gmd:distributionFormat/*/gmd:name">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
        >$loc/strings/EC21</sch:assert>

    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>$loc/strings/EC22</sch:title>

    <sch:rule context="//gmd:distributionInfo/*/gmd:distributionFormat/*/gmd:version">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
        >$loc/strings/EC22</sch:assert>

    </sch:rule>
  </sch:pattern>

  <!-- Distributor contact - Organisation Name -->
  <sch:pattern>
    <sch:title>$loc/strings/DistributorOrganisationName</sch:title>

    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:organisationName">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert
        test="not($missing) and not($missingOtherLang)"
        >$loc/strings/DistributorOrganisationName</sch:assert>

    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>$loc/strings/EC26GovEnglish</sch:title>

    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:organisationName">
      <sch:let name="government-titles" value="document(concat('file:///', $thesaurusDir, '/local/thesauri/theme/EC_Government_Titles.rdf'))"/>

      <sch:let name="organisationName" value="gco:CharacterString" />
      <sch:let name="isGovernmentOfCanada" value="starts-with(lower-case($organisationName), 'government of canada') or starts-with(lower-case($organisationName), 'gouvernement du canada')" />
      <sch:let name="titleName" value="lower-case(normalize-space(tokenize($organisationName, ';')[2]))" />

      <sch:let name="missing" value="not(string(gco:CharacterString))
                    or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert test="($missing and $missingOtherLang) or ($isGovernmentOfCanada and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='en'])) = $titleName]) or
              string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='fr'])) = $titleName]))
              )">$loc/strings/EC26GovEnglish</sch:assert>

    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>$loc/strings/EC26GovFrench</sch:title>

    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:organisationName">
      <sch:let name="government-titles" value="document(concat('file:///', $thesaurusDir, '/local/thesauri/theme/EC_Government_Titles.rdf'))"/>


      <sch:let name="organisationNameOtherLang" value="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString" />
      <sch:let name="isGovernmentOfCanadaOtherLang" value="starts-with(lower-case($organisationNameOtherLang), 'government of canada') or starts-with(lower-case($organisationNameOtherLang), 'gouvernement du canada')" />
      <sch:let name="titleNameOtherLang" value="lower-case(normalize-space(tokenize($organisationNameOtherLang, ';')[2]))" />

      <sch:let name="missing" value="not(string(gco:CharacterString))
                  or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert test="($missing and $missingOtherLang) or ($isGovernmentOfCanadaOtherLang and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='en'])) = $titleNameOtherLang]) or
              string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='fr'])) = $titleNameOtherLang]))
              )">$loc/strings/EC26GovFrench</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Distributor - Position name -->
  <sch:pattern>
    <sch:title>$loc/strings/DistributorPositionName</sch:title>

    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:positionName">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/DistributorPositionName</sch:assert>

    </sch:rule>
  </sch:pattern>

  <!-- Distributor contact - Country -->
  <sch:pattern>
      <sch:title>$loc/strings/ECCountry</sch:title>

       <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact//gmd:country">
        <sch:let name="country-values" value="document(concat('file:///', $thesaurusDir, '/local/thesauri/theme/EC_ISO_Countries.rdf'))"/>

        <sch:let name="countryName" value="lower-case(gco:CharacterString)" />
         <sch:let name="countryNameOtherLang" value="lower-case(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString)" />

        <sch:assert test="(not($countryName) or
              ($countryName and (string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang='en'])) = $countryName]) or
              string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang='fr'])) = $countryName]))))

              and

              (not($countryNameOtherLang) or
                          ($countryNameOtherLang and (string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang='en'])) = $countryNameOtherLang]) or
                          string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang='fr'])) = $countryNameOtherLang]))
                          ))">$loc/strings/ECCountry</sch:assert>

      </sch:rule>
    </sch:pattern>

  <!-- Distributor - Phone -->
  <sch:pattern>
    <sch:title>$loc/strings/DistributorPhone</sch:title>
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:contactInfo/*/gmd:phone/gmd:CI_Telephone/gmd:voice">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                " />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/DistributorPhone</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Distributor - Delivery point -->
  <sch:pattern>
    <sch:title>$loc/strings/DistributorDeliveryPoint</sch:title>
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:deliveryPoint">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                    or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert
              test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/DistributorDeliveryPoint</sch:assert>

    </sch:rule>
  </sch:pattern>

  <!-- Distributor - Electronic Mail -->
  <sch:pattern>
    <sch:title>$loc/strings/DistributorElectronicMail</sch:title>

    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert
        test="not($missing) and not($missingOtherLang)"

        >$loc/strings/DistributorElectronicMail</sch:assert>

    </sch:rule>
  </sch:pattern>

  <!-- Distributor - Hours of service -->
  <sch:pattern>
    <sch:title>$loc/strings/DistributorHoursOfService</sch:title>

    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                " />
      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/DistributorHoursOfService</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Distributor - Role -->
  <sch:pattern>
    <sch:title>$loc/strings/MissingDistributorRole</sch:title>
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:role">

      <xsl:message>InvalidDistributorRole check</xsl:message>
      <sch:let name="roleCodelist" value="document(concat('file:///', $schemaDir, '/loc/', $lang, '/codelists.xml'))"/>

      <sch:let name="missing" value="not(string(gmd:CI_RoleCode/@codeListValue))
        or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
        >$loc/strings/MissingDistributorRole</sch:assert>



    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>$loc/strings/InvalidDistributorRole</sch:title>
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:role">

      <xsl:message>InvalidDistributorRole check</xsl:message>
      <sch:let name="roleCodelist" value="document(concat('file:///', $schemaDir, '/loc/', $lang, '/codelists.xml'))"/>

      <sch:let name="missing" value="not(string(gmd:CI_RoleCode/@codeListValue))
                 or (@gco:nilReason)" />

      <sch:let name="value" value="gmd:CI_RoleCode/@codeListValue" />
      <sch:let name="isValid" value="count($roleCodelist/codelists/codelist[@name='gmd:CI_RoleCode']/entry[code=$value]) = 1" />

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidDistributorRole</sch:assert>

    </sch:rule>
  </sch:pattern>

  <!-- Distribution - Resources -->
  <sch:pattern>
    <sch:title>$loc/strings/EC23</sch:title>

    <sch:rule context="//gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine">

      <sch:let name="missingLanguageForMapService" value="not(string(@xlink:role)) and (lower-case(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString) = 'ogc:wms' or lower-case(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString) = 'esri rest: map service')" />

      <sch:assert
        test="not($missingLanguageForMapService)"
        >$loc/strings/EC23</sch:assert>

    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>$loc/strings/MapResourcesREST</sch:title>

    <!-- Online resource -->
    <sch:rule context="//gmd:distributionInfo/gmd:MD_Distribution">
      <sch:let name="smallcase" value="'abcdefghijklmnopqrstuvwxyz'" />
      <sch:let name="uppercase" value="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

      <sch:let name="mapRESTCount" value="count(gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role='urn:xml:lang:eng-CAN' and translate(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString, $uppercase, $smallcase) = 'esri rest: map service']) +
                count(gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role='urn:xml:lang:fra-CAN' and translate(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString, $uppercase, $smallcase) = 'esri rest: map service'])" />

        <sch:assert test="$mapRESTCount &lt;= 2">$loc/strings/MapResourcesRESTNumber</sch:assert>
        <sch:assert test="$mapRESTCount = 0 or $mapRESTCount = 2 or $mapRESTCount &gt; 2">$loc/strings/MapResourcesREST</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>$loc/strings/MapResourcesWMS</sch:title>

    <!-- Online resource -->
    <sch:rule context="//gmd:distributionInfo/gmd:MD_Distribution">
      <sch:let name="smallcase" value="'abcdefghijklmnopqrstuvwxyz'" />
      <sch:let name="uppercase" value="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

      <sch:let name="mapWMSCount" value="count(gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role='urn:xml:lang:eng-CAN' and translate(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString, $uppercase, $smallcase) = 'ogc:wms']) +
                count(gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role='urn:xml:lang:fra-CAN' and translate(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString, $uppercase, $smallcase) = 'ogc:wms'])" />

        <sch:assert test="$mapWMSCount &lt;= 2">$loc/strings/MapResourcesWMSNumber</sch:assert>
        <sch:assert test="$mapWMSCount = 0 or $mapWMSCount = 2 or $mapWMSCount &gt; 2">$loc/strings/MapResourcesWMS</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
      <sch:title>$loc/strings/ResourceDescription</sch:title>

      <sch:rule context="//gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine">
          <sch:let name="smallcase" value="'abcdefghijklmnopqrstuvwxyz'" />
          <sch:let name="uppercase" value="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
          <sch:let name="formats-list" value="document(concat('file:///', $thesaurusDir, '/local/thesauri/theme/EC_Resource_Formats.rdf'))"/>

          <sch:let name="description" value="gmd:CI_OnlineResource/gmd:description/gco:CharacterString" />
          <sch:let name="contentType" value="subsequence(tokenize($description, ';'), 1, 1)" />
          <sch:let name="format" value="subsequence(tokenize($description, ';'), 2, 1)" />
          <sch:let name="language" value="subsequence(tokenize($description, ';'), 3, 1)" />
          <sch:let name="language_present" value="geonet:values-in($language,
              ('eng', 'fra', 'spa', 'zxx'))"/>

          <sch:let name="descriptionTranslated" value="gmd:CI_OnlineResource/gmd:description/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString" />
          <sch:let name="contentTypeTranslated" value="subsequence(tokenize($descriptionTranslated, ';'), 1, 1)" />
          <sch:let name="languageTraslated" value="subsequence(tokenize($descriptionTranslated, ';'), 3, 1)" />

          <sch:let name="languageTranslated_present" value="geonet:values-in($language,
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
          <sch:let name="resourceFormatsList" value="geonet:resourceFormatsList($thesaurusDir)" />
          <sch:let name="locMsg" value="concat($loc/strings/ResourceDescriptionFormat, $resourceFormatsList)" />

          <sch:assert test="string($formats-list//rdf:Description[@rdf:about = concat('http://geonetwork-opensource.org/EC/resourceformat#', $format)]) and
                          string($formats-list//rdf:Description[@rdf:about = concat('http://geonetwork-opensource.org/EC/resourceformat#',$formatTranslated)])">$locMsg</sch:assert>

          <sch:assert test="normalize-space($language) != '' and normalize-space($languageTraslated) != ''">$loc/strings/ResourceDescriptionLanguage</sch:assert>

          <sch:assert test="$language_present and $languageTranslated_present">$loc/strings/ResourceDescriptionLanguage</sch:assert>
      </sch:rule>
  </sch:pattern>

  <!-- Supplemental information -->
  <sch:pattern>
    <sch:title>$loc/strings/EC27</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:supplementalInformation
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:supplementalInformation
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:supplementalInformation">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />


      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
        >$loc/strings/EC27</sch:assert>


    </sch:rule>
  </sch:pattern>

  <!-- Note (Other constraints) -->
  <sch:pattern>
    <sch:title>$loc/strings/EC31</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                " />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
        >$loc/strings/EC31</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- Online resource -->
  <!--<sch:rule context="//gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine">

      <sch:let name="missing" value="not(string(gmd:CI_OnlineResource/gmd:linkage/gmd:URL))
          or (@gco:nilReason)" />


      <sch:assert test="not($missing)">$loc/strings/Linkage</sch:assert>

      <sch:let name="missing1" value="not(string(gmd:CI_OnlineResource/gmd:name/gco:CharacterString) or string(gmd:CI_OnlineResource/gmd:name/gmx:MimeFileType))
          or (@gco:nilReason)" />
      <sch:let name="missingOtherLang1" value="not(string(gmd:CI_OnlineResource/gmd:name/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert test="not($missing1 and not($missingOtherLang1))">$loc/strings/Name_1</sch:assert>
      <sch:assert test="not($missingOtherLang1 and not($missing1))">$loc/strings/Name_2</sch:assert>

      <sch:let name="missing2" value="not(string(gmd:CI_OnlineResource/gmd:description/gco:CharacterString))
          or (@gco:nilReason)" />
      <sch:let name="missingOtherLang2" value="not(string(gmd:CI_OnlineResource/gmd:description/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

      <sch:assert test="not($missing2 and not($missingOtherLang2))">$loc/strings/Description_1</sch:assert>
      <sch:assert test="not($missingOtherLang2 and not($missing2))">$loc/strings/Description_2</sch:assert>
  </sch:rule>-->

  <!-- TODO: Check -->

  <sch:pattern>
    <sch:title>$loc/strings/OpenLicense</sch:title>

    <!-- Use Limitation -->
    <sch:rule context="//gmd:identificationInfo/gmd:MD_DataIdentification
            |//*[@gco:isoType='gmd:MD_DataIdentification']
            |//*[@gco:isoType='srv:SV_ServiceIdentification']">

      <sch:let name="openLicense" value="count(gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation[
                (normalize-space(gco:CharacterString) = 'Open Government Licence - Canada (http://open.canada.ca/en/open-government-licence-canada)' and
                normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']) = 'Licence du gouvernement ouvert - Canada (http://ouvert.canada.ca/fr/licence-du-gouvernement-ouvert-canada)') or
                (normalize-space(gco:CharacterString) = 'Licence du gouvernement ouvert - Canada (http://ouvert.canada.ca/fr/licence-du-gouvernement-ouvert-canada)' and
                normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng'])  = 'Open Government Licence - Canada (http://open.canada.ca/en/open-government-licence-canada)')])"/>

      <sch:assert
        test="$openLicense > 0"
        >$loc/strings/OpenLicense</sch:assert>

    </sch:rule>
  </sch:pattern>

 <!-- Contact -->
  <sch:pattern>
    <sch:title>$loc/strings/EC1</sch:title>

    <sch:rule context="//gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:organisationName">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />


      <sch:assert
        test="not($missing) and not($missingOtherLang)"
        >$loc/strings/EC1</sch:assert>

    </sch:rule>
  </sch:pattern>

  <!-- Thesaurus info -->
  <sch:pattern>
      <sch:rule context="//gmd:descriptiveKeywords">

          <sch:let name="thesaurusNamePresent" value="count(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation) > 0" />


          <sch:let name="missingTitle" value="not(string(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString))
              or (@gco:nilReason)" />

          <sch:let name="missingTitleOtherLang" value="not(string(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

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

          <sch:let name="missingOrganisationOtherLang" value="not(string(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:organisationName/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

          <sch:assert
              test="not($thesaurusNamePresent) or ($thesaurusNamePresent and not($missingOrganisation) and not($missingOrganisationOtherLang))"
              >$loc/strings/ECThesaurusOrg</sch:assert>

          <sch:let name="emailPresent" value="count(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress) > 0" />

          <sch:let name="missingEmail" value="not(string(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString))
              or (@gco:nilReason)" />

          <sch:let name="missingEmailOtherLang" value="not(string(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

          <sch:assert
              test="not($thesaurusNamePresent) or ($thesaurusNamePresent and (not($emailPresent) or ($emailPresent and not($missingEmail) and not($missingEmailOtherLang))))"
              >$loc/strings/ECThesaurusEmail</sch:assert>
      </sch:rule>
  </sch:pattern>

  <!-- Maintenance and frequency -->
  <sch:pattern>
    <sch:title>$loc/strings/MaintenanceFrequency</sch:title>

    <sch:rule context="//gmd:identificationInfo/*/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency
                   |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency
                   |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency">

      <sch:let name="missing" value="not(string(gmd:MD_MaintenanceFrequencyCode/@codeListValue))
               or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/MaintenanceFrequency</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>$loc/strings/InvalidMaintenanceFrequency</sch:title>
    <sch:rule context="//gmd:identificationInfo/*/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency
                   |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency
                   |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency">


      <sch:let name="maintenanceFrequencyCodelist" value="document(concat('file:///', $schemaDir, '/loc/', $lang, '/codelists.xml'))"/>

      <sch:let name="missing" value="not(string(gmd:MD_MaintenanceFrequencyCode/@codeListValue))
                 or (@gco:nilReason)" />

      <sch:let name="value" value="gmd:MD_MaintenanceFrequencyCode/@codeListValue" />
      <sch:let name="isValid" value="count($maintenanceFrequencyCodelist/codelists/codelist[@name='gmd:MD_MaintenanceFrequencyCode']/entry[code=$value]) = 1" />

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidMaintenanceFrequency</sch:assert>

    </sch:rule>
  </sch:pattern>

    <!-- Mandatory, if spatialRepresentionType in Data Identification is "vector," "grid" or "tin”. -->
    <sch:pattern>
        <sch:title>$loc/strings/ReferenceSystemInfo</sch:title>

        <sch:rule context="/gmd:MD_Metadata">
          <sch:let name="spatialRepresentationType" value="concat(//gmd:identificationInfo/*/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode/@codeListValue, '')" />

          <sch:let name="missing" value="not(gmd:referenceSystemInfo)
                " />

            <sch:assert
                test="(($spatialRepresentationType = 'RI_635' or $spatialRepresentationType = 'RI_636' or $spatialRepresentationType = 'RI_638') and not($missing)) or
                ($spatialRepresentationType != 'RI_635' and $spatialRepresentationType != 'RI_636' and $spatialRepresentationType != 'RI_638')"
                >$loc/strings/ReferenceSystemInfo</sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern>
        <sch:title>$loc/strings/ReferenceSystemInfoCode</sch:title>

        <sch:rule context="//gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code">
          <sch:let name="missing" value="not(string(gco:CharacterString))
                " />

            <sch:assert
                test="not($missing)"
                >$loc/strings/ReferenceSystemInfoCode</sch:assert>
        </sch:rule>
    </sch:pattern>
</sch:schema>
