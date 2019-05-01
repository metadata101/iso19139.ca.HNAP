<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                  xmlns:geonet="http://www.fao.org/geonetwork"
                  xmlns:gmd="http://www.isotc211.org/2005/gmd"
                  xmlns:gco="http://www.isotc211.org/2005/gco"
                  xmlns:xlink="http://www.w3.org/1999/xlink"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  xmlns:napm="http://www.geconnections.org/nap/napMetadataTools/napXsd/napm"
                  xmlns:gml="http://www.opengis.net/gml/3.2"
                  xmlns:gmx="http://www.isotc211.org/2005/gmx"
                  xmlns:exslt="http://exslt.org/common"
                  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                  xmlns:ns2="http://www.w3.org/2004/02/skos/core#"
                  exclude-result-prefixes="gmd gmx gco xlink geonet xsi napm gml exslt rdf ns2">

  <xsl:param name="thesaurusDir" />

  <xsl:template match="gmd:MD_Metadata">

    <xsl:variable name="formats-list" select="document(concat('file:///', $thesaurusDir, '/local/thesauri/theme/EC_Resource_Formats.rdf'))"/>

    <results>
      <xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine">
        <result>
          <xsl:variable name="description" select="gmd:CI_OnlineResource/gmd:description/gco:CharacterString" />
          <xsl:variable name="contentType" select="tokenize($description, ';')[1]" />
          <xsl:variable name="format" select="tokenize($description, ';')[2]" />
          <xsl:variable name="language" select="tokenize($description, ';')[3]" />

          <!--<xsl:variable name="language_present" select="geonet:values-in($language,
              ('eng', 'fra', 'spa', 'zxx'))"/>-->

          <xsl:variable name="descriptionTranslated" select="gmd:CI_OnlineResource/gmd:description/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString" />
          <xsl:variable name="contentTypeTranslated" select="tokenize($descriptionTranslated, ';')[1]" />
          <xsl:variable name="languageTraslated" select="tokenize($descriptionTranslated, ';')[3]" />

          <!--<xsl:variable name="languageTranslated_present" value="geonet:values-in($language,
              ('eng', 'fra', 'spa', 'zxx'))"/>-->

          <xsl:variable name="contentTypeStatus">
          <xsl:choose>
            <xsl:when test="($contentType = 'Web Service' or $contentType = 'Service Web' or
                        $contentType = 'Dataset' or $contentType = 'Données' or
                        $contentType = 'API' or $contentType = 'Application' or
                        $contentType='Supporting Document' or $contentType = 'Document de soutien') and
                        ($contentTypeTranslated = 'Web Service' or $contentTypeTranslated = 'Service Web' or
                        $contentTypeTranslated = 'Dataset' or $contentTypeTranslated = 'Données' or
                        $contentTypeTranslated = 'API' or $contentTypeTranslated = 'Application' or
                        $contentTypeTranslated='Supporting Document' or $contentTypeTranslated = 'Document de soutien')">
              true <!--<contentType>true</contentType>-->
            </xsl:when>
            <xsl:otherwise>
              false <!--<contentType value="{$contentType}" valueTranslated="{$contentTypeTranslated}">false</contentType>-->
            </xsl:otherwise>
          </xsl:choose>
          </xsl:variable>

          <xsl:variable name="formatTranslated" select="tokenize($descriptionTranslated, ';')[2]" />

          <xsl:variable name="formatStatus">
          <xsl:choose>
            <xsl:when test="string($formats-list//rdf:Description[@rdf:about = concat('http://geonetwork-opensource.org/EC/resourceformat#', $format)]) and
                          string($formats-list//rdf:Description[@rdf:about = concat('http://geonetwork-opensource.org/EC/resourceformat#',$formatTranslated)])">
              true <!--<format>true</format>-->
            </xsl:when>
            <xsl:otherwise>
              false <!--<format value="{$format}" valueTranslated="{$formatTranslated}">false</format>-->
            </xsl:otherwise>
          </xsl:choose>
          </xsl:variable>

          <xsl:variable name="languageStatus">
          <xsl:choose>
            <xsl:when test="normalize-space($language) != '' and normalize-space($languageTraslated) != ''">
              true <!-- <language>true</language>-->
            </xsl:when>
            <xsl:otherwise>
              false <!-- <language value="{$language}" valueTranslated="{$languageTraslated}">false</language>-->
            </xsl:otherwise>
          </xsl:choose>
          </xsl:variable>

          <xsl:attribute name="error">
            <xsl:choose>
              <xsl:when test="normalize-space($contentTypeStatus) = 'true' and normalize-space($formatStatus) = 'true' and normalize-space($languageStatus) = 'true'">false</xsl:when>
              <xsl:otherwise>true</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <!--$language_present and $languageTranslated_present-->
        </result>
      </xsl:for-each>
    </results>
  </xsl:template>
</xsl:stylesheet>
