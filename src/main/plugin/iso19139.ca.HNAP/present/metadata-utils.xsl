<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:java="java:org.fao.geonet.util.XslUtil"
                version="2.0"
                exclude-result-prefixes="#all">

  <!-- Template used to return a gco:CharacterString element
    in default metadata language or in a specific locale
    if exist.
    FIXME : gmd:PT_FreeText should not be in the match clause as gco:CharacterString
    is mandatory and PT_FreeText optional. Added for testing GM03 import.
-->
  <xsl:template name="localised" mode="localised" match="*[gco:CharacterString or gmd:PT_FreeText]">
    <xsl:param name="langId"/>

    <!-- if by accident the lang is provided without # -->
    <xsl:variable name="langcode">
      <xsl:choose>
        <xsl:when test="starts-with($langId,'#')"><xsl:value-of select="$langId" /></xsl:when>
        <xsl:otherwise>#<xsl:value-of select="$langId" /></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when
        test="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=$langcode] and
                gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=$langcode] != ''">
        <xsl:value-of
          select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=$langcode]"
        />
      </xsl:when>
      <xsl:when test="(not(gco:CharacterString) or not(string(gco:CharacterString))) and not(gmx:MimeFileType)">
        <!-- If no CharacterString, try to use the first textGroup available -->
        <xsl:value-of
          select="gmd:PT_FreeText/gmd:textGroup[position()=1]/gmd:LocalisedCharacterString"
        />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="gco:CharacterString|gmx:MimeFileType"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- Template used to match any other element eg. gco:Boolean, gco:Date
       when looking for localised strings -->
  <xsl:template mode="localised" match="*[not(gco:CharacterString or gmd:PT_FreeText)]">
    <xsl:param name="langId"/>
    <xsl:value-of select="*[1]"/>
  </xsl:template>

  <!-- Map GUI language to iso3code -->
  <xsl:template name="getLangId">
    <xsl:param name="langGui"/>
    <xsl:param name="md"/>

    <xsl:variable name="langMd">
      <xsl:call-template name="getLangForMetadata">
        <xsl:with-param name="uiLang" select="$langGui" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:call-template name="getLangIdFromMetadata">
      <xsl:with-param name="lang" select="$langMd"/>
      <xsl:with-param name="md" select="$md"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Gets the metadata lang using the URL lang: french changes from fre(UI) to fra(metadata) -->
  <xsl:template name="getLangForMetadata">
    <xsl:param name="uiLang" />

    <xsl:choose>
      <xsl:when test="$uiLang = 'fre'">fra</xsl:when>
      <xsl:otherwise><xsl:value-of select="$uiLang" /></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Get lang #id in metadata PT_Locale section,  deprecated: if not return the 2 first letters
      of the lang iso3code in uper case.

       if not return the lang iso3code in uper case.
      -->
  <xsl:template name="getLangIdFromMetadata">
    <xsl:param name="md"/>
    <xsl:param name="lang"/>

    <xsl:choose>
      <xsl:when
        test="$md/gmd:locale/gmd:PT_Locale[gmd:languageCode/gmd:LanguageCode/@codeListValue = $lang]/@id"
      >#<xsl:value-of
        select="$md/gmd:locale/gmd:PT_Locale[gmd:languageCode/gmd:LanguageCode/@codeListValue = $lang]/@id"
      />
      </xsl:when>
      <xsl:otherwise>#<xsl:value-of select="$lang"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Get lang codeListValue in metadata PT_Locale section,  if not return eng by default -->
  <xsl:template name="getLangCode">
    <xsl:param name="md"/>
    <xsl:param name="langId"/>

    <xsl:choose>
      <xsl:when
        test="$md/gmd:locale/gmd:PT_Locale[@id=$langId]/gmd:languageCode/gmd:LanguageCode/@codeListValue"
      ><xsl:value-of
        select="$md/gmd:locale/gmd:PT_Locale[@id=$langId]/gmd:languageCode/gmd:LanguageCode/@codeListValue"
      /></xsl:when>
      <xsl:otherwise>eng</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Template to get metadata title using its uuid.
      Title is loaded from current language index if available.
      If not, default title is returned.
      If failed, return uuid. -->
  <xsl:template name="getMetadataTitle">
    <xsl:param name="uuid"/>
    <xsl:variable name="metadataTitle" select="java:getIndexField(string(substring(/root/gui/url, 2)), string($uuid), 'title', string(/root/gui/language))"/>
    <xsl:choose>
      <xsl:when test="$metadataTitle=''">
        <xsl:variable name="metadataDefaultTitle" select="java:getIndexField(string(substring(/root/gui/url, 2)), string($uuid), '_defaultTitle', string(/root/gui/language))"/>
        <xsl:choose>
          <xsl:when test="$metadataDefaultTitle=''">
            <xsl:value-of select="$uuid"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$metadataDefaultTitle"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$metadataTitle"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template mode="getMetadataTitle" match="uuid">

    <xsl:variable name="metadataTitle" select="java:getIndexField(string(substring(/root/gui/url, 2)), string(.), 'title', string(/root/gui/language))"/>

    <xsl:choose>
      <xsl:when test="$metadataTitle=''">
        <xsl:variable name="metadataDefaultTitle" select="java:getIndexField(string(substring(/root/gui/url, 2)), string(.), '_defaultTitle', string(/root/gui/language))"/>
        <xsl:choose>
          <xsl:when test="$metadataDefaultTitle=''">
            <xsl:value-of select="."/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$metadataDefaultTitle"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$metadataTitle"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>



  <!-- Display related metadata records. Related resource are only iso19139/119 or iso19110 metadate records for now.

        Related resources are:
        * parent metadata record (if gmd:parentIdentifier is set)
        * services (dataset only)
        * datasets (service only)
        * feature catalogues (dataset only)

        In view mode link to related resources are displayed
        In edit mode link to add elements are provided.
    -->



  <xsl:template mode="iso19139IsEmpty" match="*|@*|text()">
    <xsl:choose>
      <!-- normal element -->
      <xsl:when test="*">
        <xsl:apply-templates mode="iso19139IsEmpty"/>
      </xsl:when>
      <!-- text element -->
      <xsl:when test="text()!=''">txt</xsl:when>
      <!-- empty element -->
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>

    <!-- attributes? -->
    <xsl:for-each select="@*">
      <xsl:if test="string-length(.)!=0">att</xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- Create a service URL for a service metadata record. -->
  <xsl:template name="getServiceURL">
    <xsl:param name="metadata"/>

    <!-- Get Service URL from GetCapabilities Operation, if null from distribution information-->
    <xsl:variable name="serviceUrl">
      <xsl:value-of select="$metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations/srv:SV_OperationMetadata[srv:operationName/gco:CharacterString='GetCapabilities']/srv:connectPoint/gmd:CI_OnlineResource/gmd:linkage/gmd:URL|
				$metadata/gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/srv:containsOperations/srv:SV_OperationMetadata[srv:operationName/gco:CharacterString='GetCapabilities']/srv:connectPoint/gmd:CI_OnlineResource/gmd:linkage/gmd:URL"/>
    </xsl:variable>

    <!-- TODO : here we could use service type and version if
            GetCapabilities url is not complete with parameter. -->
    <xsl:variable name="parameters">&amp;SERVICE=WMS&amp;VERSION=1.1.1&amp;REQUEST=GetCapabilities</xsl:variable>

    <xsl:choose>
      <xsl:when test="$serviceUrl=''">
        <!-- Search for URLs related to an OGC protocol in distribution section -->
        <xsl:variable name="urlFilter">OGC:WMS</xsl:variable>
        <xsl:variable name="distributionInfoUrl" select="$metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[contains(gmd:protocol[1]/gco:CharacterString, $urlFilter)]/gmd:linkage/gmd:URL"/>
        <xsl:value-of select="$distributionInfoUrl"/>
        <!-- FIXME ? Here we assume that only one URL is related to an OGC protocol which could not be the case in all situation.
                This service URL is used to initialize the LinkedServiceMetadataPanel to search for layers. It should be the case in most
                of service metadata records, but it could be different for metadata records referencing more than one OGC service. -->
        <xsl:if test="not(contains($distributionInfoUrl[position()=1], '?'))">
          <xsl:text>?</xsl:text>
        </xsl:if>
        <xsl:value-of select="$parameters"/>
      </xsl:when>
      <xsl:when test="not(contains($serviceUrl, '?'))">
        <xsl:value-of select="$serviceUrl"/>?<xsl:value-of select="$parameters"/>
      </xsl:when>
      <xsl:when test="not(contains($serviceUrl, 'GetCapabilities'))">
        <xsl:value-of select="$serviceUrl"/><xsl:value-of select="$parameters"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$serviceUrl"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="toIso2LangCode">
    <xsl:param name="iso3code" />

    <xsl:choose>
      <xsl:when test="$iso3code = 'fre'">fr</xsl:when>
      <xsl:otherwise>en</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
