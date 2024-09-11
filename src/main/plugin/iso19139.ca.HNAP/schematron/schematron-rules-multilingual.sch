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

   <xsl:function name="geonet:resourceContentTypesList" as="xs:string">
      <xsl:param name="thesaurusDir" as="xs:string"/>
      <xsl:param name="lang" as="xs:string"/>

      <xsl:variable name="contentTypes-list" select="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Resource_ContentTypes.rdf'), '\\', '/')))"/>

      <xsl:variable name="v">
        <xsl:for-each select="$contentTypes-list//rdf:Description">
          <xsl:sort select="lower-case(@rdf:about)" order="ascending"/>
          <xsl:value-of select="ns2:prefLabel[@xml:lang=$lang]"/>
          <xsl:if test="position() != last()">, </xsl:if>
        </xsl:for-each>
      </xsl:variable>

      <xsl:value-of select="$v"/>
    </xsl:function>

  <xsl:function name="geonet:securityLevelList" as="xs:string">
    <xsl:param name="thesaurusDir" as="xs:string"/>

    <xsl:variable name="locLang2char" select="if ($lang = 'fre') then 'fr' else 'en'"/>
    <xsl:variable name="security-level-list" select="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Security_Level.rdf'), '\\', '/')))"/>

    <xsl:variable name="v">
      <xsl:for-each select="$security-level-list//rdf:Description/ns2:prefLabel[@xml:lang=$locLang2char]">
        <xsl:sort select="lower-case(.)" order="ascending"/>
        <xsl:value-of select="."/>
        <xsl:if test="position() != last()">, </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:value-of select="$v" />
  </xsl:function>

  <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                name="geonet:checkUserNoteSecurityClassificationCode"
                as="xs:string">
    <xsl:param name="securityLevel" as="xs:string"/>
    <xsl:param name="securityClassificationCodeNode"/>

    <xsl:variable name="locLang2char" select="if ($lang = 'fre') then 'fr' else 'en'"/>
    <xsl:variable name="security-level-list"
                   select="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Security_Level.rdf'), '\\', '/')))"/>

    <xsl:variable name="lookup">
      <table>
        <row securityClassificationCode="RI_484" securityLevel="unclassified"/> <!-- unclassified/unclassified -->
        <row securityClassificationCode="RI_485" securityLevel="protectA" />    <!-- restricted/protectA -->
        <row securityClassificationCode="RI_485" securityLevel="protectB" />    <!-- restricted/protectB -->
        <row securityClassificationCode="RI_485" securityLevel="protectC"/>     <!-- restricted/protectC -->
        <row securityClassificationCode="RI_486" securityLevel="confidential"/> <!-- confidential/confidential -->
        <row securityClassificationCode="RI_489" securityLevel="confidential"/> <!-- sensitive/confidential -->
        <row securityClassificationCode="RI_487" securityLevel="secret"/>       <!-- secret/secret -->
        <row securityClassificationCode="RI_488" securityLevel="topSecret"/>    <!-- topSecret/topSecret -->
      </table>
    </xsl:variable>

    <xsl:variable name="v">
      <xsl:choose>
        <!-- Found so return empty list -->
        <xsl:when test="$lookup/table/row[@securityLevel = $securityLevel and @securityClassificationCode = $securityClassificationCodeNode/@codeListValue]">
          <xsl:value-of select="''"/>
        </xsl:when>
        <xsl:when test="$lookup/table/row[@securityClassificationCode = $securityClassificationCodeNode/@codeListValue]">
          <xsl:variable name="securityLevelList">
            <xsl:for-each select="$lookup/table/row[@securityClassificationCode = $securityClassificationCodeNode/@codeListValue]/@securityLevel">
              <xsl:variable name="securityLevelCode"
                            select="concat('http://geonetwork-opensource.org/GC/GC_Security_Classification#', .)"/>
              <xsl:value-of select="$security-level-list//rdf:Description[@rdf:about = $securityLevelCode]/ns2:prefLabel[@xml:lang=$locLang2char]"/>
              <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="replace($securityLevelList, ', ', '') =''">
              <xsl:value-of select="'NULL'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$securityLevelList"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <!-- Not Found in table so return NULL to mean that we expect this to be null   -->
          <xsl:value-of select="'NULL'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:value-of select="$v"/>

  </xsl:function>

  <xsl:function name="geonet:appendLocaleMessage">
    <xsl:param name="localeStringNode"/>
    <xsl:param name="appendText" as="xs:string"/>

    <xsl:for-each select="$localeStringNode">
       <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:value-of select="concat($localeStringNode, $appendText)"/>
       </xsl:copy>
    </xsl:for-each>
  </xsl:function>

  <xsl:function name="geonet:prependLocaleMessage">
    <xsl:param name="localeStringNode"/>
    <xsl:param name="prependText" as="xs:string"/>

    <xsl:for-each select="$localeStringNode">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:value-of select="concat($prependText, $localeStringNode)"/>
      </xsl:copy>
    </xsl:for-each>
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



    <!-- graphicOverlay - fileDescription -->
    <sch:rule context="//gmd:graphicOverview/gmd:MD_BrowseGraphic/gmd:fileDescription">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="($missing and $missingOtherLang) or (not($missing) and not($missingOtherLang))"
      >$loc/strings/FileDescription</sch:assert>

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
      <sch:let name="governmentNamesStringMainLang" value=" string($government-names//rdf:Description/ns2:prefLabel[@xml:lang=$mainLanguage2char]) "/>
      <sch:let name="governmentNamesStringAltLang" value=" string($government-names//rdf:Description/ns2:prefLabel[@xml:lang=$altLanguage2char]) "/>

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

      <sch:let name="locMsgMainLang" value="geonet:appendLocaleMessage($loc/strings/*[name() = concat('ContactGovAllowed', $mainLanguageText)], $governmentNamesStringMainLang)" />
      <sch:assert test="not($isErrorContactGovMainAllowed)">$locMsgMainLang</sch:assert>

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
      <sch:let name="locMsgAltLang" value="geonet:appendLocaleMessage($loc/strings/*[name() = concat('ContactGovAllowed', $altLanguageText)], $governmentNamesStringAltLang)" />
      <sch:assert test="not($isErrorContactGovAltAllowed)">$locMsgAltLang</sch:assert>

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

      <sch:assert test="((not($countryName) and not($countryNameOtherLang)) or
          (string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $countryName])
          and
          string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang=$altLanguage2char])) = $countryNameOtherLang])))"
      >$loc/strings/ECCountry</sch:assert>

    </sch:rule>

    <!-- Contact - Administrative area -->
    <sch:rule context="//gmd:contact//gmd:administrativeArea">
      <sch:let name="province-values" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_State_Province.rdf'), '\\', '/')))"/>

      <sch:let name="administrativeArea" value="lower-case(gco:CharacterString)" />
      <sch:let name="administrativeAreaOtherLang" value="lower-case(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)])" />

      <sch:assert test="((not($administrativeArea) and not($administrativeAreaOtherLang)) or
          (string($province-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $administrativeArea])
          and
          string($province-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang=$altLanguage2char])) = $administrativeAreaOtherLang])))"
      >$loc/strings/ContactAdministrativeArea</sch:assert>

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
      <sch:let name="emailAddress" value="string(gco:CharacterString)" />
      <sch:let name="emailAddressOtherLang" value="string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)])" />

      <sch:let name="missing" value="not($emailAddress)
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not($emailAddressOtherLang)" />

      <sch:let name="isEmailAddressFormat" value="XslUtilHnap:isEmailFormat($emailAddress, true())"/>
      <sch:let name="isOtherLangEmailAddressFormat" value="XslUtilHnap:isEmailFormat($emailAddressOtherLang, true())"/>

      <sch:assert
        test="not($missing) and not($missingOtherLang)"

      >$loc/strings/ContactElectronicMail</sch:assert>

      <sch:assert test="string($isEmailAddressFormat) ='true' and string($isOtherLangEmailAddressFormat) ='true'">$loc/strings/ElectronicMailFormat</sch:assert>
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
      <sch:let name="governmentNamesStringMainLang" value=" string($government-names//rdf:Description/ns2:prefLabel[@xml:lang=$mainLanguage2char]) "/>
      <sch:let name="governmentNamesStringAltLang" value=" string($government-names//rdf:Description/ns2:prefLabel[@xml:lang=$altLanguage2char]) "/>

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

      <sch:let name="locMsgMainLang" value="geonet:appendLocaleMessage($loc/strings/*[name() = concat('CitedResponsibleContactGovAllowed', $mainLanguageText)], $governmentNamesStringMainLang)" />
      <sch:assert test="($missing and $missingOtherLang) or
                $isGovernmentNameAllowed
                ">$locMsgMainLang</sch:assert>

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
      <sch:let name="locMsgAltLang" value="geonet:appendLocaleMessage($loc/strings/*[name() = concat('CitedResponsibleContactGovAllowed', $altLanguageText)], $governmentNamesStringAltLang)" />
      <sch:assert test="($missing and $missingOtherLang) or
                $isGovernmentNameAllowedOtherLang
                ">$locMsgAltLang</sch:assert>
    </sch:rule>


    <!-- Cited responsible party  - Country  -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty//gmd:country
             |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty//gmd:country
             |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty//gmd:country">
      <sch:let name="country-values" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/ISO_Countries.rdf'), '\\', '/')))"/>

      <sch:let name="countryName" value="lower-case(gco:CharacterString)" />
      <sch:let name="countryNameOtherLang" value="lower-case(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)])" />

      <sch:assert test="((not($countryName) and not($countryNameOtherLang)) or
          (string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $countryName])
          and
          string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang=$altLanguage2char])) = $countryNameOtherLang])))"
      >$loc/strings/ECCountry</sch:assert>
    </sch:rule>

    <!-- Cited responsible party - Administrative area -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty//gmd:administrativeArea
             |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty//gmd:administrativeArea
             |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty//gmd:administrativeArea">
      <sch:let name="province-values" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_State_Province.rdf'), '\\', '/')))"/>

      <sch:let name="administrativeArea" value="lower-case(gco:CharacterString)" />
      <sch:let name="administrativeAreaOtherLang" value="lower-case(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)])" />

      <sch:assert test="((not($administrativeArea) and not($administrativeAreaOtherLang)) or
          (string($province-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $administrativeArea])
          and
          string($province-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang=$altLanguage2char])) = $administrativeAreaOtherLang])))"
      >$loc/strings/CitedResponsiblePartyAdministrativeArea</sch:assert>

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
      <sch:let name="emailAddress" value="string(gco:CharacterString)" />
      <sch:let name="emailAddressOtherLang" value="string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)])" />

      <sch:let name="missing" value="not($emailAddress)
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not($emailAddressOtherLang)" />

      <sch:let name="isEmailAddressFormat" value="XslUtilHnap:isEmailFormat($emailAddress, true())"/>
      <sch:let name="isOtherLangEmailAddressFormat" value="XslUtilHnap:isEmailFormat($emailAddressOtherLang, true())"/>

      <sch:assert
        test="not($missing) and not($missingOtherLang)"

      >$loc/strings/CitedResponsiblePartyElectronicMail</sch:assert>

      <sch:assert test="string($isEmailAddressFormat) ='true' and string($isOtherLangEmailAddressFormat) ='true'">$loc/strings/ElectronicMailFormat</sch:assert>

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
    <sch:rule context="//gmd:identificationInfo/*/gmd:descriptiveKeywords">
      <sch:let name="missing" value="not(string(gmd:MD_Keywords/gmd:keyword[1]/gco:CharacterString))
            or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not(string(gmd:MD_Keywords/gmd:keyword[1]/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:assert
        test="not($missing) and not($missingOtherLang)"
      >$loc/strings/Keyword</sch:assert>

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

      <sch:let name="emailAddress" value="string(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString)" />
      <sch:let name="emailAddressOtherLang" value="string(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)])" />

      <sch:let name="missingEmail" value="not($emailAddress)
              or (@gco:nilReason)" />

      <sch:let name="missingEmailOtherLang" value="not($emailAddressOtherLang)" />

      <sch:let name="isEmailAddressFormat" value="XslUtilHnap:isEmailFormat($emailAddress, true())"/>
      <sch:let name="isOtherLangEmailAddressFormat" value="XslUtilHnap:isEmailFormat($emailAddressOtherLang, true())"/>

      <sch:assert
        test="not($thesaurusNamePresent) or ($thesaurusNamePresent and (not($emailPresent) or ($emailPresent and not($missingEmail) and not($missingEmailOtherLang))))"
      >$loc/strings/ECThesaurusEmail</sch:assert>

      <sch:assert test="string($isEmailAddressFormat) ='true' and string($isOtherLangEmailAddressFormat) ='true'">$loc/strings/ElectronicMailFormat</sch:assert>
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

    <sch:rule context="//gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_SecurityConstraints/gmd:userNote">

      <sch:let name="missingTitle" value="not(string(gco:CharacterString))
              or (@gco:nilReason)" />

      <sch:let name="missingTitleOtherLang" value="not(string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:let name="security-level-list" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Security_Level.rdf'), '\\', '/')))"/>

      <sch:let name="securityLevel" value="gco:CharacterString" />
      <sch:let name="securityLevelTranslated" value="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]" />
      <sch:let name="securityLevelList" value="geonet:securityLevelList($thesaurusDir)" />

      <sch:let name="locMsg" value="geonet:appendLocaleMessage($loc/strings/SecurityLevel, $securityLevelList)" />

      <sch:let name="missingOneTitleExclusively" value="($missingTitle and not($missingTitleOtherLang)) or (not($missingTitle) and $missingTitleOtherLang)" />
      <sch:let name="missingBothTitle" value="($missingTitle and $missingTitleOtherLang)" />

      <sch:let name="validSecurityLevel" value="($missingBothTitle) or
                        ($security-level-list//rdf:Description/ns2:prefLabel[@xml:lang=$mainLanguage2char]=$securityLevel and
                         $security-level-list//rdf:Description/ns2:prefLabel[@xml:lang=$altLanguage2char]=$securityLevelTranslated)"/>

      <sch:assert test="not($missingOneTitleExclusively)">$loc/strings/SecurityNoteBothLangRequired</sch:assert>

      <sch:assert test="$missingOneTitleExclusively or $validSecurityLevel">$locMsg</sch:assert>

      <sch:let name="securityLevelCode" value="replace($security-level-list//rdf:Description[lower-case(ns2:prefLabel[@xml:lang=$mainLanguage2char])=lower-case($securityLevel)]/@rdf:about, 'http://geonetwork-opensource.org/GC/GC_Security_Classification#', '')"/>
      <sch:let name="securityLevelCodeTranslated" value="replace($security-level-list//rdf:Description[lower-case(ns2:prefLabel[@xml:lang=$altLanguage2char])=lower-case($securityLevelTranslated)]/@rdf:about, 'http://geonetwork-opensource.org/GC/GC_Security_Classification#', '')"/>
      <sch:let name="securityLevelCodeMismatched" value="$securityLevelCode != $securityLevelCodeTranslated"/>

      <sch:let name="checkUserNoteSecurityClassificationCode" value="geonet:checkUserNoteSecurityClassificationCode($securityLevelCode, ../gmd:classification/gmd:MD_ClassificationCode)" />

      <sch:let name="locSecurityClassificationUserNoteMsg" value="geonet:appendLocaleMessage($loc/strings/SecurityClassificationUserNote, $checkUserNoteSecurityClassificationCode)" />

      <sch:assert test="not($validSecurityLevel) or not($securityLevelCodeMismatched)">$loc/strings/SecurityNoteMismatchedBothLang</sch:assert>
      <sch:assert test="($missingBothTitle) or not($validSecurityLevel) or not($securityLevelCodeMismatched) or $checkUserNoteSecurityClassificationCode='NULL' or $checkUserNoteSecurityClassificationCode = ''">$locSecurityClassificationUserNoteMsg</sch:assert>

      <sch:assert test="($missingBothTitle) or not($validSecurityLevel) or not($securityLevelCodeMismatched) or $checkUserNoteSecurityClassificationCode!='NULL' or $checkUserNoteSecurityClassificationCode = ''">$loc/strings/SecurityClassificationUserNoteEmpty</sch:assert>

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

      <!-- Resource name -->
      <sch:let name="missingResourceName" value="not(string(gmd:CI_OnlineResource/gmd:name/gco:CharacterString))" />

      <sch:let name="missingResourceNameOtherLang" value="not(string(gmd:CI_OnlineResource/gmd:name/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]))" />

      <sch:let name="locMsgResourceName" value="geonet:prependLocaleMessage($loc/strings/ResourceName, concat(gmd:CI_OnlineResource/gmd:linkage/gmd:URL, ' : '))" />

      <sch:assert
        test="not($missingResourceName) and not($missingResourceNameOtherLang)"
      >$locMsgResourceName</sch:assert>

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

      <sch:let name="resourceContentTypesListMain" value="geonet:resourceContentTypesList($thesaurusDir,$mainLanguage2char)"/>
      <sch:let name="resourceContentTypesListAlt" value="geonet:resourceContentTypesList($thesaurusDir,$altLanguage2char)"/>
      <sch:let name="locMsgCtMain" value="geonet:prependLocaleMessage(geonet:appendLocaleMessage($loc/strings/ResourceDescriptionContentType, $resourceContentTypesListMain),  concat(gmd:CI_OnlineResource/gmd:linkage/gmd:URL, ' : '))"/>
      <sch:let name="locMsgCtAlt" value="geonet:prependLocaleMessage(geonet:appendLocaleMessage($loc/strings/ResourceDescriptionContentType, $resourceContentTypesListAlt),  concat(gmd:CI_OnlineResource/gmd:linkage/gmd:URL, ' : '))"/>

      <sch:assert test="$contentType = document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Resource_ContentTypes.rdf'), '\\', '/')))//rdf:Description/ns2:prefLabel[@xml:lang=$mainLanguage2char]">
          $locMsgCtMain
      </sch:assert>
      <sch:assert test="$contentTypeTranslated = document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Resource_ContentTypes.rdf'), '\\', '/')))//rdf:Description/ns2:prefLabel[@xml:lang=$altLanguage2char]">
                $locMsgCtAlt
            </sch:assert>

      <sch:let name="formatTranslated" value="subsequence(tokenize($descriptionTranslated, ';'), 2, 1)" />
      <sch:let name="resourceFormatsList" value="geonet:resourceFormatsList($thesaurusDir)" />
      <sch:let name="locMsg" value="geonet:prependLocaleMessage(geonet:appendLocaleMessage($loc/strings/ResourceDescriptionFormat, $resourceFormatsList), concat(gmd:CI_OnlineResource/gmd:linkage/gmd:URL, ' : '))" />

      <sch:assert test="$formats-list//rdf:Description/ns2:prefLabel[@xml:lang = normalize-space($mainLanguage2char)]/text() = $format and
                          $formats-list//rdf:Description/ns2:prefLabel[@xml:lang = normalize-space($altLanguage2char)]/text() = $formatTranslated">$locMsg</sch:assert>

      <sch:let name="locMsgLang" value="geonet:prependLocaleMessage($loc/strings/ResourceDescriptionLanguage, concat(gmd:CI_OnlineResource/gmd:linkage/gmd:URL, ' : '))" />

      <sch:assert test="normalize-space($language) != '' and normalize-space($languageTranslated) != ''">$locMsgLang</sch:assert>

      <sch:assert test="$language_present and $languageTranslated_present">$locMsgLang</sch:assert>

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
      <sch:let name="governmentNamesStringMainLang" value=" string($government-names//rdf:Description/ns2:prefLabel[@xml:lang=$mainLanguage2char]) "/>
      <sch:let name="governmentNamesStringAltLang" value=" string($government-names//rdf:Description/ns2:prefLabel[@xml:lang=$altLanguage2char]) "/>

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

      <sch:let name="locMsgMainLang" value="geonet:appendLocaleMessage($loc/strings/*[name() = concat('DistributorGovAllowed', $mainLanguageText)], $governmentNamesStringMainLang)" />
      <sch:assert test="($missing and $missingOtherLang) or
                $isGovernmentNameAllowed
                ">$locMsgMainLang</sch:assert>

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
      <sch:let name="locMsgAltLang" value="geonet:appendLocaleMessage($loc/strings/*[name() = concat('DistributorGovAllowed', $altLanguageText)], $governmentNamesStringAltLang)" />
      <sch:assert test="($missing and $missingOtherLang) or
                $isGovernmentNameAllowedOtherLang
                ">$locMsgAltLang</sch:assert>

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

    <!-- Distributor contact - Administrative area -->
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact//gmd:administrativeArea">
      <sch:let name="province-values" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_State_Province.rdf'), '\\', '/')))"/>

      <sch:let name="administrativeArea" value="lower-case(gco:CharacterString)" />
      <sch:let name="administrativeAreaOtherLang" value="lower-case(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)])" />

      <sch:assert test="((not($administrativeArea) and not($administrativeAreaOtherLang)) or
          (string($province-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $administrativeArea])
          and
          string($province-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang=$altLanguage2char])) = $administrativeAreaOtherLang])))"
      >$loc/strings/DistributorAdministrativeArea</sch:assert>

    </sch:rule>

    <!-- Distributor contact - Country -->
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact//gmd:country">
      <sch:let name="country-values" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/ISO_Countries.rdf'), '\\', '/')))"/>

      <sch:let name="countryName" value="lower-case(gco:CharacterString)" />
      <sch:let name="countryNameOtherLang" value="lower-case(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)])" />

      <sch:assert test="((not($countryName) and not($countryNameOtherLang)) or
          (string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang=$mainLanguage2char])) = $countryName])
          and
          string($country-values//rdf:Description[lower-case(normalize-space(ns2:prefLabel[@xml:lang=$altLanguage2char])) = $countryNameOtherLang])))"
      >$loc/strings/ECCountry</sch:assert>

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
      <sch:let name="emailAddress" value="string(gco:CharacterString)" />
      <sch:let name="emailAddressOtherLang" value="string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)])" />

      <sch:let name="missing" value="not($emailAddress)
                or (@gco:nilReason)" />

      <sch:let name="missingOtherLang" value="not($emailAddressOtherLang)" />

      <sch:let name="isEmailAddressFormat" value="XslUtilHnap:isEmailFormat($emailAddress, true())"/>
   	  <sch:let name="isOtherLangEmailAddressFormat" value="XslUtilHnap:isEmailFormat($emailAddressOtherLang, true())"/>

      <sch:assert
        test="not($missing) and not($missingOtherLang)"

      >$loc/strings/DistributorElectronicMail</sch:assert>

      <sch:assert test="string($isEmailAddressFormat) ='true' and string($isOtherLangEmailAddressFormat) ='true'">$loc/strings/ElectronicMailFormat</sch:assert>

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
