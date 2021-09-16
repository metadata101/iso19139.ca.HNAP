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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gml320="http://www.opengis.net/gml"
                xmlns:gco="http://www.isotc211.org/2005/gco" version="2.0">

  <!-- 'defaultLang' global variable was declared as 'eng' in  ../../iso19139/convert/functions.xsl
  This variable is used in langIdWithCountry19139 template-->

  <!--Template langId_from_gmdlanguage19139 was declared in  ../../iso19139/convert/functions.xsl
   and it is used in template langIdWithCountry19139-->
  <xsl:import href="../../iso19139/convert/functions.xsl"/>

  <xsl:template name="langIdWithCountry19139">
    <xsl:variable name="tmp">
      <xsl:choose>
        <xsl:when test="/*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gmd:LanguageCode/@codeListValue|
        	              /*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gco:CharacterString
                                ">
          <xsl:call-template name="langId_from_gmdlanguage19139">
            <xsl:with-param name="gmdlanguage" select="/*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="$defaultLang"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="tmp2">
      <xsl:value-of select="normalize-space(string(replace($tmp, '; CAN', '')))"></xsl:value-of>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$tmp2 != 'eng' and $tmp2 != 'fra'"><xsl:value-of select="$defaultLang"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$tmp2"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="add-namespaces">

    <!-- This variable is copied from update-fixed-info.xsl. -->
    <xsl:variable name="schemaLocation2007"
                  select="'http://www.isotc211.org/2005/gmd http://schemas.opengis.net/csw/2.0.2/profiles/apiso/1.0.0/apiso.xsd'"/>

    <!-- ================================================================= -->
    <!-- This variable is copied from update-fixed-info.xsl. -->
    <!-- Try to determine if using the 2005 or 2007 version
    of ISO19139. Based on this GML 3.2.0 or 3.2.1 is used.
    Default is 2007 with GML 3.2.1.
    You can force usage of a schema by setting:
    * ISO19139:2007
    <xsl:variable name="isUsingSchema2005" select="false()"/>
    * ISO19139:2005 (not recommended)
    <xsl:variable name="isUsingSchema2005" select="true()"/>
    -->
    <xsl:variable name="isUsingSchema2005"
                  select="(/root/gmd:MD_Metadata/@xsi:schemaLocation
                          and /root/gmd:MD_Metadata/@xsi:schemaLocation != $schemaLocation2007)
                        or
                        count(//gml320:*) > 0"/>

    <!-- This variable is copied from update-fixed-info.xsl. -->
    <!-- This variable is used to migrate from 2005 to 2007 version.
    By setting the schema location in a record, on next save, the record
    will use GML3.2.1.-->
    <xsl:variable name="isUsingSchema2007"
                  select="/root/gmd:MD_Metadata/@xsi:schemaLocation
                          and /root/gmd:MD_Metadata/@xsi:schemaLocation = $schemaLocation2007"/>

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
      <xsl:when test="$isUsingSchema2005 and not($isUsingSchema2007)">
        <xsl:namespace name="gml" select="'http://www.opengis.net/gml'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:namespace name="gml" select="'http://www.opengis.net/gml/3.2'"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:namespace name="xlink" select="'http://www.w3.org/1999/xlink'"/>
  </xsl:template>

</xsl:stylesheet>
