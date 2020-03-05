<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                  xmlns:gco="http://www.isotc211.org/2005/gco"
                  xmlns:srv="http://www.isotc211.org/2005/srv"
                  xmlns:gmd="http://www.isotc211.org/2005/gmd">

  <xsl:template match="gmd:MD_Metadata">
    <links>
      <xsl:for-each select="gmd:contact/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource">
        <xsl:if test="string(gmd:CI_OnlineResource/gmd:linkage/gmd:URL)">
          <link type="metadata-contact"><xsl:value-of select="gmd:CI_OnlineResource/gmd:linkage/gmd:URL" /></link>
        </xsl:if>
      </xsl:for-each>

      <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource">
        <xsl:if test="string(gmd:CI_OnlineResource/gmd:linkage/gmd:URL)">
          <link type="cited-responsible-party"><xsl:value-of select="gmd:CI_OnlineResource/gmd:linkage/gmd:URL" /></link>
        </xsl:if>
      </xsl:for-each>

      <xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource">
        <xsl:if test="string(gmd:CI_OnlineResource/gmd:linkage/gmd:URL)">
          <link type="distributor-contact"><xsl:value-of select="gmd:CI_OnlineResource/gmd:linkage/gmd:URL" /></link>
        </xsl:if>
      </xsl:for-each>

      <xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine">
        <xsl:if test="string(gmd:CI_OnlineResource/gmd:linkage/gmd:URL)">
          <link type="online-resource"><xsl:value-of select="gmd:CI_OnlineResource/gmd:linkage/gmd:URL" /></link>
        </xsl:if>
      </xsl:for-each>
    </links>
  </xsl:template>

</xsl:stylesheet>
