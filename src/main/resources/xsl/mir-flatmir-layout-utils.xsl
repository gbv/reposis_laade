<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
    xmlns:mcrver="xalan://org.mycore.common.MCRCoreVersion"
    xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
    xmlns:calendar="xalan://java.util.GregorianCalendar"
    exclude-result-prefixes="i18n mcrver mcrxsl calendar">

  <xsl:import href="resource:xsl/layout/mir-common-layout.xsl" />

  <xsl:template name="mir.navigation">

    <!-- logo and menu -->
    <div class="lde-logo-box">
      <div class="container">
        <div class="row align-items-end">

          <!-- logo -->
          <div class="col lde-project-logo">
            <a href="https://www.uni-hildesheim.de/center-for-world-music/"
               class="lde-project-logo__link">
              <img class="lde-project-logo__image" src="{$WebApplicationBaseURL}images/logos/CWM_Logo_rgb_gruen-1.jpg" alt="" />
            </a>
            <a href="{concat($WebApplicationBaseURL,substring($loaded_navigation_xml/@hrefStartingPage,2),$HttpSession)}"
               class="lde-project-logo__link">
              <span class="lde-project-logo__slogan text-nowrap">Wolfgang Laade Music of Man Archive</span>
            </a>
          </div>

          <!-- main menu -->
          <div class="col-auto mir-main-nav">
            <nav class="navbar navbar-expand-md navbar-light">
              <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#mir-main-nav" aria-controls="mir-main-nav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
              </button>
              <div id="mir-main-nav" class="collapse navbar-collapse mir-main-nav-entries">
                <ul class="navbar-nav mr-auto">
                  <xsl:for-each select="$loaded_navigation_xml/menu">
                    <xsl:choose>
                      <xsl:when test="@id='main'"/> <!-- Ignore some menus, they are shown elsewhere in the layout -->
                      <xsl:when test="@id='brand'"/>
                      <xsl:when test="@id='below'"/>
                      <xsl:when test="@id='user'"/>
                      <xsl:otherwise>
                        <xsl:apply-templates select="."/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:for-each>
                  <xsl:call-template name="mir.basketMenu" />
                </ul>
              </div>
            </nav>
          </div>

          <!-- options -->
          <div class="col-auto mir-prop-nav">
            <nav>
              <ul class="navbar-nav ml-auto flex-row">
                <xsl:call-template name="mir.loginMenu" />
                <xsl:call-template name="mir.languageMenu" />
              </ul>
            </nav>
          </div>
        </div>
      </div>
    </div>

    <!-- image header -->
    <div class="lde-figure-head">
      <img
        class="lde-figure-head__image"
        src="{$WebApplicationBaseURL}images/backgrounds/2022018_Stammelbach_DKU5037-1_Musikarchiv-Stammelbachspeicher_Center-for-World-Music-CWM-Uni-Hildesheim_Foto-Daniel-Kunzfeld.jpg"
        alt=""/>
    </div>

    <!-- search bar -->
    <div class="lde-searchbar bg-primary">
      <div class="container">
        <div class="row ">
          <div class="col">
            <form action="{$WebApplicationBaseURL}servlets/solr/find" class="searchfield_box form-inline my-2" role="search">
              <button type="submit" class="btn btn-primary"><i class="fas fa-search"></i></button>
              <div class="form-group">
                <input name="condQuery" placeholder="{i18n:translate('mir.navsearch.placeholder')}" class="form-control search-query" id="searchInput" type="text" />
                <xsl:choose>
                  <xsl:when test="mcrxsl:isCurrentUserInRole('admin') or mcrxsl:isCurrentUserInRole('editor')">
                    <input name="owner" type="hidden" value="createdby:*" />
                  </xsl:when>
                  <xsl:when test="not(mcrxsl:isCurrentUserGuestUser())">
                    <input name="owner" type="hidden" value="createdby:{$CurrentUser}" />
                  </xsl:when>
                </xsl:choose>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="mir.jumbotwo">
    <!-- show only on startpage -->
    <xsl:if test="//div/@class='jumbotwo'">
      <div class="jumbotron">
        <div class="container">
          <h1>Mit MIR wird alles gut!</h1>
          <h2>your repository - just out of the box</h2>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="mir.footer">

    <div class="lde-logo-banner">
      <div class="container">
        <div class="row justify-content-center align-items-end">
          <div class="col-auto">
            <a href="https://www.uni-hildesheim.de/center-for-world-music/"
               class="lde-logo-banner__link">
              <img class="lde-logo-banner__image" src="{$WebApplicationBaseURL}images/logos/CWM_Logo_rgb_gruen-1.jpg" alt=""/>
            </a>
          </div>
          <div class="col-auto">
            <xsl:variable name="tmpDate" select="calendar:new()"/>
            <a href="{concat($WebApplicationBaseURL,substring($loaded_navigation_xml/@hrefStartingPage,2),$HttpSession)}"
               class="lde-logo-banner__link">
              <span class="lde-logo-banner__slogan">Wolfgang Laade Music of Man Archive</span>
              <span class="lde-logo-banner__copyright">© Center for World Music <xsl:value-of select="calendar:get($tmpDate, 1)"/></span>
            </a>
          </div>
        </div>
      </div>
    </div>

    <div class="container">
      <div class="row lde-sitemap">
        <div class="col">
          <ul class="internal_links">
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='below']/*" mode="footerMenu" />
          </ul>
        </div>
        <div class="col text-center text-md-right align-self-center">
          <a href="http://www.gbv.de/" class="laade-logo__link">
            <img
              src="{$WebApplicationBaseURL}images/logos/vzg_logo.svg"
              alt="Verbundzentrale des GBV"
              class="laade-logo__vzg" />
          </a>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="mir.powered_by">
    <xsl:variable name="mcr_version" select="concat('MyCoRe ',mcrver:getCompleteVersion())" />
    <div id="powered_by" class="laade-logo">
      <a href="http://www.mycore.de">
        <img
          src="{$WebApplicationBaseURL}mir-layout/images/mycore_logo_small_invert.png"
          title="{$mcr_version}"
          alt="powered by MyCoRe" />
      </a>
    </div>
  </xsl:template>

</xsl:stylesheet>
