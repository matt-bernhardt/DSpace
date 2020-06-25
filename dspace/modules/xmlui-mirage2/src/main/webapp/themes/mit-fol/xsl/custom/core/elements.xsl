<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Templates to cover the common dri elements.

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

-->

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

    <!-- First and foremost come the div elements, which are the only elements directly under body. Every
    document has a body and every body has at least one div, which may in turn contain other divs and
    so on. Divs can be of two types: interactive and non-interactive, as signified by the attribute of
    the same name. The two types are handled separately.
-->

    <!-- Non-interactive divs get turned into HTML div tags. The general process, which is found in many
        templates in this stylesheet, is to call the template for the head element (creating the HTML h tag),
        handle the attributes, and then apply the templates for the all children except the head. The id
        attribute is -->
    <xsl:template match="dri:div" priority="1">
        <xsl:apply-templates select="dri:head"/>
        <xsl:apply-templates select="@pagination">
            <xsl:with-param name="position">top</xsl:with-param>
        </xsl:apply-templates>
        <div>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">ds-static-div</xsl:with-param>
            </xsl:call-template>
            <xsl:choose>
                <!--  does this element have any children -->
                <xsl:when test="child::node()">
                    <xsl:apply-templates select="*[not(name()='head')]"/>
                </xsl:when>
                <!-- if no children are found we add a space to eliminate self closing tags -->
                <xsl:otherwise>
                    &#160;
                </xsl:otherwise>
            </xsl:choose>
        </div>
        <xsl:variable name="itemDivision">
            <xsl:value-of select="@n"/>
        </xsl:variable>
        <xsl:variable name="xrefTarget">
            <xsl:value-of select="./dri:p/dri:xref/@target"/>
        </xsl:variable>
        <!--<xsl:if test="$itemDivision='item-view'">-->
            <!--<xsl:call-template name="cc-license">-->
                <!--<xsl:with-param name="metadataURL" select="./dri:referenceSet/dri:reference/@url"/>-->
            <!--</xsl:call-template>-->
        <!--</xsl:if>-->
        <xsl:apply-templates select="@pagination">
            <xsl:with-param name="position">bottom</xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>


    <xsl:template match="dri:div[@interactive='yes']" priority="2">
        <xsl:apply-templates select="@pagination">
            <xsl:with-param name="position">top</xsl:with-param>
        </xsl:apply-templates>
        <form>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">ds-interactive-div</xsl:with-param>
            </xsl:call-template>
            <xsl:attribute name="action"><xsl:value-of select="@action"/></xsl:attribute>
            <xsl:attribute name="method"><xsl:value-of select="@method"/></xsl:attribute>
            <xsl:if test="@autocomplete">
                <xsl:attribute name="autocomplete"><xsl:value-of select="@autocomplete"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="@method='multipart'">
                <xsl:attribute name="method">post</xsl:attribute>
                <xsl:attribute name="enctype">multipart/form-data</xsl:attribute>
            </xsl:if>
            <xsl:attribute name="onsubmit">javascript:tSubmit(this);</xsl:attribute>
            <!--For Item Submission process, disable ability to submit a form by pressing 'Enter'-->
            <xsl:if test="starts-with(@n,'submit')">
                <xsl:attribute name="onkeydown">javascript:return disableEnterKey(event);</xsl:attribute>
            </xsl:if>

            <xsl:apply-templates select="dri:head"/>
            <xsl:apply-templates select="*[not(name()='head')]"/>

        </form>
        <!-- JS to scroll form to DIV parent of "Add" button if jump-to -->
        <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='jumpTo']">
            <script type="text/javascript">
                <xsl:text>var button = document.getElementById('</xsl:text>
                <xsl:value-of select="translate(@id,'.','_')"/>
                <xsl:text>').elements['</xsl:text>
                <xsl:value-of select="concat('submit_',/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='jumpTo'],'_add')"/>
                <xsl:text>'];</xsl:text>
            <xsl:text>
                      if (button != null) {
                        var n = button.parentNode;
                        for (; n != null; n = n.parentNode) {
                            if (n.tagName == 'DIV') {
                              n.scrollIntoView(false);
                              break;
                           }
                        }
                      }
            </xsl:text>
            </script>
        </xsl:if>
        <xsl:apply-templates select="@pagination">
            <xsl:with-param name="position">bottom</xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="dri:xref[@rend='targetBlank']">
        <a>
            <xsl:if test="@target">
                <xsl:attribute name="href"><xsl:value-of select="@target"/></xsl:attribute>
            </xsl:if>

            <xsl:if test="@n">
                <xsl:attribute name="name"><xsl:value-of select="@n"/></xsl:attribute>
            </xsl:if>

            <xsl:if test="@onclick">
                <xsl:attribute name="onclick"><xsl:value-of select="@onclick"/></xsl:attribute>
            </xsl:if>

            <xsl:attribute name="target"><xsl:text>_blank</xsl:text></xsl:attribute>

            <xsl:apply-templates />
        </a>
    </xsl:template>

</xsl:stylesheet>
