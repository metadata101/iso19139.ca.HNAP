<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                  xmlns:geonet="http://www.fao.org/geonetwork"
                  xmlns:xs="http://www.w3.org/2001/XMLSchema"
                  xmlns:gmd="http://www.isotc211.org/2005/gmd"
                  xmlns:gco="http://www.isotc211.org/2005/gco"
                  xmlns:xlink="http://www.w3.org/1999/xlink"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  exclude-result-prefixes="gmd gco xlink geonet xs xsi">


  <!-- List of enpoints to add/update/remove
    <endPoints>
      <endPoint name="file1">WAF URL 1</endPoint>
      <endPoint name="file2">WAF URL 2</endPoint>
      <endPoint name="file2">WAF URL 3</endPoint>
      <endPoint name="file1">delete</endPoint>      :  End point to delete, used for zip packages that are deployed in WAF
                                                      (zip packages that are uploaded and doesn't correspond to a shapefile,
                                                      the online resource is removed and it's used the View Data Mart link)
    </endPoints>
  -->
  <xsl:param name="endPoints" />

  <xsl:variable name="localeForTranslations">
    <xsl:choose>
      <xsl:when test="/gmd:MD_Metadata/gmd:language/gco:CharacterString = 'eng; CAN'">#fra</xsl:when>
      <xsl:otherwise>#eng</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- ================================================================= -->

  <xsl:template match="gmd:MD_Metadata">
    <xsl:message>WAF update: <xsl:value-of select="$localeForTranslations" /></xsl:message>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================= -->
  <xsl:template match="gmd:distributionInfo/gmd:MD_Distribution">
    <xsl:copy>
      <xsl:copy-of select="@*" />

      <xsl:apply-templates select="gmd:distributionFormat" />
      <xsl:apply-templates select="gmd:distributor" />

      <xsl:for-each select="gmd:transferOptions">
        <xsl:copy>
          <xsl:copy-of select="@*" />

          <xsl:for-each select="gmd:MD_DigitalTransferOptions">
            <xsl:copy>
              <xsl:copy-of select="@*" />

              <xsl:apply-templates select="gmd:unitsOfDistribution" />
              <xsl:apply-templates select="gmd:transferSize" />

              <!-- Copy all gmd:onLine, except the ones that require update -->
              <xsl:for-each select="gmd:onLine">

                <xsl:variable name="protocol" select="gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString" />
                <xsl:variable name="name" select="gmd:CI_OnlineResource/gmd:name/gco:CharacterString" />
                <xsl:variable name="fnameInUrl" select="substring-after(gmd:CI_OnlineResource/gmd:linkage/gmd:URL, '/attachments/')" />

                <xsl:message>FNAME: <xsl:value-of select="$fnameInUrl" /></xsl:message>
                <xsl:message>protocol: <xsl:value-of select="$protocol" /></xsl:message>
                <xsl:message>check: <xsl:value-of select="$endPoints/endPoints/endPoint[@name = $fnameInUrl]" /></xsl:message>

                <xsl:choose>
                  <xsl:when test="$fnameInUrl = 'datapackage.json'">
                    <!-- Take the last one, the firsts are related to theme/subtheme -->
                    <!-- This case is for datapackage.json files added by the user to the metadata -->

                    <xsl:variable name="ep" select="$endPoints/endPoints/endPoint[@name = $fnameInUrl][count($endPoints/endPoints/endPoint[@name = $fnameInUrl])]" />
                    <xsl:copy>
                      <xsl:copy-of select="@*"/>

                      <gmd:CI_OnlineResource>
                        <gmd:linkage>
                          <gmd:URL><xsl:value-of select="$ep" /></gmd:URL>
                        </gmd:linkage>
                        <gmd:protocol>
                          <gco:CharacterString>WWW:LINK-1.0-http--link</gco:CharacterString>
                        </gmd:protocol>
                        <xsl:apply-templates select="gmd:CI_OnlineResource/gmd:name" />
                        <xsl:apply-templates select="gmd:CI_OnlineResource/gmd:description" />
                      </gmd:CI_OnlineResource>
                    </xsl:copy>
                  </xsl:when>

                  <xsl:when test="string($endPoints/endPoints/endPoint[@name = $fnameInUrl]) and $endPoints/endPoints/endPoint[@name = $fnameInUrl] = 'delete' and starts-with($protocol, 'WWW:DOWNLOAD')">
                    <!-- remove the link: related to a zip file deployed in the data mart -->
                  </xsl:when>

                  <!-- DOWNLOAD LINKS -->
                  <xsl:when test="string($endPoints/endPoints/endPoint[@name = $fnameInUrl]) and starts-with($protocol, 'WWW:DOWNLOAD')">
                    <xsl:variable name="ep" select="$endPoints/endPoints/endPoint[@name = $fnameInUrl]" />
                    <xsl:copy>
                      <xsl:copy-of select="@*"/>

                      <gmd:CI_OnlineResource>
                        <gmd:linkage>
                          <gmd:URL><xsl:value-of select="$ep" /></gmd:URL>
                        </gmd:linkage>
                        <gmd:protocol>
                          <gco:CharacterString>WWW:LINK-1.0-http--link</gco:CharacterString>
                        </gmd:protocol>
                        <xsl:apply-templates select="gmd:CI_OnlineResource/gmd:name" />
                        <xsl:apply-templates select="gmd:CI_OnlineResource/gmd:description" />
                      </gmd:CI_OnlineResource>
                    </xsl:copy>
                  </xsl:when>

                  <xsl:otherwise>
                    <xsl:copy-of select="."/>
                  </xsl:otherwise>
                </xsl:choose>

              </xsl:for-each>  <!-- onLine -->

              <xsl:apply-templates select="gmd:offLine" />
            </xsl:copy>
          </xsl:for-each> <!-- MD_DigitalTransferOptions -->
        </xsl:copy>
      </xsl:for-each>  <!-- transferOptions -->

      <xsl:variable name="link" select="$endPoints/endPoints/endPoint[@name!='datapackage.json'][1]" />
      <xsl:variable name="linkDataMart" select="string-join(tokenize($link,'/')[position()!=last()],'/')" />

      <xsl:variable name="dataMartLinkExists" select="count(gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[gmd:CI_OnlineResource/gmd:linkage/gmd:URL = $linkDataMart]) > 0" />
      <!--<xsl:message>linkDataMart: <xsl:value-of select="$linkDataMart" /></xsl:message>
      <xsl:message>DataMart links: <xsl:value-of select="count(gmd:transferOptions/gmd:onLine[normalize-space(gmd:CI_OnlineResource/gmd:linkage/gmd:URL) = normalize-space($linkDataMart)])" /></xsl:message>

      <xsl:for-each select="gmd:transferOptions/gmd:MD_DigitalTransferOptions">
        <xsl:message>Link:<xsl:value-of select="gmd:onLine/gmd:CI_OnlineResource/gmd:linkage/gmd:URL" /></xsl:message>
      </xsl:for-each>-->

      <!-- Add DataMart links if are not already present -->
      <xsl:if test="not($dataMartLinkExists)">
        <gmd:transferOptions>
          <gmd:MD_DigitalTransferOptions>
            <gmd:onLine xlink:role = "urn:xml:lang:eng-CAN">
              <gmd:CI_OnlineResource>
                <gmd:linkage>
                  <gmd:URL><xsl:value-of select="$linkDataMart" /></gmd:URL>
                </gmd:linkage>
                <gmd:protocol>
                  <gco:CharacterString>WWW:LINK-1.0-http--link</gco:CharacterString>
                </gmd:protocol>
                <gmd:name xsi:type="gmd:PT_FreeText_PropertyType">
                  <gco:CharacterString>
                    <xsl:choose>
                      <xsl:when test="$localeForTranslations = '#fra'">
                        View ECCC Data Mart (English)
                      </xsl:when>
                      <xsl:otherwise>
                        Voir le Dépôt de données d'ECCC (Anglais)
                      </xsl:otherwise>
                    </xsl:choose>
                  </gco:CharacterString>
                  <gmd:PT_FreeText>
                    <gmd:textGroup>
                      <gmd:LocalisedCharacterString locale="{$localeForTranslations}">
                        <xsl:choose>
                          <xsl:when test="$localeForTranslations = '#fra'">
                            Voir le Dépôt de données d'ECCC (Anglais)
                          </xsl:when>
                          <xsl:otherwise>
                            View ECCC Data Mart (English)
                          </xsl:otherwise>
                        </xsl:choose>
                      </gmd:LocalisedCharacterString>
                    </gmd:textGroup>
                  </gmd:PT_FreeText>
                </gmd:name>
                <gmd:description xsi:type="gmd:PT_FreeText_PropertyType">
                  <gco:CharacterString>
                    <xsl:choose>
                      <xsl:when test="$localeForTranslations = '#fra'">
                        Web Service;HTML;eng
                      </xsl:when>
                      <xsl:otherwise>
                        Service Web;HTML;eng
                      </xsl:otherwise>
                    </xsl:choose>
                  </gco:CharacterString>
                  <gmd:PT_FreeText>
                    <gmd:textGroup>
                      <gmd:LocalisedCharacterString locale="{$localeForTranslations}">
                        <xsl:choose>
                          <xsl:when test="$localeForTranslations = '#fra'">
                            Service Web;HTML;eng
                          </xsl:when>
                          <xsl:otherwise>
                            Web Service;HTML;eng
                          </xsl:otherwise>
                        </xsl:choose>
                      </gmd:LocalisedCharacterString>
                    </gmd:textGroup>
                  </gmd:PT_FreeText>
                </gmd:description>
              </gmd:CI_OnlineResource>
            </gmd:onLine>

            <gmd:onLine xlink:role = "urn:xml:lang:fra-CAN">
              <gmd:CI_OnlineResource>
                <gmd:linkage>
                  <gmd:URL><xsl:value-of select="concat($linkDataMart, '?lang=fr')" /></gmd:URL>
                </gmd:linkage>
                <gmd:protocol>
                  <gco:CharacterString>WWW:LINK-1.0-http--link</gco:CharacterString>
                </gmd:protocol>
                <gmd:name xsi:type="gmd:PT_FreeText_PropertyType">
                  <gco:CharacterString>
                    <xsl:choose>
                      <xsl:when test="$localeForTranslations = '#fra'">
                        View ECCC Data Mart (French)
                      </xsl:when>
                      <xsl:otherwise>
                        Voir le Dépôt de données d'ECCC (Français)
                      </xsl:otherwise>
                    </xsl:choose>
                  </gco:CharacterString>
                  <gmd:PT_FreeText>
                    <gmd:textGroup>
                      <gmd:LocalisedCharacterString locale="{$localeForTranslations}">
                        <xsl:choose>
                          <xsl:when test="$localeForTranslations = '#fra'">
                            Voir le Dépôt de données d'ECCC (Français)
                          </xsl:when>
                          <xsl:otherwise>
                            View ECCC Data Mart (French)
                          </xsl:otherwise>
                        </xsl:choose>
                      </gmd:LocalisedCharacterString>
                    </gmd:textGroup>
                  </gmd:PT_FreeText>
                </gmd:name>
                <gmd:description xsi:type="gmd:PT_FreeText_PropertyType">
                  <gco:CharacterString>
                    <xsl:choose>
                      <xsl:when test="$localeForTranslations = '#fra'">
                        Web Service;HTML;fra
                      </xsl:when>
                      <xsl:otherwise>
                        Service Web;HTML;fra
                      </xsl:otherwise>
                    </xsl:choose>
                  </gco:CharacterString>
                  <gmd:PT_FreeText>
                    <gmd:textGroup>
                      <gmd:LocalisedCharacterString locale="{$localeForTranslations}">
                        <xsl:choose>
                          <xsl:when test="$localeForTranslations = '#fra'">
                            Service Web;HTML;fra
                          </xsl:when>
                          <xsl:otherwise>
                            Web Service;HTML;fra
                          </xsl:otherwise>
                        </xsl:choose>
                      </gmd:LocalisedCharacterString>
                    </gmd:textGroup>
                  </gmd:PT_FreeText>
                </gmd:description>
              </gmd:CI_OnlineResource>
            </gmd:onLine>
          </gmd:MD_DigitalTransferOptions>
        </gmd:transferOptions>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================= -->

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================= -->

  <!-- Remove geonet:* elements. -->
  <xsl:template match="geonet:*" priority="2"/>
  <xsl:template match="@geonet:*" priority="2"/>

</xsl:stylesheet>
