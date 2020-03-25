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
        <xsl:when test="key('rights', mycoreobject/@ID)/@read or ( key('rights', $cover_derivid)/@accKeyEnabled and key('rights', $sound_derivid)/@accKeyEnabled )">
          
          <xsl:variable name="cover_der_uri" select="concat('ifs:',$cover_derivid,'/')" />
          <xsl:variable name="cover_der_xml" select="document($cover_der_uri)/mcr_directory/children" />
          <xsl:variable name="sound_der_uri" select="concat('ifs:',$sound_derivid,'/')" />
          <xsl:variable name="sound_der_xml" select="document($sound_der_uri)/mcr_directory/children" />
          
          <xsl:variable name="cover_A_filename" select="$cover_der_xml/child[contains(name, '001_cov')]/name" />
          <xsl:variable name="cover_B_filename" select="$cover_der_xml/child[contains(name, '002_cov')]/name" />
          
          <xsl:variable name="sound_ziplink" select="concat($ServletsBaseURL,'MCRZipServlet',$JSessionID,'?id=',$sound_derivid)" />

  
          <div id="laade-track-list">
  
            <div class="row lde-tracks">
              <div class="col-6">
                <a href="{$WebApplicationBaseURL}rsc/viewer/{$cover_derivid}/{$cover_A_filename}" class="lde-currend-side-cover lde-currend-side-cover-1">
                  <img src="{$ServletsBaseURL}MCRFileNodeServlet/{$cover_derivid}/{$cover_A_filename}" class="img-fluid" alt="..." />
                </a>
                <a href="{$WebApplicationBaseURL}rsc/viewer/{$cover_derivid}/{$cover_B_filename}" class="lde-currend-side-cover d-none lde-currend-side-cover-2">
                  <img src="{$ServletsBaseURL}MCRFileNodeServlet/{$cover_derivid}/{$cover_B_filename}" class="img-fluid" alt="..." />
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
                            <a class="option downloadzip" href="{$sound_ziplink}">als Zip speichern</a>
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

                        <xsl:for-each select="$sound_der_xml/child[contains(name,'_A_')]">
                          <tr>
                            <th scope="row">1</th>
                            <td>
                              <a href="{$ServletsBaseURL}MCRFileNodeServlet/{$sound_derivid}/{name}" data-track-name="{name}" class="lde-js-play-track">
                                <i class="far fa-play-circle"></i>
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
                            <th scope="row">1</th>
                            <td>
                              <a href="{$ServletsBaseURL}MCRFileNodeServlet/{$sound_derivid}/{name}" data-track-name="{name}" class="lde-js-play-track">
                                <i class="far fa-play-circle"></i>
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
