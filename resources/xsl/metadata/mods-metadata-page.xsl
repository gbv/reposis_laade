<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:ex="http://exslt.org/dates-and-times" exclude-result-prefixes="mods mcrxsl i18n ex"
>
  <xsl:include href="layout-utils.xsl" />

  <xsl:param name="MIR.OAS" select="'hide'" />

  <xsl:template match="/site">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <head>
        <xsl:apply-templates select="citation_meta" mode="copyContent" />
        <link href="{$WebApplicationBaseURL}mir-layout/assets/jquery/plugins/shariff/shariff.min.css" rel="stylesheet" />
      </head>

      <xsl:if test="div[@id='search_browsing']">
        <div class="row detail_row" id="mir-search_browsing">
          <div class="col">
            <div class="detail_block text-center">
              <xsl:apply-templates select="div[@id='search_browsing']" mode="copyContent" />
            </div>
          </div>
        </div>
      </xsl:if>

      <xsl:if test="div[@id='mir-message']">
        <div class="row detail_row">
          <div class="col-md-12">
            <xsl:copy-of select="div[@id='mir-message']/*" />
          </div>
        </div>
      </xsl:if>

      <div class="row lde-tools">
        <div class="col-md-6 col-lg-8">
          <xsl:apply-templates select="div[@id='mir-abstract-badges']" mode="copyContent" />
        </div>
        <div class="col-md-6 col-lg-4 mt-3 mt-md-0">
            <xsl:apply-templates select="div[@id='mir-edit']" mode="copyContent" />
        </div>
      </div>

      <div class="row lde-headline">
        <div class="col">
          <xsl:apply-templates select="div[@id='mir-abstract-title']" mode="copyContent" />
        </div>
      </div>

      <xsl:if test="div[@id='laade-track-list']">
        <xsl:apply-templates select="div[@id='laade-track-list']" mode="copyContent" />
      </xsl:if>

      <xsl:if test="div[@id='laade-player']">
        <xsl:apply-templates select="div[@id='laade-player']" mode="copyContent" />
      </xsl:if>

      <xsl:if test="div[@id='laade-gallery']">
        <xsl:apply-templates select="div[@id='laade-gallery']" mode="copyContent" />
      </xsl:if>

      <div class="row">
        <div class="col-lg-8 mir_metadata">

          <xsl:if test="div[contains(@id,'mir-metadata')]/table[@class='mir-metadata']/tr">
            <h3>
              <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.categorybox')" />
            </h3>
            <xsl:apply-templates select="div[@id='mir-metadata']" mode="newMetadata" />
            <xsl:if test="div[contains(@id,'mir-metadata')]/table[@class='mir-metadata']/tr/td/div[contains(@class,'openstreetmap-container')]">
              <link rel="stylesheet" type="text/css" href="{$WebApplicationBaseURL}assets/openlayers/ol.css" />
              <script type="text/javascript" src="{$WebApplicationBaseURL}assets/openlayers/ol.js" />
              <script type="text/javascript" src="{$WebApplicationBaseURL}js/mir/geo-coords.min.js"></script>
            </xsl:if>
          </xsl:if>

        </div>
        <div class="col-lg-4">

          <xsl:comment>cites</xsl:comment>
          <xsl:if test="div[@id='mir-citation']">
            <div class="card">
              <div class="card-header">
                <h3 class="card-title">
                  <xsl:value-of select="i18n:translate('metaData.quote')" /></h3>
              </div>
              <div class="card-body">
                <xsl:apply-templates select="div[@id='mir-citation']" mode="copyContent" />
              </div>
            </div>
          </xsl:if>
          <xsl:comment>OAS statistics</xsl:comment>
          <xsl:if test="$MIR.OAS = 'show' and div[@id='mir-oastatistics']">
            <div class="card">
              <div class="card-header">
                <h3 class="card-title">
                  <xsl:value-of select="i18n:translate('mir.oas.panelheading')" />
                </h3>
              </div>
              <div class="card-body" id="mir_oas">
                <xsl:apply-templates select="div[@id='mir-oastatistics']" mode="copyContent" />
              </div>
            </div>
          </xsl:if>
          <xsl:comment>rights</xsl:comment>
          <xsl:if test="div[@id='mir-access-rights']">
            <div id="mir_access_rights_panel" class="card">
              <div class="card-header">
                <h3 class="card-title"><xsl:value-of select="i18n:translate('metaData.rights')" /></h3>
              </div>
              <div class="card-body">

                <xsl:apply-templates select="div[@id='mir-access-rights']" mode="copyContent" />

              </div>
            </div>
          </xsl:if>
          <xsl:comment>export</xsl:comment>
          <xsl:if test="div[@id='mir-export']">
            <div id="mir_export_panel" class="card">
              <div class="card-header">
                <h3 class="card-title"><xsl:value-of select="i18n:translate('metaData.export')" /></h3>
              </div>
              <div class="card-body">

                <xsl:apply-templates select="div[@id='mir-export']" mode="copyContent" />

              </div>
            </div>
          </xsl:if>
          <xsl:comment>system</xsl:comment>
          <xsl:if test="not(mcrxsl:isCurrentUserGuestUser()) and @read">
            <div id="mir_admindata_panel" class="card system">
              <div class="card-header">
                <h3 class="card-title">
                  <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.systembox')" />
                </h3>
              </div>
              <div class="card-body">

                <xsl:apply-templates select="div[@id='mir-admindata']" mode="newMetadata" />

              </div>
              <div
                  id="historyModal"
                  class="modal fade"
                  tabindex="-1"
                  role="dialog"
                  aria-labelledby="modal frame"
                  aria-hidden="true">
                <div
                  class="modal-dialog modal-lg modal-xl"
                  role="document">
                  <div class="modal-content">
                    <div class="modal-header">
                      <h4 class="modal-title" id="modalFrame-title">
                        <xsl:value-of select="i18n:translate('metadata.versionInfo.label')" />
                      </h4>
                      <button
                        type="button"
                        class="close modalFrame-cancel"
                        data-dismiss="modal"
                        aria-label="Close">
                        <i class="fas fa-times" aria-hidden="true"></i>
                      </button>
                    </div>
                    <div id="modalFrame-body" class="modal-body">
                      <xsl:apply-templates select="div[@id='mir-historydata']" mode="copyContent" />
                    </div>
                    <div class="modal-footer">
                      <button
                        id="modalFrame-cancel"
                        type="button"
                        class="btn btn-danger"
                        data-dismiss="modal">
                        <xsl:value-of select="i18n:translate('button.cancel')" />
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </xsl:if>

        </div>
      </div>


      <xsl:copy-of select="document(concat('xslTransform:schemaOrg:mcrobject:', @ID))" />
      <script src="{$WebApplicationBaseURL}mir-layout/assets/jquery/plugins/shariff/shariff.min.js"></script>
      <script src="{$WebApplicationBaseURL}assets/moment/min/moment.min.js"></script>
      <script src="{$WebApplicationBaseURL}assets/handlebars/handlebars.min.js"></script>
      <script src="{$WebApplicationBaseURL}js/mir/derivate-fileList.min.js"></script>
      <link rel="stylesheet" href="{$WebApplicationBaseURL}rsc/stat/{@ID}.css"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="citation_meta" mode="copyContent">
    <xsl:copy-of select="./*" />
  </xsl:template>

  <xsl:template match="div" mode="copyContent">
    <xsl:copy-of select="./*" />
  </xsl:template>

  <xsl:template match="div[@id='mir-metadata']" mode="newMetadata">
    <dl>
      <xsl:apply-templates select="table[@class='mir-metadata']/tr" mode="newMetadata" />
    </dl>
  </xsl:template>

  <xsl:template match="div[@id='mir-admindata']" mode="newMetadata">
    <dl>
      <xsl:apply-templates select=".//div[@id='system_box']/div[@id='system_content']/table/tr" mode="newMetadata" />
    </dl>
  </xsl:template>

  <xsl:template match="td[@class='metaname']" mode="newMetadata" priority="2">
    <dt>
      <xsl:copy-of select="node()|*" />
    </dt>
  </xsl:template>

  <xsl:template match="td[@class='metavalue']" mode="newMetadata" priority="2">
    <dd>
      <xsl:copy-of select="node()|*" />
    </dd>
  </xsl:template>

</xsl:stylesheet>
