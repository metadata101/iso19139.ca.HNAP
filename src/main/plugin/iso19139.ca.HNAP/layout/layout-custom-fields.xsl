<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:gml320="http://www.opengis.net/gml"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:gn="http://www.fao.org/geonetwork"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gn-fn-core="http://geonetwork-opensource.org/xsl/functions/core"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:ns2="http://www.w3.org/2004/02/skos/core#"
                xmlns:XslUtilHnap="java:ca.gc.schema.iso19139hnap.util.XslUtilHnap"
                xmlns:xslutil="java:org.fao.geonet.util.XslUtil"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:geonet="http://www.fao.org/geonetwork"


                xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="#all">


  <xsl:variable name="thesauriDir" select="XslUtilHnap:getThesauriDir()" />
  <xsl:variable name="resourceFormatsThLocation" select="if ($listOfThesaurus/thesaurus[key='external.theme.GC_Resource_Formats'])
                                                         then 'external'
                                                         else ' local'" />

  <xsl:variable name="resourceFormatsTh" select="document(concat('file:///', replace(concat($thesauriDir, '/', $resourceFormatsThLocation, '/thesauri/theme/GC_Resource_Formats.rdf'), '\\', '/')))" />

  <xsl:variable name="UseGOCOrganisationName" select="/root/gui/settings/schema/iso19139.ca.HNAP/UseGovernmentOfCanadaOrganisationName"/>

  <!-- Hide thesaurus name in default view -->
  <xsl:template mode="mode-iso19139" priority="2005" match="gmd:thesaurusName[$tab='default' and $schema = 'iso19139.ca.HNAP' ]" />

  <!-- Hide protocol for contacts in default view -->
  <xsl:template mode="mode-iso19139" priority="2005" match="gmd:protocol[$tab='default' and $schema = 'iso19139.ca.HNAP']" />


  <!-- ===================================================================== -->
  <!-- gml:TimePeriod (format = %Y-%m-%dThh:mm:ss) -->
  <!-- ===================================================================== -->
  <xsl:template mode="mode-iso19139" match="gml:beginPosition[$schema='iso19139.ca.HNAP']|gml:endPosition[$schema='iso19139.ca.HNAP']|gml:timePosition[$schema='iso19139.ca.HNAP']|
  	                                        gml320:beginPosition[$schema='iso19139.ca.HNAP']|gml320:endPosition[$schema='iso19139.ca.HNAP']|gml320:timePosition[$schema='iso19139.ca.HNAP']"
                priority="2000">

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="value" select="normalize-space(text())"/>


    <xsl:variable name="attributes">
      <xsl:if test="$isEditing">
        <!-- Create form for all existing attribute (not in gn namespace)
        and all non existing attributes not already present. -->
        <xsl:apply-templates mode="render-for-field-for-attribute"
                             select="             @*|           gn:attribute[not(@name = parent::node()/@*/name())]">
          <xsl:with-param name="ref" select="gn:element/@ref"/>
          <xsl:with-param name="insertRef" select="gn:element/@ref"/>
        </xsl:apply-templates>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="dateTypeElementRef" select="../gn:element/@ref"/>
    <xsl:variable name="tooltip" select="concat($schema, '|', name(.), '|', name(..), '|', $xpath)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="labelConfig" select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)"/>
    <xsl:variable name="gn-required">
      <xsl:if test="$labelConfig/condition='mandatory'">
        <xsl:text>gn-required</xsl:text>
      </xsl:if>
    </xsl:variable>

    <div class="form-group gn-field gn-date {$gn-required}"
         id="gn-el-{$dateTypeElementRef}"
         data-gn-field-highlight="">
      <label class="col-sm-2 control-label">
        <xsl:value-of select="$labelConfig/label"/>
      </label>
      <div class="col-sm-6 gn-value">
        <div data-gn-date-picker="{.}"
             data-gn-field-tooltip="{$tooltip}"
             data-label=""
             data-element-name="{name(.)}"
             data-tag-name=""
             data-element-ref="{concat('_', gn:element/@ref)}"
             data-hide-time="{if ($viewConfig/@hideTimeInCalendar = 'true') then 'true' else 'false'}">
        </div>

        <!-- Create form for all existing attribute (not in gn namespace)
         and all non existing attributes not already present. -->
        <div class="well well-sm gn-attr {if ($isDisplayingAttributes = true()) then '' else 'hidden'}">
          <xsl:apply-templates mode="render-for-field-for-attribute"
                               select="
          ../../@*|
          ../../gn:attribute[not(@name = parent::node()/@*/name())]">
            <xsl:with-param name="ref" select="../../gn:element/@ref"/>
            <xsl:with-param name="insertRef" select="../gn:element/@ref"/>
          </xsl:apply-templates>
        </div>
      </div>
      <div class="col-sm-1 gn-control">
        <xsl:call-template name="render-form-field-control-remove">
          <xsl:with-param name="editInfo" select="../gn:element"/>
          <xsl:with-param name="parentEditInfo" select="../../gn:element"/>
        </xsl:call-template>
      </div>

      <div class="col-sm-offset-2 col-sm-9">
        <xsl:call-template name="get-errors"/>
      </div>
    </div>
  </xsl:template>

<!--
    Special handling for the gmd:organisationName.  See MultiEntryCombiner.js for more info on how this works.
    Basically this is a replacement for render-element.
    Instead, it just creates a VERY simple HTML fragment (see MultiEntryCombiner.js for example).
    The MultiEntryCombiner directive handles most of this.
    This code mostly sets up two things;
    a) basic shell HTML so it can be displayed in the editor (see MultiEntryCombiner.js for HTML example).
    b) sets up the JSON configuration (see MultiEntryCombiner.js for example JSON).
-->
  <xsl:template mode="mode-iso19139" match="gmd:organisationName[$UseGOCOrganisationName = 'true' and $schema = 'iso19139.ca.HNAP']" priority="3000"  >
    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="labelConfig" select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)"/>

    <xsl:variable name="theElement" select="." />

    <xsl:variable name="hasDefaultValue" select="gco:CharacterString != ''"/>

    <!--
      Creates this (actual values of the metadata record);

        <values>
            <value ref="15" lang="eng">Government of Canada; Organization of Public Services and Procurement Canada; Defence and Marine Procurement</value>
            <value ref="18" lang="fra">Gouvernement du Canada; Organisation de Services publics et Approvisionnement Canada; Approvisionnement maritime et de défense</value>
        </values>

        Handles the Default language/non-default languages and duplication.
    -->
    <xsl:variable name="values">
      <values>
        <!-- main language -->
        <xsl:if test="$hasDefaultValue">
          <value ref="{gco:CharacterString/gn:element/@ref}" lang="{$metadataLanguage}">
            <xsl:value-of select="gco:CharacterString"/>
          </value>
        </xsl:if>

        <!-- the existing translation -->
        <xsl:for-each select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString">
          <!-- don't put in the default lang if it already has a value -->
          <xsl:if test="not($hasDefaultValue) or substring-after(@locale, '#') != $metadataLanguage">
            <value ref="{gn:element/@ref}" lang="{substring-after(@locale, '#')}">
              <xsl:value-of select="."/>
            </value>
          </xsl:if>
        </xsl:for-each>

        <!-- and create field for none translated language -->
        <xsl:for-each select="$metadataOtherLanguages/lang">
          <xsl:variable name="currentLanguageId" select="@id"/>
          <xsl:if test="count($theElement/
                gmd:PT_FreeText/gmd:textGroup/
                gmd:LocalisedCharacterString[@locale = concat('#',$currentLanguageId)]) = 0">
            <!--don't put in default language if already there-->
              <xsl:if test="not($hasDefaultValue) or $currentLanguageId != $metadataLanguage ">
                 <value ref="lang_{@id}_{$theElement/gn:element/@ref}"
                    lang="{@id}"></value>
              </xsl:if>
          </xsl:if>
        </xsl:for-each>
      </values>
    </xsl:variable>


    <xsl:variable name="DefaultMainOrganizationName_fr" select="/root/gui/settings/schema/iso19139.ca.HNAP/DefaultMainOrganizationName_fr"/>

    <xsl:variable name="DefaultMainOrganizationName_en" select="/root/gui/settings/schema/iso19139.ca.HNAP/DefaultMainOrganizationName_en"/>


    <!--
      This creates the "values":  section
       "values": {
                  "eng":"... actual metadata record value ..." ,
                  "fra":"... actual metadata record value ..."
        }
    -->
    <xsl:variable name="json_values">
      {
      <xsl:for-each select="$values/values/value">
        "<xsl:value-of select="@lang"/>":"<xsl:value-of select="."/>" <xsl:if test="not(position() = last())">,</xsl:if>
      </xsl:for-each>
      }
    </xsl:variable>

    <xsl:variable name="refs_json">
      {
      <xsl:for-each select="$values/values/value">
        "<xsl:value-of select="@lang"/>":"<xsl:value-of select="@ref"/>" <xsl:if test="not(position() = last())">,</xsl:if>
      </xsl:for-each>
      }
    </xsl:variable>

    <!---
      This is constant for ALL organisationNames - it defines what the UI looks like and how it works.
    -->
    <xsl:variable name="json_config">
      [
          {
            "type": "thesaurus",
            "heading": {
                "eng": "",
                "fra": ""
            },
            "thesaurus": "external.theme.GC_Org_Names",
            "defaultValues": {
                  "eng": "<xsl:value-of select="$DefaultMainOrganizationName_en"/>",
                  "fra": "<xsl:value-of select="$DefaultMainOrganizationName_fr"/>"
            }
          },

          {
            "type": "thesaurus",
            "heading": {
              "eng": "Department/Agency",
              "fra": "Département/agence"
            },
            "thesaurus": "external.theme.GC_Departments",
            "numberOfSuggestions": 200
          },

          {
            "type": "freeText",
            "heading": {
              "eng": "Sub-organizations (sectors, branches, etc.)",
              "fra": "Sous-organisations (secteurs, branches, etc.)"
            }
          }
      ]
    </xsl:variable>

    <xsl:variable name="cls" select="local-name()"/>

    <xsl:variable name="json">
      {
        "combiner":"; ",
        "root_id":"<xsl:value-of select="gn:element/@ref"/>",
        "refs":<xsl:copy-of select="$refs_json"/>,
        "defaultLang":"<xsl:copy-of select="$metadataLanguage"/>",
        "values": <xsl:copy-of select="$json_values"/>,
        "config":<xsl:copy-of select="$json_config"/>
      }
    </xsl:variable>

    <xsl:variable name="gn-required">
      <xsl:if test="$labelConfig/condition='mandatory'">
        <xsl:text>gn-required</xsl:text>
      </xsl:if>
    </xsl:variable>

    <div class="form-group gn-field gn-control gn-{$cls}"  >
      <label for="orgname" class="col-sm-2 control-label {$gn-required}" data-gn-field-tooltip="iso19139.ca.HNAP|gmd:organisationName" ><xsl:copy-of select="$labelConfig/label/text()"/></label>

      <div data-gn-multientry-combiner="{$json}"
           class="col-sm-9 col-xs-11 gn-value nopadding-in-table"
           data-label="$labelConfig/label">
      </div>
      <div class="col-sm-1 gn-control"/>
    </div>

  </xsl:template>



  <!-- Distribution format: Show list of allowed formats -->
  <xsl:template mode="mode-iso19139" match="//gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat/gmd:MD_Format/gmd:name[$schema = 'iso19139.ca.HNAP']" priority="2005">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="codelists" select="$codelists" required="no"/>
    <xsl:param name="overrideLabel" select="''" required="no"/>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="elementName" select="name()"/>

    <xsl:variable name="listOfValues">
      <entries>
        <xsl:for-each select="$resourceFormatsTh/rdf:RDF/rdf:Description">
          <entry>
            <code><xsl:value-of select="replace(@rdf:about, 'http://geonetwork-opensource.org/EC/resourceformat#', '')" /></code>
            <label><xsl:value-of select="ns2:prefLabel[@xml:lang=XslUtilHnap:twoCharLangCode($lang)]"/></label>
          </entry>
        </xsl:for-each>
      </entries>
    </xsl:variable>

    <xsl:call-template name="render-element">
      <xsl:with-param name="label"
                      select="if ($overrideLabel != '') then $overrideLabel else gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)"/>
      <xsl:with-param name="value" select="gco:CharacterString"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="$xpath"/>
      <xsl:with-param name="type" select="'select'"/>
      <xsl:with-param name="name"
                      select="*[1]/gn:element/@ref"/>
      <xsl:with-param name="editInfo" select="*[1]/gn:element"/>
      <xsl:with-param name="parentEditInfo" select="gn:element"/>
      <xsl:with-param name="listOfValues"
                      select="$listOfValues/entries"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:function name="geonet:getThesaurusTitle">
    <xsl:param name="thesarusNameEl" />
    <xsl:param name="lang1" />

    <xsl:variable name="lang">
        <xsl:choose>
          <xsl:when test="lower-case($lang1) = 'fre'">
            <xsl:value-of select="'#fra'"/>
          </xsl:when>

          <xsl:otherwise>
            <xsl:value-of select="concat('#',lower-case($lang1))"/>
          </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="thesaurusTitleSimple" select="$thesarusNameEl/gmd:CI_Citation/gmd:title/gco:CharacterString/normalize-space()" />
    <xsl:variable name="thesaurusTitleMultilingualNode"
                  select="$thesarusNameEl/gmd:CI_Citation/gmd:title/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale = $lang]/normalize-space()"
    />


    <xsl:choose>
      <xsl:when test="$thesaurusTitleMultilingualNode">
        <xsl:value-of select="$thesaurusTitleMultilingualNode"/>
      </xsl:when>

      <xsl:otherwise>
        <xsl:value-of select="$thesaurusTitleSimple"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- Metadata resources template -->
  <xsl:template mode="mode-iso19139"  match="//gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions[1][$schema = 'iso19139.ca.HNAP']" priority="2005" />

  <!-- Descriptive Keywords -->
  <xsl:template mode="mode-iso19139" priority="5000"
                match="gmd:descriptiveKeywords[$schema = 'iso19139.ca.HNAP']">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="overrideLabel" select="''" required="no"/>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="thesaurusTitleEl"
                  select="gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title"/>

    <xsl:variable name="thesaurusTitleMultiLingual" select="geonet:getThesaurusTitle(gmd:MD_Keywords/gmd:thesaurusName,$lang)"/>

    <!--Add all Thesaurus as first block of keywords-->
    <xsl:if test="name(preceding-sibling::*[1]) != name()">
      <xsl:call-template name="addAllThesaurus">
        <xsl:with-param name="ref" select="../gn:element/@ref"/>
      </xsl:call-template>
    </xsl:if>

    <xsl:variable name="thesaurusTitle">
      <xsl:choose>
        <xsl:when test="normalize-space($thesaurusTitleMultiLingual) != ''">
          <xsl:value-of select="if ($overrideLabel != '')
              then $overrideLabel
              else concat(
                      $iso19139strings/keywordFrom,
                      normalize-space($thesaurusTitleMultiLingual))"/>
        </xsl:when>

        <xsl:otherwise>
          <xsl:value-of select="gmd:MD_Keywords/gmd:thesaurusName/
                                  gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="attributes">
      <xsl:if test="$isEditing">
        <!-- Create form for all existing attribute (not in gn namespace)
        and all non existing attributes not already present. -->
        <xsl:apply-templates mode="render-for-field-for-attribute"
                             select="
          @*|
          gn:attribute[not(@name = parent::node()/@*/name())]">
          <xsl:with-param name="ref" select="gn:element/@ref"/>
          <xsl:with-param name="insertRef" select="gn:element/@ref"/>
        </xsl:apply-templates>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="thesaurusIdentifier"
                  select="normalize-space($thesaurusTitle)"/>

    <!-- DJB: might be wrong-->
    <xsl:variable name="thesaurusConfig"
                  as="element()?"
                  select="if ($thesaurusList/thesaurus[@key=substring-after($thesaurusIdentifier, 'geonetwork.thesaurus.')])
                          then $thesaurusList/thesaurus[@key=substring-after($thesaurusIdentifier, 'geonetwork.thesaurus.')]
                          else if ($listOfThesaurus/thesaurus[title=$thesaurusTitle])
                          then $listOfThesaurus/thesaurus[title=$thesaurusTitle]
                          else $listOfThesaurus/thesaurus[./multilingualTitles/multilingualTitle/title=$thesaurusTitle]"/>


    <xsl:choose>
      <xsl:when test="$thesaurusConfig/@fieldset = 'false'">

        <xsl:apply-templates mode="mode-iso19139" select="*">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="labels" select="$labels"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="hideDelete" as="xs:boolean">
              <xsl:value-of select="false()" />
         </xsl:variable>

        <xsl:variable name="labelConfig" select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)"/>
        <xsl:variable name="requiredClass">
          <xsl:if test="$labelConfig/condition='mandatory'">
            <xsl:value-of select="'gn-required'" />
          </xsl:if>
        </xsl:variable>

        <xsl:call-template name="render-boxed-element">
          <xsl:with-param name="label"
                          select="if ($thesaurusTitle !='')
                    then $thesaurusTitle
                    else gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)/label"/>
          <xsl:with-param name="editInfo" select="gn:element"/>
          <xsl:with-param name="cls" select="concat(local-name(), ' ', $requiredClass)"/>
          <xsl:with-param name="xpath" select="$xpath"/>
          <xsl:with-param name="attributesSnippet" select="$attributes"/>
          <!--<xsl:with-param name="hideDelete" select="$hideDelete" />-->
          <xsl:with-param name="subTreeSnippet">
            <xsl:apply-templates mode="mode-iso19139" select="*">
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="labels" select="$labels"/>
            </xsl:apply-templates>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:function name="geonet:findThesaurus">
    <xsl:param name="title1" />
    <xsl:param name="title2" />

    <!--standard way to look for thesaurus-->
    <xsl:variable name="thesaurusConfig"
                  as="element()?"
                  select="if ($listOfThesaurus/thesaurus[@key=substring-after($title1, 'geonetwork.thesaurus.')])
                          then $listOfThesaurus/thesaurus[@key=substring-after($title1, 'geonetwork.thesaurus.')]
                          else if ($listOfThesaurus/thesaurus[title=$title1])
                          then $listOfThesaurus/thesaurus[title=$title1]
                          else if ($listOfThesaurus/thesaurus[title=$title2])
                          then $listOfThesaurus/thesaurus[title=$title2]
                          else $listOfThesaurus/thesaurus[key=$title2]"/>
    <!--handle multilingual case -->
    <xsl:variable name="thesaurusConfig2"
                  as="element()?"
                  select="$listOfThesaurus/thesaurus[./multilingualTitles/multilingualTitle/title=$title1]"/>
    <xsl:variable name="thesaurusConfig3"
                  as="element()?"
                  select="$listOfThesaurus/thesaurus[./multilingualTitles/multilingualTitle/title=$title2]"/>

    <xsl:choose>
        <xsl:when test="$thesaurusConfig">
           <xsl:copy-of  select="$thesaurusConfig"/>
        </xsl:when>
        <xsl:when test="$thesaurusConfig2">
          <xsl:copy-of  select="$thesaurusConfig2"/>
        </xsl:when>
        <xsl:when test="$thesaurusConfig3">
          <xsl:copy-of  select="$thesaurusConfig3"/>
        </xsl:when>
    </xsl:choose>
  </xsl:function>


  <xsl:template mode="mode-iso19139" match="gmd:MD_Keywords[$schema = 'iso19139.ca.HNAP']" priority="6000">

    <xsl:variable name="thesaurusIdentifier"
                  select="normalize-space(gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>


    <xsl:variable name="thesaurusTitle"
                  select="gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString"/>

    <xsl:variable name="thesaurusTitle2">
          <xsl:value-of  select="normalize-space(gmd:thesaurusName/gmd:CI_Citation/gmd:title/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString)"/>
    </xsl:variable>


    <xsl:variable name="thesaurusConfig"  as="element()?"  select="geonet:findThesaurus($thesaurusTitle,$thesaurusTitle2)" />


    <xsl:choose>
      <xsl:when test="$thesaurusConfig">

        <xsl:variable name="thesaurusIdentifier"
                      select="$thesaurusConfig/key"/>

        <!-- The thesaurus key may be contained in the MD_Identifier field or
          get it from the list of thesaurus based on its title.
          -->
        <xsl:variable name="thesaurusInternalKey"
                      select="if ($thesaurusIdentifier)
          then $thesaurusIdentifier
          else $thesaurusConfig/key"/>
        <xsl:variable name="thesaurusKey"
                      select="if (starts-with($thesaurusInternalKey, 'geonetwork.thesaurus.'))
                      then substring-after($thesaurusInternalKey, 'geonetwork.thesaurus.')
                      else $thesaurusInternalKey"/>

        <!-- if gui lang eng > #EN -->
        <xsl:variable name="guiLangId"
                      select="
                      if (count($metadata/gmd:locale/gmd:PT_Locale[gmd:languageCode/gmd:LanguageCode/@codeListValue = $lang]) = 1)
                        then $metadata/gmd:locale/gmd:PT_Locale[gmd:languageCode/gmd:LanguageCode/@codeListValue = $lang]/@id
                        else $metadata/gmd:locale/gmd:PT_Locale[gmd:languageCode/gmd:LanguageCode/@codeListValue = $metadataLanguage]/@id"/>

        <!--
        get keyword in gui lang
        in default language
        -->
        <xsl:variable name="keywords" select="string-join(
                  if ($guiLangId and gmd:keyword//*[@locale = concat('#', $guiLangId)]) then
                    gmd:keyword//*[@locale = concat('#', $guiLangId)]/replace(text(), ',', ',,')
                  else gmd:keyword/*[1]/replace(text(), ',', ',,'), ',')"/>

        <!-- Define the list of transformation mode available. -->
        <!--<xsl:variable name="transformations"
                      as="xs:string"
                      select="if ($thesaurusConfig/@transformations != '')
                              then $thesaurusConfig/@transformations
                              else 'to-iso19139-keyword,to-iso19139-keyword-with-anchor,to-iso19139-keyword-as-xlink'"/>-->
        <xsl:variable name="transformations" select="'to-iso19139.ca.HNAP-keyword,to-iso19139.ca.HNAP-keyword-with-anchor,to-iso19139.ca.HNAP-keyword-as-xlink'" />

        <!-- Get current transformation mode based on XML fragment analysis -->
        <xsl:variable name="transformation"
                      select="if (parent::node()/@xlink:href) then 'to-iso19139.ca.HNAP-keyword-as-xlink'
          else if (count(gmd:keyword/gmx:Anchor) > 0)
          then 'to-iso19139.ca.HNAP-keyword-with-anchor'
          else 'to-iso19139.ca.HNAP-keyword'"/>

        <xsl:variable name="parentName" select="name(..)"/>

        <!-- Create custom widget:
              * '' for item selector,
              * 'tagsinput' for tags
              * 'tagsinput' and maxTags = 1 for only one tag
              * 'multiplelist' for multiple selection list
        -->
        <xsl:variable name="widgetMode" select="'tagsinput'"/>
        <xsl:variable name="maxTags"
                      as="xs:string"
                      select="if ($thesaurusConfig/@maxtags)
                              then $thesaurusConfig/@maxtags
                              else ''"/>
        <!--
          Example: to restrict number of keyword to 1 for INSPIRE
          <xsl:variable name="maxTags"
          select="if ($thesaurusKey = 'external.theme.inspire-theme') then '1' else ''"/>
        -->
        <!-- Create a div with the directive configuration
            * elementRef: the element ref to edit
            * elementName: the element name
            * thesaurusName: the thesaurus title to use
            * thesaurusKey: the thesaurus identifier
            * keywords: list of keywords in the element
            * transformations: list of transformations
            * transformation: current transformation
          -->

        <xsl:variable name="allLanguages"
                      select="concat($metadataLanguage, ',', $metadataOtherLanguages)"></xsl:variable>

        <xsl:variable name="thesaurusTitleToDisplay">
          <xsl:choose>
            <xsl:when test="contains($thesaurusIdentifier, 'EC_')">
              <xsl:value-of select="/root/gui/schemas/iso19139.ca.HNAP/strings/*[name() = $thesaurusIdentifier]" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$thesaurusTitle" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>



        <xsl:variable name="isMandatory">
          <xsl:choose>
            <xsl:when test="contains($thesaurusIdentifier, 'EC_Information_Category') or
                            contains($thesaurusIdentifier, 'EC_Geographic_Scope') or
                            contains($thesaurusIdentifier, 'EC_Core_Subject')">true</xsl:when>
            <xsl:otherwise>false</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <!-- $thesaurusIdentifier add label for keywords in Information Classification panel -->
        <div data-gn-keyword-selector="{$widgetMode}"
             data-metadata-id="{$metadataId}"
             data-element-ref="{concat('_X', ../gn:element/@ref, '_replace')}"
             data-parent-element-ref="{gmd:keyword[1]/gn:element/@ref}"
             data-thesaurus-title="{if ($thesaurusConfig/@fieldset = 'false' or contains($thesaurusIdentifier, 'EC_')) then $thesaurusTitleToDisplay else ''}"
             data-thesaurus-key="{$thesaurusKey}"
             data-mandatory="{$isMandatory}"
             data-keywords="{$keywords}"
             data-transformations="{$transformations}"
             data-current-transformation="{$transformation}"
             data-max-tags="{$maxTags}"
             data-lang="{$metadataOtherLanguagesAsJson}"
             data-textgroup-only="false">
        </div>

        <!-- TODO: To check for ECCC -->
        <!--<xsl:variable name="isTypePlace"
                      select="count(gmd:type/gmd:MD_KeywordTypeCode[@codeListValue='place']) > 0"/>
        <xsl:if test="$isTypePlace">
          <xsl:call-template name="render-batch-process-button">
            <xsl:with-param name="process-name" select="'add-extent-from-geokeywords'"/>
            <xsl:with-param name="process-params">{"replace": true}</xsl:with-param>
          </xsl:call-template>
        </xsl:if>-->

        <div class="col-sm-offset-2 col-sm-9">
          <!--<xsl:call-template name="get-errors-2">
            <xsl:with-param name="refToUse" select="gmd:keyword[1]/gn:element/@ref" />
          </xsl:call-template>-->
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="mode-iso19139" select="*"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>


  <xsl:template mode="mode-iso19139" match="gmd:EX_BoundingPolygon[$schema = 'iso19139.ca.HNAP']" priority="5000">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="labelConfig" select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)"/>

    <xsl:call-template name="render-boxed-element">
      <xsl:with-param name="label"
                      select="$labelConfig/label"/>
      <xsl:with-param name="editInfo" select="../gn:element"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="subTreeSnippet">

        <xsl:variable name="geometry">
          <xsl:apply-templates select="gmd:polygon/gml:MultiSurface|gmd:polygon/gml:LineString|gmd:polygon/gml:Polygon"
                               mode="gn-element-cleaner"/>
        </xsl:variable>

        <xsl:variable name="identifier"
                      select="concat('_X', gmd:polygon/gn:element/@ref, '_replace')"/>
        <xsl:variable name="readonly" select="ancestor-or-self::node()[@xlink:href] != ''"/>

        <br />
        <gn-bounding-polygon polygon-xml="{saxon:serialize($geometry, 'default-serialize-mode')}"
                             identifier="{$identifier}"
                             read-only="{$readonly}">
        </gn-bounding-polygon>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>



  <!-- Rendering date type as a dropdown to select type
  and the calendar next to it.
  -->
  <xsl:template mode="mode-iso19139"
                priority="2005"
                match="gmd:CI_Date/gmd:date[$schema = 'iso19139.ca.HNAP']">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="listOfValues" select="$codelists" required="no"/>
    <xsl:param name="overrideLabel" select="''" required="no"/>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="tooltip" select="concat($schema, '|', name(.), '|', name(..), '|', $xpath)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="labelConfig"
                  select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)"/>
    <xsl:variable name="dateTypeElementRef"
                  select="../gn:element/@ref"/>

    <div class="form-group gn-field gn-date gn-required"
         id="gn-el-{$dateTypeElementRef}"
         data-gn-field-highlight="">
      <label class="col-sm-2 control-label">
        <xsl:choose>
          <xsl:when test="$overrideLabel != ''">
            <xsl:value-of select="$overrideLabel"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$labelConfig/label"/>
          </xsl:otherwise>
        </xsl:choose>
      </label>
      <div class="col-sm-3 gn-value">
        <xsl:variable name="codelist"
                      select="gn-fn-metadata:getCodeListValues($schema,
                                'gmd:CI_DateTypeCode',
                                $listOfValues,
                                .)"/>
        <xsl:call-template name="render-codelist-as-select">
          <xsl:with-param name="listOfValues" select="$codelist"/>
          <xsl:with-param name="lang" select="$lang"/>
          <xsl:with-param name="isDisabled" select="ancestor-or-self::node()[@xlink:href]"/>
          <xsl:with-param name="elementRef"
                          select="../gmd:dateType/gmd:CI_DateTypeCode/gn:element/@ref"/>
          <xsl:with-param name="isRequired" select="true()"/>
          <xsl:with-param name="hidden" select="false()"/>
          <xsl:with-param name="valueToEdit"
                          select="../gmd:dateType/gmd:CI_DateTypeCode/@codeListValue"/>
          <xsl:with-param name="name"
                          select="concat(../gmd:dateType/gmd:CI_DateTypeCode/gn:element/@ref, '_codeListValue')"/>
        </xsl:call-template>


        <xsl:call-template name="render-form-field-control-move">
          <xsl:with-param name="elementEditInfo" select="../../gn:element"/>
          <xsl:with-param name="domeElementToMoveRef" select="$dateTypeElementRef"/>
        </xsl:call-template>
      </div>
      <div class="col-sm-6 gn-value">
        <div data-gn-date-picker="{gco:Date|gco:DateTime}"
             data-gn-field-tooltip="{$tooltip}"
             data-label=""
             data-element-name="{name(gco:Date|gco:DateTime)}"
             data-element-ref="{concat('_X', gn:element/@ref)}"
             data-hide-date-mode="true"
             data-hide-time="{not(gco:DateTime)}">
        </div>


        <!-- Create form for all existing attribute (not in gn namespace)
         and all non existing attributes not already present. -->
        <div class="well well-sm gn-attr {if ($isDisplayingAttributes = true()) then '' else 'hidden'}">
          <xsl:apply-templates mode="render-for-field-for-attribute"
                               select="
          ../../@*|
          ../../gn:attribute[not(@name = parent::node()/@*/name())]">
            <xsl:with-param name="ref" select="../../gn:element/@ref"/>
            <xsl:with-param name="insertRef" select="../gn:element/@ref"/>
          </xsl:apply-templates>
        </div>


      </div>
      <div class="col-sm-1 gn-control">
        <xsl:call-template name="render-form-field-control-remove">
          <xsl:with-param name="editInfo" select="../gn:element"/>
          <xsl:with-param name="parentEditInfo" select="../../gn:element"/>
        </xsl:call-template>
      </div>

      <div class="col-sm-offset-2 col-sm-9">
        <xsl:call-template name="get-errors"/>
      </div>
    </div>
  </xsl:template>

  <!-- Readonly language in flat mode - changing the language may cause issues with the locale so disabling it on basic view. -->
  <xsl:template mode="mode-iso19139" priority="2100" match="//gmd:MD_Metadata/gmd:language[$isFlatMode and $schema = 'iso19139.ca.HNAP']">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="overrideLabel" select="''" required="no"/>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="fieldLabelConfig"
                  select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)"/>

    <xsl:variable name="labelConfig">
      <xsl:choose>
        <xsl:when test="$overrideLabel != ''">
          <element>
            <label><xsl:value-of select="$overrideLabel"/></label>
          </element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$fieldLabelConfig"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>


    <xsl:call-template name="render-element">
      <xsl:with-param name="label"
                      select="$labelConfig/*"/>
      <xsl:with-param name="value" select="*"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="$xpath"/>
      <xsl:with-param name="type" select="gn-fn-metadata:getFieldType($editorConfig, name(), '', $xpath)"/>
      <xsl:with-param name="name" select="''"/>
      <xsl:with-param name="editInfo" select="*/gn:element"/>
      <xsl:with-param name="parentEditInfo" select="gn:element"/>
      <xsl:with-param name="isDisabled" select="true()"/>
    </xsl:call-template>

  </xsl:template>

</xsl:stylesheet>
