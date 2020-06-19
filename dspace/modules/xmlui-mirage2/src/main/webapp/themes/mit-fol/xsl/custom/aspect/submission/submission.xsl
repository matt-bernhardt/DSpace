<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
                xmlns:dri="http://di.tamu.edu/DRI/1.0/"
                xmlns:mets="http://www.loc.gov/METS/"
                xmlns:xlink="http://www.w3.org/TR/xlink/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:confman="org.dspace.core.ConfigurationManager"
                exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc confman">

    <xsl:template match="dri:div[@n='quick-step-user-info']/dri:p">
        <div class="alert alert-success alert-dismissible">
            <p>
                <xsl:apply-templates/>
                <a href="#" class="close" data-dismiss="alert" aria-label="close">&#xd7;</a>
            </p>
        </div>
    </xsl:template>

    <xsl:template match="dri:item[@n='quicksbmit-file-section']">
        <div class="ds-form-item row">
            <div class="control-group col-sm-12">
                <label class="control-label">
                    <i18n:text>xmlui.Submission.submit.Quicksubmit.file</i18n:text>
                    <xsl:text>:</xsl:text>
                </label>
                <p>
                    <xsl:apply-templates/>
                    <span class="pull-right">

                        <xsl:apply-templates select="//dri:field[@type='button' and @rend='quicksbmit-file-section']" mode="quicksubmit"/>

                    </span>
                </p>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="dri:field[@type='button' and @rend='quicksbmit-file-section']" mode="quicksubmit">
        <button type="submit" name="{@n}" class="ds-button-field ds-delete-button btn btn-default">
            <i18n:text>xmlui.Submission.submit.QuickSubmitStep.submit_remove</i18n:text>
        </button>
    </xsl:template>

    <xsl:template match="dri:field[@type='button' and @rend='quicksbmit-file-section']"/>

    <xsl:template match="dri:item[contains(@rend,'license-content')]">
        <xsl:variable name="position">
            <xsl:value-of select="position()"/>
        </xsl:variable>
        <li id="license-{$position}" class="{@rend}">
            <xsl:value-of select="." disable-output-escaping="yes"/>
        </li>
    </xsl:template>



</xsl:stylesheet>