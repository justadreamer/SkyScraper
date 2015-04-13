<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:str="http://exslt.org/strings"
    extension-element-prefixes="str">
    
    <xsl:output method="text"/>

    <xi:include href="tpl_sanitize.xsl" />

    <xsl:template match="/">
        {
        "title": "map",
        "ads": [<xsl:for-each select="//*[local-name()='dict'][position()!=last() and key[1]/text()!='GeoCluster']">
            {
            "postingID": "<xsl:value-of select="key[text()='PostingID']/following-sibling::*[1]/text()"/>",
            "title": "<xsl:call-template name="tpl_sanitize">
                <xsl:with-param name="text" select="key[text()='PostingTitle']/following-sibling::*[1]/text()"/>
            </xsl:call-template>",
            "link": "<xsl:value-of select="key[text()='PostingURL']/following-sibling::*[1]/text()"/>",
            "price": "<xsl:value-of select="key[text()='Ask']/following-sibling::*[1]/text()"/>"
            }<xsl:if test="position()!=last()">,</xsl:if>
        </xsl:for-each>]
        }
    </xsl:template>
    
</xsl:stylesheet>

