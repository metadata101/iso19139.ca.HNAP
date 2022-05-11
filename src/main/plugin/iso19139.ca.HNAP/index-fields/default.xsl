<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:gml320="http://www.opengis.net/gml"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:ns2="http://www.w3.org/2004/02/skos/core#"
                xmlns:util="java:org.fao.geonet.util.XslUtil"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                version="2.0"
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

  <xsl:variable name="inspire-thesaurus"
                select="if ($inspire!='false') then document(concat('file:///', $thesauriDir, '/external/thesauri/theme/inspire-theme.rdf')) else ''"/>
  <xsl:variable name="inspire-theme" select="if ($inspire!='false') then $inspire-thesaurus//skos:Concept else ''"/>

  <xsl:variable name="government-names" select="document(concat('file:///', replace(concat($thesauriDir, '/local/thesauri/theme/GC_Government_Names.rdf'), '\\', '/')))"/>

  <!-- If identification creation, publication and revision date
    should be indexed as a temporal extent information (eg. in INSPIRE
    metadata implementing rules, those elements are defined as part
    of the description of the temporal extent). -->
  <xsl:variable name="useDateAsTemporalExtent" select="false()"/>

  <!-- Define the way keyword and thesaurus are indexed. If false
  only keyword, thesaurusName and thesaurusType field are created.
  If true, advanced field are created to make more details query
  on keyword type and search by thesaurus. Index size is bigger
  but more detailed facet can be configured based on each thesaurus.
  -->
  <xsl:variable name="indexAllKeywordDetails" select="true()"/>

  <!-- For record not having status obsolete, flag them as non
  obsolete records. Some catalog like to restrict to non obsolete
  records only the default search. -->
  <xsl:variable name="flagNonObseleteRecords" select="false()"/>

  <!-- Choose if WMS should be also indexed
  as a KML layers to be loaded in GoogleEarth -->
  <xsl:variable name="indexWmsAsKml" select="false()"/>


  <!-- The main metadata language -->
  <xsl:variable name="isoLangId">
    <xsl:call-template name="langIdWithCountry19139"/>
  </xsl:variable>

  <!-- get iso language code as ISO639 2B -->
  <xsl:variable name="langCode_ISO639_2B">
    <xsl:choose>
      <xsl:when test="$isoLangId = 'fra'">fre</xsl:when>
      <xsl:otherwise><xsl:value-of select="$isoLangId" /></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- ========================================================================================= -->
  <xsl:template match="/">
    <Document locale="{$isoLangId}">
      <Field name="_locale" string="{$isoLangId}" store="true" index="true"/>

      <Field name="_docLocale" string="{$isoLangId}" store="true" index="true"/>

      <xsl:variable name="_defaultTitle">
        <xsl:call-template name="defaultTitle">
          <xsl:with-param name="isoDocLangId" select="$isoLangId"/>
        </xsl:call-template>
      </xsl:variable>
      <!-- not tokenized title for sorting, needed for multilingual sorting -->
      <Field name="_defaultTitle" string="{string($_defaultTitle)}" store="true" index="true"/>

      <xsl:apply-templates select="*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']" mode="metadata"/>
    </Document>
  </xsl:template>

  <!-- ========================================================================================= -->

  <xsl:template match="*" mode="metadata">

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


        <xsl:for-each select="gmd:title/gco:CharacterString">
          <Field name="title" string="{string(.)}" store="true" index="true"/>
          <!-- not tokenized title for sorting -->
          <Field name="_title" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>

        <xsl:for-each select="gmd:alternateTitle/gco:CharacterString">
          <Field name="altTitle" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>

        <xsl:for-each
                select="gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='RI_368']/gmd:date">
          <Field name="revisionDate" string="{string(gco:Date|gco:DateTime)}" store="false" index="true"/>
          <xsl:if test="$useDateAsTemporalExtent">
            <Field name="tempExtentBegin" string="{string(gco:Date|gco:DateTime)}" store="false" index="true"/>
          </xsl:if>
        </xsl:for-each>

        <xsl:for-each
                select="gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='RI_366']/gmd:date">
          <Field name="createDate" string="{string(gco:Date|gco:DateTime)}" store="true" index="true"/>
          <xsl:if test="$useDateAsTemporalExtent">
            <Field name="tempExtentBegin" string="{string(gco:Date|gco:DateTime)}" store="false" index="true"/>
          </xsl:if>
        </xsl:for-each>

        <xsl:for-each
                select="gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='RI_367']/gmd:date">
          <Field name="publicationDate" string="{string(gco:Date|gco:DateTime)}" store="false" index="true"/>
          <xsl:if test="$useDateAsTemporalExtent">
            <Field name="tempExtentBegin" string="{string(gco:Date|gco:DateTime)}" store="false" index="true"/>
          </xsl:if>
        </xsl:for-each>

        <!-- fields used to search for metadata in paper or digital format -->

        <xsl:for-each select="gmd:presentationForm">
          <Field name="presentationForm" string="{gmd:CI_PresentationFormCode/@codeListValue}" store="true"
                 index="true"/>

          <xsl:if test="contains(gmd:CI_PresentationFormCode/@codeListValue, 'Digital')">
            <Field name="digital" string="true" store="false" index="true"/>
          </xsl:if>

          <xsl:if test="contains(gmd:CI_PresentationFormCode/@codeListValue, 'Hardcopy')">
            <Field name="paper" string="true" store="false" index="true"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:for-each select="gmd:pointOfContact[1]/*/gmd:role/*/@codeListValue">
        <Field name="responsiblePartyRole" string="{string(.)}" store="false" index="true"/>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:for-each select="gmd:abstract/gco:CharacterString">
        <Field name="abstract" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:for-each select="gmd:status/gmd:MD_ProgressCode/@codeListValue">
        <Field name="status" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>


      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:for-each select="*/gmd:EX_Extent">
        <xsl:apply-templates select="gmd:geographicElement/gmd:EX_GeographicBoundingBox" mode="latLon"/>

        <xsl:for-each
                select="gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString">
          <Field name="geoDescCode" string="{string(.)}" store="false" index="true"/>
        </xsl:for-each>

        <xsl:for-each select="gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent">
          <xsl:for-each select="gml:TimePeriod">
            <xsl:variable name="times">
              <xsl:call-template name="newGmlTime">
                <xsl:with-param name="begin" select="gml:beginPosition|gml:begin/gml:TimeInstant/gml:timePosition"/>
                <xsl:with-param name="end" select="gml:endPosition|gml:end/gml:TimeInstant/gml:timePosition"/>
              </xsl:call-template>
            </xsl:variable>

            <Field name="tempExtentBegin" string="{lower-case(substring-before($times,'|'))}" store="false"
                   index="true"/>
            <Field name="tempExtentEnd" string="{lower-case(substring-after($times,'|'))}" store="false" index="true"/>
          </xsl:for-each>

        </xsl:for-each>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:for-each select="//gmd:MD_Keywords">

        <!-- Index all keywords as text or anchor -->
        <xsl:variable name="listOfKeywords"
                      select="gmd:keyword/gco:CharacterString|
                                        gmd:keyword/gmx:Anchor"/>
        <xsl:variable name="thesaurusName" select="gmd:thesaurusName/gmd:CI_Citation/gmd:title/*[1]"/>

        <xsl:for-each select="$listOfKeywords">
          <xsl:variable name="keyword" select="string(.)"/>

          <Field name="keyword" string="{$keyword}" store="true" index="true"/>

          <!-- If INSPIRE is enabled, check if the keyword is one of the 34 themes
               and index annex, theme and theme in english. -->
          <xsl:if test="$inspire='true' and normalize-space(lower-case($thesaurusName)) = 'gemet - inspire themes, version 1.0'">

            <xsl:if test="string-length(.) &gt; 0">

              <xsl:variable name="inspireannex">
                <xsl:call-template name="determineInspireAnnex">
                  <xsl:with-param name="keyword" select="$keyword"/>
                  <xsl:with-param name="inspireThemes" select="$inspire-theme"/>
                </xsl:call-template>
              </xsl:variable>

              <!-- Add the inspire field if it's one of the 34 themes -->
              <xsl:if test="normalize-space($inspireannex)!=''">
                <!-- Maybe we should add the english version to the index to not take the language into account
                or create one field in the metadata language and one in english ? -->
                <Field name="inspiretheme" string="{string(.)}" store="false" index="true"/>
                <Field name="inspireannex" string="{$inspireannex}" store="false" index="true"/>
                <!-- FIXME : inspirecat field will be set multiple time if one record has many themes -->
                <Field name="inspirecat" string="true" store="false" index="true"/>
              </xsl:if>
            </xsl:if>
          </xsl:if>
        </xsl:for-each>

        <!-- Index thesaurus name to easily search for records
        using keyword from a thesaurus. -->
        <xsl:for-each select="gmd:thesaurusName/gmd:CI_Citation">
          <xsl:variable name="thesaurusIdentifier"
                        select="gmd:identifier/gmd:MD_Identifier/gmd:code/gmx:Anchor/text()"/>

          <xsl:if test="$thesaurusIdentifier != ''">
            <Field name="thesaurusIdentifier"
                   string="{substring-after($thesaurusIdentifier,'geonetwork.thesaurus.')}"
                   store="false" index="true"/>
          </xsl:if>
          <xsl:if test="gmd:title/gco:CharacterString/text() != ''">
            <Field name="thesaurusName"
                   string="{gmd:title/gco:CharacterString/text()}"
                   store="false" index="true"/>
          </xsl:if>


          <xsl:if test="$indexAllKeywordDetails and $thesaurusIdentifier != ''">
            <!-- field thesaurus-{{thesaurusIdentifier}}={{keyword}} allows
            to group all keywords of same thesaurus in a field -->
            <xsl:variable name="currentType" select="string(.)"/>

            <xsl:for-each select="$listOfKeywords">
              <Field
                name="thesaurus-{substring-after($thesaurusIdentifier,'geonetwork.thesaurus.')}"
                string="{string(.)}"
                store="true" index="true"/>

            </xsl:for-each>
          </xsl:if>
        </xsl:for-each>

        <!-- Index thesaurus type -->
        <xsl:for-each select="gmd:type/gmd:MD_KeywordTypeCode/@codeListValue">
          <Field name="keywordType" string="{string(.)}" store="false" index="true"/>
          <xsl:if test="$indexAllKeywordDetails">
            <!-- field thesaurusType{{type}}={{keyword}} allows
            to group all keywords of same type in a field -->
            <xsl:variable name="currentType" select="string(.)"/>
            <xsl:for-each select="$listOfKeywords">
              <Field name="keywordType-{$currentType}"
                     string="{string(.)}"
                     store="false" index="true"/>
            </xsl:for-each>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:variable name="listOfKeywords">{
        <xsl:variable name="keywordWithNoThesaurus"
                      select="//gmd:MD_Keywords[
                                not(gmd:thesaurusName) or gmd:thesaurusName/*/gmd:title/(gco:CharacterString|gmx:Anchor)/text() = '']/
                                  gmd:keyword[*/text() != '']"/>
        <xsl:for-each-group select="//gmd:MD_Keywords[gmd:thesaurusName/*/gmd:title/(gco:CharacterString|gmx:Anchor)/text() != '']"
                            group-by="gmd:thesaurusName/*/gmd:title/(gco:CharacterString|gmx:Anchor)/text()">
          '<xsl:value-of select="replace(current-grouping-key(), '''', '\\''')"/>' :[
          <xsl:for-each select="current-group()/gmd:keyword/(gco:CharacterString|gmx:Anchor)">
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
          <xsl:for-each select="$keywordWithNoThesaurus/(gco:CharacterString|gmx:Anchor)">
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

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:for-each select="gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString">
        <Field name="orgName" string="{string(.)}" store="true" index="true"/>
        <Field name="_orgName" string="{string(.)}" store="true" index="true"/>

        <xsl:variable name="role"    select="../../gmd:role/*/@codeListValue"/>
        <xsl:variable name="roleTranslation" select="util:getCodelistTranslation('gmd:CI_RoleCode', string($role), string($langCode_ISO639_2B))"/>
        <xsl:variable name="logo"    select="../..//gmx:FileName/@src"/>
        <xsl:variable name="email"   select="../../gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/gco:CharacterString"/>
        <xsl:variable name="phone"   select="../../gmd:contactInfo/*/gmd:phone/*/gmd:voice[normalize-space(.) != '']/*/text()"/>
        <xsl:variable name="individualName" select="../../gmd:individualName/gco:CharacterString/text()"/>
        <xsl:variable name="positionName"   select="../../gmd:positionName/gco:CharacterString/text()"/>
        <xsl:variable name="address" select="string-join(../../gmd:contactInfo/*/gmd:address/*/(
                                    gmd:deliveryPoint|gmd:postalCode|gmd:city|
                                    gmd:administrativeArea|gmd:country)/gco:CharacterString/text(), ', ')"/>

        <Field name="responsibleParty"
               string="{concat($roleTranslation, '|resource|', ., '|', $logo, '|',  string-join($email, ','), '|', $individualName, '|', $positionName, '|', $address, '|', string-join($phone, ','))}"
               store="true" index="false"/>

      </xsl:for-each>


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
          <Field name="secUserNote" string="{$securityConstraints/gmd:userNote/gco:CharacterString}" store="true" index="true"/>
          <!-- put secUserNote in MD_SecurityConstraintsUseLimitation so that it can be displayed on the view page -->

          <xsl:variable name="securityConstraintsUseLimitation">
            <xsl:value-of select="$securityClassification"/>
            <xsl:choose>
              <xsl:when test="$securityConstraints/gmd:userNote/gco:CharacterString !='' and $securityConstraints/gmd:userNote/gco:CharacterString != $securityClassification">
                <xsl:value-of select="concat('; ', $securityConstraints/gmd:userNote/gco:CharacterString)"/>
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
        <Field name="keyword"
               string="{util:getCodelistTranslation('gmd:MD_TopicCategoryCode', string(.), string($isoLangId))}"
               store="true" index="true"/>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:for-each
        select="gmd:language/gco:CharacterString|gmd:language/gmd:LanguageCode/@codeListValue">
        <Field name="datasetLang" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:for-each select="gmd:spatialResolution/gmd:MD_Resolution">
        <xsl:for-each
          select="gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer">
          <Field name="denominator" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>

        <xsl:for-each select="gmd:distance/gco:Distance">
          <Field name="distanceVal" string="{string(.)}" store="false" index="true"/>
        </xsl:for-each>

        <xsl:for-each select="gmd:distance/gco:Distance/@uom">
          <Field name="distanceUom" string="{string(.)}" store="false" index="true"/>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="gmd:spatialRepresentationType">
        <Field name="spatialRepresentationType" string="{gmd:MD_SpatialRepresentationTypeCode/@codeListValue}"
               store="true" index="true"/>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:for-each select="gmd:resourceConstraints">
        <xsl:for-each select="//gmd:accessConstraints/gmd:MD_RestrictionCode/@codeListValue">
          <Field name="accessConstr" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>
        <xsl:for-each select="//gmd:otherConstraints/gco:CharacterString">
          <Field name="otherConstr" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>
        <xsl:for-each select="//gmd:classification/gmd:MD_ClassificationCode/@codeListValue">
          <Field name="classif" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>
        <xsl:for-each select="//gmd:useLimitation/gco:CharacterString">
          <Field name="conditionApplyingToAccessAndUse" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
      <!--  Fields use to search on Service -->

      <xsl:for-each select="srv:serviceType/gco:LocalName[string(.)]">
        <Field name="serviceType" string="{string(.)}" store="true" index="true"/>
        <Field  name="type" string="service-{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <xsl:for-each select="srv:serviceTypeVersion/gco:CharacterString">
        <Field name="serviceTypeVersion" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <xsl:for-each select="//srv:SV_OperationMetadata/srv:operationName/gco:CharacterString">
        <Field name="operation" string="{string(.)}" store="false" index="true"/>
      </xsl:for-each>

      <xsl:for-each select="srv:operatesOn/@uuidref">
        <Field name="operatesOn" string="{string(.)}" store="false" index="true"/>
      </xsl:for-each>

      <xsl:for-each select="srv:coupledResource">
        <xsl:for-each select="srv:SV_CoupledResource/srv:identifier/gco:CharacterString">
          <Field name="operatesOnIdentifier" string="{string(.)}" store="false" index="true"/>
        </xsl:for-each>

        <xsl:for-each select="srv:SV_CoupledResource/srv:operationName/gco:CharacterString">
          <Field name="operatesOnName" string="{string(.)}" store="false" index="true"/>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="//srv:SV_CouplingType/@codeListValue">
        <Field name="couplingType" string="{string(.)}" store="false" index="true"/>
      </xsl:for-each>

      <xsl:for-each
        select="gmd:graphicOverview/gmd:MD_BrowseGraphic[normalize-space(gmd:fileName/gco:CharacterString) != '']">
        <xsl:variable name="fileName" select="gmd:fileName/gco:CharacterString"/>
        <xsl:variable name="fileDescr" select="gmd:fileDescription/gco:CharacterString"/>
        <xsl:variable name="thumbnailType"
                      select="if (position() = 1) then 'thumbnail' else 'overview'"/>
        <!-- First thumbnail is flagged as thumbnail and could be considered the main one -->
        <Field name="image"
               string="{concat($thumbnailType, '|', $fileName, '|', $fileDescr)}"
               store="true" index="false"/>
      </xsl:for-each>
    </xsl:for-each>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- === Distribution === -->

    <xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution">
      <xsl:for-each select="gmd:distributionFormat/gmd:MD_Format/gmd:name/gco:CharacterString">
        <Field name="format" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <!-- index online protocol -->

      <xsl:for-each
              select="gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[gmd:linkage/gmd:URL!='']">
        <xsl:variable name="download_check">
          <xsl:text>&amp;fname=&amp;access</xsl:text>
        </xsl:variable>
        <xsl:variable name="linkage" select="gmd:linkage/gmd:URL"/>
        <xsl:variable name="title" select="normalize-space(gmd:name/gco:CharacterString|gmd:name/gmx:MimeFileType)"/>
        <xsl:variable name="desc" select="normalize-space(gmd:description/gco:CharacterString)"/>
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
    <!-- === Content info === -->
    <xsl:for-each select="gmd:contentInfo/*/gmd:featureCatalogueCitation[@uuidref]">
      <Field name="hasfeaturecat" string="{string(@uuidref)}" store="false" index="true"/>
    </xsl:for-each>

    <!-- === Data Quality  === -->
    <xsl:for-each select="gmd:dataQualityInfo/*/gmd:lineage//gmd:source[@uuidref]">
      <Field name="hassource" string="{string(@uuidref)}" store="false" index="true"/>
    </xsl:for-each>

    <xsl:for-each select="gmd:dataQualityInfo/*/gmd:report/*/gmd:result">
      <xsl:if test="$inspire='true'">
        <!--
            INSPIRE related dataset could contains a conformity section with:
            * COMMISSION REGULATION (EU) No 1089/2010 of 23 November 2010 implementing Directive 2007/2/EC of the European Parliament and of the Council as regards interoperability of spatial data sets and services
            * INSPIRE Data Specification on <Theme Name> - <version>
            * INSPIRE Specification on <Theme Name> - <version> for CRS and GRID

            Index those types of citation title to found dataset related to INSPIRE (which may be better than keyword
            which are often used for other types of datasets).

            "1089/2010" is maybe too fuzzy but could work for translated citation like "Règlement n°1089/2010, Annexe II-6" TODO improved
        -->
        <xsl:if test="(
                                contains(gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/(gco:CharacterString|gmx:Anchor), '1089/2010') or
                                contains(gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/(gco:CharacterString|gmx:Anchor), 'INSPIRE Data Specification') or
                                contains(gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/(gco:CharacterString|gmx:Anchor), 'INSPIRE Specification'))">
          <Field name="inspirerelated" string="on" store="false" index="true"/>
        </xsl:if>
      </xsl:if>

      <xsl:for-each select="//gmd:pass/gco:Boolean">
        <Field name="degree" string="{string(.)}" store="false" index="true"/>
      </xsl:for-each>

      <xsl:for-each select="//gmd:specification/*/gmd:title/gco:CharacterString">
        <Field name="specificationTitle" string="{string(.)}" store="false" index="true"/>
      </xsl:for-each>

      <xsl:for-each select="//gmd:specification/*/gmd:date/*/gmd:date">
        <Field name="specificationDate" string="{string(gco:Date|gco:DateTime)}" store="false" index="true"/>
      </xsl:for-each>

      <xsl:for-each select="//gmd:specification/*/gmd:date/*/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue">
        <Field name="specificationDateType" string="{string(.)}" store="false" index="true"/>
      </xsl:for-each>
    </xsl:for-each>
    <xsl:for-each select="gmd:dataQualityInfo/*/gmd:lineage/*/gmd:statement/gco:CharacterString">
      <Field name="lineage" string="{string(.)}" store="false" index="true"/>
    </xsl:for-each>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- === General stuff === -->
    <!-- Metadata type  -->
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
      <!-- Check if metadata is a service metadata record -->
      <xsl:when test="gmd:identificationInfo/srv:SV_ServiceIdentification">
        <Field name="type" string="service" store="false" index="true"/>
      </xsl:when>
      <!-- <xsl:otherwise>
      ... gmd:*_DataIdentification / hierachicalLevel is used and return dataset, serie, ...
      </xsl:otherwise>-->
    </xsl:choose>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <xsl:for-each select="gmd:hierarchyLevelName/gco:CharacterString">
      <Field name="levelName" string="{string(.)}" store="false" index="true"/>
    </xsl:for-each>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <xsl:for-each select="gmd:language/gco:CharacterString
                        |gmd:language/gmd:LanguageCode/@codeListValue
                        |gmd:locale/gmd:PT_Locale/gmd:languageCode/gmd:LanguageCode/@codeListValue">
      <Field name="language" string="{string(.)}" store="true" index="true"/>
    </xsl:for-each>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <xsl:for-each select="gmd:fileIdentifier/gco:CharacterString">
      <Field name="fileId" string="{string(.)}" store="false" index="true"/>
    </xsl:for-each>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <xsl:for-each select="gmd:parentIdentifier/gco:CharacterString">
      <Field name="parentUuid" string="{string(.)}" store="true" index="true"/>
    </xsl:for-each>

    <xsl:choose>
      <xsl:when test="string(gmd:parentIdentifier/gco:CharacterString)">
        <Field name="_isCollection" string="false" store="true" index="true"/>
      </xsl:when>
      <xsl:otherwise>
        <Field name="_isCollection" string="true" store="true" index="true"/>
      </xsl:otherwise>
    </xsl:choose>

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

    <xsl:for-each select="gmd:metadataStandardName/gco:CharacterString">
      <Field name="standardName" string="{string(.)}" store="true" index="true"/>
    </xsl:for-each>
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <xsl:for-each select="gmd:dateStamp/gco:DateTime">
      <Field name="changeDate" string="{string(.)}" store="true" index="true"/>
    </xsl:for-each>

    <!-- Index gco:Date as is allowed also, GN uses gco:DateTime, but this case manages imported and not edited metadata -->
    <xsl:for-each select="gmd:dateStamp/gco:Date">
      <Field name="changeDate" string="{concat(string(.), 'T00:00:00')}" store="true" index="true"/>
    </xsl:for-each>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <xsl:for-each select="gmd:contact/*/gmd:organisationName/gco:CharacterString">
      <Field name="metadataPOC" string="{string(.)}" store="false" index="true"/>

      <xsl:variable name="role"    select="../../gmd:role/*/@codeListValue"/>
      <xsl:variable name="roleTranslation" select="util:getCodelistTranslation('gmd:CI_RoleCode', string($role), string($langCode_ISO639_2B))"/>
      <xsl:variable name="logo"    select="../..//gmx:FileName/@src"/>
      <xsl:variable name="email"   select="../../gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/gco:CharacterString"/>
      <xsl:variable name="phone"   select="../../gmd:contactInfo/*/gmd:phone/*/gmd:voice[normalize-space(.) != '']/*/text()"/>
      <xsl:variable name="individualName" select="../../gmd:individualName/gco:CharacterString/text()"/>
      <xsl:variable name="positionName"   select="../../gmd:positionName/gco:CharacterString/text()"/>
      <xsl:variable name="address" select="string-join(../../gmd:contactInfo/*/gmd:address/*/(
                                    gmd:deliveryPoint|gmd:postalCode|gmd:city|
                                    gmd:administrativeArea|gmd:country)/gco:CharacterString/text(), ', ')"/>

      <Field name="responsibleParty"
             string="{concat($roleTranslation, '|metadata|', ., '|', $logo, '|',  string-join($email, ','), '|', $individualName, '|', $positionName, '|', $address, '|', string-join($phone, ','))}"
             store="true" index="false"/>
    </xsl:for-each>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- === Reference system info === -->

    <xsl:for-each select="gmd:referenceSystemInfo/gmd:MD_ReferenceSystem">
      <xsl:for-each select="gmd:referenceSystemIdentifier/gmd:RS_Identifier">
        <xsl:variable name="crs"
                      select="concat(string(gmd:codeSpace/gco:CharacterString),'::',string(gmd:code/gco:CharacterString))"/>

        <xsl:if test="$crs != '::'">
          <Field name="crs" string="{$crs}" store="false" index="true"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>

    <xsl:for-each select="gmd:referenceSystemInfo/gmd:MD_ReferenceSystem">
      <xsl:for-each select="gmd:referenceSystemIdentifier/gmd:RS_Identifier">
        <Field name="authority" string="{string(gmd:codeSpace/gco:CharacterString)}" store="false" index="true"/>
        <Field name="crsCode" string="{string(gmd:code/gco:CharacterString)}" store="false" index="true"/>
        <Field name="crsVersion" string="{string(gmd:version/gco:CharacterString)}" store="false" index="true"/>
      </xsl:for-each>
    </xsl:for-each>

    <!-- Index gmd:geometricObjectType, mapping codelist values to values
         to be used in CSS properties to represent the type of geometry -->
    <xsl:for-each select="gmd:spatialRepresentationInfo/gmd:MD_VectorSpatialRepresentation/gmd:geometricObjects/gmd:MD_GeometricObjects/gmd:geometricObjectType/gmd:MD_GeometricObjectTypeCode">
      <xsl:variable name="geometryTypeValue">
        <xsl:choose>
          <!-- point; point -->
          <xsl:when test="@codeListValue = 'RI_508'">point</xsl:when>
          <!-- curve; courbe -->
          <xsl:when test="@codeListValue = 'RI_507'">line</xsl:when>
          <!-- solid; solide / surface; surface -->
          <xsl:when test="@codeListValue = 'RI_509' or @codeListValue = 'RI_510'">area</xsl:when>
          <!-- complex; complexe / composite; composé -->
          <xsl:when test="@codeListValue = 'RI_505' or @codeListValue = 'RI_506'">multiple></xsl:when>
          <xsl:otherwise />
        </xsl:choose>
      </xsl:variable>


      <xsl:if test="string($geometryTypeValue)">
        <Field name="geometryValue" string="{$geometryTypeValue}" store="true" index="true"/>
      </xsl:if>
    </xsl:for-each>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- === Free text search === -->

    <Field name="any" store="false" index="true">
      <xsl:attribute name="string">
        <xsl:value-of select="normalize-space(string(.))"/>
        <xsl:text> </xsl:text>
        <xsl:for-each select="//@codeListValue">
          <xsl:value-of select="concat(., ' ')"/>
        </xsl:for-each>
      </xsl:attribute>
    </Field>

    <!--<xsl:apply-templates select="." mode="codeList"/>-->

  </xsl:template>

  <!-- ========================================================================================= -->
  <!-- codelist element, indexed, not stored nor tokenized -->

  <xsl:template match="*[./*/@codeListValue]" mode="codeList">
    <xsl:param name="name" select="name(.)"/>

    <Field name="{$name}" string="{*/@codeListValue}" store="false" index="true"/>
  </xsl:template>

  <!-- ========================================================================================= -->

  <xsl:template match="*" mode="codeList">
    <xsl:apply-templates select="*" mode="codeList"/>
  </xsl:template>


  <!-- ========================================================================================= -->

  <!-- inspireThemes is a nodeset consisting of skos:Concept elements -->
  <!-- each containing a skos:definition and skos:prefLabel for each language -->
  <!-- This template finds the provided keyword in the skos:prefLabel elements and returns the English one from the same skos:Concept -->
  <xsl:template name="translateInspireThemeToEnglish">
    <xsl:param name="keyword"/>
    <xsl:param name="inspireThemes"/>
    <xsl:for-each select="$inspireThemes/skos:prefLabel">
      <!-- if this skos:Concept contains a kos:prefLabel with text value equal to keyword -->
      <xsl:if test="text() = $keyword">
        <xsl:value-of select="../skos:prefLabel[@xml:lang='en']/text()"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="determineInspireAnnex">
    <xsl:param name="keyword"/>
    <xsl:param name="inspireThemes"/>
    <xsl:variable name="englishKeywordMixedCase">
      <xsl:call-template name="translateInspireThemeToEnglish">
        <xsl:with-param name="keyword" select="$keyword"/>
        <xsl:with-param name="inspireThemes" select="$inspireThemes"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="englishKeyword" select="lower-case($englishKeywordMixedCase)"/>
    <!-- Another option could be to add the annex info in the SKOS thesaurus using something
    like a related concept. -->
    <xsl:choose>
      <!-- annex i -->
      <xsl:when test="$englishKeyword='coordinate reference systems' or $englishKeyword='geographical grid systems'
			            or $englishKeyword='geographical names' or $englishKeyword='administrative units'
			            or $englishKeyword='addresses' or $englishKeyword='cadastral parcels'
			            or $englishKeyword='transport networks' or $englishKeyword='hydrography'
			            or $englishKeyword='protected sites'">
        <xsl:text>i</xsl:text>
      </xsl:when>
      <!-- annex ii -->
      <xsl:when test="$englishKeyword='elevation' or $englishKeyword='land cover'
			            or $englishKeyword='orthoimagery' or $englishKeyword='geology'">
        <xsl:text>ii</xsl:text>
      </xsl:when>
      <!-- annex iii -->
      <xsl:when test="$englishKeyword='statistical units' or $englishKeyword='buildings'
			            or $englishKeyword='soil' or $englishKeyword='land use'
			            or $englishKeyword='human health and safety' or $englishKeyword='utility and government services'
			            or $englishKeyword='environmental monitoring facilities' or $englishKeyword='production and industrial facilities'
			            or $englishKeyword='agricultural and aquaculture facilities' or $englishKeyword='population distribution - demography'
			            or $englishKeyword='area management/restriction/regulation zones and reporting units'
			            or $englishKeyword='natural risk zones' or $englishKeyword='atmospheric conditions'
			            or $englishKeyword='meteorological geographical features' or $englishKeyword='oceanographic geographical features'
			            or $englishKeyword='sea regions' or $englishKeyword='bio-geographical regions'
			            or $englishKeyword='habitats and biotopes' or $englishKeyword='species distribution'
			            or $englishKeyword='energy resources' or $englishKeyword='mineral resources'">
        <xsl:text>iii</xsl:text>
      </xsl:when>
      <!-- inspire annex cannot be established: leave empty -->
    </xsl:choose>

  </xsl:template>
</xsl:stylesheet>
