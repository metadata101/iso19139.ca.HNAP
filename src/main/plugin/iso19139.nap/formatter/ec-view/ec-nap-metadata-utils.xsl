<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gml="http://www.opengis.net/gml"
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

  <xsl:template name="showMap">
    <xsl:param name="edit" />
    <xsl:param name="coords"/>
    <!-- Indicate which drawing mode is used (ie. bbox or polygon) -->
    <xsl:param name="mode"/>

    <xsl:param name="crs" select="'4326'" />
    <xsl:param name="bbox"/>
    <xsl:param name="targetPolygon"/>
    <xsl:param name="watchedBbox"/>
    <xsl:param name="eltRef"/>
    <xsl:param name="width" select="/root/gui/config/map/metadata/width" />
    <xsl:param name="height" select="/root/gui/config/map/metadata/height" />
    <xsl:param name="schema" select ="''" />

    <xsl:choose>
      <xsl:when test="$edit=true()">
        <div id="map{$eltRef}" class="wb-geomap aoi" style="width:600px;height:780px;min-width:600px;min-height:780px"
             data-wb-geomap='{{
					"aoi": {{ "toggle": false, "extent": "{$bbox}" }}
					 }}'>
          <div class="wb-geomap-map" ></div>
          <input type="hidden" id="_{fn:tokenize($watchedBbox,'(,)')[1]}" class="w" name="_{fn:tokenize($watchedBbox,'(,)')[1]}" value="{fn:tokenize($bbox,'(,)')[1]}"/>
          <input type="hidden" id="_{fn:tokenize($watchedBbox,'(,)')[2]}" class="s" name="_{fn:tokenize($watchedBbox,'(,)')[2]}" value="{fn:tokenize($bbox,'(,)')[2]}"/>
          <input type="hidden" id="_{fn:tokenize($watchedBbox,'(,)')[4]}" class="e" name="_{fn:tokenize($watchedBbox,'(,)')[3]}" value="{fn:tokenize($bbox,'(,)')[3]}"/>
          <input type="hidden" id="_{fn:tokenize($watchedBbox,'(,)')[3]}" class="n" name="_{fn:tokenize($watchedBbox,'(,)')[4]}" value="{fn:tokenize($bbox,'(,)')[4]}"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$schema = 'sensorML'">
            <xsl:variable name="tmpCrs">
              <xsl:for-each select="/root/gui/rdf:ecSensorRefSystem/rdf:Description">
                <xsl:if test="./ns2:prefLabel[@xml:lang=fn:substring(/root/gui/language,1,2)] = $crs">
                  <xsl:value-of select="substring-after(substring-after(@rdf:about,'#'),':')"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>

            <xsl:variable name="finalCrs">
              <xsl:choose>
                <xsl:when test="$tmpCrs!=''">
                  <xsl:value-of select="$tmpCrs"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>4326</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <div id="AIOMap{$eltRef}" class="wb-geomap position" data-wb-geomap='{{ "tables": [ {{ "id": "aoi{$eltRef}" }} ],
                    "layersFile": "{/root/gui/url}/scripts/envcan/script/config-map-{$finalCrs}.js" }}'>
              <div class="wb-geomap-map" style="width:100%px;height:{$height};min-width:350px;min-height:{$height}"></div>
              <table id="aoi{$eltRef}" aria-label="Area of interest" style="display:none">
                <tr data-geometry="{$coords}" data-type="wkt"></tr>
              </table>
            </div>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="finalCrs">
              <xsl:choose>
                <xsl:when test="$crs!=''"><xsl:value-of select="$crs"/></xsl:when>
                <xsl:otherwise>4326</xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <div id="AIOMap{$eltRef}" class="wb-geomap" data-wb-geomap='{{ "tables": [ {{ "id": "aoi{$eltRef}" }} ]
                     }}'>
              <div class="wb-geomap-map" style="width:100%px;height:{$height};min-width:350px;min-height:{$height}"></div>
              <table id="aoi{$eltRef}" aria-label="Area of interest" style="display:none">
                <tr data-geometry="{$coords}" data-type="bbox"></tr>
              </table>
            </div>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


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
          <xsl:with-param name="langId" select="$language" />
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
      <xsl:with-param name="langId" select="$language"/>
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
</xsl:stylesheet>
