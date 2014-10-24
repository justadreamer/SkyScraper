<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:str="http://exslt.org/strings"
extension-element-prefixes="str">

  <xsl:output method="text"/>

  <xsl:template match="/">

  {"continents":
  [
    <xsl:for-each select="//h1 | //div[@class='colmask']">
      <xsl:choose>
        <xsl:when test="name(.)='h1'">{"name":"<xsl:value-of select="."/>",</xsl:when>
        <xsl:when test="name(.)='div'">
          <xsl:call-template name="tpl_states" />}
          <xsl:if test="position()!=last()">,</xsl:if>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  ]
  }
  </xsl:template>

  <xsl:template name="tpl_states">
    "states":[
      <xsl:for-each select=".//h4 | .//ul">
        <xsl:choose>
          <xsl:when test="name(.)='h4'">{"name":"<xsl:value-of select="."/>",</xsl:when>
          <xsl:when test="name(.)='ul'"><xsl:call-template name="tpl_sites"/>}
            <xsl:if test="position()!=last()">,</xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
    ]
  </xsl:template>

  <xsl:template name="tpl_sites">
    "sites":[
      <xsl:for-each select=".//li/a">
        {"name":"<xsl:value-of select="."/>","link":"<xsl:value-of select="./@href"/>"}
        <xsl:if test="position()!=last()">,</xsl:if>
      </xsl:for-each>
    ]
  </xsl:template>

</xsl:stylesheet>