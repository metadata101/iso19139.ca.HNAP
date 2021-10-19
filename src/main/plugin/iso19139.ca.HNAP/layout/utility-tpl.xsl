<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright (C) 2001-2021 Food and Agriculture Organization of the
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
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gn="http://www.fao.org/geonetwork"
                xmlns:XslUtilHnap="java:ca.gc.schema.iso19139hnap.util.XslUtilHnap"
                version="2.0"
                exclude-result-prefixes="#all">

  <xsl:include href="utility-tpl-multilingual.xsl"/>

  <xsl:template name="get-iso19139.ca.HNAP-is-service">
    <xsl:call-template name="get-iso19139-is-service" />
  </xsl:template>

  <xsl:template name="get-iso19139.ca.HNAP-title">
    <xsl:call-template name="get-iso19139-title" />
  </xsl:template>

  <xsl:template name="get-iso19139.ca.HNAP-extents-as-json">
    <xsl:call-template name="get-iso19139-extents-as-json" />
  </xsl:template>

  <xsl:template name="get-iso19139.ca.HNAP-online-source-config">
    <xsl:param name="pattern"/>

    <xsl:variable name="paramsToRemove">
      <!--
        The variable params to Remove contains a list of the parameters names that will be removed from the service URL.
      -->
      <paramsToRemove>
        <name>layers</name>
        <name>request</name>
        <name>legend_format</name>
        <name>feature_info_type</name>
        <name>service</name>
      </paramsToRemove>
    </xsl:variable>

    <config>
      <xsl:for-each select="$metadata/descendant::gmd:onLine[
        matches(
        gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString,
        $pattern) and
        normalize-space(gmd:CI_OnlineResource/gmd:linkage/gmd:URL) != '']">
        <xsl:variable name="protocol"
                      select="string(gmd:CI_OnlineResource/gmd:protocol)"/>
        <xsl:variable name="fileName">
          <xsl:choose>
            <xsl:when test="matches($protocol, '^DB:.*')">
              <xsl:value-of select="concat(gmd:CI_OnlineResource/gmd:linkage/gmd:URL, '#',
                gmd:CI_OnlineResource/gmd:name/gco:CharacterString)"/>
            </xsl:when>
            <xsl:when test="matches($protocol, '^FILE:.*')">
              <xsl:value-of select="gmd:CI_OnlineResource/gmd:linkage/gmd:URL"/>
            </xsl:when>
            <xsl:when test="matches($protocol, '^OGC:.*') and normalize-space(gmd:CI_OnlineResource/gmd:name/gco:CharacterString) != ''">
              <xsl:value-of select="normalize-space(gmd:CI_OnlineResource/gmd:name/gco:CharacterString)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="substring-after(
              gmd:CI_OnlineResource/gmd:linkage/gmd:URL, 'attachments/')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="isOGC" select="matches($protocol, '^OGC:.*') and normalize-space(gmd:CI_OnlineResource/gmd:name/gco:CharacterString) != ''"/>

        <xsl:if test="$fileName != ''">
          <xsl:variable name="layersParam" select="XslUtilHnap:extractUrlParameter('layers', gmd:CI_OnlineResource/gmd:linkage/gmd:URL)" />
          <xsl:variable name="cleanUrl" select="XslUtilHnap:removeFromUrl($paramsToRemove/paramsToRemove/name, gmd:CI_OnlineResource/gmd:linkage/gmd:URL)" />
          <xsl:variable name="layerName">
            <!-- In case the URL doesn't contain any `layers` parameter then the
              gmd:CI_OnlineResource/gmd:name/gco:CharacterString
             will be used instead
             -->
            <xsl:choose>
              <xsl:when test="string-length($layersParam) > 0"><xsl:value-of select="$layersParam"/></xsl:when>
              <xsl:otherwise><xsl:value-of select="$fileName"/></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>


          <resource>
            <ref>
              <xsl:value-of select="gn:element/@ref"/>
            </ref>
            <refParent>
              <xsl:value-of select="gn:element/@parent"/>
            </refParent>
            <name>
              <xsl:value-of select="normalize-space($layerName)"/>
            </name>
            <url>
              <xsl:choose>
                <xsl:when test="$isOGC = true()"><xsl:value-of select="$cleanUrl"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="gmd:CI_OnlineResource/gmd:linkage/gmd:URL"/></xsl:otherwise>
              </xsl:choose>
            </url>
            <title>
              <xsl:value-of select="normalize-space($metadata/gmd:identificationInfo/*/
              gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>
            </title>
            <abstract>
              <xsl:value-of select="normalize-space($metadata/
              gmd:identificationInfo/*/gmd:abstract)"/>
            </abstract>
            <protocol>
              <xsl:value-of select="gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString"/>
            </protocol>
          </resource>
        </xsl:if>
      </xsl:for-each>
    </config>
  </xsl:template>
</xsl:stylesheet>
