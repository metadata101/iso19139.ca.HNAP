<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:lst="http://www.lansstyrelsen.se" exclude-result-prefixes="srv">
    
    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    
    <xsl:strip-space elements="*"/>
    
    <!-- Template for Copy data -->
    <xsl:template name="copyData" match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- remove the 4 personal resource contacts -->
    <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo//gmd:pointOfContact[gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue='owner']"/>
    <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo//gmd:pointOfContact[gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue='informationManager']"/>
    <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo//gmd:pointOfContact[gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue='manager']"/>
    <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo//gmd:pointOfContact[gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue='pointOfContact']"/>
    
    <!-- remove nodes related to Förvaltningsdokumentation and Statuscomments -->
    <xsl:template match="/gmd:MD_Metadata/lst:forvaltingsDok/lst:projektKatalogDokument"/>
    <xsl:template match="/gmd:MD_Metadata/lst:forvaltingsDok/lst:FD_ForvaltningsRutiner"/>
    <xsl:template match="/gmd:MD_Metadata/lst:forvaltingsDok/lst:FD_KvalitetsForbattring"/>
    <xsl:template match="/gmd:MD_Metadata/lst:forvaltingsDok/lst:FD_ResursStatus/lst:statusKommentar"/> 
    
    <!-- remove elements 'locked' in editor. most of these covered above -->
    <!--<xsl:template match="/gmd:MD_Metadata/lst:forvaltingsDok/lst:projektKatalogDokument"/>
    <xsl:template match="/gmd:MD_Metadata/lst:forvaltingsDok/lst:FD_ForvaltningsRutiner/lst:ajourhallningsutiner"/>
    <xsl:template match="/gmd:MD_Metadata/lst:forvaltingsDok/lst:FD_ForvaltningsRutiner/lst:forvaltningsRelateratDokument"/>
    <xsl:template match="/gmd:MD_Metadata/lst:forvaltingsDok/lst:FD_ForvaltningsRutiner/lst:ovrigaRutinBeskrivningar"/>
    <xsl:template match="/gmd:MD_Metadata/lst:forvaltingsDok/lst:FD_KvalitetsForbattring/lst:ovrigtOmUtveckling"/>
    <xsl:template match="/gmd:MD_Metadata/lst:forvaltingsDok/lst:FD_KvalitetsForbattring/lst:utvecklingsIdeer"/>
    <xsl:template match="/gmd:MD_Metadata/lst:forvaltingsDok/lst:FD_KvalitetsForbattring/lst:utvecklingsDokument"/>-->
    <xsl:template match="/gmd:MD_Metadata/lst:forvaltingsDok/lst:FD_Harmonisering/lst:attributStandard"/>
    <xsl:template match="/gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep"/>
    
    <!-- Template for remove thesaurus Resursklass if LST Arbetsmaterial is one of the keywwords -->   
    <!--<xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo//gmd:descriptiveKeywords[
        (gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'Resursklass')
        and
        (gmd:MD_Keywords/gmd:keyword/gco:CharacterString = 'LST Arbetsmaterial')]" />-->
    
    
    <!-- Template for remove all sections in the node ForvaltningsDokument -->
    <!--<xsl:template match="/gmd:MD_Metadata/lst:forvaltingsDok">
        <xsl:copy/>
    </xsl:template>-->
    
</xsl:stylesheet>