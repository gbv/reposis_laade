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
    <xsl:choose>
      <xsl:when test="key('rights', mycoreobject/@ID)/@read or key('rights', mycoreobject/structure/derobjects/derobject/@xlink:href)/@accKeyEnabled">

        <xsl:variable name="objID" select="mycoreobject/@ID" />

          <div id="laade-gallery">
            <div class="row lde-gallery">

              <div class="col-12 text-right">
                <div class="dropdown options lde-options--light">
                  <div class="btn-group">
                    <a data-toggle="dropdown" class="btn btn-secondary dropdown-toggle" href="#" aria-expanded="false"><i class="fas fa-cog"></i> Aktionen</a>
                    <ul class="dropdown-menu dropdown-menu-right" style="">
                      <li class="dropdown-item">
                        <a class="option downloadzip" href="http://localhost:8291/mir/servlets/MCRZipServlet/laadeT_derivate_00019600">als Zip speichern</a>
                      </li>
                    </ul>
                  </div>
                </div>
              </div>

              <div class="col-12">
                <div class="card-columns lde-thumnails">

                  <div class="card">
                    <a href="http://localhost:8291/mir/rsc/viewer/laadeT_derivate_00019599/WLMMA_T_24156_004_lab.jpg">
                      <img src="http://localhost:8291/mir/servlets/MCRFileNodeServlet/laadeT_derivate_00019599/WLMMA_T_24156_004_lab.jpg" class="card-img-top" alt="..." />
                    </a>
                  </div>

                  <div class="card">
                    <a href="http://localhost:8291/mir/rsc/viewer/laadeT_derivate_00019599/WLMMA_T_24156_003_lab.jpg">
                      <img src="http://localhost:8291/mir/servlets/MCRFileNodeServlet/laadeT_derivate_00019599/WLMMA_T_24156_003_lab.jpg" class="card-img-top" alt="..." />
                    </a>
                  </div>

                  <div class="card">
                    <a href="http://localhost:8291/mir/rsc/viewer/laadeT_derivate_00019599/WLMMA_T_24156_002_cov.jpg">
                      <img src="http://localhost:8291/mir/servlets/MCRFileNodeServlet/laadeT_derivate_00019599/WLMMA_T_24156_002_cov.jpg" class="card-img-top" alt="..." />
                    </a>
                  </div>

                  <div class="card">
                    <a href="http://localhost:8291/mir/rsc/viewer/laadeT_derivate_00019599/WLMMA_T_24156_001_cov.jpg">
                      <img src="http://localhost:8291/mir/servlets/MCRFileNodeServlet/laadeT_derivate_00019599/WLMMA_T_24156_001_cov.jpg" class="card-img-top" alt="..." />
                    </a>
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