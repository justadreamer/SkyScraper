<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:str="http://exslt.org/strings"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:regexp="http://exslt.org/regular-expressions"
                extension-element-prefixes="str regexp">

<xsl:output method="text"/>

<xi:include href="tpl_prepend_url.xsl" />
<xi:include href="tpl_sanitize.xsl" />

<xsl:param name="URL-no-trailing-slash" select="substring($URL,1,string-length($URL)-1)" />
<xsl:variable name="IMAGE_BASE_URL" select="'https://images.craigslist.org/'" />
<xsl:template match="/">
  {
    "title":"<xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select="//span[contains(@class,'pagenum')]"/></xsl:call-template>",
    "titleNext":"<xsl:value-of select="//a[contains(@class,'next')]"/>",
    "linkNext":"<xsl:value-of select="$baseURL" /><xsl:value-of select="//a[contains(@class,'next')]/@href" />",
    "ads":
  [
  <xsl:for-each select="//li[@class='result-row']">
    { 
      "postingID":"<xsl:value-of select="@data-pid"/>",
      "title":"<xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select="normalize-space(.//a[contains(@class,'result-title')])"/></xsl:call-template>",
      "link":"<xsl:value-of select="a/@href"/>",
      "thumbnail":"<xsl:if test="string(a/@data-ids)!=''">
          <xsl:for-each select="regexp:match(regexp:replace(string(a/@data-ids),'\d+:','i',''), '\w+', 'i')">
              <xsl:value-of select="$IMAGE_BASE_URL"/><xsl:value-of select="."/><xsl:value-of select="'_300x300.jpg'" />
          </xsl:for-each>
      </xsl:if>",
      "date":"<xsl:value-of select=".//time/@title"/>",
      "price":"<xsl:value-of select=".//span[@class='result-price'] | .//span[@class='result-age']"/>",
      <xsl:variable name="cleanPlace">
          <xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select=".//span[@class='result-hood']"/></xsl:call-template>
      </xsl:variable>
      "location":"<xsl:value-of select="str:replace(str:replace($cleanPlace,'(',''),')','')"/>"
    }<xsl:if test="position()!=last()">,</xsl:if>
  </xsl:for-each>
  ]

  }
</xsl:template>

</xsl:stylesheet>
