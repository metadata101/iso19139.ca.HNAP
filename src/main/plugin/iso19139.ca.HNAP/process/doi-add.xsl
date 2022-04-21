<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                  xmlns:gco="http://www.isotc211.org/2005/gco"
                  xmlns:gmd="http://www.isotc211.org/2005/gmd"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  xmlns:geonet="http://www.fao.org/geonetwork"
                  exclude-result-prefixes="#all">

  <xsl:import href="../../iso19139/process/doi-add.xsl"/>

  <xsl:variable name="mainLang">
    <xsl:value-of
      select="(gmd:MD_Metadata|*[@gco:isoType='gmd:MD_Metadata'])/gmd:language/gco:CharacterString"/>
  </xsl:variable>

  <xsl:variable name="altLang">
   <xsl:choose>
     <xsl:when test="starts-with($mainLang, 'eng')">fra</xsl:when>
     <xsl:otherwise>eng</xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <xsl:template match="gmd:distributionInfo[not($isDoiAlreadySet) and position() = 1]"
                priority="20">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <gmd:MD_Distribution>
        <xsl:apply-templates select="*/@*"/>
        <xsl:apply-templates select="*/gmd:distributionFormat"/>
        <xsl:apply-templates select="*/gmd:distributor"/>
        <xsl:apply-templates select="*/gmd:transferOptions"/>
        <gmd:transferOptions>
          <gmd:MD_DigitalTransferOptions>
            <gmd:onLine>
              <gmd:CI_OnlineResource>
                <gmd:linkage>
                  <gmd:URL><xsl:value-of select="concat($doiProxy, $doi)"/></gmd:URL>
                </gmd:linkage>
                <gmd:protocol>
                  <gco:CharacterString><xsl:value-of select="$doiProtocol"/></gco:CharacterString>
                </gmd:protocol>
                <gmd:name>
                  <gco:CharacterString><xsl:value-of select="$doiName"/></gco:CharacterString>
                  <gmd:PT_FreeText>
                    <gmd:textGroup>
                      <gmd:LocalisedCharacterString locale="{concat('#', $altLang)}">
                        <xsl:value-of select="$doiName"/>
                      </gmd:LocalisedCharacterString>
                    </gmd:textGroup>
                  </gmd:PT_FreeText>
                </gmd:name>

                <gmd:description xsi:type="gmd:PT_FreeText_PropertyType">
                  <xsl:choose>
                    <xsl:when test="$altLang = 'fra'">
                      <gco:CharacterString>Web Service;XML;eng,fra</gco:CharacterString>
                      <gmd:PT_FreeText>
                        <gmd:textGroup>
                          <gmd:LocalisedCharacterString locale="{concat('#', $altLang)}">Service Web;XML;eng,fra</gmd:LocalisedCharacterString>
                        </gmd:textGroup>
                      </gmd:PT_FreeText>
                    </xsl:when>
                    <xsl:otherwise>
                      <gco:CharacterString>Service Web;XML;eng,fra</gco:CharacterString>
                      <gmd:PT_FreeText>
                        <gmd:textGroup>
                          <gmd:LocalisedCharacterString locale="{concat('#', $altLang)}">Web Service;XML;eng,fra</gmd:LocalisedCharacterString>
                        </gmd:textGroup>
                      </gmd:PT_FreeText>
                    </xsl:otherwise>
                  </xsl:choose>
                </gmd:description>
              </gmd:CI_OnlineResource>
            </gmd:onLine>
          </gmd:MD_DigitalTransferOptions>
        </gmd:transferOptions>
      </gmd:MD_Distribution>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
