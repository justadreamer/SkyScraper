<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:str="http://exslt.org/strings"
                extension-element-prefixes="str">


<xsl:template match="/">
  {
  [
  <xsl:for-each select="//p[@class='row']">
    { 
      "postingID":"<xsl:value-of select="@data-pid"/>",
      "title":"<xsl:value-of select=".//span[@class='pl']/a"/>",
      "link":"<xsl:value-of select="$CLURL" /><xsl:value-of select="a/@href"/>",
      "thumbnail":"<xsl:value-of select="'http://images.craigslist.org/'"/><xsl:value-of select="str:replace(a/@data-id,':0','')" /><xsl:value-of select="'_300x300.jpg'" />",
      "date":"<xsl:value-of select=".//span[@class='date']"/>",
      "price":"<xsl:value-of select=".//span[@class='price']"/>",
      "location":"<xsl:value-of select="str:replace(str:replace(str:replace(.//span[@class='pnr']/*[1],' ',''),'(',''),')','')"/>",
    }<xsl:if test="position()!=last()">,</xsl:if>
  </xsl:for-each>
  ],
  "title":"<xsl:value-of select="//span[contains(@class,'pagenum')]"/>",
  "titleNext":"<xsl:value-of select="//a[contains(@class,'next')]"/>",
  "linkNext":"<xsl:value-of select="$CLURL" /><xsl:value-of select="//a[contains(@class,'next')]/@href" />"
  }
</xsl:template>

</xsl:stylesheet>