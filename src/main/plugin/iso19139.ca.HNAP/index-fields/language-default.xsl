<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:gml320="http://www.opengis.net/gml"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:ns2="http://www.w3.org/2004/02/skos/core#"
                xmlns:util="java:org.fao.geonet.util.XslUtil"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                exclude-result-prefixes="#all">

  <!-- This file defines what parts of the metadata are indexed by Lucene
       Searches can be conducted on indexes defined here.
       The Field@name attribute defines the name of the search variable.
     If a variable has to be maintained in the user session, it needs to be
     added to the GeoNetwork constants in the Java source code.
     Please keep indexes consistent among metadata standards if they should
     work accross different metadata resources -->
  <!-- ========================================================================================= -->

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
  <xsl:include href="../convert/functions.xsl"/>
  <xsl:include href="../../../xsl/utils-fn.xsl"/>


  <!-- ========================================================================================= -->

  <xsl:param name="thesauriDir"/>
  <xsl:param name="inspire">false</xsl:param>


  <!-- ========================================================================================= -->
  <xsl:variable name="isoDocLangId">
    <xsl:call-template name="langIdWithCountry19139"/>
  </xsl:variable>

  <xsl:variable name="mainLanguage">
    <xsl:call-template name="langId_from_gmdlanguage19139">
      <xsl:with-param name="gmdlanguage" select="/*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:language"/>
    </xsl:call-template>
  </xsl:variable>

  <!-- convert ISO 639-2T to_ISO 639-2B - i.e. FRA to FRE -->
  <xsl:variable name="mainLanguage_ISO639_2B">
    <xsl:choose>
      <xsl:when test="$mainLanguage ='fra'">
        <xsl:value-of select="'fre'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$mainLanguage"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="altLang_ISO639_2B">
    <xsl:choose>
      <xsl:when test="$mainLanguage = 'eng'">fre</xsl:when>
      <xsl:otherwise>eng</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="altLanguageId" select="/*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:locale/gmd:PT_Locale[gmd:languageCode/*/@codeListValue != $mainLanguage and (gmd:languageCode/*/@codeListValue = 'eng' or gmd:languageCode/*/@codeListValue = 'fra')]/@id"/>

  <xsl:variable name="government-names" select="document(concat('file:///', replace(concat($thesauriDir, '/local/thesauri/theme/GC_Org_Names.rdf'), '\\', '/')))"/>

  <xsl:variable name="useDateAsTemporalExtent" select="false()"/>

  <xsl:template match="/">

    <Documents>
      <xsl:for-each
        select="/*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:locale/gmd:PT_Locale">
        <xsl:variable name="langId" select="@id"/>
        <!--<xsl:variable name="isoLangId" select="java:twoCharLangCode(normalize-space(string(gmd:languageCode/gmd:LanguageCode/@codeListValue)))" />-->
        <xsl:variable name="isoLangId"
                      select="normalize-space(string(gmd:languageCode/gmd:LanguageCode/@codeListValue))"/>
        <xsl:if test="$isoLangId!=$isoDocLangId">
          <!-- get iso language code as ISO639 2B -->
          <xsl:variable name="isoLangId_ISO639_2B">
            <xsl:choose>
              <xsl:when test="$isoLangId = 'fra'">fre</xsl:when>
              <xsl:otherwise><xsl:value-of select="$isoLangId" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <Document locale="{$isoLangId_ISO639_2B}">

            <Field name="_locale" string="{$isoLangId}" store="true" index="true"/>
            <Field name="_docLocale" string="{$isoDocLangId}" store="true" index="true"/>

            <xsl:variable name="poundLangId" select="concat('#',$langId)"/>
            <xsl:variable name="_defaultTitle">
              <xsl:call-template name="defaultTitle">
                <xsl:with-param name="isoDocLangId" select="$isoLangId"/>
              </xsl:call-template>
            </xsl:variable>
            <!-- not tokenized title for sorting -->
            <Field name="_defaultTitle" string="{string($_defaultTitle)}" store="true" index="true"/>

            <xsl:apply-templates select="/*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']"
                                 mode="metadata">
              <xsl:with-param name="langId" select="$poundLangId"/>
              <xsl:with-param name="isoLangId" select="$isoLangId"/>
            </xsl:apply-templates>

          </Document>
        </xsl:if>
      </xsl:for-each>
    </Documents>
  </xsl:template>

  <!-- ========================================================================================= -->

  <xsl:template match="*" mode="metadata">
    <xsl:param name="langId"/>
    <xsl:param name="isoLangId"/>

    <!-- get iso language code as ISO639 2B -->
    <xsl:variable name="langCode_ISO639_2B">
      <xsl:choose>
        <xsl:when test="$isoLangId = 'fra'">fre</xsl:when>
        <xsl:otherwise><xsl:value-of select="$isoLangId" /></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:for-each select="gmd:dateStamp/gco:DateTime">
      <Field name="changeDate" string="{string(.)}" store="true" index="true"/>
    </xsl:for-each>

    <!-- Index gco:Date as is allowed also, GN uses gco:DateTime, but this case manages imported and not edited metadata -->
    <xsl:for-each select="gmd:dateStamp/gco:Date">
      <Field name="changeDate" string="{concat(string(.), 'T00:00:00')}" store="true" index="true"/>
    </xsl:for-each>

    <!-- === Data or Service Identification === -->

    <!-- the double // here seems needed to index MD_DataIdentification when
        it is nested in a SV_ServiceIdentification class -->

    <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification|
					gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']|
					gmd:identificationInfo/srv:SV_ServiceIdentification|
					gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']">

      <xsl:for-each select="gmd:citation/gmd:CI_Citation">

        <xsl:for-each select="gmd:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString">
          <Field name="identifier" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>

        <xsl:for-each select="gmd:identifier/gmd:RS_Identifier/gmd:code/gco:CharacterString">
          <Field name="identifier" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>

        <!-- not tokenized title for sorting -->
        <Field name="_defaultTitle" string="{string(gmd:title/gco:CharacterString)}" store="true"
               index="true"/>
        <!-- not tokenized title for sorting -->
        <Field name="_title"
               string="{string(gmd:title//gmd:LocalisedCharacterString[@locale=$langId])}"
               store="true" index="true"/>

        <xsl:for-each select="gmd:title//gmd:LocalisedCharacterString[@locale=$langId]">
          <Field name="title" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>

        <xsl:for-each select="gmd:alternateTitle//gmd:LocalisedCharacterString[@locale=$langId]">
          <Field name="altTitle" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>

        <xsl:for-each
          select="gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='RI_368']/gmd:date">
          <Field name="revisionDate" string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}" store="false" index="true"/>

          <Field name="createDateMonth"
                 string="{substring(gco:Date[.!='']|gco:DateTime[.!=''], 0, 8)}" store="true"
                 index="true"/>
          <Field name="createDateYear"
                 string="{substring(gco:Date[.!='']|gco:DateTime[.!=''], 0, 5)}" store="true"
                 index="true"/>

          <xsl:if test="$useDateAsTemporalExtent">
            <Field name="tempExtentBegin" string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}" store="false" index="true"/>
          </xsl:if>
        </xsl:for-each>

        <xsl:for-each
          select="gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='RI_366']/gmd:date">
          <Field name="createDate" string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}" store="true" index="true"/>

          <Field name="createDateMonth"
                 string="{substring(gco:Date[.!='']|gco:DateTime[.!=''], 0, 8)}" store="true"
                 index="true"/>
          <Field name="createDateYear"
                 string="{substring(gco:Date[.!='']|gco:DateTime[.!=''], 0, 5)}" store="true"
                 index="true"/>

          <xsl:if test="$useDateAsTemporalExtent">
            <Field name="tempExtentBegin" string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}" store="false" index="true"/>
          </xsl:if>
        </xsl:for-each>

        <xsl:for-each
          select="gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='RI_367']/gmd:date">
          <Field name="publicationDate" string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}" store="false" index="true"/>

          <xsl:if test="$useDateAsTemporalExtent">
            <Field name="tempExtentBegin" string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}" store="false" index="true"/>
          </xsl:if>
        </xsl:for-each>

        <!-- fields used to search for metadata in paper or digital format -->

        <xsl:for-each select="gmd:presentationForm">
          <xsl:if test="contains(gmd:CI_PresentationFormCode/@codeListValue, 'Digital')">
            <Field name="digital" string="true" store="true" index="true"/>
          </xsl:if>

          <xsl:if test="contains(gmd:CI_PresentationFormCode/@codeListValue, 'Hardcopy')">
            <Field name="paper" string="true" store="true" index="true"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:for-each select="gmd:abstract//gmd:LocalisedCharacterString[@locale=$langId]">
        <Field name="abstract" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>
      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:for-each select="*/gmd:EX_Extent">
        <xsl:apply-templates select="gmd:geographicElement/gmd:EX_GeographicBoundingBox"
                             mode="latLon"/>

        <xsl:for-each
          select="gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code//gmd:LocalisedCharacterString[@locale=$langId]">
          <Field name="geoDescCode" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>

        <xsl:for-each select="gmd:description//gmd:LocalisedCharacterString[@locale=$langId]">
          <Field name="extentDesc" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>

        <xsl:for-each select="gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent|
          gmd:temporalElement/gmd:EX_SpatialTemporalExtent/gmd:extent">
          <xsl:for-each select="gml:TimePeriod/gml:beginPosition|gml320:TimePeriod/gml320:beginPosition">
            <Field name="tempExtentBegin" string="{string(.)}" store="true" index="true"/>
          </xsl:for-each>

          <xsl:for-each select="gml:TimePeriod/gml:endPosition|gml320:TimePeriod/gml320:endPosition">
            <Field name="tempExtentEnd" string="{string(.)}" store="true" index="true"/>
          </xsl:for-each>

          <xsl:for-each select="gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition|gml320:TimePeriod/gml320:begin/gml320:TimeInstant/gml320:timePosition">
            <Field name="tempExtentBegin" string="{string(.)}" store="true" index="true"/>
          </xsl:for-each>

          <xsl:for-each select="gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition|gml320:TimePeriod/gml320:end/gml320:TimeInstant/gml320:timePosition">
            <Field name="tempExtentEnd" string="{string(.)}" store="true" index="true"/>
          </xsl:for-each>

          <xsl:for-each select="gml:TimeInstant/gml:timePosition|gml320:TimeInstant/gml320:timePosition">
            <Field name="tempExtentBegin" string="{string(.)}" store="true" index="true"/>
            <Field name="tempExtentEnd" string="{string(.)}" store="true" index="true"/>
          </xsl:for-each>

        </xsl:for-each>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:for-each select="*/gmd:MD_Keywords">
        <xsl:for-each select="gmd:keyword//gmd:LocalisedCharacterString[@locale=$langId]">
          <xsl:variable name="keyword" select="string(.)"/>

          <Field name="keyword" string="{$keyword}" store="true" index="true"/>
        </xsl:for-each>

        <xsl:for-each select="gmd:type/gmd:MD_KeywordTypeCode/@codeListValue">
          <Field name="keywordType" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>
      </xsl:for-each>


      <xsl:if test="count(//gmd:keyword//gmd:LocalisedCharacterString[@locale = $langId and text() != '']) > 0">
        <xsl:variable name="listOfKeywords">{
          <xsl:variable name="keywordWithNoThesaurus"
                        select="//gmd:MD_Keywords[
                                  not(gmd:thesaurusName) or gmd:thesaurusName/*/gmd:title/gmd:LocalisedCharacterString[@locale = $langId]/text() = '']/
                                    gmd:keyword[.//gmd:LocalisedCharacterString[@locale=$langId]/text() != '']"/>
          <xsl:for-each-group select="//gmd:MD_Keywords[
                                        gmd:thesaurusName/*/gmd:title//gmd:LocalisedCharacterString[@locale = $langId]/text() != '' and
                                        count(gmd:keyword//gmd:LocalisedCharacterString[@locale = $langId and text() != '']) > 0]"
                              group-by="gmd:thesaurusName/*/gmd:title//gmd:LocalisedCharacterString[@locale = $langId]/text()">

            '<xsl:value-of select="replace(current-grouping-key(), '''', '\\''')"/>' :[
            <xsl:for-each select="current-group()/gmd:keyword//gmd:LocalisedCharacterString[@locale = $langId and text() != '']">
              {'value': <xsl:value-of select="concat('''', replace(., '''', '\\'''), '''')"/>,
              'link': '<xsl:value-of select="@xlink:href"/>'}
              <xsl:if test="position() != last()">,</xsl:if>
            </xsl:for-each>
            ]
            <xsl:if test="position() != last()">,</xsl:if>
          </xsl:for-each-group>
          <xsl:if test="count($keywordWithNoThesaurus) > 0">
            <xsl:if test="count(//gmd:MD_Keywords[gmd:thesaurusName/*/gmd:title/*/text() != '']) > 0">,</xsl:if>
            'otherKeywords': [
            <xsl:for-each select="$keywordWithNoThesaurus//gmd:LocalisedCharacterString[@locale = $langId and text() != '']">
              {'value': <xsl:value-of select="concat('''', replace(., '''', '\\'''), '''')"/>,
              'link': '<xsl:value-of select="@xlink:href"/>'}
              <xsl:if test="position() != last()">,</xsl:if>
            </xsl:for-each>
            ]
          </xsl:if>
          }
        </xsl:variable>

        <Field name="keywordGroup"
               string="{normalize-space($listOfKeywords)}"
               store="true"
               index="false"/>
      </xsl:if>
      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:for-each select="gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName//gmd:LocalisedCharacterString[@locale=$langId]">
          <Field name="orgName" string="{string(.)}" store="true" index="true"/>
          <Field name="_orgName" string="{string(.)}" store="true" index="true"/>

          <xsl:variable name="role"    select="../../../../gmd:role/*/@codeListValue"/>
          <xsl:variable name="roleTranslation" select="util:getCodelistTranslation('gmd:CI_RoleCode', string($role), string($langCode_ISO639_2B))"/>
          <xsl:variable name="logo"    select="../../../..//gmx:FileName/@src"/>
          <xsl:variable name="email"   select="../../../../gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress//gmd:LocalisedCharacterString[@locale=$langId]"/>
          <xsl:variable name="phone"   select="../../../../gmd:contactInfo/*/gmd:phone/*/gmd:voice//gmd:LocalisedCharacterString[@locale=$langId]"/>
          <xsl:variable name="individualName" select="../../../../gmd:individualName/gco:CharacterString/text()"/>
          <xsl:variable name="positionName"   select="../../../../gmd:positionName//gmd:LocalisedCharacterString[@locale=$langId]"/>

          <xsl:variable name="deliveryPoint"   select="../../../../gmd:contactInfo/*/gmd:address/*/gmd:deliveryPoint//gmd:LocalisedCharacterString[@locale=$langId]/text()"/>
          <xsl:variable name="postalCode"   select="../../../../gmd:contactInfo/*/gmd:address/*/gmd:postalCode/gco:CharacterString/text()"/>
          <xsl:variable name="city"   select="../../../../gmd:contactInfo/*/gmd:address/*/gmd:city/gco:CharacterString/text()"/>
          <xsl:variable name="administrativeArea"   select="../../../../gmd:contactInfo/*/gmd:address/*/gmd:administrativeArea//gmd:LocalisedCharacterString[@locale=$langId]/text()"/>
          <xsl:variable name="country"   select="../../../../gmd:contactInfo/*/gmd:address/*/gmd:country//gmd:LocalisedCharacterString[@locale=$langId]/text()"/>

          <xsl:variable name="address" select="string-join(($deliveryPoint, $postalCode, $city, $administrativeArea, $country), ', ')"/>

          <Field name="responsibleParty"
                 string="{concat($roleTranslation, '|resource|', ., '|', $logo, '|',  string-join($email, ','), '|', $individualName, '|', $positionName, '|', $address, '|', string-join($phone, ','))}"
                 store="true" index="false"/>
      </xsl:for-each>

      <xsl:for-each select="gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:individualName/gco:CharacterString|
  gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:individualFirstName/gco:CharacterString|
  gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:individualLastName/gco:CharacterString">
          <Field name="creator" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:for-each
              select="gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:organisationName">

        <xsl:variable name="orgName" select="gco:CharacterString" />

        <xsl:if test="$government-names//rdf:Description[starts-with(normalize-space(lower-case($orgName)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang='en'])), ';'))] or
                      $government-names//rdf:Description[starts-with(normalize-space(lower-case($orgName)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang='fr'])), ';'))]">
          <!--<Field name="orgNameCanada" string="{string(normalize-space(tokenize(., ';')[2]))}" store="true" index="true"/>-->

          <Field name="orgNameCanada_{$mainLanguage_ISO639_2B}"
                 string="{string(normalize-space(tokenize(gco:CharacterString, ';')[2]))}" store="true" index="true"/>
        </xsl:if>

        <xsl:variable name="orgNameAlt" select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)]" />

        <xsl:if test="$government-names//rdf:Description[starts-with(normalize-space(lower-case($orgNameAlt)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang='en'])), ';'))] or
                      $government-names//rdf:Description[starts-with(normalize-space(lower-case($orgNameAlt)), concat(normalize-space(lower-case(ns2:prefLabel[@xml:lang='fr'])), ';'))]">
        <Field name="orgNameCanada_{$altLang_ISO639_2B}"
                 string="{string(normalize-space(tokenize(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#', $altLanguageId)], ';')[2]))}"
                 store="true" index="true"/>
        </xsl:if>

      </xsl:for-each>


      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:choose>
        <xsl:when test="gmd:resourceConstraints/gmd:MD_SecurityConstraints">
          <xsl:variable name="securityConstraints" select="gmd:resourceConstraints/gmd:MD_SecurityConstraints[1]"/>
          <xsl:variable name="securityClassification" select="util:getCodelistTranslation($securityConstraints/gmd:classification/gmd:MD_ClassificationCode/name(), string($securityConstraints/gmd:classification/gmd:MD_ClassificationCode/@codeListValue), string($langCode_ISO639_2B))"/>
          <Field name="secConstr" string="true" store="true" index="true"/>
          <Field name="secUserNote" string="{$securityConstraints/gmd:userNote//gmd:LocalisedCharacterString[@locale=$langId]}" store="true" index="true"/>
          <!-- put secUserNote in MD_SecurityConstraintsUseLimitation so that it can be displayed on the view page -->

          <xsl:variable name="securityConstraintsUseLimitation">
            <xsl:value-of select="$securityClassification"/>
            <xsl:choose>
              <xsl:when test="$securityConstraints/gmd:userNote//gmd:LocalisedCharacterString[@locale=$langId] !='' and $securityConstraints/gmd:userNote//gmd:LocalisedCharacterString[@locale=$langId] != $securityClassification">
                <xsl:value-of select="concat('; ', $securityConstraints/gmd:userNote//gmd:LocalisedCharacterString[@locale=$langId])"/>
              </xsl:when>
            </xsl:choose>
          </xsl:variable>

          <Field name="MD_SecurityConstraintsUseLimitation" string="{$securityConstraintsUseLimitation}" store="true" index="true"/>
        </xsl:when>
        <xsl:otherwise>
          <Field name="secConstr" string="false" store="true" index="true"/>
          <xsl:variable name="securityConstraintsUseLimitation" select="if ($isoLangId = 'fra') then 'Inconnu' else 'Unknown'"/>
          <Field name="MD_SecurityConstraintsUseLimitation" string="{$securityConstraintsUseLimitation}" store="true" index="true"/>
        </xsl:otherwise>
      </xsl:choose>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:for-each select="gmd:topicCategory/gmd:MD_TopicCategoryCode">
        <Field name="topicCat" string="{string(.)}" store="true" index="true"/>
        <Field name="subject" string="{string(.)}" store="true" index="true"/>
        <Field name="keyword"
               string="{util:getCodelistTranslation('gmd:MD_TopicCategoryCode', string(.), string($isoLangId))}"
               store="true"
               index="true"/>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:for-each select="gmd:language/gco:CharacterString">
        <Field name="datasetLang" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:for-each select="gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode/@codeListValue">
        <Field name="spatialRepresentation" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:for-each select="gmd:spatialResolution/gmd:MD_Resolution">
        <xsl:for-each
          select="gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer">
          <Field name="denominator" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>

        <xsl:for-each select="gmd:distance/gco:Distance">
          <Field name="distanceVal" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>

        <xsl:for-each select="gmd:distance/gco:Distance/@uom">
          <Field name="distanceUom" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>

        <xsl:for-each select="gmd:distance/gco:Distance">
          <!-- Units may be encoded as
          http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/uom/ML_gmxUom.xml#m
          in such case retrieve the unit acronym only. -->
          <xsl:variable name="unit"
                        select="if (contains(@uom, '#')) then substring-after(@uom, '#') else @uom"/>
          <Field name="resolution" string="{concat(string(.), ' ', $unit)}" store="true"
                 index="true"/>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="gmd:resourceMaintenance/
                                gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency/
                                gmd:MD_MaintenanceFrequencyCode/@codeListValue[. != '']">
        <Field name="updateFrequency" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:for-each select="gmd:graphicOverview/gmd:MD_BrowseGraphic">
        <xsl:variable name="fileName" select="gmd:fileName/gco:CharacterString"/>
        <xsl:if test="$fileName != ''">

          <xsl:variable name="thumbnailType" select="if (position() = 1) then 'thumbnail' else 'overview'"/>

          <!-- choose the best language text.  Use the  LocalisedCharacterString (if available) otherwise use the main-language (CharacterString) -->
          <xsl:variable name="fileDescrMainLang" select="normalize-space(gmd:fileDescription/gco:CharacterString)"/>
          <xsl:variable name="fileDescrAltLang" select="normalize-space(gmd:fileDescription/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=$langId])"/>

          <xsl:variable name="fileDescr">
            <xsl:choose>
              <xsl:when test="$fileDescrAltLang"><xsl:value-of select="$fileDescrAltLang"/></xsl:when>
              <xsl:otherwise><xsl:value-of select="$fileDescrMainLang"/></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <Field name="image"
                 string="{concat($thumbnailType, '|', $fileName, '|', $fileDescr)}"
                 store="true" index="false"/>

        </xsl:if>
      </xsl:for-each>


      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
      <!--  Fields use to search on Service -->

      <xsl:for-each select="srv:serviceType/gco:LocalName[string(.)]">
        <Field name="serviceType" string="{string(.)}" store="true" index="true"/>
        <Field name="type" string="service-{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <xsl:for-each select="srv:serviceTypeVersion/gco:CharacterString">
        <Field name="serviceTypeVersion" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <xsl:for-each select="//srv:SV_OperationMetadata/srv:operationName/gco:CharacterString">
        <Field name="operation" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <xsl:for-each select="srv:operatesOn/@uuidref">
        <Field name="operatesOn" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <xsl:for-each select="srv:coupledResource">
        <xsl:for-each select="srv:SV_CoupledResource/srv:identifier/gco:CharacterString">
          <Field name="operatesOnIdentifier" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>

        <xsl:for-each select="srv:SV_CoupledResource/srv:operationName/gco:CharacterString">
          <Field name="operatesOnName" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="//srv:SV_CouplingType/srv:code/@codeListValue">
        <Field name="couplingType" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

    </xsl:for-each>

    <xsl:variable name="numMapResources" select="count(gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[contains(lower-case(gmd:protocol/gco:CharacterString), 'ogc:wms')]) +
                                          count(gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[contains(lower-case(gmd:protocol/gco:CharacterString), 'rest')])"/>

    <xsl:choose>
      <xsl:when test="$numMapResources &gt; 0">
        <Field name="_mdType" string="map" store="true" index="true"/>
      </xsl:when>
      <xsl:otherwise>
        <Field name="_mdType" string="nomap" store="true" index="true"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:for-each
            select="gmd:contact/*/gmd:organisationName//gmd:LocalisedCharacterString[@locale=$langId]">
      <Field name="metadataPOC" string="{string(.)}" store="false" index="true"/>

      <xsl:variable name="role"    select="../../../../gmd:role/*/@codeListValue"/>
      <xsl:variable name="roleTranslation" select="util:getCodelistTranslation('gmd:CI_RoleCode', string($role), string($langCode_ISO639_2B))"/>
      <xsl:variable name="logo"    select="../../../..//gmx:FileName/@src"/>
      <xsl:variable name="email"   select="../../../../gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress//gmd:LocalisedCharacterString[@locale=$langId]"/>
      <xsl:variable name="phone"   select="../../../../gmd:contactInfo/*/gmd:phone/*/gmd:voice//gmd:LocalisedCharacterString[@locale=$langId]"/>
      <xsl:variable name="individualName" select="../../../../gmd:individualName/gco:CharacterString/text()"/>
      <xsl:variable name="positionName"   select="../../../../gmd:positionName//gmd:LocalisedCharacterString[@locale=$langId]"/>

      <xsl:variable name="deliveryPoint"   select="../../../../gmd:contactInfo/*/gmd:address/*/gmd:deliveryPoint//gmd:LocalisedCharacterString[@locale=$langId]"/>
      <xsl:variable name="postalCode"   select="../../../../gmd:contactInfo/*/gmd:address/*/gmd:postalCode/gco:CharacterString/text()"/>
      <xsl:variable name="city"   select="../../../../gmd:contactInfo/*/gmd:address/*/gmd:city/gco:CharacterString/text()"/>
      <xsl:variable name="administrativeArea"   select="../../../../gmd:contactInfo/*/gmd:address/*/gmd:administrativeArea//gmd:LocalisedCharacterString[@locale=$langId]"/>
      <xsl:variable name="country"   select="../../../../gmd:contactInfo/*/gmd:address/*/gmd:country//gmd:LocalisedCharacterString[@locale=$langId]"/>

      <xsl:variable name="address" select="string-join(($deliveryPoint, $postalCode, $city, $administrativeArea, $country), ', ')"/>

      <Field name="responsibleParty"
             string="{concat($roleTranslation, '|metadata|', ., '|', $logo, '|',  string-join($email, ','), '|', $individualName, '|', $positionName, '|', $address, '|', string-join($phone, ','))}"
             store="true" index="false"/>
    </xsl:for-each>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- === Distribution === -->


    <xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution">
      <xsl:for-each
              select="gmd:distributionFormat/gmd:MD_Format/gmd:name//gmd:LocalisedCharacterString[@locale=$langId]">
        <Field name="format" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <!-- index online protocol -->

      <xsl:for-each
              select="gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[gmd:linkage/gmd:URL!='']">

        <xsl:variable name="download_check">
          <xsl:text>&amp;fname=&amp;access</xsl:text>
        </xsl:variable>
        <xsl:variable name="linkage" select="gmd:linkage/gmd:URL"/>
        <xsl:variable name="title" select="normalize-space(gmd:name//gmd:LocalisedCharacterString[@locale=$langId]|gmd:name/gmx:MimeFileType)"/>
        <xsl:variable name="desc" select="normalize-space(gmd:description//gmd:LocalisedCharacterString[@locale=$langId])"/>
        <xsl:variable name="protocol" select="normalize-space(gmd:protocol/gco:CharacterString)"/>
        <xsl:variable name="mimetype"
                      select="geonet:protocolMimeType($linkage, $protocol, gmd:name/gmx:MimeFileType/@type)"/>

        <!-- ignore empty downloads -->
        <xsl:if test="string($linkage)!='' and not(contains($linkage,$download_check))">
          <Field name="protocol" string="{string($protocol)}" store="false" index="true"/>
        </xsl:if>

        <xsl:if test="normalize-space($mimetype)!=''">
          <Field name="mimetype" string="{$mimetype}" store="false" index="true"/>
        </xsl:if>

        <xsl:if test="contains($protocol, 'WWW:DOWNLOAD')">
          <Field name="download" string="true" store="false" index="true"/>
        </xsl:if>

        <xsl:if test="contains($protocol, 'OGC:WMS')">
          <Field name="dynamic" string="true" store="false" index="true"/>
        </xsl:if>
        <Field name="link" string="{concat($title, '|', $desc, '|', $linkage, '|', $protocol, '|', $mimetype)}"
               store="true" index="false"/>

        <!-- Add KML link if WMS -->
        <xsl:if test="starts-with($protocol,'OGC:WMS-') and contains($protocol,'-get-map') and string($linkage)!='' and string($title)!=''">
          <!-- FIXME : relative path -->
          <Field name="link" string="{concat($title, '|', $desc, '|',
						'../../srv/en/google.kml?uuid=', /gmd:MD_Metadata/gmd:fileIdentifier/gco:CharacterString, '&amp;layers=', $title,
						'|application/vnd.google-earth.kml+xml|application/vnd.google-earth.kml+xml')}" store="true" index="false"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>


    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- === Service stuff ===  -->
    <!-- Service type           -->
    <xsl:for-each select="gmd:identificationInfo/srv:SV_ServiceIdentification/srv:serviceType/gco:LocalName|
			gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/srv:serviceType/gco:LocalName">
      <Field name="serviceType" string="{string(.)}" store="true" index="true"/>
    </xsl:for-each>

    <!-- Service version        -->
    <xsl:for-each select="gmd:identificationInfo/srv:SV_ServiceIdentification/srv:serviceTypeVersion/gco:CharacterString|
			gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/srv:serviceTypeVersion/gco:CharacterString">
      <Field name="serviceTypeVersion" string="{string(.)}" store="true" index="true"/>
    </xsl:for-each>


    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- === General stuff === -->

    <xsl:choose>
      <xsl:when test="gmd:hierarchyLevel">
        <xsl:for-each select="gmd:hierarchyLevel/gmd:MD_ScopeCode">
          <Field name="type" string="{string(tokenize(., ';')[1])}" store="true" index="true"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <Field name="type" string="dataset" store="true" index="true"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
      <xsl:when test="gmd:identificationInfo/srv:SV_ServiceIdentification">
        <Field name="type" string="service" store="false" index="true"/>
      </xsl:when>
      <!-- <xsl:otherwise>
       ... gmd:*_DataIdentification / hierachicalLevel is used and return dataset, serie, ...
       </xsl:otherwise>-->
    </xsl:choose>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <xsl:for-each select="gmd:hierarchyLevelName//gmd:LocalisedCharacterString[@locale=$langId]">
      <Field name="levelName" string="{string(.)}" store="true" index="true"/>
    </xsl:for-each>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <xsl:for-each select="gmd:fileIdentifier/gco:CharacterString">
      <Field name="fileId" string="{string(.)}" store="true" index="true"/>
    </xsl:for-each>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <xsl:for-each select="gmd:parentIdentifier/gco:CharacterString">
      <Field name="parentUuid" string="{string(.)}" store="true" index="true"/>
    </xsl:for-each>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- === Reference system info === -->

    <xsl:for-each select="gmd:referenceSystemInfo/gmd:MD_ReferenceSystem">
      <xsl:for-each select="gmd:referenceSystemIdentifier/gmd:RS_Identifier">
        <xsl:variable name="crs"
                      select="concat(string(gmd:codeSpace/gco:CharacterString),'::',string(gmd:code/gco:CharacterString))"/>

        <xsl:if test="$crs != '::'">
          <Field name="crs" string="{$crs}" store="true" index="true"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- === Free text search === -->
    <Field name="any" store="false" index="true">
      <xsl:attribute name="string">
        <xsl:for-each select="//node()[@locale=$langId]">
          <xsl:value-of select="concat(normalize-space(.), ' ')"/>
        </xsl:for-each>
        <xsl:text> </xsl:text>
        <xsl:for-each select="//@codeListValue">
          <xsl:value-of select="concat(., ' ')"/>
        </xsl:for-each>
        <xsl:text> </xsl:text>
        <xsl:for-each select="//gmd:fileIdentifier/gco:CharacterString">
          <xsl:value-of select="concat(., ' ')"/>
        </xsl:for-each>
      </xsl:attribute>
    </Field>

    <!-- Index all codelist -->
    <xsl:for-each select=".//*[*/@codeListValue != '']">
      <Field name="cl_{local-name()}"
             string="{*/@codeListValue}"
             store="true" index="true"/>
      <Field name="cl_{concat(local-name(), '_text')}"
             string="{util:getCodelistTranslation(name(*), string(*/@codeListValue), string($altLang_ISO639_2B))}"
             store="true" index="true"/>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
