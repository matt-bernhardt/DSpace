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
    <xsl:variable name="author-limit" select="5"/>

    <xsl:template name="itemSummaryView-DIM-file-section">
        <xsl:variable name="primaryID" select="//mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
        <xsl:variable name="primaryFile" select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file[@ID = $primaryID]"/>

        <xsl:variable name="label-1">
            <xsl:choose>
                <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.1')">
                    <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.1')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>label</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="label-2">
            <xsl:choose>
                <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.2')">
                    <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.2')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>title</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="string-length($primaryID) &gt; 0 and $primaryFile[@MIMETYPE = 'text/html']">
                <div class="item-page-field-wrapper table word-break">

                    <xsl:call-template name="itemSummaryView-DIM-file-section-entry">
                        <xsl:with-param name="href" select="$primaryFile/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                        <xsl:with-param name="mimetype" select="$primaryFile/@MIMETYPE"/>
                        <xsl:with-param name="label-1" select="$label-1"/>
                        <xsl:with-param name="label-2" select="$label-2"/>
                        <xsl:with-param name="title" select="$primaryFile/mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                        <xsl:with-param name="label" select="$primaryFile/mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                        <xsl:with-param name="size" select="$primaryFile/@SIZE"/>
                        <xsl:with-param name="licenseKey" select="$primaryFile/mets:FLocat[@LOCTYPE='URL']/@licenseKey"/>
                        <xsl:with-param name="licenseContent" select="$primaryFile/mets:FLocat[@LOCTYPE='URL']/@licenseContent"/>
                    </xsl:call-template>

                    <xsl:if test="count(//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file) &gt; 11 and not(//mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim[@non-archived='y'])">
                        <xsl:apply-templates mode="itemSummaryView-DIM-disseminate" select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']"/>
                    </xsl:if>
                </div>
            </xsl:when>
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">


                <div class="item-page-field-wrapper table word-break">

                    <xsl:if test="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file[1]">
                        <xsl:variable name="file" select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file[1]"/>
                        <xsl:call-template name="itemSummaryView-DIM-file-section-entry">
                            <xsl:with-param name="href" select="$file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            <xsl:with-param name="mimetype" select="$file/@MIMETYPE"/>
                            <xsl:with-param name="label-1" select="$label-1"/>
                            <xsl:with-param name="label-2" select="$label-2"/>
                            <xsl:with-param name="title" select="$file/mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                            <xsl:with-param name="label" select="$file/mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                            <xsl:with-param name="size" select="$file/@SIZE"/>
                            <xsl:with-param name="embargoDate" select="$file/@EMBARGODATE"/>
                            <xsl:with-param name="licenseKey" select="$file/mets:FLocat[@LOCTYPE='URL']/@licenseKey"/>
                            <xsl:with-param name="licenseContent" select="$file/mets:FLocat[@LOCTYPE='URL']/@licenseContent"/>
                        </xsl:call-template>
                    </xsl:if>

                    <xsl:if test="count(//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file) &gt; 11 and not(//mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim[@non-archived='y'])">
                        <xsl:apply-templates mode="itemSummaryView-DIM-disseminate" select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']"/>
                    </xsl:if>
                </div>
                <div class="item-page-field-wrapper table word-break">

                    <xsl:if test="count(//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file) &gt; 1">
                        <h5>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-alternate</i18n:text>
                        </h5>
                        <xsl:for-each select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file[position() &gt; 1]">
                            <xsl:call-template name="itemSummaryView-DIM-file-section-entry-alternate">
                                <xsl:with-param name="href" select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                <xsl:with-param name="mimetype" select="@MIMETYPE"/>
                                <xsl:with-param name="label-1" select="$label-1"/>
                                <xsl:with-param name="label-2" select="$label-2"/>
                                <xsl:with-param name="title" select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                                <xsl:with-param name="label" select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                                <xsl:with-param name="size" select="@SIZE"/>
                                <xsl:with-param name="embargoDate" select="@EMBARGODATE"/>
                                <xsl:with-param name="licenseKey" select="mets:FLocat[@LOCTYPE='URL']/@licenseKey"/>
                                <xsl:with-param name="licenseContent" select="mets:FLocat[@LOCTYPE='URL']/@licenseContent"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:if>
                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="//mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemSummaryView-DIM"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="itemSummaryView-DIM-disseminate" match="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']">
        <div id="mit-item-dissemination">
            <xsl:variable name="action">
                <xsl:value-of select="$context-path" />
                <xsl:text>/disseminate-package/</xsl:text>
                <xsl:value-of select="substring-after(ancestor::mets:METS/@ID,':')" />
                <xsl:text>/</xsl:text>
                <xsl:value-of select="substring-after(substring-after(ancestor::mets:METS/@ID,':'),'/')" />
                <xsl:text>.zip</xsl:text>
            </xsl:variable>
            <form method="POST" action="{$action}" id="dissemination-form">
                <xsl:choose>
                    <xsl:when test="../mets:fileGrp[@USE='METADATA']/mets:file/mets:FLocat[@xlink:title = 'imsmanifest.xml']">
                        <a href="#" onclick="document.getElementById('dissemination-form').submit(); return false;"><i18n:text>xmlui.dri2xhtml.METS-1.0.download-zip.OCW-IMSCP</i18n:text></a>
                        <input type="hidden" name="package" value="OCW-IMSCP" />
                    </xsl:when>
                    <xsl:otherwise>
                        <a href="#" onclick="document.getElementById('dissemination-form').submit(); return false;"><i18n:text>xmlui.dri2xhtml.METS-1.0.download-zip.METS</i18n:text></a>
                        <input type="hidden" name="package" value="METS" />
                    </xsl:otherwise>
                </xsl:choose>
            </form>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-file-section-entry">
        <xsl:param name="href"/>
        <xsl:param name="mimetype"/>
        <xsl:param name="label-1"/>
        <xsl:param name="label-2"/>
        <xsl:param name="title"/>
        <xsl:param name="label"/>
        <xsl:param name="size"/>
        <xsl:param name="embargoDate"/>
        <xsl:param name="licenseKey"/>
        <xsl:param name="licenseContent"/>

        <div>
            <!--<xsl:if test="$embargoDate">-->
                <!--<i18n:text>xmlui.dri2xhtml.METS-embargo-until</i18n:text>-->
                <!--<xsl:text> </xsl:text>-->
                <!--<xsl:value-of select="$embargoDate"/>-->
            <!--</xsl:if>-->
            <a class="btn btn-primary download-button">
                <xsl:attribute name="href">
                    <xsl:value-of select="$href"/>
                </xsl:attribute>
                <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-download</i18n:text>
            </a>
            <xsl:call-template name="itemSummaryView-DIM-file-section-entry-description">
                <xsl:with-param name="mimetype" select="$mimetype"/>
                <xsl:with-param name="label-1" select="$label-1"/>
                <xsl:with-param name="label-2" select="$label-2"/>
                <xsl:with-param name="title" select="$title"/>
                <xsl:with-param name="label" select="$label"/>
                <xsl:with-param name="size" select="$size"/>
                <xsl:with-param name="embargoDate" select="$embargoDate"/>
            </xsl:call-template>
        </div>
        <xsl:if test="$licenseKey != '' and $licenseContent != ''">
            <div class="bitstream-license">
                <a class="license-key" href="#">
                    <i aria-hidden="true" class="glyphicon  glyphicon-list-alt"></i>
                    <xsl:text> </xsl:text>
                    <i18n:text>
                        <xsl:value-of select="$licenseKey"/>
                    </i18n:text>
                </a>
                <div class="hidden license-content">
                    <xsl:value-of select="$licenseContent" disable-output-escaping="yes"/>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template name="itemSummaryView-DIM-file-section-entry-alternate">
        <xsl:param name="href"/>
        <xsl:param name="mimetype"/>
        <xsl:param name="label-1"/>
        <xsl:param name="label-2"/>
        <xsl:param name="title"/>
        <xsl:param name="label"/>
        <xsl:param name="size"/>
        <xsl:param name="embargoDate"/>
        <xsl:param name="licenseKey"/>
        <xsl:param name="licenseContent"/>

        <div>
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="$href"/>
                </xsl:attribute>
                <xsl:call-template name="itemSummaryView-DIM-file-section-entry-description">
                    <xsl:with-param name="mimetype" select="$mimetype"/>
                    <xsl:with-param name="label-1" select="$label-1"/>
                    <xsl:with-param name="label-2" select="$label-2"/>
                    <xsl:with-param name="title" select="$title"/>
                    <xsl:with-param name="label" select="$label"/>
                    <xsl:with-param name="size" select="$size"/>
                    <xsl:with-param name="embargoDate" select="$embargoDate"/>
                </xsl:call-template>
            </a>
        </div>

        <xsl:if test="$licenseKey != '' and $licenseContent != ''">
            <div class="bitstream-license">
                <a class="license-key" href="#">
                    <i aria-hidden="true" class="glyphicon  glyphicon-list-alt"></i>
                    <xsl:text> </xsl:text>
                    <i18n:text>
                        <xsl:value-of select="$licenseKey"/>
                    </i18n:text>
                </a>
                <div class="hidden license-content">
                    <xsl:value-of select="$licenseContent" disable-output-escaping="yes"/>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="dim:dim" mode="itemSummaryView-DIM">
        <div class="item-summary-view-metadata">
            <xsl:call-template name="itemSummaryView-DIM-title"/>
            <xsl:call-template name="itemSummaryView-DIM-authors"/>

            <div class="row">
                <div class="col-sm-4 smaller-font">
                    <div class="row">
                        <div class="col-xs-6 col-sm-12">
                            <xsl:call-template name="itemSummaryView-DIM-thumbnail"/>
                        </div>
                        <div class="col-xs-6 col-sm-12">
                            <xsl:call-template name="itemSummaryView-DIM-file-section"/>
                        </div>
                    </div>
                    <xsl:call-template name="itemSummaryView-DIM-alternative-title"/>
                    <xsl:call-template name="itemSummaryView-DIM-other-contributors"/>
                    <xsl:call-template name="itemSummaryView-DIM-advisor"/>
                    <xsl:call-template name="itemSummaryView-DIM-terms"/>
                    <xsl:if test="$ds_item_view_toggle_url != ''">
                        <xsl:call-template name="itemSummaryView-show-full"/>
                    </xsl:if>
                </div>
                <div class="col-sm-8">
                    <xsl:call-template name="itemSummaryView-DIM-abstract"/>
                    <xsl:call-template name="itemSummaryView-DIM-description"/>
                    <xsl:call-template name="itemSummaryView-DIM-date"/>
                    <xsl:call-template name="itemSummaryView-DIM-URI"/>
                    <xsl:call-template name="itemSummaryView-DIM-department"/>
                    <xsl:call-template name="itemSummaryView-DIM-journal"/>
                    <xsl:call-template name="itemSummaryView-DIM-publisher"/>
                    <xsl:call-template name="itemSummaryView-DIM-citation"/>
                    <xsl:call-template name="itemSummaryView-DIM-workflow-duplicate"/>
                    <xsl:call-template name="itemSummaryView-DIM-identifier"/>
                    <xsl:call-template name="itemSummaryView-DIM-identifier-other"/>
                    <xsl:call-template name="itemSummaryView-DIM-identifier-isbn"/>
                    <xsl:call-template name="itemSummaryView-DIM-identifier-issn"/>
                    <xsl:call-template name="itemSummaryView-DIM-series"/>
                    <xsl:call-template name="itemSummaryView-DIM-has-part"/>
                    <xsl:call-template name="itemSummaryView-DIM-based-on"/>
                    <xsl:call-template name="itemSummaryView-DIM-subject"/>
                    <hr class="collection-separator"/>
                    <xsl:call-template name="itemSummaryView-collections"/>
                </div>
            </div>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-file-section-entry-description">
        <xsl:param name="mimetype"/>
        <xsl:param name="label-1"/>
        <xsl:param name="label-2"/>
        <xsl:param name="title"/>
        <xsl:param name="label"/>
        <xsl:param name="size"/>
        <xsl:param name="embargoDate"/>
        <xsl:choose>
            <xsl:when test="contains($label-1, 'label') and string-length($label)!=0">
                <xsl:value-of select="$label"/>
            </xsl:when>
            <xsl:when test="contains($label-1, 'title') and string-length($title)!=0">
                <xsl:value-of select="$title"/>
            </xsl:when>
            <xsl:when test="contains($label-2, 'label') and string-length($label)!=0">
                <xsl:value-of select="$label"/>
            </xsl:when>
            <xsl:when test="contains($label-2, 'title') and string-length($title)!=0">
                <xsl:value-of select="$title"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="getFileTypeDesc">
                    <xsl:with-param name="mimetype">
                        <xsl:value-of select="substring-before($mimetype,'/')"/>
                        <xsl:text>/</xsl:text>
                        <xsl:choose>
                            <xsl:when test="contains($mimetype,';')">
                                <xsl:value-of select="substring-before(substring-after($mimetype,'/'),';')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring-after($mimetype,'/')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text> (</xsl:text>
        <xsl:if test="$embargoDate">
            <i18n:text>xmlui.dri2xhtml.METS-embargo-until</i18n:text>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$embargoDate"/>
            <xsl:text>, </xsl:text>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$size &lt; 1024">
                <xsl:value-of select="$size"/>
                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
            </xsl:when>
            <xsl:when test="$size &lt; 1024 * 1024">
                <xsl:value-of select="substring(string($size div 1024),1,5)"/>
                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
            </xsl:when>
            <xsl:when test="$size &lt; 1024 * 1024 * 1024">
                <xsl:value-of select="substring(string($size div (1024 * 1024)),1,5)"/>
                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring(string($size div (1024 * 1024 * 1024)),1,5)"/>
                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>)</xsl:text>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-terms">
        <xsl:if test="dim:field[@element='rights' and (not(@qualifier) or @qualifier='uri')]">
            <div class="simple-item-view-terms item-page-field-wrapper">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-terms</i18n:text>
                </h5>
                <div>
                    <xsl:copy-of select="dim:field[@element='rights' and not(@qualifier)]"/>
                    <xsl:if test="dim:field[@element='rights' and @qualifier='uri']">
                        <a href="{dim:field[@element='rights' and @qualifier='uri']/text()}">
                            <xsl:copy-of select="dim:field[@element='rights' and @qualifier='uri']"/>
                        </a>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-series">
        <xsl:if test="dim:field[@element='relation' and @qualifier='ispartofseries']">
            <div class="simple-item-view-series item-page-field-wrapper">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-series</i18n:text>
                </h5>
                <div>
                    <xsl:for-each select="dim:field[@element='relation' and @qualifier='ispartofseries']">
                        <xsl:copy-of select="node()"/>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-department">
        <xsl:if test="dim:field[@element='contributor' and @qualifier='department']">
            <div class="simple-item-view-department item-page-field-wrapper">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-department</i18n:text>
                </h5>
                <span>
                    <xsl:for-each select="dim:field[@element='contributor' and @qualifier='department']">
                        <xsl:copy-of select="node()"/>
                        <xsl:if test="count(following-sibling::dim:field[@element='contributor' and @qualifier='department']) != 0">
                            <span class="spacer">;&#160;</span>
                        </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-journal">
        <xsl:if test="dim:field[@element='relation' and @qualifier='journal']">
            <div class="simple-item-view-journal item-page-field-wrapper">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-journal</i18n:text>
                </h5>
                <div>
                    <xsl:for-each select="dim:field[@element='relation' and @qualifier='journal']">
                        <xsl:copy-of select="node()"/>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-publisher">
        <xsl:if test="dim:field[@element='publisher' and not(@qualifier)]">
            <div class="simple-item-view-journal item-page-field-wrapper">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-publisher</i18n:text>
                </h5>
                <div>
                    <xsl:for-each select="dim:field[@element='publisher' and not(@qualifier)]">
                        <xsl:copy-of select="node()"/>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-citation">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='citation']">
            <div class="simple-item-view-citation item-page-field-wrapper">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-citation</i18n:text>
                </h5>
                <div>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='citation']">
                        <xsl:copy-of select="node()"/>
                    </xsl:for-each>
                </div>
                <!--version dc.eprint.version-->
                <xsl:if test="dim:field[@element='eprint' and @qualifier='version']">
                    <div>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-version</i18n:text>
                        <xsl:text> </xsl:text>
                        <xsl:copy-of select="dim:field[@element='eprint' and @qualifier='version']"/>
                    </div>
                </xsl:if>
            </div>
        </xsl:if>

    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-authors">
        <div class="simple-item-view-authors item-page-field-wrapper table">
            <h5>
                <i18n:text>xmlui.dri2xhtml.METS-1.0.item-author</i18n:text>
            </h5>
            <xsl:choose>
                <xsl:when test="dim:field[@element='contributor'][@qualifier='author' or not(@qualifier)]">
                    <xsl:variable name="author-total" select="count(dim:field[@element='contributor'][@qualifier='author' or not(@qualifier)])"/>
                    <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author' or not(@qualifier)]">
                        <xsl:call-template name="itemSummaryView-DIM-authors-entry">
                            <xsl:with-param name="index" select="position()"/>
                        </xsl:call-template>
                        <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author' or not(@qualifier)]) != 0">
                            <span>
                                <xsl:attribute name="class">
                                    <xsl:text>author-spacer-list-</xsl:text>
                                    <xsl:value-of select="position()+1"/>

                                    <xsl:if test="position()+1 &gt; $author-limit and $author-limit &gt; 0">
                                        <xsl:text> hidden </xsl:text>
                                    </xsl:if>
                                </xsl:attribute>
                                <xsl:text>;&#160;</xsl:text>
                            </span>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="$author-total &gt; $author-limit and $author-limit &gt; 0">
                        <span id="item-view-authors-truncated">
                            <xsl:text>; ...</xsl:text>
                        </span>
                        <span>
                            <xsl:text>&#160;</xsl:text>
                        </span>
                        <span>
                            <a id="item-view-show-all-authors-link" href="#" onClick="showAuthors(); return false;">Show
                                more
                            </a>
                            <a id="item-view-hide-authors-link" href="#" onClick="hideAuthors(); return false;"
                               class="hidden">Show less
                            </a>
                        </span>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-authors-entry">
        <xsl:param name="index"/>
        <span>
            <xsl:attribute name="class">
                <xsl:if test="@authority">
                    <xsl:text> ds-dc_contributor_author-authority </xsl:text>
                </xsl:if>
            </xsl:attribute>
            <span>
                <xsl:attribute name="class">
                    <xsl:text>author-list-</xsl:text>
                    <xsl:value-of select="$index"/>

                    <xsl:if test="$index &gt; $author-limit and $author-limit &gt; 0">
                        <xsl:text> hidden </xsl:text>
                    </xsl:if>
                </xsl:attribute>
                <xsl:copy-of select="node()"/>
            </span>
        </span>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-workflow-duplicate">
        <xsl:if test="dim:field[@mdschema='workflow' and @element='duplicate']">
            <div class="simple-item-view-workflow-duplicate item-page-field-wrapper table">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-workflow-duplicate</i18n:text>
                </h5>
                <div class="text-danger">
                    <xsl:for-each select="dim:field[@mdschema='workflow' and @element='duplicate']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@mdschema='workflow' and @element='duplicate']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@mdschema='workflow' and @element='duplicate']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-abstract">
        <xsl:if test="dim:field[@element='description' and @qualifier='abstract']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract</i18n:text>
                </h5>
                <div>
                    <xsl:for-each select="dim:field[@element='description' and @qualifier='abstract']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='description' and @qualifier='abstract']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-description">
        <xsl:if test="dim:field[@element='description' and not(@qualifier)]">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-description</i18n:text>
                </h5>
                <div>
                    <xsl:for-each select="dim:field[@element='description' and not(@qualifier)]">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='description' and not(@qualifier)]) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='description' and not(@qualifier)]) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-advisor">
        <xsl:if test="dim:field[@element='contributor' and @qualifier='advisor']">
            <div class="simple-item-view-advisor item-page-field-wrapper">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-advisor</i18n:text>
                </h5>
                <xsl:for-each select="dim:field[@element='contributor' and @qualifier='advisor']">
                    <div>
                        <xsl:copy-of select="node()"/>
                    </div>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-other-contributors">
        <xsl:if test="dim:field[@element='contributor' and @qualifier='other']">
            <div class="simple-item-view-other-contributors item-page-field-wrapper">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-other-contributors</i18n:text>
                </h5>
                <xsl:for-each select="dim:field[@element='contributor' and @qualifier='other']">
                    <div>
                        <xsl:copy-of select="node()"/>
                    </div>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-alternative-title">
        <xsl:if test="dim:field[@element='title' and @qualifier='alternative']">
            <div class="simple-item-view-alternative-title item-page-field-wrapper">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-alternative-title</i18n:text>
                </h5>
                <xsl:for-each select="dim:field[@element='title' and @qualifier='alternative']">
                    <div>
                        <xsl:copy-of select="node()"/>
                    </div>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-subject">
        <xsl:if test="dim:field[@element='subject' and not(@qualifier)]">
            <div class="simple-item-view-subject item-page-field-wrapper">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-subject</i18n:text>
                </h5>
                <div>
                    <xsl:for-each select="dim:field[@element='subject' and not(@qualifier)]">
                        <xsl:copy-of select="node()"/>
                        <xsl:if test="count(following-sibling::dim:field[@element='subject' and not(@qualifier)]) != 0">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-based-on">
        <xsl:if test="dim:field[@element='relation' and @qualifier='isbasedon']">
            <div class="simple-item-view-based-on item-page-field-wrapper">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-based-on</i18n:text>
                </h5>
                <xsl:for-each select="dim:field[@element='relation' and @qualifier='isbasedon']">
                    <div>
                        <a href="{./text()}">
                            <xsl:copy-of select="node()"/>
                        </a>
                    </div>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-has-part">
        <xsl:if test="dim:field[@element='relation' and @qualifier='haspart']">
            <div class="simple-item-view-has-part item-page-field-wrapper">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-has-part</i18n:text>
                </h5>
                <xsl:for-each select="dim:field[@element='relation' and @qualifier='haspart']">
                    <div>
                        <a href="{./text()}">
                            <xsl:copy-of select="node()"/>
                        </a>
                    </div>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-identifier">
        <xsl:if test="dim:field[@element='identifier' and not(@qualifier)]">
            <div class="simple-item-view-identifier item-page-field-wrapper">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-identifier</i18n:text>
                </h5>
                <xsl:for-each select="dim:field[@element='identifier' and not(@qualifier)]">
                    <div>
                        <xsl:copy-of select="node()"/>
                    </div>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-identifier-isbn">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='isbn']">
            <div class="simple-item-view-identifier item-page-field-wrapper">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-identifier-isbn</i18n:text>
                </h5>
                <xsl:for-each select="dim:field[@element='identifier' and @qualifier='isbn']">
                    <div>
                        <xsl:copy-of select="node()"/>
                    </div>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-identifier-other">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='other']">
            <div class="simple-item-view-identifier item-page-field-wrapper">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-identifier</i18n:text>
                </h5>
                <xsl:for-each select="dim:field[@element='identifier' and @qualifier='other']">
                    <div>
                        <xsl:copy-of select="node()"/>
                    </div>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-identifier-issn">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='issn']">
            <div class="simple-item-view-identifier item-page-field-wrapper">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-identifier-issn</i18n:text>
                </h5>
                <xsl:for-each select="dim:field[@element='identifier' and @qualifier='issn']">
                    <div>
                        <xsl:copy-of select="node()"/>
                    </div>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="mets:file">
        <xsl:param name="context" select="."/>
        <div class="file-wrapper row">
            <div class="col-xs-6 col-sm-3">
                <div class="thumbnail">
                    <a class="image-link">
                        <xsl:attribute name="href">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                        mets:file[@GROUPID=current()/@GROUPID]">
                                <img class="img-thumbnail" alt="Thumbnail">
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                    mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                    </xsl:attribute>
                                </img>
                            </xsl:when>
                            <xsl:otherwise>
                                <img class="img-thumbnail" alt="Thumbnail">
                                    <xsl:attribute name="data-src">
                                        <xsl:text>holder.js/100%x</xsl:text>
                                        <xsl:value-of select="$thumbnail.maxheight"/>
                                        <xsl:text>/text:No Thumbnail</xsl:text>
                                    </xsl:attribute>
                                </img>
                            </xsl:otherwise>
                        </xsl:choose>
                    </a>
                </div>
            </div>

            <div class="col-xs-6 col-sm-7">
                <dl class="file-metadata dl-horizontal">
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-name</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:attribute name="title">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                        </xsl:attribute>
                        <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:title, 30, 5)"/>
                    </dd>
                    <!-- File size always comes in bytes and thus needs conversion -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:choose>
                            <xsl:when test="@SIZE &lt; 1024">
                                <xsl:value-of select="@SIZE"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div 1024),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </dd>
                    <!-- Lookup File Type description in local messages.xml based on MIME Type.
             In the original DSpace, this would get resolved to an application via
             the Bitstream Registry, but we are constrained by the capabilities of METS
             and can't really pass that info through. -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before(@MIMETYPE,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="contains(@MIMETYPE,';')">
                                        <xsl:value-of select="substring-before(substring-after(@MIMETYPE,'/'),';')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring-after(@MIMETYPE,'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>

                            </xsl:with-param>
                        </xsl:call-template>
                    </dd>
                    <!-- Display the contents of 'Description' only if bitstream contains a description -->
                    <xsl:if test="mets:FLocat[@LOCTYPE='URL']/@xlink:label != ''">
                        <dt>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-description</i18n:text>
                            <xsl:text>:</xsl:text>
                        </dt>
                        <dd class="word-break">
                            <xsl:attribute name="title">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                            </xsl:attribute>
                            <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:label, 30, 5)"/>
                        </dd>
                    </xsl:if>
                    <xsl:if test="@EMBARGODATE">
                        <dt>
                            <i18n:text>xmlui.dri2xhtml.METS-embargo-until</i18n:text>
                        </dt>
                        <dd class="word-break">
                            <xsl:value-of select="@EMBARGODATE"/>
                        </dd>
                    </xsl:if>

                </dl>
            </div>

            <div class="file-link col-xs-6 col-xs-offset-6 col-sm-2 col-sm-offset-0">
                <xsl:choose>
                    <xsl:when test="@ADMID">
                        <xsl:call-template name="display-rights"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="view-open"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>

    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-thumbnail">
        <xsl:variable name="primaryID" select="//mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
        <xsl:variable name="primaryFile" select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file[@ID = $primaryID]"/>

        <div class="thumbnail">

            <xsl:choose>
                <xsl:when test="string-length($primaryID) &gt; 0 and $primaryFile[@MIMETYPE = 'text/html']">
                    <xsl:variable name="thumbnailHref">
                        <xsl:value-of
                            select="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID = $primaryFile/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="string-length($thumbnailHref) &gt; 0">
                            <img class="img-thumbnail" alt="Thumbnail">
                                <xsl:attribute name="src">
                                    <xsl:value-of select="$thumbnailHref"/>
                                </xsl:attribute>
                            </img>
                        </xsl:when>
                        <xsl:otherwise>
                            <img class="img-thumbnail" alt="Thumbnail">
                                <xsl:attribute name="data-src">
                                    <xsl:text>holder.js/100%x</xsl:text>
                                    <xsl:value-of select="$thumbnail.maxheight"/>
                                    <xsl:text>/text:No Thumbnail</xsl:text>
                                </xsl:attribute>
                            </img>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                    <xsl:if test="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file[1]">
                        <xsl:variable name="file" select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file[1]"/>
                        <xsl:variable name="thumbnailHref">
                            <xsl:value-of
                                select="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID = $file/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="string-length($thumbnailHref) &gt; 0">
                                <img class="img-thumbnail" alt="Thumbnail">
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="$thumbnailHref"/>
                                    </xsl:attribute>
                                </img>
                            </xsl:when>
                            <xsl:otherwise>
                                <img class="img-thumbnail" alt="Thumbnail">
                                    <xsl:attribute name="data-src">
                                        <xsl:text>holder.js/100%x</xsl:text>
                                        <xsl:value-of select="$thumbnail.maxheight"/>
                                        <xsl:text>/text:No Thumbnail</xsl:text>
                                    </xsl:attribute>
                                </img>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xsl:when>
            </xsl:choose>
        </div>

    </xsl:template>

</xsl:stylesheet>
