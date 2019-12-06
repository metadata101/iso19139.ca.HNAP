<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright (C) 2001-2016 Food and Agriculture Organization of the
  ~ United Nations (FAO-UN), United Nations World Food Programme (WFP)
  ~ and United Nations Environment Programme (UNEP)
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or (at
  ~ your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful, but
  ~ WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  ~ General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
  ~
  ~ Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
  ~ Rome - Italy. email: geonetwork@osgeo.org
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:util="java:org.fao.geonet.util.XslUtil"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                version="2.0"
                exclude-result-prefixes="#all">

  <xsl:import href="../../iso19139/convert/functions.xsl"/>

  <!-- Override template -->
  <xsl:template mode="to-iso19139-keyword" match="*[not(/root/request/skipdescriptivekeywords)]" priority="100">
    <xsl:param name="textgroupOnly"/>
    <xsl:param name="listOfLanguage"/>
    <xsl:param name="withAnchor"/>
    <xsl:param name="withXlink"/>
    <xsl:param name="withThesaurusAnchor"/>

    <gmd:descriptiveKeywords>
      <xsl:choose>
        <xsl:when test="$withXlink">
          <xsl:variable name="isLocalXlink"
                        select="util:getSettingValue('system/xlinkResolver/localXlinkEnable')"/>
          <xsl:variable name="prefixUrl"
                        select="if ($isLocalXlink = 'true')
                                then concat('local://', $node, '/')
                                else $serviceUrl"/>

          <xsl:attribute name="xlink:href"
                         select="concat(
                                  $prefixUrl,
                                  'api/registries/vocabularies/keyword?thesaurus=',
                                   if (thesaurus/key) then thesaurus/key else /root/request/thesaurus,
                                  '&amp;id=', /root/request/id,
                                  if (/root/request/lang) then concat('&amp;lang=', /root/request/lang) else '',
                                  if ($textgroupOnly) then '&amp;textgroupOnly' else '')"/>
          <xsl:attribute name="xlink:show">replace</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="to-md-keywords-nap">
            <xsl:with-param name="withAnchor" select="$withAnchor"/>
            <xsl:with-param name="withThesaurusAnchor" select="$withThesaurusAnchor"/>
            <xsl:with-param name="listOfLanguage" select="$listOfLanguage"/>
            <xsl:with-param name="textgroupOnly" select="$textgroupOnly"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </gmd:descriptiveKeywords>
  </xsl:template>

  <!-- Override template -->
  <xsl:template mode="to-iso19139-keyword" match="*[/root/request/skipdescriptivekeywords]" priority="100">
    <xsl:param name="textgroupOnly"/>
    <xsl:param name="listOfLanguage"/>
    <xsl:param name="withAnchor"/>
    <xsl:param name="withThesaurusAnchor"/>

    <xsl:call-template name="to-md-keywords-nap">
      <xsl:with-param name="withAnchor" select="$withAnchor"/>
      <xsl:with-param name="withThesaurusAnchor" select="$withThesaurusAnchor"/>
      <xsl:with-param name="listOfLanguage" select="$listOfLanguage"/>
      <xsl:with-param name="textgroupOnly" select="$textgroupOnly"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="to-md-keywords-nap">
    <xsl:param name="textgroupOnly"/>
    <xsl:param name="listOfLanguage"/>
    <xsl:param name="withAnchor"/>
    <xsl:param name="withThesaurusAnchor"/>

    <gmd:MD_Keywords>
      <!-- Get thesaurus ID from keyword or from request parameter if no keyword found. -->
      <xsl:variable name="currentThesaurus"
                    select="if (thesaurus/key) then thesaurus/key else /root/request/thesaurus"/>


      <!-- Loop on all keyword from the same thesaurus -->
      <xsl:for-each select="//keyword[thesaurus/key = $currentThesaurus]">

        <gmd:keyword>
          <xsl:if test="$currentThesaurus = 'external.none.allThesaurus'">
            <!--
                if 'all' thesaurus we need to encode the thesaurus name so that update-fixed-info can re-organize the
                keywords into the correct thesaurus sections.
            -->
            <xsl:variable name="keywordThesaurus"
                          select="replace(./uri, 'http://org.fao.geonet.thesaurus.all/([^@]+)@@@.+', '$1')"/>
            <xsl:attribute name="gco:nilReason" select="concat('thesaurus::', $keywordThesaurus)"/>
          </xsl:if>

          <!-- Multilingual output if more than one requested language -->
          <xsl:choose>
            <xsl:when test="count($listOfLanguage) > 1">
              <xsl:attribute name="xsi:type" select="'gmd:PT_FreeText_PropertyType'"/>
              <xsl:variable name="keyword" select="."/>

              <xsl:if test="not($textgroupOnly)">
                <gco:CharacterString>
                  <xsl:value-of
                    select="$keyword/values/value[@language = $listOfLanguage[1]]/text()"></xsl:value-of>
                </gco:CharacterString>
              </xsl:if>

              <gmd:PT_FreeText>
                <xsl:for-each select="$listOfLanguage">
                  <xsl:if test="position() > 1">
                    <xsl:variable name="lang" select="."/>
                    <gmd:textGroup>
                      <gmd:LocalisedCharacterString
                        locale="#{$lang}">
                        <xsl:value-of
                          select="$keyword/values/value[@language = $lang]/text()"></xsl:value-of>
                      </gmd:LocalisedCharacterString>
                    </gmd:textGroup>
                  </xsl:if>
                </xsl:for-each>
              </gmd:PT_FreeText>
            </xsl:when>
            <xsl:otherwise>
              <!-- ... default mode -->
              <xsl:choose>
                <xsl:when test="$withAnchor">
                  <!-- TODO multilingual Anchor ? -->
                  <gmx:Anchor
                    xlink:href="{$serviceUrl}api/registries/vocabularies/keyword?thesaurus={thesaurus/key}&amp;id={uri}">
                    <xsl:value-of select="value"/>
                  </gmx:Anchor>
                </xsl:when>
                <xsl:otherwise>
                  <gco:CharacterString>
                    <xsl:value-of select="value"/>
                  </gco:CharacterString>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </gmd:keyword>
      </xsl:for-each>

      <!-- If no keyword, add one to avoid invalid metadata -->
      <xsl:if test="count(//keyword[thesaurus/key = $currentThesaurus]) = 0">
        <gmd:keyword gco:nilReason="missing">
          <gco:CharacterString></gco:CharacterString>
        </gmd:keyword>
      </xsl:if>

      <xsl:copy-of
        select="geonet:add-thesaurus-info-2($currentThesaurus, $withThesaurusAnchor, /root/gui/thesaurus/thesauri, not(/root/request/keywordOnly), $listOfLanguage[1])"/>
    </gmd:MD_Keywords>
  </xsl:template>

   <xsl:function name="geonet:add-thesaurus-info-2">
    <xsl:param name="currentThesaurus" as="xs:string"/>
    <xsl:param name="withThesaurusAnchor" as="xs:boolean"/>
    <xsl:param name="thesauri" as="node()"/>
    <xsl:param name="thesaurusInfo" as="xs:boolean"/>
    <xsl:param name="mdlang" as="xs:string"/>

    <xsl:variable name="altLang">
      <xsl:choose>
        <xsl:when test="starts-with(lower-case($mdlang), 'eng')">fra</xsl:when>
        <xsl:when test="starts-with(lower-case($mdlang), 'fre')">eng</xsl:when>
        <xsl:when test="starts-with(lower-case($mdlang), 'fra')">eng</xsl:when>
        <xsl:otherwise>eng</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>


    <!-- Add thesaurus theme -->
    <gmd:type>
      <gmd:MD_KeywordTypeCode
        codeList="http://www.isotc211.org/2005/resources/codeList.xml#MD_KeywordTypeCode"
        codeListValue="{$thesauri/thesaurus[key = $currentThesaurus]/dname}"/>
    </gmd:type>
    <xsl:if test="$thesaurusInfo">
      <xsl:variable name="thesaurusTitle" select="$thesauri/thesaurus[key = $currentThesaurus]/title" />

      <gmd:thesaurusName>
        <gmd:CI_Citation>
          <xsl:choose>
            <xsl:when test="normalize-space($thesaurusTitle) = 'theme.EC_Core_Subject.rdf'">
              <gmd:title xsi:type="gmd:PT_FreeText_PropertyType">
                <gco:CharacterString>Government of Canada Core Subject Thesaurus</gco:CharacterString>
                <gmd:PT_FreeText>
                  <gmd:textGroup>
                    <gmd:LocalisedCharacterString locale="#fra">Thésaurus des sujets de base du gouvernement du Canada</gmd:LocalisedCharacterString>
                  </gmd:textGroup>
                </gmd:PT_FreeText>
              </gmd:title>
              <gmd:date>
                <gmd:CI_Date>
                  <gmd:date>
                    <gco:Date>2004</gco:Date>
                  </gmd:date>
                  <gmd:dateType>
                    <gmd:CI_DateTypeCode codeListValue="RI_366"
                                         codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_87">creation;création</gmd:CI_DateTypeCode>
                  </gmd:dateType>
                </gmd:CI_Date>
              </gmd:date>
              <gmd:date>
                <gmd:CI_Date>
                  <gmd:date>
                    <gco:Date>2016-07-04</gco:Date>
                  </gmd:date>
                  <gmd:dateType>
                    <gmd:CI_DateTypeCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_87" codeListValue="RI_367">publication; publication</gmd:CI_DateTypeCode>
                  </gmd:dateType>
                </gmd:CI_Date>
              </gmd:date>
              <gmd:citedResponsibleParty>
                <gmd:CI_ResponsibleParty>
                  <gmd:organisationName xsi:type="gmd:PT_FreeText_PropertyType">
                    <gco:CharacterString>
                      <xsl:choose>
                        <xsl:when test="$altLang = 'fra'">Government of Canada; Library and Archives Canada</xsl:when>
                        <xsl:otherwise>Gouvernement du Canada; Bibliothèque et Archives Canada</xsl:otherwise>
                      </xsl:choose>
                    </gco:CharacterString>
                    <gmd:PT_FreeText>
                      <gmd:textGroup>
                        <gmd:LocalisedCharacterString locale="#{$altLang}">
                          <xsl:choose>
                            <xsl:when test="$altLang = 'fra'">Gouvernement du Canada; Bibliothèque et Archives Canada</xsl:when>
                            <xsl:otherwise>Government of Canada; Library and Archives Canada</xsl:otherwise>
                          </xsl:choose>
                        </gmd:LocalisedCharacterString>
                      </gmd:textGroup>
                    </gmd:PT_FreeText>
                  </gmd:organisationName>
                  <gmd:role>
                    <gmd:CI_RoleCode codeListValue="RI_409" codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_90">custodian; conservateur</gmd:CI_RoleCode>
                  </gmd:role>
                </gmd:CI_ResponsibleParty>
              </gmd:citedResponsibleParty>

            </xsl:when>
            <xsl:otherwise>
              <gmd:title xsi:type="gmd:PT_FreeText_PropertyType">
                <gco:CharacterString><xsl:value-of select="$thesauri/thesaurus[key = $currentThesaurus]/title"/></gco:CharacterString>
                <gmd:PT_FreeText>
                  <gmd:textGroup>
                    <gmd:LocalisedCharacterString locale="#fra"><xsl:value-of select="$thesauri/thesaurus[key = $currentThesaurus]/title"/></gmd:LocalisedCharacterString>
                  </gmd:textGroup>
                </gmd:PT_FreeText>
              </gmd:title>


              <xsl:variable name="thesaurusDate"
                            select="normalize-space($thesauri/thesaurus[key = $currentThesaurus]/date)"/>

              <xsl:if test="$thesaurusDate != ''">
                <gmd:date>
                  <gmd:CI_Date>
                    <gmd:date>
                      <xsl:choose>
                        <xsl:when test="contains($thesaurusDate, 'T')">
                          <gco:DateTime>
                            <xsl:value-of select="$thesaurusDate"/>
                          </gco:DateTime>
                        </xsl:when>
                        <xsl:otherwise>
                          <gco:Date>
                            <xsl:value-of select="$thesaurusDate"/>
                          </gco:Date>
                        </xsl:otherwise>
                      </xsl:choose>
                    </gmd:date>
                    <gmd:dateType>
                      <gmd:CI_DateTypeCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_87" codeListValue="RI_367">publication; publication</gmd:CI_DateTypeCode>
                    </gmd:dateType>
                  </gmd:CI_Date>
                </gmd:date>

                <gmd:date>
                  <gmd:CI_Date>
                    <gmd:date>
                      <xsl:choose>
                        <xsl:when test="contains($thesaurusDate, 'T')">
                          <gco:DateTime>
                            <xsl:value-of select="$thesaurusDate"/>
                          </gco:DateTime>
                        </xsl:when>
                        <xsl:otherwise>
                          <gco:Date>
                            <xsl:value-of select="$thesaurusDate"/>
                          </gco:Date>
                        </xsl:otherwise>
                      </xsl:choose>
                    </gmd:date>
                    <gmd:dateType>
                      <gmd:CI_DateTypeCode codeListValue="RI_366"
                                           codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_87">creation;création</gmd:CI_DateTypeCode>
                    </gmd:dateType>
                  </gmd:CI_Date>
                </gmd:date>
              </xsl:if>


              <xsl:if test="$withThesaurusAnchor">
                <gmd:identifier>
                  <gmd:MD_Identifier>
                    <gmd:code>
                      <gmx:Anchor xlink:href="{$thesauri/thesaurus[key = $currentThesaurus]/url}">
                        geonetwork.thesaurus.<xsl:value-of
                        select="$currentThesaurus"/>
                      </gmx:Anchor>
                    </gmd:code>
                  </gmd:MD_Identifier>
                </gmd:identifier>
              </xsl:if>

              <xsl:if test="contains($thesaurusTitle, 'EC_')">
                <gmd:citedResponsibleParty>
                  <gmd:CI_ResponsibleParty>
                    <gmd:organisationName xsi:type="gmd:PT_FreeText_PropertyType">
                      <gco:CharacterString>Government of Canada; Environment and Climate Change Canada</gco:CharacterString>
                      <gmd:PT_FreeText>
                        <gmd:textGroup>
                          <gmd:LocalisedCharacterString locale="#fra">Gouvernement du Canada; Environnement et Changement climatique Canada</gmd:LocalisedCharacterString>
                        </gmd:textGroup>
                      </gmd:PT_FreeText>
                    </gmd:organisationName>
                    <gmd:role>
                      <gmd:CI_RoleCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_90"
                                       codeListValue="RI_409"/>
                    </gmd:role>
                  </gmd:CI_ResponsibleParty>
                </gmd:citedResponsibleParty>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>



        </gmd:CI_Citation>
      </gmd:thesaurusName>
    </xsl:if>
  </xsl:function>
</xsl:stylesheet>
