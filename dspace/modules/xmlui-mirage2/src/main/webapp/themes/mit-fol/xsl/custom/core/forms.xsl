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

    <xsl:template match="dri:field[@type='composite'][dri:field/dri:instance | dri:params/@operations]" priority="3">
        <!-- First is special, so first we grab all the values from the child fields.
            We do this by applying normal templates to the field, which should ignore instances. -->
        <span class="ds-composite-field">
            <xsl:apply-templates select="dri:field" mode="compositeComponent"/>
        </span>
        <xsl:apply-templates select="dri:field/dri:error" mode="compositeComponent"/>
        <xsl:apply-templates select="dri:error" mode="compositeComponent"/>
        <xsl:apply-templates select="dri:help" mode="compositeComponent"/>
        <!-- Insert choice mechanism here.
             Follow it up with an ADD button if the add operation is specified. This allows
            entering more than one value for this field. -->

        <xsl:if test="contains(dri:params/@operations,'add')">
            <!-- Add buttons should be named "submit_[field]_add" so that we can ignore errors from required fields when simply adding new values-->
            <input type="submit" value="Add" name="{concat('submit_',@n,'_add')}" class="ds-button-field ds-add-button">
                <!-- Make invisible if we have choice-lookup popup that provides its own Add. -->
                <xsl:if test="dri:params/@choicesPresentation = 'lookup'">
                    <xsl:attribute name="style">
                        <xsl:text>display:none;</xsl:text>
                    </xsl:attribute>
                </xsl:if>
            </input>
        </xsl:if>

        <xsl:variable name="confidenceIndicatorID" select="concat(translate(@id,'.','_'),'_confidence_indicator')"/>
        <xsl:if test="dri:params/@authorityControlled">
            <!-- XXX note that this is wrong and won't get any authority values, but
               - for instanced inputs the entry box starts out empty anyway.
              -->
            <xsl:call-template name="authorityConfidenceIcon">
                <xsl:with-param name="confidence" select="dri:value[@type='authority']/@confidence"/>
                <xsl:with-param name="id" select="$confidenceIndicatorID"/>
            </xsl:call-template>
            <xsl:call-template name="authorityInputFields">
                <xsl:with-param name="name" select="@n"/>
                <xsl:with-param name="id" select="@id"/>
                <xsl:with-param name="authValue" select="dri:value[@type='authority']/text()"/>
                <xsl:with-param name="confValue" select="dri:value[@type='authority']/@confidence"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="dri:params/@choicesPresentation = 'suggest'">
                <xsl:call-template name="addAuthorityAutocomplete">
                    <xsl:with-param name="confidenceIndicatorID" select="$confidenceIndicatorID"/>
                </xsl:call-template>
            </xsl:when>
            <!-- lookup popup includes its own Add button if necessary. -->
            <!-- XXX does this need a Confidence Icon? -->
            <xsl:when test="dri:params/@choicesPresentation = 'lookup'">
                <xsl:call-template name="addLookupButton">
                    <xsl:with-param name="isName" select="'true'"/>
                    <xsl:with-param name="confIndicator" select="$confidenceIndicatorID"/>
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="dri:params/@choicesPresentation = 'authorLookup'">
                <xsl:call-template name="addLookupButtonAuthor">
                    <xsl:with-param name="isName" select="'true'"/>
                    <xsl:with-param name="confIndicator" select="$confidenceIndicatorID"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
        <br/>
        <xsl:if test="dri:instance or dri:field/dri:instance">
            <div class="ds-previous-values">
                <xsl:variable name="reorderable">
                    <xsl:if test="@rend='submit-name'">
                        <xsl:text>true</xsl:text>
                    </xsl:if>
                </xsl:variable>
                <xsl:if test="(@rend='submit-name')">
                    <xsl:attribute name="reordername">true</xsl:attribute>
                </xsl:if>
                <xsl:call-template name="fieldIterator">
                    <xsl:with-param name="position">1</xsl:with-param>
                    <xsl:with-param name="reorderable">
                        <xsl:value-of select="$reorderable"/>
                    </xsl:with-param>
                </xsl:call-template>
                <!-- Conclude with a DELETE button if the delete operation is specified. This allows
                    removing one or more values stored for this field. -->
                <xsl:if test="contains(dri:params/@operations,'delete') and (dri:instance or dri:field/dri:instance)">
                    <!-- Delete buttons should be named "submit_[field]_delete" so that we can ignore errors from required fields when simply removing values-->
                    <input type="submit" value="Remove selected" name="{concat('submit_',@n,'_delete')}" class="ds-button-field ds-delete-button" />
                </xsl:if>
                <xsl:for-each select="dri:field">
                    <xsl:apply-templates select="dri:instance" mode="hiddenInterpreter"/>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="dri:field[@type='composite'][dri:field/dri:instance | dri:params/@operations]" mode="formComposite" priority="2">
        <xsl:variable name="confidenceIndicatorID" select="concat(translate(@id,'.','_'),'_confidence_indicator')"/>
        <div class="ds-form-content">
            <div>
                <xsl:attribute name="class">
                    <xsl:text>control-group row</xsl:text>
                    <xsl:if test="dri:error">
                        <xsl:text> has-error</xsl:text>
                    </xsl:if>
                </xsl:attribute>
                <xsl:apply-templates select="dri:label" mode="compositeLabel"/>
                <xsl:apply-templates select="dri:field" mode="compositeComponent"/>


                <xsl:if test="dri:params/@choicesPresentation = 'lookup' or contains(dri:params/@operations,'add') or dri:params/@choicesPresentation = 'suggest' or dri:params/@choicesPresentation = 'authorLookup'">
                    <div class="col-xs-2">
                        <xsl:attribute name="class">
                            <xsl:choose>
                                <xsl:when test="dri:params/@choicesPresentation = 'lookup'"><xsl:text>col-xs-3 col-sm-2</xsl:text></xsl:when>
                                <xsl:otherwise><xsl:text>col-xs-2</xsl:text></xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>

                        <xsl:if test="dri:field/dri:label">
                            <label>
                                <xsl:attribute name="class">
                                    <xsl:text>control-label</xsl:text>
                                    <xsl:if test="dri:field/@required = 'yes'">
                                        <xsl:text> required</xsl:text>
                                    </xsl:if>
                                </xsl:attribute>
                                <xsl:text>&#160;</xsl:text>
                            </label>
                        </xsl:if>
                        <div class="clearfix">
                            <xsl:if test="contains(dri:params/@operations,'add')">
                                <button type="submit" name="{concat('submit_',@n,'_add')}"
                                        class="ds-button-field btn btn-default pull-right ds-add-button">
                                    <xsl:if test="dri:params/@choicesPresentation = 'lookup'">
                                        <xsl:attribute name="style">
                                            <xsl:text>display:none;</xsl:text>
                                        </xsl:attribute>
                                    </xsl:if>
                                    <!-- Make invisible if we have choice-lookup operation that provides its own Add. -->
                                    <i18n:text>xmlui.mirage2.forms.instancedCompositeFields.add</i18n:text>
                                </button>
                            </xsl:if>

                            <xsl:choose>
                                <!-- insert choice mechansim and/or Add button here -->
                                <xsl:when test="dri:params/@choicesPresentation = 'suggest'">
                                    <xsl:message terminate="yes">
                                        <i18n:text>xmlui.mirage2.forms.instancedCompositeFields.noSuggestionError</i18n:text>
                                    </xsl:message>
                                </xsl:when>
                                <!-- lookup popup includes its own Add button if necessary. -->
                                <xsl:when test="dri:params/@choicesPresentation = 'lookup'">
                                    <xsl:call-template name="addLookupButton">
                                        <xsl:with-param name="isName" select="'true'"/>
                                        <xsl:with-param name="confIndicator" select="$confidenceIndicatorID"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="dri:params/@choicesPresentation = 'authorLookup'">
                                    <xsl:call-template name="addLookupButtonAuthor">
                                        <xsl:with-param name="isName" select="'true'"/>
                                        <xsl:with-param name="confIndicator" select="$confidenceIndicatorID"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                        </div>
                    </div>
                </xsl:if>
                <!-- place to store authority value -->
                <xsl:if test="dri:params/@authorityControlled">
                    <xsl:call-template name="authorityConfidenceIcon">
                        <xsl:with-param name="confidence" select="dri:value[@type='authority']/@confidence"/>
                        <xsl:with-param name="id" select="$confidenceIndicatorID"/>
                    </xsl:call-template>
                    <xsl:call-template name="authorityInputFields">
                        <xsl:with-param name="name" select="@n"/>
                        <xsl:with-param name="authValue" select="dri:value[@type='authority']/text()"/>
                        <xsl:with-param name="confValue" select="dri:value[@type='authority']/@confidence"/>
                    </xsl:call-template>
                </xsl:if>
            </div>

            <xsl:apply-templates select="dri:help" mode="help"/>
            <xsl:apply-templates select="dri:error" mode="compositeComponent"/>
            <xsl:apply-templates select="dri:field/dri:error" mode="compositeComponent"/>
            <xsl:if test="dri:instance or dri:field/dri:instance">
                <div class="ds-previous-values">
                    <xsl:variable name="reorderable">
                        <xsl:if test="@rend='submit-name'">
                            <xsl:text>true</xsl:text>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:if test="(@rend='submit-name')">
                        <xsl:attribute name="reordername">true</xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="fieldIterator">
                        <xsl:with-param name="position">1</xsl:with-param>
                        <xsl:with-param name="reorderable">
                            <xsl:value-of select="$reorderable"/>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:if test="contains(dri:params/@operations,'delete') and (dri:instance or dri:field/dri:instance)">
                        <!-- Delete buttons should be named "submit_[field]_delete" so that we can ignore errors from required fields when simply removing values-->
                        <button type="submit" name="{concat('submit_',@n,'_delete')}" class="ds-button-field ds-delete-button btn btn-default">
                            <i18n:text>xmlui.mirage2.forms.instancedCompositeFields.remove</i18n:text>
                        </button>
                    </xsl:if>
                    <xsl:for-each select="dri:field">
                        <xsl:apply-templates select="dri:instance" mode="hiddenInterpreter"/>
                    </xsl:for-each>
                </div>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template name="fieldIterator">
        <xsl:param name="reorderable" select="'false'"/>

        <xsl:param name="position"/>
        <!-- add authority value for this instance -->
        <xsl:if test="dri:instance[position()=$position]/dri:value[@type='authority']">
            <xsl:call-template name="authorityInputFields">
                <xsl:with-param name="name" select="@n"/>
                <xsl:with-param name="position" select="$position"/>
                <xsl:with-param name="authValue" select="dri:instance[position()=$position]/dri:value[@type='authority']/text()"/>
                <xsl:with-param name="confValue" select="dri:instance[position()=$position]/dri:value[@type='authority']/@confidence"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:choose>
            <!-- First check to see if the composite itself has a non-empty instance value in that
                position. In that case there is no need to go into the individual fields. -->
            <xsl:when test="count(dri:instance[position()=$position]/dri:value[@type != 'authority'])">
                <div class="checkbox">
                    <label>
                        <input type="checkbox" value="{concat(@n,'_',$position)}" name="{concat(@n,'_selected')}"/>
                        <xsl:apply-templates select="dri:instance[position()=$position]" mode="interpreted"/>
                        <xsl:call-template name="authorityConfidenceIcon">
                            <xsl:with-param name="confidence"
                                            select="dri:instance[position()=$position]/dri:value[@type='authority']/@confidence"/>
                        </xsl:call-template>
                    </label>
                    <xsl:if test="$reorderable='true'">
                        <span class="reorderingarrow glyphicon btn-xs glyphicon-arrow-up btn btn-default" position="{$position}" field="{@n}"></span>
                        <span class="reorderingarrow glyphicon btn-xs glyphicon-arrow-down btn btn-default" position="{$position}" field="{@n}"></span>
                    </xsl:if>
                </div>

                <xsl:call-template name="fieldIterator">
                    <xsl:with-param name="position">
                        <xsl:value-of select="$position + 1"/>
                    </xsl:with-param>
                    <xsl:with-param name="reorderable" select="$reorderable"/>
                </xsl:call-template>
            </xsl:when>
            <!-- Otherwise, build the string from the component fields -->
            <xsl:when test="dri:field/dri:instance[position()=$position]">
                <div class="checkbox">
                    <label>
                        <input type="checkbox" value="{concat(@n,'_',$position)}" name="{concat(@n,'_selected')}"/>
                        <xsl:apply-templates select="dri:field" mode="compositeField">
                            <xsl:with-param name="position" select="$position"/>
                        </xsl:apply-templates>
                    </label>
                </div>

                <xsl:call-template name="fieldIterator">
                    <xsl:with-param name="position"><xsl:value-of select="$position + 1"/></xsl:with-param>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dri:field[dri:field/dri:instance | dri:params/@operations]" priority="2">
        <xsl:choose>
            <xsl:when test="contains(dri:params/@operations,'add')">
                <div class="row">
                    <div class="col-xs-10">
                        <xsl:apply-templates select="." mode="normalField"/>
                    </div>

                    <div class="col-xs-2">
                        <button type="submit" name="{concat('submit_',@n,'_add')}"
                                class="pull-right ds-button-field btn btn-default ds-add-button">
                            <!-- Make invisible if we have choice-lookup popup that provides its own Add. -->
                            <xsl:if test="dri:params/@choicesPresentation = 'lookup'">
                                <xsl:attribute name="style">
                                    <xsl:text>display:none;</xsl:text>
                                </xsl:attribute>
                            </xsl:if>
                            <i18n:text>xmlui.mirage2.forms.nonCompositeFieldSet.add</i18n:text>
                        </button>
                    </div>
                </div>


            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="normalField"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="dri:help" mode="help"/>
        <xsl:apply-templates select="dri:error" mode="error"/>
        <xsl:if test="dri:instance">
            <div class="ds-previous-values">
                <xsl:variable name="reorderable">
                    <xsl:if test="@rend='submit-name'">
                        <xsl:text>true</xsl:text>
                    </xsl:if>
                </xsl:variable>
                <xsl:if test="(@rend='submit-name')">
                    <xsl:attribute name="reordername">true</xsl:attribute>
                </xsl:if>
                <!-- Iterate over the dri:instance elements contained in this field. The instances contain
                    stored values as either "interpreted", "raw", or "default" values. -->
                <xsl:call-template name="simpleFieldIterator">
                    <xsl:with-param name="reorderable" select="$reorderable"/>
                    <xsl:with-param name="position">1</xsl:with-param>
                </xsl:call-template>
                <!-- Conclude with a DELETE button if the delete operation is specified. This allows
                    removing one or more values stored for this field. -->
                <xsl:if test="contains(dri:params/@operations,'delete') and dri:instance">
                    <!-- Delete buttons should be named "submit_[field]_delete" so that we can ignore errors from required fields when simply removing values-->
                    <p>
                        <button type="submit" name="{concat('submit_',@n,'_delete')}" class="ds-button-field btn btn-default ds-delete-button">
                            <i18n:text>xmlui.mirage2.forms.nonCompositeFieldSet.remove</i18n:text>
                        </button>
                    </p>
                </xsl:if>
                <!-- Behind the scenes, add hidden fields for every instance set. This is to make sure that
                    the form still submits the information in those instances, even though they are no
                    longer encoded as HTML fields. The DRI Reference should contain the exact attributes
                    the hidden fields should have in order for this to work properly. -->
                <xsl:apply-templates select="dri:instance" mode="hiddenInterpreter"/>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="simpleFieldIterator">
        <xsl:param name="reorderable" select="'false'"/>
        <xsl:param name="position"/>
        <xsl:if test="dri:instance[position()=$position]">
            <div class="checkbox">
                <label>
                    <input type="checkbox" value="{concat(@n,'_',$position)}" name="{concat(@n,'_selected')}"/>
                    <xsl:apply-templates select="dri:instance[position()=$position]" mode="interpreted"/>

                    <!-- look for authority value in instance. -->
                    <xsl:if test="dri:instance[position()=$position]/dri:value[@type='authority']">
                        <xsl:call-template name="authorityConfidenceIcon">
                            <xsl:with-param name="confidence"
                                            select="dri:instance[position()=$position]/dri:value[@type='authority']/@confidence"/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:if test="$reorderable='true'">
                        <span class="reorderingarrow glyphicon btn-xs glyphicon-arrow-up btn btn-default" position="{$position}" field="{@n}"></span>
                        <span class="reorderingarrow glyphicon btn-xs glyphicon-arrow-down btn btn-default" position="{$position}" field="{@n}"></span>
                    </xsl:if>
                </label>
            </div>

            <xsl:call-template name="simpleFieldIterator">
                <xsl:with-param name="position">
                    <xsl:value-of select="$position + 1"/>
                </xsl:with-param>
                <xsl:with-param name="reorderable" select="$reorderable"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template
            match="dri:list[@id='aspect.submission.StepTransformer.list.submit-describe']/dri:item[@n='file-section']"
            priority="4">
        <xsl:variable name="id"
                      select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='item' and @qualifier='identifier']"/>
        <xsl:variable name="externalMetadataURL">
            <xsl:text>cocoon:/</xsl:text>
            <xsl:text>/metadata/internal/item/</xsl:text>
            <xsl:value-of select="$id"/>
            <xsl:text>/mets.xml</xsl:text>
            <xsl:text>?sections=fileSec&amp;fileGrpTypes=ORIGINAL</xsl:text>
        </xsl:variable>
        <xsl:apply-templates select="document($externalMetadataURL)" mode="describe-file-section"/>
    </xsl:template>

    <xsl:template match="mets:METS" mode="describe-file-section" priority="4">
        <xsl:call-template name="describe-step-file-section"/>
    </xsl:template>

    <!--Copy of item-view.xsl templates to make sure these open in a new tab-->
    <xsl:template name="describe-step-file-section">
        <xsl:choose>
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                <div class="item-page-field-wrapper table word-break">
                    <h5>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                    </h5>

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

                    <xsl:for-each
                            select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                        <xsl:call-template name="describe-step-file-section-entry">
                            <xsl:with-param name="href" select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            <xsl:with-param name="mimetype" select="@MIMETYPE"/>
                            <xsl:with-param name="label-1" select="$label-1"/>
                            <xsl:with-param name="label-2" select="$label-2"/>
                            <xsl:with-param name="title" select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                            <xsl:with-param name="label" select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                            <xsl:with-param name="size" select="@SIZE"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="//mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemSummaryView-DIM"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="describe-step-file-section-entry">
        <xsl:param name="href"/>
        <xsl:param name="mimetype"/>
        <xsl:param name="label-1"/>
        <xsl:param name="label-2"/>
        <xsl:param name="title"/>
        <xsl:param name="label"/>
        <xsl:param name="size"/>
        <div>
            <a target="_blank" rel="noopener noreferrer">
                <xsl:attribute name="href">
                    <xsl:value-of select="$href"/>
                </xsl:attribute>
                <xsl:call-template name="getFileIcon">
                    <xsl:with-param name="mimetype">
                        <xsl:value-of select="substring-before($mimetype,'/')"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="substring-after($mimetype,'/')"/>
                    </xsl:with-param>
                </xsl:call-template>
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
            </a>
        </div>
    </xsl:template>

    <!-- Fieldset (instanced) field stuff, in the case of non-composites -->
    <xsl:template match="dri:field[dri:field/dri:instance | dri:params/@operations]" priority="2">
        <xsl:choose>
            <xsl:when test="contains(dri:params/@operations,'add')">
                <div class="row">
                    <div class="col-xs-10">
                        <xsl:apply-templates select="." mode="normalField"/>
                    </div>

                    <div class="col-xs-2">
                        <button type="submit" name="{concat('submit_',@n,'_add')}"
                                class="pull-right ds-button-field btn btn-default ds-add-button">
                            <!-- Make invisible if we have choice-lookup popup that provides its own Add. -->
                            <xsl:if test="dri:params/@choicesPresentation = 'lookup'">
                                <xsl:attribute name="style">
                                    <xsl:text>display:none;</xsl:text>
                                </xsl:attribute>
                            </xsl:if>
                            <i18n:text>xmlui.mirage2.forms.nonCompositeFieldSet.add</i18n:text>
                        </button>
                        <xsl:choose>
                            <xsl:when test="dri:params/@choicesPresentation = 'departmentLookup'">
                                <xsl:call-template name="addLookupButtonDepartment">
                                    <xsl:with-param name="editItemNewMetadata">false</xsl:with-param>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </div>
                </div>


            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="normalField"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="dri:help" mode="help"/>
        <xsl:apply-templates select="dri:error" mode="error"/>
        <xsl:if test="dri:instance">
            <div class="ds-previous-values">
                <!-- Iterate over the dri:instance elements contained in this field. The instances contain
                    stored values as either "interpreted", "raw", or "default" values. -->
                <xsl:call-template name="simpleFieldIterator">
                    <xsl:with-param name="position">1</xsl:with-param>
                </xsl:call-template>
                <!-- Conclude with a DELETE button if the delete operation is specified. This allows
                    removing one or more values stored for this field. -->
                <xsl:if test="contains(dri:params/@operations,'delete') and dri:instance">
                    <!-- Delete buttons should be named "submit_[field]_delete" so that we can ignore errors from required fields when simply removing values-->
                    <p>
                        <button type="submit" name="{concat('submit_',@n,'_delete')}" class="ds-button-field btn btn-default ds-delete-button">
                            <i18n:text>xmlui.mirage2.forms.nonCompositeFieldSet.remove</i18n:text>
                        </button>
                    </p>
                </xsl:if>
                <!-- Behind the scenes, add hidden fields for every instance set. This is to make sure that
                    the form still submits the information in those instances, even though they are no
                    longer encoded as HTML fields. The DRI Reference should contain the exact attributes
                    the hidden fields should have in order for this to work properly. -->
                <xsl:apply-templates select="dri:instance" mode="hiddenInterpreter"/>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="dri:field" mode="normalField">
        <xsl:variable name="confidenceIndicatorID" select="concat(translate(@id,'.','_'),'_confidence_indicator')"/>
        <xsl:choose>
            <!-- TODO: this has changed dramatically (see form3.xml) -->
            <xsl:when test="@type= 'select'">
                <select>
                    <xsl:call-template name="fieldAttributes"/>
                    <xsl:apply-templates/>
                </select>
            </xsl:when>
            <xsl:when test="@type= 'textarea'">
                <textarea>
                    <xsl:call-template name="fieldAttributes"/>
                    <xsl:attribute name="onkeydown">event.cancelBubble=true;</xsl:attribute>

                    <!--
                        if the cols and rows attributes are not defined we need to call
                        the templates for them since they are required attributes in strict xhtml
                     -->
                    <xsl:choose>
                        <xsl:when test="not(./dri:params[@cols])">
                            <xsl:call-template name="textAreaCols"/>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="not(./dri:params[@rows])">
                            <xsl:call-template name="textAreaRows"/>
                        </xsl:when>
                    </xsl:choose>

                    <xsl:apply-templates />
                    <xsl:choose>
                        <xsl:when test="./dri:value[@type='raw']">
                            <xsl:copy-of select="./dri:value[@type='raw']/node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="./dri:value[@type='default']/node()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if  test="string-length(./dri:value) &lt; 1">
                        <i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>
                    </xsl:if>
                </textarea>


                <!-- add place to store authority value -->
                <xsl:if test="dri:params/@authorityControlled">
                    <xsl:variable name="confidence">
                        <xsl:if test="./dri:value[@type='authority']">
                            <xsl:value-of select="./dri:value[@type='authority']/@confidence"/>
                        </xsl:if>
                    </xsl:variable>
                    <!-- add authority confidence widget -->
                    <xsl:call-template name="authorityConfidenceIcon">
                        <xsl:with-param name="confidence" select="$confidence"/>
                        <xsl:with-param name="id" select="$confidenceIndicatorID"/>
                    </xsl:call-template>
                    <xsl:call-template name="authorityInputFields">
                        <xsl:with-param name="name" select="@n"/>
                        <xsl:with-param name="id" select="@id"/>
                        <xsl:with-param name="authValue" select="dri:value[@type='authority']/text()"/>
                        <xsl:with-param name="confValue" select="dri:value[@type='authority']/@confidence"/>
                        <xsl:with-param name="confIndicatorID" select="$confidenceIndicatorID"/>
                        <xsl:with-param name="unlockButton" select="dri:value[@type='authority']/dri:field[@rend='ds-authority-lock']/@n"/>
                        <xsl:with-param name="unlockHelp" select="dri:value[@type='authority']/dri:field[@rend='ds-authority-lock']/dri:help"/>
                    </xsl:call-template>
                </xsl:if>
                <!-- add choice mechanisms -->
                <xsl:choose>
                    <xsl:when test="dri:params/@choicesPresentation = 'suggest'">
                        <xsl:call-template name="addAuthorityAutocomplete">
                            <xsl:with-param name="confidenceIndicatorID" select="$confidenceIndicatorID"/>
                            <xsl:with-param name="confidenceName">
                                <xsl:value-of select="concat(@n,'_confidence')"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="dri:params/@choicesPresentation = 'lookup'">
                        <xsl:call-template name="addLookupButton">
                            <xsl:with-param name="isName" select="'false'"/>
                            <xsl:with-param name="confIndicator" select="$confidenceIndicatorID"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="dri:params/@choicesPresentation = 'authorLookup'">
                        <xsl:call-template name="addLookupButtonAuthor">
                            <xsl:with-param name="isName" select="'false'"/>
                            <xsl:with-param name="confIndicator" select="$confidenceIndicatorID"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="dri:params/@choicesPresentation = 'departmentLookup'">
                        <xsl:call-template name="addLookupButtonDepartment">
                            <xsl:with-param name="editItemNewMetadata">false</xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>

            <!-- This is changing dramatically -->
            <xsl:when test="@type= 'checkbox' or @type= 'radio'">
                <fieldset>
                    <xsl:call-template name="standardAttributes">
                        <xsl:with-param name="class">
                            <xsl:text>ds-</xsl:text><xsl:value-of select="@type"/><xsl:text>-field </xsl:text>
                            <xsl:if test="dri:error">
                                <xsl:text>error </xsl:text>
                            </xsl:if>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:attribute name="id"><xsl:value-of select="generate-id()"/></xsl:attribute>
                    <xsl:if test="dri:label">
                        <legend><xsl:apply-templates select="dri:label" mode="compositeComponent" /></legend>
                    </xsl:if>
                    <xsl:apply-templates />
                </fieldset>
            </xsl:when>
            <!--
                <input>
                            <xsl:call-template name="fieldAttributes"/>
                    <xsl:if test="dri:value[@checked='yes']">
                                <xsl:attribute name="checked">checked</xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>
                </input>
                -->
            <xsl:when test="@type= 'composite'">
                <!-- TODO: add error and help stuff on top of the composite -->
                <span class="ds-composite-field">
                    <xsl:apply-templates select="dri:field" mode="compositeComponent"/>
                </span>
                <xsl:apply-templates select="dri:field/dri:error" mode="compositeComponent"/>
                <xsl:apply-templates select="dri:error" mode="compositeComponent"/>
                <xsl:apply-templates select="dri:field/dri:help" mode="compositeComponent"/>
                <!--<xsl:apply-templates select="dri:help" mode="compositeComponent"/>-->
            </xsl:when>
            <!-- text, password, file, and hidden types are handled the same.
                Buttons: added the xsl:if check which will override the type attribute button
                    with the value 'submit'. No reset buttons for now...
            -->
            <xsl:otherwise>
                <input>
                    <xsl:call-template name="fieldAttributes"/>
                    <xsl:if test="@type='button'">
                        <xsl:attribute name="type">submit</xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="value">
                        <xsl:choose>
                            <xsl:when test="./dri:value[@type='raw']">
                                <xsl:value-of select="./dri:value[@type='raw']"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="./dri:value[@type='default']"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:if test="dri:params/@choicesClosed='yes'">
                        <xsl:attribute name="readonly"><xsl:text>readonly</xsl:text></xsl:attribute>
                    </xsl:if>
                    <xsl:if test="dri:value/i18n:text">
                        <xsl:attribute name="i18n:attr">value</xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates />
                </input>

                <xsl:variable name="confIndicatorID" select="concat(@id,'_confidence_indicator')"/>
                <xsl:if test="dri:params/@authorityControlled">
                    <xsl:variable name="confidence">
                        <xsl:if test="./dri:value[@type='authority']">
                            <xsl:value-of select="./dri:value[@type='authority']/@confidence"/>
                        </xsl:if>
                    </xsl:variable>
                    <!-- add authority confidence widget -->
                    <xsl:call-template name="authorityConfidenceIcon">
                        <xsl:with-param name="confidence" select="$confidence"/>
                        <xsl:with-param name="id" select="$confidenceIndicatorID"/>
                    </xsl:call-template>
                    <xsl:call-template name="authorityInputFields">
                        <xsl:with-param name="name" select="@n"/>
                        <xsl:with-param name="id" select="@id"/>
                        <xsl:with-param name="authValue" select="dri:value[@type='authority']/text()"/>
                        <xsl:with-param name="confValue" select="dri:value[@type='authority']/@confidence"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="dri:params/@choicesPresentation = 'suggest'">
                        <xsl:call-template name="addAuthorityAutocomplete">
                            <xsl:with-param name="confidenceIndicatorID" select="$confidenceIndicatorID"/>
                            <xsl:with-param name="confidenceName">
                                <xsl:value-of select="concat(@n,'_confidence')"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="dri:params/@choicesPresentation = 'lookup'">
                        <xsl:call-template name="addLookupButton">
                            <xsl:with-param name="isName" select="'false'"/>
                            <xsl:with-param name="confIndicator" select="$confidenceIndicatorID"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="dri:params/@choicesPresentation = 'authorLookup'">
                        <xsl:call-template name="addLookupButtonAuthor">
                            <xsl:with-param name="isName" select="'false'"/>
                            <xsl:with-param name="confIndicator" select="$confidenceIndicatorID"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dri:field[starts-with(@id, 'aspect.administrative.item.EditItemMetadataForm.field.') and @rend='departmentLookup']">
        <xsl:call-template name="addLookupButtonDepartment">
            <xsl:with-param name="editItemNewMetadata">true</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>