<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:gml320="http://www.opengis.net/gml"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:xlink='http://www.w3.org/1999/xlink'
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:ns2="http://www.w3.org/2004/02/skos/core#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:XslUtilHnap="java:ca.gc.schema.iso19139hnap.util.XslUtilHnap"
                xmlns:XslUtil="java:org.fao.geonet.util.XslUtil"
                xmlns:exslt = "http://exslt.org/common"
                exclude-result-prefixes="gml320 rdf ns2 rdfs skos exslt geonet XslUtil XslUtilHnap gn-fn-iso19139">

	<xsl:include href="../iso19139.ca.HNAP/convert/functions.xsl"/>
  <xsl:include href="../iso19139.ca.HNAP/layout/utility-fn.xsl"/>


  <xsl:variable name="schemaLocationFor2007"
                select="'http://www.isotc211.org/2005/gmd http://schemas.opengis.net/csw/2.0.2/profiles/apiso/1.0.0/apiso.xsd'"/>

  <!-- ================================================================= -->
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


  <xsl:variable name="thesauriDir" select="XslUtilHnap:getThesauriDir()" />
  <xsl:variable name="ecCoreThesaurus" select="document(concat('file:///', replace(concat($thesauriDir, '/external/thesauri/theme/GC_Core_Subject.rdf'), '\\', '/')))" />


  <xsl:variable name="localeForTranslations">
    <xsl:choose>
      <xsl:when test="normalize-space(/root/gmd:MD_Metadata/gmd:language/gco:CharacterString) = 'eng; CAN'">#fra</xsl:when>
      <xsl:otherwise>#eng</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

 <xsl:variable name="serviceUrl" select="/root/env/siteURL"/>
  <xsl:variable name="node" select="/root/env/node"/>


  <!-- We use the category check to find out if this is an SDS metadata. Please replace with anything better -->
  <xsl:variable name="isSDS"
                select="count(//gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/gmx:Anchor[starts-with(@xlink:href, 'http://inspire.ec.europa.eu/metadata-codelist/Category')]) = 1"/>


    <!-- The default language is also added as gmd:locale
  for multilingual metadata records. -->
  <xsl:variable name="mainLanguage">
    <xsl:call-template name="langId_from_gmdlanguage19139">
      <xsl:with-param name="gmdlanguage" select="/root/*/gmd:language"/>
    </xsl:call-template>
  </xsl:variable>


  <xsl:variable name="isMultilingual"
                select="count(/root/*/gmd:locale[*/gmd:languageCode/*/@codeListValue != $mainLanguage]) > 0"/>

  <xsl:variable name="locales"
                select="/root/*/gmd:locale/gmd:PT_Locale"/>

  <!-- ******************************************************************************************************
        get main language code to be used in locale ID
        If it does not already exists in the pt_local then it will generate one to be used. -->
  <xsl:variable name="mainLanguageId">
     <!-- Potential options include 3 char or 2 char code in both upper and lower. -->

      <xsl:variable name="localeList"
                    select="/root/*/gmd:locale/gmd:PT_Locale"/>
      <xsl:variable name="twoCharMainLangCode"
                select="XslUtilHnap:twoCharLangCode($mainLanguage)"/>
     <xsl:variable name="nextThreeCharLangCode"
                select="substring(concat($localeList[1]/@id, '   '), 1, 3)"/>
     <xsl:variable name="nextTwoCharLangCode"
                select="XslUtilHnap:twoCharLangCode($localeList[1]/@id)"/>

      <xsl:choose>
        <!-- If one of the locales is equal to the main language then that is the id that will be used. -->
        <xsl:when test="$localeList[upper-case(@id) = upper-case($mainLanguage)]">
           <xsl:value-of  select="$localeList[upper-case(@id) = upper-case($mainLanguage)]/@id"/>
        </xsl:when>
        <!-- If one of the locales is equal to the 2 Char main language then that is the id that will be used. -->
        <xsl:when test="$localeList[upper-case(@id) = upper-case($twoCharMainLangCode)]">
           <xsl:value-of  select="$localeList[upper-case(@id) = upper-case($twoCharMainLangCode)]/@id"/>
        </xsl:when>

        <!-- If one of the locales is equal to the upper case version then the codes are assumed to be in uppercase. -->
        <xsl:when test="$localeList[@id = upper-case($nextThreeCharLangCode)]">
           <xsl:value-of  select="upper-case($mainLanguage)"/>
        </xsl:when>
        <!-- If one of the locales is equal to the lower case version then the codes are assumed to be in lowercase. -->
        <xsl:when test="$localeList[@id = lower-case($nextThreeCharLangCode)]">
           <xsl:value-of  select="lower-case($mainLanguage)"/>
        </xsl:when>

        <!-- If one of the locales is equal to the 2 char upper case version then the codes are assumed to be in uppercase 2 char. -->
        <xsl:when test="$localeList[@id = upper-case($nextTwoCharLangCode)]">
           <xsl:value-of  select="upper-case($twoCharMainLangCode)"/>
        </xsl:when>
        <!-- If one of the locales is equal to the 2 char lower case version then the codes are assumed to be in lowercase 2 char. -->
        <xsl:when test="$localeList[@id = lower-case($nextTwoCharLangCode)]">
           <xsl:value-of  select="lower-case($twoCharMainLangCode)"/>
        </xsl:when>

        <!-- If we did not find an option then just use the main language as the code. -->
        <xsl:otherwise><xsl:value-of select="$mainLanguage"/></xsl:otherwise>
      </xsl:choose>
  </xsl:variable>

  <!-- Get alt language -->
  <xsl:variable name="altLanguageId" select="$locales[gmd:languageCode/*/@codeListValue != $mainLanguage and (gmd:languageCode/*/@codeListValue = 'eng' or gmd:languageCode/*/@codeListValue = 'fra')]/@id"/>

 <!-- *******************************************************************************************************
       The default country code to be used in the gmd:locale
       for multilingual metadata records. -->
  <xsl:variable name="mainLanguageCountryId">
      <xsl:variable name="language"  select="normalize-space(/root/*/gmd:language/gco:CharacterString/text())"/>
      <!-- Get the main language which could be "EN", "EN; US" if it contains a ; then extract country code -->
      <xsl:choose>
        <xsl:when test="contains($language,';')">
           <xsl:value-of  select="normalize-space(substring-after($language,';'))"/>
        </xsl:when>
      </xsl:choose>
  </xsl:variable>

  <xsl:variable name="defaultEncoding"
                select="'utf8'"/>

  <xsl:variable name="editorConfig"
                select="document('layout/config-editor.xml')"/>


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
  <!-- load codelist Document-->
  <xsl:variable name="codelistDocument" select="document(concat('loc/', $mainLanguage_ISO639_2B, '/codelists.xml'))"/>

  <xsl:variable name="nonMultilingualFields"
                select="$editorConfig/editor/multilingualFields/exclude"/>

	<xsl:template match="/root">
		<xsl:apply-templates select="gmd:MD_Metadata"/>
	</xsl:template>

	<!-- ================================================================= -->

	<xsl:template match="gmd:MD_Metadata">
		<xsl:copy copy-namespaces="no">
			<xsl:call-template name="add-namespaces"/>

			<xsl:apply-templates select="@*"/>

			<gmd:fileIdentifier>
				<gco:CharacterString>
					<xsl:value-of select="/root/env/uuid"/>
				</gco:CharacterString>
			</gmd:fileIdentifier>

			<xsl:apply-templates select="gmd:language"/>

			<!-- fixed to uft8 -->
			<gmd:characterSet>
				<gmd:MD_CharacterSetCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_95" codeListValue="RI_458">utf8; utf8</gmd:MD_CharacterSetCode>
			</gmd:characterSet>

			<xsl:choose>
				<xsl:when test="/root/env/parentUuid!=''">
					<gmd:parentIdentifier>
						<gco:CharacterString>
							<xsl:value-of select="/root/env/parentUuid"/>
						</gco:CharacterString>
					</gmd:parentIdentifier>
				</xsl:when>
				<xsl:when test="gmd:parentIdentifier">
					<xsl:copy-of select="gmd:parentIdentifier"/>
				</xsl:when>
			</xsl:choose>

      <xsl:apply-templates select="
        gmd:hierarchyLevel|
        gmd:hierarchyLevelName|
        gmd:contact|
        gmd:dateStamp|
        gmd:metadataStandardName|
        gmd:metadataStandardVersion|
        gmd:dataSetURI"/>

      <!-- Copy existing locales and create an extra one for the default metadata language. -->
      <xsl:apply-templates select="gmd:locale[*/gmd:languageCode/*/@codeListValue != $mainLanguage]"/>

 		  <xsl:apply-templates select="node()[name()!='gmd:fileIdentifier' and
                                            name()!='gmd:language' and
                                            name()!='gmd:parentIdentifier' and
                                            name()!='gmd:characterSet' and
                                            name()!='gmd:hierarchyLevel' and
                                            name()!='gmd:hierarchyLevelName' and
                                            name()!='gmd:contact' and
                                            name()!='gmd:dateStamp' and
                                            name()!='gmd:metadataStandardName' and
                                            name()!='gmd:metadataStandardVersion' and
                                            name()!='gmd:dataSetURI' and
                                            name()!='gmd:locale']"/>
		</xsl:copy>
	</xsl:template>


	<!-- ================================================================= -->
	<!-- Do not process MD_Metadata header generated by previous template  -->

	<xsl:template match="gmd:MD_Metadata/gmd:fileIdentifier|gmd:MD_Metadata/gmd:parentIdentifier" priority="10"/>

	<!-- ================================================================= -->

	<xsl:template match="gmd:dateStamp">
    <xsl:choose>
        <xsl:when test="/root/env/changeDate">
            <xsl:copy>
                    <gco:DateTime>
                        <xsl:value-of select="/root/env/changeDate"/>
                    </gco:DateTime>
            </xsl:copy>
        </xsl:when>
        <xsl:otherwise>
            <xsl:copy-of select="."/>
        </xsl:otherwise>
    </xsl:choose>
	</xsl:template>

	<!-- ================================================================= -->

	<!-- Only set metadataStandardName and metadataStandardVersion
	if not set. -->
	<xsl:template match="gmd:metadataStandardName[@gco:nilReason='missing' or gco:CharacterString=''
		    or normalize-space(gmd:PT_FreeText/*/gmd:LocalisedCharacterString[@locale != concat('#', $mainLanguageId)]) = '']" priority="10">
		<xsl:copy>
      <xsl:attribute name="xsi:type">gmd:PT_FreeText_PropertyType</xsl:attribute>
      <xsl:choose>
			  <xsl:when test="$mainLanguage='fra'">
          <gco:CharacterString>Profil nord-américain de la norme ISO 19115:2003 - Information géographique - Métadonnées</gco:CharacterString>
          <xsl:if test="isMultilingual">
            <gmd:PT_FreeText>
              <gmd:textGroup>
                <gmd:LocalisedCharacterString locale="#eng">North American Profile of ISO 19115:2003 - Geographic information - Metadata</gmd:LocalisedCharacterString>
              </gmd:textGroup>
            </gmd:PT_FreeText>
          </xsl:if>
	  	  </xsl:when>
			  <xsl:otherwise>
          <gco:CharacterString>North American Profile of ISO 19115:2003 - Geographic information - Metadata</gco:CharacterString>
          <xsl:if test="isMultilingual">
            <gmd:PT_FreeText>
              <gmd:textGroup>
                <gmd:LocalisedCharacterString locale="#fra">Profil nord-américain de la norme ISO 19115:2003 - Information géographique - Métadonnées</gmd:LocalisedCharacterString>
              </gmd:textGroup>
            </gmd:PT_FreeText>
          </xsl:if>
		  	</xsl:otherwise>
		  </xsl:choose>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="gmd:metadataStandardVersion[@gco:nilReason='missing' or gco:CharacterString='']" priority="10">
		<xsl:copy>
			<gco:CharacterString>CAN/CGSB-171.100-2009</gco:CharacterString>
		</xsl:copy>
	</xsl:template>

	<!-- ================================================================= -->

    <xsl:template match="@gml:id|@gml320:id">
		<xsl:choose>
			<xsl:when test="normalize-space(.)=''">
        <xsl:attribute name="{if ($isUsing2005Schema and not($isUsing2007Schema))
                              then 'gml320' else 'gml'}:id">
					<xsl:value-of select="generate-id(.)"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ==================================================================== -->
	<!-- Fix srsName attribute generate CRS:84 (EPSG:4326 with long/lat
	     ordering) by default -->

	<xsl:template match="@srsName">
		<xsl:choose>
			<xsl:when test="normalize-space(.)=''">
				<xsl:attribute name="srsName">
					<xsl:text>CRS:84</xsl:text>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

  <!-- Add required gml attributes if missing -->
  <xsl:template match="gml:Polygon[not(@gml:id) and not(@srsName)]|
                       gml:MultiSurface[not(@gml:id) and not(@srsName)]|
                       gml:LineString[not(@gml:id) and not(@srsName)]|
                       gml320:Polygon[not(@gml320:id) and not(@srsName)]">
    <xsl:copy copy-namespaces="no">
      <xsl:choose>
        <xsl:when test="$isUsing2005Schema and not($isUsing2007Schema)">
          <xsl:namespace name="gml320" select="'http://www.opengis.net/gml'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:namespace name="gml" select="'http://www.opengis.net/gml/3.2'"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:attribute name="{if ($isUsing2005Schema and not($isUsing2007Schema))
                            then 'gml320' else 'gml'}:id">
        <xsl:value-of select="generate-id(.)"/>
      </xsl:attribute>
      <xsl:attribute name="srsName">
        <xsl:text>http://www.opengis.net/def/crs/EPSG/0/4326</xsl:text>
      </xsl:attribute>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="*"/>
    </xsl:copy>
  </xsl:template>

	<!-- ================================================================= -->


  <xsl:template match="*[gco:CharacterString|gmx:Anchor|gmd:PT_FreeText]">
    <xsl:copy>
      <xsl:apply-templates select="@*[not(name() = 'gco:nilReason') and not(name() = 'xsi:type')]"/>

      <!-- Add nileason if text is empty -->
      <xsl:variable name="excluded"
                    select="gn-fn-iso19139:isNotMultilingualField(., $editorConfig)"/>


      <xsl:variable name="valueInPtFreeTextForMainLanguage"
                    select="normalize-space(gmd:PT_FreeText/*/gmd:LocalisedCharacterString[
                                            @locale = concat('#', $mainLanguageId)])"/>

      <!-- Add nileason if text is empty -->
      <xsl:variable name="isMainLanguageEmpty"
                    select="if ($isMultilingual and not($excluded))
                            then ($valueInPtFreeTextForMainLanguage = '' and normalize-space(gco:CharacterString|gmx:Anchor) = '')
                            else if ($valueInPtFreeTextForMainLanguage != '')
                            then $valueInPtFreeTextForMainLanguage = ''
                            else normalize-space(gco:CharacterString|gmx:Anchor) = ''"/>


      <!-- TODO ? Removes @nilReason from parents of gmx:Anchor if anchor has @xlink:href attribute filled. -->
      <xsl:variable name="isEmptyAnchor"
                    select="normalize-space(gmx:Anchor/@xlink:href) = ''" />

      <xsl:choose>
        <xsl:when test="$isMainLanguageEmpty">
          <xsl:attribute name="gco:nilReason">
            <xsl:choose>
              <xsl:when test="@gco:nilReason">
                <xsl:value-of select="@gco:nilReason"/>
              </xsl:when>
              <xsl:otherwise>missing</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="@gco:nilReason != 'missing' and not($isMainLanguageEmpty)">
          <xsl:copy-of select="@gco:nilReason"/>
        </xsl:when>
      </xsl:choose>


      <!-- For multilingual records, for multilingual fields,
       create a gco:CharacterString or gmx:Anchor containing
       the same value as the default language PT_FreeText.
      -->
      <xsl:variable name="element" select="name()"/>


      <xsl:choose>
        <!-- Check record does not contains multilingual elements
          matching the main language. This may happen if the main
          language is declared in locales and only PT_FreeText are set.
          It should not be possible in GeoNetwork, but record user can
          import may use this encoding. -->
        <xsl:when test="not($isMultilingual) and
                        $valueInPtFreeTextForMainLanguage != '' and
                        normalize-space(gco:CharacterString|gmx:Anchor) = ''">
          <xsl:element name="{if (gmx:Anchor) then 'gmx:Anchor' else 'gco:CharacterString'}">
            <xsl:copy-of select="gmx:Anchor/@*"/>
            <xsl:value-of select="$valueInPtFreeTextForMainLanguage"/>
          </xsl:element>
        </xsl:when>
        <xsl:when test="not($isMultilingual) or
                        $excluded">
          <!-- Copy gco:CharacterString only. PT_FreeText are removed if not multilingual. -->
          <xsl:apply-templates select="gco:CharacterString|gmx:Anchor"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- Add xsi:type for multilingual element. -->
          <xsl:attribute name="xsi:type" select="'gmd:PT_FreeText_PropertyType'"/>

          <!-- Is the default language value set in a PT_FreeText ? -->
          <xsl:variable name="isInPTFreeText"
                        select="count(gmd:PT_FreeText/*/gmd:LocalisedCharacterString[
                                            @locale = concat('#', $mainLanguageId)]) = 1"/>


          <xsl:choose>
            <xsl:when test="$isInPTFreeText">
              <!-- Update gco:CharacterString to contains
                   the default language value from the PT_FreeText.
                   PT_FreeText takes priority. -->
              <xsl:element name="{if (gmx:Anchor) then 'gmx:Anchor' else 'gco:CharacterString'}">
                <xsl:copy-of select="gmx:Anchor/@*"/>
                <xsl:value-of select="gmd:PT_FreeText/*/gmd:LocalisedCharacterString[
                                            @locale = concat('#', $mainLanguageId)]/text()"/>
              </xsl:element>

              <xsl:if test="gmd:PT_FreeText[normalize-space(.) != '']">
                <gmd:PT_FreeText>
                  <xsl:call-template name="populate-free-text"/>
                </gmd:PT_FreeText>
              </xsl:if>

            </xsl:when>
            <xsl:otherwise>

              <!-- Populate PT_FreeText for default language if not existing and it is not null. -->
              <xsl:apply-templates select="gco:CharacterString|gmx:Anchor"/>


                <!-- only put this in if there's stuff to put in, otherwise we get a <gmd:PT_FreeText/> in output -->
              <xsl:if test="gmd:PT_FreeText">
                  <gmd:PT_FreeText>
                    <!-- do NOT put in the main language (again) -->
<!--                    <xsl:if test="normalize-space(gco:CharacterString|gmx:Anchor) != ''"> &lt;!&ndash; default lang&ndash;&gt;-->
<!--                      <gmd:textGroup>-->
<!--                        <gmd:LocalisedCharacterString locale="#{$mainLanguageId}">-->
<!--                          <xsl:value-of select="gco:CharacterString|gmx:Anchor"/>-->
<!--                        </gmd:LocalisedCharacterString>-->
<!--                      </gmd:textGroup>-->
<!--                    </xsl:if>-->
                    <xsl:call-template name="populate-free-text"/> <!-- other langs -->
                  </gmd:PT_FreeText>
                </xsl:if>

            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>

      <!-- Apply other elements that we are not handling in this template -->
      <xsl:apply-templates select="node()[not(self::gco:CharacterString|self::gmx:Anchor|self::gmd:PT_FreeText)]"/>

    </xsl:copy>
  </xsl:template>


  <xsl:template name="populate-free-text">
    <xsl:variable name="freeText"
                  select="gmd:PT_FreeText/gmd:textGroup"/>
    <!-- dont put in main language - its aready in the main section -->
<!--    <xsl:apply-templates select="$freeText[*/@locale = concat('#', $mainLanguageId)]"/>-->

    <xsl:for-each select="$locales[@id != $mainLanguageId]">
      <xsl:variable name="localId"
                    select="@id"/>

      <xsl:variable name="element"
                    select="$freeText[*/@locale = concat('#', $localId)]"/>

      <xsl:apply-templates select="$element"/>
    </xsl:for-each>
  </xsl:template>


  <xsl:template
    match="gmd:topicCategory[not(gmd:MD_TopicCategoryCode)]"
    priority="10" />


  <xsl:template match="gmd:topicCategory">
    <xsl:copy>
      <xsl:apply-templates select="@*[not(name()='gco:nilReason')]"/>
      <xsl:choose>
        <xsl:when test="normalize-space(gmd:MD_TopicCategoryCode)=''">
          <xsl:attribute name="gco:nilReason">
            <xsl:choose>
              <xsl:when test="@gco:nilReason"><xsl:value-of select="@gco:nilReason"/></xsl:when>
              <xsl:otherwise>missing</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="@gco:nilReason!='missing' and normalize-space(gmd:MD_TopicCategoryCode)!=''">
          <xsl:copy-of select="@gco:nilReason"/>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

	<!-- ================================================================= -->
	<!-- codelists: set @codeList path -->
	<!-- ================================================================= -->
  <!-- Add codelist labels -->
    <xsl:template match="gmd:LanguageCode[@codeListValue]" priority="2200">
        <gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/">
            <xsl:apply-templates select="@*[name(.)!='codeList']"/>

            <xsl:if test="normalize-space(./text()) != ''">
               <xsl:value-of select="XslUtil:getIsoLanguageLabel(@codeListValue, $mainLanguage)" />
            </xsl:if>
        </gmd:LanguageCode>
    </xsl:template>

  <!-- We don't have code list for country so only handle "CAN" -->
  <xsl:template match="gmd:Country[@codeListValue='CAN']" priority="2200">
  	<xsl:copy>
  	  <xsl:apply-templates select="@*"/>
  	  <xsl:attribute name="codeList">http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_117</xsl:attribute>
  	  <xsl:text>Canada; Canada</xsl:text>
  	</xsl:copy>
  </xsl:template>

  <xsl:template match="gmd:*[@codeListValue]" priority="220">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="codelistCode">
        <xsl:choose>
          <xsl:when test="normalize-space(name(.)) = 'gmd:MD_ScopeCode'">
            <xsl:value-of select="'IC_108'"/>
          </xsl:when>
          <xsl:when test="normalize-space(name(.)) = 'gmd:MD_ProgressCode' and name(parent::*) = 'gmd:status'">
            <xsl:value-of select="'IC_106'"/>
          </xsl:when>
          <xsl:when
            test="normalize-space(name(.)) = 'gmd:MD_SpatialRepresentationTypeCode' and name(parent::*) = 'gmd:spatialRepresentationType'">
            <xsl:value-of select="'IC_109'"/>
          </xsl:when>
          <xsl:when
            test="normalize-space(name(.)) = 'gmd:MD_MaintenanceFrequencyCode' and name(parent::*) = 'gmd:maintenanceAndUpdateFrequency'">
            <xsl:value-of select="'IC_102'"/>
          </xsl:when>
          <xsl:when test="normalize-space(name(.)) = 'gmd:CI_RoleCode' and name(parent::*) = 'gmd:role'">
            <xsl:value-of select="'IC_90'"/>
          </xsl:when>
          <xsl:when test="normalize-space(name(.)) = 'gmd:CI_DateTypeCode' and name(parent::*) = 'gmd:dateType'">
            <xsl:value-of select="'IC_87'"/>
          </xsl:when>
          <xsl:when test="normalize-space(name(.)) = 'gmd:MD_RestrictionCode'">
            <xsl:value-of select="'IC_107'"/>
          </xsl:when>
          <xsl:when
            test="normalize-space(name(.)) = 'gmd:CI_PresentationFormCode' and name(parent::*) = 'gmd:presentationForm'">
            <xsl:value-of select="'IC_89'"/>
          </xsl:when>
          <xsl:when test="normalize-space(name(.)) = 'gmd:MD_GeometricObjectTypeCode'">
            <xsl:value-of select="'IC_99'"/>
          </xsl:when>
          <xsl:when test="normalize-space(name(.)) = 'gmd:MD_CellGeometryCode'">
            <xsl:value-of select="'IC_94'"/>
          </xsl:when>
          <xsl:when test="normalize-space(name(.)) = 'gmd:MD_PixelOrientationCode'">
            <xsl:value-of select="'IC_105'"/>
          </xsl:when>
          <xsl:when test="normalize-space(name(.)) = 'gmd:DQ_EvaluationMethodTypeCode'">
            <xsl:value-of select="'IC_91'"/>
          </xsl:when>
          <xsl:when test="normalize-space(name(.)) = 'gmd:DS_AssociationTypeCode'">
            <xsl:value-of select="'IC_92'"/>
          </xsl:when>
          <xsl:when test="normalize-space(name(.)) = 'gmd:DS_InitiativeTypeCode'">
            <xsl:value-of select="'IC_93'"/>
          </xsl:when>
          <xsl:when test="normalize-space(name(.)) = 'gmd:MD_ClassificationCode'">
            <xsl:value-of select="'IC_96'"/>
          </xsl:when>
          <xsl:when test="normalize-space(name(.)) = 'gmd:MD_CoverageContentTypeCode'">
            <xsl:value-of select="'IC_97'"/>
          </xsl:when>
          <xsl:when test="normalize-space(name(.)) = 'gmd:MD_DimensionNameTypeCode'">
            <xsl:value-of select="'IC_98'"/>
          </xsl:when>
          <xsl:when test="normalize-space(name(.)) = 'gmd:MD_ImagingConditionCode'">
            <xsl:value-of select="'IC_100'"/>
          </xsl:when>
          <xsl:when test="normalize-space(name(.)) = 'gmd:MD_MediumFormatCode'">
            <xsl:value-of select="'IC_103'"/>
          </xsl:when>
          <xsl:when test="normalize-space(name(.)) = 'gmd:MD_TopologyLevelCode'">
            <xsl:value-of select="'IC_111'"/>
          </xsl:when>
          <xsl:when test="normalize-space(name(.)) = 'gmd:MD_MediumNameCode'">
            <xsl:value-of select="'IC_104'"/>
          </xsl:when>
          <xsl:when test="normalize-space(name(.)) = 'gmd:MD_CharacterSetCode'
            				                and ((name(parent::*) = 'gmd:characterSet'
            				                    and (name(parent::*/parent::*) = 'gmd:MD_DataIdentification'
            				                      or name(parent::*/parent::*) = 'gmd:MD_Metadata')
            				                     )or(
            				                     (name(parent::*) = 'gmd:characterEncoding'
            				                      and name(parent::*/parent::*) = 'gmd:PT_Locale')
            				                    ))">
            <xsl:value-of select="'IC_95'"/>
          </xsl:when>
          <xsl:when test="normalize-space(name(.)) = 'gmd:MD_KeywordTypeCode' and name(parent::*) = 'gmd:type'">
            <xsl:value-of select="'IC_101'"/>
          </xsl:when>
          <xsl:when test="normalize-space(name(.)) = 'srv:SV_CouplingType'">
            <xsl:value-of select="'IC_114'"/>
          </xsl:when>
          <xsl:when test="normalize-space(name(.)) = 'srv:DCPList'">
            <xsl:value-of select="'IC_112'"/>
          </xsl:when>
          <xsl:when
            test="normalize-space(name(.)) = 'gmd:fileType' and @xsi:type='napm:napMD_FileFormatCode_PropertyType'">
            <xsl:value-of select="'IC_115'"/>
          </xsl:when>
          <xsl:otherwise>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:attribute name="codeList">
        <xsl:choose>
          <xsl:when test="normalize-space($codelistCode) != ''">
            <xsl:value-of
              select="concat('http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#',$codelistCode)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of
              select="concat('http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#',local-name(.))"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:if test="string(@codeListValue) and normalize-space($codelistCode) != ''">
        <xsl:variable name="elementCodeValue" select="string(@codeListValue)"/>
        <xsl:choose>
          <xsl:when
            test="gco:CharacterString and normalize-space(name(.)) = 'gmd:fileType' and @xsi:type='napm:napMD_FileFormatCode_PropertyType'">
            <gco:CharacterString>
              <xsl:value-of
                select="$codelistDocument/codelists/codelist[@name='napm:napMD_FileFormatCode']/entry[code = $elementCodeValue]/value"/>
            </gco:CharacterString>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="elementName" select="name()"/>
            <xsl:value-of
              select="$codelistDocument/codelists/codelist[@name=$elementName]/entry[code = $elementCodeValue]/value"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

	<!-- ================================================================= -->

  <xsl:template match="gmx:FileName[contains(../../@id,'geonetwork.thesaurus.')]" priority="200">
		<xsl:copy>
    	<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>

	<!-- ================================================================= -->

  <xsl:template match="gmx:FileName[name(..)!='gmd:contactInstructions']">
    <xsl:copy>
			<xsl:attribute name="src">
				<xsl:choose>
					<xsl:when test="/root/env/config/downloadservice/simple='true'">
						<xsl:value-of select="concat(/root/env/siteURL,'/resources.get?id=',/root/env/id,'&amp;fname=',.,'&amp;access=private')"/>
					</xsl:when>
					<xsl:when test="/root/env/config/downloadservice/withdisclaimer='true'">
						<xsl:value-of select="concat(/root/env/siteURL,'/file.disclaimer?id=',/root/env/id,'&amp;fname=',.,'&amp;access=private')"/>
					</xsl:when>
					<xsl:otherwise> <!-- /root/env/config/downloadservice/leave='true' -->
						<xsl:value-of select="@src"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:value-of select="."/>
		</xsl:copy>
	</xsl:template>

	<!-- ================================================================= -->

	<!-- Do not allow to expand operatesOn sub-elements
		and constrain users to use uuidref attribute to link
		service metadata to datasets. This will avoid to have
		error on XSD validation. -->
	<xsl:template match="srv:operatesOn|gmd:featureCatalogueCitation">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
		</xsl:copy>
	</xsl:template>


	<!-- ================================================================= -->
	<!-- Set local identifier to the first 2 letters of iso code. Locale ids
		are used for multilingual charcterString using #iso2code for referencing.
	-->
	<xsl:template match="gmd:PT_Locale">

		<xsl:variable name="id" select="substring(gmd:languageCode/gmd:LanguageCode/@codeListValue, 1, 3)"/>
		<xsl:choose>
			<xsl:when test="@id and (normalize-space(@id)!='' and normalize-space(@id)=$id)">
				<xsl:copy>
          <xsl:copy-of select="@*" />

          <gmd:languageCode>
            <gmd:LanguageCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_116">
              <xsl:attribute name="codeListValue">
                <xsl:value-of select="$id"/>
              </xsl:attribute>
              <xsl:choose>
                <xsl:when test="normalize-space($id) = 'fra'">French; Français</xsl:when>
                <xsl:otherwise>English; Anglais</xsl:otherwise>
              </xsl:choose>
            </gmd:LanguageCode>
          </gmd:languageCode>
          <xsl:apply-templates select="gmd:country" />
          <xsl:apply-templates select="gmd:characterEncoding" />
        </xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<gmd:PT_Locale>
					<xsl:attribute name="id">
						<xsl:value-of select="$id"/>
					</xsl:attribute>

          <gmd:languageCode>
            <gmd:LanguageCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_116">
              <xsl:attribute name="codeListValue">
                <xsl:value-of select="$id"/>
              </xsl:attribute>
              <xsl:choose>
                <xsl:when test="normalize-space($id) = 'fra'">French; Français</xsl:when>
                <xsl:otherwise>English; Anglais</xsl:otherwise>
              </xsl:choose>
            </gmd:LanguageCode>
          </gmd:languageCode>
          <xsl:apply-templates select="gmd:country" />
          <xsl:apply-templates select="gmd:characterEncoding" />
				</gmd:PT_Locale>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

  <xsl:template match="gmd:MD_DataIdentification">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>

      <xsl:apply-templates select="gmd:citation"/>
      <xsl:apply-templates select="gmd:abstract"/>
      <xsl:apply-templates select="gmd:purpose"/>
      <xsl:apply-templates select="gmd:credit"/>

      <xsl:apply-templates select="gmd:status"/>
      <xsl:apply-templates select="gmd:pointOfContact"/>
      <xsl:apply-templates select="gmd:resourceMaintenance"/>
      <xsl:apply-templates select="gmd:graphicOverview"/>
      <xsl:apply-templates select="gmd:resourceFormat"/>


      <xsl:variable name="keywordGroups">
        <keywords xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco">

          <!-- Keywords without or empty thesaurus -->
          <!-- Group by type -->
          <xsl:for-each-group select="gmd:descriptiveKeywords[not(gmd:MD_Keywords/gmd:thesaurusName) or not(string(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString))]" group-by="gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue">

            <!-- Group by thesaurus -->
              <keyword-group type="{gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue}" value="{gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode}">
                <xsl:for-each select="current-group()/gmd:MD_Keywords/gmd:keyword">
                  <keyword value="{gco:CharacterString}" translation="{gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale != concat('#', $mainLanguageId)]}"
                           locale="{gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[string(@locale) and @locale != concat('#', $mainLanguageId)]/@locale}">
                    <xsl:copy-of select="../gmd:thesaurusName" />
                  </keyword>
                </xsl:for-each>
              </keyword-group>

          </xsl:for-each-group>

          <!-- Keywords with thesaurus -->
          <!-- Group by type -->
        <xsl:for-each-group select="gmd:descriptiveKeywords[string(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString)]" group-by="gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode">

          <!-- Group by thesaurus -->
          <xsl:for-each-group select="current-group()" group-by="gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString">
            <keyword-group type="{gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue}" value="{gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode}">
              <xsl:for-each select="current-group()/gmd:MD_Keywords/gmd:keyword">
                <keyword value="{gco:CharacterString}" translation="{gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale != concat('#', $mainLanguageId)]}"
                         locale="{gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[string(@locale) and @locale != concat('#', $mainLanguageId)]/@locale}">
                  <xsl:copy-of select="../gmd:thesaurusName" />
                </keyword>
              </xsl:for-each>
            </keyword-group>

          </xsl:for-each-group>
        </xsl:for-each-group>

        </keywords>
      </xsl:variable>

      <xsl:variable name="list-keywords" select="exslt:node-set($keywordGroups)" />
      <!--<xsl:for-each select="$list-keywords/keywords/keyword-group">
        <xsl:message>KEYWORD GROUP: <xsl:value-of select="@type" /></xsl:message>
        <xsl:for-each select="keyword">
          <xsl:message>KEYWORD11: <xsl:value-of select="@value" /> - <xsl:value-of select="@locale" /></xsl:message>
        </xsl:for-each>
      </xsl:for-each>-->

      <xsl:for-each select="$list-keywords/keywords/keyword-group">

        <xsl:variable name="currentCodeValue" select="@type" />
        <gmd:descriptiveKeywords>
          <gmd:MD_Keywords>

            <xsl:for-each select="keyword">

              <xsl:choose>
                <xsl:when test="$isMultilingual">
                  <gmd:keyword xsi:type="gmd:PT_FreeText_PropertyType">
                    <gco:CharacterString><xsl:value-of select="@value" /></gco:CharacterString>
                    <gmd:PT_FreeText>
                      <gmd:textGroup>
                        <gmd:LocalisedCharacterString locale="{@locale}"><xsl:value-of select="@translation" /></gmd:LocalisedCharacterString>
                      </gmd:textGroup>
                    </gmd:PT_FreeText>
                  </gmd:keyword>
                </xsl:when>
                <xsl:otherwise>
                  <gmd:keyword>
                    <gco:CharacterString><xsl:value-of select="@value" /></gco:CharacterString>
                  </gmd:keyword>
                </xsl:otherwise>
              </xsl:choose>

            </xsl:for-each>


            <gmd:type>
              <gmd:MD_KeywordTypeCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_101" codeListValue="{@type}">
                  <xsl:value-of select="$codelistDocument/codelists/codelist[@name='gmd:MD_KeywordTypeCode']/entry[code = $currentCodeValue]/value"/>
              </gmd:MD_KeywordTypeCode>
            </gmd:type>

            <xsl:apply-templates select="keyword[1]/gmd:thesaurusName" />
          </gmd:MD_Keywords>
        </gmd:descriptiveKeywords>
      </xsl:for-each>


      <!--<xsl:apply-templates select="gmd:descriptiveKeywords" />-->
      <xsl:apply-templates select="gmd:resourceSpecificUsage"/>
      <xsl:apply-templates select="gmd:resourceConstraints"/>
      <xsl:apply-templates select="gmd:aggregationInfo"/>
      <xsl:apply-templates select="gmd:spatialRepresentationType"/>
      <xsl:apply-templates select="gmd:spatialResolution"/>
      <xsl:apply-templates select="gmd:language"/>
      <xsl:apply-templates select="gmd:characterSet"/>
      <xsl:apply-templates select="gmd:topicCategory"/>
      <xsl:apply-templates select="gmd:environmentDescription"/>
      <xsl:apply-templates select="gmd:extent"/>
      <xsl:apply-templates select="gmd:supplementalInformation"/>
    </xsl:copy>
  </xsl:template>



  <xsl:template  match="gco:Distance">
    <xsl:element name="gco:{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="uom">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/uom/gmxUom.xml#<xsl:value-of select="@uom"/></xsl:attribute>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>



  <xsl:template match="gmd:onLine[@xlink:title]" priority="100">
    <xsl:copy>
      <xsl:apply-templates select="@*[name()!='xlink:title']" />

      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="gco:Date">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="@xsi:nil and string(.)"><xsl:copy-of select="@*[not(name()='xsi:nil')]" /> </xsl:when>
        <xsl:otherwise><xsl:copy-of select="@*" /></xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="gml:TimePeriod[gml:beginPosition]" priority="100">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="not(string(@gml:id))">
          <xsl:copy-of select="@*[not(name()='gml:id')]"/>
          <xsl:attribute name="gml:id" select="generate-id()" />

        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="@*"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:apply-templates select="gml:beginPosition" />
      <xsl:apply-templates select="gml:endPosition" />

      <xsl:if test="not(gml:endPosition)">
        <gml:endPosition />
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- Fix the dates for the Core Subject Thesaurus -->
  <xsl:template match="gmd:thesaurusName/gmd:CI_Citation[gmd:title/gco:CharacterString='Government of Canada Core Subject Thesaurus' or
                                        gmd:title/gco:CharacterString='Thésaurus des sujets de base du gouvernement du Canada']">

    <xsl:copy>
      <xsl:copy-of select="@*" />

      <xsl:apply-templates select="gmd:title" />
      <xsl:apply-templates select="gmd:alternateTitle" />

      <gmd:date>
        <gmd:CI_Date>
          <gmd:date>
            <gco:Date>2004</gco:Date>
          </gmd:date>
          <gmd:dateType>
            <gmd:CI_DateTypeCode codeListValue="RI_366" codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_87">creation;création</gmd:CI_DateTypeCode>
          </gmd:dateType>
        </gmd:CI_Date>
      </gmd:date>

      <gmd:date>
        <gmd:CI_Date>
          <gmd:date>
            <gco:Date>2015-04-21</gco:Date>
          </gmd:date>
          <gmd:dateType>
            <gmd:CI_DateTypeCode codeList="http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml#IC_87" codeListValue="RI_367">publication; publication</gmd:CI_DateTypeCode>
          </gmd:dateType>
        </gmd:CI_Date>
      </gmd:date>

      <xsl:apply-templates select="gmd:edition" />
      <xsl:apply-templates select="gmd:editionDate" />
      <xsl:apply-templates select="gmd:identifier" />
      <xsl:apply-templates select="gmd:citedResponsibleParty" />
      <xsl:apply-templates select="gmd:presentationForm" />
      <xsl:apply-templates select="gmd:series" />
      <xsl:apply-templates select="gmd:otherCitationDetails" />
      <xsl:apply-templates select="gmd:collectiveTitle" />
      <xsl:apply-templates select="gmd:ISBN" />
      <xsl:apply-templates select="gmd:ISSN" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@xsi:schemaLocation">
    <xsl:if test="XslUtil:getSettingValue('system/metadata/validation/removeSchemaLocation') = 'false'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>

  <!-- ================================================================= -->
	<!-- copy everything else as is -->

	<xsl:template match="@*|node()">
	    <xsl:copy>
	        <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
	</xsl:template>

</xsl:stylesheet>
