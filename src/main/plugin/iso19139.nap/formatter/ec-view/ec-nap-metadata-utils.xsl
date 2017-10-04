<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:ns2="http://www.w3.org/2004/02/skos/core#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
                xmlns:gn-fn-render="http://geonetwork-opensource.org/xsl/functions/render"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:exslt="http://exslt.org/common"
                xmlns:saxon="http://saxon.sf.net/"
                version="2.0"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all">

  <xsl:template name="getUserLang">
    <xsl:choose>
      <xsl:when test="/root/lang='fra'">
        <xsl:text>fre</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>eng</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="parentCollection">
    <xsl:param name="schema"/>
    <xsl:param name="resources"/>
    <xsl:param name="theme"/>
    <xsl:param name="subtheme"/>

    <xsl:if test="count($resources/*) &gt; 0">
      <h3><xsl:value-of select="/root/schemas/iso19139.nap/strings/ParentCollection"/></h3>
      <xsl:for-each select="$resources">
        <!-- Sort first datasets -->
        <xsl:sort select="normalize-space(concat(geonet:info/schema, ' ', title))"/>

        <div class="relatedDatasets" id="rlds{position()}">
          <!-- hide records over 5, to make visible with more button -->
          <xsl:if test="position() &gt; 5"><xsl:attribute name="style" select="'display:none'"/></xsl:if>
          <div style="float:left"> <!-- todo: check here the schema for icon to display -->
            <img class="icon" align="bottom">
              <xsl:attribute name="src" select="concat(/root/gui/url,'/images/dataset.png')" />
              <xsl:attribute name="alt" select="concat('Dataset&#160;:',title)" />
              <xsl:attribute name="title" select="concat('Dataset&#160;:',title)" />
            </img>
            <!-- Response for related resources is different depending on the relation:
                * Child relation return a brief representation of metadata
                * Parent reprentation (and others) return the raw metadata
            -->


            <xsl:variable name="md">
              <xsl:apply-templates mode="brief" select="."/>
            </xsl:variable>
            <xsl:variable name="metadata" select="exslt:node-set($md)/*[1]"/>
            <!--<xsl:value-of select="$metadata/title" />-->
            <xsl:variable name="classificationFilter">
              <xsl:choose>
                <xsl:when test="$schema = 'iso19139.napec'">_classificationTheme=<xsl:value-of select="$theme" />&amp;_classificationSubtheme=<xsl:value-of select="$subtheme" />&amp;</xsl:when>
                <xsl:otherwise></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            &#160;<a href="search?_schema={$schema}&amp;{$classificationFilter}parentUuid={$metadata/geonet:info/uuid}" title="Search metadata in the collection {$metadata/title}"><xsl:value-of select="$metadata/title" /></a>

          </div>
          <div style="float:right">
            <a class="btn btn-default btn-sm" href="metadata/{/root/lang}/{geonet:info/uuid}"><xsl:value-of select="/root/schemas/iso19139.nap/strings/View"/></a>
          </div>
          <div style="clear:both"></div>
        </div>
      </xsl:for-each>

    </xsl:if>
  </xsl:template>

  <xsl:template name="relatedDatasets">
    <xsl:param name="schema"/>
    <xsl:param name="resources"/>

    <xsl:if test="count($resources/*) &gt; 0">
      <h3><xsl:value-of select="/root/schemas/iso19139.nap/strings/Relateddata"/> (<xsl:value-of select="count($resources)" />)</h3>
      <xsl:for-each select="$resources">
        <!-- Sort first datasets -->
        <xsl:sort select="normalize-space(concat(geonet:info/schema, ' ', title))"/>

        <div class="relatedDatasets" id="rlds{position()}">
          <!-- hide records over 5, to make visible with more button -->
          <xsl:if test="position() &gt; 5"><xsl:attribute name="style" select="'display:none'"/></xsl:if>
          <div style="float:left"> <!-- todo: check here the schema for icon to display -->
            <img class="icon" align="bottom">
              <xsl:choose>
                <xsl:when test="geonet:info/schema='sensorML'">
                  <xsl:attribute name="src" select="concat(/root/gui/url,'/images/monsite.png')" />
                  <xsl:attribute name="alt" select="concat('Monitoring Site:&#160;',title)" />
                  <xsl:attribute name="title" select="concat('Monitoring Site:&#160;',title)" />
                </xsl:when>
                <!-- <xsl:when test=""></xsl:when> todo hierarchy level -> test if service -->
                <xsl:otherwise>
                  <xsl:attribute name="src" select="concat(/root/gui/url,'/images/dataset.png')" />
                  <xsl:attribute name="alt" select="concat('Dataset&#160;:',title)" />
                  <xsl:attribute name="title" select="concat('Dataset&#160;:',title)" />
                </xsl:otherwise>
              </xsl:choose>
            </img>
            <!-- Response for related resources is different depending on the relation:
                * Child relation return a brief representation of metadata
                * Parent reprentation (and others) return the raw metadata
            -->
            <xsl:choose>
              <xsl:when test="name() != 'metadata'">
                <xsl:variable name="md">
                  <xsl:apply-templates mode="brief" select="."/>
                </xsl:variable>
                <xsl:variable name="metadata" select="exslt:node-set($md)/*[1]"/>
                <xsl:value-of select="$metadata/title" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="title" />
              </xsl:otherwise>
            </xsl:choose>

          </div>
          <div style="float:right">
            <a class="btn btn-default btn-sm" href="{/root/gui/url}/metadata/{/root/gui/language}/{geonet:info/uuid}"><xsl:value-of select="/root/gui/strings/View"/></a>
          </div>
          <div style="clear:both"></div>
        </div>
      </xsl:for-each>

      <xsl:if test="count($resources) &gt; 5">
        <a href="javascript:void(jQuery.each(jQuery('.relatedDatasets'),function(){{this.style.display='block'}}))" onclick="this.style.display='none'">
          <xsl:value-of select="concat((count($resources)-5),' ',/root/schemas/iso19139.nap/strings/more,'...')" /></a>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- Create a div with class name set to extentViewer in
        order to generate a new map.  -->

  <xsl:template name="showPanel">
    <xsl:param name="title" select="''" />
    <xsl:param name="content" />
    <xsl:param name="style" select="''" /> <!-- can be '', success, info, warning, danger-->
    <div class="list-group">
      <xsl:if test="$title!=''">
        <xsl:variable name="titlestyle"><xsl:choose>
          <xsl:when test="$style=''">active</xsl:when>
          <xsl:otherwise>list-group-item-<xsl:value-of select="$style"/></xsl:otherwise>
        </xsl:choose></xsl:variable>
        <div class="list-group-item {$titlestyle}"><xsl:copy-of select="$title"/></div>
      </xsl:if>
      <div class="list-group-item"><xsl:copy-of select="$content"/></div>
    </div>
  </xsl:template>


  <!-- show metadata export icons eg. in search results or metadata viewer -->
  <xsl:template name="showMetadataExportIcons">
    <xsl:param name="info" />

    <xsl:variable name="muuid" select="$info/uuid"/>
    <xsl:variable name="workspace" select="string($info/workspace)"/>

    <!-- add xml link -->
    <!--<xsl:variable name="mdDownloadLink">
      <xsl:choose>
        <xsl:when test="/root/gui/env/platform/appMode = 'fgp'">xml.metadata.download</xsl:when>
        <xsl:otherwise>xml.metadata.get</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>-->

    <!--<xsl:variable name="xmlUrl" select="concat($url,'/', normalize-space($mdDownloadLink), '?uuid=',$muuid, '&amp;fromWorkspace=', $workspace)"/>-->
    <xsl:variable name="xmlUrl" select="concat($nodeUrl, 'api/records/', $muuid, '/formatters/xml')"/>
    <a href="#" onclick="downloadXml('{$xmlUrl}', '{$muuid}'); return false;" title="{/root/gui/strings/downloadas} XML" class="btn btn-default btn-md mrgn-rght-sm">
      <xsl:if test="/root/gui/env/platform/appMode != 'fgp'">
        <xsl:attribute name="target">_blank</xsl:attribute>
      </xsl:if>

      <img src="{/root/gui/url}/images/xml.png" alt="{/root/gui/strings/downloadas} XML" title="{/root/gui/strings/downloadas} XML" />
    </a>

    <!-- add pdf link -->
    <!--<xsl:variable name="pdfUrl" select="concat($url,'/rest.pdf?uuid=',$muuid, '&amp;fromWorkspace=', $workspace)"/>-->
    <xsl:variable name="pdfUrl" select="concat($nodeUrl, 'api/records/', $muuid, '/formatters/xsl-view?root=div&amp;output=pdf')"/>
    <a href="{$pdfUrl}" title="{/root/gui/strings/downloadas} PDF" class="btn btn-default btn-md" target="_blank">
      <img src="{/root/gui/url}/images/pdf_small.gif" alt="{/root/gui/strings/downloadas} PDF" title="{/root/gui/strings/downloadas} PDF" />
    </a>
  </xsl:template>


  <xsl:template name="ratingStars">
    <xsl:param name="fill" select="false()"/>
    <xsl:param name="count" select="1"/>

    <xsl:if test="$count > 0">
      <span>
        <xsl:attribute name="class">
          <xsl:choose>
            <xsl:when test="$fill = true()">fa fa-star fa-fw</xsl:when>
            <xsl:otherwise>fa fa-star-o fa-fw</xsl:otherwise>
          </xsl:choose>

        </xsl:attribute>
      </span>
      <xsl:call-template name="ratingStars">
        <xsl:with-param name="fill" select="$fill"/>
        <xsl:with-param name="count" select="$count - 1"/>
      </xsl:call-template>
    </xsl:if>

  </xsl:template>


  <!-- Template to display the Add Map Cart button in metadata detail page -->
  <xsl:template match="*" mode="showAddMapCart" priority="100">
    <xsl:variable name="isoLang">
      <xsl:choose>
        <xsl:when test="/root/lang='eng'">
          <xsl:text>urn:xml:lang:eng-CAN</xsl:text>
        </xsl:when>
        <xsl:when test="/root/lang='fre'">
          <xsl:text>urn:xml:lang:fra-CAN</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>


    <xsl:variable name="langId">
      <xsl:call-template name="getLangId">
        <xsl:with-param name="langGui" select="/root/lang" />
        <xsl:with-param name="md"
                        select="ancestor-or-self::*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="langId2" select="substring($langId, 2)" />

    <!-- Resources -->
    <xsl:variable name="webMapServicesProtocols" select="/root/gui/webServiceTypes" />

    <xsl:variable name="mapResourcesCount" select="count( /root/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role=$isoLang]/gmd:CI_OnlineResource[lower-case(normalize-space(gmd:protocol/gco:CharacterString))=$webMapServicesProtocols/record/name])"/>
    <xsl:variable name="resourcesCount" select="count( /root/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine)"/>
    <xsl:variable name="mapResourcesTotalCount" select="count( /root/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[lower-case(normalize-space(gmd:protocol/gco:CharacterString))=$webMapServicesProtocols/record/name])"/>

    <xsl:if test="$mapResourcesCount > 0">
      <xsl:variable name="esriRestValue">esri rest: map service</xsl:variable>
      <xsl:variable name="hasRESTService" select="count(/root/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[lower-case(normalize-space(gmd:protocol/gco:CharacterString))=$esriRestValue]) &gt; 0"/>

      <xsl:for-each-group select="/root/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/
                                    gmd:MD_DigitalTransferOptions/gmd:onLine/
                                    gmd:CI_OnlineResource[lower-case(normalize-space(gmd:protocol/gco:CharacterString))=$webMapServicesProtocols/record/name]"
                          group-by="lower-case(normalize-space(gmd:protocol/gco:CharacterString))">

        <xsl:message>position: <xsl:value-of select="position()" /></xsl:message>

        <xsl:for-each select="current-group()">
          <xsl:sort select="gmd:protocol/gco:CharacterString" order="descending" />

          <xsl:if test="position() = 1">
            <xsl:variable name="urlValue" select="normalize-space(gmd:linkage/gmd:URL)" />

            <xsl:variable name="nameValue">
              <xsl:for-each select="gmd:name">
                <xsl:call-template name="localised">
                  <xsl:with-param name="langId" select="$langId"/>
                </xsl:call-template>
              </xsl:for-each>
            </xsl:variable>

            <xsl:variable name="descriptionValue">
              <xsl:for-each select="gmd:description">
                <xsl:call-template name="localised">
                  <xsl:with-param name="langId" select="$langId"/>
                </xsl:call-template>
              </xsl:for-each>
            </xsl:variable>



            <xsl:variable name="p" select="lower-case(normalize-space(gmd:protocol/gco:CharacterString))" />

            <!-- TODO: Update condition -->
            <!--<xsl:if test="(/root/gmd:MD_Metadata/geonet:info/disabledMapServices = 'false' or not(/root/gmd:MD_Metadata/geonet:info/disabledMapServices)) and
                          (((/root/gmd:MD_Metadata/geonet:info/rcs_protocol_registered != '-1') and ($webMapServicesProtocols/record[name = $p]/id = /root/gmd:MD_Metadata/geonet:info/rcs_protocol_registered)) or
                           ((/root/gmd:MD_Metadata/geonet:info/rcs_protocol_registered = '-1') and ((lower-case(gmd:protocol/gco:CharacterString) = $esriRestValue) or
                           (not($hasRESTService) and lower-case(gmd:protocol/gco:CharacterString) = 'ogc:wms'))))">-->
            <xsl:if test="((lower-case(gmd:protocol/gco:CharacterString) = $esriRestValue) or
                         (not($hasRESTService) and lower-case(gmd:protocol/gco:CharacterString) = 'ogc:wms'))">

              <xsl:variable name="sq">'</xsl:variable>
              <xsl:variable name="tsq">\\'</xsl:variable>
              <xsl:variable name="titleMap"><xsl:apply-templates select="/root/*/geonet:info/uuid" mode="getMetadataTitle" /></xsl:variable>
              <xsl:variable name="titleMapEscaped" select="replace($titleMap, $sq, $tsq)" />

              <!-- TODO: Update string -->
              <!--<xsl:variable name="maxPreviewLayers" select="/root/gui/env/publication/mapviewer/maxlayersmappreview" />-->
              <xsl:variable name="maxPreviewLayers" select="'Preview %1 layers'" />
              <xsl:variable name="mapPreviewLayersMsg" select="replace(/root/gui/strings/maxpreviewlayers, '%1', $maxPreviewLayers)" />
              <xsl:variable name="mapPreviewLayersTitle" select="/root/gui/strings/map-preview/dialogtitle" />
              <xsl:variable name="mapPreviewLayersLayerAdd" select="/root/gui/strings/map-preview/dialoglayeradded" />
              <xsl:variable name="mapPreviewLayersLayerExists" select="/root/gui/strings/map-preview/dialoglayerexists" />


              <xsl:variable name="vm-smallkey">
                <xsl:choose>
                  <xsl:when test="/root/*/geonet:info/workspace = 'true' or /root/*/geonet:info/status = '1'">draft-<xsl:value-of select="normalize-space(/root/*/geonet:info/smallkey)" /></xsl:when>
                  <xsl:otherwise><xsl:value-of select="normalize-space(/root/*/geonet:info/smallkey)" /></xsl:otherwise>
                </xsl:choose>
              </xsl:variable>

              <xsl:variable name="map_url">
                <xsl:choose>
                  <xsl:when test="/root/lang = 'fre'"><xsl:value-of select="/root/gui/env/publication/mapviewer/viewonmap_fre" /></xsl:when>
                  <xsl:otherwise><xsl:value-of select="/root/gui/env/publication/mapviewer/viewonmap_eng" /></xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:variable name="newwindow">
                <xsl:choose>
                  <xsl:when test="/root/gui/env/platform/appMode = 'fgp'">false</xsl:when>
                  <xsl:otherwise>true</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>

              <!-- Add to map preview -->
              <a class="btn btn-default btn-sm mrgn-rght-sm" href="#" title="{/root/gui/strings/map_page/add2mapPreview_tooltip}">
                <xsl:attribute name="onclick">mappreview.addLayer('<xsl:value-of select="$urlValue" />','<xsl:value-of select="$titleMapEscaped" />','<xsl:value-of select="replace($nameValue, $sq, $tsq)" />',
                  '<xsl:value-of select="replace($descriptionValue, $sq, $tsq)" />','<xsl:value-of select="normalize-space(gmd:protocol)" />',
                  '<xsl:value-of select="normalize-space($vm-smallkey)" />', '<xsl:value-of select="$maxPreviewLayers" />',
                  '<xsl:value-of select="$mapPreviewLayersMsg" />',
                  '<xsl:value-of select="$mapPreviewLayersTitle" />', '<xsl:value-of select="$mapPreviewLayersLayerAdd" />',
                  '<xsl:value-of select="$mapPreviewLayersLayerExists" />'); return false;</xsl:attribute>
                <xsl:value-of select="/root/gui/strings/map_page/add2mapPreview"/>
              </a>
              &#160;
              <a href="#" onclick="map.view('{$map_url}', '{normalize-space($vm-smallkey)}', {$newwindow})" title="{/root/gui/strings/map_page/viewdatasetmap_tooltip}" class="btn btn-default envcan-icon"><span class="fa fa-globe fa-1-5x"></span>&#160;<span><xsl:value-of
                select="/root/gui/strings/map_page/viewdatasetmap" /></span></a>

            </xsl:if>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each-group>
    </xsl:if>
  </xsl:template>

  <!-- Most of the elements are ... -->
  <xsl:template mode="render-field"
                match="*[gco:CharacterString|gco:Integer|gco:Decimal|
       gco:Boolean|gco:Real|gco:Measure|gco:Length|gco:Distance|
       gco:Angle|gmx:FileName|
       gco:Scale|gco:Record|gco:RecordType|gmx:MimeFileType|gmd:URL|
       gco:LocalName|gmd:PT_FreeText|gml:beginPosition|gml:endPosition|
       gco:Date|gco:DateTime|*/@codeListValue]"
                priority="50">
    <xsl:param name="fieldName" select="''" as="xs:string"/>

    <dl>
      <dt>
        <xsl:value-of select="if ($fieldName)
                                then $fieldName
                                else tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <xsl:choose>
          <xsl:when test="*/@codeListValue">
            <xsl:apply-templates mode="render-value" select="*/@codeListValue"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="render-value" select="*"/>
          </xsl:otherwise>
        </xsl:choose>

        <!--<xsl:apply-templates mode="render-value" select="@*"/>-->
      </dd>
    </dl>
  </xsl:template>


  <xsl:template mode="render-field"
                match="*[gmd:PT_FreeText]"
                priority="100">

    <xsl:param name="fieldName" select="''" as="xs:string"/>

    <dl>
      <dt>
        <xsl:value-of select="if ($fieldName)
                                then $fieldName
                                else tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <xsl:apply-templates mode="localised" select=".">
          <xsl:with-param name="langId" select="$langForMetadata" />
        </xsl:apply-templates>

        <!--<xsl:apply-templates mode="render-value" select="@*"/>-->
      </dd>
    </dl>

  </xsl:template>

  <xsl:template mode="render-field"
                match="gmd:date[gmd:CI_Date]"
                priority="100">

    <xsl:param name="fieldName" select="''" as="xs:string"/>

    <dl>
      <dt>
        <xsl:value-of select="if ($fieldName)
                                then $fieldName
                                else tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <xsl:apply-templates mode="render-value" select="gmd:CI_Date/gmd:date"/>
        <xsl:if test="string(gmd:CI_Date/gmd:dateType/*/@codeListValue)" >
        (<xsl:apply-templates mode="render-value" select="gmd:CI_Date/gmd:dateType/*/@codeListValue"/>)
        </xsl:if>

        <!--<xsl:apply-templates mode="render-value" select="@*"/>-->
      </dd>
    </dl>

  </xsl:template>

  <!-- Block elements -->
  <xsl:template mode="render-field"
                match="gmd:resourceConstraints|gmd:referenceSystemInfo|gmd:distributionFormat"
                priority="100">

    <xsl:param name="fieldName" select="''" as="xs:string"/>

    <dl>
      <dt>
        <xsl:value-of select="if ($fieldName)
                                then $fieldName
                                else tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <xsl:apply-templates mode="render-field" select="*"/>
      </dd>
    </dl>

  </xsl:template>


  <xsl:template mode="render-field"
                match="gmd:language"
                priority="100">

    <xsl:param name="fieldName" select="''" as="xs:string"/>

    <dl>
      <dt>
        <xsl:value-of select="if ($fieldName)
                                then $fieldName
                                else tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <xsl:variable name="text">
          <xsl:choose>
            <xsl:when test="starts-with(gco:CharacterString, 'eng')">
              <xsl:value-of select="/root/schemas/*[name()=$schema]/strings/english"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="/root/schemas/*[name()=$schema]/strings/french"/>
            </xsl:otherwise>
          </xsl:choose>



          <!-- In view mode display other languages from gmd:locale of gmd:MD_Metadata element -->
          <xsl:if test="../gmd:locale or ../../gmd:locale">
            <xsl:text> (</xsl:text><xsl:value-of select="string(/root/schemas/*[name()=$schema]/labels/element[@name='gmd:locale' and not(@context)]/label)"/>
            <xsl:text>:</xsl:text>
            <xsl:for-each select="../gmd:locale|../../gmd:locale">
              <xsl:variable name="c" select="gmd:PT_Locale/gmd:languageCode/gmd:LanguageCode/@codeListValue"/>
              <xsl:choose>
                <xsl:when test="starts-with($c, 'eng')">
                  <xsl:value-of select="/root/schemas/*[name()=$schema]/strings/english"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="/root/schemas/*[name()=$schema]/strings/french"/>
                </xsl:otherwise>
              </xsl:choose>

              <xsl:if test="position()!=last()">, </xsl:if>
            </xsl:for-each><xsl:text>)</xsl:text>
          </xsl:if>
        </xsl:variable>

        <xsl:value-of select="$text" />

        <!--<xsl:apply-templates mode="render-value" select="@*"/>-->
      </dd>
    </dl>

  </xsl:template>

  <!-- Traverse the tree -->
  <xsl:template mode="render-field"
                match="*">
    <xsl:apply-templates mode="render-field"/>
  </xsl:template>

  <!-- ########################## -->
  <!-- Render values for text ... -->
  <xsl:template mode="render-value"
                match="gco:CharacterString|gco:Integer|gco:Decimal|
       gco:Boolean|gco:Real|gco:Measure|gco:Length|gco:Distance|gco:Angle|gmx:FileName|
       gco:Scale|gco:Record|gco:RecordType|gmx:MimeFileType|gmd:URL|
       gco:LocalName|gml:beginPosition|gml:endPosition">

    <xsl:choose>
      <xsl:when test="contains(., 'http')">
        <!-- Replace hyperlink in text by an hyperlink -->
        <xsl:variable name="textWithLinks"
                      select="replace(., '([a-z][\w-]+:/{1,3}[^\s()&gt;&lt;]+[^\s`!()\[\]{};:'&apos;&quot;.,&gt;&lt;?«»“”‘’])',
                                    '&lt;a href=''$1''&gt;$1&lt;/a&gt;')"/>

        <xsl:if test="$textWithLinks != ''">
          <xsl:copy-of select="saxon:parse(
                          concat('&lt;p&gt;',
                          replace($textWithLinks, '&amp;', '&amp;amp;'),
                          '&lt;/p&gt;'))"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- ... Codelists -->
  <xsl:template mode="render-value"
                match="@codeListValue" priority="2">

    <xsl:variable name="id" select="."/>
    <xsl:variable name="codelistTranslation"
                  select="tr:codelist-value-label(
                            tr:create($schema),
                            parent::node()/local-name(), $id)"/>
    <xsl:choose>
      <xsl:when test="$codelistTranslation != ''">

        <xsl:variable name="codelistDesc"
                      select="tr:codelist-value-desc(
                            tr:create($schema),
                            parent::node()/local-name(), $id)"/>
        <span title="{$codelistDesc}">
          <xsl:value-of select="$codelistTranslation"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gmd:PT_FreeText">
    <xsl:apply-templates mode="localised" select="../node()">
      <xsl:with-param name="langId" select="$langForMetadata"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- ... URL -->
  <xsl:template mode="render-value"
                match="gmd:URL">
    <a href="{.}">
      <xsl:value-of select="."/>
    </a>
  </xsl:template>

  <xsl:template mode="render-value"
                match="@*" />


  <xsl:template name="thumbnail">
    <xsl:param name="metadata"/>
    <xsl:param name="id"/>
    <xsl:param name="size">180</xsl:param>

    <xsl:variable name="langId" select="/root/gui/language" />

    <xsl:variable name="otherLangId">
      <xsl:choose>
        <xsl:when test="$langId = 'fre'">eng</xsl:when>
        <xsl:when test="$langId = 'eng'">fre</xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="im">
      <xsl:for-each select="$metadata//gmd:graphicOverview/gmd:MD_BrowseGraphic">
        <xsl:variable name="fileName"  select="gmd:fileName/gco:CharacterString"/>
        <xsl:if test="$fileName != ''">
          <xsl:variable name="fileDescr" select="gmd:fileDescription/gco:CharacterString"/>

          <xsl:choose>
            <!-- the thumbnail is an url -->
            <xsl:when test="contains($fileName ,'://')">
              <image type="unknown"><xsl:value-of select="$fileName"/></image>
            </xsl:when>
            <xsl:otherwise>
              <image type="thumbnail">
                <xsl:attribute name="lang">
                  <xsl:choose>
                    <xsl:when test="ends-with($fileDescr, '_fre')">fre</xsl:when>
                    <xsl:otherwise>eng</xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
                <xsl:value-of select="concat(/root/gui/locService,'/resources.get?id=',$id,'&amp;fname=',$fileName,'&amp;access=public')"/>
              </image>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="images" select="exslt:node-set($im)"/>

    <xsl:choose>
      <!-- small thumbnail -->
      <xsl:when test="$images/image[@type='thumbnail' and @lang=$langId]">

        <xsl:choose>

          <!-- large thumbnail link -->
          <xsl:when test="$images/image[@type='overview']">
            <a href="javascript:popWindow('{$images/image[@type='overview']}')">
              <img class="full-width" src="{$images/image[@type='thumbnail']}" alt="{/root/gui/strings/thumbnail}" onerror="this.src = '{/root/gui/url}/images/nopreview.png'"/>
            </a>
          </xsl:when>

          <!-- no large thumbnail -->
          <xsl:otherwise>
            <img class="full-width" src="{$images/image[@type='thumbnail' and @lang=$langId]}" alt="{/root/gui/strings/thumbnail}" onerror="this.src = '{/root/gui/url}/images/nopreview.png'"/>
          </xsl:otherwise>
        </xsl:choose>

      </xsl:when>

      <!-- small thumbnail other lang -->
      <xsl:when test="$images/image[@type='thumbnail' and @lang=$otherLangId]">

        <xsl:choose>

          <!-- large thumbnail link -->
          <xsl:when test="$images/image[@type='overview']">
            <a href="javascript:popWindow('{$images/image[@type='overview']}')">
              <img class="full-width" src="{$images/image[@type='thumbnail']}" alt="{/root/gui/strings/thumbnail}" onerror="this.src = '{/root/gui/url}/images/nopreview.png'"/>
            </a>
          </xsl:when>

          <!-- no large thumbnail -->
          <xsl:otherwise>
            <img class="full-width" src="{$images/image[@type='thumbnail' and @lang=$otherLangId]}" alt="{/root/gui/strings/thumbnail}" onerror="this.src = '{/root/gui/url}/images/nopreview.png'"/>
          </xsl:otherwise>
        </xsl:choose>

      </xsl:when>

      <!-- unknown thumbnail (usually a url so limit size) -->
      <xsl:when test="$images/image[@type='unknown']">
        <img class="full-width" src="{$images/image[@type='unknown']}" alt="{/root/gui/strings/thumbnail}" onerror="this.src = '{/root/gui/url}/images/nopreview.png'">
          <xsl:if test="string($size)">
            <xsl:attribute name="width"><xsl:value-of select="$size" /></xsl:attribute>
            <xsl:attribute name="height"><xsl:value-of select="$size" /></xsl:attribute>
          </xsl:if>
        </img>
      </xsl:when>

      <!-- papermaps thumbnail -->
      <!-- FIXME
            <xsl:when test="/root/gui/paperMap and string(dataIdInfo/idCitation/presForm/PresFormCd/@value)='mapHardcopy'">
                <a href="PAPERMAPS-URL">
                    <img src="{/root/gui/paperMap}" alt="{/root/gui/strings/paper}" title="{/root/gui/strings/paper}"/>
                </a>
            </xsl:when>
            -->

      <!-- no thumbnail -->
      <xsl:otherwise>
        <!-- then don't show! <img src="{/root/gui/locUrl}/images/nopreview.gif" alt="{/root/gui/strings/thumbnail}"/> -->
        <img class="full-width" src="{/root/gui/url}/images/nopreview.png" alt="{/root/gui/strings/thumbnail}"/>
      </xsl:otherwise>
    </xsl:choose>
    <br/>
  </xsl:template>

</xsl:stylesheet>
