<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
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