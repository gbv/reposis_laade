<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
                xmlns:embargo="xalan://org.mycore.mods.MCRMODSEmbargoUtils"
                xmlns:piUtil="xalan://org.mycore.pi.frontend.MCRIdentifierXSLUtils"
                xmlns:encoder="xalan://java.net.URLEncoder"
                exclude-result-prefixes="i18n mcr mods acl xlink embargo encoder"
>
  <xsl:import href="xslImport:modsmeta:metadata/laade-track-list.xsl" />
  <xsl:template match="/">


    <!-- cover derivate exists -->
    <xsl:if test="mycoreobject/structure/derobjects/derobject/classification[@classid='derivate_types'][@categid='cover']">
      <xsl:variable name="cover_derivid" select="mycoreobject/structure/derobjects/derobject[classification[@classid='derivate_types'][@categid='cover']]/@xlink:href" />
      <xsl:choose>
        <!-- user has cover access -->
        <xsl:when test="key('rights', $cover_derivid)/@read">
          <!-- sound exists -->
          <xsl:if test="mycoreobject/structure/derobjects/derobject/classification[@classid='derivate_types'][@categid='sound']">
            <xsl:variable name="sound_derivid" select="mycoreobject/structure/derobjects/derobject[classification[@classid='derivate_types'][@categid='sound']]/@xlink:href" />
            <!-- user has sound access -->
            <xsl:choose>
              <xsl:when test="key('rights', $sound_derivid)/@read">

                <xsl:variable name="cover_der_uri" select="concat('ifs:',$cover_derivid,'/')" />
                <xsl:variable name="cover_der_xml" select="document($cover_der_uri)/mcr_directory/children" />
                <xsl:variable name="sound_der_uri" select="concat('ifs:',$sound_derivid,'/')" />
                <xsl:variable name="sound_der_xml" select="document($sound_der_uri)/mcr_directory/children" />

                <xsl:variable name="cover_front_filename">
                  <xsl:choose>
                    <xsl:when test="$cover_der_xml/child[contains(name, '001_cov')]/name">
                      <xsl:value-of select="$cover_der_xml/child[contains(name, '001_cov')]/name" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="mycoreobject/structure/derobjects/derobject[classification[@classid='derivate_types'][@categid='cover']]/maindoc"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:variable name="cover_back_filename" select="$cover_der_xml/child[contains(name, '002_cov')]/name" />

                <xsl:variable name="sound_ziplink" select="concat($ServletsBaseURL,'MCRZipServlet',$JSessionID,'?id=',$sound_derivid)" />


                <div id="laade-track-list">

                  <div class="row lde-tracks">
                    <div class="col-md-6">
                      <a href="{$WebApplicationBaseURL}rsc/viewer/{$cover_derivid}/{$cover_front_filename}" class="lde-currend-side-cover">
                        <img src="{$ServletsBaseURL}MCRTileCombineServlet/MID/{$cover_derivid}/{$cover_front_filename}" class="img-fluid" alt="..." />
                      </a>
                      <xsl:if test="$cover_back_filename">
                        <a href="{$WebApplicationBaseURL}rsc/viewer/{$cover_derivid}/{$cover_back_filename}" class="lde-currend-side-cover d-none">
                          <img src="{$ServletsBaseURL}MCRTileCombineServlet/MID/{$cover_derivid}/{$cover_back_filename}" class="img-fluid" alt="..." />
                        </a>
                        <a href="#" class="lde-js-coverToggle mt-1 d-block">
                          <i class="fas fa-reply"></i>
                          Cover wenden
                        </a>
                      </xsl:if>
                    </div>
                    <div class="col-md-6 mt-5 mt-md-0">

                      <ul class="nav nav-tabs lde-nav-tabs--light" id="lde-track-lists-nav" role="tablist">
                        <xsl:choose>
                          <xsl:when test="$sound_der_xml/child[contains(name,'_B_')]">
                            <li class="nav-item">
                              <a class="nav-link active" id="lde-side-a-tab" data-toggle="tab" href="#lde-side-a" role="tab" aria-controls="side-a" aria-selected="true">Seite A</a>
                            </li>
                            <li class="nav-item">
                              <a class="nav-link" id="lde-side-b-tab" data-toggle="tab" href="#lde-side-b" role="tab" aria-controls="side-b" aria-selected="false">Seite B</a>
                            </li>
                          </xsl:when>
                          <xsl:otherwise>
                            <li class="nav-item">
                              <a class="nav-link" id="lde-side-cd-tab" data-toggle="tab" href="#lde-cd" role="tab" aria-controls="side-cd" aria-selected="false">Titel</a>
                            </li>
                          </xsl:otherwise>
                        </xsl:choose>
                        <li class="nav-item ml-auto">
                          <xsl:apply-templates select="mycoreobject/structure/derobjects/derobject[classification[@classid='derivate_types'][@categid='sound']]" mode="laadeDerivateActions">
                            <xsl:with-param name="deriv" select="mycoreobject/structure/derobjects/derobject[classification[@classid='derivate_types'][@categid='sound']]/@xlink:href" />
                            <xsl:with-param name="parentObjID" select="mycoreobject/@ID" />
                          </xsl:apply-templates>
                        </li>
                      </ul>

                      <div class="tab-content" id="lde-track-lists">

                        <xsl:choose>
                          <xsl:when test="$sound_der_xml/child[contains(name,'_B_')]">

                            <div class="tab-pane fade show active" id="lde-side-a" role="tabpanel" aria-labelledby="Seite A">

                              <xsl:call-template name="generateTrackList">
                                <xsl:with-param name="sound_file_condition" select="'_A_'"/>
                                <xsl:with-param name="sound_der_xml" select="$sound_der_xml"/>
                                <xsl:with-param name="sound_derivid" select="$sound_derivid"/>
                              </xsl:call-template>

                            </div>
                            <div class="tab-pane fade" id="lde-side-b" role="tabpanel" aria-labelledby="Seite B">

                              <xsl:call-template name="generateTrackList">
                                <xsl:with-param name="sound_file_condition" select="'_B_'"/>
                                <xsl:with-param name="sound_der_xml" select="$sound_der_xml"/>
                                <xsl:with-param name="sound_derivid" select="$sound_derivid"/>
                              </xsl:call-template>

                            </div>
                          </xsl:when>
                          <xsl:otherwise>
                            <div class="tab-pane fade show active" id="lde-cd" role="tabpanel" aria-labelledby="Titel">

                              <xsl:call-template name="generateTrackList">
                                <xsl:with-param name="sound_file_condition" select="'.'"/>
                                <xsl:with-param name="sound_der_xml" select="$sound_der_xml"/>
                                <xsl:with-param name="sound_derivid" select="$sound_derivid"/>
                              </xsl:call-template>

                            </div>
                          </xsl:otherwise>
                        </xsl:choose>

                      </div>

                    </div>
                  </div>
                </div>
              </xsl:when>
              <!-- user has no sound access -->
              <xsl:otherwise>
                <xsl:comment>
                  <xsl:value-of select="'tracklist hidden: no &quot;sound&quot; permission'" />
                </xsl:comment>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
          <!-- sound not exists, nothing happen -->
        </xsl:when>
        <!-- user has no cover access -->
        <xsl:otherwise>
          <xsl:comment>
            <xsl:value-of select="'tracklist hidden: no &quot;cover&quot; permission'" />
          </xsl:comment>
          <!-- just show the cover and a access hint -->
          <xsl:variable name="object_id" select="mycoreobject/@ID" />
          <div id="laade-track-list">
            <div class="row lde-tracks mb-5">
              <div class="col-md-6">
                <a href="{$WebApplicationBaseURL}api/iiif/v2/image/thumbnail/{$object_id}/full/!1000,1000/0/color.jpg" class="lde-currend-side-cover">
                  <img src="{$WebApplicationBaseURL}api/iiif/v2/image/thumbnail/{$object_id}/full/!1000,1000/0/color.jpg" class="img-fluid" alt="Album cover" />
                </a>
              </div>
              <div class="col-md-6 mt-5 mt-md-0">
                <p>
                  <xsl:value-of select="i18n:translate('lde.no-derivat.permission')" /><br />
                  <a href="mailto:cwm_mund@uni-hildesheim.de">cwm_mund@uni-hildesheim.de</a>
                </p>
              </div>
            </div>
          </div>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <!-- cover not exists, nothing happen -->

    <xsl:apply-imports />
  </xsl:template>

  <xsl:template name="generateTrackList">
    <xsl:param name="sound_file_condition" />
    <xsl:param name="sound_der_xml" />
    <xsl:param name="sound_derivid" />

    <xsl:variable name="display-cell-class" select="'d-none d-sm-table-cell d-md-none d-lg-table-cell'" />

    <table class="table table-sm mt-3">
      <thead>
        <tr>
          <th scope="col">#</th>
          <th scope="col">Name</th>
          <th scope="col" class="{$display-cell-class}" >Datum</th>
          <th scope="col" class="{$display-cell-class}">Grösse</th>
        </tr>
      </thead>
      <tbody>
        <xsl:for-each select="$sound_der_xml/child[contains(name,$sound_file_condition)]">

          <xsl:variable name="formated_file_size">
            <xsl:call-template name="formatFileSize">
              <xsl:with-param name="size" select="size"/>
            </xsl:call-template>
          </xsl:variable>

          <xsl:variable name="formated_file_date">
            <xsl:call-template name="formatISODate">
              <xsl:with-param name="date" select="date[@type='lastModified']" />
              <xsl:with-param name="format" select="i18n:translate('metaData.date')" />
            </xsl:call-template>
          </xsl:variable>

          <tr>
            <td scope="row"><xsl:value-of select="position()"/></td>
            <td>
              <a
                href="#"
                data-prerendered-json="{$WebApplicationBaseURL}rsc/wavesurfer/{$sound_derivid}/{name}.json"
                data-baseurl="{$WebApplicationBaseURL}"
                data-derivid="{$sound_derivid}"
                data-track-name="{name}"
                title="{$formated_file_date} - {$formated_file_size}"
                class="lde-js-play-track">
                <i class="far fa-play-circle lde-play-button"></i>
                <i class="far fa-pause-circle lde-pause-button"></i>
                <xsl:value-of select="name"/>
              </a>
            </td>
            <td class="{$display-cell-class}">
              <xsl:value-of select="$formated_file_date" />
            </td>
            <td class="{$display-cell-class}">
              <span class="text-nowrap">
                <xsl:value-of select="$formated_file_size" />
              </span>
            </td>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template match="derobject" mode="laadeDerivateActions">
    <xsl:param name="deriv" />
    <xsl:param name="parentObjID" />

    <xsl:if
      test="(key('rights', $deriv)/@accKeyEnabled and key('rights', $deriv)/@readKey) and not(mcr:isCurrentUserGuestUser() or key('rights', $deriv)/@read or key('rights', $deriv)/@write)"
      >
      <div class="dropdown options  lde-options--light">
        <div class="btn-group">
          <a data-toggle="dropdown" class="btn btn-secondary dropdown-toggle" href="#" aria-expanded="false"><i class="fas fa-cog"></i> Aktionen</a>
          <ul class="dropdown-menu dropdown-menu-right">
            <li>
              <a class="option dropdown-item" tabindex="-1" href="{$WebApplicationBaseURL}authorization/accesskey.xed?objId={$deriv}&amp;url={encoder:encode(string($RequestURL))}">
                <xsl:value-of select="i18n:translate('mir.accesskey.setOnUser')" />
              </a>
            </li>
          </ul>
        </div>
      </div>
    </xsl:if>

    <xsl:if test="key('rights', $deriv)/@write">
      <xsl:variable select="concat('mcrobject:',$deriv)" name="derivlink" />
      <xsl:variable select="document($derivlink)" name="derivate" />

      <div class="dropdown options  lde-options--light">
        <div class="btn-group">
          <a data-toggle="dropdown" class="btn btn-secondary dropdown-toggle" href="#" aria-expanded="false"><i class="fas fa-cog"></i> Aktionen</a>
          <ul class="dropdown-menu dropdown-menu-right">
            <xsl:if test="key('rights', $deriv)/@write">
              <li>
                <a href="{$WebApplicationBaseURL}editor/editor-derivate.xed{$HttpSession}?derivateid={$deriv}" class="option dropdown-item">
                  <xsl:value-of select="i18n:translate('component.mods.metaData.options.updateDerivateName')" />
                </a>
              </li>
            </xsl:if>
            <xsl:if test="key('rights', $deriv)/@write">
              <li>
                <a href="{$ServletsBaseURL}MCRDisplayHideDerivateServlet?derivate={$deriv}" class="option dropdown-item">
                  <xsl:value-of select="i18n:translate(concat('mir.derivate.display.', $derivate//derivate/@display))" />
                </a>
              </li>
            </xsl:if>
            <xsl:if test="key('rights', $deriv)/@write">
              <li>
                <a href="{$ServletsBaseURL}MCRZipServlet/{$deriv}" class="option dropdown-item downloadzip">
                  <xsl:value-of select="i18n:translate('component.mods.metaData.options.zip')" />
                </a>
              </li>
            </xsl:if>
            <xsl:if test="key('rights', $deriv)/@delete">
              <li class="last">
                <a href="{$ServletsBaseURL}derivate/delete{$HttpSession}?id={$deriv}" class="option dropdown-item confirm_deletion" data-text="{i18n:translate('mir.confirm.derivate.text')}">
                  <xsl:value-of select="i18n:translate('component.mods.metaData.options.delDerivate')" />
                </a>
              </li>
            </xsl:if>
            <xsl:if test="key('rights', $deriv)/@accKeyEnabled and key('rights', $deriv)/@write">
              <xsl:variable name="action">
                <xsl:choose>
                  <xsl:when test="key('rights', $deriv)/@readKey">
                    <xsl:text>edit</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>create</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <li>
                <a class="option dropdown-item" tabindex="-1"
                  href="{$WebApplicationBaseURL}authorization/accesskey.xed?action={$action}&amp;objId={$deriv}&amp;url={encoder:encode(string($RequestURL))}"
                  >
                  <xsl:choose>
                    <xsl:when test="key('rights', $deriv)/@readKey">
                      <xsl:value-of select="i18n:translate('mir.accesskey.edit')" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="i18n:translate('mir.accesskey.add')" />
                    </xsl:otherwise>
                  </xsl:choose>
                </a>
              </li>
            </xsl:if>
          </ul>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
