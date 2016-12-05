<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl ="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:exslt="http://exslt.org/common"
                xmlns:napec="http://www.ec.gc.ca/data_donnees/standards/schemas/napec"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:ns2="http://www.w3.org/2004/02/skos/core#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                exclude-result-prefixes="gmx xsi gmd gco gml gts srv xlink exslt geonet napec rdf ns2 rdfs skos svrl">

  <!-- ===================================================================== -->
  <!-- === iso19139.nap brief formatting 							   === -->
  <!-- ===================================================================== -->
  <xsl:template name="iso19139.napBrief">
    <metadata>
      <xsl:choose>
        <xsl:when test="geonet:info/isTemplate='s'">
          <xsl:apply-templates mode="iso19139-subtemplate" select="."/>
          <xsl:copy-of select="geonet:info" copy-namespaces="no"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- call iso19139 brief -->
          <xsl:call-template name="iso19139-brief"/>
          <!-- now brief elements for nap specific elements -->
          <xsl:call-template name="iso19139.nap-brief"/>
        </xsl:otherwise>
      </xsl:choose>
    </metadata>
  </xsl:template>

  <!-- nap extensions in gmd:MD_Metadata need to be added to brief template -->
  <xsl:template name="iso19139.nap-brief">
    <xsl:variable name="info" select="geonet:info"/>
    <xsl:variable name="id" select="$info/id"/>
    <xsl:variable name="uuid" select="$info/uuid"/>

    <xsl:variable name="langId">
      <xsl:call-template name="getLangId">
        <xsl:with-param name="langGui" select="/root/gui/language"/>
        <xsl:with-param name="md" select="."/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource">

      <xsl:variable name="protocol" select="gmd:protocol[1]/gco:CharacterString"/>
      <!--<xsl:variable name="linkage"  select="normalize-space(gmd:linkage/gmd:URL)"/> -->
      <xsl:variable name="linkage" select="gmd:linkage/gmd:URL" />

      <!--<xsl:variable name="name">
          <xsl:for-each select="gmd:name">
              <xsl:call-template name="localised">
                  <xsl:with-param name="langId" select="$langId"/>
              </xsl:call-template>
          </xsl:for-each>
      </xsl:variable>-->
      <xsl:variable name="name">
        <xsl:apply-templates mode="localised" select="gmd:name">
          <xsl:with-param name="langId" select="$langId"></xsl:with-param>
        </xsl:apply-templates>
      </xsl:variable>


      <xsl:variable name="mimeType" select="normalize-space(gmd:name/gmx:MimeFileType/@type)"/>

      <!--<xsl:variable name="desc">
        <xsl:for-each select="gmd:description">
          <xsl:call-template name="localised">
            <xsl:with-param name="langId" select="$langId"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:variable>-->
      <xsl:variable name="desc">
        <xsl:apply-templates mode="localised" select="gmd:description">
          <xsl:with-param name="langId" select="$langId"></xsl:with-param>
        </xsl:apply-templates>
      </xsl:variable>

      <xsl:if test="string($linkage)!=''">

        <xsl:element name="link">
          <xsl:attribute name="title"><xsl:value-of select="normalize-space($desc)"/></xsl:attribute>
          <xsl:attribute name="href"><xsl:value-of select="$linkage"/></xsl:attribute>
          <xsl:attribute name="name"><xsl:value-of select="normalize-space($name)"/></xsl:attribute>
          <xsl:attribute name="protocol"><xsl:value-of select="$protocol"/></xsl:attribute>
          <xsl:attribute name="type" select="geonet:protocolMimeType($linkage, $protocol, $mimeType)"/>
        </xsl:element>

      </xsl:if>

      <!-- Generate a KML output link for a WMS service -->
      <xsl:if test="string($linkage)!='' and starts-with($protocol,'OGC:WMS-') and contains($protocol,'-get-map') and string($name)!=''">

        <xsl:element name="link">
          <xsl:attribute name="title"><xsl:value-of select="$desc"/></xsl:attribute>
          <xsl:attribute name="href">
            <xsl:value-of select="concat(/root/gui/env/server/protocol,'://',/root/gui/env/server/host,':',/root/gui/env/server/port,/root/gui/locService,'/google.kml?uuid=',$uuid,'&amp;layers=',$name)"/>
          </xsl:attribute>
          <xsl:attribute name="name"><xsl:value-of select="$name"/></xsl:attribute>
          <xsl:attribute name="type">application/vnd.google-earth.kml+xml</xsl:attribute>
        </xsl:element>
      </xsl:if>

    </xsl:for-each>

  </xsl:template>

</xsl:stylesheet>