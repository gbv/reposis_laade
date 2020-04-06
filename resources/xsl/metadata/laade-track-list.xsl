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
                exclude-result-prefixes="i18n mcr mods acl xlink embargo"
>
  <xsl:import href="xslImport:modsmeta:metadata/laade-track-list.xsl" />
  <xsl:template match="/">
    <!-- check if sound and cover derivate exists -->
    <xsl:if test="mycoreobject/structure/derobjects/derobject/classification[@classid='derivate_types'][@categid='sound'] and
      mycoreobject/structure/derobjects/derobject/classification[@classid='derivate_types'][@categid='cover']">

      <xsl:variable name="cover_derivid" select="mycoreobject/structure/derobjects/derobject[classification[@classid='derivate_types'][@categid='cover']]/@xlink:href" />
      <xsl:variable name="sound_derivid" select="mycoreobject/structure/derobjects/derobject[classification[@classid='derivate_types'][@categid='sound']]/@xlink:href" />

      <xsl:choose>
        <xsl:when test="key('rights', $cover_derivid)/@read and key('rights', $sound_derivid)/@read">

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
              <div class="col-6">
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
              <div class="col-6">

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
                    <div class="dropdown options  lde-options--light">
                      <div class="btn-group">
                        <a data-toggle="dropdown" class="btn btn-secondary dropdown-toggle" href="#" aria-expanded="false"><i class="fas fa-cog"></i> Aktionen</a>
                        <ul class="dropdown-menu dropdown-menu-right" style="">
                          <li class="dropdown-item">
                            <a class="option downloadzip" href="{$sound_ziplink}">als Zip speichern</a>
                          </li>
                        </ul>
                      </div>
                    </div>
                  </li>
                </ul>

                <div class="tab-content" id="lde-track-lists">

                  <xsl:choose>
                    <xsl:when test="$sound_der_xml/child[contains(name,'_B_')]">
                      <div class="tab-pane fade show active" id="lde-side-a" role="tabpanel" aria-labelledby="Seite A">
                        <table class="table table-sm table-striped mt-1">
                          <thead>

                            <tr>
                              <th scope="col">#</th>
                              <th scope="col">Aktion</th>
                              <th scope="col">Name</th>
                              <th scope="col">Datum</th>
                              <th scope="col">Grösse</th>
                            </tr>

                          </thead>
                          <tbody>

                            <xsl:for-each select="$sound_der_xml/child[contains(name,'_A_')]">
                              <tr>
                                <th scope="row"><xsl:value-of select="position()"/></th>
                                <td>
                                  <a
                                    href="{$ServletsBaseURL}MCRFileNodeServlet/{$sound_derivid}/{name}"
                                    data-prerendered-json="{$WebApplicationBaseURL}rsc/wavesurfer/{$sound_derivid}/{name}.json"
                                    data-track-name="{name}"
                                    class="lde-js-play-track">
                                    <i class="far fa-play-circle lde-play-button"></i>
                                    <i class="far fa-pause-circle lde-pause-button"></i>
                                  </a>
                                </td>
                                <td>
                                  <a href="{$ServletsBaseURL}MCRFileNodeServlet/{$sound_derivid}/{name}">
                                    <xsl:value-of select="name"/>
                                  </a>
                                </td>
                                <td><xsl:value-of select="date[@type='lastModified']"/></td>
                                <td><xsl:value-of select="size"/></td>
                              </tr>
                            </xsl:for-each>

                          </tbody>
                        </table>
                      </div>
                      <div class="tab-pane fade" id="lde-side-b" role="tabpanel" aria-labelledby="Seite B">
                        <table class="table table-sm table-striped mt-3">
                          <thead>

                            <tr>
                              <th scope="col">#</th>
                              <th scope="col">Aktion</th>
                              <th scope="col">Name</th>
                              <th scope="col">Datum</th>
                              <th scope="col">Grösse</th>
                            </tr>

                          </thead>
                          <tbody>

                            <xsl:for-each select="$sound_der_xml/child[contains(name,'_B_')]">
                              <tr>
                                <th scope="row"><xsl:value-of select="position()"/></th>
                                <td>
                                  <a
                                    href="{$ServletsBaseURL}MCRFileNodeServlet/{$sound_derivid}/{name}"
                                    data-prerendered-json="{$WebApplicationBaseURL}rsc/wavesurfer/{$sound_derivid}/{name}.json"
                                    data-track-name="{name}"
                                    class="lde-js-play-track">
                                    <i class="far fa-play-circle lde-play-button"></i>
                                    <i class="far fa-pause-circle lde-pause-button"></i>
                                  </a>
                                </td>
                                <td>
                                  <a href="{$ServletsBaseURL}MCRFileNodeServlet/{$sound_derivid}/{name}">
                                    <xsl:value-of select="name"/>
                                  </a>
                                </td>
                                <td><xsl:value-of select="date[@type='lastModified']"/></td>
                                <td><xsl:value-of select="size"/></td>
                              </tr>
                            </xsl:for-each>

                          </tbody>
                        </table>
                      </div>
                    </xsl:when>
                    <xsl:otherwise>
                      <div class="tab-pane fade show active" id="lde-cd" role="tabpanel" aria-labelledby="CD">
                        <table class="table table-sm table-striped mt-1">
                          <thead>

                            <tr>
                              <th scope="col">#</th>
                              <th scope="col">Aktion</th>
                              <th scope="col">Name</th>
                              <th scope="col">Datum</th>
                              <th scope="col">Grösse</th>
                            </tr>

                          </thead>
                          <tbody>

                            <xsl:for-each select="$sound_der_xml/child">
                              <tr>
                                <th scope="row"><xsl:value-of select="position()"/></th>
                                <td>
                                  <a
                                    href="{$ServletsBaseURL}MCRFileNodeServlet/{$sound_derivid}/{name}"
                                    data-prerendered-json="{$WebApplicationBaseURL}rsc/wavesurfer/{$sound_derivid}/{name}.json"
                                    data-track-name="{name}"
                                    class="lde-js-play-track">
                                    <i class="far fa-play-circle lde-play-button"></i>
                                    <i class="far fa-pause-circle lde-pause-button"></i>
                                  </a>
                                </td>
                                <td>
                                  <a href="{$ServletsBaseURL}MCRFileNodeServlet/{$sound_derivid}/{name}">
                                    <xsl:value-of select="name"/>
                                  </a>
                                </td>
                                <td><xsl:value-of select="date[@type='lastModified']"/></td>
                                <td><xsl:value-of select="size"/></td>
                              </tr>
                            </xsl:for-each>

                          </tbody>
                        </table>
                      </div>
                    </xsl:otherwise>
                  </xsl:choose>


                </div>

              </div>
            </div>
          </div>
        </xsl:when>
        <xsl:otherwise>
          <xsl:comment>
            <xsl:value-of select="'mir-collapse-files: no &quot;view&quot; permission'" />
          </xsl:comment>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-imports />
  </xsl:template>
</xsl:stylesheet>