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

    <xsl:template match="dri:xref">
        <a>
            <xsl:if test="@target">
                <xsl:choose>
                    <xsl:when test="contains(./@target, '{{context-path}}')">
                        <xsl:attribute name="href">
                            <xsl:call-template name="string-replace-all">
                                <xsl:with-param name="text" select="./@target"/>
                                <xsl:with-param name="replace" select="'{{context-path}}'"/>
                                <xsl:with-param name="by" select="$context-path"/>
                            </xsl:call-template>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="href">
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>

            <xsl:if test="@rend">
                <xsl:choose>
                    <xsl:when test="starts-with(@rend, 'download=')">
                        <xsl:attribute name="download">
                            <xsl:value-of select="substring-after(@rend, 'download=')"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="class">
                            <xsl:value-of select="@rend"/>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>

            <xsl:if test="@n">
                <xsl:attribute name="name">
                    <xsl:value-of select="@n"/>
                </xsl:attribute>
            </xsl:if>

            <xsl:if test="@onclick">
                <xsl:attribute name="onclick">
                    <xsl:value-of select="@onclick"/>
                </xsl:attribute>
            </xsl:if>

            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <xsl:template name="string-replace-all">
        <xsl:param name="text"/>
        <xsl:param name="replace"/>
        <xsl:param name="by"/>
        <xsl:choose>
            <xsl:when test="contains($text, $replace)">
                <xsl:value-of select="substring-before($text,$replace)"/>
                <xsl:value-of select="$by"/>
                <xsl:call-template name="string-replace-all">
                    <xsl:with-param name="text"
                                    select="substring-after($text,$replace)"/>
                    <xsl:with-param name="replace" select="$replace"/>
                    <xsl:with-param name="by" select="$by"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>