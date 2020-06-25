<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
                xmlns:dri="http://di.tamu.edu/DRI/1.0/"
                xmlns:mets="http://www.loc.gov/METS/"
                xmlns:xlink="http://www.w3.org/TR/xlink/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc">

    <xsl:output indent="yes"/>

    <!-- =============================================================== -->
    <!-- - - - - - New templates for Choice/Authority control - - - - -  -->

    <!-- choose 'hidden' for invisible auth, 'text' lets CSS control it. -->
    <xsl:variable name="authorityInputType" select="'text'"/>

    <!-- add button to invoke Choices lookup popup.. assume
      -  that the context is a dri:field, where dri:params/@choices is true.
     -->
    <xsl:template name="addLookupButtonDepartment">
        <xsl:param name="editItemNewMetadata"/>
        <button type="button" name="{concat('lookup_',@n)}">
            <xsl:attribute name="class">
                <xsl:text>ds-button-field ds-add-button btn btn-default </xsl:text>
                <xsl:if test="@type = 'hidden'"><xsl:text>hidden </xsl:text></xsl:if>
            </xsl:attribute>
            <xsl:attribute name="onClick">
                <xsl:text>javascript:DepartmentLookup('</xsl:text>
                <!-- URL -->
                <xsl:value-of select="concat($context-path, '/choices/')"/>
                <xsl:choose>
                    <xsl:when test="starts-with(@n, 'value_')">
                        <xsl:value-of select="dri:params/@choices"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@n"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>', '</xsl:text>
                <xsl:value-of select="@n"/>
                <xsl:text>', </xsl:text>
                <!-- Collection ID for context -->
                <xsl:choose>
                    <xsl:when test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='choice'][@qualifier='collection']">
                        <xsl:text>'</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='choice'][@qualifier='collection']"/>
                        <xsl:text>'</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>-1</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>, </xsl:text>
                <xsl:choose>
                    <xsl:when test="$editItemNewMetadata = 'true'">
                        <xsl:text>true</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>false</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>);</xsl:text>
            </xsl:attribute>
            <i18n:text>xmlui.ChoiceLookupTransformer.lookup</i18n:text>
        </button>
    </xsl:template>

</xsl:stylesheet>