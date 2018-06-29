<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:exslt="http://exslt.org/common"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:ns2="http://www.w3.org/2004/02/skos/core#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="gmx gts gmd gco gml geonet xlink rdf ns2 rdfs skos xs exslt fn"
                version="2.0">

  <!-- Redirect to iso19139 default layout -->
  <xsl:template name="metadata-fop-iso19139.nap">
    <xsl:param name="schema"/>

    <xsl:variable name="isoLang">
      <xsl:choose>
        <xsl:when test="/root/gui/language='eng'">
          <xsl:text>urn:xml:lang:eng-CAN</xsl:text>
        </xsl:when>
        <xsl:when test="/root/gui/language='fre'">
          <xsl:text>urn:xml:lang:fra-CAN</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>


    <xsl:variable name="langForMetadata">
      <xsl:call-template name="getLangForMetadata">
        <xsl:with-param name="uiLang" select="/root/gui/language" />
      </xsl:call-template>
    </xsl:variable>

    <fo:table-row>
      <fo:table-cell padding-left="4pt" padding-right="4pt" padding-top="4pt" margin-top="4pt" margin-right="8pt">
        <fo:block>

          <fo:table width="100%" table-layout="fixed">
            <fo:table-column column-width="5cm"/>
            <fo:table-column column-width="6.8cm"/>
            <fo:table-body>

              <!-- Abstract -->
              <fo:table-row>
                <fo:table-cell padding-left="4pt" padding-right="4pt" padding-top="4pt" margin-top="4pt"
                               number-columns-spanned="2">
                  <fo:block font-weight="bold" font-size="10pt" padding-top="4pt" padding-bottom="4pt"
                            padding-left="4pt" padding-right="4pt">
                    <xsl:value-of select="/root/gui/strings/description"/>
                  </fo:block>
                  <fo:block color="#2e456b">
                    <xsl:for-each select="/root/gmd:MD_Metadata//gmd:abstract">
                      <xsl:call-template name="localised">
                        <xsl:with-param name="langId"
                                        select="concat('#', $langForMetadata)"/>
                      </xsl:call-template>
                    </xsl:for-each>
                  </fo:block>
                </fo:table-cell>
              </fo:table-row>



              <!-- Bounding box -->
              <xsl:if test="(/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal!='') and number(/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal)!=0 and
                                  (/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal!='') and number(/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal)!=0 and
                                  (/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal!='') and number(/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal)!=0 and
                                  (/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal!='') and number(/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal)!=0">
                <xsl:call-template name="TRFop">
                  <xsl:with-param name="label">
                    <xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/GeographicExtent"/>
                  </xsl:with-param>
                  <xsl:with-param name="text">
                    <xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/sw"/>:<xsl:value-of
                    select="concat(format-number(/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal,'#.###'), ' ', format-number(/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal,'#.###'))"/>,
                    <xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/ne"/>:<xsl:value-of
                    select="concat(format-number(/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal,'#.###'), ' ', format-number(/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal,'#.###'))"/>
                  </xsl:with-param>
                </xsl:call-template>

              </xsl:if>
            </fo:table-body>
          </fo:table>

          <!-- Bounding box map -->
          <xsl:if test="(/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal!='') and number(/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal)!=0 and
                                  (/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal!='') and number(/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal)!=0 and
                                  (/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal!='') and number(/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal)!=0 and
                                  (/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal!='') and number(/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal)!=0">

            <fo:table width="100%" table-layout="fixed">
              <fo:table-column column-width="11.8cm"/>
              <fo:table-body>

                <xsl:variable name="minx" select="/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal"/>
                <xsl:variable name="miny" select="/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal"/>
                <xsl:variable name="maxx" select="/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal"/>
                <xsl:variable name="maxy" select="/root/gmd:MD_Metadata//gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal"/>
                <xsl:variable name="geom" select="concat('POLYGON%28%28', $minx, '%20', $miny,'%2C',$maxx,'%20',$miny,'%2C',$maxx,'%20',$maxy,'%2C',$minx,'%20',$maxy,'%2C',$minx,'%20',$miny, '%29%29')"/>

                <fo:table-row>
                  <fo:table-cell padding-left="4pt" padding-right="4pt" padding-top="4pt" margin-top="4pt">
                    <fo:block>
                      <fo:external-graphic content-width="300pt" alignment-adjust="baseline">
                        <xsl:attribute name="src">
                          <xsl:value-of
                            select="concat( //server/protocol, '://', //server/host,':', //server/port, /root/gui/url, '/srv/eng/region.getmap.png?mapsrs=EPSG:4326&amp;geom=', $geom, '&amp;geomsrs=EPSG:4326&amp;background=geogratis&amp;width=300')"
                          />

                        </xsl:attribute>
                      </fo:external-graphic>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>
              </fo:table-body>
            </fo:table>
          </xsl:if>


          <xsl:if test="/root/gmd:MD_Metadata/gmd:identificationInfo//gmd:extent/gmd:EX_Extent/gmd:temporalElement">
            <fo:table width="100%" table-layout="fixed">
              <fo:table-column column-width="5cm"/>
              <fo:table-column column-width="6.8cm"/>
              <fo:table-body>

                <!-- Time period -->
                <xsl:for-each
                  select="/root/gmd:MD_Metadata/gmd:identificationInfo//gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod">
                  <xsl:call-template name="TRFop">
                    <xsl:with-param name="label">
                      <xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Timeperiod"/>
                    </xsl:with-param>
                    <xsl:with-param name="text">
                      <xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/from"/>:<xsl:value-of select="gml:beginPosition"/> -
                      <xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/to"/>:<xsl:value-of select="gml:endPosition"/>
                    </xsl:with-param>
                  </xsl:call-template>
                </xsl:for-each>
              </fo:table-body>
            </fo:table>
          </xsl:if>

          <fo:block margin-top="8pt"/>


          <!-- Dataresources -->
          <xsl:if
            test="count(gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role=$isoLang]/gmd:CI_OnlineResource|gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[not(string(@xlink:role))]/gmd:CI_OnlineResource) != 0">
            <fo:block font-weight="bold" font-size="10pt" padding-top="4pt" padding-bottom="4pt" padding-left="4pt"
                      padding-right="4pt">
              <xsl:value-of select="/root/gui/strings/Dataresources"/>
            </fo:block>


            <xsl:for-each
              select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role=$isoLang]/gmd:CI_OnlineResource|gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[not(string(@xlink:role))]/gmd:CI_OnlineResource">
              <xsl:if test="normalize-space(gmd:linkage/gmd:URL)!=''">
                <fo:block padding-left="4pt" padding-right="4pt" padding-top="4pt" margin-top="4pt">
                  <fo:basic-link>
                    <xsl:attribute name="external-destination">url('<xsl:value-of select="gmd:linkage/gmd:URL"/>')
                    </xsl:attribute>
                    <fo:inline text-decoration="underline">
                      <xsl:choose>
                        <xsl:when test="normalize-space(gmd:name)!=''">
                          <xsl:value-of select="gmd:name"/>
                        </xsl:when>
                        <xsl:when test="normalize-space(gmd:description)!=''">
                          <xsl:value-of select="gmd:description"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="gmd:linkage/gmd:URL"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </fo:inline>
                  </fo:basic-link>

                </fo:block>

              </xsl:if>
            </xsl:for-each>
            <fo:block margin-top="8pt"/>
          </xsl:if>

          <!-- Relateddata -->

          <!-- Products -->
          <xsl:if
            test="count((/root/gui/relation/services/response/*[geonet:info]|/root/gui/relation/children/response/*[geonet:info]|/root/gui/relation/related/response/*[geonet:info])) != 0">
            <fo:block font-weight="bold" font-size="10pt" padding-top="4pt" padding-bottom="4pt" padding-left="4pt"
                      padding-right="4pt">
              <xsl:value-of select="/root/gui/strings/Relateddata"/>
            </fo:block>
            <!-- this will work for display of a single record, but not for more then 1 ! -->
            <xsl:for-each
              select="/root/gui/relation/services/response/*[geonet:info]|/root/gui/relation/children/response/*[geonet:info]|/root/gui/relation/related/response/*[geonet:info]|/root/gui/relation/parent/response/*[geonet:info]">
              <fo:block padding-left="4pt" padding-right="4pt" padding-top="4pt" margin-top="4pt">
                <fo:external-graphic content-width="10pt" padding-right="8pt" alignment-adjust="baseline">
                  <xsl:attribute name="src">
                    <xsl:value-of
                      select="concat(//server/protocol, '://', //server/host,':', //server/port, /root/gui/url, '/images/')"/>
                    <xsl:choose>
                      <xsl:when test="geonet:info/schema='sensorML'">transmit_blue.png</xsl:when>
                      <xsl:otherwise>database.png</xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                </fo:external-graphic>
                <fo:basic-link>
                  <xsl:attribute name="external-destination">url('<xsl:value-of
                    select="concat(//server/protocol, '://', //server/host,':', //server/port, /root/gui/url,'/srv/',/root/gui/language,'/pdf?uuid=',geonet:info/uuid)"
                  />')
                  </xsl:attribute>
                  <fo:inline text-decoration="underline">
                    <xsl:choose>
                      <xsl:when test="name() != 'metadata'">
                        <xsl:variable name="md">
                          <xsl:apply-templates mode="brief" select="."/>
                        </xsl:variable>
                        <xsl:variable name="metadata" select="exslt:node-set($md)/*[1]"/>
                        <xsl:value-of select="$metadata/title"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="title"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </fo:inline>
                </fo:basic-link>
              </fo:block>
            </xsl:for-each>
            <fo:block margin-top="8pt"/>
          </xsl:if>

          <!-- Collection -->
          <xsl:if
            test="count((/root/gui/relation/parent/response/*[geonet:info])) != 0">
            <fo:block font-weight="bold" font-size="10pt" padding-top="4pt" padding-bottom="4pt" padding-left="4pt"
                      padding-right="4pt">
              <xsl:value-of select="/root/gui/strings/Relateddata"/>
            </fo:block>
            <!-- this will work for display of a single record, but not for more then 1 ! -->
            <xsl:for-each
              select="/root/gui/relation/services/response/*[geonet:info]|/root/gui/relation/children/response/*[geonet:info]|/root/gui/relation/related/response/*[geonet:info]|/root/gui/relation/parent/response/*[geonet:info]">
              <fo:block padding-left="4pt" padding-right="4pt" padding-top="4pt" margin-top="4pt">
                <fo:external-graphic content-width="10pt" padding-right="8pt" alignment-adjust="baseline">
                  <xsl:attribute name="src">
                    <xsl:value-of
                      select="concat(//server/protocol, '://', //server/host,':', //server/port, /root/gui/url, '/images/')"/>
                    <xsl:choose>
                      <xsl:when test="geonet:info/schema='sensorML'">transmit_blue.png</xsl:when>
                      <xsl:otherwise>database.png</xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                </fo:external-graphic>
                <fo:basic-link>
                  <xsl:attribute name="external-destination">url('<xsl:value-of
                    select="concat(//server/protocol, '://', //server/host,':', //server/port, /root/gui/url,'/srv/',/root/gui/language,'/pdf?uuid=',geonet:info/uuid)"
                  />')
                  </xsl:attribute>
                  <fo:inline text-decoration="underline">
                    <xsl:choose>
                      <xsl:when test="name() != 'metadata'">
                        <xsl:variable name="md">
                          <xsl:apply-templates mode="brief" select="."/>
                        </xsl:variable>
                        <xsl:variable name="metadata" select="exslt:node-set($md)/*[1]"/>
                        <xsl:value-of select="$metadata/title"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="title"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </fo:inline>
                </fo:basic-link>
              </fo:block>
            </xsl:for-each>
            <fo:block margin-top="8pt"/>
          </xsl:if>

          <!-- Additionalinformation -->
          <fo:block font-weight="bold" font-size="10pt" padding-top="4pt" padding-bottom="4pt" padding-left="4pt"
                    padding-right="4pt">
            <xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Additionalinformation"/>
          </fo:block>

          <!-- Metadatarecord -->
          <fo:block border-width="1pt" border-style="solid" border-color="#1b5a9f">
            <fo:table table-layout="fixed" width="100%">
              <fo:table-column column-width="5cm"/>
              <fo:table-column column-width="6.8cm"/>

              <fo:table-body>
                <fo:table-row background-color="#1b5a9f">
                  <fo:table-cell padding-left="4pt" padding-right="4pt" padding-top="4pt" margin-top="4pt"
                                 number-columns-spanned="2" display-align="center">
                    <fo:block color="#ffffff" font-weight="bold" font-size="10pt">
                      <xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Metadatarecord"/>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>

                <xsl:apply-templates mode="elementFop"
                                     select="gmd:fileIdentifier|geonet:child[string(@name)='fileIdentifier']">
                  <xsl:with-param name="schema" select="$schema"/>
                </xsl:apply-templates>

                <!-- dataseturi -->
                <xsl:apply-templates mode="elementFop" select="gmd:dataSetURI">
                  <xsl:with-param name="schema" select="$schema"/>
                </xsl:apply-templates>

                <!-- Hierarchy level -->
                <xsl:apply-templates mode="elementFop"
                                     select="gmd:hierarchyLevel|geonet:child[string(@name)='hierarchyLevel']">
                  <xsl:with-param name="schema" select="$schema"/>

                </xsl:apply-templates>

                <!-- Datestamp -->
                <xsl:apply-templates mode="elementFop" select="gmd:dateStamp|geonet:child[string(@name)='dateStamp']">
                  <xsl:with-param name="schema" select="$schema"/>

                </xsl:apply-templates>

                <!-- ReferenceSystemInfo -->
                <xsl:for-each select="gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier">
                  <xsl:apply-templates mode="elementFop" select="gmd:codeSpace">
                    <xsl:with-param name="schema" select="$schema"/>
                  </xsl:apply-templates>
                  <xsl:apply-templates mode="elementFop" select="gmd:code">
                    <xsl:with-param name="schema" select="$schema"/>
                  </xsl:apply-templates>
                  <xsl:apply-templates mode="elementFop" select="gmd:version">
                    <xsl:with-param name="schema" select="$schema"/>
                  </xsl:apply-templates>
                </xsl:for-each>

              </fo:table-body>
            </fo:table>
          </fo:block>
          <fo:block margin-top="12pt"/>

          <!-- Datasetidentification -->
          <fo:block border-width="1pt" border-style="solid" border-color="#1b5a9f">
            <fo:table table-layout="fixed" width="100%">
              <fo:table-column column-width="5cm"/>
              <fo:table-column column-width="6.8cm"/>

              <fo:table-body>
                <fo:table-row background-color="#1b5a9f">
                  <fo:table-cell padding-left="4pt" padding-right="4pt" padding-top="4pt" margin-top="4pt"
                                 number-columns-spanned="2" display-align="center">
                    <fo:block color="#ffffff" font-weight="bold" font-size="10pt">
                      <xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Datasetidentification"/>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>

                <xsl:apply-templates mode="elementFop"
                                     select="gmd:identificationInfo//gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date">
                  <xsl:with-param name="schema" select="$schema"/>

                </xsl:apply-templates>

                <xsl:apply-templates mode="elementFop" select="gmd:language|geonet:child[string(@name)='language']">
                  <xsl:with-param name="schema" select="$schema"/>

                </xsl:apply-templates>

                <xsl:apply-templates mode="elementFop"
                                     select="gmd:characterSet|geonet:child[string(@name)='characterSet']">
                  <xsl:with-param name="schema" select="$schema"/>
                </xsl:apply-templates>

                <!-- todo: which status to use? -->
                <xsl:apply-templates mode="elementFop"
                                     select="gmd:identificationInfo//gmd:status">
                  <xsl:with-param name="schema" select="$schema"/>
                </xsl:apply-templates>


                <!-- Maintenance and update frequency -->
                <xsl:apply-templates mode="elementFop"
                                     select="gmd:identificationInfo//gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency">
                  <xsl:with-param name="schema" select="$schema"/>
                </xsl:apply-templates>


                <!-- Spatial representation type -->
                <xsl:apply-templates mode="elementFop" select="gmd:identificationInfo//gmd:spatialRepresentationType|geonet:child[string(@name)='spatialRepresentationType']">
                  <xsl:with-param name="schema" select="$schema"/>
                </xsl:apply-templates>

                <!-- Legal constraints -->

                <xsl:if test="gmd:identificationInfo//gmd:resourceConstraints/gmd:MD_LegalConstraints">
                  <xsl:call-template name="info-rows-separator" />
                </xsl:if>

                <xsl:for-each select="gmd:identificationInfo//gmd:resourceConstraints">
                  <xsl:apply-templates mode="elementFop"
                                       select="gmd:MD_LegalConstraints//gmd:useLimitation">
                    <xsl:with-param name="schema" select="$schema"/>
                  </xsl:apply-templates>

                  <xsl:apply-templates mode="elementFop"
                                       select="gmd:MD_LegalConstraints//gmd:MD_RestrictionCode/@codeListValue">
                    <xsl:with-param name="schema" select="$schema"/>
                  </xsl:apply-templates>

                  <xsl:apply-templates mode="elementFop"
                                       select="gmd:MD_LegalConstraints//gmd:otherConstraints">
                    <xsl:with-param name="schema" select="$schema"/>
                  </xsl:apply-templates>

                  <xsl:call-template name="info-rows-separator" />
                </xsl:for-each>



                <xsl:apply-templates mode="elementFop"
                                     select="gmd:identificationInfo//gmd:supplementalInformation|geonet:child[string(@name)='supplementalInformation']">
                  <xsl:with-param name="schema" select="$schema"/>
                </xsl:apply-templates>

                <!-- Service type - specific info -->
                <xsl:apply-templates mode="elementFop" select="gmd:identificationInfo/*/srv:serviceType">
                  <xsl:with-param name="schema" select="$schema"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementFop" select="gmd:identificationInfo/*/srv:serviceTypeVersion">
                  <xsl:with-param name="schema" select="$schema"/>
                </xsl:apply-templates>

                <xsl:apply-templates mode="elementFop" select="gmd:identificationInfo/*/srv:couplingType">
                  <xsl:with-param name="schema" select="$schema"/>
                </xsl:apply-templates>

                <xsl:for-each select="gmd:identificationInfo/*/srv:containsOperations/srv:SV_OperationMetadata">

                  <xsl:variable name="operation">
                    <xsl:apply-templates mode="elementFop"
                                         select="./srv:operationName">
                      <xsl:with-param name="schema" select="$schema"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates mode="elementFop"
                                         select="./srv:DCP/srv:DCPList">
                      <xsl:with-param name="schema" select="$schema"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates mode="elementFop"
                                         select="./srv:operationDescription">
                      <xsl:with-param name="schema" select="$schema"/>
                    </xsl:apply-templates>

                    <xsl:for-each select="srv:parameters/srv:SV_Parameter">
                      <xsl:variable name="parameter">
                        <xsl:apply-templates mode="elementFop"
                                             select="./srv:name">
                          <xsl:with-param name="schema" select="$schema"/>
                        </xsl:apply-templates>

                        <xsl:apply-templates mode="elementFop"
                                             select="./srv:direction">
                          <xsl:with-param name="schema" select="$schema"/>
                        </xsl:apply-templates>

                        <xsl:apply-templates mode="elementFop"
                                             select="./srv:description">
                          <xsl:with-param name="schema" select="$schema"/>
                        </xsl:apply-templates>

                        <xsl:apply-templates mode="elementFop"
                                             select="./srv:repeatability">
                          <xsl:with-param name="schema" select="$schema"/>
                        </xsl:apply-templates>


                        <xsl:apply-templates mode="elementFop"
                                             select="./srv:valueType">
                          <xsl:with-param name="schema" select="$schema"/>
                        </xsl:apply-templates>
                      </xsl:variable>

                      <xsl:call-template name="blockElementFop">
                        <xsl:with-param name="block" select="$parameter"/>
                        <xsl:with-param name="label">
                          <xsl:value-of
                            select="/root/gui/schemas/*[name()=$schema]/labels/element[@name='srv:SV_Parameter']/label"/>
                        </xsl:with-param>
                      </xsl:call-template>
                    </xsl:for-each>


                    <xsl:apply-templates mode="elementFop"
                                         select="./srv:connectPoint">
                      <xsl:with-param name="schema" select="$schema"/>
                    </xsl:apply-templates>
                  </xsl:variable>

                  <xsl:call-template name="blockElementFop">
                    <xsl:with-param name="block" select="$operation"/>
                    <xsl:with-param name="label">
                      <xsl:value-of
                        select="/root/gui/schemas/*[name()=$schema]/labels/element[@name='srv:containsOperations']/label"/>
                    </xsl:with-param>
                  </xsl:call-template>
                </xsl:for-each>
              </fo:table-body>
            </fo:table>
          </fo:block>
        </fo:block>
      </fo:table-cell>


      <!-- ** Sidebar ** -->

      <fo:table-cell padding-left="4pt" padding-right="4pt" padding-top="4pt" margin-top="4pt">

        <xsl:if
          test="gmd:identificationInfo//gmd:graphicOverview/gmd:MD_BrowseGraphic/gmd:fileName/gco:CharacterString!=''">

          <xsl:variable name="langId" select="/root/gui/language" />

          <xsl:variable name="thumbnailName">
            <xsl:choose>
              <xsl:when test="$langId != 'eng'"><xsl:value-of select="concat('thumbnail_', $langId)" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="'thumbnail'" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="largeThumbnailName">
            <xsl:choose>
              <xsl:when test="$langId != 'eng'"><xsl:value-of select="concat('large_thumbnail_', $langId)" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="'large_thumbnail'" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="thumbnailNameOtherLang">
            <xsl:choose>
              <xsl:when test="$langId != 'fre'"><xsl:value-of select="'thumbnail_fre'" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="'thumbnail'" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="largeThumbnailNameOtherLang">
            <xsl:choose>
              <xsl:when test="$langId != 'fre'"><xsl:value-of select="'large_thumbnail_fre'" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="'large_thumbnail'" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="fileName">
            <xsl:choose>
              <!-- large thumbnail -->
              <xsl:when test="gmd:identificationInfo//gmd:graphicOverview/gmd:MD_BrowseGraphic/gmd:fileDescription/gco:CharacterString = $largeThumbnailName and
                            gmd:identificationInfo//gmd:graphicOverview/gmd:MD_BrowseGraphic[gmd:fileDescription/gco:CharacterString=$largeThumbnailName]/gmd:fileName/gco:CharacterString!=''">
                <xsl:value-of
                  select="gmd:identificationInfo//gmd:graphicOverview/gmd:MD_BrowseGraphic[gmd:fileDescription/gco:CharacterString = $largeThumbnailName]/gmd:fileName/gco:CharacterString"/>
              </xsl:when>
              <!-- small thumbnail -->
              <xsl:when test="gmd:identificationInfo//gmd:graphicOverview/gmd:MD_BrowseGraphic/gmd:fileDescription/gco:CharacterString = $thumbnailName and
                            gmd:identificationInfo//gmd:graphicOverview/gmd:MD_BrowseGraphic[gmd:fileDescription/gco:CharacterString=$thumbnailName]/gmd:fileName/gco:CharacterString!=''">
                <xsl:value-of
                  select="gmd:identificationInfo//gmd:graphicOverview/gmd:MD_BrowseGraphic[gmd:fileDescription/gco:CharacterString = $thumbnailName]/gmd:fileName/gco:CharacterString"/>
              </xsl:when>
              <!-- large thumbnail other language -->
              <xsl:when test="gmd:identificationInfo//gmd:graphicOverview/gmd:MD_BrowseGraphic/gmd:fileDescription/gco:CharacterString = $largeThumbnailNameOtherLang and
                              gmd:identificationInfo//gmd:graphicOverview/gmd:MD_BrowseGraphic[gmd:fileDescription/gco:CharacterString=$largeThumbnailNameOtherLang]/gmd:fileName/gco:CharacterString!=''">
                <xsl:value-of select="gmd:identificationInfo//gmd:graphicOverview/gmd:MD_BrowseGraphic[gmd:fileDescription/gco:CharacterString = $largeThumbnailNameOtherLang]/gmd:fileName/gco:CharacterString"/>
              </xsl:when>
              <!-- small thumbnail other language -->
              <xsl:when test="gmd:identificationInfo//gmd:graphicOverview/gmd:MD_BrowseGraphic/gmd:fileDescription/gco:CharacterString = $thumbnailNameOtherLang and
                              gmd:identificationInfo//gmd:graphicOverview/gmd:MD_BrowseGraphic[gmd:fileDescription/gco:CharacterString=$thumbnailNameOtherLang]/gmd:fileName/gco:CharacterString!=''">
                <xsl:value-of select="gmd:identificationInfo//gmd:graphicOverview/gmd:MD_BrowseGraphic[gmd:fileDescription/gco:CharacterString = $thumbnailNameOtherLang]/gmd:fileName/gco:CharacterString"/>
              </xsl:when>
              <!-- any thumbnail -->
              <xsl:otherwise>
                <xsl:value-of
                  select="gmd:identificationInfo//gmd:graphicOverview/gmd:MD_BrowseGraphic[
                    not(gmd:fileDescription/gco:CharacterString = 'thumbnail') and
                     not(gmd:fileDescription/gco:CharacterString = 'thumbnail_fre') and
                      not(gmd:fileDescription/gco:CharacterString = 'large_thumbnail') and
                       not(gmd:fileDescription/gco:CharacterString = 'large_thumbnail_fre')][1]/gmd:fileName/gco:CharacterString"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:if test="gmd:identificationInfo//gmd:graphicOverview/gmd:MD_BrowseGraphic/gmd:fileName/gco:CharacterString=$fileName">
            <fo:block border-width="1pt" border-style="solid" border-color="#1b5a9f">
              <fo:table width="100%" table-layout="fixed">
                <fo:table-column column-width="3cm"/>
                <fo:table-column column-width="4.2cm"/>
                <fo:table-body>
                  <fo:table-row background-color="#1b5a9f">
                    <fo:table-cell padding-left="4pt" padding-right="4pt" padding-top="4pt" margin-top="4pt"
                                   number-columns-spanned="2" display-align="center">
                      <fo:block color="#ffffff" font-weight="bold" font-size="10pt">
                        <xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Thumbnail"/>
                      </fo:block>
                    </fo:table-cell>
                  </fo:table-row>

                  <fo:table-row>
                    <fo:table-cell number-columns-spanned="2">
                      <fo:block>
                        <fo:inline padding="0.5cm">
                          <fo:external-graphic content-width="6.2cm">
                            <xsl:attribute name="src">
                              <xsl:value-of
                                select="concat( //server/protocol, '://', //server/host,':', //server/port, /root/gui/url, '/srv/eng/resources.get?uuid=', gmd:fileIdentifier/gco:CharacterString, '&amp;fname=', $fileName, '&amp;access=public')"
                              />
                            </xsl:attribute>
                          </fo:external-graphic>
                        </fo:inline>
                      </fo:block>
                    </fo:table-cell>
                  </fo:table-row>
                </fo:table-body>
              </fo:table>
            </fo:block>
            <fo:block margin-top="8pt"/>
          </xsl:if>
        </xsl:if>

        <fo:block border-width="1pt" border-style="solid" border-color="#1b5a9f">
          <fo:table width="100%" table-layout="fixed">
            <fo:table-column column-width="3cm"/>
            <fo:table-column column-width="4.2cm"/>
            <fo:table-body>
              <fo:table-row background-color="#1b5a9f">
                <fo:table-cell padding-left="4pt" padding-right="4pt" padding-top="4pt" margin-top="4pt"
                               number-columns-spanned="2" display-align="center">
                  <fo:block color="#ffffff" font-weight="bold" font-size="10pt">

                    <xsl:value-of select="/root/gui/schemas/iso19139.nap/strings/Dataclassification"/>


                  </fo:block>
                </fo:table-cell>
              </fo:table-row>


              <xsl:variable name="keywordsList">
                <xsl:for-each
                  select="gmd:identificationInfo//gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword">
                  <xsl:choose>
                    <xsl:when test="(../gmd:thesaurusName/gmd:CI_Citation/@id = 'local.theme.EC_Waf')">
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:variable name="keywordVal">
                        <xsl:variable name="keywordVal">
                          <xsl:call-template name="localised">
                            <xsl:with-param name="langId"
                                            select="concat('#', $langForMetadata)"/>
                          </xsl:call-template>
                        </xsl:variable>
                      </xsl:variable>
                      <xsl:value-of select="normalize-space($keywordVal)" /><xsl:if test="string(normalize-space($keywordVal))"><xsl:text>, </xsl:text></xsl:if>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>
              </xsl:variable>

              <xsl:call-template name="TRFop">
                <xsl:with-param name="label" select="/root/gui/strings/keywords"/>
                <xsl:with-param name="text">

                  <xsl:if test="string($keywordsList)">
                    <xsl:value-of
                      select="normalize-space(substring($keywordsList, 1, string-length($keywordsList) - 1))"/>
                  </xsl:if>
                </xsl:with-param>
              </xsl:call-template>


              <xsl:apply-templates mode="elementFop"
                                   select="gmd:identificationInfo//gmd:topicCategory">
                <xsl:with-param name="schema" select="$schema"/>
              </xsl:apply-templates>
            </fo:table-body>
          </fo:table>
        </fo:block>
        <fo:block margin-top="8pt"/>

        <!-- Metadata contacts-->
        <xsl:for-each select="gmd:contact/gmd:CI_ResponsibleParty">
          <fo:block border-width="1pt" border-style="solid" border-color="#1b5a9f">
            <fo:table width="100%" table-layout="fixed">
              <fo:table-column column-width="3cm"/>
              <fo:table-column column-width="4.2cm"/>
              <fo:table-body>
                <fo:table-row background-color="#1b5a9f">
                  <fo:table-cell padding-left="4pt" padding-right="4pt" padding-top="4pt" margin-top="4pt"
                                 number-columns-spanned="2" display-align="center">
                    <fo:block color="#ffffff" font-weight="bold" font-size="10pt">
                      <xsl:value-of select="/root/gui/strings/MetadataContact"/>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>
                <xsl:apply-templates mode="elementFop" select=".">
                  <xsl:with-param name="schema" select="$schema"/>
                </xsl:apply-templates>
              </fo:table-body>
            </fo:table>
          </fo:block>
          <fo:block margin-top="8pt"/>
        </xsl:for-each>

        <!-- Contacts-->
        <xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact/gmd:CI_ResponsibleParty">
          <fo:block border-width="1pt" border-style="solid" border-color="#1b5a9f">
            <fo:table width="100%" table-layout="fixed">
              <fo:table-column column-width="3cm"/>
              <fo:table-column column-width="4.2cm"/>
              <fo:table-body>
                <fo:table-row background-color="#1b5a9f">
                  <fo:table-cell padding-left="4pt" padding-right="4pt" padding-top="4pt" margin-top="4pt"
                                 number-columns-spanned="2" display-align="center">
                    <fo:block color="#ffffff" font-weight="bold" font-size="10pt">
                      <xsl:value-of select="/root/gui/strings/Contact"/>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>
                <xsl:apply-templates mode="elementFop" select=".">
                  <xsl:with-param name="schema" select="$schema"/>
                </xsl:apply-templates>
              </fo:table-body>
            </fo:table>
          </fo:block>
          <fo:block margin-top="8pt"/>
        </xsl:for-each>

        <!-- Data contacts-->
        <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty">
          <fo:block border-width="1pt" border-style="solid" border-color="#1b5a9f">
            <fo:table width="100%" table-layout="fixed">
              <fo:table-column column-width="3cm"/>
              <fo:table-column column-width="4.2cm"/>
              <fo:table-body>
                <fo:table-row background-color="#1b5a9f">
                  <fo:table-cell padding-left="4pt" padding-right="4pt" padding-top="4pt" margin-top="4pt"
                                 number-columns-spanned="2" display-align="center">
                    <fo:block color="#ffffff" font-weight="bold" font-size="10pt">
                      <xsl:value-of select="/root/gui/strings/DataContact"/>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>
                <xsl:apply-templates mode="elementFop" select=".">
                  <xsl:with-param name="schema" select="$schema"/>
                </xsl:apply-templates>
              </fo:table-body>
            </fo:table>
          </fo:block>
          <fo:block margin-top="8pt"/>
        </xsl:for-each>

        <!-- Distributor contact -->
        <xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/*/gmd:distributorContact/gmd:CI_ResponsibleParty">
          <fo:block border-width="1pt" border-style="solid" border-color="#1b5a9f">
            <fo:table width="100%" table-layout="fixed">
              <fo:table-column column-width="3cm"/>
              <fo:table-column column-width="4.2cm"/>
              <fo:table-body>
                <fo:table-row background-color="#1b5a9f">
                  <fo:table-cell padding-left="4pt" padding-right="4pt" padding-top="4pt" margin-top="4pt"
                                 number-columns-spanned="2" display-align="center">
                    <fo:block color="#ffffff" font-weight="bold" font-size="10pt">
                      <xsl:value-of select="/root/gui/strings/DistributorContact"/>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>
                <xsl:apply-templates mode="elementFop" select=".">
                  <xsl:with-param name="schema" select="$schema"/>
                </xsl:apply-templates>
              </fo:table-body>
            </fo:table>
          </fo:block>
          <fo:block margin-top="8pt"/>
        </xsl:for-each>
      </fo:table-cell>
    </fo:table-row>

  </xsl:template>

  <xsl:template name="TRFop">
    <xsl:param name="label"/>
    <xsl:param name="text"/>
    <xsl:if test="$text!=''">
      <fo:table-row>
        <fo:table-cell padding-left="4pt" padding-right="4pt" padding-top="4pt" margin-top="4pt">
          <fo:block color="#2e456b">
            <xsl:value-of select="$label"/>
          </fo:block>
        </fo:table-cell>
        <fo:table-cell padding-left="4pt" padding-right="4pt" padding-top="4pt" margin-top="4pt">
          <fo:block color="#707070">
            <xsl:value-of select="$text"/>
          </fo:block>
        </fo:table-cell>
      </fo:table-row>
    </xsl:if>
  </xsl:template>

  <xsl:template name="info-rows-separator">
    <fo:table-row>
      <fo:table-cell number-columns-spanned="2"
                     padding-top="4pt" padding-bottom="4pt" padding-right="4pt"
                     padding-left="4pt">
        <fo:block border-top-style="solid">
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>
</xsl:stylesheet>
