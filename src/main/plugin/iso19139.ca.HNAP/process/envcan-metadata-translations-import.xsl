<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:xls="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">

  <xsl:param name="translations" />

  <!-- $replacements/replacements/replacement[field = $fieldIdDate and searchValue = ':;:'] -->
  <xsl:variable name="uuid" select="gmd:MD_Metadata/gmd:fileIdentifier/gco:CharacterString" />

  <xsl:variable name="mainLanguage" select="substring(gmd:MD_Metadata/gmd:language/gco:CharacterString, 1, 3)" />

  <xsl:variable name="localeLang">
    <xsl:choose>
      <xsl:when test="$mainLanguage = 'eng'">#fra</xsl:when>
      <xsl:otherwise>#eng</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template match="gmd:MD_Metadata">
    <xsl:copy>
      <xsl:copy-of select="@*"/>

      <xsl:apply-templates select="gmd:fileIdentifier" />
      <xsl:apply-templates select="gmd:language" />
      <xsl:apply-templates select="gmd:characterSet" />
      <xsl:apply-templates select="gmd:parentIdentifier" />
      <xsl:apply-templates select="gmd:hierarchyLevel" />
      <xsl:apply-templates select="gmd:hierarchyLevelName" />

      <xsl:for-each select="gmd:contact">
        <xsl:variable name="contactPos" select="position()" />
        <xsl:copy>
          <xsl:copy-of select="@*" />

          <xsl:call-template name="CI_ResponsibleParty">
            <xsl:with-param name="sectionPosition" select="$contactPos" />
          </xsl:call-template>
        </xsl:copy>
      </xsl:for-each>

      <xsl:apply-templates select="gmd:dateStamp" />
      <xsl:apply-templates select="gmd:metadataStandardName" />
      <xsl:apply-templates select="gmd:metadataStandardVersion" />
      <xsl:apply-templates select="gmd:dataSetURI" />
      <xsl:apply-templates select="gmd:locale" />
      <xsl:apply-templates select="gmd:spatialRepresentationInfo" />
      <xsl:apply-templates select="gmd:referenceSystemInfo" />
      <xsl:apply-templates select="gmd:metadataExtensionInfo" />
      <xsl:apply-templates select="gmd:identificationInfo" />
      <xsl:apply-templates select="gmd:contentInfo" />
      <xsl:apply-templates select="gmd:distributionInfo" />
      <xsl:apply-templates select="gmd:dataQualityInfo" />
      <xsl:apply-templates select="gmd:portrayalCatalogueInfo" />
      <xsl:apply-templates select="gmd:metadataConstraints" />
      <xsl:apply-templates select="gmd:applicationSchemaInfo" />
      <xsl:apply-templates select="gmd:metadataMaintenance" />
      <xsl:apply-templates select="gmd:series" />
      <xsl:apply-templates select="gmd:describes" />
      <xsl:apply-templates select="gmd:propertyType" />
      <xsl:apply-templates select="gmd:featureType" />
      <xsl:apply-templates select="gmd:featureAttribute" />

    </xsl:copy>
  </xsl:template>

  <!-- Do a copy of every nodes and attributes -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="gmd:identificationInfo/gmd:MD_DataIdentification" priority="100">
    <xsl:copy>
      <xsl:copy-of select="@*" />

      <!-- Citation -->
      <xsl:for-each select="gmd:citation">
        <xsl:copy>
          <xsl:copy-of select="@*" />

          <!-- CI_Citation -->
          <xsl:for-each select="gmd:CI_Citation">
            <xsl:copy>
              <xsl:copy-of select="@*" />

              <!-- Title -->
              <xsl:for-each select="gmd:title">
                <xsl:call-template name="updateTranslation" />
              </xsl:for-each>

              <xsl:apply-templates select="gmd:alternateTitle|
                                gmd:date|
                                gmd:edition|
                                gmd:editionDate|
                                gmd:identifier" />


              <!-- citedResponsibleParty -->
              <xsl:for-each select="gmd:citedResponsibleParty">
                <xsl:variable name="citedResponsiblePartyPos" select="position()" />
                <xsl:copy>
                  <xsl:copy-of select="@*" />

                  <xsl:call-template name="CI_ResponsibleParty">
                    <xsl:with-param name="sectionPosition" select="$citedResponsiblePartyPos" />
                  </xsl:call-template>
                </xsl:copy>
              </xsl:for-each>


              <xsl:apply-templates select="gmd:presentationForm|
                                gmd:series|
                                gmd:otherCitationDetails|
                                gmd:collectiveTitle|
                                gmd:ISBN|
                                gmd:ISSN" />

            </xsl:copy>

          </xsl:for-each>

        </xsl:copy>
      </xsl:for-each>


      <xsl:for-each select="gmd:abstract">
        <xsl:call-template name="updateTranslation" />
      </xsl:for-each>

      <xsl:apply-templates select="gmd:purpose" />
      <xsl:apply-templates select="gmd:credit" />
      <xsl:apply-templates select="gmd:status" />
      <xsl:apply-templates select="gmd:pointOfContact" />
      <xsl:apply-templates select="gmd:resourceMaintenance" />
      <xsl:apply-templates select="gmd:graphicOverview" />
      <xsl:apply-templates select="gmd:resourceFormat" />

      <!--<xsl:apply-templates select="gmd:descriptiveKeywords" />-->

      <xsl:for-each select="gmd:descriptiveKeywords">
        <xsl:variable name="descriptiveKeywordsPos" select="position()" />

        <xsl:copy>
          <xsl:copy-of select="@*" />

          <xsl:for-each select="gmd:MD_Keywords">

            <xsl:copy>
              <xsl:copy-of select="@*" />

              <xsl:for-each select="gmd:keyword">

                <xsl:choose>
                  <xsl:when test="not(../gmd:thesaurusName/gmd:CI_Citation/@id)">

                    <xsl:call-template name="updateTranslation">
                      <xsl:with-param name="position" select="concat($descriptiveKeywordsPos, '-', position())" />

                    </xsl:call-template>

                  </xsl:when>
                  <!-- Special keywords,  copy them -->
                  <xsl:otherwise>
                    <xsl:copy-of select="." />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>

              <xsl:apply-templates select="gmd:type" />
              <xsl:apply-templates select="gmd:thesaurusName" />
            </xsl:copy>
          </xsl:for-each>
        </xsl:copy>
      </xsl:for-each>

      <xsl:apply-templates select="gmd:resourceSpecificUsage" />
      <xsl:apply-templates select="gmd:resourceConstraints" />
      <xsl:apply-templates select="gmd:aggregationInfo" />
      <xsl:apply-templates select="gmd:spatialRepresentationType" />
      <xsl:apply-templates select="gmd:spatialResolution" />
      <xsl:apply-templates select="gmd:language" />
      <xsl:apply-templates select="gmd:characterSet" />
      <xsl:apply-templates select="gmd:topicCategory" />
      <xsl:apply-templates select="gmd:environmentDescription" />
      <xsl:apply-templates select="gmd:extent" />

      <xsl:for-each select="gmd:supplementalInformation">
        <xsl:call-template name="updateTranslation">
          <xsl:with-param name="position" select="position()" />
        </xsl:call-template>
      </xsl:for-each>

    </xsl:copy>
  </xsl:template>

  <xsl:template match="gmd:identificationInfo/srv:SV_ServiceIdentification" priority="100">
    <xsl:copy>
      <xsl:copy-of select="@*" />

      <!-- Citation -->
      <xsl:for-each select="gmd:citation">
        <xsl:copy>
          <xsl:copy-of select="@*" />

          <!-- CI_Citation -->
          <xsl:for-each select="gmd:CI_Citation">
            <xsl:copy>
              <xsl:copy-of select="@*" />

              <!-- Title -->
              <xsl:for-each select="gmd:title">
                <xsl:call-template name="updateTranslation" />
              </xsl:for-each>

              <xsl:apply-templates select="gmd:alternateTitle|
                                gmd:date|
                                gmd:edition|
                                gmd:editionDate|
                                gmd:identifier" />


              <!-- citedResponsibleParty -->
              <xsl:for-each select="gmd:citedResponsibleParty">
                <xsl:variable name="citedResponsiblePartyPos" select="position()" />
                <xsl:copy>
                  <xsl:copy-of select="@*" />

                  <xsl:call-template name="CI_ResponsibleParty">
                    <xsl:with-param name="sectionPosition" select="$citedResponsiblePartyPos" />
                  </xsl:call-template>
                </xsl:copy>
              </xsl:for-each>


              <xsl:apply-templates select="gmd:presentationForm|
                                gmd:series|
                                gmd:otherCitationDetails|
                                gmd:collectiveTitle|
                                gmd:ISBN|
                                gmd:ISSN" />

            </xsl:copy>

          </xsl:for-each>

        </xsl:copy>
      </xsl:for-each>


      <xsl:for-each select="gmd:abstract">
        <xsl:call-template name="updateTranslation" />
      </xsl:for-each>

      <xsl:apply-templates select="gmd:purpose" />
      <xsl:apply-templates select="gmd:credit" />
      <xsl:apply-templates select="gmd:status" />
      <xsl:apply-templates select="gmd:pointOfContact" />
      <xsl:apply-templates select="gmd:resourceMaintenance" />
      <xsl:apply-templates select="gmd:graphicOverview" />
      <xsl:apply-templates select="gmd:resourceFormat" />

      <!--<xsl:apply-templates select="gmd:descriptiveKeywords" />-->

      <xsl:for-each select="gmd:descriptiveKeywords">
        <xsl:variable name="descriptiveKeywordsPos" select="position()" />

        <xsl:copy>
          <xsl:copy-of select="@*" />

          <xsl:for-each select="gmd:MD_Keywords">

            <xsl:copy>
              <xsl:copy-of select="@*" />

              <xsl:for-each select="gmd:keyword">

                <xsl:choose>
                  <xsl:when test="not(../gmd:thesaurusName/gmd:CI_Citation/@id)">

                    <xsl:call-template name="updateTranslation">
                      <xsl:with-param name="position" select="concat($descriptiveKeywordsPos, '-', position())" />

                    </xsl:call-template>

                  </xsl:when>
                  <!-- Special keywords,  copy them -->
                  <xsl:otherwise>
                    <xsl:copy-of select="." />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>

              <xsl:apply-templates select="gmd:type" />
              <xsl:apply-templates select="gmd:thesaurusName" />
            </xsl:copy>
          </xsl:for-each>
        </xsl:copy>
      </xsl:for-each>

      <xsl:apply-templates select="gmd:resourceSpecificUsage" />
      <xsl:apply-templates select="gmd:resourceConstraints" />
      <xsl:apply-templates select="gmd:aggregationInfo" />
      <xsl:apply-templates select="srv:*" />
    </xsl:copy>
  </xsl:template>

  <!-- distributor contact -->
  <xsl:template match="gmd:distributionInfo/gmd:MD_Distribution" priority="100">
    <xsl:copy>
      <xsl:copy-of select="@*" />

      <xsl:apply-templates select="gmd:distributionFormat" />

      <xsl:for-each select="gmd:distributor">
        <xsl:variable name="distributorPos" select="position()" />

        <xsl:copy>
          <xsl:copy-of select="@*" />

          <xsl:for-each select="gmd:MD_Distributor">
            <xsl:copy>
              <xsl:copy-of select="@*" />

              <xsl:for-each select="gmd:distributorContact">
                <xsl:copy>
                  <xsl:copy-of select="@*" />

                  <xsl:call-template name="CI_ResponsibleParty">
                    <xsl:with-param name="sectionPosition" select="$distributorPos" />
                  </xsl:call-template>
                </xsl:copy>
              </xsl:for-each>

              <xsl:apply-templates select="gmd:distributionOrderProcess" />
              <xsl:apply-templates select="gmd:distributorFormat" />
              <xsl:apply-templates select="gmd:distributorTransferOptions" />
            </xsl:copy>
          </xsl:for-each>
        </xsl:copy>
      </xsl:for-each>

      <xsl:apply-templates select="gmd:transferOptions" />
    </xsl:copy>
  </xsl:template>

  <!-- Imports a gmd:CI_ResponsibleParty section -->
  <xsl:template name="CI_ResponsibleParty">
    <xsl:param name="sectionPosition" />

    <xsl:for-each select="gmd:CI_ResponsibleParty">
      <xsl:copy>
        <xsl:copy-of select="@*" />

        <xsl:apply-templates select="gmd:individualName" />

        <xsl:for-each select="gmd:organisationName">
          <xsl:call-template name="updateTranslation">
            <xsl:with-param name="position" select="$sectionPosition" />
          </xsl:call-template>
        </xsl:for-each>

        <xsl:for-each select="gmd:positionName">
          <xsl:call-template name="updateTranslation">
            <xsl:with-param name="position" select="$sectionPosition" />
          </xsl:call-template>
        </xsl:for-each>

        <xsl:for-each select="gmd:contactInfo">
          <xsl:copy>
            <xsl:copy-of select="@*" />

            <xsl:for-each select="gmd:CI_Contact">
              <xsl:copy>
                <xsl:copy-of select="@*" />

                <xsl:apply-templates select="gmd:phone" />

                <xsl:for-each select="gmd:address">
                  <xsl:copy>
                    <xsl:copy-of select="@*" />

                    <xsl:for-each select="gmd:CI_Address">
                      <xsl:copy>
                        <xsl:copy-of select="@*" />
                        <xsl:for-each select="gmd:deliveryPoint">
                          <xsl:call-template name="updateTranslation">
                            <xsl:with-param name="position" select="concat($sectionPosition, '-', position())" />
                          </xsl:call-template>
                        </xsl:for-each>

                        <xsl:apply-templates select="gmd:city|gmd:administrativeArea|gmd:postalCode|gmd:country" />

                        <xsl:for-each select="gmd:electronicMailAddress">
                          <xsl:call-template name="updateTranslation">
                            <xsl:with-param name="position" select="concat($sectionPosition, '-', position())" />
                          </xsl:call-template>
                        </xsl:for-each>
                      </xsl:copy>
                    </xsl:for-each>
                  </xsl:copy>
                </xsl:for-each>

                <xsl:apply-templates select="gmd:onlineResource" />


                <xsl:for-each select="gmd:hoursOfService">
                  <xsl:call-template name="updateTranslation">
                    <xsl:with-param name="position" select="$sectionPosition" />
                  </xsl:call-template>
                </xsl:for-each>

                <xsl:for-each select="gmd:contactInstructions">
                  <xsl:call-template name="updateTranslation">
                    <xsl:with-param name="position" select="$sectionPosition" />
                  </xsl:call-template>
                </xsl:for-each>

              </xsl:copy>
            </xsl:for-each>
          </xsl:copy>
        </xsl:for-each>

        <xsl:apply-templates select="gmd:role" />

      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="updateTranslation">
    <xsl:param name="position" select="'1'" />

    <xsl:variable name="xpath"><xsl:call-template name="getXPath" /></xsl:variable>

    <xsl:choose>
      <!-- Apply the translations -->
      <xsl:when test="$translations/translations/translation[field = $xpath and position = $position]">
        <xsl:variable name="englishTranslation" select="$translations/translations/translation[field = $xpath and position = $position]/englishText" />
        <xsl:variable name="frenchTranslation" select="$translations/translations/translation[field = $xpath and position = $position]/frenchText" />

        <xsl:variable name="englishActual">
          <xsl:choose>
            <xsl:when test="$mainLanguage = 'eng'"><xsl:value-of select="gco:CharacterString" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString" /></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="frenchActual">
          <xsl:choose>
            <xsl:when test="$mainLanguage = 'fra'"><xsl:value-of select="gco:CharacterString" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString" /></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:copy>
          <xsl:choose>
            <xsl:when
              test="string($englishTranslation) or string($englishActual) or string($frenchTranslation) or string($englishActual)">
              <xsl:copy-of select="@*[name() != 'gco:nilReason']" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="@*" />
            </xsl:otherwise>
          </xsl:choose>

          <xsl:if test="not(@xsi:type)">
            <xsl:attribute name="xsi:type">gmd:PT_FreeText_PropertyType</xsl:attribute>
          </xsl:if>

          <!-- Main language -->
          <gco:CharacterString>
            <xsl:choose>
              <xsl:when test="$mainLanguage = 'eng'">
                <xsl:choose>
                  <xsl:when test="string($englishTranslation)"><xsl:value-of
                    select="$englishTranslation" /></xsl:when>

                  <xsl:otherwise>
                    <xsl:value-of
                      select="$englishActual" />
                  </xsl:otherwise>
                </xsl:choose>

              </xsl:when>

              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="string($frenchTranslation)"><xsl:value-of
                    select="$frenchTranslation" /></xsl:when>

                  <xsl:otherwise>
                    <xsl:value-of
                      select="$frenchActual" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </gco:CharacterString>


          <!-- Locales -->
          <xsl:if test="not(gmd:PT_FreeText)">
            <gmd:PT_FreeText>
              <gmd:textGroup>
                <gmd:LocalisedCharacterString locale="{$localeLang}">
                  <xsl:choose>
                    <xsl:when test="$localeLang='#eng'">
                      <xsl:choose>
                        <xsl:when test="string($englishTranslation)"><xsl:value-of
                          select="$englishTranslation" /></xsl:when>

                        <xsl:otherwise>
                          <xsl:value-of
                            select="$englishActual" />
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$localeLang='#fra'">
                      <xsl:choose>
                        <xsl:when test="string($frenchTranslation)"><xsl:value-of
                          select="$frenchTranslation" /></xsl:when>

                        <xsl:otherwise>
                          <xsl:value-of
                            select="$frenchActual" />
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:when>
                  </xsl:choose>
                </gmd:LocalisedCharacterString>
              </gmd:textGroup>
            </gmd:PT_FreeText>
          </xsl:if>

          <xsl:for-each select="gmd:PT_FreeText">
            <xsl:copy>
              <xsl:copy-of select="@*" />

              <xsl:for-each select="gmd:textGroup">
                <xsl:copy>
                  <xsl:copy-of select="@*" />

                  <xsl:for-each select="gmd:LocalisedCharacterString">
                    <xsl:copy>
                      <xsl:copy-of select="@*" />

                      <xsl:choose>
                        <xsl:when test="@locale='#eng'">
                          <xsl:choose>
                            <xsl:when test="string($englishTranslation)"><xsl:value-of
                              select="$englishTranslation" /></xsl:when>

                            <xsl:otherwise>
                              <xsl:value-of
                                select="$englishActual" />
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:when>
                        <xsl:when test="@locale='#fra'">
                          <xsl:choose>
                            <xsl:when test="string($frenchTranslation)"><xsl:value-of
                              select="$frenchTranslation" /></xsl:when>

                            <xsl:otherwise>
                              <xsl:value-of
                                select="$frenchActual" />
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:apply-templates select="*" />
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:copy>
                  </xsl:for-each> <!-- gmd:LocalisedCharacterString -->
                </xsl:copy>
              </xsl:for-each> <!-- gmd:textGroup -->
            </xsl:copy>

            <!-- Create the node -->
            <xsl:if test="not(gmd:textGroup/gmd:LocalisedCharacterString[@locale=$localeLang])">
              <gmd:PT_FreeText>
                <gmd:textGroup>
                  <gmd:LocalisedCharacterString locale="{$localeLang}">
                    <xsl:choose>
                      <xsl:when test="$localeLang='#eng'">
                        <xsl:choose>
                          <xsl:when test="string($englishTranslation)"><xsl:value-of
                            select="$englishTranslation" /></xsl:when>

                          <xsl:otherwise>
                            <xsl:value-of
                              select="$englishActual" />
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:when>
                      <xsl:when test="$localeLang='#fra'">
                        <xsl:choose>
                          <xsl:when test="string($frenchTranslation)"><xsl:value-of
                            select="$frenchTranslation" /></xsl:when>

                          <xsl:otherwise>
                            <xsl:value-of
                              select="$frenchActual" />
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:when>
                    </xsl:choose>
                  </gmd:LocalisedCharacterString>
                </gmd:textGroup>
              </gmd:PT_FreeText>
            </xsl:if>
          </xsl:for-each> <!-- gmd:PT_FreeText -->
        </xsl:copy>

      </xsl:when>

      <!-- Copy the node -->
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>

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
</xsl:stylesheet>
