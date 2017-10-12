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


  <!-- Hide thesaurus name -->
  <xsl:template mode="mode-iso19139" priority="2005" match="gmd:thesaurusName" />


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


  <!-- Metadata resources template -->
  <xsl:template mode="mode-iso19139"  match="//gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions[1]" priority="2005">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="codelists" select="$codelists" required="no"/>
    <xsl:param name="overrideLabel" select="''" required="no"/>

    <xsl:variable name="langId">
      <xsl:call-template name="getLangId">
        <xsl:with-param name="langGui" select="/root/gui/language" />
        <xsl:with-param name="md"
                        select="ancestor-or-self::*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']" />
      </xsl:call-template>
    </xsl:variable>

    <!-- TODO: Update -->
    <!--<xsl:variable name="webMapServicesProtocols" select="/root/gui/webServiceTypes" />-->
    <xsl:variable name="wm">
      <protocols>
        <record>
          <name>ogc:wms</name>
        </record>
      </protocols>
    </xsl:variable>

    <xsl:variable name="webMapServicesProtocols" select="$wm/protocols" />

    <div data-gn-hnap-onlinesrc-list=""></div>


    <div class="wb-inv">
      <!-- MAP RESOURCES -->
      <h4 title="{/root/gui/schemas/iso19139.nap/strings/MapResourcesDesc}">
        <span class="btn btn-success pull-right btn-xs" onclick="dataDepositMap.showAddMapServiceResource()">
          <span class="glyphicon glyphicon-plus"></span>&#160;<xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/AddMapServiceResource" /></span>
        <xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/MapResources" />
      </h4>

      <p><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/MapResourcesDesc" /></p>

      <table class="table table-striped" id="mapservice-resources-table" style="width:100%">
        <thead>
          <tr>
            <th style="min-width:10px"><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Dataresources_RCS" /></th>
            <th style="min-width:100px"><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Dataresources_Service" /></th>
            <th style="min-width:100px"><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Dataresources_Layer" /></th>
            <th style="min-width:100px"><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Dataresources_Description" /></th>
            <th style="min-width:100px"><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Dataresources_Protocol" /></th>
            <th style="min-width:100px"><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Dataresources_Language" /></th>
            <th style="min-width:120px">&#160;</th>
          </tr>
        </thead>

        <tbody>
          <!-- TODO: Update -->
          <xsl:variable name="rcs_protocol_preferred" select="'ogc:wms'" /> <!--select="/root/gmd:MD_Metadata/geonet:info/rcs_protocol_preferred" />-->
          <xsl:variable name="rcs_protocol_registered" select="'ogc:wms'" /> <!--select="/root/gmd:MD_Metadata/geonet:info/rcs_protocol_registered" />-->

          <xsl:for-each select="../gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[lower-case(normalize-space(gmd:protocol/gco:CharacterString)) = $webMapServicesProtocols/record/name]">
            <xsl:sort select="concat(gmd:protocol/gco:CharacterString, ../@xlink:role)" />

            <tr id="resource_{../@xlink:title}">
              <!-- Register RCS -->
              <td>
                <xsl:variable name="l" select="../@xlink:role" />
                <xsl:variable name="p" select="lower-case(normalize-space(gmd:protocol/gco:CharacterString))" />

                <xsl:if test="count(//root/gui/webServiceTypes/record[register_rcs = 'y' and name = $p]) = 1">
                  <input type="radio" value="{//root/gui/webServiceTypes/record[register_rcs = 'y' and name = $p]/id}" name="rcs_priority">

                    <xsl:choose>
                      <xsl:when test="$rcs_protocol_preferred = '-1' and $rcs_protocol_registered = '-1'">
                        <xsl:if test="//root/gui/webServiceTypes/record[register_rcs = 'y']/name = $p">
                          <xsl:attribute name="checked">checked</xsl:attribute>
                        </xsl:if>
                      </xsl:when>
                      <xsl:when test="$rcs_protocol_preferred = '-1' and $rcs_protocol_registered != '-1'">
                        <xsl:if test="//root/gui/webServiceTypes/record[register_rcs = 'y' and name = $p]/id = $rcs_protocol_registered">
                          <xsl:attribute name="checked">checked</xsl:attribute>
                        </xsl:if>
                      </xsl:when>
                      <xsl:when test="$rcs_protocol_preferred != '-1' and $rcs_protocol_registered = '-1'">
                        <xsl:if test="//root/gui/webServiceTypes/record[register_rcs = 'y' and name = $p]/id = $rcs_protocol_preferred">
                          <xsl:attribute name="checked">checked</xsl:attribute>
                        </xsl:if>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:if test="//root/gui/webServiceTypes/record[register_rcs = 'y' and name = $p]/id = $rcs_protocol_registered or
                                                    //root/gui/webServiceTypes/record[register_rcs = 'y' and name = $p]/id = $rcs_protocol_preferred">
                          <xsl:attribute name="checked">checked</xsl:attribute>
                        </xsl:if>
                      </xsl:otherwise>
                    </xsl:choose>
                  </input>
                </xsl:if>

              </td>
              <!-- Service -->
              <td>
                <xsl:variable name="serviceName">
                  <xsl:value-of select="gmd:linkage/gmd:URL" />
                </xsl:variable>

                <a target="_blank" title="{gmd:linkage/gmd:URL}" href="{gmd:linkage/gmd:URL}">
                  <xsl:choose>
                    <xsl:when test="string-length($serviceName) &gt; 20"><xsl:value-of select="substring($serviceName,1, 17)" />...</xsl:when>
                    <xsl:otherwise><xsl:value-of select="$serviceName" /></xsl:otherwise>
                  </xsl:choose>
                </a>

              </td>
              <!-- Name -->
              <td>
                <xsl:variable name="resourceName">
                  <xsl:for-each select="gmd:name">
                    <xsl:call-template name="localised">
                      <xsl:with-param name="langId" select="$langId"/>
                    </xsl:call-template>
                  </xsl:for-each>
                </xsl:variable>

                <xsl:value-of select="$resourceName" />
              </td>
              <!-- Description -->
              <td>
                <xsl:variable name="resourceDesc">
                  <xsl:for-each select="gmd:description">
                    <xsl:call-template name="localised">
                      <xsl:with-param name="langId" select="$langId"/>
                    </xsl:call-template>
                  </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="$resourceDesc" /></td>
              <!-- Protocol -->
              <td>
                <xsl:value-of select="gmd:protocol" />
              </td>
              <td>
                <xsl:choose>
                  <xsl:when test="../@xlink:role='urn:xml:lang:fra-CAN'">
                    <xsl:value-of select="'French'" />
                  </xsl:when>
                  <xsl:otherwise><xsl:value-of select="'English'" /></xsl:otherwise>
                </xsl:choose>
              </td>
              <td>

                <span role="button" class="btn btn-warning btn-xs"
                      onclick="if (noDoubleClick()) dataDepositMap.showEditMapServiceResource('{../@xlink:title}', '')">
                  <span class="glyphicon glyphicon-pencil"></span></span>&#160;
                <span role="button" class="btn btn-danger btn-xs"
                      onclick="if (noDoubleClick()) dataDepositMap.removeResource('{../@xlink:title}', '')" >
                  <span class="glyphicon glyphicon-remove"></span></span>

              </td>

            </tr>

          </xsl:for-each>
        </tbody>

      </table>


      <!-- DATA RESOURCES -->
      <h4 title="{/root/gui/schemas/iso19139.nap/strings/DataresourcesDesc}">
        <span role="button" class="btn btn-success pull-right btn-xs" onclick="onlinesrcService.onOpenPopup('hnap-onlinesrc')">
          <span class="glyphicon glyphicon-plus"></span>&#160;<xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/AddDataResource" /></span>
        <xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Dataresources" />
      </h4>
      <p><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/DataresourcesDesc" /></p>

      <table class="table table-striped" id="data-resources-table">
        <thead>
          <tr>
            <th><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Dataresources_Name" /></th>
            <th><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Dataresources_Description" /></th>
            <th><xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Dataresources_Protocol" /></th>
            <th style="min-width:120px">&#160;</th>
          </tr>
        </thead>
        <tbody>
          <xsl:for-each select="../gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource">
            <xsl:sort select="lower-case(gmd:name)" />
            <xsl:variable name="protocolValue">
              <xsl:value-of select="normalize-space(gmd:protocol/gco:CharacterString)" />
            </xsl:variable>

            <xsl:if test="not(string($webMapServicesProtocols/record[name = lower-case($protocolValue)]))">

              <xsl:variable name="urlVal" select="normalize-space(gmd:linkage/gmd:URL)" />
              <xsl:variable name="fileNameStageArea" select="normalize-space(translate(gmd:name, ' ', '_'))" />

              <xsl:variable name="titleId" select="../@xlink:title" />

              <tr id="resource_{../@xlink:title}">
                <!-- Name -->
                <td>
                  <xsl:variable name="fnameInUrl" select="substring-before(substring-after(gmd:linkage/gmd:URL, 'fname='), '&amp;')" />

                  <xsl:variable name="resourceName">
                    <xsl:for-each select="gmd:name">
                      <xsl:call-template name="localised">
                        <xsl:with-param name="langId" select="$langId"/>
                      </xsl:call-template>
                    </xsl:for-each>
                  </xsl:variable>

                  <a target="_blank" href="{gmd:linkage/gmd:URL}"><xsl:value-of select="$resourceName" /></a>
                </td>
                <!-- Description -->
                <td> <xsl:variable name="resourceDesc">
                  <xsl:for-each select="gmd:description">
                    <xsl:call-template name="localised">
                      <xsl:with-param name="langId" select="$langId"/>
                    </xsl:call-template>
                  </xsl:for-each>
                </xsl:variable>
                  <xsl:value-of select="$resourceDesc" /></td>

                <!-- Protocol -->
                <td>
                  <xsl:value-of select="gmd:protocol" />
                </td>
                <td>

                  <span role="button" class="btn btn-warning btn-xs"
                        onclick="if (noDoubleClick()) dataDeposit.showEditDataResourceFgp('{../@xlink:title}', '')">
                    <span class="glyphicon glyphicon-pencil"></span></span>&#160;
                  <span role="button" class="btn btn-danger btn-xs"
                        onclick="if (noDoubleClick()) dataDeposit.removeResourceFgp('{../@xlink:title}', '')" >
                    <span class="glyphicon glyphicon-remove"></span></span>
                </td>
              </tr>
            </xsl:if>
          </xsl:for-each>
        </tbody>
      </table>

    </div>
  </xsl:template>
</xsl:stylesheet>
