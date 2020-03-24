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
    <xsl:choose>
      <xsl:when test="key('rights', mycoreobject/@ID)/@read or key('rights', mycoreobject/structure/derobjects/derobject/@xlink:href)/@accKeyEnabled">

        <xsl:variable name="objID" select="mycoreobject/@ID" />

        <div id="laade-track-list">

          <div class="row lde-tracks">
            <div class="col-6">
              <a href="http://localhost:8291/mir/rsc/viewer/laadeT_derivate_00019599/WLMMA_T_24156_001_cov.jpg" class="lde-currend-side-cover lde-currend-side-cover-1">
                <img src="http://localhost:8291/mir/servlets/MCRFileNodeServlet/laadeT_derivate_00019599/WLMMA_T_24156_001_cov.jpg" class="img-fluid" alt="..." />
              </a>
              <a href="http://localhost:8291/mir/rsc/viewer/laadeT_derivate_00019599/WLMMA_T_24156_002_cov.jpg" class="lde-currend-side-cover d-none lde-currend-side-cover-2">
                <img src="http://localhost:8291/mir/servlets/MCRFileNodeServlet/laadeT_derivate_00019599/WLMMA_T_24156_002_cov.jpg" class="img-fluid" alt="..." />
              </a>
            </div>
            <div class="col-6">

              <ul class="nav nav-tabs lde-nav-tabs--light" id="lde-track-lists-nav" role="tablist">
                <li class="nav-item">
                  <a class="nav-link active" id="lde-side-a-tab" data-toggle="tab" data-side-cover="lde-currend-side-cover-1" href="#lde-side-a" role="tab" aria-controls="side-a" aria-selected="true">Seite A</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" id="lde-side-b-tab" data-toggle="tab" data-side-cover="lde-currend-side-cover-2" href="#lde-side-b" role="tab" aria-controls="side-b" aria-selected="false">Seite B</a>
                </li>
                <li class="nav-item ml-auto">
                  <div class="dropdown options  lde-options--light">
                    <div class="btn-group">
                      <a data-toggle="dropdown" class="btn btn-secondary dropdown-toggle" href="#" aria-expanded="false"><i class="fas fa-cog"></i> Aktionen</a>
                      <ul class="dropdown-menu dropdown-menu-right" style="">
                        <li class="dropdown-item">
                          <a class="option downloadzip" href="http://localhost:8291/mir/servlets/MCRZipServlet/laadeT_derivate_00019600">als Zip speichern</a>
                        </li>
                      </ul>
                    </div>
                  </div>
                </li>
              </ul>

              <div class="tab-content" id="lde-track-lists">
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

                      <tr>
                        <th scope="row">1</th>
                        <td>
                          <a href="http://localhost:8291/mir/wavedata/WLMMA_T_24156_A_01.mp3" data-track-name="WLMMA_T_24156_A_01.mp3" class="lde-js-play-track">
                            <i class="far fa-play-circle"></i>
                          </a>
                        </td>
                        <td>
                          <a href="http://localhost:8291/mir/wavedata/WLMMA_T_24156_A_01.mp3">
                            WLMMA_T_24156_A_01.mp3
                          </a>
                        </td>
                        <td>20.03.2020</td>
                        <td>28 MB</td>
                      </tr>

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

                      <tr>
                        <th scope="row">1</th>
                        <td>
                          <a href="http://localhost:8291/mir/wavedata/WLMMA_T_24156_B_01.mp3" data-track-name="WLMMA_T_24156_B_01.mp3" class="lde-js-play-track">
                            <i class="far fa-play-circle"></i>
                          </a>
                        </td>
                        <td>
                          <a href="http://localhost:8291/mir/wavedata/WLMMA_T_24156_B_01.mp3">
                            WLMMA_T_24156_B_01.mp3
                          </a>
                        </td>
                        <td>20.03.2020</td>
                        <td>18 MB</td>
                      </tr>

                      <tr>
                        <th scope="row">2</th>
                        <td>
                          <a href="http://localhost:8291/mir/wavedata/WLMMA_T_24156_B_02.mp3" data-track-name="WLMMA_T_24156_B_02.mp3" class="lde-js-play-track">
                            <i class="far fa-play-circle"></i>
                          </a>
                        </td>
                        <td>
                          <a href="http://localhost:8291/mir/wavedata/WLMMA_T_24156_B_02.mp3">
                            WLMMA_T_24156_B_02.mp3
                          </a>
                        </td>
                        <td>20.03.2020</td>
                        <td>12 MB</td>
                      </tr>

                    </tbody>
                  </table>
                </div>
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
    <xsl:apply-imports />
  </xsl:template>
</xsl:stylesheet>

              <!--xsl:for-each select="mycoreobject/structure/derobjects/derobject[key('rights', @xlink:href)/@read]">
                <xsl:variable name="derId" select="@xlink:href" />
                <xsl:variable name="derivateXML" select="document(concat('mcrobject:',$derId))" />

                <div id="files{@xlink:href}" class="file_box">
                  <xsl:if test="classification/@categid='sound'">
                    <div class="row header">
                      <div class="col-12">
                        <div class="headline">
                          <div class="title">
                            <a class="btn btn-primary btn-sm file_toggle dropdown-toggle" data-toggle="collapse" href="#collapse{@xlink:href}" aria-expanded="false" aria-controls="collapse{@xlink:href}">
                              <span>
                                <xsl:choose>
                                  <xsl:when test="$derivateXML//titles/title[@xml:lang=$CurrentLang]">
                                    <xsl:value-of select="$derivateXML//titles/title[@xml:lang=$CurrentLang]" />
                                  </xsl:when>
                                  <xsl:when test="not(contains($derivateXML/mycorederivate/@label,'data object from'))">
                                    <xsl:value-of select="$derivateXML/mycorederivate/@label" />
                                  </xsl:when>
                                  <xsl:otherwise>
                                    <xsl:value-of select="i18n:translate('metadata.files.file')" />
                                  </xsl:otherwise>
                                </xsl:choose>
                              </span>
                              <xsl:if test="position() > 1">
                                <span class="set_number">
                                  <xsl:value-of select="position()" />
                                </span>
                              </xsl:if>
                            </a>
                            </div>
                          <xsl:apply-templates select="." mode="derivateActions">
                            <xsl:with-param name="deriv" select="@xlink:href" />
                            <xsl:with-param name="parentObjID" select="$objID" />
                          </xsl:apply-templates>
                          <div class="clearfix" />
                        </div>
                      </div>
                    </div>
                      <xsl:choose>
                      <xsl:when test="key('rights', @xlink:href)/@read">
                        <xsl:variable name="maindoc" select="$derivateXML/mycorederivate/derivate/internals/internal/@maindoc" />
                        <div class="file_box_files" data-objID="{$objID}" data-deriID="{$derId}" data-mainDoc="{$maindoc}" data-writedb="{acl:checkPermission($derId,'writedb')}"
                          data-deletedb="{acl:checkPermission($derId,'deletedb')}">
                          <xsl:if test="not(mcr:isCurrentUserGuestUser())">
                            <xsl:attribute name="data-jwt">
                              <xsl:value-of select="'required'" />
                            </xsl:attribute>
                          </xsl:if>
                          <div class="filelist-loading">
                            <div class="bounce1"></div>
                            <div class="bounce2"></div>
                            <div class="bounce3"></div>
                          </div>
                        </div>
                        <noscript>
                          <br />
                          <a href="{$ServletsBaseURL}MCRFileNodeServlet/{$derId}/">
                            <xsl:value-of select="i18n:translate('metadata.files.toDerivate')" />
                          </a>
                        </noscript>
                      </xsl:when>
                      <xsl:otherwise>
                        <div id="collapse{@xlink:href}" class="row body collapse in show">
                          <div class="col-12">
                            <xsl:value-of select="i18n:translate('mir.derivate.no_access')" />
                          </div>
                        </div>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:if>
                </div>
              </xsl:for-each-->
