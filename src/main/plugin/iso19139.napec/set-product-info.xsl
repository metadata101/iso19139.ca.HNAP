<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:napec="http://www.ec.gc.ca/data_donnees/standards/schemas/napec"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:srv="http://www.isotc211.org/2005/srv" exclude-result-prefixes="gmd">

  <xsl:variable name="mdLang" select="/root/gmd:MD_Metadata/gmd:language/gco:CharacterString" />

  <!-- ================================================================= -->

	<xsl:template match="/root">
		 <xsl:apply-templates select="gmd:MD_Metadata"/>
	</xsl:template>

  <!-- ================================================================= -->

  <xsl:template match="gmd:MD_Metadata">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>

      <xsl:apply-templates select="gmd:fileIdentifier"/>
      <xsl:apply-templates select="gmd:language"/>
      <xsl:apply-templates select="gmd:characterSet"/>

      <xsl:choose>
        <xsl:when test="/root/env/parentUuid!=''">
          <gmd:parentIdentifier>
            <gco:CharacterString>
              <xsl:value-of select="/root/env/parentUuid"/>
            </gco:CharacterString>
          </gmd:parentIdentifier>
        </xsl:when>
        <xsl:when test="gmd:parentIdentifier">
          <xsl:copy-of select="gmd:parentIdentifier"/>
        </xsl:when>
      </xsl:choose>

      <xsl:apply-templates select="node()[name()!='gmd:fileIdentifier' and name()!='gmd:language' and name()!='gmd:characterSet']"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:choose>
        <!-- Metadata main language is french -->
        <xsl:when test="starts-with($mdLang, 'fra')">
          <gco:CharacterString><xsl:value-of select="/root/env/title_fre"/></gco:CharacterString>
            <gmd:PT_FreeText>
              <gmd:textGroup>
                <gmd:LocalisedCharacterString locale="#eng"><xsl:value-of select="/root/env/title_eng"/></gmd:LocalisedCharacterString>
              </gmd:textGroup>
            </gmd:PT_FreeText>
        </xsl:when>
        <!-- Metadata main language is english -->
        <xsl:otherwise>
          <gco:CharacterString><xsl:value-of select="/root/env/title_eng"/></gco:CharacterString>
          <gmd:PT_FreeText>
            <gmd:textGroup>
              <gmd:LocalisedCharacterString locale="#fra"><xsl:value-of select="/root/env/title_fre"/></gmd:LocalisedCharacterString>
            </gmd:textGroup>
          </gmd:PT_FreeText>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================= -->

  <xsl:template match="gmd:hierarchyLevel">
    <xsl:copy>
      <gmd:MD_ScopeCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_108" codeListValue="RI_622">dataset; jeuDonnées</gmd:MD_ScopeCode>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================= -->

  <xsl:template match="gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/@id='local.theme.EC_Waf']" />
  <xsl:template match="gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString='local.theme.EC_Waf']" />

  <!-- ================================================================= -->

  <xsl:template match="napec:MD_DataIdentification">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates select="gmd:citation" />
      <xsl:apply-templates select="gmd:abstract" />
      <xsl:apply-templates select="gmd:purpose" />
      <xsl:apply-templates select="gmd:credit" />
      <xsl:apply-templates select="gmd:status" />
      <xsl:apply-templates select="gmd:pointOfContact" />
      <xsl:apply-templates select="gmd:resourceMaintenance" />
      <xsl:apply-templates select="gmd:graphicOverview" />
      <xsl:apply-templates select="gmd:resourceFormat" />
      <xsl:apply-templates select="gmd:descriptiveKeywords" />

      <!-- Theme -->
      <gmd:descriptiveKeywords>
        <gmd:MD_Keywords id="classification-theme">
          <gmd:keyword xsi:type="gmd:PT_FreeText_PropertyType">
            <xsl:choose>
              <!-- Metadata main language is french -->
              <xsl:when test="starts-with($mdLang, 'fra')">
                <gco:CharacterString><xsl:value-of select="/root/env/theme_fre"/></gco:CharacterString>
                <gmd:PT_FreeText>
                  <gmd:textGroup>
                    <gmd:LocalisedCharacterString locale="#eng"><xsl:value-of select="/root/env/theme_eng"/></gmd:LocalisedCharacterString>
                  </gmd:textGroup>
                </gmd:PT_FreeText>
              </xsl:when>
              <!-- Metadata main language is english -->
              <xsl:otherwise>
                <gco:CharacterString><xsl:value-of select="/root/env/theme_eng"/></gco:CharacterString>
                <gmd:PT_FreeText>
                  <gmd:textGroup>
                    <gmd:LocalisedCharacterString locale="#fra"><xsl:value-of select="/root/env/theme_fre"/></gmd:LocalisedCharacterString>
                  </gmd:textGroup>
                </gmd:PT_FreeText>
              </xsl:otherwise>
            </xsl:choose>
          </gmd:keyword>
          <gmd:type>
            <gmd:MD_KeywordTypeCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_101" codeListValue="RI_528">theme; thème</gmd:MD_KeywordTypeCode>
          </gmd:type>
          <xsl:call-template name="thesaurusName" />
        </gmd:MD_Keywords>
      </gmd:descriptiveKeywords>

      <!-- Subtheme -->
      <gmd:descriptiveKeywords>
        <gmd:MD_Keywords id="classification-subtheme">
          <gmd:keyword xsi:type="gmd:PT_FreeText_PropertyType">
            <xsl:choose>
              <!-- Metadata main language is french -->
              <xsl:when test="starts-with($mdLang, 'fra')">
                <gco:CharacterString><xsl:value-of select="/root/env/subtheme_fre"/></gco:CharacterString>
                <gmd:PT_FreeText>
                  <gmd:textGroup>
                    <gmd:LocalisedCharacterString locale="#eng"><xsl:value-of select="/root/env/subtheme_eng"/></gmd:LocalisedCharacterString>
                  </gmd:textGroup>
                </gmd:PT_FreeText>
              </xsl:when>
              <!-- Metadata main language is english -->
              <xsl:otherwise>
                <gco:CharacterString><xsl:value-of select="/root/env/subtheme_eng"/></gco:CharacterString>
                <gmd:PT_FreeText>
                  <gmd:textGroup>
                    <gmd:LocalisedCharacterString locale="#fra"><xsl:value-of select="/root/env/subtheme_fre"/></gmd:LocalisedCharacterString>
                  </gmd:textGroup>
                </gmd:PT_FreeText>
              </xsl:otherwise>
            </xsl:choose>
          </gmd:keyword>
          <gmd:type>
            <gmd:MD_KeywordTypeCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_101" codeListValue="RI_528">theme; thème</gmd:MD_KeywordTypeCode>
          </gmd:type>
          <xsl:call-template name="thesaurusName" />
        </gmd:MD_Keywords>
      </gmd:descriptiveKeywords>

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
      <xsl:apply-templates select="gmd:supplementalInformation" />
      <xsl:apply-templates select="napec:EC_CorporateInfo" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="napec:SV_ServiceIdentification">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates select="gmd:citation" />
      <xsl:apply-templates select="gmd:abstract" />
      <xsl:apply-templates select="gmd:purpose" />
      <xsl:apply-templates select="gmd:credit" />
      <xsl:apply-templates select="gmd:status" />
      <xsl:apply-templates select="gmd:pointOfContact" />
      <xsl:apply-templates select="gmd:resourceMaintenance" />
      <xsl:apply-templates select="gmd:graphicOverview" />
      <xsl:apply-templates select="gmd:resourceFormat" />
      <xsl:apply-templates select="gmd:descriptiveKeywords" />

      <!-- Theme -->
      <gmd:descriptiveKeywords>
        <gmd:MD_Keywords id="classification-theme">
          <gmd:keyword xsi:type="gmd:PT_FreeText_PropertyType">
            <xsl:choose>
              <!-- Metadata main language is french -->
              <xsl:when test="starts-with($mdLang, 'fra')">
                <gco:CharacterString><xsl:value-of select="/root/env/theme_fre"/></gco:CharacterString>
                <gmd:PT_FreeText>
                  <gmd:textGroup>
                    <gmd:LocalisedCharacterString locale="#eng"><xsl:value-of select="/root/env/theme_eng"/></gmd:LocalisedCharacterString>
                  </gmd:textGroup>
                </gmd:PT_FreeText>
              </xsl:when>
              <!-- Metadata main language is english -->
              <xsl:otherwise>
                <gco:CharacterString><xsl:value-of select="/root/env/theme_eng"/></gco:CharacterString>
                <gmd:PT_FreeText>
                  <gmd:textGroup>
                    <gmd:LocalisedCharacterString locale="#fra"><xsl:value-of select="/root/env/theme_fre"/></gmd:LocalisedCharacterString>
                  </gmd:textGroup>
                </gmd:PT_FreeText>
              </xsl:otherwise>
            </xsl:choose>
          </gmd:keyword>
          <gmd:type>
            <gmd:MD_KeywordTypeCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_101" codeListValue="RI_528">theme; thème</gmd:MD_KeywordTypeCode>
          </gmd:type>
          <xsl:call-template name="thesaurusName" />
        </gmd:MD_Keywords>
      </gmd:descriptiveKeywords>

      <!-- Subtheme -->
      <gmd:descriptiveKeywords>
        <gmd:MD_Keywords id="classification-subtheme">
          <gmd:keyword xsi:type="gmd:PT_FreeText_PropertyType">
            <xsl:choose>
              <!-- Metadata main language is french -->
              <xsl:when test="starts-with($mdLang, 'fra')">
                <gco:CharacterString><xsl:value-of select="/root/env/subtheme_fre"/></gco:CharacterString>
                <gmd:PT_FreeText>
                  <gmd:textGroup>
                    <gmd:LocalisedCharacterString locale="#eng"><xsl:value-of select="/root/env/subtheme_eng"/></gmd:LocalisedCharacterString>
                  </gmd:textGroup>
                </gmd:PT_FreeText>
              </xsl:when>
              <!-- Metadata main language is english -->
              <xsl:otherwise>
                <gco:CharacterString><xsl:value-of select="/root/env/subtheme_eng"/></gco:CharacterString>
                <gmd:PT_FreeText>
                  <gmd:textGroup>
                    <gmd:LocalisedCharacterString locale="#fra"><xsl:value-of select="/root/env/subtheme_fre"/></gmd:LocalisedCharacterString>
                  </gmd:textGroup>
                </gmd:PT_FreeText>
              </xsl:otherwise>
            </xsl:choose>
          </gmd:keyword>
          <gmd:type>
            <gmd:MD_KeywordTypeCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_101" codeListValue="RI_528">theme; thème</gmd:MD_KeywordTypeCode>
          </gmd:type>
          <xsl:call-template name="thesaurusName" />
        </gmd:MD_Keywords>
      </gmd:descriptiveKeywords>

      <xsl:apply-templates select="gmd:resourceSpecificUsage" />
      <xsl:apply-templates select="gmd:resourceConstraints" />
      <xsl:apply-templates select="gmd:aggregationInfo" />
      <xsl:apply-templates select="srv:*"/>
      <xsl:apply-templates select="napec:EC_CorporateInfo" />
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================= -->

  <!-- remove the online resources, product metadata is created from the collection md and don't want to keep the online resources -->
  <xsl:template match="gmd:MD_DigitalTransferOptions">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>

      <xsl:apply-templates select="gmd:unitsOfDistribution" />
      <xsl:apply-templates select="gmd:transferSize" />

      <xsl:if test="/root/env/keeplinks = 'true'">
        <xsl:apply-templates select="gmd:onLine" />
      </xsl:if>

      <xsl:apply-templates select="gmd:offLine" />

    </xsl:copy>
  </xsl:template>

  <!-- ================================================================= -->

  <xsl:template name="thesaurusName">
    <gmd:thesaurusName>
      <gmd:CI_Citation>
        <gmd:title xsi:type="gmd:PT_FreeText_PropertyType">
          <gco:CharacterString>local.theme.EC_Waf</gco:CharacterString>
          <gmd:PT_FreeText>
            <gmd:textGroup>
              <xsl:choose>
                <!-- Metadata main language is french -->
                <xsl:when test="starts-with($mdLang, 'fra')">
                  <gmd:LocalisedCharacterString locale="#eng">local.theme.EC_Waf</gmd:LocalisedCharacterString>

                </xsl:when>
                <xsl:otherwise>
                  <gmd:LocalisedCharacterString locale="#fra">local.theme.EC_Waf</gmd:LocalisedCharacterString>
                </xsl:otherwise>
              </xsl:choose>
            </gmd:textGroup>
          </gmd:PT_FreeText>
        </gmd:title>
        <gmd:date>
          <gmd:CI_Date>
            <gmd:date>
              <gco:Date>2012-05-25</gco:Date>
            </gmd:date>
            <gmd:dateType>
              <gmd:CI_DateTypeCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_87" codeListValue="RI_367">publication; publication</gmd:CI_DateTypeCode>
            </gmd:dateType>
          </gmd:CI_Date>
        </gmd:date>
        <gmd:date>
          <gmd:CI_Date>
            <gmd:date>
              <gco:Date>2012-05-25</gco:Date>
            </gmd:date>
            <gmd:dateType>
              <gmd:CI_DateTypeCode codeListValue="RI_366" codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_87">creation; création</gmd:CI_DateTypeCode>
            </gmd:dateType>
          </gmd:CI_Date>
        </gmd:date>
        <gmd:citedResponsibleParty>
          <gmd:CI_ResponsibleParty>
            <xsl:choose>
              <xsl:when test="starts-with($mdLang, 'fra')">
                <gmd:organisationName xsi:type="gmd:PT_FreeText_PropertyType">
                  <gco:CharacterString>Gouvernement du Canada; Environnement et Changement climatique Canada</gco:CharacterString>
                  <gmd:PT_FreeText>
                    <gmd:textGroup>
                      <gmd:LocalisedCharacterString locale="#eng">Government of Canada; Environment and Climate Change Canada</gmd:LocalisedCharacterString>
                    </gmd:textGroup>
                  </gmd:PT_FreeText>
                </gmd:organisationName>
              </xsl:when>
              <xsl:otherwise>
                <gmd:organisationName xsi:type="gmd:PT_FreeText_PropertyType">
                  <gco:CharacterString>Government of Canada; Environment and Climate Change Canada</gco:CharacterString>
                  <gmd:PT_FreeText>
                    <gmd:textGroup>
                      <gmd:LocalisedCharacterString locale="#fra">Gouvernement du Canada; Environnement et Changement climatique Canada</gmd:LocalisedCharacterString>
                    </gmd:textGroup>
                  </gmd:PT_FreeText>
                </gmd:organisationName>
              </xsl:otherwise>
            </xsl:choose>

            <gmd:role>
              <gmd:CI_RoleCode codeListValue="RI_409" codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_90">custodian; conservateur</gmd:CI_RoleCode>
            </gmd:role>
          </gmd:CI_ResponsibleParty>
        </gmd:citedResponsibleParty>
      </gmd:CI_Citation>
    </gmd:thesaurusName>
  </xsl:template>

  <!-- ================================================================= -->

	<xsl:template match="@*|node()">
		 <xsl:copy>
			  <xsl:apply-templates select="@*|node()"/>
		 </xsl:copy>
	</xsl:template>

	<!-- ================================================================= -->

</xsl:stylesheet>
