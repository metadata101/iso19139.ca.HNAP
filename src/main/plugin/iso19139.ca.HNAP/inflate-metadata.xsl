<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                  xmlns:gmd="http://www.isotc211.org/2005/gmd"
                  xmlns:xlink='http://www.w3.org/1999/xlink'
                  xmlns:gco="http://www.isotc211.org/2005/gco"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  xmlns:XslUtilHnap="java:ca.gc.schema.iso19139hnap.util.XslUtilHnap"
                  exclude-result-prefixes="gmd xlink gco xsi XslUtilHnap">

  <xsl:include href="../iso19139.ca.HNAP/convert/functions.xsl"/>

  <xsl:variable name="lang"><xsl:value-of select="/root/env/lang"/></xsl:variable>
  <xsl:variable name="mdLang"><xsl:value-of select="//gmd:MD_Metadata/gmd:language/gco:CharacterString"/></xsl:variable>
  <xsl:variable name="addOnlineResourceId">
    <xsl:choose>
      <xsl:when test="/root/env/addOnlineResourceId"><xsl:value-of select="/root/env/addOnlineResourceId" /></xsl:when>
      <xsl:otherwise>true</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="mainLanguage">
    <xsl:call-template name="langId_from_gmdlanguage19139">
      <xsl:with-param name="gmdlanguage" select="/root/*/gmd:language"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="isMultilingual"
                select="count(/root/*/gmd:locale[*/gmd:languageCode/*/@codeListValue != $mainLanguage]) > 0"/>

  <xsl:variable name="altLang">
    <xsl:choose>
      <xsl:when test="$mdLang = 'eng; CAN'">fra</xsl:when>
      <xsl:otherwise>eng</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="locales"
                select="/root/*/gmd:locale/gmd:PT_Locale"/>

  <!-- ******************************************************************************************************
        get main language code to be used in locale ID
        If it does not already exists in the pt_local then it will generate one to be used. -->
  <xsl:variable name="mainLanguageId">
    <!-- Potential options include 3 char or 2 char code in both upper and lower. -->

    <xsl:variable name="localeList"
                  select="/root/*/gmd:locale/gmd:PT_Locale"/>
    <xsl:variable name="twoCharMainLangCode"
                  select="XslUtilHnap:twoCharLangCode($mainLanguage)"/>
    <xsl:variable name="nextThreeCharLangCode"
                  select="substring(concat($localeList[1]/@id, '   '), 1, 3)"/>
    <xsl:variable name="nextTwoCharLangCode"
                  select="XslUtilHnap:twoCharLangCode($localeList[1]/@id)"/>

    <xsl:choose>
      <!-- If one of the locales is equal to the main language then that is the id that will be used. -->
      <xsl:when test="$localeList[upper-case(@id) = upper-case($mainLanguage)]">
        <xsl:value-of  select="$localeList[upper-case(@id) = upper-case($mainLanguage)]/@id"/>
      </xsl:when>
      <!-- If one of the locales is equal to the 2 Char main language then that is the id that will be used. -->
      <xsl:when test="$localeList[upper-case(@id) = upper-case($twoCharMainLangCode)]">
        <xsl:value-of  select="$localeList[upper-case(@id) = upper-case($twoCharMainLangCode)]/@id"/>
      </xsl:when>

      <!-- If one of the locales is equal to the upper case version then the codes are assumed to be in uppercase. -->
      <xsl:when test="$localeList[@id = upper-case($nextThreeCharLangCode)]">
        <xsl:value-of  select="upper-case($mainLanguage)"/>
      </xsl:when>
      <!-- If one of the locales is equal to the lower case version then the codes are assumed to be in lowercase. -->
      <xsl:when test="$localeList[@id = lower-case($nextThreeCharLangCode)]">
        <xsl:value-of  select="lower-case($mainLanguage)"/>
      </xsl:when>

      <!-- If one of the locales is equal to the 2 char upper case version then the codes are assumed to be in uppercase 2 char. -->
      <xsl:when test="$localeList[@id = upper-case($nextTwoCharLangCode)]">
        <xsl:value-of  select="upper-case($twoCharMainLangCode)"/>
      </xsl:when>
      <!-- If one of the locales is equal to the 2 char lower case version then the codes are assumed to be in lowercase 2 char. -->
      <xsl:when test="$localeList[@id = lower-case($nextTwoCharLangCode)]">
        <xsl:value-of  select="lower-case($twoCharMainLangCode)"/>
      </xsl:when>

      <!-- If we did not find an option then just use the main language as the code. -->
      <xsl:otherwise><xsl:value-of select="$mainLanguage"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- Get alt language -->
  <xsl:variable name="altLanguageId" select="$locales[gmd:languageCode/*/@codeListValue != $mainLanguage and (gmd:languageCode/*/@codeListValue = 'eng' or gmd:languageCode/*/@codeListValue = 'fra')]/@id"/>

  <!-- *******************************************************************************************************
        The default country code to be used in the gmd:locale
        for multilingual metadata records. -->
  <xsl:variable name="mainLanguageCountryId">
    <xsl:variable name="language"  select="normalize-space(/root/*/gmd:language/gco:CharacterString/text())"/>
    <!-- Get the main language which could be "EN", "EN; US" if it contains a ; then extract country code -->
    <xsl:choose>
      <xsl:when test="contains($language,';')">
        <xsl:value-of  select="normalize-space(substring-after($language,';'))"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <!-- ================================================================= -->

  <xsl:template match="/root">
    <xsl:apply-templates select="gmd:MD_Metadata"/>
  </xsl:template>

  <!-- ================================================================= -->
  <xsl:template match="gmd:MD_Metadata">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>

      <xsl:apply-templates select="gmd:fileIdentifier" />
      <xsl:apply-templates select="gmd:language" />
      <xsl:apply-templates select="gmd:characterSet" />
      <xsl:if test="not(gmd:characterSet)">
        <gmd:characterSet>
          <gmd:MD_CharacterSetCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_95" codeListValue="RI_458">utf8; utf8</gmd:MD_CharacterSetCode>
        </gmd:characterSet>
      </xsl:if>

      <xsl:apply-templates select="gmd:parentIdentifier" />
      <xsl:apply-templates select="gmd:hierarchyLevel" />
      <xsl:if test="not(gmd:hierarchyLevel)">
        <gmd:hierarchyLevel>
          <gmd:MD_ScopeCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_108" codeListValue="RI_622">dataset; jeuDonnées</gmd:MD_ScopeCode>
        </gmd:hierarchyLevel>
      </xsl:if>

      <xsl:apply-templates select="gmd:contact" />
      <xsl:apply-templates select="gmd:dateStamp" />
      <xsl:apply-templates select="gmd:metadataStandardName" />
      <xsl:if test="not(gmd:metadataStandardName)">
        <xsl:choose>
          <xsl:when test="$mdLang = 'fra; CAN'">
            <gmd:metadataStandardName xsi:type="gmd:PT_FreeText_PropertyType">
              <gco:CharacterString>Profil nord-américain de la norme ISO 19115:2003 - Information géographique - Métadonnées</gco:CharacterString>
              <gmd:PT_FreeText>
                <gmd:textGroup>
                  <gmd:LocalisedCharacterString locale="#eng">North American Profile of ISO 19115:2003 - Geographic information - Metadata</gmd:LocalisedCharacterString>
                </gmd:textGroup>
              </gmd:PT_FreeText>
            </gmd:metadataStandardName>
          </xsl:when>
          <xsl:otherwise>
            <gmd:metadataStandardName xsi:type="gmd:PT_FreeText_PropertyType">
              <gco:CharacterString>North American Profile of ISO 19115:2003 - Geographic information - Metadata</gco:CharacterString>
              <gmd:PT_FreeText>
                <gmd:textGroup>
                  <gmd:LocalisedCharacterString locale="#fra">Profil nord-américain de la norme ISO 19115:2003 - Information géographique - Métadonnées</gmd:LocalisedCharacterString>
                </gmd:textGroup>
              </gmd:PT_FreeText>
            </gmd:metadataStandardName>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>

      <xsl:apply-templates select="gmd:metadataStandardVersion" />
      <xsl:if test="not(gmd:metadataStandardVersion)">
        <gmd:metadataStandardVersion>
          <gco:CharacterString>CAN/CGSB-171.100-2009</gco:CharacterString>
        </gmd:metadataStandardVersion>
      </xsl:if>

      <xsl:apply-templates select="gmd:dataSetURI" />

      <!-- Copy existing locales and create an extra one for the default metadata language. -->
      <xsl:apply-templates select="gmd:locale[*/gmd:languageCode/*/@codeListValue != $mainLanguage]"/>
        <gmd:locale>
          <gmd:PT_Locale id="{$mainLanguageId}">
            <gmd:languageCode>
              <gmd:LanguageCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_116"
                                codeListValue="{$mainLanguage}">
                <xsl:choose>
                  <xsl:when test="normalize-space($mainLanguage) = 'fra'">French; Français</xsl:when>
                  <xsl:otherwise>English; Anglais</xsl:otherwise>
                </xsl:choose>
              </gmd:LanguageCode>
            </gmd:languageCode>
            <xsl:choose>
              <!-- Add country code if it exists. -->
              <xsl:when test="$mainLanguageCountryId">
                <gmd:country>
                  <xsl:choose>
                    <xsl:when test="upper-case($mainLanguageCountryId) = 'CAN'">
                      <gmd:Country codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_117"
                                   codeListValue="CAN">Canada; Canada</gmd:Country>
                    </xsl:when>
                    <xsl:otherwise>
                      <gmd:Country codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_117"
                                   codeListValue="$mainLanguageCountryId"></gmd:Country>
                    </xsl:otherwise>
                  </xsl:choose>
                </gmd:country>
              </xsl:when>
            </xsl:choose>
            <gmd:characterEncoding>
              <gmd:MD_CharacterSetCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_95"
                                       codeListValue="RI_458">utf8; utf8</gmd:MD_CharacterSetCode>
            </gmd:characterEncoding>
          </gmd:PT_Locale>
        </gmd:locale>

      <xsl:apply-templates select="gmd:spatialRepresentationInfo" />
      <xsl:apply-templates select="gmd:referenceSystemInfo" />
      <xsl:if test="not(gmd:referenceSystemInfo)">
        <xsl:variable name="spatialRepresentationType" select="gmd:identificationInfo/*/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode/@codeListValue" />

        <xsl:if test="$spatialRepresentationType = 'RI_635' or $spatialRepresentationType = 'RI_636' or $spatialRepresentationType = 'RI_638'">
          <gmd:referenceSystemInfo>
            <gmd:MD_ReferenceSystem>
              <gmd:referenceSystemIdentifier>
                <gmd:RS_Identifier>
                  <gmd:code>
                    <gco:CharacterString/>
                  </gmd:code>
                  <gmd:codeSpace>
                    <gco:CharacterString/>
                  </gmd:codeSpace>
                  <gmd:version>
                    <gco:CharacterString/>
                  </gmd:version>
                </gmd:RS_Identifier>
              </gmd:referenceSystemIdentifier>
            </gmd:MD_ReferenceSystem>
          </gmd:referenceSystemInfo>
        </xsl:if>
      </xsl:if>

      <xsl:apply-templates select="gmd:identificationInfo" />
      <xsl:apply-templates select="gmd:contentInfo" />
      <xsl:apply-templates select="gmd:distributionInfo" />
      <xsl:apply-templates select="gmd:dataQualityInfo" />
      <xsl:apply-templates select="gmd:portrayalCatalogueInfo" />
      <xsl:apply-templates select="gmd:metadataConstraints" />
      <xsl:apply-templates select="gmd:applicationSchemaInfo" />
      <xsl:apply-templates select="gmd:metadataMaintenance" />
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================= -->
  <xsl:template match="gmd:MD_DataIdentification">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>

      <xsl:for-each select="gmd:citation">
        <xsl:copy>
          <xsl:copy-of select="@*" />
          <xsl:for-each select="gmd:CI_Citation ">
            <xsl:copy>
              <xsl:copy-of select="@*" />

              <xsl:apply-templates select="gmd:title" />
              <xsl:apply-templates select="gmd:alternateTitle" />
              <xsl:apply-templates select="gmd:date" />

              <xsl:if test="count(gmd:date[*/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'RI_366']) = 0">
                <gmd:date>
                  <gmd:CI_Date>
                    <gmd:date>
                      <gco:Date></gco:Date>
                    </gmd:date>
                    <gmd:dateType>
                      <gmd:CI_DateTypeCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_87"
                                           codeListValue="RI_366">creation; création</gmd:CI_DateTypeCode>
                    </gmd:dateType>
                  </gmd:CI_Date>
                </gmd:date>
              </xsl:if>

              <xsl:if test="count(gmd:date[*/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'RI_367']) = 0">
                <gmd:date>
                  <gmd:CI_Date>
                    <gmd:date>
                      <gco:Date></gco:Date>
                    </gmd:date>
                    <gmd:dateType>
                      <gmd:CI_DateTypeCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_87"
                                           codeListValue="RI_367">publication; publication</gmd:CI_DateTypeCode>
                    </gmd:dateType>
                  </gmd:CI_Date>
                </gmd:date>
              </xsl:if>

              <xsl:apply-templates select="gmd:edition" />
              <xsl:apply-templates select="gmd:editionDate" />
              <xsl:apply-templates select="gmd:identifier" />
              <xsl:apply-templates select=" gmd:citedResponsibleParty" />
              <xsl:apply-templates select="gmd:presentationForm" />
              <xsl:apply-templates select="gmd:series" />
              <xsl:apply-templates select="gmd:otherCitationDetails" />
              <xsl:apply-templates select="gmd:collectiveTitle" />
              <xsl:apply-templates select="gmd:ISBN" />
              <xsl:apply-templates select="gmd:ISSN" />
            </xsl:copy>
          </xsl:for-each>

        </xsl:copy>
      </xsl:for-each>

      <xsl:apply-templates select="gmd:abstract" />
      <xsl:apply-templates select="gmd:purpose" />
      <xsl:apply-templates select="gmd:credit" />
      <xsl:apply-templates select="gmd:status" />
      <xsl:if test="not(gmd:status)">
        <gmd:status>
          <gmd:MD_ProgressCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_106" codeListValue=""/>
        </gmd:status>
      </xsl:if>

      <xsl:apply-templates select="gmd:pointOfContact" />
      <xsl:apply-templates select="gmd:resourceMaintenance" />
      <xsl:if test="not(gmd:resourceMaintenance)">
        <gmd:resourceMaintenance>
          <gmd:MD_MaintenanceInformation>
            <gmd:maintenanceAndUpdateFrequency>
              <gmd:MD_MaintenanceFrequencyCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_102" codeListValue=""/>
            </gmd:maintenanceAndUpdateFrequency>
          </gmd:MD_MaintenanceInformation>
        </gmd:resourceMaintenance>
      </xsl:if>


      <xsl:apply-templates select="gmd:graphicOverview" />
      <xsl:apply-templates select="gmd:descriptiveKeywords" />


      <xsl:if test="not(gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'Government of Canada Core Subject Thesaurus' or
                              gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'Thésaurus des sujets de base du gouvernement du Canada')">
        <gmd:descriptiveKeywords>
          <gmd:MD_Keywords>
            <gmd:keyword xsi:type="gmd:PT_FreeText_PropertyType">
              <gco:CharacterString></gco:CharacterString>
              <gmd:PT_FreeText>
                <gmd:textGroup>
                  <gmd:LocalisedCharacterString locale="#{$altLang}"/>
                </gmd:textGroup>
              </gmd:PT_FreeText>
            </gmd:keyword>
            <gmd:type>
              <gmd:MD_KeywordTypeCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_101" codeListValue="RI_528">theme; thème</gmd:MD_KeywordTypeCode>
            </gmd:type>
            <gmd:thesaurusName>
              <gmd:CI_Citation>
                <gmd:title xsi:type="gmd:PT_FreeText_PropertyType">
                  <gco:CharacterString>
                    <xsl:choose>
                      <xsl:when test="$altLang = 'fra'">Government of Canada Core Subject Thesaurus</xsl:when>
                      <xsl:otherwise>Thésaurus des sujets de base du gouvernement du Canada</xsl:otherwise>
                    </xsl:choose>
                  </gco:CharacterString>
                  <gmd:PT_FreeText>
                    <gmd:textGroup>
                      <gmd:LocalisedCharacterString locale="#{$altLang}">
                        <xsl:choose>
                          <xsl:when test="$altLang = 'fra'">Thésaurus des sujets de base du gouvernement du Canada</xsl:when>
                          <xsl:otherwise>Government of Canada Core Subject Thesaurus</xsl:otherwise>
                        </xsl:choose>
                      </gmd:LocalisedCharacterString>
                    </gmd:textGroup>
                  </gmd:PT_FreeText>
                </gmd:title>
                <gmd:date>
                  <gmd:CI_Date>
                    <gmd:date>
                      <gco:Date>2004</gco:Date>
                    </gmd:date>
                    <gmd:dateType>
                      <gmd:CI_DateTypeCode codeListValue="RI_366"
                                           codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_87">creation;création</gmd:CI_DateTypeCode>
                    </gmd:dateType>
                  </gmd:CI_Date>
                </gmd:date>
                <gmd:date>
                  <gmd:CI_Date>
                    <gmd:date>
                      <gco:Date>2016-07-04</gco:Date>
                    </gmd:date>
                    <gmd:dateType>
                      <gmd:CI_DateTypeCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_87" codeListValue="RI_367">publication; publication</gmd:CI_DateTypeCode>
                    </gmd:dateType>
                  </gmd:CI_Date>
                </gmd:date>
                <gmd:citedResponsibleParty>
                  <gmd:CI_ResponsibleParty>
                    <gmd:organisationName xsi:type="gmd:PT_FreeText_PropertyType">
                      <gco:CharacterString>
                        <xsl:choose>
                          <xsl:when test="$altLang = 'fra'">Government of Canada; Library and Archives Canada</xsl:when>
                          <xsl:otherwise>Gouvernement du Canada; Bibliothèque et Archives Canada</xsl:otherwise>
                        </xsl:choose>
                      </gco:CharacterString>
                      <gmd:PT_FreeText>
                        <gmd:textGroup>
                          <gmd:LocalisedCharacterString locale="#{$altLang}">
                            <xsl:choose>
                              <xsl:when test="$altLang = 'fra'">Gouvernement du Canada; Bibliothèque et Archives Canada</xsl:when>
                              <xsl:otherwise>Government of Canada; Library and Archives Canada</xsl:otherwise>
                            </xsl:choose>
                          </gmd:LocalisedCharacterString>
                        </gmd:textGroup>
                      </gmd:PT_FreeText>
                    </gmd:organisationName>
                    <gmd:role>
                      <gmd:CI_RoleCode codeListValue="RI_409" codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_90">custodian; conservateur</gmd:CI_RoleCode>
                    </gmd:role>
                  </gmd:CI_ResponsibleParty>
                </gmd:citedResponsibleParty>
              </gmd:CI_Citation>
            </gmd:thesaurusName>
          </gmd:MD_Keywords>
        </gmd:descriptiveKeywords>
      </xsl:if>

      <xsl:apply-templates select="gmd:resourceConstraints" />

      <xsl:if test="not(gmd:resourceConstraints)">
        <gmd:resourceConstraints>
          <gmd:MD_LegalConstraints>
            <gmd:useLimitation xsi:type="gmd:PT_FreeText_PropertyType" gco:nilReason="missing">
              <gco:CharacterString>
                <xsl:choose>
                  <xsl:when test="$altLang = 'fra'">Open Government Licence - Canada (http://open.canada.ca/en/open-government-licence-canada)</xsl:when>
                  <xsl:otherwise>Licence du gouvernement ouvert - Canada (http://ouvert.canada.ca/fr/licence-du-gouvernement-ouvert-canada)</xsl:otherwise>
                </xsl:choose>
              </gco:CharacterString>
              <gmd:PT_FreeText>
                <gmd:textGroup>
                  <gmd:LocalisedCharacterString locale="#{$altLang}">
                    <xsl:choose>
                      <xsl:when test="$altLang = 'fra'">Licence du gouvernement ouvert - Canada (http://ouvert.canada.ca/fr/licence-du-gouvernement-ouvert-canada)</xsl:when>
                      <xsl:otherwise>Open Government Licence - Canada (http://open.canada.ca/en/open-government-licence-canada)</xsl:otherwise>
                    </xsl:choose>
                  </gmd:LocalisedCharacterString>
                </gmd:textGroup>
              </gmd:PT_FreeText>
            </gmd:useLimitation>
            <gmd:accessConstraints>
              <gmd:MD_RestrictionCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_107" codeListValue="RI_606">license; licence</gmd:MD_RestrictionCode>
            </gmd:accessConstraints>
            <gmd:useConstraints>
              <gmd:MD_RestrictionCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_107" codeListValue="RI_606">license; licence</gmd:MD_RestrictionCode>
            </gmd:useConstraints>
            <gmd:otherConstraints xsi:type="gmd:PT_FreeText_PropertyType">
              <gco:CharacterString/>
              <gmd:PT_FreeText>
                <gmd:textGroup>
                  <gmd:LocalisedCharacterString  locale="#{$altLang}" />
                </gmd:textGroup>
              </gmd:PT_FreeText>
            </gmd:otherConstraints>
          </gmd:MD_LegalConstraints>
        </gmd:resourceConstraints>
      </xsl:if>

      <xsl:apply-templates select="gmd:aggregationInfo" />
      <xsl:apply-templates select="gmd:spatialRepresentationType" />
      <xsl:if test="not(gmd:spatialRepresentationType)">
        <gmd:spatialRepresentationType>
          <gmd:MD_SpatialRepresentationTypeCode codeListValue="" codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_109"/>
        </gmd:spatialRepresentationType>
      </xsl:if>

      <xsl:apply-templates select="gmd:spatialResolution" />
      <xsl:apply-templates select="gmd:language" />
      <xsl:apply-templates select="gmd:characterSet" />
      <xsl:apply-templates select="gmd:topicCategory" />
      <xsl:if test="not(gmd:topicCategory)">
        <gmd:topicCategory gco:nilReason="missing">
          <gmd:MD_TopicCategoryCode></gmd:MD_TopicCategoryCode>
        </gmd:topicCategory>
      </xsl:if>

      <xsl:apply-templates select="gmd:environmentDescription" />
      <xsl:apply-templates select="gmd:extent" />
      <xsl:apply-templates select="gmd:supplementalInformation" />
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================= -->
  <xsl:template match="gmd:CI_Address">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>

      <xsl:apply-templates select="gmd:deliveryPoint" />
      <xsl:apply-templates select="gmd:city" />
      <xsl:apply-templates select="gmd:administrativeArea" />
      <xsl:apply-templates select="gmd:postalCode" />
      <xsl:apply-templates select="gmd:country" />
      <xsl:apply-templates select="gmd:electronicMailAddress" />
      <xsl:if test="not(gmd:electronicMailAddress)">
        <xsl:choose>
          <xsl:when test="$mdLang = 'fra; CAN'">
            <gmd:electronicMailAddress xsi:type="gmd:PT_FreeText_PropertyType" gco:nilReason="missing">
              <gco:CharacterString/>
              <xsl:if test="isMultilingual">
                <gmd:PT_FreeText>
                  <gmd:textGroup>
                    <gmd:LocalisedCharacterString locale="#eng"/>
                  </gmd:textGroup>
                </gmd:PT_FreeText>
              </xsl:if>
            </gmd:electronicMailAddress>
          </xsl:when>
          <xsl:otherwise>
            <gmd:electronicMailAddress xsi:type="gmd:PT_FreeText_PropertyType" gco:nilReason="missing">
              <gco:CharacterString/>
              <xsl:if test="isMultilingual">
                <gmd:PT_FreeText>
                  <gmd:textGroup>
                    <gmd:LocalisedCharacterString locale="#fra"/>
                  </gmd:textGroup>
                </gmd:PT_FreeText>
              </xsl:if>
            </gmd:electronicMailAddress>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================= -->
  <xsl:template match="gmd:MD_Distribution">
    <xsl:choose>
      <xsl:when test="normalize-space($addOnlineResourceId) = 'true'">
        <xsl:copy>
          <xsl:apply-templates select="@*"/>

          <xsl:apply-templates select="gmd:distributionFormat"/>
          <xsl:apply-templates select="gmd:distributor"/>

          <xsl:for-each select="gmd:transferOptions">
            <xsl:copy>
              <xsl:apply-templates select="@*"/>

              <xsl:for-each select="gmd:MD_DigitalTransferOptions">
                <xsl:copy>
                  <xsl:apply-templates select="@*"/>

                  <xsl:apply-templates select="gmd:unitsOfDistribution"/>
                  <xsl:apply-templates select="gmd:transferSize"/>

                  <xsl:for-each select="gmd:onLine">
                    <xsl:copy>
                      <xsl:copy-of select="@*" />
                      <xsl:attribute name="xlink:title"><xsl:value-of select="concat('tor1', generate-id())" /></xsl:attribute>

                      <xsl:apply-templates select="node()"/>
                    </xsl:copy>
                  </xsl:for-each>

                  <xsl:apply-templates select="gmd:offLine"/>
                </xsl:copy>

              </xsl:for-each>

            </xsl:copy>
          </xsl:for-each>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ================================================================= -->

  <xsl:template match="gmd:organisationName[not(gmd:PT_FreeText)]">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:if test="not(@xsi:type)">
        <xsl:attribute name="xsi:type">gmd:PT_FreeText_PropertyType</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="*" />
      <xsl:if test="isMultilingual">
        <gmd:PT_FreeText>
          <gmd:textGroup>
            <gmd:LocalisedCharacterString locale="#{$altLang}">
            </gmd:LocalisedCharacterString>
          </gmd:textGroup>
        </gmd:PT_FreeText>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================= -->

  <xsl:template match="gmd:MD_Format">
    <xsl:copy>
      <xsl:copy-of select="@*" />

      <!-- Fix invalid multilingual gmd:name -->
      <xsl:choose>
        <xsl:when test="gmd:name/gmd:PT_FreeText">
          <gmd:name>
            <gco:CharacterString><xsl:value-of select="gmd:name/gco:CharacterString" /></gco:CharacterString>
          </gmd:name>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="gmd:name" />
        </xsl:otherwise>
      </xsl:choose>

      <xsl:apply-templates select="gmd:version" />
      <xsl:apply-templates select="gmd:amendmentNumber" />
      <xsl:apply-templates select="gmd:specification" />
      <xsl:apply-templates select="gmd:fileDecompressionTechnique" />
      <xsl:apply-templates select="gmd:formatDistributor" />
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================= -->

  <!-- copy everything else as is -->

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
