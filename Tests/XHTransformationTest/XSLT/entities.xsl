<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:str="http://exslt.org/strings"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                extension-element-prefixes="str">

<xsl:output method="text"/>

<xsl:template match="/">
  {
    "text":"<xsl:value-of select="//a"/>",
    "link":"<xsl:value-of select="//a/@href"/>"
  }
</xsl:template>

</xsl:stylesheet>