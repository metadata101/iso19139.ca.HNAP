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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:gml320="http://www.opengis.net/gml"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:gn="http://www.fao.org/geonetwork"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
                version="2.0"
                exclude-result-prefixes="#all">

  <xsl:include href="layout-custom-fields.xsl"/>
  <xsl:include href="utility-tpl.xsl"/>

  <!-- Visit all XML tree recursively -->
  <xsl:template mode="mode-iso19139.ca.HNAP" match="*[$schema = 'iso19139.ca.HNAP']|@*[$schema = 'iso19139.ca.HNAP']">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:apply-templates mode="mode-iso19139" select=".">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="labels" select="$labels"/>
    </xsl:apply-templates>
  </xsl:template>


  <!-- napm:napMD_FileFormatCode_PropertyType is not a codelist element even if having codeList attribute.
       It's present in gmd:MD_BrowseGraphic that is handled in the Thubnails panel. Avoid processing it -->
  <xsl:template mode="mode-iso19139" priority="3005" match="*[*/@codeList and */@xsi:type='napm:napMD_FileFormatCode_PropertyType' and $schema = 'iso19139.ca.HNAP']" />

  <!-- Codelist - delegate to schema codelists -->
  <xsl:template mode="mode-iso19139" priority="2005" match="*[*/@codeList and $schema = 'iso19139.ca.HNAP']">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="codelists" select="$codelists" required="no"/>
    <xsl:param name="overrideLabel" select="''" required="no"/>
    <xsl:param name="refToDelete" required="no"/>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="elementName" select="name()"/>
    <xsl:variable name="labelConfig">
      <xsl:choose>
        <xsl:when test="$overrideLabel != ''">
          <element>
            <label><xsl:value-of select="$overrideLabel"/></label>
          </element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), '', $xpath)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="ref"
                  select="*/gn:element/@ref"/>

    <xsl:call-template name="render-element">
      <xsl:with-param name="label" select="$labelConfig/*"/>
      <xsl:with-param name="value" select="*/@codeListValue"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="$xpath"/>
      <xsl:with-param name="type" select="gn-fn-iso19139:getCodeListType(name())"/>
      <xsl:with-param name="name"
                      select="if ($isEditing) then concat(*/gn:element/@ref, '_codeListValue') else ''"/>
      <xsl:with-param name="editInfo" select="*/gn:element"/>
      <xsl:with-param name="parentEditInfo"
                      select="if ($refToDelete) then $refToDelete else gn:element"/>
      <xsl:with-param name="listOfValues"
                      select="gn-fn-metadata:getCodeListValues($schema, name(*[@codeListValue]), $codelists, .)"/>
      <xsl:with-param name="isFirst"
                      select="count(preceding-sibling::*[name() = $elementName]) = 0"/>
      <!-- Children of an element having an XLink using the directory
      is in readonly mode. Search by reference because this template may be
      called without context eg. render-table. -->
      <xsl:with-param name="isDisabled"
                      select="count($metadata//*[gn:element/@ref = $ref]/ancestor-or-self::node()[contains(@xlink:href, 'api/registries/entries')]) > 0"/>

      <xsl:with-param name="forceXsdSchemaCheck" select="false()"/>
    </xsl:call-template>

  </xsl:template>


  <!-- Use code previous to https://github.com/geonetwork/core-geonetwork/commit/30133214c723d04a20b50f2650fcfc12bea475c9 -->
  <!-- Render simple element which usually match a form field -->
  <xsl:template mode="mode-iso19139" priority="1000"
                match="*[gco:CharacterString[$schema = 'iso19139.ca.HNAP']|gco:Integer[$schema = 'iso19139.ca.HNAP']|gco:Decimal[$schema = 'iso19139.ca.HNAP']|
       gco:Boolean[$schema = 'iso19139.ca.HNAP']|gco:Real[$schema = 'iso19139.ca.HNAP']|gco:Measure[$schema = 'iso19139.ca.HNAP']|gco:Length[$schema = 'iso19139.ca.HNAP']|gco:Distance[$schema = 'iso19139.ca.HNAP']|gco:Angle[$schema = 'iso19139.ca.HNAP']|gmx:FileName[$schema = 'iso19139.ca.HNAP']|
       gco:Scale[$schema = 'iso19139.ca.HNAP']|gco:Record[$schema = 'iso19139.ca.HNAP']|gco:RecordType[$schema = 'iso19139.ca.HNAP']|gmx:MimeFileType[$schema = 'iso19139.ca.HNAP']|gmd:URL[$schema = 'iso19139.ca.HNAP']|gco:LocalName[$schema = 'iso19139.ca.HNAP']|gmd:PT_FreeText[$schema = 'iso19139.ca.HNAP']]">


    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="overrideLabel" select="''" required="no"/>
    <xsl:param name="refToDelete" required="no"/>
    <xsl:param name="config" required="no"/>

    <xsl:variable name="elementName" select="name()"/>
    <xsl:variable name="excluded"
                  select="gn-fn-iso19139:isNotMultilingualField(., $editorConfig)"/>

    <!-- Allow to define the main language in gmd:locale also, overriding default check in GeoNetwork
         that if there's 1 or more gmd:locale is handle as multilingual -->
    <xsl:variable name="metadataIsMultilingualHNAP" select="count($metadataOtherLanguages/*) > 1"/>


    <xsl:variable name="hasPTFreeText"
                  select="count(gmd:PT_FreeText) > 0"/>
    <xsl:variable name="hasOnlyPTFreeText"
                  select="count(gmd:PT_FreeText) > 0 and count(gco:CharacterString) = 0"/>
    <xsl:variable name="isMultilingualElement"
                  select="$metadataIsMultilingualHNAP and $excluded = false()"/>
    <xsl:variable name="isMultilingualElementExpanded"
                  select="$isMultilingualElement and count($editorConfig/editor/multilingualFields/expanded[name = $elementName]) > 0"/>

    <!-- For some fields, always display attributes.
    TODO: move to editor config ? -->
    <xsl:variable name="forceDisplayAttributes" select="count(gmx:FileName) > 0"/>

    <!-- TODO: Support gmd:LocalisedCharacterString -->
    <xsl:variable name="monoLingualValue" select="gco:CharacterString|gco:Integer|gco:Decimal|
      gco:Boolean|gco:Real|gco:Measure|gco:Length|gco:Distance|gco:Angle|gmx:FileName|
      gco:Scale|gco:Record|gco:RecordType|gmx:MimeFileType|gmd:URL|gco:LocalName"/>
    <xsl:variable name="theElement"
                  select="if ($isMultilingualElement and $hasOnlyPTFreeText or not($monoLingualValue))
                          then gmd:PT_FreeText
                          else $monoLingualValue"/>
    <!--
      This may not work if node context is lost eg. when an element is rendered
      after a selection with copy-of.
      <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>-->
    <xsl:variable name="xpath"
                  select="gn-fn-metadata:getXPathByRef(gn:element/@ref, $metadata, false())"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="labelConfig"
                  select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)"/>
    <xsl:variable name="helper" select="gn-fn-metadata:getHelper($labelConfig/helper, .)"/>

    <xsl:variable name="attributes">

      <!-- Create form for all existing attribute (not in gn namespace)
      and all non existing attributes not already present for the
      current element and its children (eg. @uom in gco:Distance).
      A list of exception is defined in form-builder.xsl#render-for-field-for-attribute. -->
      <xsl:apply-templates mode="render-for-field-for-attribute"
                           select="@*">
        <xsl:with-param name="ref" select="gn:element/@ref"/>
        <xsl:with-param name="insertRef" select="$theElement/gn:element/@ref"/>
      </xsl:apply-templates>
      <xsl:apply-templates mode="render-for-field-for-attribute"
                           select="*/@*">
        <xsl:with-param name="ref" select="$theElement/gn:element/@ref"/>
        <xsl:with-param name="insertRef" select="$theElement/gn:element/@ref"/>
      </xsl:apply-templates>
      <xsl:apply-templates mode="render-for-field-for-attribute"
                           select="gn:attribute[not(@name = parent::node()/@*/name())]">
        <xsl:with-param name="ref" select="gn:element/@ref"/>
        <xsl:with-param name="insertRef" select="$theElement/gn:element/@ref"/>
      </xsl:apply-templates>
      <xsl:apply-templates mode="render-for-field-for-attribute"
                           select="*/gn:attribute[not(@name = parent::node()/@*/name())]">
        <xsl:with-param name="ref" select="$theElement/gn:element/@ref"/>
        <xsl:with-param name="insertRef" select="$theElement/gn:element/@ref"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="errors">
      <xsl:if test="$showValidationErrors">
        <xsl:call-template name="get-errors">
          <xsl:with-param name="theElement" select="$theElement"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="values">
      <xsl:if test="$isMultilingualElement">
        <xsl:variable name="text"
                      select="normalize-space(gco:CharacterString|gmx:Anchor)"/>

        <values>

          <xsl:if test="gco:CharacterString">
            <value ref="{$theElement/gn:element/@ref}" lang="{$metadataLanguage}">
              <xsl:value-of select="gco:CharacterString"/>
            </value>
          </xsl:if>

          <!-- the existing translation -->
          <xsl:for-each select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString">
            <xsl:if test="not($metadataLanguage = substring-after(@locale, '#'))">
              <value ref="{gn:element/@ref}" lang="{substring-after(@locale, '#')}">
                <xsl:value-of select="."/>
              </value>
            </xsl:if>
          </xsl:for-each>

          <!-- and create field for none translated language -->
          <xsl:for-each select="$metadataOtherLanguages/lang">
            <xsl:variable name="code" select="@code"/>
            <xsl:variable name="currentLanguageId" select="@id"/>


            <xsl:variable name="ptFreeElementDoesNotExist"
                          select="count($theElement/parent::node()/
                                        gmd:PT_FreeText/*/
                                        gmd:LocalisedCharacterString[
                                          @locale = concat('#', $currentLanguageId)]) = 0"/>


            <xsl:choose>
<!--              <xsl:when test="$ptFreeElementDoesNotExist and-->
<!--                              $text != '' and-->
<!--                              $code = $metadataLanguage">-->
<!--              <value ref="lang_{@id}_{$theElement/parent::node()/gn:element/@ref}"-->
<!--                       lang="{@id}">-->
<!--                  <xsl:value-of select="$text"/>-->
<!--                </value>-->
<!--              </xsl:when>-->
              <xsl:when test="$ptFreeElementDoesNotExist">
                <xsl:if test="not($metadataLanguage = @id)">
                  <value ref="lang_{@id}_{$theElement/parent::node()/gn:element/@ref}"
                       lang="{@id}"></value>
                </xsl:if>
              </xsl:when>
            </xsl:choose>
          </xsl:for-each>
        </values>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="labelConfig">
      <xsl:choose>
        <xsl:when test="$overrideLabel != ''">
          <element>
            <label><xsl:value-of select="$overrideLabel"/></label>
          </element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$labelConfig"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>


    <xsl:call-template name="render-element">
      <xsl:with-param name="label"
                      select="$labelConfig/*"/>
      <xsl:with-param name="value" select="if ($isMultilingualElement) then $values else *"/>
      <xsl:with-param name="errors" select="$errors"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <!--<xsl:with-param name="widget"/>
        <xsl:with-param name="widgetParams"/>-->
      <xsl:with-param name="xpath" select="$xpath"/>
      <xsl:with-param name="attributesSnippet" select="$attributes"/>
      <xsl:with-param name="type"
                      select="if ($config and $config/@use != '')
                              then $config/@use
                              else gn-fn-metadata:getFieldType($editorConfig, name(),
        name($theElement), $xpath)"/>
      <xsl:with-param name="directiveAttributes">
        <xsl:choose>
          <xsl:when test="$config and $config/@use != ''">
            <xsl:element name="directive">
              <xsl:attribute name="data-directive-name" select="$config/@use"/>
              <xsl:copy-of select="$config/directiveAttributes/@*"/>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="gn-fn-metadata:getFieldDirective($editorConfig, name(),name($theElement), $xpath)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="name" select="$theElement/gn:element/@ref"/>
      <xsl:with-param name="editInfo" select="$theElement/gn:element"/>
      <xsl:with-param name="parentEditInfo"
                      select="if ($refToDelete) then $refToDelete else gn:element"/>
      <!-- TODO: Handle conditional helper -->
      <xsl:with-param name="listOfValues" select="$helper"/>
      <xsl:with-param name="toggleLang" select="$isMultilingualElementExpanded"/>
      <xsl:with-param name="forceDisplayAttributes" select="$forceDisplayAttributes"/>
      <xsl:with-param name="isFirst"
                      select="count(preceding-sibling::*[name() = $elementName]) = 0"/>
      <!-- Children of an element having an XLink using the directory
      is in readonly mode. Search by reference because this template may be
      called without context eg. render-table. -->
      <xsl:with-param name="isDisabled"
                      select="count($metadata//*[gn:element/@ref = $theElement/gn:element/@ref]/ancestor-or-self::node()[contains(@xlink:href, 'api/registries/entries')]) > 0"/>

      <xsl:with-param name="forceXsdSchemaCheck" select="false()"/>
    </xsl:call-template>

  </xsl:template>

</xsl:stylesheet>
