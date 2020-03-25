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
  <xsl:import href="xslImport:modsmeta:metadata/laade-gallery.xsl" />
  <xsl:template match="/">
    <!-- check if cover derivate exists -->
    <xsl:if test="mycoreobject/structure/derobjects/derobject/classification[@classid='derivate_types'][@categid='cover']">
      
      <xsl:variable name="cover_derivid" select="mycoreobject/structure/derobjects/derobject[classification[@classid='derivate_types'][@categid='cover']]/@xlink:href" />
      
      <xsl:choose>
        <xsl:when test="key('rights', $cover_derivid)/@read">

          <xsl:variable name="ziplink" select="concat($ServletsBaseURL,'MCRZipServlet',$JSessionID,'?id=',$cover_derivid)" />
          <xsl:variable name="suburi" select="concat('ifs:',$cover_derivid,'/')" />
  
            <div id="laade-gallery">
              <div class="row lde-gallery">
  
                <div class="col-12 text-right">
                  <div class="dropdown options lde-options--light">
                    <div class="btn-group">
                      <a data-toggle="dropdown" class="btn btn-secondary dropdown-toggle" href="#" aria-expanded="false"><i class="fas fa-cog"></i> Aktionen</a>
                      <ul class="dropdown-menu dropdown-menu-right" style="">
                        <li class="dropdown-item">
                          <a class="option downloadzip" href="{$ziplink}">als Zip speichern</a>
                        </li>
                      </ul>
                    </div>
                  </div>
                </div>
  
                <div class="col-12">
                  <div class="card-columns lde-thumnails">
                    <xsl:for-each select="document($suburi)/mcr_directory/children/child">
                      <div class="card">
                        <a href="{$WebApplicationBaseURL}rsc/viewer/{$cover_derivid}/{name}">
                          <img src="{$ServletsBaseURL}MCRTileCombineServlet/MIN/{$cover_derivid}/{name}" class="card-img-top" alt="..." />
                        </a>
                      </div>
                    </xsl:for-each>
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