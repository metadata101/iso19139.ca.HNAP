<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:geonet="http://www.fao.org/geonetwork"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            queryBinding="xslt2">

  <sch:title xmlns="http://www.w3.org/2001/XMLSchema">HNAP validation rules (common)</sch:title>
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
                                       then lower-case(normalize-space(//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gmd:LanguageCode/@codeListValue))
                                       else if (contains(//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gco:CharacterString,';'))
                                            then lower-case(normalize-space(substring-before(//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gco:CharacterString,';')))
                                            else lower-case(//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language/gco:CharacterString)"/>
  <sch:let name="mainLanguageId" value="//*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:locale/gmd:PT_Locale[gmd:languageCode/*/@codeListValue = $mainLanguage]/@id"/>
  <sch:let name="mainLanguageText" value="if ($mainLanguage = 'fra') then 'French' else 'English'"/>
  <sch:let name="mainLanguage2char" value="if ($mainLanguage = 'fra') then 'fr' else 'en'"/>

  <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron" name="geonet:protocolListString" as="xs:string">
    <xsl:param name="protocolNode"/>

  	<xsl:variable name="v">
  	  <xsl:for-each select="$protocolNode">
        <xsl:sort select="lower-case(.)" order="ascending"/>
        <xsl:value-of select="."/>
        <xsl:if test="position() != last()">, </xsl:if>
       </xsl:for-each>
    </xsl:variable>

  	<xsl:value-of select="$v"/>
  </xsl:function>

  <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron" name="geonet:appendLocaleMessage">
    <xsl:param name="localeStringNode"/>
    <xsl:param name="appendText" as="xs:string"/>

    <xsl:for-each select="$localeStringNode">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:value-of select="concat($localeStringNode, $appendText)"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:function>

  <!--- Metadata pattern -->
  <sch:pattern>
    <sch:title>$loc/strings/Metadata</sch:title>

    <!-- HierarchyLevel -->
    <sch:rule context="//gmd:hierarchyLevel">

      <sch:let name="missing" value="not(string(gmd:MD_ScopeCode/@codeListValue))
                 or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/HierarchyLevel</sch:assert>

      <sch:let name="hierarchyLevelCodelistLabel"
               value="tr:codelist-value-label(
                            tr:create($schema),
                            gmd:MD_ScopeCode/local-name(),
                            gmd:MD_ScopeCode/@codeListValue)"/>

      <sch:let name="isValid" value="($hierarchyLevelCodelistLabel != '') and ($hierarchyLevelCodelistLabel != gmd:MD_ScopeCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidHierarchyLevel</sch:assert>

    </sch:rule>


    <!-- referenceSystemInfo -->
    <!-- Mandatory, if spatialRepresentionType in Data Identification is "vector," "grid" or "tin”. -->
    <sch:rule context="/gmd:MD_Metadata">
      <sch:let name="missing" value="not(gmd:referenceSystemInfo)
                " />

      <sch:let name="sRequireRefSystemInfo" value="count(//gmd:identificationInfo/*/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode[@codeListValue= 'RI_635']) +
                                                     count(//gmd:identificationInfo/*/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode[@codeListValue= 'RI_636']) +
                                                     count(//gmd:identificationInfo/*/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode[@codeListValue= 'RI_638'])" />

      <sch:assert
        test="(($sRequireRefSystemInfo > 0) and not($missing)) or
            $sRequireRefSystemInfo = 0"
      >$loc/strings/ReferenceSystemInfo</sch:assert>
    </sch:rule>

    <sch:rule context="//gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code">
      <sch:let name="missing" value="not(string(gco:CharacterString))
                " />

      <sch:assert
        test="not($missing)"
      >$loc/strings/ReferenceSystemInfoCode</sch:assert>

      <sch:let name="prefix" value="tokenize(gco:CharacterString, ':')[1]" />
      <sch:let name="value" value="tokenize(gco:CharacterString, ':')[2]" />

      <sch:assert test="gco:CharacterString = 'Proj4' or gco:CharacterString = 'unknown' or
                ($prefix = 'EPSG' and string(number($value)) != 'NaN') or
                ($prefix = 'SR-ORG' and string(number($value)) != 'NaN')
                ">$loc/strings/ReferenceSystemInfoCodeInvalid</sch:assert>
    </sch:rule>

    <!-- Contact - Role -->
    <sch:rule context="//gmd:contact/*/gmd:role">

      <sch:let name="roleCodelistLabel"
               value="tr:codelist-value-label(
                            tr:create($schema),
                            gmd:CI_RoleCode/local-name(),
                            gmd:CI_RoleCode/@codeListValue)"/>

      <sch:let name="missing" value="not(string(gmd:CI_RoleCode/@codeListValue))
                 or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/MissingContactRole</sch:assert>

      <sch:let name="isValid" value="($roleCodelistLabel != '') and ($roleCodelistLabel != gmd:CI_RoleCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidContactRole</sch:assert>

    </sch:rule>
  </sch:pattern>


  <!--- Data Identification pattern -->
  <sch:pattern>
    <sch:title>$loc/strings/DataIdentification</sch:title>

    <!-- Status -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:status
                     |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:status
                     |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:status">

      <sch:let name="missing" value="not(string(gmd:MD_ProgressCode/@codeListValue))
                 or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/Status</sch:assert>


      <sch:let name="statusCodelistLabel"
               value="tr:codelist-value-label(
                            tr:create($schema),
                            gmd:MD_ProgressCode/local-name(),
                            gmd:MD_ProgressCode/@codeListValue)"/>

      <sch:let name="isValid" value="($statusCodelistLabel != '') and ($statusCodelistLabel != gmd:MD_ProgressCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidStatusCode</sch:assert>

    </sch:rule>


    <!-- Topic Category -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:topicCategory
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:topicCategory
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:topicCategory">

      <sch:let name="missing" value="not(string(gmd:MD_TopicCategoryCode))
                " />

      <sch:assert
        test="not($missing)"
      >$loc/strings/TopicCategory</sch:assert>
    </sch:rule>


    <!-- Spatial Representation Type -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:spatialRepresentationType
                   |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:spatialRepresentationType
                   |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:spatialRepresentationType">

      <sch:let name="spatialRepresentationTypeCodelistLabel"
               value="tr:codelist-value-label(
                            tr:create($schema),
                            gmd:MD_SpatialRepresentationTypeCode/local-name(),
                            gmd:MD_SpatialRepresentationTypeCode/@codeListValue)"/>

      <sch:let name="isValid" value="($spatialRepresentationTypeCodelistLabel = '') or ($spatialRepresentationTypeCodelistLabel != gmd:MD_SpatialRepresentationTypeCode/@codeListValue)"/>

      <sch:assert
        test="$isValid"
      >$loc/strings/InvalidSpatialRepresentationType</sch:assert>
    </sch:rule>


    <!-- Creation/revision dates -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation">

      <sch:let name="missingPublication" value="count(gmd:date[gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'RI_367']) = 0" />

      <sch:assert
        test="not($missingPublication)"
      >$loc/strings/PublicationDate</sch:assert>

      <sch:let name="missingCreation" value="count(gmd:date[gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'RI_366']) = 0" />

      <sch:assert
        test="not($missingCreation)"
      >$loc/strings/CreationDate</sch:assert>

      <sch:let name="creationDate" value="gmd:date[gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'RI_366']/gmd:CI_Date/gmd:date/gco:Date" />
      <sch:let name="publicationDate" value="gmd:date[gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'RI_367']/gmd:CI_Date/gmd:date/gco:Date" />

      <sch:assert test="XslUtilHnap:compareDates($publicationDate, $creationDate) &gt;= 0 ">$loc/strings/PublicationDateBeforeCreationDate</sch:assert>

    </sch:rule>

    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date">

      <sch:let name="missing" value="not(string(gmd:date/gco:Date)) and not(string(gmd:date/gco:DateTime))
                    " />

      <sch:assert
        test="not($missing)"
      >$loc/strings/MissingDate</sch:assert>
    </sch:rule>


    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:dateType
            |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:dateType
            |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:dateType">

      <sch:let name="dateTypeCodelistLabel"
               value="tr:codelist-value-label(
                            tr:create($schema),
                            gmd:CI_DateTypeCode/local-name(),
                            gmd:CI_DateTypeCode/@codeListValue)"/>

      <sch:let name="missing" value="not(string(gmd:CI_DateTypeCode/@codeListValue))
                 or (@gco:nilReason)" />

      <sch:let name="isValid" value="($dateTypeCodelistLabel != '') and ($dateTypeCodelistLabel != gmd:CI_DateTypeCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidDateTypeCode</sch:assert>

    </sch:rule>

    <!-- Begin position -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod//gml:beginPosition">

      <sch:let name="beginPosition" value="." />
      <sch:let name="missingBeginPosition" value="not(string($beginPosition))" />

      <sch:assert test="not($missingBeginPosition)">$loc/strings/BeginDate</sch:assert>
      <sch:assert test="$missingBeginPosition or (XslUtilHnap:verifyDateFormat($beginPosition) &gt; 0)">$loc/strings/BeginPositionFormat</sch:assert>
    </sch:rule>

    <!-- End position -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent">

      <sch:let name="beginPosition" value="gmd:extent/gml:TimePeriod//gml:beginPosition" />
      <sch:let name="missingBeginPosition" value="not(string($beginPosition))" />
      <sch:let name="endPosition" value="gmd:extent/gml:TimePeriod//gml:endPosition" />
      <sch:let name="missingEndPosition" value="not(string($endPosition))" />

      <sch:assert test="$missingBeginPosition or $missingEndPosition or (XslUtilHnap:compareDates($endPosition, $beginPosition) &gt;= 0)">$loc/strings/EndPosition</sch:assert>
    </sch:rule>

    <!-- Dataset language -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:language
                   |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:language
                   |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:language">

      <sch:let name="missing" value="not(string(gco:CharacterString))
               or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/DataLanguage</sch:assert>
    </sch:rule>

    <!-- Maintenance and frequency -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency
                   |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency
                   |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency">

      <sch:let name="missing" value="not(string(gmd:MD_MaintenanceFrequencyCode/@codeListValue))
               or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/MaintenanceFrequency</sch:assert>


      <sch:let name="maintenanceFrequencyCodelistLabel"
               value="tr:codelist-value-label(
                            tr:create($schema),
                            gmd:MD_MaintenanceFrequencyCode/local-name(),
                            gmd:MD_MaintenanceFrequencyCode/@codeListValue)"/>

      <sch:let name="isValid" value="($maintenanceFrequencyCodelistLabel != '') and ($maintenanceFrequencyCodelistLabel != gmd:MD_MaintenanceFrequencyCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidMaintenanceFrequency</sch:assert>
    </sch:rule>


    <!-- Cited Responsible Party - Role -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:role
      |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:role
      |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:citation/*/gmd:citedResponsibleParty/*/gmd:role">

      <sch:let name="roleCodelistLabel"
               value="tr:codelist-value-label(
                            tr:create($schema),
                            gmd:CI_RoleCode/local-name(),
                            gmd:CI_RoleCode/@codeListValue)"/>

      <sch:let name="missing" value="not(string(gmd:CI_RoleCode/@codeListValue))
        or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/MissingCitedResponsibleRole</sch:assert>

      <sch:let name="isValid" value="($roleCodelistLabel != '') and ($roleCodelistLabel != gmd:CI_RoleCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidCitedResponsibleRole</sch:assert>

    </sch:rule>


    <!-- Core Subject Thesaurus -->
    <sch:rule context="//gmd:identificationInfo/gmd:MD_DataIdentification
            |//*[@gco:isoType='gmd:MD_DataIdentification']
            |//*[@gco:isoType='srv:SV_ServiceIdentification']">

<sch:let name="coreSubjectThesaurusExists"
               value="count(gmd:descriptiveKeywords[*/gmd:thesaurusName/*/gmd:title/*/text() = 'Government of Canada Core Subject Thesaurus' or
              */gmd:thesaurusName/*/gmd:title/*/text() = 'Thésaurus des sujets de base du gouvernement du Canada']) > 0" />

      <sch:assert test="$coreSubjectThesaurusExists">$loc/strings/CoreSubjectThesaurusMissing</sch:assert>
    </sch:rule>

    <!-- Access constraints -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:accessConstraints">

      <sch:let name="missing" value="not(string(gmd:MD_RestrictionCode/@codeListValue))" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/MissingAccessConstraints</sch:assert>

      <sch:let name="accessConstraintsCodelistLabel"
               value="tr:codelist-value-label(
                            tr:create($schema),
                            gmd:MD_RestrictionCode/local-name(),
                            gmd:MD_RestrictionCode/@codeListValue)"/>

      <sch:let name="isValid" value="($accessConstraintsCodelistLabel != '') and ($accessConstraintsCodelistLabel != gmd:MD_RestrictionCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidAccessConstraints</sch:assert>
    </sch:rule>

    <!-- Use constraints -->
    <sch:rule context="//gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useConstraints">

      <sch:let name="missing" value="not(string(gmd:MD_RestrictionCode/@codeListValue))" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/MissingUseConstraints</sch:assert>

      <sch:let name="useConstraintsCodelistLabel"
               value="tr:codelist-value-label(
                            tr:create($schema),
                            gmd:MD_RestrictionCode/local-name(),
                            gmd:MD_RestrictionCode/@codeListValue)"/>

      <sch:let name="isValid" value="($useConstraintsCodelistLabel != '') and ($useConstraintsCodelistLabel != gmd:MD_RestrictionCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidUseConstraints</sch:assert>
    </sch:rule>

    <sch:rule context="//gmd:identificationInfo">
      <sch:let name="hierarchyLevel" value="string(parent::gmd:MD_Metadata/gmd:hierarchyLevel/gmd:MD_ScopeCode)"/>
      <sch:let name="serviceLevel" value="string(parent::gmd:MD_Metadata/gmd:hierarchyLevel/gmd:MD_ScopeCode[@codeListValue='RI_631'])"/>
      <sch:let name="serviceIndNode" value="string( //srv:SV_ServiceIdentification | //*[@gco:isoType='srv:SV_ServiceIdentification'] )"/>
      <sch:let name="locMsg" value="geonet:appendLocaleMessage($loc/strings/ServiceNamespace, $hierarchyLevel)"/>

      <sch:assert test="($serviceLevel and $serviceIndNode) or (not($serviceLevel) and not ($serviceIndNode) )">$locMsg</sch:assert>
    </sch:rule>
  </sch:pattern>


  <!-- Distribution - Resources -->
  <sch:pattern>
    <sch:title>$loc/strings/Distribution</sch:title>

    <sch:rule context="//gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage/gmd:URL">

      <sch:let name="missing" value="not(string(.)) and not(string(../../../../gmd:onLine[@xlink:role!=../../../@xlink:role and @xlink:title=../../../@xlink:title]/gmd:CI_OnlineResource/gmd:linkage/gmd:URL))
                and (string(../../gmd:protocol/gco:CharacterString) or
                string(../../gmd:name/gco:CharacterString) or
                string(../../../../gmd:onLine[@xlink:role!=../../../@xlink:role and @xlink:title=../../../@xlink:title]/gmd:CI_OnlineResource/gmd:name/gco:CharacterString) or
                string(../../../../gmd:onLine[@xlink:role!=../../../@xlink:role and @xlink:title=../../../@xlink:title]/gmd:CI_OnlineResource/gmd:description/gco:CharacterString) or
                string(../../gmd:description/gco:CharacterString))"
      />

      <sch:assert
        test="not($missing)"
      >$loc/strings/OnlineResourceUrl</sch:assert>

    </sch:rule>

    <sch:rule context="//gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource">
        <sch:let name="locLabel" value="document(concat('../loc/', $lang, '/labels.xml'))"/>
        <sch:let name="protocolList" value="$locLabel/labels/element[@name='gmd:protocol']/helper/option/@value"/>
        <sch:let name="protocol" value="gmd:protocol/gco:CharacterString/text()"/>
        <sch:let name="isValidProtocol" value="$protocol = $protocolList"/>

    		<sch:let name="resourceName" value="gmd:name/gco:CharacterString/text()" />

    		<sch:let name="protocolListString" value="geonet:protocolListString($protocolList)"/>

        <sch:let name="locMsg" value="geonet:appendLocaleMessage($loc/strings/OnlineResourceProtocol, $protocolListString)"/>

        <sch:assert test="$isValidProtocol">$locMsg</sch:assert>

    </sch:rule>

    <!-- Online resource: MapResourcesREST, MapResourcesWMS-->
    <sch:rule context="//gmd:distributionInfo/gmd:MD_Distribution">
      <sch:let name="smallcase" value="'abcdefghijklmnopqrstuvwxyz'" />
      <sch:let name="uppercase" value="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

      <sch:let name="mapRESTCount" value="count(gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role='urn:xml:lang:eng-CAN' and translate(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString, $uppercase, $smallcase) = 'esri rest: map service']) +
                count(gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role='urn:xml:lang:fra-CAN' and translate(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString, $uppercase, $smallcase) = 'esri rest: map service'])" />

      <sch:assert test="$mapRESTCount &lt;= 2">$loc/strings/MapResourcesRESTNumber</sch:assert>
      <sch:assert test="$mapRESTCount = 0 or $mapRESTCount = 2 or $mapRESTCount &gt; 2">$loc/strings/MapResourcesREST</sch:assert>

      <sch:let name="mapWMSCount" value="count(gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role='urn:xml:lang:eng-CAN' and translate(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString, $uppercase, $smallcase) = 'ogc:wms']) +
                count(gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[@xlink:role='urn:xml:lang:fra-CAN' and translate(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString, $uppercase, $smallcase) = 'ogc:wms'])" />

      <sch:assert test="$mapWMSCount &lt;= 2">$loc/strings/MapResourcesWMSNumber</sch:assert>
      <sch:assert test="$mapWMSCount = 0 or $mapWMSCount = 2 or $mapWMSCount &gt; 2">$loc/strings/MapResourcesWMS</sch:assert>
    </sch:rule>

    <!-- Distribution - Format -->
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributionFormat/*/gmd:name">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/DistributionFormatName</sch:assert>

      <sch:let name="distribution-formats" value="document(concat('file:///', replace(concat($thesaurusDir, '/external/thesauri/theme/GC_Resource_Formats.rdf'), '\\', '/')))"/>

      <sch:let name="distributionFormat" value="gco:CharacterString" />

      <sch:assert test="($missing) or (string($distribution-formats//rdf:Description[replace(@rdf:about, 'http://geonetwork-opensource.org/EC/resourceformat#', '') = $distributionFormat]))">$loc/strings/DistributionFormatInvalid</sch:assert>

    </sch:rule>


    <sch:rule context="//gmd:distributionInfo/*/gmd:distributionFormat/*/gmd:version">

      <sch:let name="missing" value="not(string(gco:CharacterString))
                or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/DistributionFormatVersion</sch:assert>

    </sch:rule>

    <!-- Distributor - Role -->
    <sch:rule context="//gmd:distributionInfo/*/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/*/gmd:role">

      <sch:let name="roleCodelistLabel"
               value="tr:codelist-value-label(
                            tr:create($schema),
                            gmd:CI_RoleCode/local-name(),
                            gmd:CI_RoleCode/@codeListValue)"/>

      <sch:let name="missing" value="not(string(gmd:CI_RoleCode/@codeListValue))
        or (@gco:nilReason)" />

      <sch:assert
        test="not($missing)"
      >$loc/strings/MissingDistributorRole</sch:assert>

      <sch:let name="isValid" value="($roleCodelistLabel != '') and ($roleCodelistLabel != gmd:CI_RoleCode/@codeListValue)"/>

      <sch:assert
        test="$isValid or $missing"
      >$loc/strings/InvalidDistributorRole</sch:assert>
    </sch:rule>
  </sch:pattern>
</sch:schema>
