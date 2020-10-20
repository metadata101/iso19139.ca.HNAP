<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:geonet="http://www.fao.org/geonetwork"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            queryBinding="xslt2">

  <sch:title xmlns="http://www.w3.org/2001/XMLSchema">HNAP validation rules (open-license)</sch:title>
  <sch:ns prefix="gml" uri="http://www.opengis.net/gml/3.2"/>
  <sch:ns prefix="gml320" uri="http://www.opengis.net/gml"/>
  <sch:ns prefix="gmd" uri="http://www.isotc211.org/2005/gmd"/>
  <sch:ns prefix="srv" uri="http://www.isotc211.org/2005/srv"/>
  <sch:ns prefix="gco" uri="http://www.isotc211.org/2005/gco"/>
  <sch:ns prefix="gmx" uri="http://www.isotc211.org/2005/gmx"/>
  <sch:ns prefix="geonet" uri="http://www.fao.org/geonetwork"/>
  <sch:ns prefix="xsl" uri="http://www.w3.org/1999/XSL/Transform"/>
  <sch:ns prefix="XslUtilHnap" uri="java:ca.gc.schema.iso19139hnap.util.XslUtilHnap"/>
  <sch:ns prefix="tr" uri="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"/>
  <sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>
  <sch:ns prefix="rdf" uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>
  <sch:ns prefix="ns2" uri="http://www.w3.org/2004/02/skos/core#"/>
  <sch:ns prefix="rdfs" uri="http://www.w3.org/2000/01/rdf-schema#"/>

  <sch:let name="schema" value="'iso19139.ca.HNAP'"/>
  <sch:let name="mainLanguage" value="if (normalize-space(//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gmd:LanguageCode/@codeListValue) != '')
                                       then normalize-space(//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gmd:LanguageCode/@codeListValue)
                                       else if (contains(//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gco:CharacterString,';'))
                                            then normalize-space(substring-before(//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gco:CharacterString,';'))
                                            else //*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gco:CharacterString"/>
  <sch:let name="mainLanguageId" value="//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:locale/gmd:PT_Locale[gmd:languageCode/*/@codeListValue = $mainLanguage]/@id"/>
  <sch:let name="altLanguageId" value="//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:locale/gmd:PT_Locale[gmd:languageCode/*/@codeListValue != $mainLanguage and (gmd:languageCode/*/@codeListValue = 'eng' or gmd:languageCode/*/@codeListValue = 'fra')]/@id"/>
  <sch:let name="mainLanguage2char" value="if (lower-case($mainLanguageId) = 'fra') then 'fr' else 'en'"/>
  <sch:let name="altLanguage2char" value="if (lower-case($altLanguageId) = 'fra') then 'fr' else 'en'"/>
  <sch:let name="mainLanguageText" value="if (lower-case($mainLanguageId) = 'fra') then 'French' else 'English'"/>
  <sch:let name="altLanguageText" value="if (lower-case($altLanguageId) = 'fra') then 'French' else 'English'"/>

  <xsl:function name="geonet:resourceFormatsList" as="xs:string">
    <xsl:param name="thesaurusDir" as="xs:string"/>

    <xsl:variable name="formats-list" select="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Resource_Formats.rdf'), '\\', '/')))"/>

    <xsl:variable name="v">
      <xsl:for-each select="$formats-list//rdf:Description[ns2:prefLabel[@xml:lang='en']]">
        <xsl:sort select="lower-case(@rdf:about)" order="ascending" />
        <xsl:value-of select="replace(@rdf:about, 'http://geonetwork-opensource.org/EC/resourceformat#', '')" />
        <xsl:if test="position() != last()">, </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:value-of select="$v" />
  </xsl:function>

  <!-- Checks if the values in arg (can be a comma separate list of items) are all in the searchStrings list -->
  <xsl:function name="geonet:values-in" as="xs:boolean">
    <xsl:param name="arg" as="xs:string?"/>
    <xsl:param name="searchStrings" as="xs:string*"/>

    <xsl:variable name="list" select="tokenize($arg, ',')" />
    <xsl:sequence
            select="
            every $listValue in $list
            satisfies exists($searchStrings[. = $listValue])
            "
    />
  </xsl:function>

  <!-- ===================================================================
  EC schematron rules for open-data license validation in metadata editor:
  ==================================================================== -->

  <!-- Use limitation -->
  <sch:pattern>
    <sch:title>$loc/strings/DataIdentification</sch:title>

    <!-- Use limitation -->
    <sch:rule context="//gmd:identificationInfo/gmd:MD_DataIdentification
        |//*[@gco:isoType='gmd:MD_DataIdentification']
        |//*[@gco:isoType='srv:SV_ServiceIdentification']">

      <sch:let name="open-licenses" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Open_licenses.rdf'), '\\', '/')))"/>

      <sch:let name="openLicenseMultilingual" value="count(gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation[
            (normalize-space(gco:CharacterString) = $open-licenses//rdf:Description/ns2:prefLabel[@xml:lang=$mainLanguage2char]) and
            (normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]) = $open-licenses//rdf:Description/ns2:prefLabel[@xml:lang=$altLanguage2char])
            ])" />

      <sch:let name="openLicense" value="count(gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation[
        (normalize-space(gco:CharacterString) = $open-licenses//rdf:Description/ns2:prefLabel[@xml:lang=$mainLanguage2char])])" />

      <sch:assert
        test="(($openLicenseMultilingual > 0) and (string($altLanguageId))) or (($openLicense > 0) and (not(string($altLanguageId))))"
      >$loc/strings/OpenLicense</sch:assert>

    </sch:rule>

  </sch:pattern>

</sch:schema>
