<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:geonet="http://www.fao.org/geonetwork"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            queryBinding="xslt2">

  <sch:title xmlns="http://www.w3.org/2001/XMLSchema">HNAP validation rules (multilingual)</sch:title>
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
  <sch:let name="altLanguage" value="if ($mainLanguage = 'eng') then 'fra' else 'eng'"/>
  <sch:let name="mainLanguageId" value="//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:locale/gmd:PT_Locale[gmd:languageCode/*/@codeListValue = $mainLanguage]/@id"/>
  <sch:let name="altLanguageId" value="//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:locale/gmd:PT_Locale[gmd:languageCode/*/@codeListValue != $mainLanguage and (gmd:languageCode/*/@codeListValue = 'eng' or gmd:languageCode/*/@codeListValue = 'fra')]/@id"/>
  <sch:let name="mainLanguage2char" value="if ($mainLanguage = 'fra') then 'fr' else 'en'"/>
  <sch:let name="altLanguage2char" value="if (lower-case($altLanguage) = 'fra') then 'fr' else 'en'"/>
  <sch:let name="mainLanguageText" value="if ($mainLanguage = 'fra') then 'French' else 'English'"/>
  <sch:let name="altLanguageText" value="if (lower-case($altLanguage) = 'fra') then 'French' else 'English'"/>

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

      <sch:let name="correct" value="(gco:CharacterString = 'North American Profile of ISO 19115:2003 - Geographic information - Metadata' or
                          gco:CharacterString = 'Profil nord-américain de la norme ISO 19115:2003 - Information géographique - Métadonnées') and

                      (gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)] = 'North American Profile of ISO 19115:2003 - Geographic information - Metadata' or
                       gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)] = 'Profil nord-américain de la norme ISO 19115:2003 - Information géographique - Métadonnées')
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

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="not($missing) and not($missingOtherLang)"
      >$loc/strings/ContactOrganisationName</sch:assert>

      <sch:let name="government-titles" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Departments.rdf'), '\\', '/')))"/>
      <sch:let name="government-names" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Org_Names.rdf'), '\\', '/')))"/>

      <sch:let name="organisationName" value="gco:CharacterString" />
      <sch:let name="isGovernmentOfCanada" value="starts-with(lower-case(normalize-space(tokenize($organisationName, ';')[1])), 'government of canada') or starts-with(lower-case(normalize-space(tokenize($organisationName, ';')[1])), 'gouvernement du canada')" />
      <sch:let name="titleName" value="lower-case(normalize-space(tokenize($organisationName, ';')[2]))" />



      <sch:let name="isGovernmentNameAllowed" value="(
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationName)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang=$altLanguage2char])), ';'))]) or
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationName)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang=$mainLanguage2char])), ';'))])
        )"/>

      <sch:let name="isErrorContactGovMain" value="not(($missing and $missingOtherLang) or ($isGovernmentNameAllowed and not($isGovernmentOfCanada)) or (not($isGovernmentNameAllowed) and not($isGovernmentOfCanada)) or ($isGovernmentOfCanada and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $titleName]) or
                string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang=$altLanguage2char])) = $titleName]))
                     ))"/>

      <sch:let name="isErrorContactGovMainAllowed" value="not($isErrorContactGovMain) and not(
                ($missing and $missingOtherLang) or
                $isGovernmentNameAllowed
                )"/>

      <sch:assert test="not($isErrorContactGovMain)">$loc/strings/*[name() = concat('ContactGov', $mainLanguageText)]</sch:assert>

      <sch:assert test="not($isErrorContactGovMainAllowed)">$loc/strings/*[name() = concat('ContactGovAllowed', $mainLanguageText)]</sch:assert>

      <sch:let name="organisationNameOtherLang" value="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]" />
      <sch:let name="isGovernmentOfCanadaOtherLang" value="starts-with(lower-case(normalize-space(tokenize($organisationNameOtherLang, ';')[1])), 'government of canada') or starts-with(lower-case(normalize-space(tokenize($organisationNameOtherLang, ';')[1])), 'gouvernement du canada')" />
      <sch:let name="titleNameOtherLang" value="lower-case(normalize-space(tokenize($organisationNameOtherLang, ';')[2]))" />
      <sch:let name="isGovernmentNameAllowedOtherLang" value="(
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationNameOtherLang)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang=$altLanguage2char])), ';'))]) or
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationNameOtherLang)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang=$mainLanguage2char])), ';'))])
        )"/>

      <sch:let name="isErrorContactGovAlt" value="not($isErrorContactGovMain or $isErrorContactGovMainAllowed) and not(
                ($missing and $missingOtherLang) or ($isGovernmentNameAllowed and not($isGovernmentOfCanada)) or (not($isGovernmentNameAllowed) and not($isGovernmentOfCanada)) or ($isGovernmentOfCanada and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $titleName]) or
                string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang=$altLanguage2char])) = $titleName]))
                     )
                 )"/>

      <sch:let name="isErrorContactGovAltAllowed" value="not($isErrorContactGovMain or $isErrorContactGovMainAllowed or $isErrorContactGovAlt)  and not(
                ($missing and $missingOtherLang) or
                $isGovernmentNameAllowed
                )"/>

      <sch:assert test="not($isErrorContactGovAlt)">$loc/strings/*[name() = concat('ContactGov', $altLanguageText)]</sch:assert>
      <sch:assert test="not($isErrorContactGovAltAllowed)">$loc/strings/*[name() = concat('ContactGovAllowed', $altLanguageText)]</sch:assert>

    </sch:rule>


    <!-- Contact - Position name -->
    <sch:rule context="//gmd:contact/*/gmd:positionName">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/ContactPositionName</sch:assert>

    </sch:rule>


    <!-- Contact - Country -->
    <sch:rule context="//gmd:contact//gmd:country">
      <sch:let name="country-values" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/ISO_Countries.rdf'), '\\', '/')))"/>

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


    <!-- Contact - Delivery point -->
    <sch:rule context="//gmd:contact/*/gmd:contactInfo//gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                " />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/ContactDeliveryPoint</sch:assert>
    </sch:rule>


    <!-- Contact - Phone -->
    <sch:rule context="//gmd:contact/*/gmd:contactInfo/*/gmd:phone/gmd:CI_Telephone/gmd:voice">

      <sch:let name="missing" value="not(string(gco:CharacterString))
              " />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/ContactPhone</sch:assert>
    </sch:rule>


    <!-- Contact - Electronic Mail -->
    <sch:rule context="//gmd:contact/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="not($missing) and not($missingOtherLang)"

      >$loc/strings/ContactElectronicMail</sch:assert>

    </sch:rule>


    <!-- Contact - Hours of service -->
    <sch:rule context="//gmd:contact/*/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                " />
      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/ContactHoursOfService</sch:assert>
    </sch:rule>


    <!-- Contact - Role -->
    <sch:rule context="//gmd:contact/*/gmd:role">

      <sch:let name="roleCodelistLabel"
                     value="tr:codelist-value-label(
                            tr:create($schema),
                            gmd:CI_RoleCode/local-name(),
                            gmd:CI_RoleCode/@codeListValue)"/>

      <sch:let name="missing" value="not(string(gmd:CI_RoleCode/@codeListValue))
                 or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/MissingContactRole</sch:assert>

      <sch:let name="isValid" value="($roleCodelistLabel != '') and ($roleCodelistLabel != gmd:CI_RoleCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidContactRole</sch:assert>

    </sch:rule>
  </sch:pattern>


  <!--- Data Identification pattern -->
  <sch:pattern>
    <sch:title>$loc/strings/DataIdentification</sch:title>

    <!-- Use Limitation -->
    <!-- Use Limitation -->
    <sch:rule context="//gmd:identificationInfo/gmd:MD_DataIdentification
        |//*[@gco:isoType='gmd:MD_DataIdentification']
        |//*[@gco:isoType='srv:SV_ServiceIdentification']">

      <sch:let name="open-licenses" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Open_Licenses.rdf'), '\\', '/')))"/>

      <sch:let name="openLicense" value="count(gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation[
            (normalize-space(gco:CharacterString) = $open-licenses//rdf:Description/ns2:prefLabel[@xml:lang=$mainLanguage2char]) and
            (normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]) = $open-licenses//rdf:Description/ns2:prefLabel[@xml:lang=$altLanguage2char])
            ])" />

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

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="not($missing) and not($missingOtherLang)"
        >$loc/strings/MetadataTitle</sch:assert>
    </sch:rule>


    <!-- Abstract -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:abstract
                     |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:abstract
                     |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:abstract">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                         or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="not($missing) and not($missingOtherLang)"
      >$loc/strings/MetadataAbstract</sch:assert>

    </sch:rule>


    <!-- Cited responsible party  - Organisation Name -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:organisationName">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />


      <sch:assert
        test="not($missing) and not($missingOtherLang)"
      >$loc/strings/CitedResponsiblePartyOrganisationName</sch:assert>

      <sch:let name="government-titles" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Departments.rdf'), '\\', '/')))"/>
      <sch:let name="government-names" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Org_Names.rdf'), '\\', '/')))"/>

      <sch:let name="organisationName" value="gco:CharacterString" />
      <sch:let name="isGovernmentOfCanada" value="starts-with(lower-case(normalize-space(tokenize($organisationName, ';')[1])), 'government of canada') or starts-with(lower-case(normalize-space(tokenize($organisationName, ';')[1])), 'gouvernement du canada')" />
      <sch:let name="titleName" value="lower-case(normalize-space(tokenize($organisationName, ';')[2]))" />

      <sch:let name="isGovernmentNameAllowed" value="(
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationName)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang=$altLanguage2char])), ';'))]) or
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationName)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang=$mainLanguage2char])), ';'))])
        )"/>

      <sch:assert test="($missing and $missingOtherLang) or ($isGovernmentNameAllowed and not($isGovernmentOfCanada)) or (not($isGovernmentNameAllowed) and not($isGovernmentOfCanada)) or ($isGovernmentOfCanada and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $titleName]) or
                string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang=$altLanguage2char])) = $titleName]))
              )">$loc/strings/*[name() = concat('CitedResponsibleContactGov', $mainLanguageText)]</sch:assert>

      <sch:assert test="($missing and $missingOtherLang) or
                $isGovernmentNameAllowed
                ">$loc/strings/*[name() = concat('CitedResponsibleContactGovAllowed', $mainLanguageText)]</sch:assert>

      <sch:let name="organisationNameOtherLang" value="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]" />
      <sch:let name="isGovernmentOfCanadaOtherLang" value="starts-with(lower-case(normalize-space(tokenize($organisationNameOtherLang, ';')[1])), 'government of canada') or starts-with(lower-case(normalize-space(tokenize($organisationNameOtherLang, ';')[1])), 'gouvernement du canada')" />
      <sch:let name="titleNameOtherLang" value="lower-case(normalize-space(tokenize($organisationNameOtherLang, ';')[2]))" />
      <sch:let name="isGovernmentNameAllowedOtherLang" value="(
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationNameOtherLang)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang=$altLanguage2char])), ';'))]) or
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationNameOtherLang)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang=$mainLanguage2char])), ';'))])
        )"/>

      <sch:assert test="($missing and $missingOtherLang) or ($isGovernmentNameAllowedOtherLang and not($isGovernmentOfCanadaOtherLang)) or (not($isGovernmentNameAllowedOtherLang) and not($isGovernmentOfCanadaOtherLang)) or ($isGovernmentNameAllowedOtherLang and not($isGovernmentOfCanadaOtherLang)) or ($isGovernmentOfCanadaOtherLang and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $titleNameOtherLang]) or
                string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang=$altLanguage2char])) = $titleNameOtherLang]))
              )">$loc/strings/*[name() = concat('CitedResponsibleContactGov', $altLanguageText)]</sch:assert>
      <sch:assert test="($missing and $missingOtherLang) or
                $isGovernmentNameAllowedOtherLang
                ">$loc/strings/*[name() = concat('CitedResponsibleContactGovAllowed', $altLanguageText)]</sch:assert>
    </sch:rule>


    <!-- Cited responsible party  - Country  -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty//gmd:country
             |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty//gmd:country
             |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty//gmd:country">
      <sch:let name="country-values" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/ISO_Countries.rdf'), '\\', '/')))"/>

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


    <!-- Cited Responsible Party - Position name -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:positionName
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:positionName
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:positionName">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/CitedResponsiblePartyPositionName</sch:assert>

    </sch:rule>


    <!-- Cited Responsible Party - Phone -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:phone/gmd:CI_Telephone/gmd:voice
              |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:phone/gmd:CI_Telephone/gmd:voice
              |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:phone/gmd:CI_Telephone/gmd:voice">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                " />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/CitedResponsiblePartyPhone</sch:assert>
    </sch:rule>

    <!-- Cited Responsible Party - Delivery point -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:CI_Contact//gmd:address/gmd:CI_Address/gmd:deliveryPoint
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:CI_Contact//gmd:address/gmd:CI_Address/gmd:deliveryPoint">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                " />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/CitedResponsiblePartyDeliveryPoint</sch:assert>
    </sch:rule>


    <!-- Cited Responsible Party - Electronic Mail -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress
                      |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress
                      |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="not($missing) and not($missingOtherLang)"

      >$loc/strings/CitedResponsiblePartyElectronicMail</sch:assert>

    </sch:rule>


    <!-- Cited Responsible Party - Hours of service -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:CI_Contact/gmd:hoursOfService
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:CI_Contact/gmd:hoursOfService">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                " />
      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/CitedResponsiblePartyHoursOfService</sch:assert>
    </sch:rule>


    <!-- Keywords -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword">
      <sch:let name="missing" value="not(string(gco:CharacterString))
            or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="not($missing) and not($missingOtherLang)"
      >$loc/strings/FreeTextKeyword</sch:assert>

    </sch:rule>


    <!-- Thesaurus contact -->
    <sch:rule context="//gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:organisationName">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />


      <sch:assert
        test="not($missing) and not($missingOtherLang)"
      >$loc/strings/OrganisationNameThesaurus</sch:assert>

    </sch:rule>

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

    <!-- Supplemental information -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:supplementalInformation
          |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:supplementalInformation
          |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:supplementalInformation">

      <sch:let name="missing" value="not(string(gco:CharacterString))
              or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />


      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/SupplementalInfo</sch:assert>
    </sch:rule>


    <!-- Constraints -->

    <!-- Note (Other constraints) -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                " />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/OtherConstraintsNote2</sch:assert>

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
      >$loc/strings/OtherConstraintsNote</sch:assert>

    </sch:rule>

    <sch:rule context="//gmd:MD_SecurityConstraints/gmd:userNote">

      <sch:let name="missingTitle" value="not(string(gco:CharacterString))
              or (@gco:nilReason)" />

      <sch:let name="missingTitleOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:let name="security-level-list" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Security_Level.rdf'), '\\', '/')))"/>

      <sch:let name="userNote" value="gco:CharacterString" />
      <sch:let name="userNoteTranslated" value="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]" />
      <sch:let name="securityLevelList" value="geonet:securityLevelList($thesaurusDir)" />
      <sch:let name="locMsg" value="concat($loc/strings/SecurityLevel, $securityLevelList)" />

      <sch:assert test="($missingTitle and $missingTitleOtherLang) or
                        (string($security-level-list//rdf:Description[@rdf:about = concat('http://geonetwork-opensource.org/EC/GC_Security_Classification#', $userNote)]) and
                         string($security-level-list//rdf:Description[@rdf:about = concat('http://geonetwork-opensource.org/EC/GC_Security_Classification#',$userNoteTranslated)]))">$locMsg</sch:assert>

    </sch:rule>

    <!-- Use limitation -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                         or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="not($missing) and not($missingOtherLang)"
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
      <sch:let name="resourceFormatsList" value="geonet:resourceFormatsList($thesaurusDir)" />
      <sch:let name="locMsg" value="concat($loc/strings/ResourceDescriptionFormat, $resourceFormatsList)" />

      <sch:assert test="string($formats-list//rdf:Description[@rdf:about = concat('http://geonetwork-opensource.org/EC/resourceformat#', $format)]) and
                          string($formats-list//rdf:Description[@rdf:about = concat('http://geonetwork-opensource.org/EC/resourceformat#',$formatTranslated)])">$locMsg</sch:assert>

      <sch:assert test="normalize-space($language) != '' and normalize-space($languageTranslated) != ''">$loc/strings/ResourceDescriptionLanguage</sch:assert>

      <sch:assert test="$language_present and $languageTranslated_present">$loc/strings/ResourceDescriptionLanguage</sch:assert>

    </sch:rule>


    <!-- Distributor contact - Organisation Name -->
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:organisationName">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="not($missing) and not($missingOtherLang)"
      >$loc/strings/DistributorOrganisationName</sch:assert>


      <sch:let name="government-titles" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Departments.rdf'), '\\', '/')))"/>
      <sch:let name="government-names" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Org_Names.rdf'), '\\', '/')))"/>

      <sch:let name="organisationName" value="gco:CharacterString" />
      <sch:let name="isGovernmentOfCanada" value="starts-with(lower-case(normalize-space(tokenize($organisationName, ';')[1])), 'government of canada') or starts-with(lower-case(normalize-space(tokenize($organisationName, ';')[1])), 'gouvernement du canada')" />
      <sch:let name="titleName" value="lower-case(normalize-space(tokenize($organisationName, ';')[2]))" />

      <sch:let name="isGovernmentNameAllowed" value="(
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationName)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang=$altLanguage2char])), ';'))]) or
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationName)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang=$mainLanguage2char])), ';'))])
        )"/>

      <sch:assert test="($missing and $missingOtherLang) or ($isGovernmentNameAllowed and not($isGovernmentOfCanada)) or (not($isGovernmentNameAllowed) and not($isGovernmentOfCanada)) or ($isGovernmentOfCanada and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $titleName]) or
                string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang=$altLanguage2char])) = $titleName]))
              )">$loc/strings/*[name() = concat('DistributorGov', $mainLanguageText)]</sch:assert>

      <sch:assert test="($missing and $missingOtherLang) or
                $isGovernmentNameAllowed
                ">$loc/strings/*[name() = concat('DistributorGovAllowed', $mainLanguageText)]</sch:assert>

      <sch:let name="organisationNameOtherLang" value="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]" />
      <sch:let name="isGovernmentOfCanadaOtherLang" value="starts-with(lower-case(normalize-space(tokenize($organisationNameOtherLang, ';')[1])), 'government of canada') or starts-with(lower-case(normalize-space(tokenize($organisationNameOtherLang, ';')[1])), 'gouvernement du canada')" />
      <sch:let name="titleNameOtherLang" value="lower-case(normalize-space(tokenize($organisationNameOtherLang, ';')[2]))" />
      <sch:let name="isGovernmentNameAllowedOtherLang" value="(
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationNameOtherLang)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang=$altLanguage2char])), ';'))]) or
          string($government-names//rdf:Description[starts-with(normalize-space(lower-case($organisationNameOtherLang)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang=$mainLanguage2char])), ';'))])
        )"/>

      <sch:assert test="($missing and $missingOtherLang) or ($isGovernmentNameAllowedOtherLang and not($isGovernmentOfCanadaOtherLang)) or (not($isGovernmentNameAllowedOtherLang) and not($isGovernmentOfCanadaOtherLang)) or ($isGovernmentNameAllowedOtherLang and not($isGovernmentOfCanadaOtherLang)) or ($isGovernmentOfCanadaOtherLang and (string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $titleNameOtherLang]) or
                string($government-titles//rdf:Description[normalize-space(lower-case(ns2:prefLabel[@xml:lang=$altLanguage2char])) = $titleNameOtherLang]))
               )">$loc/strings/*[name() = concat('DistributorGov', $altLanguageText)]</sch:assert>
      <sch:assert test="($missing and $missingOtherLang) or
                $isGovernmentNameAllowedOtherLang
                ">$loc/strings/*[name() = concat('DistributorGovAllowed', $altLanguageText)]</sch:assert>

    </sch:rule>

    <!-- Distributor - Position name -->
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:positionName">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/DistributorPositionName</sch:assert>

    </sch:rule>

    <!-- Distributor contact - Country -->
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact//gmd:country">
      <sch:let name="country-values" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/ISO_Countries.rdf'), '\\', '/')))"/>

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

    <!-- Distributor - Phone -->
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:contactInfo/*/gmd:phone/gmd:CI_Telephone/gmd:voice">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                " />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/DistributorPhone</sch:assert>
    </sch:rule>

    <!-- Distributor - Delivery point -->
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:deliveryPoint">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                    or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/DistributorDeliveryPoint</sch:assert>

    </sch:rule>


    <!-- Distributor - Electronic Mail -->
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:contactInfo/*/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="not($missing) and not($missingOtherLang)"

      >$loc/strings/DistributorElectronicMail</sch:assert>

    </sch:rule>


    <!-- Distributor - Hours of service -->
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                " />
      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/DistributorHoursOfService</sch:assert>
    </sch:rule>

  </sch:pattern>

</sch:schema>
