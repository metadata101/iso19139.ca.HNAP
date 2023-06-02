<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
						xmlns:gco="http://www.isotc211.org/2005/gco"
                        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns:xlink='http://www.w3.org/1999/xlink'
						xmlns:gmd="http://www.isotc211.org/2005/gmd" exclude-result-prefixes="gmd">

	<xsl:variable name="lang"><xsl:value-of select="/root/env/lang"/></xsl:variable>
  <xsl:variable name="template"><xsl:value-of select="/root/env/template"/></xsl:variable>

  <!-- ================================================================= -->

	<xsl:template match="/root">
		 <xsl:apply-templates select="gmd:MD_Metadata"/>
	</xsl:template>

	<!-- ================================================================= -->

	<xsl:template match="gmd:MD_Metadata/gmd:language">
		<xsl:choose>
			<xsl:when test="$lang = 'fre'">
				<gmd:language>
					<gco:CharacterString>fra; CAN</gco:CharacterString>
				</gmd:language>

			</xsl:when>
			<xsl:otherwise>
				<gmd:language>
					<gco:CharacterString>eng; CAN</gco:CharacterString>
				</gmd:language>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


  <xsl:template match="gmd:MD_Metadata/gmd:locale/gmd:PT_Locale">
    <xsl:choose>
      <xsl:when test="$lang = 'fre'">
        <gmd:PT_Locale id="eng">
          <gmd:languageCode>
            <gmd:LanguageCode codeList="https://schemas.metadata.geo.ca/register/napMetadataRegister.xml#IC_116" codeListValue="eng">English; Anglais</gmd:LanguageCode>
          </gmd:languageCode>
          <gmd:country>
            <gmd:Country codeList="https://schemas.metadata.geo.ca/register/napMetadataRegister.xml#IC_117" codeListValue="CAN">Canada; Canada</gmd:Country>
          </gmd:country>
          <gmd:characterEncoding>
            <gmd:MD_CharacterSetCode codeList="https://schemas.metadata.geo.ca/register/napMetadataRegister.xml#IC_95" codeListValue="RI_458">utf8; utf8</gmd:MD_CharacterSetCode>
          </gmd:characterEncoding>
        </gmd:PT_Locale>
      </xsl:when>
      <xsl:otherwise>
        <gmd:PT_Locale id="fra">
          <gmd:languageCode>
            <gmd:LanguageCode codeList="https://schemas.metadata.geo.ca/register/napMetadataRegister.xml#IC_116" codeListValue="fra">French; Français</gmd:LanguageCode>
          </gmd:languageCode>
          <gmd:country>
            <gmd:Country codeList="https://schemas.metadata.geo.ca/register/napMetadataRegister.xml#IC_117" codeListValue="CAN">Canada; Canada</gmd:Country>
          </gmd:country>
          <gmd:characterEncoding>
            <gmd:MD_CharacterSetCode codeList="https://schemas.metadata.geo.ca/register/napMetadataRegister.xml#IC_95" codeListValue="RI_458">utf8; utf8</gmd:MD_CharacterSetCode>
          </gmd:characterEncoding>
        </gmd:PT_Locale>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

        <!--
         <gmd:title xsi:type="gmd:PT_FreeText_PropertyType">
                        <gco:CharacterString>Dataset Metadata - ISO 19115 NAP (Default)</gco:CharacterString>
                        <gmd:PT_FreeText>
                            <gmd:textGroup>
                                <gmd:LocalisedCharacterString locale="#fra">Dataset Metadata - ISO 19115 NAP (Default)</gmd:LocalisedCharacterString>
                            </gmd:textGroup>
                        </gmd:PT_FreeText>
                    </gmd:title>

                    -->

    <xsl:template match="*[@xsi:type='gmd:PT_FreeText_PropertyType']">

        <xsl:variable name="currentLang">
            <xsl:choose>
                <xsl:when test="//gmd:MD_Metadata/gmd:language/gco:CharacterString = 'eng; CAN'">eng</xsl:when>
                <xsl:otherwise>fre</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:copy>
            <xsl:copy-of select="@*"/>

            <xsl:choose>
                <xsl:when test="$lang = $currentLang">
                    <gco:CharacterString><xsl:value-of select="gco:CharacterString" /></gco:CharacterString>
                </xsl:when>

                <xsl:otherwise>
                    <xsl:choose>
                        <!-- main language is french -->
                        <xsl:when test="$lang = 'fre'">
                            <gco:CharacterString><xsl:value-of select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale = '#fra']" /></gco:CharacterString>
                        </xsl:when>
                        <!-- main language is english -->
                        <xsl:otherwise>
                            <gco:CharacterString><xsl:value-of select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale = '#eng']" /></gco:CharacterString>
                        </xsl:otherwise>
                    </xsl:choose>

                </xsl:otherwise>
            </xsl:choose>

            <xsl:apply-templates select="gmd:PT_FreeText"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="gmd:LocalisedCharacterString">
        <xsl:variable name="currentLang">
            <xsl:choose>
                <xsl:when test="//gmd:MD_Metadata/gmd:language/gco:CharacterString = 'eng; CAN'">eng</xsl:when>
                <xsl:otherwise>fre</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$lang = $currentLang">
                <xsl:copy-of select="." />
            </xsl:when>

            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$lang = 'fre'">
                        <xsl:choose>
                            <xsl:when test="@locale = '#eng'">
                                <gmd:LocalisedCharacterString locale="#eng"><xsl:value-of select="." /></gmd:LocalisedCharacterString>
                            </xsl:when>
                            <xsl:otherwise>
                                <gmd:LocalisedCharacterString locale="#eng"><xsl:value-of select="../../../gco:CharacterString" /></gmd:LocalisedCharacterString>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="@locale = '#fra'">
                                <gmd:LocalisedCharacterString locale="#fra"><xsl:value-of select="." /></gmd:LocalisedCharacterString>
                            </xsl:when>
                            <xsl:otherwise>
                                <gmd:LocalisedCharacterString locale="#fra"><xsl:value-of select="../../../gco:CharacterString" /></gmd:LocalisedCharacterString>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>

	</xsl:template>


  <xsl:template match="gmd:MD_Distribution">
    <xsl:copy>
      <xsl:copy-of select="@*" />

      <xsl:choose>
        <!-- Don't copy files uploaded if saved as a template -->
        <xsl:when test="$template = 'y'">

          <!-- Process the distribution formats to remove the ones related to file uploads -->
          <xsl:for-each select="gmd:distributionFormat">
            <xsl:variable name="formatId" select="@xlink:title" />

            <xsl:choose>
              <xsl:when test="string($formatId)">
                <!-- Check if the related resource is an uploaded file -->
                <xsl:variable name="relatedResProtocol" select="../gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role = 'urn:xml:lang:eng-CAN' and @xlink:title = $formatId]/gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString" />

                <xsl:choose>
                  <xsl:when test="starts-with($relatedResProtocol,'WWW:DOWNLOAD-') and contains($relatedResProtocol,'http--download')">
                    <!-- Ignore the resource -->

                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:copy>
                      <xsl:copy-of select="@*" />
                      <xsl:apply-templates select="gmd:MD_Format" />
                    </xsl:copy>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:copy>
                  <xsl:copy-of select="@*" />
                  <xsl:apply-templates select="gmd:MD_Format" />
                </xsl:copy>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>

          <xsl:apply-templates select="gmd:distributor"/>

          <xsl:apply-templates select="gmd:transferOptions" />


        </xsl:when>

        <xsl:otherwise>
          <xsl:apply-templates select="gmd:distributionFormat"/>
          <xsl:apply-templates select="gmd:distributor"/>
          <xsl:apply-templates select="gmd:transferOptions" />
        </xsl:otherwise>
      </xsl:choose>

    </xsl:copy>
  </xsl:template>

  <xsl:template match="gmd:onLine[starts-with(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString,'WWW:DOWNLOAD-') and contains(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString,'http--download')]">
    <xsl:choose>
      <!-- Don't copy files uploaded if saved as a template -->
      <xsl:when test="$template = 'y'">
        <!-- Ignore the resource -->

      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:copy-of select="@*" />
          <xsl:apply-templates select="node()" />
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ================================================================= -->

	<xsl:template match="@*|node()">
		 <xsl:copy>
			  <xsl:apply-templates select="@*|node()"/>
		 </xsl:copy>
	</xsl:template>

	<!-- ================================================================= -->

</xsl:stylesheet>
