<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:gn="http://www.fao.org/geonetwork"
                xmlns:gn-fn-core="http://geonetwork-opensource.org/xsl/functions/core"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:ns2="http://www.w3.org/2004/02/skos/core#"
                xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="#all">

  <xsl:variable name="thesauriDir" select="/root/gui/thesaurusDir" />
  <xsl:variable name="resourceFormatsTh" select="document(concat('file:///', replace(concat($thesauriDir, '/local/thesauri/theme/EC_Resource_Formats.rdf'), '\\', '/')))" />


  <!-- Hide thesaurus name in default view -->
  <xsl:template mode="mode-iso19139" priority="2005" match="gmd:thesaurusName[$tab='default']" />

  <!-- Hide protocol for contacts in default view -->
  <xsl:template mode="mode-iso19139" priority="2005" match="gmd:protocol[$tab='default']" />


  <!-- ===================================================================== -->
  <!-- gml:TimePeriod (format = %Y-%m-%dThh:mm:ss) -->
  <!-- ===================================================================== -->
  <xsl:template mode="mode-iso19139" match="gml:beginPosition[$schema='iso19139.nap']|gml:endPosition[$schema='iso19139.nap']|gml:timePosition[$schema='iso19139.nap']"
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


    <xsl:call-template name="render-element">
      <xsl:with-param name="label"
                      select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), '', $xpath)/label"/>
      <xsl:with-param name="name" select="gn:element/@ref"/>
      <xsl:with-param name="value" select="text()"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="$xpath"/>
      <!--
          Default field type is Date.
          TODO : Add the capability to edit those elements as:
           * xs:time
           * xs:dateTime
           * xs:anyURI
           * xs:decimal
           * gml:CalDate
          See http://trac.osgeo.org/geonetwork/ticket/661
        -->
      <xsl:with-param name="type"
                      select="if (string-length($value) = 10 or $value = '') then 'date' else 'datetime'"/>
      <xsl:with-param name="editInfo" select="gn:element"/>
      <xsl:with-param name="attributesSnippet" select="$attributes"/>
    </xsl:call-template>
    </xsl:template>

            <!-- Readonly elements -->
    <xsl:template mode="mode-iso19139" priority="2005" match="gmd:fileIdentifier|gmd:dateStamp">
    <xsl:call-template name="render-element">
      <xsl:with-param name="label"
                      select="gn-fn-metadata:getLabel($schema, name(), $labels)"/>
      <xsl:with-param name="value" select="*"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="gn-fn-metadata:getXPath(.)"/>
      <xsl:with-param name="type" select="gn-fn-metadata:getFieldType($editorConfig, name(), '')"/>
      <xsl:with-param name="name" select="''"/>
      <xsl:with-param name="editInfo" select="*/gn:element"/>
      <xsl:with-param name="parentEditInfo" select="gn:element"/>
      <xsl:with-param name="isDisabled" select="true()"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template mode="mode-iso19139" match="gmd:organisationName" priority="2000">

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="labelConfig" select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)"/>

   <xsl:variable name="theElement" select="." />

    <xsl:variable name="values">
      <values>
        <!-- Or the PT_FreeText element matching the main language -->
        <xsl:if test="gco:CharacterString">
          <xsl:message>V: <xsl:value-of select="gco:CharacterString" /></xsl:message>
          <value ref="{gco:CharacterString/gn:element/@ref}" lang="{$metadataLanguage}">
            <xsl:value-of select="gco:CharacterString"/>
          </value>
          <xsl:message>value main: <xsl:value-of select="gco:CharacterString" /> - <xsl:value-of select="gco:CharacterString/gn:element/@ref" /></xsl:message>
        </xsl:if>

        <!-- the existing translation -->
        <xsl:for-each select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString">
          <value ref="{gn:element/@ref}" lang="{substring-after(@locale, '#')}">
            <xsl:value-of select="."/>
          </value>
          <xsl:message>value alt 1:  <xsl:value-of select="." /> - <xsl:value-of select="gn:element/@ref" /> <xsl:value-of select="substring-after(@locale, '#')" /></xsl:message>
        </xsl:for-each>

        <!-- and create field for none translated language -->
        <xsl:for-each select="$metadataOtherLanguages/lang">
          <xsl:variable name="currentLanguageId" select="@id"/>
          <xsl:if test="count($theElement/
                gmd:PT_FreeText/gmd:textGroup/
                gmd:LocalisedCharacterString[@locale = concat('#',$currentLanguageId)]) = 0">
            <value ref="lang_{@id}_{$theElement/parent::node()/gn:element/@ref}"
                   lang="{@id}"></value>

            <xsl:message>value alt 1: <xsl:value-of select="$theElement/parent::node()/gn:element/@ref" /> <xsl:value-of select="@id" /></xsl:message>

          </xsl:if>
        </xsl:for-each>
      </values>
    </xsl:variable>

    <xsl:call-template name="render-element">
      <xsl:with-param name="label"
                      select="$labelConfig"/>
      <xsl:with-param name="value" select="$values"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="$xpath"/>
      <xsl:with-param name="directive" select="'gn-organisation-entry-selector-ec'"/>
      <xsl:with-param name="editInfo" select="gn:element"/>
      <xsl:with-param name="parentEditInfo" select="../gn:element"/>
    </xsl:call-template>

  </xsl:template>


  <xsl:template mode="mode-iso19139" match="gmd:country" priority="2000">

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="labelConfig" select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)"/>

    <xsl:variable name="theElement" select="." />

    <xsl:variable name="values">
      <values>
        <!-- Or the PT_FreeText element matching the main language -->
        <xsl:if test="gco:CharacterString">
          <xsl:message>V: <xsl:value-of select="gco:CharacterString" /></xsl:message>
          <value ref="{gco:CharacterString/gn:element/@ref}" lang="{$metadataLanguage}">
            <xsl:value-of select="gco:CharacterString"/>
          </value>
          <xsl:message>value main: <xsl:value-of select="gco:CharacterString" /> - <xsl:value-of select="gco:CharacterString/gn:element/@ref" /></xsl:message>
        </xsl:if>

        <!-- the existing translation -->
        <xsl:for-each select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString">
          <value ref="{gn:element/@ref}" lang="{substring-after(@locale, '#')}">
            <xsl:value-of select="."/>
          </value>
          <xsl:message>value alt 1:  <xsl:value-of select="." /> - <xsl:value-of select="gn:element/@ref" /> <xsl:value-of select="substring-after(@locale, '#')" /></xsl:message>
        </xsl:for-each>

        <!-- and create field for none translated language -->
        <xsl:for-each select="$metadataOtherLanguages/lang">
          <xsl:variable name="currentLanguageId" select="@id"/>
          <xsl:if test="count($theElement/
                gmd:PT_FreeText/gmd:textGroup/
                gmd:LocalisedCharacterString[@locale = concat('#',$currentLanguageId)]) = 0">
            <value ref="lang_{@id}_{$theElement/parent::node()/gn:element/@ref}"
                   lang="{@id}"></value>

            <xsl:message>value alt 1: <xsl:value-of select="$theElement/parent::node()/gn:element/@ref" /> <xsl:value-of select="@id" /></xsl:message>

          </xsl:if>
        </xsl:for-each>
      </values>
    </xsl:variable>

    <xsl:call-template name="render-element">
      <xsl:with-param name="label"
                      select="$labelConfig"/>
      <xsl:with-param name="value" select="$values"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="$xpath"/>
      <xsl:with-param name="directive" select="'gn-country-selector-ec'"/>
      <xsl:with-param name="editInfo" select="gn:element"/>
      <xsl:with-param name="parentEditInfo" select="../gn:element"/>
    </xsl:call-template>

  </xsl:template>

  <xsl:template mode="mode-iso19139" match="gmd:administrativeArea" priority="2000">

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="labelConfig" select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)"/>

    <xsl:variable name="theElement" select="." />

    <xsl:variable name="values">
      <values>
        <!-- Or the PT_FreeText element matching the main language -->
        <xsl:if test="gco:CharacterString">
          <xsl:message>V: <xsl:value-of select="gco:CharacterString" /></xsl:message>
          <value ref="{gco:CharacterString/gn:element/@ref}" lang="{$metadataLanguage}">
            <xsl:value-of select="gco:CharacterString"/>
          </value>
          <xsl:message>value main: <xsl:value-of select="gco:CharacterString" /> - <xsl:value-of select="gco:CharacterString/gn:element/@ref" /></xsl:message>
        </xsl:if>

        <!-- the existing translation -->
        <xsl:for-each select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString">
          <value ref="{gn:element/@ref}" lang="{substring-after(@locale, '#')}">
            <xsl:value-of select="."/>
          </value>
          <xsl:message>value alt 1:  <xsl:value-of select="." /> - <xsl:value-of select="gn:element/@ref" /> <xsl:value-of select="substring-after(@locale, '#')" /></xsl:message>
        </xsl:for-each>

        <!-- and create field for none translated language -->
        <xsl:for-each select="$metadataOtherLanguages/lang">
          <xsl:variable name="currentLanguageId" select="@id"/>
          <xsl:if test="count($theElement/
                gmd:PT_FreeText/gmd:textGroup/
                gmd:LocalisedCharacterString[@locale = concat('#',$currentLanguageId)]) = 0">
            <value ref="lang_{@id}_{$theElement/parent::node()/gn:element/@ref}"
                   lang="{@id}"></value>

            <xsl:message>value alt 1: <xsl:value-of select="$theElement/parent::node()/gn:element/@ref" /> <xsl:value-of select="@id" /></xsl:message>

          </xsl:if>
        </xsl:for-each>
      </values>
    </xsl:variable>

    <xsl:call-template name="render-element">
      <xsl:with-param name="label"
                      select="$labelConfig"/>
      <xsl:with-param name="value" select="$values"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="$xpath"/>
      <xsl:with-param name="directive" select="'gn-state-selector-ec'"/>
      <xsl:with-param name="editInfo" select="gn:element"/>
      <xsl:with-param name="parentEditInfo" select="../gn:element"/>
    </xsl:call-template>

  </xsl:template>


  <!-- Distribution format: Show list of allowed formats -->
  <xsl:template mode="mode-iso19139" match="//gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat/gmd:MD_Format/gmd:name" priority="2005">
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
            <code><xsl:value-of select="ns2:prefLabel[@xml:lang='en']" /></code>
            <label> <xsl:value-of select="ns2:prefLabel[@xml:lang='en']" /></label>
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
                      select="*/gn:element/@ref"/>
      <xsl:with-param name="editInfo" select="*/gn:element"/>
      <xsl:with-param name="parentEditInfo" select="gn:element"/>
      <xsl:with-param name="listOfValues"
                      select="$listOfValues/entries"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="mode-iso19139" match="gmd:EX_GeographicBoundingBox" priority="2005">
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

        <xsl:variable name="identifier"
                      select="../following-sibling::gmd:geographicElement[1]/gmd:EX_GeographicDescription/
                                  gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/(gmx:Anchor|gco:CharacterString)"/>
        <xsl:variable name="description"
                      select="../preceding-sibling::gmd:description/gco:CharacterString"/>
        <div gn-draw-bbox-wet=""
             data-hleft="{gmd:westBoundLongitude/gco:Decimal}"
             data-hright="{gmd:eastBoundLongitude/gco:Decimal}"
             data-hbottom="{gmd:southBoundLatitude/gco:Decimal}"
             data-htop="{gmd:northBoundLatitude/gco:Decimal}"
             data-hleft-ref="_{gmd:westBoundLongitude/gco:Decimal/gn:element/@ref}"
             data-hright-ref="_{gmd:eastBoundLongitude/gco:Decimal/gn:element/@ref}"
             data-hbottom-ref="_{gmd:southBoundLatitude/gco:Decimal/gn:element/@ref}"
             data-htop-ref="_{gmd:northBoundLatitude/gco:Decimal/gn:element/@ref}"
             data-lang="lang">
          <xsl:if test="$identifier and $isFlatMode">
            <xsl:attribute name="data-identifier"
                           select="$identifier"/>
            <xsl:attribute name="data-identifier-ref"
                           select="concat('_', $identifier/gn:element/@ref)"/>
          </xsl:if>
          <xsl:if test="$description and $isFlatMode and not($metadataIsMultilingual)">
            <xsl:attribute name="data-description"
                           select="$description"/>
            <xsl:attribute name="data-description-ref"
                           select="concat('_', $description/gn:element/@ref)"/>
          </xsl:if>
        </div>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <xsl:template mode="mode-iso19139" priority="2005"
                match="gmd:linkage1111">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="overrideLabel" select="''" required="no"/>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="elementName" select="name()"/>

    <xsl:message>gmd:linkage ref: <xsl:copy-of select="*/gn:element" /></xsl:message>
    <xsl:message>gmd:linkage $xpath: <xsl:value-of select="$xpath" /></xsl:message>

    <xsl:call-template name="render-element">
      <xsl:with-param name="label"
                      select="if ($overrideLabel != '') then $overrideLabel else gn-fn-metadata:getLabel($schema, name(gmd:URL), $labels, name(), $isoType, $xpath)"/>
      <xsl:with-param name="value" select="gmd:URL"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="$xpath"/>
      <xsl:with-param name="name"
                      select="*/gn:element/@ref"/>
      <xsl:with-param name="editInfo" select="*/gn:element"/>

    </xsl:call-template>

  </xsl:template>
  <!-- Metadata resources template -->
  <xsl:template mode="mode-iso19139"  match="//gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions[1]" priority="2005" />
</xsl:stylesheet>
