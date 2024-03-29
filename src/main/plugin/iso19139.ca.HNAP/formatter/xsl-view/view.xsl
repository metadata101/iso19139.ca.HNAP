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
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:gml320="http://www.opengis.net/gml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
                xmlns:gn-fn-render="http://geonetwork-opensource.org/xsl/functions/render"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
                xmlns:xslUtils="java:org.fao.geonet.util.XslUtil"
                xmlns:saxon="http://saxon.sf.net/"
                version="2.0"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all">
  <xsl:import href="../../layout/evaluate.xsl"/>
  <xsl:import href="../../layout/utility-tpl-multilingual.xsl"/>
  <xsl:import href="../../layout/utility-fn.xsl"/>
  <xsl:import href="../../../iso19139/formatter/xsl-view/view.xsl"/>

  <!-- Load the editor configuration to be able
  to render the different views -->
  <xsl:variable name="configuration"
                select="document('../../layout/config-editor.xml')"/>

  <!-- Required for utility-fn.xsl -->
  <xsl:variable name="editorConfig"
                select="document('../../layout/config-editor.xml')"/>

  <xsl:variable name="langId" select="gn-fn-iso19139:getLangIdHNAP($metadata, $language)"/>


  <!-- Override codelist template, to don't use the text value,
       just the codeListValue attribute -->
  <xsl:template mode="render-field"
                match="*[*/@codeListValue]"
                priority="100">
    <xsl:param name="fieldName" select="''" as="xs:string"/>

    <xsl:if test="normalize-space(string-join(*/@codeListValue, '')) != ''">
      <dl>
        <dt>
          <xsl:call-template name="render-field-label">
            <xsl:with-param name="fieldName" select="$fieldName"/>
            <xsl:with-param name="languages" select="$allLanguages"/>
          </xsl:call-template>
        </dt>
        <dd><xsl:comment select="name()"/>
          <xsl:apply-templates mode="render-value" select="*/@codeListValue"/>
        </dd>
      </dl>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
