<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                  xmlns:gco="http://www.isotc211.org/2005/gco"
                  xmlns:gmd="http://www.isotc211.org/2005/gmd"
                  xmlns:srv="http://www.isotc211.org/2005/srv"
                  xmlns:gml="http://www.opengis.net/gml/3.2">

    <xsl:param name="language" />

    <xsl:template match="gmd:MD_Metadata">
      <xsl:variable name="mdLanguage" select="gmd:language/gco:CharacterString" />

      <dataset>
        <uuid><xsl:value-of select="gmd:fileIdentifier/gco:CharacterString"/></uuid>
        <name><xsl:value-of select="gmd:fileIdentifier/gco:CharacterString"/></name>

        <parent_id><xsl:value-of select="gmd:parentIdentifier/gco:CharacterString"/></parent_id>

        <language><xsl:value-of select="gmd:language/gco:CharacterString"/></language>
        <date_published><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='RI_367']/gmd:date/*" /></date_published>
        <date_modified><xsl:value-of select="gmd:dateStamp/*" /></date_modified>

        <time_period_coverage_start><xsl:value-of select="gmd:identificationInfo/*/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition" /></time_period_coverage_start>
        <time_period_coverage_end><xsl:value-of select="gmd:identificationInfo/*/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:endPosition" /></time_period_coverage_end>

        <hierarchy_level><xsl:value-of select="gmd:hierarchyLevel/gmd:MD_ScopeCode"/></hierarchy_level>
        <status><xsl:value-of select="lower-case(tokenize(gmd:identificationInfo/*/gmd:status/gmd:MD_ProgressCode, ';')[1])"/></status>
        
        <spatial_representation_type>
        <xsl:for-each select="gmd:identificationInfo/*/gmd:spatialRepresentationType">
          <xsl:if test="tokenize(gmd:MD_SpatialRepresentationTypeCode, ';')[1] != 'none'">
            <value><xsl:value-of select="tokenize(gmd:MD_SpatialRepresentationTypeCode, ';')[1]"/></value>
          </xsl:if>
        </xsl:for-each>
        </spatial_representation_type>

        <xsl:variable name="presentationForm" select="gmd:identificationInfo/*/gmd:presentationForm/gmd:CI_PresentationFormCode/@codeListValue" />
        <xsl:variable name="presentationFormCkan">
          <xsl:choose>
            <xsl:when test="$presentationForm = 'RI_387'">document_digital</xsl:when>
            <xsl:when test="$presentationForm = 'RI_389'">image_digital</xsl:when>
            <xsl:when test="$presentationForm = 'RI_388'">document_hardcopy</xsl:when>
            <xsl:when test="$presentationForm = 'RI_390'">image_hardcopy</xsl:when>
            <xsl:when test="$presentationForm = 'RI_391'">map_digital</xsl:when>
            <xsl:when test="$presentationForm = 'RI_392'">map_hardcopy</xsl:when>
            <xsl:when test="$presentationForm = 'RI_393'">model_digital</xsl:when>
            <xsl:when test="$presentationForm = 'RI_394'">model_hardcopy</xsl:when>
            <xsl:when test="$presentationForm = 'RI_395'">profile_digital</xsl:when>
            <xsl:when test="$presentationForm = 'RI_396'">profile_hardcopy</xsl:when>
            <xsl:when test="$presentationForm = 'RI_397'">table_digital</xsl:when>
            <xsl:when test="$presentationForm = 'RI_398'">table_hardcopy</xsl:when>
            <xsl:when test="$presentationForm = 'RI_399'">video_digital</xsl:when>
            <xsl:when test="$presentationForm = 'RI_400'">video_hardcopy</xsl:when>
            <xsl:when test="$presentationForm = 'RI_401'">audio_digital</xsl:when>
            <xsl:when test="$presentationForm = 'RI_402'">audio_hardcopy</xsl:when>
            <xsl:when test="$presentationForm = 'RI_403'">multimedia_digital</xsl:when>
            <xsl:when test="$presentationForm = 'RI_404'">multimedia_hardcopy</xsl:when>
            <xsl:when test="$presentationForm = 'RI_405'">diagram_digital</xsl:when>
            <xsl:when test="$presentationForm = 'RI_406'">diagram_hardcopy</xsl:when>
            <xsl:otherwise></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <presentation_form><xsl:value-of select="$presentationFormCkan" /></presentation_form>

        <!-- TODO: Fixed value to the code for ECCC, check for FGP -->
        <owner_org>49E2ADF4-AD7A-43EB-85C8-6433D37ED62C</owner_org>
        <creator>Environment and Climate Change Canada</creator>
        <subject>
          <value>economics_and_industry</value>
        </subject>


        <reference_system_information><xsl:value-of select="concat(gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code/gco:CharacterString, 
          ',', gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:codeSpace/gco:CharacterString,
          ',', gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:version/gco:CharacterString)" /></reference_system_information>

        <author_email>
          <xsl:choose>
            <xsl:when test="starts-with($mdLanguage, 'eng')">
              <value_eng><xsl:value-of select="gmd:contact/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString"/></value_eng>
              <value_fre><xsl:value-of select="gmd:contact/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']"/></value_fre>
            </xsl:when>
            <xsl:otherwise>
              <value_eng><xsl:value-of select="gmd:contact/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng']"/></value_eng>
              <value_fre><xsl:value-of select="gmd:contact/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString"/></value_fre>
            </xsl:otherwise>
          </xsl:choose>
        </author_email>

        <!-- TODO: as_needed, continual, P1D, P1W, P2W, P1M, P2M, P3M, P6M, P1Y, irregular, not_planned, unknown -->
        <xsl:variable name="mdFrequency" select="gmd:identificationInfo/*/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency/gmd:MD_MaintenanceFrequencyCode/@codeListValue" />
        <xsl:variable name="ckanFrequency">
          <xsl:choose>
            <xsl:when test="$mdFrequency = 'RI_540'">as_needed</xsl:when>
            <xsl:when test="$mdFrequency = 'RI_532'">continual</xsl:when>
            <xsl:when test="$mdFrequency = 'RI_533'">P1D</xsl:when>
            <xsl:when test="$mdFrequency = 'RI_534'">P1W</xsl:when>

            <!-- semimonthly and fortnightly -->
            <xsl:when test="$mdFrequency = 'RI_535'">P2W</xsl:when>
            <xsl:when test="$mdFrequency = 'RI_544'">P2W</xsl:when>

            <xsl:when test="$mdFrequency = 'RI_536'">P1M</xsl:when>
            <xsl:when test="$mdFrequency = 'RI_537'">P3M</xsl:when>
            <xsl:when test="$mdFrequency = 'RI_538'">P6M</xsl:when>
            <xsl:when test="$mdFrequency = 'RI_539'">P1Y</xsl:when>
            <xsl:when test="$mdFrequency = 'RI_541'">irregular</xsl:when>
            <xsl:when test="$mdFrequency = 'RI_542'">not_planned</xsl:when>
            <xsl:when test="$mdFrequency = 'RI_543'">unknown</xsl:when>
            <xsl:otherwise>unknown</xsl:otherwise>
          </xsl:choose>
        </xsl:variable><frequency><xsl:value-of select="$ckanFrequency" /></frequency>

        <!-- TODO: Seem fixed values -->
        <license_id>ca-ogl-lgo</license_id>
        <restrictions>unrestricted</restrictions>
        <ready_to_publish>true</ready_to_publish>
        <jurisdiction>federal</jurisdiction>
        <imso_approval>true</imso_approval>
        <collection>fgp</collection>
        <catalog_type>Geo Data | G\u00e9o</catalog_type>
        <!-- TODO: Seem fixed values -->

        <topic_category>
          <xsl:for-each select="gmd:identificationInfo/*/gmd:topicCategory">
            <value><xsl:value-of select="gmd:MD_TopicCategoryCode" /></value>
          </xsl:for-each>
        </topic_category>

        <keywords>
          <xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword">
            <xsl:if test="string(gco:CharacterString) and string(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString)">
            <keyword>
              <xsl:choose>
                <xsl:when test="starts-with($mdLanguage, 'eng')">
                  <eng><xsl:value-of select="gco:CharacterString"/></eng>
                  <fre><xsl:value-of select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']"/></fre>
                </xsl:when>
                <xsl:otherwise>
                  <eng><xsl:value-of select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng']"/></eng>
                  <fre><xsl:value-of select="gmd:title/gco:CharacterString"/></fre>
                </xsl:otherwise>
              </xsl:choose>
            </keyword>
            </xsl:if>
          </xsl:for-each>
        </keywords>


        <xsl:choose>
          <xsl:when test="starts-with($mdLanguage, 'eng')">
            <title>
              <eng><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString"/></eng>
              <fre><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']"/></fre>
            </title>
            <notes>
              <eng><xsl:value-of select="gmd:identificationInfo/*/gmd:abstract/gco:CharacterString"/></eng>
              <fre><xsl:value-of select="gmd:identificationInfo/*/gmd:abstract/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']"/></fre>
            </notes>
          </xsl:when>
          <xsl:otherwise>
            <title>
              <eng><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng']"/></eng>
              <fre><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString"/></fre>
            </title>
            <notes>
              <fre><xsl:value-of select="gmd:identificationInfo/*/gmd:abstract/gco:CharacterString"/></fre>
              <eng><xsl:value-of select="gmd:identificationInfo/*/gmd:abstract/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng']"/></eng>
            </notes>
          </xsl:otherwise>
        </xsl:choose>


        <attribution_eng>Contains information licensed under the Open Government Licence \u2013 Canada.</attribution_eng>
        <attribution_fre>Contient des informations autoris\u00e9es sous la Licence du gouvernement ouvert- Canada</attribution_fre>


      
        <xsl:for-each select="//gmd:extent//gmd:EX_GeographicBoundingBox|//srv:extent//gmd:EX_GeographicBoundingBox">
          <xsl:variable name="minx" select="gmd:westBoundLongitude/gco:Decimal"/>
          <xsl:variable name="miny" select="gmd:southBoundLatitude/gco:Decimal"/>
          <xsl:variable name="maxx" select="gmd:eastBoundLongitude/gco:Decimal"/>
          <xsl:variable name="maxy" select="gmd:northBoundLatitude/gco:Decimal"/>
          <xsl:variable name="hasGeometry" select="($minx!='' and $miny!='' and $maxx!='' and $maxy!='' and (number($maxx)+number($minx)+number($maxy)+number($miny))!=0)"/>
          <xsl:variable name="geom" select="concat('POLYGON((', $minx, ' ', $miny,',',$maxx,' ',$miny,',',$maxx,' ',$maxy,',',$minx,' ',$maxy,',',$minx,' ',$miny, '))')"/>
          <xsl:if test="$hasGeometry">
            <spatial><xsl:value-of select="concat( '{' , '&quot;' , 'type', '&quot;', ':', '&quot;', 'Polygon', '&quot;', ',', '&quot;', 'coordinates', '&quot;', ': [[[', $minx, ', ', $miny, '], [', $maxx, ', ', $miny, '], [',  $maxx, ', ', $maxy, '], [',  $minx, ', ', $maxy, '], [', $minx, ', ', $miny, ']]]}')"/></spatial>
          </xsl:if>
        </xsl:for-each>

        <contacts>
          <xsl:for-each select="gmd:contact">
            <contact>
              <xsl:choose>
                <xsl:when test="starts-with($mdLanguage, 'eng')">
                  <eng>
                    <administrative_area><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea/gco:CharacterString"/></administrative_area>
                    <country><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country/gco:CharacterString"/></country>
                    <organization_name><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString"/></organization_name>
                    <phone><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/gco:CharacterString"/></phone>
                    <address><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint/gco:CharacterString"/></address>
                    <postal_code><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode/gco:CharacterString"/></postal_code>
                    <electronic_mail_address><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString"/></electronic_mail_address>
                  </eng>

                  <fre>
                    <administrative_area><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']"/></administrative_area>
                    <country><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']"/></country>
                    <organization_name><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:organisationName/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']"/></organization_name>
                    <phone><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']"/></phone>
                    <address><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']"/></address>
                    <postal_code><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode/gco:CharacterString"/></postal_code>
                    <electronic_mail_address><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']"/></electronic_mail_address>
                  </fre>
                </xsl:when>
                <xsl:otherwise>
                  <eng>
                    <administrative_area><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng']"/></administrative_area>
                    <country><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng']"/></country>
                    <organization_name><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:organisationName/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng']"/></organization_name>
                    <phone><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng']"/></phone>
                    <address><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng']"/></address>
                    <postal_code><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode/gco:CharacterString"/></postal_code>
                    <electronic_mail_address><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng']"/></electronic_mail_address>
                  </eng>

                  <fre>
                    <administrative_area><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea/gco:CharacterString"/></administrative_area>
                    <country><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country/gco:CharacterString"/></country>
                    <organization_name><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:administratiorganisationName/gco:CharacterString"/></organization_name>
                    <phone><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/gco:CharacterString"/></phone>
                    <address><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint/gco:CharacterString"/></address>
                    <postal_code><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode/gco:CharacterString"/></postal_code>
                    <electronic_mail_address><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString"/></electronic_mail_address>
                  </fre>

                </xsl:otherwise>
              </xsl:choose>
            </contact>
          </xsl:for-each>
        </contacts>
        
        <distributors>
        <xsl:for-each select="gmd:distributionInfo/*/gmd:distributor/*/gmd:distributorContact">
          <distributor>
          <xsl:choose>
            <xsl:when test="starts-with($mdLanguage, 'eng')">
              <eng>
                <administrative_area><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea/gco:CharacterString"/></administrative_area>
                <country><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country/gco:CharacterString"/></country>
                <organization_name><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString"/></organization_name>
                <phone><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/gco:CharacterString"/></phone>
                <address><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint/gco:CharacterString"/></address>
                <postal_code><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode/gco:CharacterString"/></postal_code>
                <electronic_mail_address><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString"/></electronic_mail_address>
              </eng>

              <fre>
                <administrative_area><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']"/></administrative_area>
                <country><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']"/></country>
                <organization_name><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:organisationName/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']"/></organization_name>
                <phone><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']"/></phone>
                <address><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']"/></address>
                <postal_code><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode/gco:CharacterString"/></postal_code>
                <electronic_mail_address><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']"/></electronic_mail_address>
              </fre>

            </xsl:when>
            <xsl:otherwise>
              <eng>
                <administrative_area><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng']"/></administrative_area>
                <country><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng']"/></country>
                <organization_name><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:organisationName/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng']"/></organization_name>
                <phone><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng']"/></phone>
                <address><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng']"/></address>
                <postal_code><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode/gco:CharacterString"/></postal_code>
                <electronic_mail_address><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng']"/></electronic_mail_address>
              </eng>
              <fre>
                <administrative_area><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea/gco:CharacterString"/></administrative_area>
                <country><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country/gco:CharacterString"/></country>
                <organization_name><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:administratiorganisationName/gco:CharacterString"/></organization_name>
                <phone><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/gco:CharacterString"/></phone>
                <address><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint/gco:CharacterString"/></address>
                <postal_code><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode/gco:CharacterString"/></postal_code>
                <electronic_mail_address><xsl:value-of select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString"/></electronic_mail_address>
              </fre>
            </xsl:otherwise>
          </xsl:choose>
          </distributor>
        </xsl:for-each>
        </distributors>
        
        <resources>
          <xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine">
            <resource>
              <url><xsl:value-of select="gmd:CI_OnlineResource/gmd:linkage/gmd:URL" /></url>
              <xsl:choose>
                <xsl:when test="starts-with($mdLanguage, 'eng')">
                  <name>
                    <eng><xsl:value-of select="gmd:CI_OnlineResource/gmd:name/gco:CharacterString" /></eng>
                    <fre><xsl:value-of select="gmd:CI_OnlineResource/gmd:name/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#fra']" /></fre>
                  </name>

                </xsl:when>
                <xsl:otherwise>
                  <name>
                    <eng><xsl:value-of select="gmd:CI_OnlineResource/gmd:name/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng']" /></eng>
                    <fre><xsl:value-of select="gmd:CI_OnlineResource/gmd:name/gco:CharacterString" /></fre>
                  </name>
                </xsl:otherwise>
              </xsl:choose>
              <protocol><xsl:value-of select="gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString" /></protocol>
              <xsl:variable name="description" select="gmd:CI_OnlineResource/gmd:description/gco:CharacterString" />

              <xsl:variable name="mdResourceType" select="normalize-space(tokenize($description, ';')[1])" />
              <xsl:variable name="ckanResourceType">
                <xsl:choose>
                  <xsl:when test="$mdResourceType = 'Dataset' or $mdResourceType = 'Données'">dataset</xsl:when>
                  <xsl:when test="$mdResourceType = 'Supporting Document' or $mdResourceType = 'Document de soutien'">specification</xsl:when>
                  <xsl:when test="$mdResourceType = 'API'">api</xsl:when>
                  <xsl:when test="$mdResourceType = 'Application'">application</xsl:when>
                  <xsl:when test="$mdResourceType = 'Web Service' or $mdResourceType = 'Service Web'">web_service</xsl:when>
                </xsl:choose>
              </xsl:variable>
              <resource_type><xsl:value-of select="$ckanResourceType" /></resource_type>
              <format><xsl:value-of select="tokenize($description, ';')[2]" /></format>
              <language><xsl:value-of select="substring(tokenize($description, ';')[3], 0, 3)" /></language>
            </resource>
          </xsl:for-each>
        </resources>


        <!-- Organization Name at Publication -->
        <org_title_at_publication></org_title_at_publication>

        <!-- Individual entities (persons) primarily responsible for making the dataset (separate multiple entities by commas). -->
        <creator></creator>


        <!-- contributor: names of entities (persons, groups, GC Departments or Agencies) that contributed to the dataset (separate multiple entities by commas).-->
        <contributor></contributor>

        <!-- The contact person's email for the dataset -->
        <maintainer_email></maintainer_email>

<!--
gmd:thesaurusName>
            <gmd:CI_Citation>
              <gmd:title>
                <gco:CharacterString>local.place.EC_Geographic_Scope</gco:CharacterString>
-->
        <!-- geographic_region: TODO: Use geographic scope, but seem same values -->
        <xsl:for-each select="//gmd:descriptiveKeywords/gmd:MD_Keywords[gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'local.place.EC_Geographic_Scope']/gmd:keyword">
          <xsl:variable name="geographicScope">
            <xsl:choose>
              <xsl:when test="starts-with($mdLanguage, 'eng')"><xsl:value-of select="gco:CharacterString" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#eng']" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <geographic_region></geographic_region>


          <program_page_url></program_page_url>
        </xsl:for-each>

        <digital_object_identifier><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString" /></digital_object_identifier>

      </dataset>
    </xsl:template>

</xsl:stylesheet>
