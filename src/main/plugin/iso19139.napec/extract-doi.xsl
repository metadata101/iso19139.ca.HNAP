<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                  xmlns:gco="http://www.isotc211.org/2005/gco"
                  xmlns:gmd="http://www.isotc211.org/2005/gmd">

  <xsl:param name="language" />

  <xsl:template match="gmd:MD_Metadata">
    <resource xsi:schemaLocation="http://datacite.org/schema/kernel-3 http://schema.datacite.org/meta/kernel-3/metadata.xsd" xmlns="http://datacite.org/schema/kernel-3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <identifier identifierType="DOI"><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString" /></identifier>
      <creators>
        <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty">
          <creator>
            <creatorName><xsl:value-of select="gmd:individualName/gco:CharacterString" /></creatorName>
          </creator>
        </xsl:for-each>
      </creators>

      <titles>
        <title><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString" /></title>
      </titles>

      <xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty">
        <publisher><xsl:value-of select="gmd:individualName/gco:CharacterString" /></publisher>
      </xsl:for-each>

      <publicationYear><xsl:value-of select="substring(gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='RI_367']/gmd:date/*, 1, 4)" /></publicationYear>
      
      <subjects>
        <xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword">
          <subject><xsl:value-of select="gco:CharacterString" /></subject>
        </xsl:for-each>
      </subjects>

      <language>eng</language>

      <resourceType resourceTypeGeneral="Dataset">Dataset</resourceType>
      <version>1</version>

      <rightsList>
        <xsl:for-each select="gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation">
          <rights><xsl:value-of select="gco:CharacterString" /></rights>
        </xsl:for-each>
      </rightsList>

      <descriptions>
        <description descriptionType="Abstract">
          <xsl:value-of select="gmd:identificationInfo/*/gmd:abstract/gco:CharacterString" />
        </description>
      </descriptions>

      <geoLocations>
        <xsl:for-each select="//gmd:extent//gmd:EX_GeographicBoundingBox">
          <xsl:variable name="minx" select="gmd:westBoundLongitude/gco:Decimal"/>
          <xsl:variable name="miny" select="gmd:southBoundLatitude/gco:Decimal"/>
          <xsl:variable name="maxx" select="gmd:eastBoundLongitude/gco:Decimal"/>
          <xsl:variable name="maxy" select="gmd:northBoundLatitude/gco:Decimal"/>
          <xsl:variable name="hasGeometry" select="($minx!='' and $miny!='' and $maxx!='' and $maxy!='' and (number($maxx)+number($minx)+number($maxy)+number($miny))!=0)"/>

          <xsl:if test="$hasGeometry">
            <xsl:variable name="geom" select="concat($minx, ' ', $miny,' ',$maxx,' ',$maxx)"/>
            <geoLocation>
              <geoLocationBox> <xsl:value-of select="$geom" /></geoLocationBox>
            </geoLocation>
          </xsl:if>
        </xsl:for-each>

      </geoLocations>
    </resource>
  </xsl:template>

</xsl:stylesheet>
