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

<!--
Processing to insert or update an online resource element.
Insert is made in first transferOptions found.

Note: It assumes that it will be adding new items in
      the first /gmd:distributionInfo
      and first /gmd:MD_Distribution
      and first /gmd:transferOptions

-->
<xsl:stylesheet xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:digestUtils="java:org.apache.commons.codec.digest.DigestUtils"
                xmlns:exslt="http://exslt.org/common"
                exclude-result-prefixes="#all"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="2.0">

  <!-- Main properties for the link.
  Name and description may be multilingual eg. ENG#English name|FRE#Le français
  Name and description may be a list of layer/feature type names and titles comma separated. -->
  <xsl:param name="protocol" select="'WWW:LINK-1.0-http--link'"/>
  <xsl:param name="url"/>
  <xsl:param name="name"/>
  <xsl:param name="desc"/>
  <xsl:param name="function"/>
  <xsl:param name="applicationProfile"/>
  <xsl:param name="language"/>

  <!-- Add an optional uuidref attribute to the onLine element created. -->
  <xsl:param name="uuidref"/>

  <!-- In this case an external metadata is available under the
  extra element and all online resource from this records are added
  in this one. -->
  <xsl:param name="extra_metadata_uuid"/>

  <!-- Target element to update.
      updateKey is used to identify the resource name to be updated - it is for backwards compatibility.  Will not be used if resourceHash is set.
                The key is based on the concatenation of URL+Protocol+Name
      resourceHash is hash value of the object to be removed which will ensure the correct value is removed. It will override the usage of updateKey
      resourceIdx is the index location of the object to be removed - can be used when duplicate entries exists to ensure the correct one is removed.
  -->
  <xsl:param name="updateKey" select="''"/>
  <xsl:param name="resourceHash" select="''"/>
  <xsl:param name="resourceIdx" select="''"/>

  <xsl:variable name="update_flag">
    <xsl:value-of select="boolean($updateKey != '' or $resourceHash != '' or $resourceIdx != '')"/>
  </xsl:variable>


  <xsl:variable name="mainLang">
    <xsl:value-of
      select="(gmd:MD_Metadata|*[@gco:isoType='gmd:MD_Metadata'])/gmd:language/gco:CharacterString"/>
  </xsl:variable>

  <!-- Add new gmd:onLine and consider cases where parent elements don't exist -->
  <!--  <gmd:distributionInfo> does not exist-->
  <xsl:template match="gmd:MD_Metadata[not(gmd:distributionInfo) and $update_flag = false()]|*[@gco:isoType='gmd:MD_Metadata' and not(gmd:distributionInfo) and $update_flag = false()]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates
        select="gmd:fileIdentifier|
                gmd:language|
                gmd:characterSet|
                gmd:parentIdentifier|
                gmd:hierarchyLevel|
                gmd:hierarchyLevelName|
                gmd:contact|
                gmd:dateStamp|
                gmd:metadataStandardName|
                gmd:metadataStandardVersion|
                gmd:dataSetURI|
                gmd:locale|
                gmd:spatialRepresentationInfo|
                gmd:referenceSystemInfo|
                gmd:metadataExtensionInfo|
                gmd:identificationInfo|
                gmd:contentInfo"/>

      <gmd:distributionInfo>
        <gmd:MD_Distribution>
          <gmd:transferOptions>
            <gmd:MD_DigitalTransferOptions>
              <xsl:call-template name="createOnlineSrc"/>
            </gmd:MD_DigitalTransferOptions>
          </gmd:transferOptions>
        </gmd:MD_Distribution>
      </gmd:distributionInfo>

      <xsl:apply-templates
        select="gmd:dataQualityInfo|
                gmd:portrayalCatalogueInfo|
                gmd:metadataConstraints|
                gmd:applicationSchemaInfo|
                gmd:metadataMaintenance|
                gmd:series|
                gmd:describes|
                gmd:propertyType|
                gmd:featureType|
                gmd:featureAttribute"/>
    </xsl:copy>
  </xsl:template>

  <!--  <gmd:MD_Distribution> does not exist-->
  <xsl:template match="*/gmd:distributionInfo[not(gmd:MD_Distribution) and $update_flag = false() and position() = 1]">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
      <gmd:MD_Distribution>
        <gmd:transferOptions>
          <gmd:MD_DigitalTransferOptions>
            <xsl:call-template name="createOnlineSrc"/>
          </gmd:MD_DigitalTransferOptions>
        </gmd:transferOptions>
      </gmd:MD_Distribution>
    </xsl:copy>
  </xsl:template>

  <!--  <gmd:transferOptions> does not exist-->
  <xsl:template match="*/gmd:distributionInfo[1]/gmd:MD_Distribution[not(gmd:transferOptions) and $update_flag = false() and position() = 1]">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
      <gmd:transferOptions>
        <gmd:MD_DigitalTransferOptions>
          <xsl:call-template name="createOnlineSrc"/>
        </gmd:MD_DigitalTransferOptions>
      </gmd:transferOptions>
    </xsl:copy>
  </xsl:template>

  <!--  <gmd:MD_DigitalTransferOptions> does not exist-->
  <xsl:template match="*/gmd:distributionInfo[1]/gmd:MD_Distribution[1]/gmd:transferOptions[not(gmd:MD_DigitalTransferOptions) and $update_flag = false() and position() = 1]">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
      <gmd:MD_DigitalTransferOptions>
        <xsl:call-template name="createOnlineSrc"/>
      </gmd:MD_DigitalTransferOptions>
    </xsl:copy>
  </xsl:template>

  <!--  Add new gmd:gmd:onLine-->
  <xsl:template match="*/gmd:distributionInfo[1]/gmd:MD_Distribution[1]/gmd:transferOptions[1]/gmd:MD_DigitalTransferOptions[$update_flag = false() and position() = 1]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates
        select="gmd:unitsOfDistribution|
                gmd:transferSize|
                gmd:onLine"/>

      <xsl:call-template name="createOnlineSrc"/>

      <xsl:apply-templates select="gmd:offLine"/>
    </xsl:copy>
  </xsl:template>
  <!-- End of inserting gmd:onLine -->


  <!-- Updating the gmd:onLine based on update parameters -->
  <!-- Note: first part of the match needs to match the xsl:for-each select from extract-relations.xsl in order to get the position() to match -->
  <!-- The unique identifier is marked with resourceIdx which is the position index and resourceHash which is hash code of the current node (combination of url, resource name, and description) -->
  <!-- Template to match all gmd:onLine elements -->
  <xsl:template match="//gmd:MD_DigitalTransferOptions/gmd:onLine" priority="2">
    <!-- Calculate the global position of the current gmd:onLine element -->
    <xsl:variable name="position" select="count(//gmd:MD_DigitalTransferOptions/gmd:onLine[current() >> .]) + 1" />

    <xsl:choose>
      <xsl:when test="gmd:CI_OnlineResource[gmd:linkage/gmd:URL != ''] and
                        ($resourceIdx = '' or $position = xs:integer($resourceIdx)) and
                        ($resourceHash != '' or ($updateKey != '' and normalize-space($updateKey) = concat(
                            gmd:CI_OnlineResource/gmd:linkage/gmd:URL,
                            gmd:CI_OnlineResource/gmd:protocol/*,
                            gmd:CI_OnlineResource/gmd:name/gco:CharacterString)))
                       and ($resourceHash = '' or digestUtils:md5Hex(normalize-space(.)) = $resourceHash)">
        <xsl:call-template name="createOnlineSrc"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="createOnlineSrc">
    <!-- Add all online source from the target metadata to the
    current one -->
    <xsl:if test="//extra">
      <xsl:for-each select="//extra//gmd:onLine">
        <gmd:onLine>
          <xsl:if test="$extra_metadata_uuid">
            <xsl:attribute name="uuidref" select="$extra_metadata_uuid"/>
          </xsl:if>
          <xsl:apply-templates select="*"/>
        </gmd:onLine>
      </xsl:for-each>
    </xsl:if>

    <xsl:variable name="separator" select="'\|'"/>
    <xsl:variable name="useOnlyPTFreeText" select="'false'" />
    <!--  <xsl:value-of
        select="count(//*[gmd:PT_FreeText and not(gco:CharacterString)]) > 0"/>
    </xsl:variable>-->


    <xsl:if test="$url">
      <!-- In case the protocol is an OGC protocol
      the name parameter may contain a list of layers
      separated by comma.
      In that case on one online element is added per
      layer/featureType.
      -->
      <xsl:choose>
        <xsl:when test="starts-with($protocol, 'OGC:') and $name != ''">

          <xsl:variable name="resourceLang">
            <xsl:choose>
              <xsl:when test="ends-with($desc, 'fra')"><xsl:value-of select="'urn:xml:lang:fra-CAN'"/></xsl:when>
              <xsl:otherwise><xsl:value-of select="'urn:xml:lang:eng-CAN'"/></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <gmd:onLine>
            <xsl:attribute name="xlink:role" select="$resourceLang"/>

            <xsl:if test="$uuidref">
              <xsl:attribute name="uuidref" select="$uuidref"/>
            </xsl:if>
            <gmd:CI_OnlineResource>
              <gmd:linkage>
                <gmd:URL>
                  <xsl:value-of select="$url"/>
                </gmd:URL>
              </gmd:linkage>
              <gmd:protocol>
                <gco:CharacterString>
                  <xsl:value-of select="$protocol"/>
                </gco:CharacterString>
              </gmd:protocol>

              <xsl:if test="$applicationProfile != ''">
                <gmd:applicationProfile>
                  <xsl:choose>
                    <xsl:when test="contains($applicationProfile, '#')">
                      <xsl:for-each select="tokenize($applicationProfile, $separator)">
                        <xsl:variable name="nameLang"
                                      select="substring-before(., '#')"></xsl:variable>
                        <xsl:variable name="nameValue"
                                      select="substring-after(., '#')"></xsl:variable>
                        <xsl:if
                          test="$useOnlyPTFreeText = 'false' and $nameLang = $mainLang">
                          <gco:CharacterString>
                            <xsl:value-of select="$nameValue"/>
                          </gco:CharacterString>
                        </xsl:if>
                      </xsl:for-each>

                      <gmd:PT_FreeText>
                        <xsl:for-each select="tokenize($applicationProfile, $separator)">
                          <xsl:variable name="nameLang"
                                        select="substring-before(., '#')"></xsl:variable>
                          <xsl:variable name="nameValue"
                                        select="substring-after(., '#')"></xsl:variable>

                          <xsl:if
                            test="$useOnlyPTFreeText = 'true' or $nameLang != $mainLang">
                            <gmd:textGroup>
                              <gmd:LocalisedCharacterString
                                locale="{concat('#', $nameLang)}">
                                <xsl:value-of select="$nameValue"/>
                              </gmd:LocalisedCharacterString>
                            </gmd:textGroup>
                          </xsl:if>

                        </xsl:for-each>
                      </gmd:PT_FreeText>
                    </xsl:when>
                    <xsl:otherwise>
                      <gco:CharacterString>
                        <xsl:value-of select="$applicationProfile"/>
                      </gco:CharacterString>
                    </xsl:otherwise>
                  </xsl:choose>
                </gmd:applicationProfile>
              </xsl:if>

              <xsl:if test="$name != ''">
                <gmd:name>
                  <xsl:choose>

                    <!--Multilingual-->
                    <xsl:when test="contains($name, '#')">
                      <xsl:attribute name="xsi:type">gmd:PT_FreeText_PropertyType</xsl:attribute>

                      <xsl:for-each select="tokenize($name, $separator)">

                        <xsl:variable name="nameLang"
                                      select="substring-before(., '#')"></xsl:variable>
                        <xsl:variable name="nameValue"
                                      select="substring-after(., '#')"></xsl:variable>

                        <!--<xsl:message>useOnlyPTFreeText: <xsl:value-of select="$useOnlyPTFreeText" /></xsl:message>
                        <xsl:message>ML: <xsl:value-of select="$mainLang" /></xsl:message>
                        <xsl:message>nameLang: <xsl:value-of select="$nameLang" /></xsl:message>
                        <xsl:message>nameValue: <xsl:value-of select="$nameValue" /></xsl:message>-->


                        <xsl:if
                          test="$useOnlyPTFreeText = 'false' and $nameLang = $mainLang">
                          <gco:CharacterString>
                            <xsl:value-of select="$nameValue"/>
                          </gco:CharacterString>
                        </xsl:if>
                      </xsl:for-each>

                      <gmd:PT_FreeText>
                        <xsl:for-each select="tokenize($name, $separator)">
                          <xsl:variable name="nameLang"
                                        select="substring-before(., '#')"></xsl:variable>
                          <xsl:variable name="nameValue"
                                        select="substring-after(., '#')"></xsl:variable>

                          <xsl:if
                            test="$useOnlyPTFreeText = 'true' or $nameLang != $mainLang">
                            <gmd:textGroup>
                              <gmd:LocalisedCharacterString
                                locale="{concat('#', $nameLang)}">
                                <xsl:value-of select="$nameValue"/>
                              </gmd:LocalisedCharacterString>
                            </gmd:textGroup>
                          </xsl:if>

                        </xsl:for-each>
                      </gmd:PT_FreeText>
                    </xsl:when>
                    <xsl:otherwise>
                      <gco:CharacterString>
                        <xsl:value-of select="$name"/>
                      </gco:CharacterString>
                    </xsl:otherwise>
                  </xsl:choose>
                </gmd:name>
              </xsl:if>

              <xsl:if test="$desc != ''">
                <gmd:description>
                  <xsl:attribute name="xsi:type">gmd:PT_FreeText_PropertyType</xsl:attribute>

                  <xsl:choose>
                    <xsl:when test="contains($desc, '#')">
                      <xsl:for-each select="tokenize($desc, $separator)">
                        <xsl:variable name="descLang"
                                      select="substring-before(., '#')"></xsl:variable>
                        <xsl:variable name="descValue"
                                      select="substring-after(., '#')"></xsl:variable>
                        <xsl:if
                          test="$useOnlyPTFreeText = 'false' and $descLang = $mainLang">
                          <gco:CharacterString>
                            <xsl:value-of select="$descValue"/>
                          </gco:CharacterString>
                        </xsl:if>
                      </xsl:for-each>

                      <gmd:PT_FreeText>
                        <xsl:for-each select="tokenize($desc, $separator)">
                          <xsl:variable name="descLang"
                                        select="substring-before(., '#')"></xsl:variable>
                          <xsl:variable name="descValue"
                                        select="substring-after(., '#')"></xsl:variable>
                          <xsl:if
                            test="$useOnlyPTFreeText = 'true' or $descLang != $mainLang">
                            <gmd:textGroup>
                              <gmd:LocalisedCharacterString
                                locale="{concat('#', $descLang)}">
                                <xsl:value-of select="$descValue"/>
                              </gmd:LocalisedCharacterString>
                            </gmd:textGroup>
                          </xsl:if>
                        </xsl:for-each>
                      </gmd:PT_FreeText>
                    </xsl:when>
                    <xsl:otherwise>
                      <gco:CharacterString>
                        <xsl:value-of select="$desc"/>
                      </gco:CharacterString>
                    </xsl:otherwise>
                  </xsl:choose>
                </gmd:description>
              </xsl:if>


              <xsl:if test="$function != ''">
                <gmd:function>
                  <gmd:CI_OnLineFunctionCode
                    codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_OnLineFunctionCode"
                    codeListValue="{$function}"/>
                </gmd:function>
              </xsl:if>
            </gmd:CI_OnlineResource>
          </gmd:onLine>

        </xsl:when>
        <xsl:otherwise>
          <!-- ... the name is simply added in the newly
          created online element. -->
          <gmd:onLine>
            <xsl:variable name="isMapProtocol" select="starts-with($protocol, 'ESRI REST:') or starts-with($protocol, 'OGC:')" />

            <xsl:variable name="resourceLang">
              <xsl:choose>
                <xsl:when test="ends-with($desc, 'fra')"><xsl:value-of select="'urn:xml:lang:fra-CAN'"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="'urn:xml:lang:eng-CAN'"/></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <xsl:if test="$isMapProtocol">
              <xsl:attribute name="xlink:role" select="$resourceLang"/>
            </xsl:if>

            <xsl:if test="$uuidref">
              <xsl:attribute name="uuidref" select="$uuidref"/>
            </xsl:if>
            <gmd:CI_OnlineResource>
              <gmd:linkage>
                <gmd:URL>
                  <xsl:value-of select="$url"/>
                </gmd:URL>
              </gmd:linkage>

              <xsl:if test="$protocol != ''">
                <gmd:protocol>
                  <gco:CharacterString>
                    <xsl:value-of select="$protocol"/>
                  </gco:CharacterString>
                </gmd:protocol>
              </xsl:if>

              <xsl:if test="$applicationProfile != ''">
                <gmd:applicationProfile>
                  <xsl:choose>
                    <xsl:when test="contains($applicationProfile, '#')">
                      <xsl:for-each select="tokenize($applicationProfile, $separator)">
                        <xsl:variable name="nameLang"
                                      select="substring-before(., '#')"></xsl:variable>
                        <xsl:variable name="nameValue"
                                      select="substring-after(., '#')"></xsl:variable>
                        <xsl:if
                          test="$useOnlyPTFreeText = 'false' and $nameLang = $mainLang">
                          <gco:CharacterString>
                            <xsl:value-of select="$nameValue"/>
                          </gco:CharacterString>
                        </xsl:if>
                      </xsl:for-each>

                      <gmd:PT_FreeText>
                        <xsl:for-each select="tokenize($applicationProfile, $separator)">
                          <xsl:variable name="nameLang"
                                        select="substring-before(., '#')"></xsl:variable>
                          <xsl:variable name="nameValue"
                                        select="substring-after(., '#')"></xsl:variable>

                          <xsl:if
                            test="$useOnlyPTFreeText = 'true' or $nameLang != $mainLang">
                            <gmd:textGroup>
                              <gmd:LocalisedCharacterString
                                locale="{concat('#', $nameLang)}">
                                <xsl:value-of select="$nameValue"/>
                              </gmd:LocalisedCharacterString>
                            </gmd:textGroup>
                          </xsl:if>

                        </xsl:for-each>
                      </gmd:PT_FreeText>
                    </xsl:when>
                    <xsl:otherwise>
                      <gco:CharacterString>
                        <xsl:value-of select="$applicationProfile"/>
                      </gco:CharacterString>
                    </xsl:otherwise>
                  </xsl:choose>
                </gmd:applicationProfile>
              </xsl:if>

              <xsl:if test="$name != ''">
                <gmd:name>
                  <xsl:choose>

                    <!--Multilingual-->
                    <xsl:when test="contains($name, '#')">
                      <xsl:attribute name="xsi:type">gmd:PT_FreeText_PropertyType</xsl:attribute>

                      <xsl:for-each select="tokenize($name, $separator)">

                        <xsl:variable name="nameLang"
                                      select="substring-before(., '#')"></xsl:variable>
                        <xsl:variable name="nameValue"
                                      select="substring-after(., '#')"></xsl:variable>

                        <!--<xsl:message>useOnlyPTFreeText: <xsl:value-of select="$useOnlyPTFreeText" /></xsl:message>
                        <xsl:message>ML: <xsl:value-of select="$mainLang" /></xsl:message>
                        <xsl:message>nameLang: <xsl:value-of select="$nameLang" /></xsl:message>
                        <xsl:message>nameValue: <xsl:value-of select="$nameValue" /></xsl:message>-->


                        <xsl:if
                          test="$useOnlyPTFreeText = 'false' and $nameLang = $mainLang">
                          <gco:CharacterString>
                            <xsl:value-of select="$nameValue"/>
                          </gco:CharacterString>
                        </xsl:if>
                      </xsl:for-each>

                      <gmd:PT_FreeText>
                        <xsl:for-each select="tokenize($name, $separator)">
                          <xsl:variable name="nameLang"
                                        select="substring-before(., '#')"></xsl:variable>
                          <xsl:variable name="nameValue"
                                        select="substring-after(., '#')"></xsl:variable>

                          <xsl:if
                            test="$useOnlyPTFreeText = 'true' or $nameLang != $mainLang">
                            <gmd:textGroup>
                              <gmd:LocalisedCharacterString
                                locale="{concat('#', $nameLang)}">
                                <xsl:value-of select="$nameValue"/>
                              </gmd:LocalisedCharacterString>
                            </gmd:textGroup>
                          </xsl:if>

                        </xsl:for-each>
                      </gmd:PT_FreeText>
                    </xsl:when>
                    <xsl:otherwise>
                      <gco:CharacterString>
                        <xsl:value-of select="$name"/>
                      </gco:CharacterString>
                    </xsl:otherwise>
                  </xsl:choose>
                </gmd:name>
              </xsl:if>

              <xsl:if test="$desc != ''">
                <gmd:description>
                  <xsl:attribute name="xsi:type">gmd:PT_FreeText_PropertyType</xsl:attribute>

                  <xsl:choose>
                    <xsl:when test="contains($desc, '#')">
                      <xsl:for-each select="tokenize($desc, $separator)">
                        <xsl:variable name="descLang"
                                      select="substring-before(., '#')"></xsl:variable>
                        <xsl:variable name="descValue"
                                      select="substring-after(., '#')"></xsl:variable>
                        <xsl:if
                          test="$useOnlyPTFreeText = 'false' and $descLang = $mainLang">
                          <gco:CharacterString>
                            <xsl:value-of select="$descValue"/>
                          </gco:CharacterString>
                        </xsl:if>
                      </xsl:for-each>

                      <gmd:PT_FreeText>
                        <xsl:for-each select="tokenize($desc, $separator)">
                          <xsl:variable name="descLang"
                                        select="substring-before(., '#')"></xsl:variable>
                          <xsl:variable name="descValue"
                                        select="substring-after(., '#')"></xsl:variable>
                          <xsl:if
                            test="$useOnlyPTFreeText = 'true' or $descLang != $mainLang">
                            <gmd:textGroup>
                              <gmd:LocalisedCharacterString
                                locale="{concat('#', $descLang)}">
                                <xsl:value-of select="$descValue"/>
                              </gmd:LocalisedCharacterString>
                            </gmd:textGroup>
                          </xsl:if>
                        </xsl:for-each>
                      </gmd:PT_FreeText>
                    </xsl:when>
                    <xsl:otherwise>
                      <gco:CharacterString>
                        <xsl:value-of select="$desc"/>
                      </gco:CharacterString>
                    </xsl:otherwise>
                  </xsl:choose>
                </gmd:description>
              </xsl:if>

              <xsl:if test="$function != ''">
                <gmd:function>
                  <gmd:CI_OnLineFunctionCode
                    codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_OnLineFunctionCode"
                    codeListValue="{$function}"/>
                </gmd:function>
              </xsl:if>
            </gmd:CI_OnlineResource>
          </gmd:onLine>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="extra" priority="2"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
