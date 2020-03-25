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
  <xsl:import href="xslImport:modsmeta:metadata/laade-player.xsl" />
  <xsl:template match="/">
    <!-- check if sound derivate exists -->
    <xsl:if test="mycoreobject/structure/derobjects/derobject/classification[@classid='derivate_types'][@categid='sound']">
      
      <xsl:variable name="sound_derivid" select="mycoreobject/structure/derobjects/derobject[classification[@classid='derivate_types'][@categid='sound']]/@xlink:href" />
      
      <xsl:choose>
        <xsl:when test="key('rights', mycoreobject/@ID)/@read or key('rights', $sound_derivid)/@accKeyEnabled">

  
          <div id="laade-player">
  
            <div class="row lde-player">
              <div class="col">
                <script src="{$WebApplicationBaseURL}js/wavesurfer.js"></script>
                <script src="{$WebApplicationBaseURL}js/wavesurfer.timeline.js"></script>
  
                <div id="waveform" class="text-center">
                  <div class="lde-message mt-5 text-center">Lade Datei und bereite Ansicht vor ...</div>
                  <div class="spinner-border mb-3 mt-3" role="status">
                    <span class="sr-only">Loading ...</span>
                  </div>
                  <div class="progress">
                    <div class="progress-bar progress-bar-striped" role="progressbar" style="width: 25%;" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100">0%</div>
                  </div>
                </div>
  
                <div class="row">
                  <div class="col">
                    <div id="wave-timeline"></div>
                  </div>
                </div>
  
                <div class="row d-none">
                  <div class="col-6">
                    <span class="lde-player-current">0</span>
                  </div>
                  <div class="col-6 text-right">
                    <span class="lde-player-duration">0</span>
                  </div>
                </div>
  
                <div class="row lde-player-controls">
                  <div class="col-auto">
                    <a href="#" class="lde-player-button lde-js-button-backward" title="Backward">
                      <i class="fa fa-backward"></i>
                    </a>
                  </div>
                  <div class="col-auto">
                    <a href="#" class="lde-player-button lde-js-button-play" title="Play">
                      <i class="fa fa-play lde-js-play"></i>
                      <i class="fa fa-pause lde-js-stop active d-none"></i>
                    </a>
                  </div>
                  <div class="col-auto">
                    <a href="#" class="lde-player-button lde-js-button-forward" title="Forward">
                      <i class="fa fa-forward"></i>
                    </a>
                  </div>
                  <div class="col-auto">
                    <a href="#" class="lde-player-button lde-js-button-loop" title="Loop">
                      <i class="fa fa-redo lde-js-loop"></i>
                    </a>
                  </div>
                  <div class="col text-center">
                    <span class="lde-current-track-name"><xsl:value-of select="mycoreobject/structure/derobjects/derobject/classification[@classid='derivate_types'][@categid='sound']/maindoc"/></span>
                  </div>
                  <div class="col-auto text-right">
                    <a href="#" class="lde-player-button lde-js-button-mute" title="Mute">
                      <i class="fa fa-volume-up lde-js-loud"></i>
                      <i class="fa fa-volume-mute lde-js-mute active d-none"></i>
                    </a>
                  </div>
                </div>
                <script src="{$WebApplicationBaseURL}js/laade-player.js"></script>
  
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
