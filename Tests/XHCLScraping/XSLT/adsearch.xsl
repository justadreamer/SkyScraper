<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:str="http://exslt.org/strings"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                extension-element-prefixes="str">

<xsl:output method="text"/>

<xi:include href="tpl_prepend_url.xsl" />
<xi:include href="tpl_sanitize.xsl" />

<xsl:param name="URL-no-trailing-slash" select="substring($URL,1,string-length($URL)-1)" />

<xsl:template match="/">
  {
    "title":"<xsl:value-of select="//span[contains(@class,'pagenum')]"/>",
    "titleNext":"<xsl:value-of select="//a[contains(@class,'next')]"/>",
    "linkNext":"<xsl:value-of select="$baseURL" /><xsl:value-of select="//a[contains(@class,'next')]/@href" />",
    "ads":
  [
  <xsl:for-each select="//p[@class='row']">
    { 
      "postingID":"<xsl:value-of select="@data-pid"/>",
      "title":"<xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select=".//span[@class='pl']/a"/></xsl:call-template>",
      "link":"<xsl:call-template name="tpl_prepend_href_with_base_url"><xsl:with-param name="href" select="a/@href"/></xsl:call-template>",
      "thumbnail":"<xsl:value-of select="'http://images.craigslist.org/'"/><xsl:value-of select="str:replace(a/@data-id,':0','')" /><xsl:value-of select="'_300x300.jpg'" />",
      "date":"<xsl:value-of select=".//span[@class='date']"/>",
      "price":"<xsl:value-of select=".//span[@class='price']"/>",
      "location":"<xsl:value-of select="str:replace(str:replace(str:replace(.//span[@class='pnr']/*[1],' ',''),'(',''),')','')"/>"
    }<xsl:if test="position()!=last()">,</xsl:if>
  </xsl:for-each>
  ]

  }
</xsl:template>

</xsl:stylesheet>