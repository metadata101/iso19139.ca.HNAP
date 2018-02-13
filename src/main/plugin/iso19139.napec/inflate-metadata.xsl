<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                  xmlns:gmd="http://www.isotc211.org/2005/gmd"
                  xmlns:xlink='http://www.w3.org/1999/xlink'
                  xmlns:gco="http://www.isotc211.org/2005/gco"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  xmlns:napec="http://www.ec.gc.ca/data_donnees/standards/schemas/napec"
                  exclude-result-prefixes="gmd xlink gco xsi napec">

  <xsl:variable name="lang"><xsl:value-of select="/root/env/lang"/></xsl:variable>
  <xsl:variable name="mdLang"><xsl:value-of select="//gmd:MD_Metadata/gmd:language/gco:CharacterString"/></xsl:variable>
  <xsl:variable name="addOnlineResourceId">
    <xsl:choose>
      <xsl:when test="/root/env/addOnlineResourceId"><xsl:value-of select="/root/env/addOnlineResourceId" /></xsl:when>
      <xsl:otherwise>true</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="altLang">
    <xsl:choose>
      <xsl:when test="$mdLang = 'eng; CAN'">fra</xsl:when>
      <xsl:otherwise>eng</xsl:otherwise>
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

      <xsl:apply-templates select="gmd:locale" />
      <xsl:if test="not(gmd:locale)">
        <gmd:locale>
        <xsl:choose>
          <xsl:when test="$mdLang = 'fra; CAN'">
            <gmd:PT_Locale id="eng">
              <gmd:languageCode>
                <gmd:LanguageCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_116" codeListValue="eng">English; Anglais</gmd:LanguageCode>
              </gmd:languageCode>
              <gmd:country>
                <gmd:Country codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_117" codeListValue="CAN">Canada; Canada</gmd:Country>
              </gmd:country>
              <gmd:characterEncoding>
                <gmd:MD_CharacterSetCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_95" codeListValue="RI_458">utf8; utf8</gmd:MD_CharacterSetCode>
              </gmd:characterEncoding>
            </gmd:PT_Locale>
          </xsl:when>
          <xsl:otherwise>
            <gmd:PT_Locale id="fra">
              <gmd:languageCode>
                <gmd:LanguageCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_116" codeListValue="fra">French; Français</gmd:LanguageCode>
              </gmd:languageCode>
              <gmd:country>
                <gmd:Country codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_117" codeListValue="CAN">Canada; Canada</gmd:Country>
              </gmd:country>
              <gmd:characterEncoding>
                <gmd:MD_CharacterSetCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_95" codeListValue="RI_458">utf8; utf8</gmd:MD_CharacterSetCode>
              </gmd:characterEncoding>
            </gmd:PT_Locale>
          </xsl:otherwise>
        </xsl:choose>
        </gmd:locale>
      </xsl:if>

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
  <xsl:template match="napec:MD_DataIdentification">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>

      <xsl:apply-templates select="gmd:citation" />
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

      <xsl:apply-templates select="napec:EC_CorporateInfo" />
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
              <gmd:PT_FreeText>
                <gmd:textGroup>
                  <gmd:LocalisedCharacterString locale="#eng"/>
                </gmd:textGroup>
              </gmd:PT_FreeText>
            </gmd:electronicMailAddress>
          </xsl:when>
          <xsl:otherwise>
            <gmd:electronicMailAddress xsi:type="gmd:PT_FreeText_PropertyType" gco:nilReason="missing">
              <gco:CharacterString/>
              <gmd:PT_FreeText>
                <gmd:textGroup>
                  <gmd:LocalisedCharacterString locale="#fra"/>
                </gmd:textGroup>
              </gmd:PT_FreeText>
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
  <!-- copy everything else as is -->

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>