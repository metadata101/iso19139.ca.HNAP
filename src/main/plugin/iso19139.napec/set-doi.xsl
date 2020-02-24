<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                  xmlns:gco="http://www.isotc211.org/2005/gco"
                  xmlns:gmd="http://www.isotc211.org/2005/gmd"
                  exclude-result-prefixes="gmd">

  <!-- ================================================================= -->

  <xsl:template match="/root">
    <xsl:apply-templates select="*[name() != 'env']"/>
  </xsl:template>

  <!-- ================================================================= -->

  <xsl:template match="gmd:citation[name(parent::node()) = 'napec:MD_DataIdentification']">
    <xsl:copy>
      <xsl:copy-of select="@*"/>

      <gmd:CI_Citation>
        <xsl:apply-templates select="gmd:CI_Citation/gmd:title"/>
        <xsl:apply-templates select="gmd:CI_Citation/gmd:alternateTitle"/>
        <xsl:apply-templates select="gmd:CI_Citation/gmd:date"/>
        <xsl:apply-templates select="gmd:CI_Citation/gmd:edition"/>
        <xsl:apply-templates select="gmd:CI_Citation/gmd:editionDate"/>

        <xsl:apply-templates select="gmd:CI_Citation/gmd:identifier"/>

        <!-- gmd:identifier for DOI -->
        <!-- TODO: Check to update it -->
        <gmd:identifier>
          <gmd:MD_Identifier>
            <gmd:code>
              <gco:CharacterString><xsl:value-of select="/root/env/doi"/></gco:CharacterString>
            </gmd:code>
          </gmd:MD_Identifier>
        </gmd:identifier>

        <xsl:apply-templates select="gmd:CI_Citation/gmd:citedResponsibleParty"/>
        <xsl:apply-templates select="gmd:CI_Citation/gmd:presentationForm"/>
        <xsl:apply-templates select="gmd:CI_Citation/gmd:series"/>
        <xsl:apply-templates select="gmd:CI_Citation/gmd:editionDate"/>
        <xsl:apply-templates select="gmd:CI_Citation/gmd:otherCitationDetails"/>
        <xsl:apply-templates select="gmd:CI_Citation/gmd:collectiveTitle"/>
        <xsl:apply-templates select="gmd:CI_Citation/gmd:ISBN"/>
        <xsl:apply-templates select="gmd:CI_Citation/gmd:ISSN"/>
      </gmd:CI_Citation>

    </xsl:copy>
  </xsl:template>

  <!-- ================================================================= -->

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================= -->

</xsl:stylesheet>