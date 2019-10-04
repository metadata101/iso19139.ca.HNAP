<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" queryBinding="xslt2">

    <sch:title xmlns="http://www.w3.org/2001/XMLSchema">Schematron validation / GeoNetwork recommendations</sch:title>
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
    EC schematron rules:
    ============================================================= -->

    <sch:pattern name="GeneralContent">
        <sch:title>General content</sch:title>

        <!-- HierarchyLevel -->
        <sch:rule context="//gmd:hierarchyLevel">

           <sch:let name="missing" value="not(string(gmd:MD_ScopeCode/@codeListValue))
               or (@gco:nilReason)" />

           <sch:assert
               test="not($missing)"
               >$loc/strings/EC8</sch:assert>

        </sch:rule>

        <!-- MetadataStandardName -->
        <sch:rule context="//gmd:metadataStandardName">

          <sch:let name="correct" value="(gco:CharacterString = 'North American Profile of ISO 19115:2003 - Geographic information - Metadata' or
                      gco:CharacterString = 'Profil nord-américain de la norme ISO 19115:2003 - Information géographique - Métadonnées') and

                      (gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString = 'North American Profile of ISO 19115:2003 - Geographic information - Metadata' or
                       gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString = 'Profil nord-américain de la norme ISO 19115:2003 - Information géographique - Métadonnées')
                        " />

          <sch:assert
                  test="$correct"
          >$loc/strings/MetadataStandardName</sch:assert>
        </sch:rule>

        <!-- Date -->
        <sch:rule context="//gmd:identificationInfo/gmd:citation/*/gmd:date/gmd:CI_Date/gmd:date
                   |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:date/gmd:CI_Date/gmd:date
                   |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:date/gmd:CI_Date/gmd:date">

                   <sch:let name="missing" value="not(string(gco:Date))
                       or (@gco:nilReason)" />

                   <sch:assert
                       test="not($missing)"
                       >$loc/strings/EC6</sch:assert>

        </sch:rule>

        <!-- Date Type -->
        <sch:rule context="//gmd:identificationInfo/gmd:citation/*/gmd:date/gmd:CI_Date/gmd:dateType
                  |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:date/gmd:CI_Date/gmd:dateType
                  |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:date/gmd:CI_Date/gmd:dateType">

                  <sch:let name="missing" value="not(string(gmd:CI_DateTypeCode/@codeListValue))
                      or (@gco:nilReason)" />

                  <sch:assert
                      test="not($missing)"
                      >$loc/strings/EC7</sch:assert>

        </sch:rule>

      <!-- Creation/revision dates -->
      <sch:rule context="//gmd:identificationInfo/gmd:citation/gmd:CI_Citation
                     |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation
                     |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation">

        <sch:let name="missingPublication" value="count(gmd:date[gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'RI_367']) = 0" />

        <sch:assert
          test="not($missingPublication)"
          >$loc/strings/EC40</sch:assert>

        <sch:let name="missingCreation" value="count(gmd:date[gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'RI_366']) = 0" />

        <sch:assert
          test="not($missingCreation)"
          >$loc/strings/EC41</sch:assert>

      </sch:rule>

      <!-- Temporal extent -->
      <sch:rule context="//gmd:identificationInfo/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/gml:beginPosition
      |//*[@gco:isoType='gmd:MD_DataIdentification']/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/gml:beginPosition
      |//*[@gco:isoType='srv:SV_ServiceIdentification']/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/gml:beginPosition">

        <sch:let name="beginPosition" value="." />

        <sch:assert test="geonet:verifyDateFormat($beginPosition) &gt; 0">$loc/strings/BeginPositionFormat</sch:assert>
      </sch:rule>


      <sch:rule context="//gmd:identificationInfo/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/gml:endPosition
      |//*[@gco:isoType='gmd:MD_DataIdentification']/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/gml:endPosition
      |//*[@gco:isoType='srv:SV_ServiceIdentification']/*/gmd:extent/*/gmd:temporalElement/*/gmd:extent/gml:TimePeriod/gml:endPosition">

          <sch:let name="endPosition" value="." />
          <sch:let name="beginPosition" value="../gml:beginPosition" />

          <sch:assert test="geonet:verifyDateFormat($endPosition) &gt; 0">$loc/strings/EndPositionFormat</sch:assert>
          <sch:assert test="geonet:compareDates($endPosition, $beginPosition) &gt;= 0">$loc/strings/EndPosition</sch:assert>
      </sch:rule>


      <!-- Contact -->
      <sch:rule context="//gmd:contact/*/gmd:organisationName">

        <sch:let name="government-titles" value="document(concat('file:///', $thesaurusDir, '/local/thesauri/theme/EC_Government_Titles.rdf'))"/>
        <sch:let name="government-names" value="document(concat('file:///', $thesaurusDir, '/local/thesauri/theme/EC_Government_Names.rdf'))"/>


        <sch:let name="mdLang" value="tokenize(/gmd:MD_Metadata/gmd:language/gco:CharacterString, ';')[1]" />

        <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

        <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

        <sch:let name="organisationName" value="gco:CharacterString" />
        <sch:let name="isGovernmentOfCanada" value="starts-with(lower-case($organisationName), 'government of canada;') or starts-with(lower-case($organisationName), 'gouvernement du canada;')" />
        <sch:let name="titleName" value="lower-case(normalize-space(tokenize($organisationName, ';')[2]))" />

        <sch:let name="isGovernmentNameAllowed" value="(
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationName)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang='fr'])), ';'))]) or
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationName)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang='en'])), ';'))])
        )"/>

        <sch:assert test="($missing and $missingOtherLang) or ($isGovernmentNameAllowed and not($isGovernmentOfCanada)) or (not($isGovernmentNameAllowed) and not($isGovernmentOfCanada)) or ($isGovernmentOfCanada and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='en'])) = $titleName]) or
                string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='fr'])) = $titleName]))
                 )">$loc/strings/EC1GovEnglish</sch:assert>

        <sch:assert test="($missing and $missingOtherLang) or
                $isGovernmentNameAllowed
                ">$loc/strings/EC1GovAllowedEnglish</sch:assert>

        <sch:let name="organisationNameOtherLang" value="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']" />
        <sch:let name="isGovernmentOfCanadaOtherLang" value="starts-with(lower-case($organisationNameOtherLang), 'government of canada;') or starts-with(lower-case($organisationNameOtherLang), 'gouvernement du canada;')" />
        <sch:let name="titleNameOtherLang" value="lower-case(normalize-space(tokenize($organisationNameOtherLang, ';')[2]))" />
        <sch:let name="isGovernmentNameAllowedOtherLang" value="(
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationNameOtherLang)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang='fr'])), ';'))]) or
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationNameOtherLang)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang='en'])), ';'))])
        )"/>

        <sch:assert test="($missing and $missingOtherLang) or ($isGovernmentNameAllowedOtherLang and not($isGovernmentOfCanadaOtherLang)) or (not($isGovernmentNameAllowedOtherLang) and not($isGovernmentOfCanadaOtherLang)) or ($isGovernmentNameAllowedOtherLang and not($isGovernmentOfCanadaOtherLang)) or ($isGovernmentOfCanadaOtherLang and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='en'])) = $titleNameOtherLang]) or
                string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='fr'])) = $titleNameOtherLang]))
               )">$loc/strings/EC1GovFrench</sch:assert>
        <sch:assert test="($missing and $missingOtherLang) or
                $isGovernmentNameAllowedOtherLang
                ">$loc/strings/EC1GovAllowedFrench</sch:assert>
      </sch:rule>

      <!-- Country -->
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

      <!-- Role -->
      <sch:rule context="//gmd:contact/*/gmd:role">

        <sch:let name="missing" value="not(string(gmd:CI_RoleCode/@codeListValue))
                      or (@gco:nilReason)" />

        <sch:assert
          test="not($missing)"
          >$loc/strings/EC17</sch:assert>

      </sch:rule>

      <!-- Cited Responsible Contact -->
      <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName
                  |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName
                  |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName">

        <sch:let name="government-titles" value="document(concat('file:///', $thesaurusDir, '/local/thesauri/theme/EC_Government_Titles.rdf'))"/>
        <sch:let name="government-names" value="document(concat('file:///', $thesaurusDir, '/local/thesauri/theme/EC_Government_Names.rdf'))"/>


        <sch:let name="mdLang" value="tokenize(/gmd:MD_Metadata/gmd:language/gco:CharacterString, ';')[1]" />

        <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

        <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

        <sch:let name="organisationName" value="gco:CharacterString" />
        <sch:let name="isGovernmentOfCanada" value="starts-with(lower-case($organisationName), 'government of canada;') or starts-with(lower-case($organisationName), 'gouvernement du canada;')" />
        <sch:let name="titleName" value="lower-case(normalize-space(tokenize($organisationName, ';')[2]))" />

        <sch:let name="isGovernmentNameAllowed" value="(
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationName)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang='fr'])), ';'))]) or
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationName)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang='en'])), ';'))])
        )"/>

        <sch:assert test="($missing and $missingOtherLang) or ($isGovernmentNameAllowed and not($isGovernmentOfCanada)) or (not($isGovernmentNameAllowed) and not($isGovernmentOfCanada)) or ($isGovernmentOfCanada and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='en'])) = $titleName]) or
                string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='fr'])) = $titleName]))
                )">$loc/strings/EC37GovEnglish</sch:assert>

        <sch:assert test="($missing and $missingOtherLang) or
                $isGovernmentNameAllowed
                ">$loc/strings/EC37GovAllowedEnglish</sch:assert>

        <sch:let name="organisationNameOtherLang" value="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']" />
        <sch:let name="isGovernmentOfCanadaOtherLang" value="starts-with(lower-case($organisationNameOtherLang), 'government of canada;') or starts-with(lower-case($organisationNameOtherLang), 'gouvernement du canada;')" />
        <sch:let name="titleNameOtherLang" value="lower-case(normalize-space(tokenize($organisationNameOtherLang, ';')[2]))" />
        <sch:let name="isGovernmentNameAllowedOtherLang" value="(
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationNameOtherLang)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang='fr'])), ';'))]) or
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationNameOtherLang)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang='en'])), ';'))])
        )"/>

        <sch:assert test="($missing and $missingOtherLang) or ($isGovernmentNameAllowedOtherLang and not($isGovernmentOfCanadaOtherLang)) or (not($isGovernmentNameAllowedOtherLang) and not($isGovernmentOfCanadaOtherLang)) or ($isGovernmentNameAllowedOtherLang and not($isGovernmentOfCanadaOtherLang)) or ($isGovernmentOfCanadaOtherLang and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='en'])) = $titleNameOtherLang]) or
                string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='fr'])) = $titleNameOtherLang]))
                )">$loc/strings/EC37GovFrench</sch:assert>

        <sch:assert test="($missing and $missingOtherLang) or
                $isGovernmentNameAllowedOtherLang
                ">$loc/strings/EC37GovAllowedFrench</sch:assert>
      </sch:rule>

        <!-- Country -->
       <sch:rule context="//gmd:identificationInfo/gmd:citation/*/gmd:citedResponsibleParty//gmd:country
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


        <!-- Role -->
        <sch:rule context="//gmd:identificationInfo/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:role
                  |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:role
                  |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:role">

                  <sch:let name="missing" value="not(string(gmd:CI_RoleCode/@codeListValue))
                      or (@gco:nilReason)" />

                  <sch:assert
                      test="not($missing)"
                      >$loc/strings/EC36</sch:assert>

        </sch:rule>

        <!-- Distributor Contact - Organisation -->
      <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:organisationName">

        <sch:let name="government-titles" value="document(concat('file:///', $thesaurusDir, '/local/thesauri/theme/EC_Government_Titles.rdf'))"/>
        <sch:let name="government-names" value="document(concat('file:///', $thesaurusDir, '/local/thesauri/theme/EC_Government_Names.rdf'))"/>

        <sch:let name="mdLang" value="tokenize(/gmd:MD_Metadata/gmd:language/gco:CharacterString, ';')[1]" />

        <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

        <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

        <sch:let name="organisationName" value="gco:CharacterString" />
        <sch:let name="isGovernmentOfCanada" value="starts-with(lower-case($organisationName), 'government of canada;') or starts-with(lower-case($organisationName), 'gouvernement du canada;')" />
        <sch:let name="titleName" value="lower-case(normalize-space(tokenize($organisationName, ';')[2]))" />

        <sch:let name="isGovernmentNameAllowed" value="(
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationName)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang='fr'])), ';'))]) or
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationName)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang='en'])), ';'))])
        )"/>

        <sch:assert test="($missing and $missingOtherLang) or ($isGovernmentNameAllowed and not($isGovernmentOfCanada)) or (not($isGovernmentNameAllowed) and not($isGovernmentOfCanada)) or ($isGovernmentOfCanada and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='en'])) = $titleName]) or
                string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='fr'])) = $titleName]))
                )">$loc/strings/EC26GovEnglish</sch:assert>

        <sch:assert test="($missing and $missingOtherLang) or
                $isGovernmentNameAllowed
                ">$loc/strings/EC26GovAllowedEnglish</sch:assert>

        <sch:let name="organisationNameOtherLang" value="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']" />
        <sch:let name="isGovernmentOfCanadaOtherLang" value="starts-with(lower-case($organisationNameOtherLang), 'government of canada;') or starts-with(lower-case($organisationNameOtherLang), 'gouvernement du canada;')" />
        <sch:let name="titleNameOtherLang" value="lower-case(normalize-space(tokenize($organisationNameOtherLang, ';')[2]))" />
        <sch:let name="isGovernmentNameAllowedOtherLang" value="(
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationNameOtherLang)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang='fr'])), ';'))]) or
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationNameOtherLang)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang='en'])), ';'))])
        )"/>

        <sch:assert test="($missing and $missingOtherLang) or ($isGovernmentNameAllowedOtherLang and not($isGovernmentOfCanadaOtherLang)) or (not($isGovernmentNameAllowedOtherLang) and not($isGovernmentOfCanadaOtherLang)) or ($isGovernmentNameAllowedOtherLang and not($isGovernmentOfCanadaOtherLang)) or ($isGovernmentOfCanadaOtherLang and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='en'])) = $titleNameOtherLang]) or
                string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang='fr'])) = $titleNameOtherLang]))
               )">$loc/strings/EC26GovFrench</sch:assert>

        <sch:assert test="($missing and $missingOtherLang) or
                $isGovernmentNameAllowedOtherLang
                ">$loc/strings/EC26GovAllowedFrench</sch:assert>
      </sch:rule>

      <!-- Country -->
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

        <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:role">

                  <sch:let name="missing" value="not(string(gmd:CI_RoleCode/@codeListValue))
                      or (@gco:nilReason)" />

                  <sch:assert
                      test="not($missing)"
                      >$loc/strings/EC30</sch:assert>

        </sch:rule>

        <!-- Status -->
        <sch:rule context="//gmd:identificationInfo/*/gmd:status
                   |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:status
                   |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:status">

                   <sch:let name="missing" value="not(string(gmd:MD_ProgressCode/@codeListValue))
                       or (@gco:nilReason)" />

                   <sch:assert
                       test="not($missing)"
                       >$loc/strings/EC10</sch:assert>

        </sch:rule>

        <!-- Language -->
        <sch:rule context="//gmd:identificationInfo/*/gmd:language
                   |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:language
                   |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:language">

                   <sch:let name="missing" value="not(string(gco:CharacterString))
                       or (@gco:nilReason)" />

                   <sch:assert
                       test="not($missing)"
                       >$loc/strings/EC19</sch:assert>

        </sch:rule>

        <!-- Topic category -->
        <sch:rule context="//gmd:identificationInfo/*/gmd:topicCategory
                   |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:topicCategory
                   |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:topicCategory">

                   <sch:let name="missing" value="not(string(gmd:MD_TopicCategoryCode))
                      " />

                   <sch:assert
                       test="not($missing)"
                       >$loc/strings/EC12</sch:assert>
        </sch:rule>

        <!-- Maintenance and frequency -->
        <sch:rule context="//gmd:identificationInfo/*/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency
                   |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency
                   |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency">

                   <sch:let name="missing" value="not(string(gmd:MD_MaintenanceFrequencyCode/@codeListValue))
                       or (@gco:nilReason)" />

                   <sch:assert
                       test="not($missing)"
                       >$loc/strings/EC11</sch:assert>

        </sch:rule>

        <!-- Spatial representation type -->
        <sch:rule context="//gmd:identificationInfo/*/gmd:spatialRepresentationType
                    |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:spatialRepresentationType
                    |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:spatialRepresentationType">

                    <sch:let name="missing" value="not(string(gmd:MD_SpatialRepresentationTypeCode/@codeListValue))
                        or (@gco:nilReason)" />

                    <sch:assert
                        test="not($missing)"
                        >$loc/strings/EC22</sch:assert>

         </sch:rule>

        <!-- Access constraints -->
        <sch:rule context="//gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:accessConstraints
                |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:accessConstraints
                |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:accessConstraints">

                <sch:let name="missing" value="not(string(gmd:MD_RestrictionCode/@codeListValue))
                    or (@gco:nilReason)" />

                <sch:assert
                    test="not($missing)"
                    >$loc/strings/EC23</sch:assert>

                <sch:let name="accessConstraintsCodelist" value="document(concat('file:///', $schemaDir, '/loc/', $lang, '/codelists.xml'))"/>

                <sch:let name="value" value="gmd:MD_RestrictionCode/@codeListValue" />
                <sch:let name="isValid" value="count($accessConstraintsCodelist/codelists/codelist[@name='gmd:MD_RestrictionCode']/entry[code=$value]) = 1" />

                <sch:assert
                  test="$isValid or $missing"
                >$loc/strings/InvalidAccessConstraints</sch:assert>

        </sch:rule>

        <!-- Use constraints -->
        <sch:rule context="//gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useConstraints
                  |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useConstraints
                  |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useConstraints">

          <sch:let name="missing" value="not(string(gmd:MD_RestrictionCode/@codeListValue))
                      or (@gco:nilReason)" />

          <sch:assert
            test="not($missing)"
            >$loc/strings/EC24</sch:assert>

          <sch:let name="useConstraintsCodelist" value="document(concat('file:///', $schemaDir, '/loc/', $lang, '/codelists.xml'))"/>

          <sch:let name="value" value="gmd:MD_RestrictionCode/@codeListValue" />
          <sch:let name="isValid" value="count($useConstraintsCodelist/codelists/codelist[@name='gmd:MD_RestrictionCode']/entry[code=$value]) = 1" />

          <sch:assert
            test="$isValid or $missing"
          >$loc/strings/InvalidUseConstraints</sch:assert>
        </sch:rule>

        <!-- Temporal extent -->
        <sch:rule context="//gmd:identificationInfo/*/gmd:extent/*/gmd:temporalElement/gmd:EX_TemporalExtent/*/gml:TimePeriod
                              |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:extent/*/gmd:temporalElement/gmd:EX_TemporalExtent/*/gml:TimePeriod
                              |//*[@gco:isoType='srv:SV_ServiceIdentification']/*/gmd:extent/*/gmd:temporalElement/gmd:EX_TemporalExtent/*/gml:TimePeriod">

                              <sch:let name="missing" value="not(string(gml:beginPosition))
                                  or (@gco:nilReason)" />

                              <sch:assert
                                  test="not($missing)"
                                  >$loc/strings/EC20</sch:assert>
        </sch:rule>

        <!-- Geographical extent -->
        <sch:rule context="//gmd:identificationInfo/*/gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox
                              |//*[@gco:isoType='gmd:MD_DataIdentification']/*/gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox
                              |//*[@gco:isoType='srv:SV_ServiceIdentification']/*/gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox">

                              <sch:let name="missing" value="(not(string(gmd:westBoundLongitude/gco:Decimal))
                                  or not(string(gmd:eastBoundLongitude/gco:Decimal))
                                  or not(string(gmd:southBoundLatitude/gco:Decimal))
                                  or not(string(gmd:northBoundLatitude/gco:Decimal)))
                                  or (@gco:nilReason)" />

                              <sch:assert
                                  test="not($missing)"
                                  >$loc/strings/EC21</sch:assert>
        </sch:rule>

       <!-- Spatial reference code -->
       <sch:rule context="//gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code">

                 <sch:let name="missing" value="not(string(gco:CharacterString))
                    " />

                 <sch:assert
                     test="not($missing)"
                     >$loc/strings/EC33</sch:assert>
      </sch:rule>

      <!-- Spatial reference codespace -->
      <!--<sch:rule context="//gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:codeSpace">

                 <sch:let name="missing" value="not(string(gco:CharacterString))
                    " />

                 <sch:assert
                     test="not($missing)"
                     >$loc/strings/EC34</sch:assert>
      </sch:rule>-->

      <!-- Online resource -->
      <sch:rule context="//gmd:distributionInfo/gmd:MD_Distribution">
        <sch:let name="smallcase" value="'abcdefghijklmnopqrstuvwxyz'" />
        <sch:let name="uppercase" value="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

        <sch:let name="mapRESTCount" value="count(gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role='urn:xml:lang:eng-CAN' and translate(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString, $uppercase, $smallcase) = 'esri rest: map service']) +
                count(gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role='urn:xml:lang:fra-CAN' and translate(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString, $uppercase, $smallcase) = 'esri rest: map service'])" />

        <sch:let name="mapWMSCount" value="count(gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role='urn:xml:lang:eng-CAN' and translate(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString, $uppercase, $smallcase) = 'ogc:wms']) +
                count(gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role='urn:xml:lang:fra-CAN' and translate(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString, $uppercase, $smallcase) = 'ogc:wms'])" />

        <sch:assert test="$mapRESTCount &lt;= 2">$loc/strings/MapResourcesRESTNumber</sch:assert>
        <sch:assert test="$mapRESTCount = 0 or $mapRESTCount = 2 or $mapRESTCount &gt; 2">$loc/strings/MapResourcesREST</sch:assert>
        <sch:assert test="$mapWMSCount &lt;= 2">$loc/strings/MapResourcesWMSNumber</sch:assert>
        <sch:assert test="$mapWMSCount = 0 or $mapWMSCount = 2 or $mapWMSCount &gt; 2">$loc/strings/MapResourcesWMS</sch:assert>
      </sch:rule>

      <!-- Online resource description -->
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

      <!-- Distribution format -->
      <sch:rule context="//gmd:distributionInfo/*/gmd:distributionFormat/*/gmd:name">

        <sch:let name="missing" value="not(string(gco:CharacterString))
                  or (@gco:nilReason)" />

        <sch:assert
          test="not($missing)"
          >$loc/strings/EC38</sch:assert>

        <sch:let name="distribution-formats" value="document(concat('file:///', $thesaurusDir, '/local/thesauri/theme/EC_Resource_Formats.rdf'))"/>

        <sch:let name="distributionFormat" value="gco:CharacterString" />

        <sch:assert test="($missing) or (string($distribution-formats//rdf:Description[normalize-space(ns2:prefLabel[@xml:lang='en']) = $distributionFormat]))">$loc/strings/DistributionFormatInvalid</sch:assert>
      </sch:rule>

      <sch:rule context="//gmd:distributionInfo/*/gmd:distributionFormat/*/gmd:version">

        <sch:let name="missing" value="not(string(gco:CharacterString))
                  or (@gco:nilReason)" />

        <sch:assert
          test="not($missing)"
          >$loc/strings/EC39</sch:assert>

      </sch:rule>

      <!-- Thesaurus info -->
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


      <sch:rule context="//gmd:identificationInfo/gmd:MD_DataIdentification
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:MD_DataIdentification
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/srv:SV_ServiceIdentification">


        <sch:let name="missing" value="not(gmd:spatialRepresentationType)" />

        <sch:assert
                test="not($missing)"
        >$loc/strings/SpatialRepresentation</sch:assert>
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
    </sch:pattern>

    <sch:pattern name="Optional">
        <sch:title>Optional</sch:title>

        <!-- Supplemental information -->
        <sch:rule context="//gmd:identificationInfo/*/gmd:supplementalInformation
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:supplementalInformation
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:supplementalInformation">

            <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

             <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))" />


                <!--<sch:assert test="(not($missing and not($missingOtherLang)) and
                                               not($missingOtherLang and not($missing)))">$loc/strings/SupplementalInformation</sch:assert>-->
                <sch:assert test="not($missing and not($missingOtherLang))">$loc/strings/SupplementalInformation_1</sch:assert>
                <sch:assert test="not($missingOtherLang and not($missing))">$loc/strings/SupplementalInformation_2</sch:assert>

        </sch:rule>

      <!-- Contact -->

      <!-- Position name -->
      <sch:rule context="//gmd:contact/*/gmd:positionName">

        <sch:let name="missing" value="not(string(gco:CharacterString))
               " />

        <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))" />

        <!--<sch:assert test="(not($missing and not($missingOtherLang)) and
                                                       not($missingOtherLang and not($missing)))">$loc/strings/HoursOfService</sch:assert>-->
        <sch:assert test="not($missing and not($missingOtherLang))">$loc/strings/PositionName_1</sch:assert>
        <sch:assert test="not($missingOtherLang and not($missing))">$loc/strings/PositionName_2</sch:assert>
      </sch:rule>

      <!-- Hours of service -->
      <sch:rule context="//gmd:contact/*/gmd:contactInfo//gmd:CI_Contact/gmd:hoursOfService">

         <sch:let name="missing" value="not(string(gco:CharacterString))
             " />

         <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))" />

          <!--<sch:assert test="(not($missing and not($missingOtherLang)) and
                                                         not($missingOtherLang and not($missing)))">$loc/strings/HoursOfService</sch:assert>-->
          <sch:assert test="not($missing and not($missingOtherLang))">$loc/strings/HoursOfService_1</sch:assert>
          <sch:assert test="not($missingOtherLang and not($missing))">$loc/strings/HoursOfService_2</sch:assert>
      </sch:rule>

		 <!-- Delivery point -->
		 <sch:rule context="//gmd:contact/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:deliveryPoint">

			<sch:let name="missing" value="not(string(gco:CharacterString))
				" />

			<sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))" />

			 <!--<sch:assert test="(not($missing and not($missingOtherLang)) and
															not($missingOtherLang and not($missing)))">$loc/strings/HoursOfService</sch:assert>-->
			 <sch:assert test="not($missing and not($missingOtherLang))">$loc/strings/DeliveryPoint_1</sch:assert>
			 <sch:assert test="not($missingOtherLang and not($missing))">$loc/strings/DeliveryPoint_2</sch:assert>
		 </sch:rule>

      <!-- Phone -->
      <sch:rule context="//gmd:contact/*/gmd:contactInfo/*/gmd:phone/gmd:CI_Telephone/gmd:voice">

        <sch:let name="missing" value="not(string(gco:CharacterString))
				" />

        <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))" />

        <!--<sch:assert test="(not($missing and not($missingOtherLang)) and
                               not($missingOtherLang and not($missing)))">$loc/strings/HoursOfService</sch:assert>-->
        <sch:assert test="not($missing and not($missingOtherLang))">$loc/strings/Phone_1</sch:assert>
        <sch:assert test="not($missingOtherLang and not($missing))">$loc/strings/Phone_2</sch:assert>
      </sch:rule>

      <!-- Cited Responsible Contact -->
      <!-- Hours of service -->
      <sch:rule context="//gmd:identificationInfo/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService
                |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService
                |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService">

        <sch:let name="missing" value="not(string(gco:CharacterString))
               " />

        <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))" />

        <!--<sch:assert test="(not($missing and not($missingOtherLang)) and
                                                       not($missingOtherLang and not($missing)))">$loc/strings/HoursOfService</sch:assert>-->
        <sch:assert test="not($missing and not($missingOtherLang))">$loc/strings/HoursOfServiceCited_1</sch:assert>
        <sch:assert test="not($missingOtherLang and not($missing))">$loc/strings/HoursOfServiceCited_2</sch:assert>
      </sch:rule>

      <!-- Delivery point -->
      <sch:rule context="//gmd:identificationInfo/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:deliveryPoint
                |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:deliveryPoint
                |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:deliveryPoint">

        <sch:let name="missing" value="not(string(gco:CharacterString))
				" />

        <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))" />

        <!--<sch:assert test="(not($missing and not($missingOtherLang)) and
                               not($missingOtherLang and not($missing)))">$loc/strings/HoursOfService</sch:assert>-->
        <sch:assert test="not($missing and not($missingOtherLang))">$loc/strings/DeliveryPointCited_1</sch:assert>
        <sch:assert test="not($missingOtherLang and not($missing))">$loc/strings/DeliveryPointCited_2</sch:assert>
      </sch:rule>



      <!-- Phone -->
      <sch:rule context="//gmd:identificationInfo/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:phone/gmd:CI_Telephone/gmd:voice
                |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:phone/gmd:CI_Telephone/gmd:voice
                |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:phone/gmd:CI_Telephone/gmd:voice">

        <sch:let name="missing" value="not(string(gco:CharacterString))
				" />

        <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))" />

        <!--<sch:assert test="(not($missing and not($missingOtherLang)) and
                               not($missingOtherLang and not($missing)))">$loc/strings/HoursOfService</sch:assert>-->
        <sch:assert test="not($missing and not($missingOtherLang))">$loc/strings/PhoneCited_1</sch:assert>
        <sch:assert test="not($missingOtherLang and not($missing))">$loc/strings/PhoneCited_2</sch:assert>
      </sch:rule>

      <!-- Distributor Contact -->
      <!-- Position name -->
      <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:positionName">

        <sch:let name="missing" value="not(string(gco:CharacterString))
               " />

        <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))" />

        <!--<sch:assert test="(not($missing and not($missingOtherLang)) and
                                                       not($missingOtherLang and not($missing)))">$loc/strings/HoursOfService</sch:assert>-->
        <sch:assert test="not($missing and not($missingOtherLang))">$loc/strings/PositionNameDist_1</sch:assert>
        <sch:assert test="not($missingOtherLang and not($missing))">$loc/strings/PositionNameDist_2</sch:assert>
      </sch:rule>

      <!-- Hours of service -->
      <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService">

        <sch:let name="missing" value="not(string(gco:CharacterString))
               " />

        <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))" />

        <!--<sch:assert test="(not($missing and not($missingOtherLang)) and
                                                       not($missingOtherLang and not($missing)))">$loc/strings/HoursOfService</sch:assert>-->
        <sch:assert test="not($missing and not($missingOtherLang))">$loc/strings/HoursOfServiceDist_1</sch:assert>
        <sch:assert test="not($missingOtherLang and not($missing))">$loc/strings/HoursOfServiceDist_2</sch:assert>
      </sch:rule>

      <!-- Delivery point -->
      <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:deliveryPoint">

        <sch:let name="missing" value="not(string(gco:CharacterString))
				" />

        <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))" />

        <!--<sch:assert test="(not($missing and not($missingOtherLang)) and
                               not($missingOtherLang and not($missing)))">$loc/strings/HoursOfService</sch:assert>-->
        <sch:assert test="not($missing and not($missingOtherLang))">$loc/strings/DeliveryPointDist_1</sch:assert>
        <sch:assert test="not($missingOtherLang and not($missing))">$loc/strings/DeliveryPointDist_2</sch:assert>
      </sch:rule>

      <!-- Delivery point -->
      <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:contactInfo/*/gmd:phone/gmd:CI_Telephone/gmd:voice">

        <sch:let name="missing" value="not(string(gco:CharacterString))
				" />

        <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))" />

        <!--<sch:assert test="(not($missing and not($missingOtherLang)) and
                               not($missingOtherLang and not($missing)))">$loc/strings/HoursOfService</sch:assert>-->
        <sch:assert test="not($missing and not($missingOtherLang))">$loc/strings/PhoneDist_1</sch:assert>
        <sch:assert test="not($missingOtherLang and not($missing))">$loc/strings/PhoneDist_2</sch:assert>
      </sch:rule>



      <!-- Note (Other constraints) -->
        <sch:rule context="//gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints
           |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints
           |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints">

           <sch:let name="missing" value="not(string(gco:CharacterString))
               " />

           <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))" />

            <!--<sch:assert test="(not($missing and not($missingOtherLang)) and
                                                           not($missingOtherLang and not($missing)))">$loc/strings/HoursOfService</sch:assert>-->
            <sch:assert test="not($missing and not($missingOtherLang))">$loc/strings/Note_1</sch:assert>
            <sch:assert test="not($missingOtherLang and not($missing))">$loc/strings/Note_2</sch:assert>
        </sch:rule>


        <!-- Online resource -->
        <sch:rule context="//gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine">

            <sch:let name="missing" value="not(string(gmd:CI_OnlineResource/gmd:linkage/gmd:URL))
                or (@gco:nilReason)" />

            <!--<sch:assert test="(not($missing and not($missingOtherLang)) and
                                           not($missingOtherLang and not($missing)))">$loc/strings/Linkage</sch:assert>-->
            <sch:assert test="not($missing)">$loc/strings/Linkage</sch:assert>

            <sch:let name="missing1" value="not(string(gmd:CI_OnlineResource/gmd:name/gco:CharacterString) or string(gmd:CI_OnlineResource/gmd:name/gmx:MimeFileType))
                or (@gco:nilReason)" />
            <sch:let name="missingOtherLang1" value="not(string(gmd:CI_OnlineResource/gmd:name/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

            <!--<sch:assert test="(not($missing1 and not($missingOtherLang1)) and
                                           not($missingOtherLang1 and not($missing1)))">$loc/strings/Name</sch:assert>-->
            <sch:assert test="not($missing1 and not($missingOtherLang1))">$loc/strings/Name_1</sch:assert>
            <sch:assert test="not($missingOtherLang1 and not($missing1))">$loc/strings/Name_2</sch:assert>

            <sch:let name="missing2" value="not(string(gmd:CI_OnlineResource/gmd:description/gco:CharacterString))
                or (@gco:nilReason)" />
            <sch:let name="missingOtherLang2" value="not(string(gmd:CI_OnlineResource/gmd:description/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString))" />

            <!--<sch:assert test="(not($missing2 and not($missingOtherLang2)) and
                                           not($missingOtherLang2 and not($missing2)))">$loc/strings/Description</sch:assert>-->
            <sch:assert test="not($missing2 and not($missingOtherLang2))">$loc/strings/Description_1</sch:assert>
            <sch:assert test="not($missingOtherLang2 and not($missing2))">$loc/strings/Description_2</sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern name="External">
      <sch:title>External</sch:title>

      <!-- Use Limitation -->
      <sch:rule context="//gmd:identificationInfo/gmd:MD_DataIdentification
              |//*[@gco:isoType='gmd:MD_DataIdentification']
              |//*[@gco:isoType='srv:SV_ServiceIdentification']">

        <sch:let name="openLicense" value="count(gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation[
                (normalize-space(gco:CharacterString) = 'Open Government Licence - Canada (http://open.canada.ca/en/open-government-licence-canada)' and
                normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']) = 'Licence du gouvernement ouvert - Canada (http://ouvert.canada.ca/fr/licence-du-gouvernement-ouvert-canada)') or

                (normalize-space(gco:CharacterString) = 'Licence du gouvernement ouvert - Canada (http://ouvert.canada.ca/fr/licence-du-gouvernement-ouvert-canada)' and
                normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng'])  = 'Open Government Licence - Canada (http://open.canada.ca/en/open-government-licence-canada)') or

                (normalize-space(gco:CharacterString) = 'Open Government Licence - British Columbia (https://www2.gov.bc.ca/gov/content/data/open-data/open-government-licence-bc)' and
                normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']) = 'Licence du gouvernement ouvert - Colombie-Britannique (https://www2.gov.bc.ca/gov/content/data/open-data/open-government-licence-bc)') or

                (normalize-space(gco:CharacterString) = 'Licence du gouvernement ouvert - Colombie-Britannique (https://www2.gov.bc.ca/gov/content/data/open-data/open-government-licence-bc)' and
                normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng'])  = 'Open Government Licence - British Columbia (https://www2.gov.bc.ca/gov/content/data/open-data/open-government-licence-bc)') or

                (normalize-space(gco:CharacterString) = 'Open Government Licence - Alberta (https://open.alberta.ca/licence)' and
                normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']) = 'Licence du gouvernement ouvert - Alberta (https://open.alberta.ca/licence)') or

                (normalize-space(gco:CharacterString) = 'Licence du gouvernement ouvert - Alberta (https://open.alberta.ca/licence)' and
                normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng'])  = 'Open Government Licence - Alberta (https://open.alberta.ca/licence)') or

                (normalize-space(gco:CharacterString) = 'Open Government Licence – Newfoundland and Labrador (https://opendata.gov.nl.ca/public/opendata/page/?page-id=licence)' and
                normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']) = 'Licence du gouvernement ouvert – Terre-Neuve-et-Labrador (https://opendata.gov.nl.ca/public/opendata/page/?page-id=licence)') or

                (normalize-space(gco:CharacterString) = 'Licence du gouvernement ouvert – Terre-Neuve-et-Labrador (https://opendata.gov.nl.ca/public/opendata/page/?page-id=licence)' and
                normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng'])  = 'Open Government Licence – Newfoundland and Labrador (https://opendata.gov.nl.ca/public/opendata/page/?page-id=licence)') or

                (normalize-space(gco:CharacterString) = 'Open Government Licence – Nova Scotia (https://novascotia.ca/opendata/licence.asp)' and
                normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']) = 'Licence du gouvernement ouvert – Nouvelle-Écosse (https://novascotia.ca/opendata/licence.asp)') or

                (normalize-space(gco:CharacterString) = 'Licence du gouvernement ouvert – Nouvelle-Écosse (https://novascotia.ca/opendata/licence.asp)' and
                normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng'])  = 'Open Government Licence – Nova Scotia (https://novascotia.ca/opendata/licence.asp)') or

                (normalize-space(gco:CharacterString) = 'Open Government Licence – Ontario (https://www.ontario.ca/page/open-government-licence-ontario)' and
                normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']) = 'Licence du gouvernement ouvert – Ontario (https://www.ontario.ca/fr/page/licence-du-gouvernement-ouvert-ontario)') or

                (normalize-space(gco:CharacterString) = 'Licence du gouvernement ouvert – Ontario (https://www.ontario.ca/fr/page/licence-du-gouvernement-ouvert-ontario)' and
                normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng'])  = 'Open Government Licence – Ontario (https://www.ontario.ca/page/open-government-licence-ontario)') or

                (normalize-space(gco:CharacterString) = 'Open Government Licence – Prince Edward Island (https://www.princeedwardisland.ca/en/information/finance/open-government-licence-prince-edward-island)' and
                normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']) = 'Licence du gouvernement ouvert – Île-du-Prince-Édouard (https://www.princeedwardisland.ca/fr/information/finances/licence-du-gouvernement-ouvert-ile-du-prince-edouard)') or

                (normalize-space(gco:CharacterString) = 'Licence du gouvernement ouvert – Île-du-Prince-Édouard (https://www.princeedwardisland.ca/fr/information/finances/licence-du-gouvernement-ouvert-ile-du-prince-edouard)' and
                normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng'])  = 'Open Government Licence – Prince Edward Island (https://www.princeedwardisland.ca/en/information/finance/open-government-licence-prince-edward-island)')
                ])"/>

        <sch:assert
          test="$openLicense > 0"
          >$loc/strings/OpenLicense</sch:assert>

      </sch:rule>
    </sch:pattern>

  <sch:pattern name="EnglishContent">
        <sch:title>English content</sch:title>

        <!-- Title -->
        <sch:rule context="//gmd:identificationInfo/gmd:citation/*/gmd:title
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:title
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:title">

            <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

            <sch:assert
                test="not($missing)"
                >$loc/strings/EC5English</sch:assert>

        </sch:rule>

      <!-- Contact - Electronic mail address -->
      <sch:rule context="//gmd:contact/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">

        <sch:let name="missing" value="not(string(gco:CharacterString))
                      or (@gco:nilReason)" />

        <sch:assert
          test="not($missing)"
          >$loc/strings/EC16English</sch:assert>

      </sch:rule>

      <!-- Contact - Organization name -->
        <sch:rule context="//gmd:contact/*/gmd:organisationName">
           <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

            <sch:assert
                test="not($missing)"
                >$loc/strings/EC1English</sch:assert>

        </sch:rule>

      <!-- Cited Responsible Contact - Electronic mail address -->
      <sch:rule context="//gmd:identificationInfo/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress
                |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress
                |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">

        <sch:let name="missing" value="not(string(gco:CharacterString))
                    or (@gco:nilReason)" />

        <sch:assert
          test="not($missing)"
          >$loc/strings/EC35English</sch:assert>

      </sch:rule>

        <!-- Cited Responsible Contact - Organization name -->
        <sch:rule context="//gmd:identificationInfo/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName
                  |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName
                  |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName">

          <sch:let name="missing" value="not(string(gco:CharacterString))
                  or (@gco:nilReason)" />

          <sch:assert
            test="not($missing)"
            >$loc/strings/EC37English</sch:assert>

        </sch:rule>


      <!-- Distributor Contact - Electronic mail address -->
      <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">

        <sch:let name="missing" value="not(string(gco:CharacterString))
                      or (@gco:nilReason)" />

        <sch:assert
          test="not($missing)"
          >$loc/strings/EC29English</sch:assert>

      </sch:rule>

      <!-- Distributor Contact - Organization name -->
        <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:organisationName">

            <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

            <sch:assert
                test="not($missing)"
                >$loc/strings/EC26English</sch:assert>

        </sch:rule>


        <!-- Abstract -->
        <sch:rule context="//gmd:identificationInfo/*/gmd:abstract
                   |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:abstract
                   |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:abstract">

                   <sch:let name="missing" value="not(string(gco:CharacterString))
                       or (@gco:nilReason)" />

                   <sch:assert
                       test="not($missing)"
                       >$loc/strings/EC9English</sch:assert>

        </sch:rule>


        <!-- Keywords -->
        <sch:rule context="//gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[not(string(gmd:thesaurusName/gmd:CI_Citation/@id))]/gmd:keyword
                   |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:descriptiveKeywords/gmd:MD_Keywords[not(string(gmd:thesaurusName/gmd:CI_Citation/@id))]/gmd:keyword
                   |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:descriptiveKeywords/gmd:MD_Keywords[not(string(gmd:thesaurusName/gmd:CI_Citation/@id))]/gmd:keyword">

                   <sch:let name="missing" value="not(string(gco:CharacterString))
                       or (@gco:nilReason)" />

                   <sch:assert
                       test="not($missing)"
                       >$loc/strings/EC25English</sch:assert>

        </sch:rule>

        <!-- Use limitation -->
         <sch:rule context="//gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation
                                                         |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation
                                                         |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation">

                   <sch:let name="missing" value="not(string(gco:CharacterString))
                       or (@gco:nilReason)" />

                   <sch:assert
                       test="not($missing)"
                       >$loc/strings/EC32English</sch:assert>

        </sch:rule>
    </sch:pattern>

    <sch:pattern name="FrenchContent">
        <sch:title>French content</sch:title>

        <!-- Title -->
        <sch:rule context="//gmd:identificationInfo/gmd:citation/*/gmd:title
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:title
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:title">

                <sch:let name="missing" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))
                " />

            <sch:assert
                test="not($missing)"
                >$loc/strings/EC5French</sch:assert>

        </sch:rule>

      <!-- Contact - Electronic mail address -->
      <sch:rule context="//gmd:contact/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">

        <sch:let name="missing" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))
                              " />

        <sch:assert
          test="not($missing)"
          >$loc/strings/EC16French</sch:assert>

      </sch:rule>


      <!-- Contact - Organization name -->
        <sch:rule context="//gmd:contact/*/gmd:organisationName">
          <sch:let name="missing" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))
                              " />

            <sch:assert
                test="not($missing)"
                >$loc/strings/EC1French</sch:assert>

        </sch:rule>

      <!-- Cited Responsible Contact - Electronic mail address -->
      <sch:rule context="//gmd:identificationInfo/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress
                |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress
                |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">

        <sch:let name="missing" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))
                              " />

        <sch:assert
          test="not($missing)"
          >$loc/strings/EC35French</sch:assert>

      </sch:rule>

        <!-- Cited Responsible Contact - Organization name -->
        <sch:rule context="//gmd:identificationInfo/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName
                    |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName
                    |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName">

          <sch:let name="missing" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))
                              " />

          <sch:assert
            test="not($missing)"
            >$loc/strings/EC37French</sch:assert>

        </sch:rule>

        <!-- Distributor Contact - Electronic mail address -->
        <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">

          <sch:let name="missing" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))
                                                " />

          <sch:assert
            test="not($missing)"
            >$loc/strings/EC29French</sch:assert>

        </sch:rule>

        <!-- Distributor Contact - Organization name -->
        <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:organisationName">

            <sch:let name="missing" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))
                                                " />

            <sch:assert
                test="not($missing)"
                >$loc/strings/EC26French</sch:assert>

        </sch:rule>


        <!-- Distributor Contact - Position name -->
        <!--<sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:positionName">

                    <sch:let name="missing" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))
                                                        " />
                   <sch:assert
                       test="not($missing)"
                       >$loc/strings/EC28French</sch:assert>

        </sch:rule>-->


        <!-- Abstract -->
        <sch:rule context="//gmd:identificationInfo/*/gmd:abstract
                   |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:abstract
                   |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:abstract">

                   <sch:let name="missing" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))
                       " />

                   <sch:assert
                       test="not($missing)"
                       >$loc/strings/EC9French</sch:assert>

        </sch:rule>

        <!-- Keywords -->
        <sch:rule context="//gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[not(string(gmd:thesaurusName/gmd:CI_Citation/@id))]/gmd:keyword
                   |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:descriptiveKeywords/gmd:MD_Keywords[not(string(gmd:thesaurusName/gmd:CI_Citation/@id))]/gmd:keyword
                   |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:descriptiveKeywords/gmd:MD_Keywords[not(string(gmd:thesaurusName/gmd:CI_Citation/@id))]/gmd:keyword">

                   <sch:let name="missing"  value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))
                       " />

                   <sch:assert
                       test="not($missing)"
                       >$loc/strings/EC25French</sch:assert>

        </sch:rule>

        <!-- Use limitation -->
         <sch:rule context="//gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation
                                                         |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation
                                                         |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation">

            <sch:let name="missing"  value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']))
                 " />

                   <sch:assert
                       test="not($missing)"
                       >$loc/strings/EC32French</sch:assert>

        </sch:rule>
    </sch:pattern>
</sch:schema>
