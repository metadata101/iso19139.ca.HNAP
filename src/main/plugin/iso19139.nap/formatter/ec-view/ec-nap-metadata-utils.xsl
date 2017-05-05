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
                xmlns:saxon="http://saxon.sf.net/"
                version="2.0"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all">

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

</xsl:stylesheet>
