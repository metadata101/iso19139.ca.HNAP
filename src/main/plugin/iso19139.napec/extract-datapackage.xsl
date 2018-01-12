<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                  xmlns:gco="http://www.isotc211.org/2005/gco"
                  xmlns:gmd="http://www.isotc211.org/2005/gmd">

    <xsl:param name="language" />

    <xsl:template match="gmd:MD_Metadata">
      <datapackage>
        <uuid><xsl:value-of select="gmd:fileIdentifier/gco:CharacterString"/></uuid>

        <xsl:choose>
          <xsl:when test="starts-with(gmd:language/gco:CharacterString, 'eng')">
            <title_eng><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString"/></title_eng>
            <title_fre><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']"/></title_fre>
            <description_eng><xsl:value-of select="gmd:identificationInfo/*/gmd:abstract/gco:CharacterString"/></description_eng>
            <description_fre><xsl:value-of select="gmd:identificationInfo/*/gmd:abstract/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']"/></description_fre>
          </xsl:when>
          <xsl:otherwise>
            <title_eng><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng']"/></title_eng>
            <title_fre><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString"/></title_fre>
            <description_fre><xsl:value-of select="gmd:identificationInfo/*/gmd:abstract/gco:CharacterString"/></description_fre>
            <description_eng><xsl:value-of select="gmd:identificationInfo/*/gmd:abstract/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng']"/></description_eng>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:for-each select="//gmd:extent//gmd:EX_GeographicBoundingBox">
          <xsl:variable name="minx" select="gmd:westBoundLongitude/gco:Decimal"/>
          <xsl:variable name="miny" select="gmd:southBoundLatitude/gco:Decimal"/>
          <xsl:variable name="maxx" select="gmd:eastBoundLongitude/gco:Decimal"/>
          <xsl:variable name="maxy" select="gmd:northBoundLatitude/gco:Decimal"/>
          <xsl:variable name="hasGeometry" select="($minx!='' and $miny!='' and $maxx!='' and $maxy!='' and (number($maxx)+number($minx)+number($maxy)+number($miny))!=0)"/>
          <xsl:variable name="geom" select="concat('POLYGON((', $minx, ' ', $miny,',',$maxx,' ',$miny,',',$maxx,' ',$maxy,',',$minx,' ',$maxy,',',$minx,' ',$miny, '))')"/>

          <xsl:if test="$hasGeometry">
            <bbox><xsl:value-of select="concat( $minx, ',', $miny,',',$maxx,',',$maxy)"/></bbox>
            <!--<bbox><xsl:value-of select="$geom"/></bbox>-->
          </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:graphicOverview/gmd:MD_BrowseGraphic
				|gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:graphicOverview/gmd:MD_BrowseGraphic
				|gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:graphicOverview/gmd:MD_BrowseGraphic
				">
          <xsl:choose>
            <xsl:when test="gmd:fileDescription/gco:CharacterString = 'large_thumbnail' and gmd:fileName/gco:CharacterString != ''">
              <thumbnail>
                <xsl:value-of select="gmd:fileName/gco:CharacterString" />
              </thumbnail>
            </xsl:when>
            <xsl:when test="gmd:fileDescription/gco:CharacterString = 'thumbnail' and gmd:fileName/gco:CharacterString != ''">
              <thumbnail>
                <xsl:value-of select="gmd:fileName/gco:CharacterString" />
              </thumbnail>
            </xsl:when>
            <xsl:when test="gmd:fileDescription/gco:CharacterString = 'large_thumbnail_fre' and gmd:fileName/gco:CharacterString != ''">
              <thumbnail_fre>
                <xsl:value-of select="gmd:fileName/gco:CharacterString" />
              </thumbnail_fre>
            </xsl:when>
            <xsl:when test="gmd:fileDescription/gco:CharacterString = 'thumbnail_fre' and gmd:fileName/gco:CharacterString != ''">
              <thumbnail_fre>
                <xsl:value-of select="gmd:fileName/gco:CharacterString" />
              </thumbnail_fre>
            </xsl:when>
            <xsl:otherwise>
              <thumbnail>
                <xsl:value-of select="gmd:fileName/gco:CharacterString" />
              </thumbnail>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>

        <keywords><xsl:for-each select="//gmd:MD_Keywords"><xsl:value-of select="gmd:keyword/gco:CharacterString" />,</xsl:for-each></keywords>

        <resources>
          <xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine">
            <resource>
              <url><xsl:value-of select="gmd:CI_OnlineResource/gmd:linkage/gmd:URL" /></url>
              <name><xsl:value-of select="gmd:CI_OnlineResource/gmd:name/gco:CharacterString" /></name>
              <protocol><xsl:value-of select="gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString" /></protocol>
            </resource>
          </xsl:for-each>
        </resources>
      </datapackage>
    </xsl:template>

</xsl:stylesheet>
