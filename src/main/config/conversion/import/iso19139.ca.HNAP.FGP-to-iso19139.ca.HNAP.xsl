<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

  <!-- There are some known discrepancies between FGP and HNAP due to misinterpretations of the standards
       This converter is to be used to fix these discrepancies until a resolution is made.
       Refer to the related metadata 101 issues which should be documented next to each fix below. -->

  <xsl:include href="../../../WEB-INF/data/config/schema_plugins/iso19139.ca.HNAP/convert/functions.xsl"/>

  <xsl:variable name="metadataStandardNameEng"
                select="'North American Profile of ISO 19115:2003 - Geographic information - Metadata'"/>
  <xsl:variable name="metadataStandardNameFre"
                select="'Profil nord-américain de la norme ISO 19115:2003 - Information géographique - Métadonnées'"/>
  <xsl:variable name="metadataStandardVersion" select="'CAN/CGSB-171.100-2009'"/>


  <!-- The default language is also added as gmd:locale
 for multilingual metadata records. -->
  <xsl:variable name="mainLanguage">
    <xsl:call-template name="langId_from_gmdlanguage19139">
      <xsl:with-param name="gmdlanguage" select="/*[@gco:isoType='gmd:MD_Metadata' or name()='gmd:MD_Metadata']/gmd:language"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="locales"
                select="/*[@gco:isoType='gmd:MD_Metadata' or name()='gmd:MD_Metadata']/gmd:locale/gmd:PT_Locale"/>

  <xsl:variable name="altLanguage" select="$locales[gmd:languageCode/*/@codeListValue != $mainLanguage and (gmd:languageCode/*/@codeListValue = 'eng' or gmd:languageCode/*/@codeListValue = 'fra')]/gmd:languageCode/*/@codeListValue"/>
  <xsl:variable name="altLanguageId" select="$locales[gmd:languageCode/*/@codeListValue != $mainLanguage and (gmd:languageCode/*/@codeListValue = 'eng' or gmd:languageCode/*/@codeListValue = 'fra')]/@id"/>

  <!-- FGP fix namespace issue
       https://github.com/metadata101/iso19139.ca.HNAP/issues/172
        https://github.com/metadata101/iso19139.ca.HNAP/issues/169
        -->
  <xsl:template match="gmd:MD_Metadata">
    <xsl:copy copy-namespaces="no">
      <xsl:call-template name="add-namespaces"/>

      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <!-- FGP fix issue where french country is not following the iso code. So "Canada" should be "Canada (le)"
      gco:CharacterString incorrect
      https://github.com/metadata101/iso19139.ca.HNAP/issues/157
   -->
  <xsl:template
    match="gmd:country/gco:CharacterString[text()='Canada' and $mainLanguage='fra']/text()|
           gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[text()='Canada' and @locale=concat('#', $altLanguageId) and $altLanguage='fra']/text()"
    priority="10">
      <xsl:text>Canada (le)</xsl:text>
  </xsl:template>

  <xsl:template
    match="gmd:CI_Address/gmd:country[gco:CharacterString[text()='Canada'] and not(gmd:PT_FreeText) and ($mainLanguage='fra' or $mainLanguage='eng')]"
    priority="10">
      <xsl:copy>
        <xsl:attribute name="xsi:type">gmd:PT_FreeText_PropertyType</xsl:attribute>
        <xsl:apply-templates select="node()|@*"/>
        <gmd:PT_FreeText>
            <gmd:textGroup>
              <gmd:LocalisedCharacterString>
                <xsl:attribute name="locale">
                  <xsl:value-of select="concat('#', $altLanguageId)" />
                </xsl:attribute>						
                <xsl:choose>
                  <xsl:when test="$mainLanguage='eng'">
                    <xsl:text>Canada (le)</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>Canada</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </gmd:LocalisedCharacterString>
            </gmd:textGroup>
        </gmd:PT_FreeText>
      </xsl:copy>
  </xsl:template>

  <!-- FGP fix issue where some of the data does not have the correct gmd:metadataStandardName
       gco:CharacterString incorrect
       As it is FGP, it is supposed to have the correct HNAP values so this will correct them -->
  <xsl:template
    match="gmd:metadataStandardName/gco:CharacterString[text()!=$metadataStandardNameEng and text()!=$metadataStandardNameFre]"
    priority="10">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="$mainLanguage='fra'">
          <xsl:value-of select="$metadataStandardNameFre"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$metadataStandardNameEng"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <!-- FGP fix issue in gmd:administrativeArea where gco:CharacterString has no text but gmd:PT_FreeText has.  -->
  <xsl:template
    match="gmd:administrativeArea[not(gco:CharacterString/text()) and gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString/text()]/gco:CharacterString"
    priority="10">
    <xsl:copy>
        <xsl:value-of select="../gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString/text()"/>
    </xsl:copy>
  </xsl:template> 

  <!-- FGP fix issue in gmd:administrativeArea where gmd:PT_FreeText has incorrect provincial name of Québec in English.  -->
  <xsl:template
    match="gmd:administrativeArea/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[text()='Québec' and @locale='#eng']/text()"
    priority="10">
        <xsl:text>Quebec</xsl:text>
  </xsl:template>
  
  <!--Add gmd:administrativeArea LocalisedCharacterString if not exists. Special case for Québec in French and Quebec in English -->
  <xsl:template match="gmd:administrativeArea[gco:CharacterString/text()  and not(gmd:PT_FreeText)]"
    priority="10">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="node()|@*"/>
        <gmd:PT_FreeText>
          <gmd:textGroup>
            <xsl:choose>
              <xsl:when test="$mainLanguage='eng'">
                <gmd:LocalisedCharacterString locale="#fra">
                   <xsl:choose>
                      <xsl:when test="./gco:CharacterString/text() = 'Quebec'">
                         <xsl:value-of select="'Québec'"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="./gco:CharacterString/text()"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </gmd:LocalisedCharacterString>
              </xsl:when>
              <xsl:otherwise>
                <gmd:LocalisedCharacterString locale="#eng">
                   <xsl:choose>
                      <xsl:when test="./gco:CharacterString/text() = 'Québec'">
                         <xsl:value-of select="'Quebec'"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="./gco:CharacterString/text()"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </gmd:LocalisedCharacterString>
              </xsl:otherwise>
            </xsl:choose>
          </gmd:textGroup>
        </gmd:PT_FreeText>
    </xsl:copy>
  </xsl:template>

  <!-- ISO19139 are compatible with HNAP however for to import to process then records as HNAP we need to ensure that the metadataStandardName is set correctly -->

  <!-- FGP fix issue where some of the data does not have the correct gmd:metadataStandardName
       gmd:LocalisedCharacterString incorrect
       As it is FGP, it is supposed to have the correct HNAP values so this will correct them -->
  <xsl:template
    match="gmd:metadataStandardName/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[text()!=$metadataStandardNameEng and text()!=$metadataStandardNameFre]"
    priority="10">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="$mainLanguage!='fra'">
          <xsl:value-of select="$metadataStandardNameFre"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$metadataStandardNameEng"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <!-- FGP fix issue where some of the data does not have the correct gmd:metadataStandardVersion
     As it is FGP, it is supposed to have the correct HNAP values so this will correct them -->
  <xsl:template match="gmd:metadataStandardVersion/gco:CharacterString[text()!=$metadataStandardVersion]"
                priority="10">
    <xsl:copy>
      <xsl:value-of select="$metadataStandardVersion"/>
    </xsl:copy>
  </xsl:template>

  <!--Add default unclassified as security constraint if missing from metadata xml-->
  <xsl:template match="gmd:MD_DataIdentification">
    <xsl:copy copy-namespaces="no">
      <xsl:if test="not(gmd:resourceConstraints/gmd:MD_SecurityConstraints/gmd:classification/gmd:MD_ClassificationCode)">
        <gmd:resourceConstraints>
          <gmd:MD_SecurityConstraints>
            <gmd:classification>
              <gmd:MD_ClassificationCode codeList="https://schemas.metadata.geo.ca/register/napMetadataRegister.xml#IC_96"
                                         codeListValue="RI_484">unclassified; nonClassifié</gmd:MD_ClassificationCode>
            </gmd:classification>
          </gmd:MD_SecurityConstraints>
        </gmd:resourceConstraints>
      </xsl:if>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <!--Add default LocalisedCharacterString to thumbnail -->
  <xsl:template match="gmd:fileDescription[gco:CharacterString/text() != ''  and not(gmd:PT_FreeText)]">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="node()|@*"/>
        <gmd:PT_FreeText>
          <gmd:textGroup>
            <xsl:choose>
              <xsl:when test="$mainLanguage='eng'">
                <gmd:LocalisedCharacterString locale="#fra">
                  <xsl:value-of select="./gco:CharacterString/text()"/>
                </gmd:LocalisedCharacterString>
              </xsl:when>
              <xsl:otherwise>
                <gmd:LocalisedCharacterString locale="#eng">
                  <xsl:value-of select="./gco:CharacterString/text()"/>
                </gmd:LocalisedCharacterString>
              </xsl:otherwise>
            </xsl:choose>
          </gmd:textGroup>
        </gmd:PT_FreeText>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
