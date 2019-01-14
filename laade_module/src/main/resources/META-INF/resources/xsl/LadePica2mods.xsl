<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:zs="http://www.loc.gov/zing/srw/"
                xmlns:pica="info:srw/schema/5/picaXML-v1.0">

  <xsl:output method="xml" indent="yes"/>

  <xsl:variable name="lb" select="'{'"/>
  <xsl:variable name="rb" select="'}'"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:variable name="sortTemp">
    <element name="typeOfResource"/>
    <element name="titleInfo"/>
    <element name="name"/>
    <element name="genre"/>
    <element name="originInfo"/>
    <element name="language"/>
    <element name="abstract"/>
    <element name="note"/>
    <element name="subject"/>
    <element name="classification"/>
    <element name="relatedItem"/>
    <element name="identifier"/>
    <element name="location"/>
    <element name="accessCondition"/>
  </xsl:variable>

  <xsl:template match="zs:searchRetrieveResponse">
    <xsl:variable name="modsDocs">
      <xsl:apply-templates select="zs:records/zs:record[zs:recordSchema='picaxml']/zs:recordData/pica:record"/>
    </xsl:variable>

    <xsl:for-each select="$modsDocs/mods:mods">
      <xsl:variable name="signatur" select="mods:location/mods:shelfLocator/text()"/>
      <xsl:if test="starts-with($signatur, 'WLMMA_CD') or starts-with($signatur, 'WLMMA_T')">
        <xsl:copy-of select="."/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="pica:record">
    <xsl:variable name="result">
      <xsl:apply-templates/>
    </xsl:variable>

    <mods:mods>
      <xsl:for-each select="$sortTemp/element">
        <xsl:variable name="elementName" select="@name"/>
        <xsl:copy-of select="$result/*[local-name()=$elementName]"/>
      </xsl:for-each>
    </mods:mods>
  </xsl:template>

  <xsl:template match="pica:datafield[@tag='021A']">
    <mods:titleInfo xlink:type="simple">
      <xsl:if test="./pica:subfield[@code='a']">
        <xsl:variable name="mainTitle" select="./pica:subfield[@code='a']"/>
        <xsl:choose>
          <xsl:when test="contains($mainTitle, '@')">
            <xsl:variable name="nonSort" select="normalize-space(substring-before($mainTitle, '@'))"/>
            <xsl:choose>
              <xsl:when test="string-length(nonSort) &lt; 9">
                <mods:nonSort>
                  <xsl:value-of select="$nonSort"/>
                </mods:nonSort>
                <mods:title>
                  <xsl:value-of select="substring-after($mainTitle, '@')"/>
                </mods:title>
              </xsl:when>
              <xsl:otherwise>
                <mods:title>
                  <xsl:value-of select="$mainTitle"/>
                </mods:title>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <mods:title>
              <xsl:value-of select="$mainTitle"/>
            </mods:title>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:if test="./pica:subfield[@code='d']">
        <mods:subTitle>
          <xsl:value-of select="./pica:subfield[@code='d']"/>
        </mods:subTitle>
      </xsl:if>
    </mods:titleInfo>
  </xsl:template>

  <!-- Ort und Verlag -->
  <xsl:template match="pica:datafield[@tag='033A']">
    <xsl:if test="count(pica:subfield[@code='p' or @code='n'])&gt;0">
      <mods:originInfo>
        <xsl:for-each select="distinct-values(pica:subfield[@code='p'])">
          <mods:place>
            <xsl:value-of select="."/>
          </mods:place>
        </xsl:for-each>
        <xsl:for-each select="distinct-values(pica:subfield[@code='n'])">
          <mods:publisher>
            <xsl:value-of select="."/>
          </mods:publisher>
        </xsl:for-each>
      </mods:originInfo>
    </xsl:if>

  </xsl:template>

  <!-- PPN -->
  <xsl:template match="pica:datafield[@tag='003@' and pica:subfield/@code='0']">
    <mods:identifier type="uri">
      <xsl:value-of select="concat('http://gso.gbv.de/DB=2.1/PPNSET?PPN=', pica:subfield[@code='0']/text())"/>
    </mods:identifier>
  </xsl:template>

  <!-- mods name -->
  <xsl:template match="pica:datafield[starts-with(@tag, '028')]">
    <xsl:variable name="picaRoles" select="./pica:subfield[@code='B']"/>

    <xsl:variable name="picaRolesString">
      <xsl:choose>
        <xsl:when test="count($picaRoles)&gt;1">
          <xsl:for-each select="picaRoles">
            <xsl:if test="position()&gt;1">
              <xsl:value-of select="','"/>
            </xsl:if>
            <xsl:value-of select="."/>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$picaRoles"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="roles">
      <xsl:choose>
        <xsl:when test="string-length($picaRolesString) &gt; 0">
          <xsl:for-each select="tokenize($picaRolesString, ',')">
            <xsl:if test="position()&gt;1">
              <xsl:value-of select="','"/>
            </xsl:if>
            <xsl:variable name="role" select="lower-case(normalize-space(.))"/>
            <xsl:choose>
              <xsl:when test="string-length($role)=0"></xsl:when>
              <xsl:when test="$pica2MARC/code[mapping/@from=$role]">
                <xsl:value-of select="$pica2MARC/code[mapping/@from=$role]/@name" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:message>Unknown person type found:
                  <xsl:value-of select="$role"/>
                </xsl:message>
                <xsl:value-of select="'ctb'"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'ctb'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="picaNode" select="."/>
    <xsl:for-each select="distinct-values(tokenize($roles, ','))">
      <mods:name type="personal">
        <mods:role>
          <mods:roleTerm authority="marcrelator" type="code">
            <xsl:value-of select="."/>
          </mods:roleTerm>
        </mods:role>
        <xsl:for-each select="distinct-values($picaNode/pica:subfield[@code='0'])">
          <mods:nameIdentifier>
            <xsl:attribute name="type">
              <xsl:value-of select="substring-before(., '/')"/>
            </xsl:attribute>
            <xsl:value-of select="substring-after(., '/')"/>
          </mods:nameIdentifier>
        </xsl:for-each>
        <xsl:for-each select="distinct-values($picaNode/pica:subfield[@code='a'])">
          <mods:namePart type="family">
            <xsl:value-of select="."/>
          </mods:namePart>
        </xsl:for-each>
        <xsl:for-each select="distinct-values($picaNode/pica:subfield[@code='d'])">
          <mods:namePart type="given">
            <xsl:value-of select="."/>
          </mods:namePart>
        </xsl:for-each>
        <xsl:for-each select="distinct-values($picaNode/pica:subfield[@code='P'])">
          <mods:namePart>
            <xsl:value-of select="."/>
          </mods:namePart>
        </xsl:for-each>
        <xsl:for-each select="distinct-values($picaNode/pica:subfield[@code='n'])">
          <mods:namePart type="termsOfAddress">
            <xsl:value-of select="."/>
          </mods:namePart>
        </xsl:for-each>
        <xsl:for-each select="distinct-values($picaNode/pica:subfield[@code='l'])">
          <mods:namePart type="termsOfAddress">
            <xsl:value-of select="."/>
          </mods:namePart>
        </xsl:for-each>
        <xsl:for-each select="distinct-values($picaNode/pica:subfield[@code='p'])">
          <mods:affiliation>
            <xsl:value-of select="."/>
          </mods:affiliation>
        </xsl:for-each>
      </mods:name>
    </xsl:for-each>
  </xsl:template>

  <!-- shelfLocator -->
  <xsl:template match="pica:datafield[@tag='209A' and pica:subfield/@code='a' and @occurrence='01']">
    <mods:location>
      <mods:shelfLocator>
        <xsl:value-of select="translate(pica:subfield[@code='a'], ' ','_')"/>
      </mods:shelfLocator>
    </mods:location>
  </xsl:template>

  <xsl:variable name="pica2MARC">
    <code name="asn">
      <mapping from="accociated name"/>
      <mapping from="asociated name"/>
      <mapping from="associated name"/>
      <mapping from="asscociated name"/>
    </code>
    <code name="arr">
      <mapping from="arr."/>
      <mapping from="arrangeurin"/>
    </code>
    <code name="aut">
      <mapping from="autor"/>
      <mapping from="vef."/>
      <mapping from="ver.f"/>
      <mapping from="ver."/>
      <mapping from="verf"/>
      <mapping from="verf."/>
      <mapping from="{$lb}verf."/>
      <mapping from="verf.."/>
      <mapping from="verfasserin"/>
      <mapping from="verfasser"/>
      <mapping from="[verf."/>
      <mapping from="verf:"/>
      <mapping from="vrf."/>
      <mapping from="mitverf."/>
    </code>
    <code name="edt">
      <mapping from="ed."/>
      <mapping from="herausgeberin"/>
      <mapping from="hrg."/>
      <mapping from="hrrsg."/>
      <mapping from="hrsg."/>
      <mapping from="hrsg.?"/>
      <mapping from="hrsg"/>
      <mapping from="hrsg.."/>
      <mapping from="red."/>
      <mapping from="redactor"/>
      <mapping from="bearb."/>
      <mapping from="bearb"/>
      <mapping from="bearb.]"/>
      <mapping from="berab."/>
    </code>
    <code name="chr">
      <mapping from="choreographer"/>
    </code>
    <code name="col">
      <mapping from="collector"/>
      <mapping from="samm."/>
      <mapping from="sammler"/>
    </code>
    <code name="com">
      <mapping from="compiler"/>
      <mapping from="zusammenstellender"/>
    </code>
    <code name="cnd">
      <mapping from="conductor"/>
      <mapping from="dirigentin"/>
      <mapping from="dirignetin"/>
      <mapping from="dirigent"/>
      <mapping from="leitung"/>
      <mapping from="ltg"/>
      <mapping from="ltg."/>
      <mapping from="musikalischer leiterin"/>
    </code>
    <code name="cre">
      <mapping from="creator"/>
    </code>
    <code name="edc">
      <mapping from="bearb. dir."/>
    </code>
    <code name="drt">
      <mapping from="direcor"/>
      <mapping from="director"/>
      <mapping from="regisseur"/>
      <mapping from="regisseurin"/>
      <mapping from="regie"/>
      <mapping from="dir." />
    </code>
    <code name="rce">
      <mapping from="engineer"/>
      <mapping from="recording engineer"/>
      <mapping from="recording enginner"/>
      <mapping from="record. engineer"/>
      <mapping from="recording rengineer"/>
      <mapping from="recordind engineer"/>
      <mapping from="recordin engineer"/>
      <mapping from="recording enginneer"/>
      <mapping from="recording enginer"/>
      <mapping from="recording engineers"/>
      <mapping from="recorded engineer"/>
      <mapping from="recording eingineer"/>
      <mapping from="recordimg engineer"/>
      <mapping from="recroding engineer"/>
      <mapping from="maestru de sunet"/>
    </code>
    <code name="mus">
      <mapping from="muiscian"/>
      <mapping from="muisician"/>
      <mapping from="muscian"/>
      <mapping from="musican"/>
      <mapping from="musician"/>
      <mapping from="musician]"/>
      <mapping from="musiciann"/>
      <mapping from="musisican"/>
    </code>
    <code name="pht">
      <mapping from="photogr"/>
      <mapping from="photogr."/>
      <mapping from="fotogr."/>
    </code>
    <code name="pro">
      <mapping from="poducer"/>
      <mapping from="prod."/>
      <mapping from="prodcuer"/>
      <mapping from="produced"/>
      <mapping from="producer"/>
      <mapping from="producing engineer"/>
      <mapping from="produktion"/>
      <mapping from="produzentin"/>
      <mapping from="hrsg. producer"/>
      <mapping from="[producer"/>
      <mapping from="produzent"/>
    </code>
    <code name="trl">
      <mapping from="transl."/>
      <mapping from="übbrs."/>
      <mapping from="über.s"/>
      <mapping from="übers."/>
      <mapping from="übers.-"/>
      <mapping from="üers."/>
      <mapping from="bers."/>
      <mapping from="übers"/>
      <mapping from="übesr."/>
    </code>
    <code name="sng">
      <mapping from="vocalist"/>
      <mapping from="interpret"/>
      <mapping from="intepr."/>
      <mapping from="interp."/>
      <mapping from="interpr"/>
      <mapping from="interpr."/>
      <mapping from="interpr.]"/>
      <mapping from="intper."/>
      <mapping from="intperpr."/>
      <mapping from="sängerin"/>
      <mapping from="sänger"/>
      <mapping from="singer. übers."/>
      <mapping from="singer"/>
    </code>
    <code name="cmp">
      <mapping from="komp"/>
      <mapping from="komp."/>
      <mapping from="komponistin"/>
      <mapping from="komponist"/>
      <mapping from="komponit"/>
      <mapping from="mutmaßl. komp."/>
      <mapping from="komp.?"/>
    </code>
    <code name="hst">
      <mapping from="gastgeberin"/>
    </code>
    <code name="dte">
      <mapping from="gef. person"/>
      <mapping from="gefeierter"/>
      <mapping from="widmungsempfänger"/>
    </code>
    <code name="wam">
      <mapping from="writer of acccompanying material"/>
      <mapping from="writer of accomanying material"/>
      <mapping from="writer of accomapanying material"/>
      <mapping from="writer of accompanying material"/>
      <mapping from="writer of accompanying material."/>
      <mapping from="writer of accompaying material"/>
      <mapping from="writer of acommpanying material"/>
      <mapping from="writer of acompanying material"/>
      <mapping from="writer off accompanying material"/>
      <mapping from="writerof accompanying material"/>
    </code>
    <code name="cmm">
      <mapping from="vorr"/>
      <mapping from="vorr."/>
      <mapping from="vorr.]"/>
    </code>
    <code name="cns">
      <mapping from="zensor"/>
    </code>
    <code name="itr">
      <mapping from="indtrumentalist"/>
      <mapping from="insrumentalist"/>
      <mapping from="instr."/>
      <mapping from="instruementalmusikerin"/>
      <mapping from="instrumantalist"/>
      <mapping from="instrumenalist"/>
      <mapping from="instrumenalmusikerin"/>
      <mapping from="instrumentalist"/>
      <mapping from="instrumentalimusikerin"/>
      <mapping from="instrumentaliste"/>
      <mapping from="instrumentalist]"/>
      <mapping from="instrumentalistin"/>
      <mapping from="instrumentalmusikerin"/>
      <mapping from="instrumentalmusiker"/>
      <mapping from="instrumentalmusikern"/>
      <mapping from="isntrumentalist"/>
      <mapping from="instrumentralist"/>
      <mapping from="instrumentalmusikter"/>
      <mapping from="intrumentalist"/>
      <mapping from="insturmentalist"/>
      <mapping from="instrumentlaist"/>
      <mapping from="instrumental"/>
      <mapping from="instrummentalist"/>
      <mapping from="instrumentelist"/>
      <mapping from="instumentalist"/>
      <mapping from="instrumentlist"/>
      <mapping from="vioarǎ"/>
      <mapping from="harmonica"/>
      <mapping from="bass"/>
      <mapping from="musik"/>
    </code>
    <code name="vac">
      <mapping from="speaker"/>
      <mapping from="sprecher"/>
      <mapping from="sprechsst."/>
      <mapping from="sprechst."/>
      <mapping from="sprechst.."/>
      <mapping from="sprechst.]"/>
      <mapping from="sprechstimme"/>
      <mapping from="sprecht."/>
      <mapping from="sprechtst."/>
      <mapping from="srechst."/>
      <mapping from="rednerin"/>
      <mapping from="rezitator"/>
    </code>
    <code name="trc">
      <mapping from="transcriber"/>
    </code>
    <code name="res">
      <mapping from="reasearcher"/>
      <mapping from="researcher"/>
    </code>
    <code name="mod">
      <mapping from="moderatorin"/>
    </code>
    <code name="ill">
      <mapping from="illl"/>
      <mapping from="ill."/>
      <mapping from="ill"/>
      <mapping from="illustratorin"/>
      <mapping from="il."/>
      <mapping from="lll."/>
    </code>
    <code name="nrt">
      <mapping from="erzähler"/>
    </code>
    <code name="act">
      <mapping from="schauspielerin"/>
      <mapping from="performer"/>
    </code>
  </xsl:variable>


</xsl:stylesheet>
