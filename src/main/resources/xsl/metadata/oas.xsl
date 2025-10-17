<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
                exclude-result-prefixes="mcri18n">
    <xsl:import href="xslImport:modsmeta:metadata/oas.xsl"/>
    <xsl:param name="MIR.OAS" select="'hide'"/>

    <xsl:template match=".">
        <xsl:if test="$MIR.OAS = 'show' and div[@id='mir-oastatistics']">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <xsl:value-of select="mcri18n:translate('mir.oas.panelheading')"/>
                    </h3>
                </div>
                <div class="panel-body" id="mir_oas">
                    <xsl:apply-templates select="div[@id='mir-oastatistics']" mode="copyContent"/>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="div" mode="copyContent">
        <xsl:copy-of select="./*" />
    </xsl:template>
</xsl:stylesheet>