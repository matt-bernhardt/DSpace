<?xml version="1.0" encoding="UTF-8"?>
<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Author: Art Lowel (art at atmire dot com)

    The purpose of this file is to transform the DRI for some parts of
    DSpace into a format more suited for the theme xsls. This way the
    theme xsl files can stay cleaner, without having to change Java
    code and interfere with other themes

    e.g. this file can be used to add a class to a form field, without
    having to duplicate the entire form field template in the theme xsl
    Simply add it here to the rend attribute and let the default form
    field template handle the rest.
-->

<xsl:stylesheet
        xmlns="http://di.tamu.edu/DRI/1.0/"
        xmlns:dri="http://di.tamu.edu/DRI/1.0/"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
        xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
        xmlns:confman="org.dspace.core.ConfigurationManager"
        exclude-result-prefixes="xsl dri i18n confman">

    <xsl:output indent="yes"/>

    <xsl:template match="//dri:pageMeta/dri:metadata[@element='javascript' and text()='aspects/Statistics/js/interactive-stats-table.js?v=2']">
        <!-- interactive-stats-table.js has been overridden in the theme
             however we need the statlet_main.js to load in dependencies like the i18n
        -->
        <metadata element="javascript" qualifier="static">aspects/ReportingSuite/scripts/statlet_main.js</metadata>
    </xsl:template>

    <!-- most popular countries - maps -->
    <xsl:template match="dri:div[@id='aspect.statistics.mostpopular.MostPopular.div.geo-stat-chart' or @id='aspect.statistics.mostpopular.MostPopular.div.geo-stat-chart-cities']">
        <div rend="panel panel-default">
            <xsl:attribute name="id">
                <xsl:value-of select="@id"/><xsl:text>_wrapper</xsl:text>
            </xsl:attribute>
            <div rend="panel-heading">
                <hi rend="fa fa-globe">&#160;</hi>
                <xsl:choose>
                    <xsl:when test="@id='aspect.statistics.mostpopular.MostPopular.div.geo-stat-chart'">
                        <hi>
                            <i18n:text>xmlui.mit.most-popular.map.total-downloads-by-country</i18n:text>
                        </hi>
                    </xsl:when>
                    <xsl:otherwise>
                        <hi>
                            <i18n:text>xmlui.mit.most-popular.map.total-downloads-by-city</i18n:text>
                        </hi>
                    </xsl:otherwise>
                </xsl:choose>

            </div>
            <div>
                <xsl:call-template name="copy-attributes"/>
                <div rend="map" id="chart">
                    <hi>
                        <i18n:text>xmlui.mit.most-popular.map.loading</i18n:text>
                    </hi>
                </div>
                <div rend="areaLegend">
                    <hi>
                        <i18n:text>xmlui.mit.most-popular.map.loading</i18n:text>
                    </hi>
                    <hi rend="geochartDisclaimer">
                        <hi rend="bold"><i18n:text>xmlui.mit.most-popular.map.disclaimer</i18n:text>:
                        </hi>
                        <hi>
                            <i18n:text>xmlui.mit.most-popular.map.disclaimer-content</i18n:text>
                        </hi>
                    </hi>
                </div>
            </div>
        </div>
    </xsl:template>


</xsl:stylesheet>
