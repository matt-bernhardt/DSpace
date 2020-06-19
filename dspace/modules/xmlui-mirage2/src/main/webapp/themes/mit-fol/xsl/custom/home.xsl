<xsl:stylesheet
        xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
        xmlns:dri="http://di.tamu.edu/DRI/1.0/"
        xmlns:mets="http://www.loc.gov/METS/"
        xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
        xmlns:xlink="http://www.w3.org/TR/xlink/"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
        xmlns="http://www.w3.org/1999/xhtml"
        xmlns:xalan="http://xml.apache.org/xalan"
        xmlns:encoder="xalan://java.net.URLEncoder"
        xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
        xmlns:jstring="java.lang.String"
        xmlns:rights="http://cosimo.stanford.edu/sdr/metsrights/"
        xmlns:confman="org.dspace.core.ConfigurationManager"
        exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util jstring rights confman">

    <xsl:output indent="yes"/>

    <xsl:template match="dri:div[@id='search-section-homepage']">
        <form method="post" class="" id="home-search-form" action="{$context-path}/discover">
            <fieldset>
                <i18n:text>xmlui.general.search-mit</i18n:text>
                <div class="input-group">
                    <input placeholder="Search" type="text" class="ds-text-field form-control" name="query" aria-label="Search MIT DSpace" />
                    <span class="input-group-btn">
                        <button title="Search" class="ds-button-field btn btn-primary">
                            <i18n:text>xmlui.general.search</i18n:text>
                        </button>
                    </span>
                </div>
                <a href="{$context-path}/discover">
                    <i18n:text>xmlui.general.search-advanced</i18n:text>
                </a>
            </fieldset>
        </form>
    </xsl:template>

</xsl:stylesheet>
