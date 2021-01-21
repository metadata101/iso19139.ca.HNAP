<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gml320="http://www.opengis.net/gml"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- ISO19139 are compatible with HNAP however for to import to process then records as HNAP we need to ensure that the metadataStandardName is set correctly -->

    <xsl:include href="../functions.xsl"/>

    <xsl:variable name="metadataStandardNameEng"
                  select="'North American Profile of ISO 19115:2003 - Geographic information - Metadata'"/>
    <xsl:variable name="metadataStandardNameFre"
                  select="'Profil nord-américain de la norme ISO 19115:2003 - Information géographique - Métadonnées'"/>
    <xsl:variable name="metadataStandardVersion" select="'CAN/CGSB-171.100-2009'"/>


    <!-- The default language is also added as gmd:locale
   for multilingual metadata records. -->
    <xsl:variable name="mainLanguage">
        <xsl:call-template name="langId_from_gmdlanguage19139">
            <xsl:with-param name="gmdlanguage" select="/root/*/gmd:language"/>
        </xsl:call-template>
    </xsl:variable>

  <xsl:variable name="schemaLocationFor2007"
                select="'http://www.isotc211.org/2005/gmd http://schemas.opengis.net/csw/2.0.2/profiles/apiso/1.0.0/apiso.xsd'"/>


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

  <xsl:template match="gmd:MD_Metadata">
    <xsl:copy copy-namespaces="no">
      <xsl:call-template name="add-namespaces"/>

      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

    <xsl:template
            match="gmd:metadataStandardName/gco:CharacterString[text()!=$metadataStandardNameEng and text()!=$metadataStandardNameFre]"
            priority="10">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="$mainLanguage='fra'">
                    <xsl:value-of select="$metadataStandardNameFre"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$metadataStandardNameEng"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

    <xsl:template
            match="gmd:metadataStandardName/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[text()!=$metadataStandardNameEng and text()!=$metadataStandardNameFre]"
            priority="10">
        <xsl:copy>

            <xsl:choose>
                <xsl:when test="$mainLanguage!='fra'">
                    <xsl:value-of select="$metadataStandardNameFre"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$metadataStandardNameEng"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="gmd:metadataStandardVersion/gco:CharacterString[text()!=$metadataStandardVersion]"
                  priority="10">
        <xsl:copy>
            <xsl:value-of select="$metadataStandardVersion"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>