<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                  xmlns:gco="http://www.isotc211.org/2005/gco"
                  xmlns:gmd="http://www.isotc211.org/2005/gmd"
                  exclude-result-prefixes="gmd">

    <!-- ================================================================= -->

    <xsl:template match="/root">
        <xsl:apply-templates select="*[name() != 'env']"/>
    </xsl:template>

    <!-- ================================================================= -->

    <!-- Cleanup DOI -->
    <xsl:template match="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:identifier" />


    <!-- ================================================================= -->

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- ================================================================= -->

</xsl:stylesheet>