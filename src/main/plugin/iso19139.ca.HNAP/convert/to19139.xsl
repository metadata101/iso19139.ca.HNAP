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

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gml320="http://www.opengis.net/gml"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                exclude-result-prefixes="#all">


  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <xsl:variable name="schemaLocationFor2007"
                select="'http://www.isotc211.org/2005/gmd http://schemas.opengis.net/csw/2.0.2/profiles/apiso/1.0.0/apiso.xsd'"/>


  <!-- ================================================================= -->
  <!-- Try to determine if using the 2005 or 2007 version
  of ISO19139. Based on this GML 3.2.0 or 3.2.1 is used.
  Default is 2007 with GML 3.2.1.
  You can force usage of a schema by setting:
  * ISO19139:2007
  <xsl:variable name="isUsing2005Schema" select="false()"/>
  * ISO19139:2005 (not recommended)
  <xsl:variable name="isUsing2005Schema" select="true()"/>
  -->
  <xsl:variable name="isUsing2005Schema"
                select="(/root/gmd:MD_Metadata/@xsi:schemaLocation
                          and /root/gmd:MD_Metadata/@xsi:schemaLocation != $schemaLocationFor2007)
                        or
                        count(//gml320:*) > 0"/>

  <!-- This variable is used to migrate from 2005 to 2007 version.
  By setting the schema location in a record, on next save, the record
  will use GML3.2.1.-->
  <xsl:variable name="isUsing2007Schema"
                select="/root/gmd:MD_Metadata/@xsi:schemaLocation
                          and /root/gmd:MD_Metadata/@xsi:schemaLocation = $schemaLocationFor2007"/>


  <!-- identity template -->
  <xsl:template match="@*|node()">
    <xsl:copy copy-namespaces="no">
      <xsl:call-template name="add-namespaces"/>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="add-namespaces">
    <xsl:namespace name="xsi" select="'http://www.w3.org/2001/XMLSchema-instance'"/>
    <xsl:namespace name="gco" select="'http://www.isotc211.org/2005/gco'"/>
    <xsl:namespace name="gmd" select="'http://www.isotc211.org/2005/gmd'"/>
    <xsl:namespace name="gfc" select="'http://www.isotc211.org/2005/gfc'"/>
    <xsl:namespace name="srv" select="'http://www.isotc211.org/2005/srv'"/>
    <xsl:namespace name="gmx" select="'http://www.isotc211.org/2005/gmx'"/>
    <xsl:namespace name="gts" select="'http://www.isotc211.org/2005/gts'"/>
    <xsl:namespace name="gsr" select="'http://www.isotc211.org/2005/gsr'"/>
    <xsl:namespace name="gss" select="'http://www.isotc211.org/2005/gss'"/>
    <xsl:namespace name="gmi" select="'http://www.isotc211.org/2005/gmi'"/>
    <xsl:namespace name="napm" select="'http://www.geconnections.org/nap/napMetadataTools/napXsd/napm'"/>

    <xsl:choose>
      <xsl:when test="$isUsing2005Schema and not($isUsing2007Schema)">
        <xsl:namespace name="gml" select="'http://www.opengis.net/gml'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:namespace name="gml" select="'http://www.opengis.net/gml/3.2'"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:namespace name="xlink" select="'http://www.w3.org/1999/xlink'"/>
  </xsl:template>

</xsl:stylesheet>
