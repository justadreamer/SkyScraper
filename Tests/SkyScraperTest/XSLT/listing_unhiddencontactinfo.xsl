<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:str="http://exslt.org/strings"
    xmlns:exsl="http://exslt.org/common"
    xmlns:regexp="http://exslt.org/regular-expressions"
    extension-element-prefixes="str regexp">
    
    <xsl:import href="xml-to-string.xsl" />
    <xsl:import href="tpl_sanitize2.xsl" />
    
    <xsl:output method="text"/>
    
    <xsl:template match="/">
        <xsl:variable name="content">
            <xsl:call-template name="xml-to-string"> <xsl:with-param name="node-set" select="."/> </xsl:call-template>
        </xsl:variable>
        {
        <xsl:choose>
            <xsl:when test="//form[@id='standalone_captcha']">
                "has_captcha": true
            </xsl:when>
            <xsl:otherwise>
                "body": "<xsl:call-template name="tpl_sanitize"><xsl:with-param name="text"><xsl:value-of select="$content" /></xsl:with-param></xsl:call-template>",
                "descr": "<xsl:call-template name="tpl_sanitize"><xsl:with-param name="text"><xsl:value-of select="."/></xsl:with-param></xsl:call-template>"
            </xsl:otherwise>
        </xsl:choose>
        }
    </xsl:template>
    
    
</xsl:stylesheet>
