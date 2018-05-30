<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:str="http://exslt.org/strings"
xmlns:xi="http://www.w3.org/2001/XInclude"
extension-element-prefixes="str">

<xsl:output method="text"/>

<xi:include href="tpl_prepend_url.xsl" />

<xsl:template match="/">

{"categories":
[
  <xsl:for-each select="//div[@class='col' and @id!='forums']">
      {
        "name":"<xsl:value-of select=".//h4[text()]"/><xsl:value-of select=".//h4//span[@class='txt']"/>",
        "link":"<xsl:value-of select="$URL"/><xsl:value-of select="@id"/>",
        "subcategories":
        [
          <xsl:for-each select=".//li/a">
            {
              "name":"<xsl:value-of select="."/>",
              "link":"<xsl:call-template name="tpl_prepend_href_with_base_url"><xsl:with-param name="href" select="./@href"/></xsl:call-template>"
            }
            <xsl:if test="position()!=last()">,</xsl:if>
          </xsl:for-each>
        ]
      }
      <xsl:if test="position()!=last()">,</xsl:if>
  </xsl:for-each>
]
}
</xsl:template>

</xsl:stylesheet>
